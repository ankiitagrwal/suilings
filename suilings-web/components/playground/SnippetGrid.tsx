"use client";

import { SnippetCard, SnippetData } from "./SnippetCard";
import { Loader2 } from "lucide-react";

// Re-export SnippetData for use in other components
export type { SnippetData };

interface SnippetGridProps {
  snippets: SnippetData[];
  isLoading?: boolean;
  emptyMessage?: string;
}

export function SnippetGrid({ 
  snippets, 
  isLoading = false,
  emptyMessage = "No snippets found"
}: SnippetGridProps) {
  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      </div>
    );
  }

  if (snippets.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-12 text-center">
        <p className="text-muted-foreground text-lg">{emptyMessage}</p>
        <p className="text-muted-foreground text-sm mt-2">
          Try adjusting your search or filters
        </p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {snippets.map((snippet) => (
        <SnippetCard key={snippet.id} snippet={snippet} />
      ))}
    </div>
  );
}
