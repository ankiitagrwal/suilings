import { PlaygroundEditor } from "@/components/playground/PlaygroundEditor";
import { createClient } from "@/lib/supabase/server";
import { notFound } from "next/navigation";

interface PageProps {
  params: Promise<{
    snippetId: string;
  }>;
}

export default async function SnippetPage({ params }: PageProps) {
  const { snippetId } = await params;
  const supabase = await createClient();

  // Fetch snippet
  const { data: snippet, error } = await supabase
    .from("playground_snippets")
    .select("*")
    .eq("id", snippetId)
    .single();

  if (error || !snippet) {
    notFound();
  }

  // Check if current user owns this snippet
  const { data: { user } } = await supabase.auth.getUser();
  const isOwner = user && user.id === snippet.user_id;

  // Increment view count (only for public snippets viewed by others)
  if (snippet.is_public && (!user || user.id !== snippet.user_id)) {
    // Non-blocking increment - don't wait for it
    Promise.resolve(supabase.rpc('increment_view_count', { snippet_id: snippetId }))
      .catch((err: unknown) => console.warn('Failed to increment view count:', err));
  }

  return (
    <PlaygroundEditor
      initialCode={snippet.code}
      snippetId={snippet.id}
      snippetTitle={snippet.title}
      isReadOnly={!isOwner}
      showFork={!isOwner && snippet.is_public}
    />
  );
}
