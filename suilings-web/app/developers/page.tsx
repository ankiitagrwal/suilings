"use client";

import { useEffect, useState, useCallback } from "react";
import Link from "next/link";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { Footer } from "@/components/layout/Footer";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";
import {
  Award,
  Briefcase,
  Flame,
  MapPin,
  Search,
  SlidersHorizontal,
  Users,
  BookOpen,
  ChevronLeft,
  ChevronRight,
  X,
} from "lucide-react";

const ROLE_OPTIONS = [
  "Smart Contract Dev",
  "Protocol Engineer",
  "Frontend Dev",
  "Full Stack Dev",
  "DevRel",
  "Security Auditor",
  "Blockchain Architect",
  "Technical Writer",
];

const SORT_OPTIONS = [
  { value: "most_exercises", label: "Most Exercises" },
  { value: "longest_streak", label: "Longest Streak" },
  { value: "recently_active", label: "Recently Active" },
];

interface Developer {
  id: string;
  username: string;
  displayName: string;
  avatarUrl?: string | null;
  bio?: string | null;
  location?: string | null;
  githubUsername?: string | null;
  openToWork: boolean;
  skillsSummary?: string | null;
  availableRoles: string[];
  completedExercises: number;
  streakDays: number;
  lastActive: string;
  hasCredential: boolean;
  joinedAt: string;
}

