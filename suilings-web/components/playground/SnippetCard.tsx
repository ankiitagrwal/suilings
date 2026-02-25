"use client";

import Link from "next/link";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Eye, GitFork, User } from "lucide-react";
import { formatDistanceToNow } from "date-fns";

export interface SnippetData {
  id: string;
  title: string;
  description: string | null;
  tags: string[];
  viewCount: number;
  forkCount: number;
  createdAt: string;
  author: {
    id: string;
    username: string;
    avatarUrl?: string;
  } | null;
}

interface SnippetCardProps {
  snippet: SnippetData;
}

export function SnippetCard({ snippet }: SnippetCardProps) {
  return (
    <Link href={`/playground/${snippet.id}`} className="block h-full">
      <Card className="hover:border-primary transition-all cursor-pointer h-full">
        <CardHeader>
          <CardTitle className="line-clamp-1 text-lg">{snippet.title}</CardTitle>
          {snippet.description && (
            <CardDescription className="line-clamp-2">
              {snippet.description}
            </CardDescription>
          )}
        </CardHeader>
        <CardContent className="space-y-3">
          {/* Tags */}
          {snippet.tags.length > 0 && (
            <div className="flex flex-wrap gap-1">
              {snippet.tags.slice(0, 3).map((tag) => (
                <Badge key={tag} variant="secondary" className="text-xs">
                  {tag}
                </Badge>
              ))}
              {snippet.tags.length > 3 && (
                <Badge variant="secondary" className="text-xs">
                  +{snippet.tags.length - 3}
                </Badge>
              )}
            </div>
          )}

          {/* Stats and Author */}
          <div className="flex items-center justify-between text-sm text-muted-foreground">
            <div className="flex items-center gap-3">
              <span className="flex items-center gap-1">
                <Eye className="h-3 w-3" />
                {snippet.viewCount}
              </span>
              <span className="flex items-center gap-1">
                <GitFork className="h-3 w-3" />
                {snippet.forkCount}
              </span>
            </div>
            
            {snippet.author && (
              <span className="flex items-center gap-1">
                <User className="h-3 w-3" />
                @{snippet.author.username}
              </span>
            )}
          </div>

          {/* Time */}
          <div className="text-xs text-muted-foreground">
            {formatDistanceToNow(new Date(snippet.createdAt), { addSuffix: true })}
          </div>
        </CardContent>
      </Card>
    </Link>
  );
}
