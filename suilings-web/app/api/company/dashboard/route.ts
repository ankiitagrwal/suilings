import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";

export const runtime = "nodejs";

export async function GET() {
  try {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const admin = createAdminClient();

    const { data: company } = await admin
      .from("companies")
      .select("*")
      .eq("admin_user_id", user.id)
      .single();

    if (!company) {
      return NextResponse.json({ company: null, listings: [], applications: [] });
    }

    const { data: listings } = await admin
      .from("job_listings")
      .select("*")
      .eq("company_id", company.id)
      .order("created_at", { ascending: false });

    const listingIds = (listings ?? []).map((l) => l.id);

    let applications: unknown[] = [];
    if (listingIds.length > 0) {
      const { data: rawApps } = await admin
        .from("job_applications")
        .select("id, job_id, user_id, status, cover_note, applied_at")
        .in("job_id", listingIds)
        .order("applied_at", { ascending: false });

      if (rawApps && rawApps.length > 0) {
        const applicantIds = [...new Set(rawApps.map((a) => a.user_id))];

        const { data: profiles } = await admin
          .from("profiles")
          .select("id, username, full_name, avatar_url, location, github_username, bio, skills_summary, available_roles")
          .in("id", applicantIds);

        const { data: progressRows } = await admin
          .from("exercise_progress")
          .select("user_id")
          .in("user_id", applicantIds)
          .eq("status", "completed");

        const { data: credentials } = await admin
          .from("sbt_credentials")
          .select("user_id")
          .in("user_id", applicantIds);

        const profileMap = new Map((profiles ?? []).map((p) => [p.id, p]));
        const completedByUser = new Map<string, number>();
        for (const row of progressRows ?? []) {
          completedByUser.set(row.user_id, (completedByUser.get(row.user_id) ?? 0) + 1);
        }
        const credentialSet = new Set((credentials ?? []).map((c) => c.user_id));

        applications = rawApps.map((app) => {
          const profile = profileMap.get(app.user_id);
          return {
            ...app,
            applicant: profile
              ? {
                  id: profile.id,
                  username: profile.username,
                  full_name: profile.full_name,
                  avatar_url: profile.avatar_url,
                  location: profile.location,
                  github_username: profile.github_username,
                  bio: profile.bio,
                  skills_summary: profile.skills_summary,
                  available_roles: profile.available_roles ?? [],
                  completed_exercises: completedByUser.get(app.user_id) ?? 0,
                  has_credential: credentialSet.has(app.user_id),
                  profile_url: `/u/${profile.username}`,
                }
              : null,
          };
        });
      }
    }

    return NextResponse.json({ company, listings: listings ?? [], applications });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to fetch dashboard data";
    console.error("[/api/company/dashboard GET]", error);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
