"use client";

import { useState, useEffect } from "react";
import { Search, Filter, SlidersHorizontal } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
  DropdownMenuCheckboxItem,
  DropdownMenuSeparator,
  DropdownMenuLabel,
} from "@/components/ui/dropdown-menu";

interface SearchFilterProps {
  onSearch: (params: SearchParams) => void;
}

export interface SearchParams {
  query: string;
  tags: string[];
  sortBy: "created" | "views" | "forks" | "trending";
}

const AVAILABLE_TAGS = [
  "nft",
  "defi",
  "beginner",
  "intermediate",
  "advanced",
  "marketplace",
  "coin",
  "collection",
  "game",
  "dao",
];

const SORT_OPTIONS = [
  { value: "created", label: "Most Recent" },
  { value: "views", label: "Most Viewed" },
  { value: "forks", label: "Most Forked" },
  { value: "trending", label: "Trending" },
] as const;

export function SearchFilter({ onSearch }: SearchFilterProps) {
  const [query, setQuery] = useState("");
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [sortBy, setSortBy] = useState<SearchParams["sortBy"]>("created");

  // Debounced search
  useEffect(() => {
    const timer = setTimeout(() => {
      onSearch({ query, tags: selectedTags, sortBy });
    }, 300);

    return () => clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [query, selectedTags, sortBy]);

  const toggleTag = (tag: string) => {
    setSelectedTags((prev) =>
      prev.includes(tag) ? prev.filter((t) => t !== tag) : [...prev, tag]
    );
  };

  const clearFilters = () => {
    setQuery("");
    setSelectedTags([]);
    setSortBy("created");
  };

  const hasActiveFilters = query || selectedTags.length > 0 || sortBy !== "created";

  return (
    <div className="flex flex-col sm:flex-row gap-3 mb-6">
      {/* Search Input */}
      <div className="relative flex-1">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <Input
          placeholder="Search snippets..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="pl-10"
        />
      </div>

      {/* Filter by Tags */}
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="outline" size="default" className="gap-2">
            <Filter className="h-4 w-4" />
            Tags
            {selectedTags.length > 0 && (
              <span className="ml-1 rounded-full bg-primary px-2 py-0.5 text-xs text-primary-foreground">
                {selectedTags.length}
              </span>
            )}
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-56">
          <DropdownMenuLabel>Filter by tags</DropdownMenuLabel>
          <DropdownMenuSeparator />
          {AVAILABLE_TAGS.map((tag) => (
            <DropdownMenuCheckboxItem
              key={tag}
              checked={selectedTags.includes(tag)}
              onCheckedChange={() => toggleTag(tag)}
            >
              {tag}
            </DropdownMenuCheckboxItem>
          ))}
        </DropdownMenuContent>
      </DropdownMenu>

      {/* Sort Options */}
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="outline" size="default" className="gap-2">
            <SlidersHorizontal className="h-4 w-4" />
            {SORT_OPTIONS.find((opt) => opt.value === sortBy)?.label}
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuLabel>Sort by</DropdownMenuLabel>
          <DropdownMenuSeparator />
          {SORT_OPTIONS.map((option) => (
            <DropdownMenuItem
              key={option.value}
              onClick={() => setSortBy(option.value)}
              className={sortBy === option.value ? "bg-accent" : ""}
            >
              {option.label}
            </DropdownMenuItem>
          ))}
        </DropdownMenuContent>
      </DropdownMenu>

      {/* Clear Filters */}
      {hasActiveFilters && (
        <Button variant="ghost" size="default" onClick={clearFilters}>
          Clear
        </Button>
      )}
    </div>
  );
}