export default function DevelopersPage() {
  const [developers, setDevelopers] = useState<Developer[]>([]);
  const [total, setTotal] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [showFilters, setShowFilters] = useState(false);

  // Filters
  const [openToWorkOnly, setOpenToWorkOnly] = useState(false);
  const [credentialOnly, setCredentialOnly] = useState(false);
  const [location, setLocation] = useState("");
  const [selectedRole, setSelectedRole] = useState("");
  const [minExercises, setMinExercises] = useState("");
  const [sort, setSort] = useState("most_exercises");
  const [page, setPage] = useState(1);
  const limit = 24;

  const fetchDevelopers = useCallback(async () => {
    setIsLoading(true);
    try {
      const params = new URLSearchParams();
      if (openToWorkOnly) params.set("open_to_work", "true");
      if (credentialOnly) params.set("credential_only", "true");
      if (location.trim()) params.set("location", location.trim());
      if (selectedRole) params.set("role", selectedRole);
      if (minExercises && parseInt(minExercises) > 0) params.set("min_exercises", minExercises);
      params.set("sort", sort);
      params.set("page", String(page));
      params.set("limit", String(limit));

      const res = await fetch(`/api/developers?${params.toString()}`);
      if (!res.ok) throw new Error("Failed to fetch");
      const data = await res.json();
      setDevelopers(data.developers ?? []);
      setTotal(data.total ?? 0);
    } catch (err) {
      console.error(err);
      setDevelopers([]);
    } finally {
      setIsLoading(false);
    }
  }, [openToWorkOnly, credentialOnly, location, selectedRole, minExercises, sort, page]);

  useEffect(() => {
    fetchDevelopers();
  }, [fetchDevelopers]);

  // Reset page when filters change
  const resetPage = () => setPage(1);

  const totalPages = Math.ceil(total / limit);
  const activeFilterCount = [
    openToWorkOnly,
    credentialOnly,
    location.trim() !== "",
    selectedRole !== "",
    minExercises !== "" && parseInt(minExercises) > 0,
  ].filter(Boolean).length;

  const clearFilters = () => {
    setOpenToWorkOnly(false);
    setCredentialOnly(false);
    setLocation("");
    setSelectedRole("");
    setMinExercises("");
    setSort("most_exercises");
    setPage(1);
  };

  return (
    <>
      <SimpleHeader />
      <div className="min-h-screen bg-background">
        {/* Page Header */}
        <div className="border-b bg-card">
          <div className="container mx-auto px-4 py-10 max-w-7xl">
            <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4">
              <div>
                <h1 className="text-3xl font-bold tracking-tight flex items-center gap-3">
                  <Users className="h-8 w-8 text-primary" />
                  Find Move Developers
                </h1>
                <p className="text-muted-foreground mt-1.5">
                  Browse verified Sui / Move engineers — filter by credential, availability, and skills
                </p>
              </div>
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <span className="font-semibold text-foreground">{total}</span> developer{total !== 1 ? "s" : ""}
              </div>
            </div>
          </div>
        </div>

        <div className="container mx-auto px-4 py-8 max-w-7xl">
          {/* Toolbar */}
          <div className="flex flex-col sm:flex-row gap-3 mb-6">
            {/* Sort */}
            <div className="flex gap-1 p-1 bg-muted rounded-lg">
              {SORT_OPTIONS.map((opt) => (
                <button
                  key={opt.value}
                  onClick={() => { setSort(opt.value); resetPage(); }}
                  className={`px-3 py-1.5 text-sm rounded-md transition-colors font-medium ${
                    sort === opt.value
                      ? "bg-background shadow-sm text-foreground"
                      : "text-muted-foreground hover:text-foreground"
                  }`}
                >
                  {opt.label}
                </button>
              ))}
            </div>

            <div className="flex-1 flex gap-2 justify-end">
              {activeFilterCount > 0 && (
                <Button variant="ghost" size="sm" onClick={clearFilters} className="gap-1.5 text-muted-foreground">
                  <X className="h-3.5 w-3.5" />
                  Clear filters
                  <Badge variant="secondary" className="ml-0.5 text-xs">{activeFilterCount}</Badge>
                </Button>
              )}
              <Button
                variant="outline"
                size="sm"
                onClick={() => setShowFilters(!showFilters)}
                className="gap-2"
              >
                <SlidersHorizontal className="h-4 w-4" />
                Filters
                {activeFilterCount > 0 && (
                  <Badge className="ml-0.5 text-xs h-5 w-5 p-0 flex items-center justify-center">
                    {activeFilterCount}
                  </Badge>
                )}
              </Button>
            </div>
          </div>

          {/* Filter Panel */}
          {showFilters && (
            <Card className="mb-6">
              <CardContent className="pt-5 pb-5">
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
                  {/* Open to Work toggle */}
                  <div className="flex items-center justify-between gap-3">
                    <Label htmlFor="openToWorkFilter" className="font-medium cursor-pointer">
                      Open to Work only
                    </Label>
                    <Switch
                      id="openToWorkFilter"
                      checked={openToWorkOnly}
                      onCheckedChange={(v) => { setOpenToWorkOnly(v); resetPage(); }}
                    />
                  </div>

                  {/* Credential toggle */}
                  <div className="flex items-center justify-between gap-3">
                    <Label htmlFor="credentialFilter" className="font-medium cursor-pointer">
                      Credential holders only
                    </Label>
                    <Switch
                      id="credentialFilter"
                      checked={credentialOnly}
                      onCheckedChange={(v) => { setCredentialOnly(v); resetPage(); }}
                    />
                  </div>

                  {/* Location */}
                  <div>
                    <Label htmlFor="locationFilter" className="mb-1.5 block text-sm">Location</Label>
                    <div className="relative">
                      <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                      <Input
                        id="locationFilter"
                        value={location}
                        onChange={(e) => { setLocation(e.target.value); resetPage(); }}
                        placeholder="City or Country"
                        className="pl-8"
                      />
                    </div>
                  </div>

                  {/* Min Exercises */}
                  <div>
                    <Label htmlFor="minExercisesFilter" className="mb-1.5 block text-sm">
                      Min. exercises completed
                    </Label>
                    <Input
                      id="minExercisesFilter"
                      type="number"
                      min={0}
                      value={minExercises}
                      onChange={(e) => { setMinExercises(e.target.value); resetPage(); }}
                      placeholder="e.g. 10"
                    />
                  </div>
                </div>

                {/* Role filter */}
                <div className="mt-4">
                  <p className="text-sm font-medium mb-2">Role</p>
                  <div className="flex flex-wrap gap-2">
                    {ROLE_OPTIONS.map((role) => (
                      <button
                        key={role}
                        type="button"
                        onClick={() => { setSelectedRole(selectedRole === role ? "" : role); resetPage(); }}
                        className="focus:outline-none"
                      >
                        <Badge
                          variant={selectedRole === role ? "default" : "outline"}
                          className="cursor-pointer select-none transition-colors"
                        >
                          {role}
                        </Badge>
                      </button>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Developer Grid */}
          {isLoading ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
              {Array.from({ length: 12 }).map((_, i) => (
                <Card key={i} className="animate-pulse">
                  <CardContent className="pt-5 pb-5">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="h-11 w-11 rounded-full bg-muted" />
                      <div className="space-y-1.5 flex-1">
                        <div className="h-4 w-24 bg-muted rounded" />
                        <div className="h-3 w-16 bg-muted rounded" />
                      </div>
                    </div>
                    <div className="h-3 w-full bg-muted rounded mb-1" />
                    <div className="h-3 w-3/4 bg-muted rounded" />
                  </CardContent>
                </Card>
              ))}
            </div>
          ) : developers.length === 0 ? (
            <div className="text-center py-24 text-muted-foreground">
              <Users className="h-12 w-12 mx-auto mb-4 opacity-30" />
              <p className="text-lg font-medium">No developers found</p>
              <p className="text-sm mt-1">Try adjusting your filters</p>
              {activeFilterCount > 0 && (
                <Button variant="outline" className="mt-4" onClick={clearFilters}>
                  Clear all filters
                </Button>
              )}
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
              {developers.map((dev) => (
                <DeveloperCard key={dev.id} dev={dev} />
              ))}
            </div>
          )}

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex items-center justify-center gap-3 mt-10">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={page <= 1}
                className="gap-1.5"
              >
                <ChevronLeft className="h-4 w-4" />
                Previous
              </Button>
              <span className="text-sm text-muted-foreground">
                Page {page} of {totalPages}
              </span>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={page >= totalPages}
                className="gap-1.5"
              >
                Next
                <ChevronRight className="h-4 w-4" />
              </Button>
            </div>
          )}
        </div>
      </div>
      <Footer />
    </>
  );
}

function DeveloperCard({ dev }: { dev: Developer }) {
  const initials = dev.displayName
    ? dev.displayName.split(" ").map((n) => n[0]).join("").toUpperCase().slice(0, 2)
    : (dev.username ?? "?").slice(0, 2).toUpperCase();

  return (
    <Link href={`/u/${dev.username ?? dev.id}`} className="group block">
      <Card className="h-full transition-shadow hover:shadow-md">
        <CardContent className="pt-5 pb-5">
          {/* Avatar + name */}
          <div className="flex items-start gap-3 mb-3">
            <Avatar className="h-11 w-11 shrink-0">
              <AvatarImage src={dev.avatarUrl ?? undefined} />
              <AvatarFallback className="text-sm font-semibold">{initials}</AvatarFallback>
            </Avatar>
            <div className="min-w-0 flex-1">
              <p className="font-semibold text-sm truncate group-hover:text-primary transition-colors">
                {dev.displayName}
              </p>
              <p className="text-xs text-muted-foreground truncate">@{dev.username}</p>
            </div>
          </div>

          {/* Badges row */}
          <div className="flex flex-wrap gap-1.5 mb-3">
            {dev.openToWork && (
              <Badge className="bg-green-500/15 text-green-600 border-green-500/30 gap-1 text-xs font-medium">
                <Briefcase className="h-3 w-3" />
                Open to Work
              </Badge>
            )}
            {dev.hasCredential && (
              <Badge variant="secondary" className="gap-1 text-xs font-medium">
                <Award className="h-3 w-3" />
                Credentialed
              </Badge>
            )}
          </div>

          {/* Skills summary */}
          {dev.skillsSummary && (
            <p className="text-xs text-muted-foreground line-clamp-2 mb-3">
              {dev.skillsSummary}
            </p>
          )}

          {/* Roles */}
          {dev.availableRoles.length > 0 && (
            <div className="flex flex-wrap gap-1 mb-3">
              {dev.availableRoles.slice(0, 2).map((r) => (
                <Badge key={r} variant="outline" className="text-xs">
                  {r}
                </Badge>
              ))}
              {dev.availableRoles.length > 2 && (
                <Badge variant="outline" className="text-xs">
                  +{dev.availableRoles.length - 2}
                </Badge>
              )}
            </div>
          )}

          {/* Stats */}
          <div className="flex items-center gap-3 text-xs text-muted-foreground border-t pt-3 mt-auto">
            <span className="flex items-center gap-1">
              <BookOpen className="h-3.5 w-3.5" />
              {dev.completedExercises} exercises
            </span>
            {dev.streakDays > 0 && (
              <span className="flex items-center gap-1">
                <Flame className="h-3.5 w-3.5 text-orange-500" />
                {dev.streakDays}d streak
              </span>
            )}
            {dev.location && (
              <span className="flex items-center gap-1 ml-auto truncate">
                <MapPin className="h-3.5 w-3.5 shrink-0" />
                <span className="truncate">{dev.location}</span>
              </span>
            )}
          </div>
        </CardContent>
      </Card>
    </Link>
  );
}
