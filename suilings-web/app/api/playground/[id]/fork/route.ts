import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

/**
 * POST /api/playground/[id]/fork
 * 
 * Fork (copy) a snippet
 */
export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const supabase = await createClient();
    
    // Check authentication
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    
    if (authError || !user) {
      return NextResponse.json(
        { error: "Unauthorized", message: "Please sign in to fork snippets" },
        { status: 401 }
      );
    }

    // Get original snippet
    const { data: original, error: getError } = await supabase
      .from("playground_snippets")
      .select("*")
      .eq("id", id)
      .single();

    if (getError || !original) {
      return NextResponse.json(
        { error: "Not Found", message: "Snippet not found" },
        { status: 404 }
      );
    }

    // Check if snippet is public (only public snippets can be forked)
    if (!original.is_public && original.user_id !== user.id) {
      return NextResponse.json(
        { error: "Forbidden", message: "Cannot fork private snippets" },
        { status: 403 }
      );
    }

    // Create forked snippet
    const { data: forked, error: forkError } = await supabase
      .from("playground_snippets")
      .insert({
        user_id: user.id,
        title: `${original.title} (Fork)`,
        code: original.code,
        description: original.description,
        is_public: original.is_public,
        forked_from: original.id,
      })
      .select()
      .single();

    if (forkError) {
      console.error("Failed to fork snippet:", forkError);
      return NextResponse.json(
        { error: "Database Error", message: "Failed to fork snippet" },
        { status: 500 }
      );
    }

    // Increment fork count atomically (non-blocking but reliable)
    // Using raw SQL increment to avoid race conditions
    Promise.resolve(supabase.rpc('increment_fork_count', { snippet_id: id }))
      .catch((err: unknown) => console.warn('Failed to increment fork count:', err));

    return NextResponse.json({
      success: true,
      message: "Snippet forked successfully",
      snippet: {
        id: forked.id,
        title: forked.title,
        forked_from: original.id,
        original_title: original.title,
      },
    });

  } catch (error) {
    console.error("Fork snippet error:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}
