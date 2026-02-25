"use client";

import { useEffect, useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { SnippetGrid, type SnippetData } from "@/components/playground/SnippetGrid";
import { SearchFilter, type SearchParams } from "@/components/playground/SearchFilter";
import { Button } from "@/components/ui/button";
import { Plus, Loader2 } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { toast } from "sonner";

export default function MySnippetsPage() {
  const router = useRouter();
  const [snippets, setSnippets] = useState<SnippetData[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchParams, setSearchParams] = useState<SearchParams>({
    query: "",
    tags: [],
    sortBy: "created",
  });

  // Memoize the search handler to prevent infinite re-renders
  const handleSearch = useCallback((params: SearchParams) => {
    setSearchParams(params);
  }, []);

  useEffect(() => {
    loadMySnippets();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [searchParams]);

  async function loadMySnippets() {
    setIsLoading(true);
    try {
      const supabase = createClient();
      
      // Get current user
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        router.push("/auth/signin");
        return;
      }

      // Try search API
      const params = new URLSearchParams({
        author: user.id,
        sort: searchParams.sortBy,
        limit: "50",
      });
      
      if (searchParams.query) {
        params.append("q", searchParams.query);
      }
      
      if (searchParams.tags.length > 0) {
        params.append("tags", searchParams.tags.join(","));
      }

      const response = await fetch(`/api/playground/search?${params}`);
      const data = await response.json();

      if (data.snippets) {
        setSnippets(data.snippets);
      } else {
        // Fallback to direct query if API fails
        const { data: directSnippets, error } = await supabase
          .from('playground_snippets')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', { ascending: false });

        if (error) {
          console.error('Direct query error:', error);
        } else {
          // Map to expected format
          const mappedSnippets = (directSnippets || []).map(s => ({
            id: s.id,
            title: s.title,
            description: s.description,
            tags: s.tags || [],
            viewCount: s.view_count,
            forkCount: s.fork_count,
            createdAt: s.created_at,
            author: {
              id: user.id,
              username: user.user_metadata?.user_name || user.email?.split('@')[0] || 'user',
            },
          }));
          setSnippets(mappedSnippets);
        }
      }
    } catch (error) {
      console.error("Failed to load snippets:", error);
      toast.error("Failed to load your snippets");
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <>
      <SimpleHeader />
      <div className="container mx-auto px-4 py-8 max-w-7xl">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-3xl font-bold">My Snippets</h1>
            <p className="text-muted-foreground mt-1">
              Manage your Move code snippets
            </p>
          </div>
          <Button onClick={() => router.push("/playground")} className="gap-2">
            <Plus className="h-4 w-4" />
            New Snippet
          </Button>
        </div>

        {/* Search and Filters */}
        <SearchFilter onSearch={handleSearch} />

        {/* Snippets Grid */}
        <SnippetGrid
          snippets={snippets}
          isLoading={isLoading}
          emptyMessage="You haven't created any snippets yet"
        />
      </div>
    </>
  );
}
