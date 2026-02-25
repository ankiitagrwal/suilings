import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ username: string }> }
) {
  try {
    const { username } = await params;
    const supabase = await createClient();

    // Get user profile (using existing profiles table)
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("*")
      .eq("username", username)
      .single();

    if (profileError || !profile) {
      return NextResponse.json(
        { error: "Profile not found" },
        { status: 404 }
      );
    }

    // Get exercise progress stats
    const { data: progress } = await supabase
      .from("exercise_progress")
      .select("*")
      .eq("user_id", profile.id);

    const completedExercises = progress?.filter(
      (p) => p.completed === true || p.is_completed === true || p.status === "completed"
    ).length || 0;

    const skippedExercises = progress?.filter((p) => p.is_skipped === true).length || 0;

    // Get SBT credential
    const { data: credential } = await supabase
      .from("sbt_credentials")
      .select("*")
      .eq("user_id", profile.id)
      .single();

    // TEMPORARY: Hide SBT for test users (HIDE_SBT_FOR_USERNAMES)
    const { HIDE_SBT_FOR_USERNAMES } = await import("@/lib/config/credential-config");
    const profileUsername = (profile.username || "").toLowerCase();
    const profileGithub = (profile.github_username || "").toLowerCase();
    const hideSbt = HIDE_SBT_FOR_USERNAMES.some(
      (u) => u.toLowerCase() === profileUsername || u.toLowerCase() === profileGithub
    );
    const resolvedCredential = credential && !hideSbt ? credential : null;

    // Get public snippets
    const { data: snippets } = await supabase
      .from("playground_snippets")
      .select("id, title, description, view_count, fork_count, created_at, tags")
      .eq("user_id", profile.id)
      .eq("is_public", true)
      .order("created_at", { ascending: false })
      .limit(12);

    // Get recent activity (optional - only if table exists)
    const { data: activity } = await supabase
      .from("activity_feed")
      .select("*")
      .eq("user_id", profile.id)
      .eq("is_public", true)
      .order("created_at", { ascending: false })
      .limit(10);

    return NextResponse.json({
      profile: {
        username: profile.username,
        displayName: profile.full_name || profile.display_name,
        bio: profile.bio,
        avatarUrl: profile.avatar_url,
        githubUsername: profile.github_username || profile.username,
        twitterUsername: profile.twitter_username,
        discordUsername: profile.discord_username,
        websiteUrl: profile.website || profile.website_url,
        location: profile.location,
        createdAt: profile.created_at,
      },
      stats: {
        completedExercises,
        skippedExercises,
        totalExercises: 82,
        completionRate: Math.round((completedExercises / 82) * 100),
      },
      credential: resolvedCredential ? {
        id: resolvedCredential.id,
        mintedAt: resolvedCredential.minted_at,
        transactionDigest: resolvedCredential.transaction_digest,
        objectId: resolvedCredential.object_id,
      } : null,
      snippets: snippets || [],
      activity: activity || [],
    });
  } catch (error) {
    console.error("Profile fetch error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
