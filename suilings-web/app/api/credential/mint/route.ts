import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { SuiClient } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { fromBase64 } from "@mysten/sui/utils";
import { decodeSuiPrivateKey } from "@mysten/sui/cryptography";
import { REQUIRED_EXERCISES_FOR_CREDENTIAL } from "@/lib/config/credential-config";

// Environment variables for Sui network and contract
const SUI_NETWORK = process.env.SUI_NETWORK || "testnet";
const SUI_RPC_URL = process.env.SUI_RPC_URL || "https://sui-testnet-rpc.publicnode.com";
const CREDENTIAL_PACKAGE_ID = process.env.CREDENTIAL_PACKAGE_ID;
const CREDENTIAL_ADMIN_CAP_ID = process.env.CREDENTIAL_ADMIN_CAP_ID;
const CREDENTIAL_REGISTRY_ID = process.env.CREDENTIAL_REGISTRY_ID;
const ADMIN_WALLET_PRIVATE_KEY = process.env.ADMIN_WALLET_PRIVATE_KEY;

/**
 * POST /api/credential/mint
 * 
 * Mints a Soulbound Token (SBT) credential for the authenticated user
 * 
 * Requirements:
 * - User must be authenticated
 * - User must have completed all 82 exercises
 * - User must have a linked wallet
 * - User must not already have a credential
 * 
 * Request body:
 * - wallet_address: string (recipient wallet)
 */
