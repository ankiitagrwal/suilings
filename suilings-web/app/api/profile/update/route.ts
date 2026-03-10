import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

export async function PATCH(request: NextRequest) {
  try {
    const supabase = await createClient();
    
    // Check authentication
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return NextResponse.json(
        { error: "Unauthorized" },
        { status: 401 }
      );
    }

    const body = await request.json();
    const {
      displayName,
      bio,
      githubUsername,
      twitterUsername,
      websiteUrl,
      location,
      openToWork,
      skillsSummary,
      availableRoles,
    } = body;

    // Validate inputs
    if (bio && bio.length > 500) {
      return NextResponse.json(
        { error: "Bio must be less than 500 characters" },
        { status: 400 }
      );
    }
    if (skillsSummary && skillsSummary.length > 300) {
      return NextResponse.json(
        { error: "Skills summary must be less than 300 characters" },
        { status: 400 }
      );
    }
    if (availableRoles !== undefined && !Array.isArray(availableRoles)) {
      return NextResponse.json(
        { error: "availableRoles must be an array" },
        { status: 400 }
      );
    }

    const updates: Record<string, unknown> = {};
    if (displayName !== undefined) updates.full_name = displayName;
    if (bio !== undefined) updates.bio = bio;
    if (location !== undefined) updates.location = location;
    if (githubUsername !== undefined) updates.github_username = githubUsername;
    if (twitterUsername !== undefined) updates.twitter_username = twitterUsername;
    if (websiteUrl !== undefined) updates.website = websiteUrl;
    if (openToWork !== undefined) updates.open_to_work = openToWork;
    if (skillsSummary !== undefined) updates.skills_summary = skillsSummary;
    if (availableRoles !== undefined) updates.available_roles = availableRoles;

    // Update profile (using existing profiles table)
    const { data, error } = await supabase
      .from("profiles")
      .update(updates)
      .eq("id", user.id)
      .select()
      .single();

    if (error) {
      console.error("Profile update error:", error);
      console.error("Error details:", JSON.stringify(error, null, 2));
      return NextResponse.json(
        { error: "Failed to update profile", details: error.message },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      profile: data,
    });
  } catch (error) {
    console.error("Profile update error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
