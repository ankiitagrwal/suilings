import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";

export const runtime = "nodejs";

interface RouteParams {
  params: Promise<{ id: string }>;
}

export async function POST(request: NextRequest, { params }: RouteParams) {
  try {
    const { id: jobId } = await params;
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const admin = createAdminClient();

    const { data: job } = await admin
      .from("job_listings")
      .select("id, status, min_exercises_required, requires_credential, company_id, expires_at")
      .eq("id", jobId)
      .single();

    if (!job) {
      return NextResponse.json({ error: "Job not found" }, { status: 404 });
    }
    if (job.status !== "open") {
      return NextResponse.json({ error: "This position is no longer accepting applications" }, { status: 409 });
    }
    if (job.expires_at && new Date(job.expires_at) < new Date()) {
      return NextResponse.json({ error: "This position has expired" }, { status: 409 });
    }

    // Check company is verified
    const { data: jobCompany } = await admin
      .from("companies")
      .select("verified")
      .eq("id", job.company_id)
      .single();

    if (!jobCompany?.verified) {
      return NextResponse.json({ error: "This company is not verified" }, { status: 403 });
    }

    // Check if already applied
    const { data: existing } = await admin
      .from("job_applications")
      .select("id")
      .eq("job_id", jobId)
      .eq("user_id", user.id)
      .single();

    if (existing) {
      return NextResponse.json({ error: "You have already applied to this position" }, { status: 409 });
    }

    // Check minimum exercises requirement
    if (job.min_exercises_required > 0) {
      const { count } = await admin
        .from("exercise_progress")
        .select("id", { count: "exact", head: true })
        .eq("user_id", user.id)
        .eq("status", "completed");

      if ((count ?? 0) < job.min_exercises_required) {
        return NextResponse.json(
          { error: `You need at least ${job.min_exercises_required} completed exercises to apply` },
          { status: 422 }
        );
      }
    }

    // Check credential requirement
    if (job.requires_credential) {
      const { data: credential } = await admin
        .from("sbt_credentials")
        .select("id")
        .eq("user_id", user.id)
        .single();

      if (!credential) {
        return NextResponse.json(
          { error: "This position requires a Suilings credential (SBT)" },
          { status: 422 }
        );
      }
    }

    const body = await request.json();
    const cover_note = body.cover_note?.trim() || null;

    const { data: application, error } = await admin
      .from("job_applications")
      .insert({
        job_id: jobId,
        user_id: user.id,
        cover_note,
        status: "pending",
      })
      .select()
      .single();

    if (error) {
      if (error.code === "23505") {
        return NextResponse.json({ error: "You have already applied to this position" }, { status: 409 });
      }
      throw error;
    }

    return NextResponse.json({ application }, { status: 201 });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to submit application";
    console.error("[/api/jobs/[id]/apply POST]", error);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

export async function GET(_request: NextRequest, { params }: RouteParams) {
  try {
    const { id: jobId } = await params;
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const admin = createAdminClient();

    const { data: application } = await admin
      .from("job_applications")
      .select("id, status, applied_at")
      .eq("job_id", jobId)
      .eq("user_id", user.id)
      .single();

    return NextResponse.json({ application: application ?? null });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to check application status";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
