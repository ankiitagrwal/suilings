import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import type { CreateCompanyPayload } from "@/types/jobs";

export const runtime = "nodejs";

export async function GET() {
  try {
    const admin = createAdminClient();
    const { data: companies, error } = await admin
      .from("companies")
      .select("*")
      .order("created_at", { ascending: false });

    if (error) throw error;

    return NextResponse.json({ companies: companies ?? [] });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to fetch companies";
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

    // Check if user already administers a company
    const { data: existing } = await admin
      .from("companies")
      .select("id")
      .eq("admin_user_id", user.id)
      .single();

    if (existing) {
      return NextResponse.json(
        { error: "You already have a registered company" },
        { status: 409 }
      );
    }

    const body = (await request.json()) as CreateCompanyPayload;
    const { name, slug, description, website, logo_url, contact_email } = body;

    if (!name?.trim()) {
      return NextResponse.json({ error: "Company name is required" }, { status: 400 });
    }
    if (!slug?.trim()) {
      return NextResponse.json({ error: "Company slug is required" }, { status: 400 });
    }

    const normalizedSlug = slug.trim().toLowerCase().replace(/[^a-z0-9-]/g, "-");

    const { data: company, error } = await admin
      .from("companies")
      .insert({
        name: name.trim(),
        slug: normalizedSlug,
        description: description?.trim() ?? null,
        website: website?.trim() ?? null,
        logo_url: logo_url?.trim() ?? null,
        contact_email: contact_email?.trim() ?? null,
        admin_user_id: user.id,
        verified: false,
      })
      .select()
      .single();

    if (error) {
      if (error.code === "23505") {
        return NextResponse.json(
          { error: "A company with that slug already exists" },
          { status: 409 }
        );
      }
      throw error;
    }

    return NextResponse.json({ company }, { status: 201 });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to create company";
    console.error("[/api/companies POST]", error);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
