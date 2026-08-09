import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import type { CreateJobPayload } from "@/types/jobs";

export const runtime = "nodejs";

export async function GET(request: NextRequest) {
  try {
    const admin = createAdminClient();
    const { searchParams } = request.nextUrl;

    const search = searchParams.get("search")?.trim() || "";
    const locationType = searchParams.get("location_type") || "";
    const requiresCredential = searchParams.get("requires_credential") === "true";
    const minExercises = parseInt(searchParams.get("min_exercises") || "0", 10);
    const jobType = searchParams.get("type") || "";
    const page = Math.max(1, parseInt(searchParams.get("page") || "1", 10));
    const limit = Math.min(50, Math.max(1, parseInt(searchParams.get("limit") || "24", 10)));

    let query = admin
      .from("job_listings")
      .select(`
        id, title, type, location_type, location,
        salary_min, salary_max, currency,
        min_exercises_required, requires_credential, tags,
        status, created_at,
        companies (id, name, slug, logo_url, verified)
      `, { count: "exact" })
      .eq("status", "open")
      .or(`expires_at.is.null,expires_at.gt.${new Date().toISOString()}`)
      .order("created_at", { ascending: false });

    if (search) query = query.ilike("title", `%${search}%`);
    if (locationType) query = query.eq("location_type", locationType);
    if (requiresCredential) query = query.eq("requires_credential", true);
    if (minExercises > 0) query = query.gte("min_exercises_required", minExercises);
    if (jobType) query = query.eq("type", jobType);

    const { data: jobs, error, count } = await query.range(
      (page - 1) * limit,
      page * limit - 1
    );

    if (error) throw error;

    return NextResponse.json({ jobs: jobs ?? [], total: count ?? 0, page, limit });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to fetch jobs";
    console.error("[/api/jobs GET]", error);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const admin = createAdminClient();

    const { data: company } = await admin
      .from("companies")
      .select("id, verified")
      .eq("admin_user_id", user.id)
      .single();

    if (!company) {
      return NextResponse.json(
        { error: "You must register a company before posting jobs" },
        { status: 403 }
      );
    }

    if (!company.verified) {
      return NextResponse.json(
        { error: "Your company must be verified before posting jobs. Verification is pending." },
        { status: 403 }
      );
    }

    const body = (await request.json()) as CreateJobPayload;
    const { title, description, type, location_type, location, salary_min, salary_max, currency, min_exercises_required, requires_credential, tags, expires_at } = body;

    if (!title?.trim()) {
      return NextResponse.json({ error: "Job title is required" }, { status: 400 });
    }
    if (!description?.trim()) {
      return NextResponse.json({ error: "Job description is required" }, { status: 400 });
    }

    if (salary_min != null && salary_min < 0) {
      return NextResponse.json({ error: "Minimum salary cannot be negative" }, { status: 400 });
    }
    if (salary_max != null && salary_max < 0) {
      return NextResponse.json({ error: "Maximum salary cannot be negative" }, { status: 400 });
    }
    if (salary_min && salary_max && salary_min > salary_max) {
      return NextResponse.json({ error: "Maximum salary must be greater than minimum" }, { status: 400 });
    }

    const { data: job, error } = await admin
      .from("job_listings")
      .insert({
        company_id: company.id,
        title: title.trim(),
        description: description.trim(),
        type: type ?? "full-time",
        location_type: location_type ?? "remote",
        location: location?.trim() ?? null,
        salary_min: salary_min ?? null,
        salary_max: salary_max ?? null,
        currency: currency ?? "USD",
        min_exercises_required: min_exercises_required ?? 0,
        requires_credential: requires_credential ?? false,
        tags: tags ?? [],
        expires_at: expires_at ?? null,
        status: "open",
      })
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ job }, { status: 201 });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to create job listing";
    console.error("[/api/jobs POST]", error);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
