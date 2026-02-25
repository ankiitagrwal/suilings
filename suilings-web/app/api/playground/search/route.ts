import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const query = searchParams.get("q") || "";
    const tags = searchParams.get("tags")?.split(",").filter(Boolean) || [];
    const sortBy = searchParams.get("sort") || "created"; // created, views, forks, trending
    const authorId = searchParams.get("author");
    const limit = parseInt(searchParams.get("limit") || "20");
    const offset = parseInt(searchParams.get("offset") || "0");

    const supabase = await createClient();

    let queryBuilder = supabase
      .from("playground_snippets")
      .select("*", { count: "exact" });
    
    // If filtering by author, show all their snippets (public + private)
    // Otherwise, only show public snippets
    if (!authorId) {
      queryBuilder = queryBuilder.eq("is_public", true);
    }

    // Text search
    if (query) {
      queryBuilder = queryBuilder.or(
        `title.ilike.%${query}%,description.ilike.%${query}%`
      );
    }

    // Filter by tags
    if (tags.length > 0) {
      queryBuilder = queryBuilder.contains("tags", tags);
    }

    // Filter by author
    if (authorId) {
      queryBuilder = queryBuilder.eq("user_id", authorId);
    }

    // Sort
    switch (sortBy) {
      case "views":
        queryBuilder = queryBuilder.order("view_count", { ascending: false });
        break;
      case "forks":
        queryBuilder = queryBuilder.order("fork_count", { ascending: false });
        break;
      case "trending":
        // Trending = combination of recent + popular
        queryBuilder = queryBuilder
          .order("view_count", { ascending: false })
          .order("created_at", { ascending: false });
        break;
      case "created":
      default:
        queryBuilder = queryBuilder.order("created_at", { ascending: false });
        break;
    }

    // Pagination
    queryBuilder = queryBuilder.range(offset, offset + limit - 1);

    const { data, error, count } = await queryBuilder;

    if (error) {
      console.error("Search error:", error);
      return NextResponse.json(
        { error: "Failed to search snippets" },
        { status: 500 }
      );
    }

    // Fetch user data separately for each snippet
    const userIds = [...new Set(data?.map(s => s.user_id).filter(Boolean))];
    const { data: users } = await supabase
      .from("profiles")
      .select("user_id, username, avatar_url")
      .in("user_id", userIds);

    const userMap = new Map(users?.map(u => [u.user_id, u]) || []);

    // Format response with user info
    const snippets = data?.map((snippet) => {
      const user = userMap.get(snippet.user_id);
      return {
        id: snippet.id,
        title: snippet.title,
        description: snippet.description,
        code: snippet.code,
        tags: snippet.tags || [],
        viewCount: snippet.view_count,
        forkCount: snippet.fork_count,
        isPublic: snippet.is_public,
        createdAt: snippet.created_at,
        updatedAt: snippet.updated_at,
        author: user
          ? {
              id: user.user_id,
              username: user.username || "anonymous",
              avatarUrl: user.avatar_url,
            }
          : null,
      };
    }) || [];

    return NextResponse.json({
      snippets,
      pagination: {
        total: count || 0,
        limit,
        offset,
        hasMore: (count || 0) > offset + limit,
      },
    });
  } catch (error) {
    console.error("Search error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
