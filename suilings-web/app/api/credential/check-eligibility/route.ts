import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { REQUIRED_EXERCISES_FOR_CREDENTIAL, IS_TESTING_MODE } from "@/lib/config/credential-config";

const TOTAL_EXERCISES = REQUIRED_EXERCISES_FOR_CREDENTIAL;

/**
 * GET /api/credential/check-eligibility
 * 
 * Checks if the authenticated user is eligible to mint a credential
 * 
 * Requirements:
 * - Completed all 82 exercises
 * - Has a linked wallet
 * - Has not already minted a credential
 */
export async function GET() {
  try {
    const supabase = await createClient();
    
    // Check authentication
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    
    if (authError || !user) {
      return NextResponse.json(
        { error: "Unauthorized", message: "Please sign in to check eligibility" },
        { status: 401 }
      );
    }

    // Get user's progress from exercise_progress table
    const { data: progressData, error: progressError } = await supabase
      .from("exercise_progress")
      .select("*")
      .eq("user_id", user.id);

    if (progressError) {
      console.error("Failed to fetch progress:", progressError);
      console.error("Error details:", {
        code: progressError.code,
        message: progressError.message,
        details: progressError.details,
        hint: progressError.hint
      });
      return NextResponse.json(
        { 
          error: "Database Error", 
          message: "Failed to check progress",
          debug: {
            error_code: progressError.code,
            error_message: progressError.message,
            error_details: progressError.details
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
    const missingExercises = TOTAL_EXERCISES - completedExercises;
    const hasCompletedAll = completedExercises >= TOTAL_EXERCISES;

    // Check if user has a linked wallet
    const { data: walletData } = await supabase
      .from("user_wallets")
      .select("wallet_address")
      .eq("user_id", user.id)
      .limit(1)
      .single();

    const hasWalletLinked = !!walletData;

    // Check if user already has a credential
    const { data: credentialData } = await supabase
      .from("sbt_credentials")
      .select("id")
      .eq("user_id", user.id)
      .limit(1)
      .single();

    const alreadyMinted = !!credentialData;

    // User is eligible if they've completed all exercises, have a wallet, and haven't minted yet
    const eligible = hasCompletedAll && hasWalletLinked && !alreadyMinted;

    return NextResponse.json({
      eligible,
      completed_exercises: completedExercises,
      missing_exercises: missingExercises,
      total_exercises: TOTAL_EXERCISES,
      has_wallet_linked: hasWalletLinked,
      already_minted: alreadyMinted,
      requirements: {
        complete_all_exercises: hasCompletedAll,
        link_wallet: hasWalletLinked,
        not_already_minted: !alreadyMinted,
      },
    });

  } catch (error) {
    console.error("Check eligibility error:", error);
    return NextResponse.json(
      { error: "Internal Server Error", message: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}

