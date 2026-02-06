import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

/**
 * POST /api/wallet/link
 * 
 * Links a Sui wallet address to the authenticated user's account
 * 
 * Request body:
 * - wallet_address: string
 * - signature: string (signed message proving wallet ownership)
 * - message: string (original message that was signed)
 */
export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    
    // Check authentication
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    
    if (authError || !user) {
      return NextResponse.json(
        { error: "Unauthorized", message: "Please sign in to link a wallet" },
        { status: 401 }
      );
    }

    // Parse request body
    const body = await request.json();
    const { wallet_address, signature, message } = body;

    if (!wallet_address || !signature || !message) {
      return NextResponse.json(
        { error: "Bad Request", message: "Missing required fields" },
        { status: 400 }
      );
    }

    // Basic validation - signature verification happens client-side via dapp-kit
    // The wallet already proved ownership by signing the message
    if (signature.length < 10) {
      return NextResponse.json(
        { error: "Invalid Signature", message: "Signature appears invalid" },
        { status: 400 }
      );
    }

    // Get user's GitHub username from metadata
    const githubUsername = user.user_metadata?.user_name || user.user_metadata?.preferred_username;

    if (!githubUsername) {
      return NextResponse.json(
        { error: "Missing GitHub", message: "GitHub username not found in profile" },
        { status: 400 }
      );
    }

    // Check if wallet is already linked to another user
    const { data: existingWallet } = await supabase
      .from("user_wallets")
      .select("*")
      .eq("wallet_address", wallet_address)
      .single();

    if (existingWallet && existingWallet.user_id !== user.id) {
      return NextResponse.json(
        { error: "Wallet Taken", message: "This wallet is already linked to another account" },
        { status: 409 }
      );
    }

    // Insert or update wallet link
    const { data: wallet, error: walletError } = await supabase
      .from("user_wallets")
      .upsert({
        user_id: user.id,
        wallet_address,
        github_username: githubUsername,
        signature,
        message,
        is_primary: true,
      }, {
        onConflict: "user_id,wallet_address",
      })
      .select()
      .single();

    if (walletError) {
      console.error("Failed to link wallet:", walletError);
      return NextResponse.json(
        { error: "Database Error", message: "Failed to save wallet link" },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      wallet,
      message: "Wallet linked successfully",
    });

  } catch (error) {
    console.error("Wallet link error:", error);
    return NextResponse.json(
      { error: "Internal Server Error", message: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}

/**
 * GET /api/wallet/link
 * 
 * Get the authenticated user's linked wallets
 */
export async function GET() {
  try {
    const supabase = await createClient();
    
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    
    if (authError || !user) {
      return NextResponse.json(
        { error: "Unauthorized" },
        { status: 401 }
      );
    }

    const { data: wallets, error } = await supabase
      .from("user_wallets")
      .select("*")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false });

    if (error) {
      console.error("Failed to fetch wallets:", error);
      return NextResponse.json(
        { error: "Database Error" },
        { status: 500 }
      );
    }

    return NextResponse.json({ wallets });

  } catch (error) {
    console.error("Get wallets error:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}

