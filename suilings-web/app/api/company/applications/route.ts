import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import type { ApplicationStatus } from "@/types/jobs";

export const runtime = "nodejs";

export async function PATCH(request: NextRequest) {
  try {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const admin = createAdminClient();

    const body = await request.json();
    const { application_id, status } = body as { application_id: string; status: ApplicationStatus };

    const validStatuses: ApplicationStatus[] = ["pending", "reviewed", "shortlisted", "rejected", "hired"];
    if (!validStatuses.includes(status)) {
      return NextResponse.json({ error: "Invalid status" }, { status: 400 });
    }

    const { data: application } = await admin
      .from("job_applications")
      .select("job_id")
      .eq("id", application_id)
      .single();

    if (!application) {
      return NextResponse.json({ error: "Application not found" }, { status: 404 });
    }

    const { data: job } = await admin
      .from("job_listings")
      .select("company_id")
      .eq("id", application.job_id)
      .single();

    const { data: company } = await admin
      .from("companies")
      .select("admin_user_id")
      .eq("id", job?.company_id)
      .single();

    if (!company || company.admin_user_id !== user.id) {
      return NextResponse.json({ error: "Forbidden" }, { status: 403 });
    }

    const { data: updated, error } = await admin
      .from("job_applications")
      .update({ status })
      .eq("id", application_id)
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ application: updated });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to update application";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
