import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { isPlatformAdmin } from "@/lib/admin";

export const runtime = "nodejs";

export async function GET() {
  try {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user || !isPlatformAdmin(user.email)) {
      return NextResponse.json({ error: "Forbidden" }, { status: 403 });
    }

    const admin = createAdminClient();

    const { data: companies, error } = await admin
      .from("companies")
      .select(`
        id, name, slug, description, website, logo_url,
        contact_email, verified, admin_user_id, created_at, updated_at
      `)
      .order("created_at", { ascending: false });

    if (error) throw error;

    // Enrich with admin profile info and job/application counts
    const enriched = await Promise.all(
      (companies ?? []).map(async (company) => {
        const [
          { data: adminProfile },
          { count: jobCount },
          { count: appCount },
        ] = await Promise.all([
          admin
            .from("profiles")
            .select("username, full_name, avatar_url, github_username")
            .eq("id", company.admin_user_id)
            .single(),
          admin
            .from("job_listings")
            .select("id", { count: "exact", head: true })
            .eq("company_id", company.id),
          admin
            .from("job_applications")
            .select("id", { count: "exact", head: true })
            .in(
              "job_id",
              (
                await admin
                  .from("job_listings")
                  .select("id")
                  .eq("company_id", company.id)
              ).data?.map((j) => j.id) ?? []
            ),
        ]);

        return {
          ...company,
          admin_profile: adminProfile,
          job_count: jobCount ?? 0,
          application_count: appCount ?? 0,
        };
      })
    );

    return NextResponse.json({ companies: enriched });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to fetch companies";
    console.error("[/api/admin/companies GET]", error);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user || !isPlatformAdmin(user.email)) {
      return NextResponse.json({ error: "Forbidden" }, { status: 403 });
    }

    const admin = createAdminClient();
    const body = await request.json();
    const { company_id, verified } = body as { company_id: string; verified: boolean };

    if (!company_id || typeof verified !== "boolean") {
      return NextResponse.json({ error: "company_id and verified (boolean) are required" }, { status: 400 });
    }

    const { data: updated, error } = await admin
      .from("companies")
      .update({ verified })
      .eq("id", company_id)
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ company: updated });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to update company";
    console.error("[/api/admin/companies PATCH]", error);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
