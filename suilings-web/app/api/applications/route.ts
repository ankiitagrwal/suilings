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

    const { data: applications, error } = await admin
      .from("job_applications")
      .select(`
        id, job_id, status, cover_note, applied_at,
        job_listings (
          id, title, type, location_type, location, status,
          companies (id, name, slug, logo_url, verified)
        )
      `)
      .eq("user_id", user.id)
      .order("applied_at", { ascending: false });

    if (error) throw error;

    return NextResponse.json({ applications: applications ?? [] });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to fetch applications";
    console.error("[/api/applications GET]", error);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
