import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { Footer } from "@/components/layout/Footer";
import { CompanyDashboardClient } from "@/components/company/CompanyDashboardClient";
import type { Company, JobListing } from "@/types/jobs";

export const metadata = {
  title: "Company Dashboard — Suilings",
};

interface ApplicationWithApplicant {
  id: string;
  job_id: string;
  user_id: string;
  status: "pending" | "reviewed" | "shortlisted" | "rejected";
  cover_note: string | null;
  applied_at: string;
  applicant: {
    id: string;
    username: string;
    full_name: string | null;
    avatar_url: string | null;
    location: string | null;
    github_username: string | null;
    completed_exercises: number;
    has_credential: boolean;
    profile_url: string;
  } | null;
}

export default async function CompanyDashboardPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login?redirect=/company/dashboard");
  }

  const admin = createAdminClient();

  const { data: company } = await admin
    .from("companies")
    .select("*")
    .eq("admin_user_id", user.id)
    .single();

  if (!company) {
    redirect("/company/register");
  }

  const { data: listings } = await admin
    .from("job_listings")
    .select("*")
    .eq("company_id", company.id)
    .order("created_at", { ascending: false });

  const jobs = (listings ?? []) as JobListing[];
  const jobIds = jobs.map((j) => j.id);

  let applications: ApplicationWithApplicant[] = [];

  if (jobIds.length > 0) {
    const { data: rawApps } = await admin
      .from("job_applications")
      .select("id, job_id, user_id, status, cover_note, applied_at")
      .in("job_id", jobIds)
      .order("applied_at", { ascending: false });

    if (rawApps && rawApps.length > 0) {
      const applicantIds = [...new Set(rawApps.map((a) => a.user_id))];

      const [{ data: profiles }, { data: progressRows }, { data: credentials }] = await Promise.all([
        admin
          .from("profiles")
          .select("id, username, full_name, avatar_url, location, github_username")
          .in("id", applicantIds),
        admin
          .from("exercise_progress")
          .select("user_id")
          .in("user_id", applicantIds)
          .eq("status", "completed"),
        admin
          .from("sbt_credentials")
          .select("user_id")
          .in("user_id", applicantIds),
      ]);

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
                completed_exercises: completedByUser.get(app.user_id) ?? 0,
                has_credential: credentialSet.has(app.user_id),
                profile_url: `/u/${profile.username}`,
              }
            : null,
        };
      });
    }
  }

  return (
    <>
      <SimpleHeader />
      <div className="min-h-screen bg-background">
        <CompanyDashboardClient
          company={company as Company}
          listings={jobs}
          applications={applications}
        />
      </div>
      <Footer />
    </>
  );
}
