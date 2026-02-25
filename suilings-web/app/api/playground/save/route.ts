import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

/**
 * POST /api/playground/save
 * 
 * Saves a code snippet to the database
 */
export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    
    // Check authentication
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    
    if (authError || !user) {
      return NextResponse.json(
        { error: "Unauthorized", message: "Please sign in to save snippets" },
        { status: 401 }
      );
    }

    const { title, code, description, tags, is_public } = await request.json();

    // Validate inputs
    if (!code || typeof code !== 'string') {
      return NextResponse.json(
        { error: "Bad Request", message: "Code is required" },
        { status: 400 }
      );
    }

    if (code.length > 100000) {
      return NextResponse.json(
        { error: "Bad Request", message: "Code too large. Maximum size is 100KB" },
        { status: 400 }
      );
    }

    // Save snippet to database
    const { data, error } = await supabase
      .from("playground_snippets")
      .insert({
        user_id: user.id,
        title: title || "Untitled",
        code,
        description: description || null,
        tags: tags || [],
        is_public: is_public !== false, // Default to public
      })
      .select()
      .single();

    if (error) {
      console.error("Failed to save snippet:", error);
      return NextResponse.json(
        { error: "Database Error", message: "Failed to save snippet" },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      id: data.id,
      message: "Snippet saved successfully",
      snippet: {
        id: data.id,
        title: data.title,
        is_public: data.is_public,
        created_at: data.created_at,
      },
    });

  } catch (error) {
    console.error("Save snippet error:", error);
    return NextResponse.json(
      { 
        error: "Internal Server Error",
        message: error instanceof Error ? error.message : "An unexpected error occurred"
      },
      { status: 500 }
    );
  }
}