export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    
    // Check authentication
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    
    if (authError || !user) {
      return NextResponse.json(
        { error: "Unauthorized", message: "Please sign in to mint a credential" },
        { status: 401 }
      );
    }

    // Parse request body
    const body = await request.json();
    const { wallet_address } = body;

    if (!wallet_address) {
      return NextResponse.json(
        { error: "Bad Request", message: "Wallet address is required" },
        { status: 400 }
      );
    }

    // Verify environment variables
    if (!CREDENTIAL_PACKAGE_ID || !CREDENTIAL_ADMIN_CAP_ID || !CREDENTIAL_REGISTRY_ID || !ADMIN_WALLET_PRIVATE_KEY) {
      console.error("Missing contract configuration");
      return NextResponse.json(
        { error: "Configuration Error", message: "Smart contract not configured" },
        { status: 500 }
      );
    }

    // Check if user already has a credential
    const { data: existingCredential } = await supabase
      .from("sbt_credentials")
      .select("*")
      .eq("user_id", user.id)
      .single();

    if (existingCredential) {
      return NextResponse.json(
        { error: "Already Minted", message: "You already have a credential" },
        { status: 409 }
      );
    }

    // Get user's completion data from exercise_progress table
    const { data: progressData, error: progressError } = await supabase
      .from("exercise_progress")
      .select("*")
      .eq("user_id", user.id);

    if (progressError) {
      console.error("Failed to fetch progress for minting:", progressError);
      return NextResponse.json(
        { 
          error: "Database Error", 
          message: "Failed to check progress",
          debug: {
            error_code: progressError.code,
            error_message: progressError.message
          }
        },
        { status: 500 }
      );
    }

    // Filter completed exercises (handle different column names)
    const completedData = progressData?.filter(p => 
      p.completed === true || 
      p.is_completed === true || 
      p.status === 'completed'
    ) || [];

    const completedExercises = completedData.length;
    
    console.log(`User ${user.id} has ${completedExercises} completed exercises out of ${progressData?.length || 0} total`);

    if (completedExercises < REQUIRED_EXERCISES_FOR_CREDENTIAL) {
      return NextResponse.json(
        { error: "Not Eligible", message: `Complete all ${REQUIRED_EXERCISES_FOR_CREDENTIAL} exercises first (${completedExercises}/${REQUIRED_EXERCISES_FOR_CREDENTIAL})` },
        { status: 400 }
      );
    }

    // Get GitHub username
    const githubUsername = user.user_metadata?.user_name || user.user_metadata?.preferred_username;

    if (!githubUsername) {
      return NextResponse.json(
        { error: "Missing GitHub", message: "GitHub username not found" },
        { status: 400 }
      );
    }

    // Calculate streak days (simplified - you may want more complex logic)
    const { data: statsData } = await supabase
      .from("user_stats")
      .select("current_streak")
      .eq("user_id", user.id)
      .single();

    const streakDays = statsData?.current_streak || 0;

    // Calculate total time (if tracked)
    const totalTimeMinutes = 0; // TODO: Implement time tracking

    // Initialize Sui client
    const suiClient = new SuiClient({ url: SUI_RPC_URL });

    // Initialize admin keypair - handle both bech32 and base64 formats
    let adminKeypair: Ed25519Keypair;
    try {
      if (ADMIN_WALLET_PRIVATE_KEY.startsWith('suiprivkey')) {
        // Bech32 format (e.g., suiprivkey1...)
        const { secretKey } = decodeSuiPrivateKey(ADMIN_WALLET_PRIVATE_KEY);
        adminKeypair = Ed25519Keypair.fromSecretKey(secretKey);
      } else {
        // Base64 format
        adminKeypair = Ed25519Keypair.fromSecretKey(fromBase64(ADMIN_WALLET_PRIVATE_KEY));
      }
    } catch (error) {
      console.error("Failed to parse admin private key:", error);
      return NextResponse.json(
        { 
          error: "Configuration Error", 
          message: "Invalid admin wallet private key format. Please check ADMIN_WALLET_PRIVATE_KEY in .env" 
        },
        { status: 500 }
      );
    }

    // Get current timestamp
    const completionTimestamp = Date.now();

    // Create transaction to mint credential
    const tx = new Transaction();

    // Call mint_credential function
    tx.moveCall({
      target: `${CREDENTIAL_PACKAGE_ID}::credential::mint_credential`,
      arguments: [
        tx.object(CREDENTIAL_ADMIN_CAP_ID), // admin_cap
        tx.object(CREDENTIAL_REGISTRY_ID), // registry
        tx.pure.address(wallet_address), // recipient
        tx.pure.string(githubUsername), // github_username
        tx.pure.u64(completedExercises), // exercises_completed
        tx.pure.u64(completionTimestamp), // completion_timestamp
        tx.pure.u64(streakDays), // streak_days
        tx.pure.u64(totalTimeMinutes), // total_time_minutes
        tx.object("0x6"), // clock object
      ],
    });

    // Execute transaction
    const result = await suiClient.signAndExecuteTransaction({
      signer: adminKeypair,
      transaction: tx,
      options: {
        showEffects: true,
        showObjectChanges: true,
      },
    });

    // Check if transaction was successful
    if (result.effects?.status?.status !== "success") {
      console.error("Transaction failed:", result.effects?.status);
      return NextResponse.json(
        { error: "Mint Failed", message: "Transaction failed on blockchain" },
        { status: 500 }
      );
    }

    // Extract the created SBT object ID
    const createdObjects = result.objectChanges?.filter(
      (change) => change.type === "created"
    );

    const sbtObject = createdObjects?.find((obj) =>
      obj.objectType?.includes("::credential::SuilingsCredential")
    );

    if (!sbtObject || !("objectId" in sbtObject)) {
      console.error("Failed to find SBT object in transaction result");
      return NextResponse.json(
        { error: "Mint Failed", message: "Failed to retrieve credential object" },
        { status: 500 }
      );
    }

    const sbtObjectId = sbtObject.objectId;
    const transactionDigest = result.digest;

    // Save credential to database using admin client (bypasses RLS)
    const supabaseAdmin = createAdminClient();
    const { data: credential, error: credentialError } = await supabaseAdmin
      .from("sbt_credentials")
      .insert({
        user_id: user.id,
        wallet_address,
        sbt_object_id: sbtObjectId,
        github_username: githubUsername,
        completed_exercises: completedExercises,
        completion_date: new Date().toISOString(),
        streak_days: streakDays,
        total_time_minutes: totalTimeMinutes,
        mint_transaction_digest: transactionDigest,
        mint_status: "confirmed",
        blockchain_network: SUI_NETWORK,
        metadata: {
          minted_at: completionTimestamp,
          package_id: CREDENTIAL_PACKAGE_ID,
        },
      })
      .select()
      .single();

    if (credentialError) {
      console.error("Failed to save credential:", credentialError);
      console.error("Error details:", {
        code: credentialError.code,
        message: credentialError.message,
        details: credentialError.details,
        hint: credentialError.hint,
      });
      
      // Credential minted on blockchain but DB save failed
      // Return error so user knows something is wrong
      return NextResponse.json(
        { 
          error: "Database Save Failed", 
          message: "Credential was minted on blockchain but failed to save to database. Please contact support with your transaction details.",
          blockchain_tx: transactionDigest,
          sbt_object_id: sbtObjectId,
          explorer_url: `${SUI_NETWORK === "mainnet" ? "https://suivision.xyz" : "https://testnet.suivision.xyz"}/object/${sbtObjectId}`,
          debug: {
            error_code: credentialError.code,
            error_message: credentialError.message,
            error_details: credentialError.details,
          }
        },
        { status: 500 }
      );
    }

    // Generate explorer URL (SuiVision)
    const explorerBaseUrl = SUI_NETWORK === "mainnet" 
      ? "https://suivision.xyz"
      : "https://testnet.suivision.xyz";
    const explorerUrl = `${explorerBaseUrl}/object/${sbtObjectId}`;

    return NextResponse.json({
      success: true,
      credential,
      sbt_object_id: sbtObjectId,
      transaction_digest: transactionDigest,
      explorer_url: explorerUrl,
      message: "Credential minted successfully!",
    });

  } catch (error) {
    console.error("Credential mint error:", error);
    return NextResponse.json(
      { 
        error: "Internal Server Error", 
        message: error instanceof Error ? error.message : "An unexpected error occurred" 
      },
      { status: 500 }
    );
  }
}

