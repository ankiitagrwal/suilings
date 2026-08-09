import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";

export const runtime = "nodejs";

interface RouteParams {
  params: Promise<{ id: string }>;
}

export async function GET(_request: NextRequest, { params }: RouteParams) {
  try {
    const { id } = await params;
    const admin = createAdminClient();

    const { data: job, error } = await admin
      .from("job_listings")
      .select(`
        *,
        companies (id, name, slug, description, website, logo_url, verified)
      `)
      .eq("id", id)
      .single();

    if (error || !job) {
      return NextResponse.json({ error: "Job not found" }, { status: 404 });
    }

    const { count: applicationCount } = await admin
      .from("job_applications")
      .select("id", { count: "exact", head: true })
      .eq("job_id", id);

    return NextResponse.json({ job, applicationCount: applicationCount ?? 0 });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to fetch job";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

export async function PATCH(request: NextRequest, { params }: RouteParams) {
  try {
    const { id } = await params;
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const admin = createAdminClient();

    const { data: job } = await admin
      .from("job_listings")
      .select("company_id")
      .eq("id", id)
      .single();

    if (!job) {
      return NextResponse.json({ error: "Job not found" }, { status: 404 });
    }

    const { data: company } = await admin
      .from("companies")
      .select("admin_user_id, verified")
      .eq("id", job.company_id)
      .single();

    if (!company || company.admin_user_id !== user.id) {
      return NextResponse.json({ error: "Forbidden" }, { status: 403 });
    }

    if (!company.verified) {
      return NextResponse.json({ error: "Your company must be verified to edit job listings" }, { status: 403 });
    }

    const body = await request.json();
    const allowed = ["title", "description", "type", "location_type", "location", "salary_min", "salary_max", "currency", "min_exercises_required", "requires_credential", "tags", "status", "expires_at"];
    const updates: Record<string, unknown> = {};
    for (const key of allowed) {
      if (body[key] !== undefined) updates[key] = body[key];
    }

    const { data: updated, error } = await admin
      .from("job_listings")
      .update(updates)
      .eq("id", id)
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ job: updated });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to update job";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

export async function DELETE(_request: NextRequest, { params }: RouteParams) {
  try {
    const { id } = await params;
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const admin = createAdminClient();

    const { data: job } = await admin
      .from("job_listings")
      .select("company_id")
      .eq("id", id)
      .single();

    if (!job) {
      return NextResponse.json({ error: "Job not found" }, { status: 404 });
    }

    const { data: company } = await admin
      .from("companies")
      .select("admin_user_id")
      .eq("id", job.company_id)
      .single();

    if (!company || company.admin_user_id !== user.id) {
      return NextResponse.json({ error: "Forbidden" }, { status: 403 });
    }

    const { error } = await admin
      .from("job_listings")
      .delete()
      .eq("id", id);

    if (error) throw error;

    return NextResponse.json({ success: true });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to delete job";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
