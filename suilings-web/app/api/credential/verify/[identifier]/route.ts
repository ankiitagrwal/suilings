import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

/**
 * GET /api/credential/verify/:identifier
 * 
 * Public endpoint to verify a credential by:
 * - GitHub username (e.g., @username or username)
 * - Wallet address (e.g., 0x...)
 * - SBT Object ID (e.g., 0x...)
 * 
 * This endpoint is public and does not require authentication
 */
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ identifier: string }> }
) {
  try {
    const supabase = await createClient();
    const { identifier } = await params;
    let cleanIdentifier = identifier;

    // Remove @ prefix if present
    if (cleanIdentifier.startsWith("@")) {
      cleanIdentifier = cleanIdentifier.slice(1);
    }

    // Try to find credential using the stored function
    const { data, error } = await supabase
      .rpc("get_credential_by_identifier", {
        identifier: cleanIdentifier,
      });

    if (error) {
      console.error("Failed to verify credential:", error);
      return NextResponse.json(
        { 
          verified: false, 
          message: "Failed to verify credential" 
        },
        { status: 500 }
      );
    }

    // If no credential found
    if (!data || data.length === 0) {
      return NextResponse.json(
        { 
          verified: false, 
          message: "No credential found for this identifier" 
        },
        { status: 404 }
      );
    }

    const credential = data[0];

    // TEMPORARY: Hide SBT for test users (HIDE_SBT_FOR_USERNAMES)
    const { HIDE_SBT_FOR_USERNAMES } = await import("@/lib/config/credential-config");
    if (HIDE_SBT_FOR_USERNAMES.some((u) => (credential.github_username || "").toLowerCase() === u.toLowerCase())) {
      return NextResponse.json(
        { verified: false, message: "No credential found for this identifier" },
        { status: 404 }
      );
    }

    return NextResponse.json({
      verified: true,
      credential: {
        id: credential.sbt_object_id,
        user_id: credential.user_id || "",
        sbt_object_id: credential.sbt_object_id,
        github_username: credential.github_username,
        wallet_address: credential.wallet_address,
        completed_exercises: credential.completed_exercises,
        completion_date: credential.completion_date,
        streak_days: credential.streak_days,
        total_time_minutes: credential.total_time_minutes || 0,
        mint_transaction_digest: credential.mint_transaction_digest,
        mint_status: (credential.mint_status || "confirmed") as "pending" | "confirmed" | "failed",
        blockchain_network: credential.blockchain_network as "mainnet" | "testnet" | "devnet" | "localnet",
        metadata: credential.metadata || null,
        created_at: credential.created_at || credential.completion_date,
        updated_at: credential.updated_at || credential.completion_date,
        days_since_completion: credential.days_since_completion,
        avatar_url: credential.avatar_url,
        full_name: credential.full_name,
      },
      message: "Credential verified successfully",
    });

  } catch (error) {
    console.error("Credential verification error:", error);
    return NextResponse.json(
      { 
        verified: false,
        message: "An unexpected error occurred" 
      },
      { status: 500 }
    );
  }
}

