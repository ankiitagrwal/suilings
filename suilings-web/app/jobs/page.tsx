"use client";

import { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import Image from "next/image";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { Footer } from "@/components/layout/Footer";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import {
  Briefcase,
  MapPin,
  Clock,
  ShieldCheck,
  Search,
  Building2,
  ArrowRight,
  SlidersHorizontal,
  X,
} from "lucide-react";
import { toast } from "sonner";
import type { JobListing, Company } from "@/types/jobs";

interface JobWithCompany extends JobListing {
  companies: Company;
}

const JOB_TYPE_OPTIONS = [
  { value: "", label: "All Types" },
  { value: "full-time", label: "Full-time" },
  { value: "part-time", label: "Part-time" },
  { value: "contract", label: "Contract" },
];

const LOCATION_TYPE_OPTIONS = [
  { value: "", label: "All Locations" },
  { value: "remote", label: "Remote" },
  { value: "onsite", label: "On-site" },
  { value: "hybrid", label: "Hybrid" },
];

const JOB_TYPE_LABELS: Record<string, string> = {
  "full-time": "Full-time",
  "part-time": "Part-time",
  contract: "Contract",
};

const LOCATION_TYPE_LABELS: Record<string, string> = {
  remote: "Remote",
  onsite: "On-site",
  hybrid: "Hybrid",
};

function formatSalary(min: number | null, max: number | null, currency: string): string | null {
  if (!min && !max) return null;
  const fmt = (n: number) => (n >= 1000 ? `${(n / 1000).toFixed(0)}k` : `${n}`);
  const symbol = currency === "USD" ? "$" : currency;
  if (min && max) return `${symbol}${fmt(min)} – ${symbol}${fmt(max)}`;
  if (min) return `From ${symbol}${fmt(min)}`;
  return `Up to ${symbol}${fmt(max!)}`;
}

export default function JobsPage() {
  const [jobs, setJobs] = useState<JobWithCompany[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [filters, setFilters] = useState({
    type: "",
    location_type: "",
    requires_credential: false,
    min_exercises: 0,
  });
  const [search, setSearch] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");
  const [showFilters, setShowFilters] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(search);
      setPage(1);
    }, 300);
    return () => clearTimeout(timer);
  }, [search]);

  const fetchJobs = useCallback(async () => {
    setIsLoading(true);
    try {
      const params = new URLSearchParams({ page: String(page), limit: "20" });
      if (debouncedSearch) params.set("search", debouncedSearch);
      if (filters.type) params.set("type", filters.type);
      if (filters.location_type) params.set("location_type", filters.location_type);
      if (filters.requires_credential) params.set("requires_credential", "true");
      if (filters.min_exercises > 0) params.set("min_exercises", String(filters.min_exercises));

      const res = await fetch(`/api/jobs?${params}`);
      const data = await res.json();
      setJobs(data.jobs ?? []);
      setTotal(data.total ?? 0);
    } catch {
      toast.error("Failed to load jobs");
      setJobs([]);
    } finally {
      setIsLoading(false);
    }
  }, [page, filters, debouncedSearch]);

  useEffect(() => {
    fetchJobs();
  }, [fetchJobs]);

  const filteredJobs = jobs;

  const hasActiveFilters =
    filters.type || filters.location_type || filters.requires_credential || filters.min_exercises > 0;

  function clearFilters() {
    setFilters({ type: "", location_type: "", requires_credential: false, min_exercises: 0 });
    setPage(1);
  }

  return (
    <>
      <SimpleHeader />
      <div className="min-h-screen bg-background">
        {/* Hero */}
        <div className="border-b border-border bg-card/50">
          <div className="container mx-auto px-4 py-10 max-w-5xl">
            <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
              <div>
                <h1 className="text-4xl font-bold mb-2">
                  Jobs for Move Developers
                </h1>
                <p className="text-muted-foreground">
                  {total > 0 ? `${total} open position${total !== 1 ? "s" : ""}` : "Find your next role in the Sui ecosystem"}
                </p>
              </div>
              <div className="flex gap-2 shrink-0">
                <Button variant="outline" asChild>
                  <Link href="/company/dashboard">
                    <Building2 className="h-4 w-4 mr-2" />
                    Post a Job
                  </Link>
                </Button>
              </div>
            </div>
          </div>
        </div>

        <div className="container mx-auto px-4 py-8 max-w-5xl">
          {/* Search + Filter Bar */}
          <div className="flex gap-2 mb-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search jobs or companies…"
                className="pl-9"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
            <Button
              variant={showFilters ? "default" : "outline"}
              size="icon"
              onClick={() => setShowFilters((v) => !v)}
            >
              <SlidersHorizontal className="h-4 w-4" />
            </Button>
            {hasActiveFilters && (
              <Button variant="ghost" size="sm" onClick={clearFilters} className="gap-1 text-muted-foreground">
                <X className="h-3.5 w-3.5" />
                Clear
              </Button>
            )}
          </div>

          {/* Filters */}
          {showFilters && (
            <div className="flex flex-wrap gap-3 mb-6 p-4 rounded-xl border border-border bg-card">
              <div className="flex flex-col gap-1">
                <span className="text-xs font-medium text-muted-foreground uppercase tracking-wide">Job Type</span>
                <div className="flex gap-1">
                  {JOB_TYPE_OPTIONS.map((opt) => (
                    <button
                      key={opt.value}
                      onClick={() => { setFilters((f) => ({ ...f, type: opt.value })); setPage(1); }}
                      className={`px-3 py-1 rounded-full text-xs font-medium border transition-colors ${
                        filters.type === opt.value
                          ? "bg-indigo-500 text-white border-indigo-500"
                          : "border-border hover:border-indigo-500/50 text-muted-foreground hover:text-foreground"
                      }`}
                    >
                      {opt.label}
                    </button>
                  ))}
                </div>
              </div>

              <div className="flex flex-col gap-1">
                <span className="text-xs font-medium text-muted-foreground uppercase tracking-wide">Location</span>
                <div className="flex gap-1">
                  {LOCATION_TYPE_OPTIONS.map((opt) => (
                    <button
                      key={opt.value}
                      onClick={() => { setFilters((f) => ({ ...f, location_type: opt.value })); setPage(1); }}
                      className={`px-3 py-1 rounded-full text-xs font-medium border transition-colors ${
                        filters.location_type === opt.value
                          ? "bg-indigo-500 text-white border-indigo-500"
                          : "border-border hover:border-indigo-500/50 text-muted-foreground hover:text-foreground"
                      }`}
                    >
                      {opt.label}
                    </button>
                  ))}
                </div>
              </div>

              <div className="flex flex-col gap-1 justify-end">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={filters.requires_credential}
                    onChange={(e) => { setFilters((f) => ({ ...f, requires_credential: e.target.checked })); setPage(1); }}
                    className="rounded border-border"
                  />
                  <span className="text-sm flex items-center gap-1">
                    <ShieldCheck className="h-3.5 w-3.5 text-amber-500" />
                    Credential required only
                  </span>
                </label>
              </div>
            </div>
          )}

          {/* Active filter chips */}
          {hasActiveFilters && (
            <div className="flex flex-wrap gap-2 mb-4">
              {filters.type && (
                <Badge variant="secondary" className="gap-1">
                  {JOB_TYPE_LABELS[filters.type]}
                  <button onClick={() => setFilters((f) => ({ ...f, type: "" }))}><X className="h-3 w-3" /></button>
                </Badge>
              )}
              {filters.location_type && (
                <Badge variant="secondary" className="gap-1">
                  {LOCATION_TYPE_LABELS[filters.location_type]}
                  <button onClick={() => setFilters((f) => ({ ...f, location_type: "" }))}><X className="h-3 w-3" /></button>
                </Badge>
              )}
              {filters.requires_credential && (
                <Badge variant="secondary" className="gap-1">
                  Credential required
                  <button onClick={() => setFilters((f) => ({ ...f, requires_credential: false }))}><X className="h-3 w-3" /></button>
                </Badge>
              )}
            </div>
          )}

          {/* Job List */}
          {isLoading ? (
            <div className="space-y-4">
              {Array.from({ length: 6 }).map((_, i) => (
                <div key={i} className="h-24 rounded-xl border border-border bg-card animate-pulse" />
              ))}
            </div>
          ) : filteredJobs.length === 0 ? (
            <div className="text-center py-20 text-muted-foreground">
              <Briefcase className="h-12 w-12 mx-auto mb-4 opacity-30" />
              <p className="text-lg font-medium">No jobs found</p>
              <p className="text-sm mt-1">Try adjusting your filters or check back later.</p>
              {hasActiveFilters && (
                <Button variant="outline" className="mt-4" onClick={clearFilters}>
                  Clear filters
                </Button>
              )}
            </div>
          ) : (
            <>
              <div className="space-y-3">
                {filteredJobs.map((job) => {
                  const salary = formatSalary(job.salary_min, job.salary_max, job.currency ?? "USD");
                  const company = job.companies;
                  return (
                    <Link key={job.id} href={`/jobs/${job.id}`} className="block">
                      <Card className="hover:border-indigo-500/40 transition-colors group">
                        <CardContent className="p-5">
                          <div className="flex gap-4 items-start">
                            <div className="h-12 w-12 rounded-xl border border-border bg-background flex items-center justify-center shrink-0 overflow-hidden">
                              {company?.logo_url ? (
                                <Image
                                  src={company.logo_url}
                                  alt={company.name}
                                  width={48}
                                  height={48}
                                  className="object-contain"
                                />
                              ) : (
                                <Building2 className="h-5 w-5 text-muted-foreground" />
                              )}
                            </div>

                            <div className="flex-1 min-w-0">
                              <div className="flex flex-wrap items-start justify-between gap-2">
                                <div>
                                  <div className="flex flex-wrap items-center gap-2 mb-0.5">
                                    <h3 className="font-semibold group-hover:text-indigo-500 transition-colors">
                                      {job.title}
                                    </h3>
                                    {job.requires_credential && (
                                      <Badge
                                        variant="outline"
                                        className="text-xs gap-1 border-amber-500/40 text-amber-600"
                                      >
                                        <ShieldCheck className="h-2.5 w-2.5" />
                                        Credential
                                      </Badge>
                                    )}
                                    {company?.verified && (
                                      <Badge className="text-xs gap-1 bg-indigo-500/10 text-indigo-600 border-indigo-500/20">
                                        <ShieldCheck className="h-2.5 w-2.5" />
                                        Verified
                                      </Badge>
                                    )}
                                  </div>
                                  {company && (
                                    <span className="text-sm text-muted-foreground">
                                      {company.name}
                                    </span>
                                  )}
                                </div>
                                <div className="shrink-0 flex items-center gap-1 text-sm font-medium text-indigo-500">
                                  View Role
                                  <ArrowRight className="h-3.5 w-3.5" />
                                </div>
                              </div>

                              <div className="flex flex-wrap items-center gap-3 text-xs text-muted-foreground mt-2">
                                <span className="flex items-center gap-1">
                                  <Clock className="h-3 w-3" />
                                  {JOB_TYPE_LABELS[job.type] ?? job.type}
                                </span>
                                <span className="flex items-center gap-1">
                                  <MapPin className="h-3 w-3" />
                                  {LOCATION_TYPE_LABELS[job.location_type] ?? job.location_type}
                                  {job.location ? ` · ${job.location}` : ""}
                                </span>
                                {salary && <span>{salary}</span>}
                                {job.min_exercises_required > 0 && (
                                  <span className="flex items-center gap-1">
                                    <Briefcase className="h-3 w-3" />
                                    {job.min_exercises_required}+ exercises
                                  </span>
                                )}
                              </div>
                              {job.tags && job.tags.length > 0 && (
                                <div className="flex flex-wrap gap-1 mt-2">
                                  {job.tags.slice(0, 4).map((tag: string) => (
                                    <span key={tag} className="px-1.5 py-0.5 rounded text-[10px] font-medium bg-muted text-muted-foreground">
                                      {tag}
                                    </span>
                                  ))}
                                  {job.tags.length > 4 && (
                                    <span className="text-[10px] text-muted-foreground">+{job.tags.length - 4}</span>
                                  )}
                                </div>
                              )}
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    </Link>
                  );
                })}
              </div>

              {/* Pagination */}
              {total > 20 && (
                <div className="flex justify-center gap-2 mt-8">
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={page <= 1}
                    onClick={() => setPage((p) => p - 1)}
                  >
                    Previous
                  </Button>
                  <span className="flex items-center px-4 text-sm text-muted-foreground">
                    Page {page} of {Math.ceil(total / 20)}
                  </span>
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={page >= Math.ceil(total / 20)}
                    onClick={() => setPage((p) => p + 1)}
                  >
                    Next
                  </Button>
                </div>
              )}
            </>
          )}
        </div>
      </div>
      <Footer />
    </>
  );
}
