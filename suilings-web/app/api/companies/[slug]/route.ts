import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";

export const runtime = "nodejs";

interface RouteParams {
  params: Promise<{ slug: string }>;
}

export async function GET(_request: NextRequest, { params }: RouteParams) {
  try {
    const { slug } = await params;
    const admin = createAdminClient();

    const { data: company, error } = await admin
      .from("companies")
      .select("*")
      .eq("slug", slug)
      .single();

    if (error || !company) {
      return NextResponse.json({ error: "Company not found" }, { status: 404 });
    }

    const { data: listings } = await admin
      .from("job_listings")
      .select("id, title, type, location_type, location, salary_min, salary_max, currency, min_exercises_required, requires_credential, status, created_at")
      .eq("company_id", company.id)
      .eq("status", "open")
      .order("created_at", { ascending: false });

    return NextResponse.json({ company, listings: listings ?? [] });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to fetch company";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

export async function PATCH(request: NextRequest, { params }: RouteParams) {
  try {
    const { slug } = await params;
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const admin = createAdminClient();

    const { data: company } = await admin
      .from("companies")
      .select("id, admin_user_id")
      .eq("slug", slug)
      .single();

    if (!company) {
      return NextResponse.json({ error: "Company not found" }, { status: 404 });
    }
    if (company.admin_user_id !== user.id) {
      return NextResponse.json({ error: "Forbidden" }, { status: 403 });
    }

    const body = await request.json();
    const allowed = ["name", "description", "website", "logo_url", "contact_email"];
    const updates: Record<string, unknown> = {};
    for (const key of allowed) {
      if (body[key] !== undefined) updates[key] = body[key];
    }

    const { data: updated, error } = await admin
      .from("companies")
      .update(updates)
      .eq("id", company.id)
      .select()
      .single();

    if (error) throw error;

    return NextResponse.json({ company: updated });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to update company";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
