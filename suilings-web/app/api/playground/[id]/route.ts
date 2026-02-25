import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

/**
 * GET /api/playground/[id]
 * 
 * Get a snippet by ID
 */
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const supabase = await createClient();

    // Get snippet
    const { data, error } = await supabase
      .from("playground_snippets")
      .select("*")
      .eq("id", id)
      .single();

    if (error || !data) {
      return NextResponse.json(
        { error: "Not Found", message: "Snippet not found" },
        { status: 404 }
      );
    }

    // Check if user can view this snippet
    const { data: { user } } = await supabase.auth.getUser();
    
    if (!data.is_public && (!user || user.id !== data.user_id)) {
      return NextResponse.json(
        { error: "Forbidden", message: "This snippet is private" },
        { status: 403 }
      );
    }

    // Increment view count atomically (non-blocking but reliable)
    // Using raw SQL increment to avoid race conditions
    Promise.resolve(supabase.rpc('increment_view_count', { snippet_id: id }))
      .catch((err: unknown) => console.warn('Failed to increment view count:', err));

    return NextResponse.json({
      success: true,
      snippet: data,
    });

  } catch (error) {
    console.error("Get snippet error:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}

/**
 * PATCH /api/playground/[id]
 * 
 * Update a snippet (owner only)
 */
export async function PATCH(
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
        { error: "Unauthorized" },
        { status: 401 }
      );
    }

    const updates = await request.json();

    // Validate updates
    if (updates.code && updates.code.length > 100000) {
      return NextResponse.json(
        { error: "Bad Request", message: "Code too large" },
        { status: 400 }
      );
    }

    // Update snippet (only if user owns it)
    const { data, error } = await supabase
      .from("playground_snippets")
      .update({
        ...(updates.title && { title: updates.title }),
        ...(updates.code && { code: updates.code }),
        ...(updates.description !== undefined && { description: updates.description }),
        ...(updates.tags !== undefined && { tags: updates.tags }),
        ...(updates.is_public !== undefined && { is_public: updates.is_public }),
        updated_at: new Date().toISOString(),
      })
      .eq("id", id)
      .eq("user_id", user.id) // Only allow updating own snippets
      .select()
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return NextResponse.json(
          { error: "Not Found", message: "Snippet not found or you don't have permission" },
          { status: 404 }
        );
      }
      
      console.error("Update snippet error:", error);
      return NextResponse.json(
        { error: "Database Error", message: "Failed to update snippet" },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      message: "Snippet updated successfully",
      snippet: data,
    });

  } catch (error) {
    console.error("Update snippet error:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}

/**
 * DELETE /api/playground/[id]
 * 
 * Delete a snippet (owner only)
 */
export async function DELETE(
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
        { error: "Unauthorized" },
        { status: 401 }
      );
    }

    // Delete snippet (only if user owns it)
    const { error } = await supabase
      .from("playground_snippets")
      .delete()
      .eq("id", id)
      .eq("user_id", user.id);

    if (error) {
      console.error("Delete snippet error:", error);
      return NextResponse.json(
        { error: "Database Error", message: "Failed to delete snippet" },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      message: "Snippet deleted successfully",
    });

  } catch (error) {
    console.error("Delete snippet error:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}
