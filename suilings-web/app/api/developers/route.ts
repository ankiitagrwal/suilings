import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";

export const runtime = "nodejs";

export async function GET(request: NextRequest) {
  try {
    const admin = createAdminClient();
    const { searchParams } = request.nextUrl;

    // --- Query params ---
    const openToWorkOnly = searchParams.get("open_to_work") === "true";
    const credentialOnly = searchParams.get("credential_only") === "true";
    const minExercises = parseInt(searchParams.get("min_exercises") || "0", 10);
    const maxExercises = searchParams.get("max_exercises")
      ? parseInt(searchParams.get("max_exercises")!, 10)
      : null;
    const location = searchParams.get("location") || "";
    const role = searchParams.get("role") || "";
    const sort = searchParams.get("sort") || "most_exercises"; // most_exercises | longest_streak | recently_active
    const page = Math.max(1, parseInt(searchParams.get("page") || "1", 10));
    const limit = Math.min(50, Math.max(1, parseInt(searchParams.get("limit") || "24", 10)));

    // --- 1. Fetch profiles ---
    let profileQuery = admin
      .from("profiles")
      .select("id, username, full_name, avatar_url, location, bio, open_to_work, skills_summary, available_roles, github_username, created_at");

    if (openToWorkOnly) {
      profileQuery = profileQuery.eq("open_to_work", true);
    }
    if (location) {
      profileQuery = profileQuery.ilike("location", `%${location}%`);
    }
    if (role) {
      profileQuery = profileQuery.contains("available_roles", [role]);
    }

    const { data: profiles, error: profilesError } = await profileQuery;
    if (profilesError) {
      console.error("[/api/developers] profiles query failed:", JSON.stringify(profilesError));
      throw profilesError;
    }
    if (!profiles || profiles.length === 0) {
      return NextResponse.json({ developers: [], total: 0, page, limit });
    }

    const profileIds = profiles.map((p) => p.id);

    // --- 2. Fetch exercise progress for these users ---
    const { data: progressRows, error: progressError } = await admin
      .from("exercise_progress")
      .select("user_id, status, completed_at, updated_at")
      .in("user_id", profileIds);

    if (progressError) {
      console.error("[/api/developers] exercise_progress query failed:", JSON.stringify(progressError));
      throw progressError;
    }

    // Build per-user aggregates
    const progressByUser = new Map<
      string,
      { completed: number; lastActive: Date; streakDays: number }
    >();

    for (const id of profileIds) {
      const rows = progressRows?.filter((r) => r.user_id === id) ?? [];
      const completed = rows.filter((r) => r.status === "completed").length;
      const dates = rows
        .map((r) => new Date(r.completed_at || r.updated_at))
        .filter((d) => !isNaN(d.getTime()));
      const lastActive = dates.length > 0 ? new Date(Math.max(...dates.map((d) => d.getTime()))) : new Date(0);
      const streakDays = calculateStreak(rows);
      progressByUser.set(id, { completed, lastActive, streakDays });
    }

    // --- 3. Fetch SBT credentials for these users ---
    const { data: credentialRows, error: credentialError } = await admin
      .from("sbt_credentials")
      .select("user_id, sbt_object_id, created_at")
      .in("user_id", profileIds);

    if (credentialError) {
      console.error("[/api/developers] sbt_credentials query failed:", JSON.stringify(credentialError));
    }

    const credentialByUser = new Map<string, boolean>();
    credentialRows?.forEach((c) => credentialByUser.set(c.user_id, true));

    // --- 4. Compose developer entries ---
    let developers = profiles.map((p) => {
      const prog = progressByUser.get(p.id) ?? { completed: 0, lastActive: new Date(0), streakDays: 0 };
      return {
        id: p.id,
        username: p.username,
        displayName: p.full_name || p.username,
        avatarUrl: p.avatar_url,
        bio: p.bio,
        location: p.location,
        githubUsername: p.github_username,
        openToWork: p.open_to_work ?? false,
        skillsSummary: p.skills_summary,
        availableRoles: p.available_roles ?? [],
        completedExercises: prog.completed,
        streakDays: prog.streakDays,
        lastActive: prog.lastActive.toISOString(),
        hasCredential: credentialByUser.has(p.id),
        joinedAt: p.created_at,
      };
    });

    // --- 5. Apply post-fetch filters ---
    if (credentialOnly) {
      developers = developers.filter((d) => d.hasCredential);
    }
    if (minExercises > 0) {
      developers = developers.filter((d) => d.completedExercises >= minExercises);
    }
    if (maxExercises !== null) {
      developers = developers.filter((d) => d.completedExercises <= maxExercises);
    }

    // --- 6. Sort ---
    developers.sort((a, b) => {
      if (sort === "longest_streak") {
        if (b.streakDays !== a.streakDays) return b.streakDays - a.streakDays;
        return b.completedExercises - a.completedExercises;
      }
      if (sort === "recently_active") {
        return new Date(b.lastActive).getTime() - new Date(a.lastActive).getTime();
      }
      // default: most_exercises
      if (b.completedExercises !== a.completedExercises) return b.completedExercises - a.completedExercises;
      return b.streakDays - a.streakDays;
    });

    const total = developers.length;

    // --- 7. Paginate ---
    const offset = (page - 1) * limit;
    const paginated = developers.slice(offset, offset + limit);

    return NextResponse.json({ developers: paginated, total, page, limit });
  } catch (error: unknown) {
    // Supabase errors are plain objects with a `message` field, not Error instances
    const message =
      error instanceof Error
        ? error.message
        : (error as { message?: string })?.message ?? "Failed to fetch developers";
    console.error("[/api/developers] error:", JSON.stringify(error, null, 2));
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

function calculateStreak(rows: { status: string; completed_at?: string | null; updated_at?: string | null }[]): number {
  const completedDates = rows
    .filter((r) => r.status === "completed")
    .map((r) => {
      const d = new Date(r.completed_at || r.updated_at || "");
      return isNaN(d.getTime()) ? null : d;
    })
    .filter((d): d is Date => d !== null);

  if (completedDates.length === 0) return 0;

  // Unique calendar days (UTC)
  const daySet = new Set(completedDates.map((d) => d.toISOString().slice(0, 10)));
  const days = [...daySet].sort().reverse();

  const today = new Date().toISOString().slice(0, 10);
  const yesterday = new Date(Date.now() - 86400_000).toISOString().slice(0, 10);
  if (days[0] !== today && days[0] !== yesterday) return 0;

  let streak = 1;
  for (let i = 1; i < days.length; i++) {
    const prev = new Date(days[i - 1]);
    const curr = new Date(days[i]);
    const diff = (prev.getTime() - curr.getTime()) / 86400_000;
    if (diff === 1) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}
