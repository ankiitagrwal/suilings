"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { Footer } from "@/components/layout/Footer";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  Briefcase,
  MapPin,
  Clock,
  Building2,
  ArrowRight,
  CheckCircle2,
  Eye,
  Star,
  XCircle,
  Loader2,
} from "lucide-react";
import { toast } from "sonner";
import { useAuth } from "@/lib/hooks/useAuth";
import type { ApplicationStatus } from "@/types/jobs";

interface ApplicationWithJob {
  id: string;
  job_id: string;
  status: ApplicationStatus;
  cover_note: string | null;
  applied_at: string;
  job_listings: {
    id: string;
    title: string;
    type: string;
    location_type: string;
    location: string | null;
    status: string;
    companies: {
      id: string;
      name: string;
      slug: string;
      logo_url: string | null;
      verified: boolean;
    };
  };
}

const STATUS_CONFIG: Record<string, { label: string; icon: React.ElementType; className: string }> = {
  pending: {
    label: "Pending",
    icon: Clock,
    className: "bg-secondary text-secondary-foreground border-border",
  },
  reviewed: {
    label: "Reviewed",
    icon: Eye,
    className: "bg-blue-500/10 text-blue-600 border-blue-500/20",
  },
  shortlisted: {
    label: "Shortlisted",
    icon: Star,
    className: "bg-amber-500/10 text-amber-600 border-amber-500/20",
  },
  hired: {
    label: "Hired",
    icon: CheckCircle2,
    className: "bg-green-500/10 text-green-600 border-green-500/20",
  },
  rejected: {
    label: "Not Selected",
    icon: XCircle,
    className: "bg-red-500/10 text-red-600 border-red-500/20",
  },
};

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

export default function MyApplicationsPage() {
  const { user, loading: authLoading } = useAuth();
  const [applications, setApplications] = useState<ApplicationWithJob[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [filter, setFilter] = useState<string>("all");

  useEffect(() => {
    if (authLoading) return;
    if (!user) {
      setIsLoading(false);
      return;
    }

    async function fetchApplications() {
      try {
        const res = await fetch("/api/applications");
        const data = await res.json();
        setApplications(data.applications ?? []);
      } catch {
        toast.error("Failed to load applications");
        setApplications([]);
      } finally {
        setIsLoading(false);
      }
    }
    fetchApplications();
  }, [user, authLoading]);

  const filteredApplications =
    filter === "all"
      ? applications
      : applications.filter((a) => a.status === filter);

  const statusCounts = applications.reduce<Record<string, number>>((acc, a) => {
    acc[a.status] = (acc[a.status] || 0) + 1;
    return acc;
  }, {});

  if (!authLoading && !user) {
    return (
      <>
        <SimpleHeader />
        <div className="min-h-screen bg-background flex items-center justify-center">
          <div className="text-center">
            <Briefcase className="h-12 w-12 mx-auto mb-4 text-muted-foreground opacity-30" />
            <p className="text-lg font-medium mb-2">Sign in to view your applications</p>
            <Button asChild>
              <Link href="/login">Sign In</Link>
            </Button>
          </div>
        </div>
        <Footer />
      </>
    );
  }

  return (
    <>
      <SimpleHeader />
      <div className="min-h-screen bg-background">
        <div className="border-b border-border bg-card/50">
          <div className="container mx-auto px-4 py-10 max-w-5xl">
            <h1 className="text-4xl font-bold mb-2">My Applications</h1>
            <p className="text-muted-foreground">
              {applications.length > 0
                ? `${applications.length} application${applications.length !== 1 ? "s" : ""} submitted`
                : "Track your job applications here"}
            </p>
          </div>
        </div>

        <div className="container mx-auto px-4 py-8 max-w-5xl">
          {/* Filter tabs */}
          {applications.length > 0 && (
            <div className="flex flex-wrap gap-2 mb-6">
              <button
                onClick={() => setFilter("all")}
                className={`px-3 py-1 rounded-full text-xs font-medium border transition-colors ${
                  filter === "all"
                    ? "bg-indigo-500 text-white border-indigo-500"
                    : "border-border hover:border-indigo-500/50 text-muted-foreground hover:text-foreground"
                }`}
              >
                All ({applications.length})
              </button>
              {Object.entries(STATUS_CONFIG).map(([key, config]) => {
                const count = statusCounts[key] || 0;
                if (count === 0) return null;
                return (
                  <button
                    key={key}
                    onClick={() => setFilter(key)}
                    className={`px-3 py-1 rounded-full text-xs font-medium border transition-colors ${
                      filter === key
                        ? "bg-indigo-500 text-white border-indigo-500"
                        : "border-border hover:border-indigo-500/50 text-muted-foreground hover:text-foreground"
                    }`}
                  >
                    {config.label} ({count})
                  </button>
                );
              })}
            </div>
          )}

          {/* Applications List */}
          {isLoading ? (
            <div className="flex justify-center py-20">
              <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
            </div>
          ) : filteredApplications.length === 0 ? (
            <div className="text-center py-20 text-muted-foreground">
              <Briefcase className="h-12 w-12 mx-auto mb-4 opacity-30" />
              {applications.length === 0 ? (
                <>
                  <p className="text-lg font-medium">No applications yet</p>
                  <p className="text-sm mt-1">
                    Browse open positions and start applying.
                  </p>
                  <Button variant="outline" className="mt-4" asChild>
                    <Link href="/jobs">Browse Jobs</Link>
                  </Button>
                </>
              ) : (
                <p className="text-lg font-medium">
                  No {STATUS_CONFIG[filter]?.label?.toLowerCase()} applications
                </p>
              )}
            </div>
          ) : (
            <div className="space-y-3">
              {filteredApplications.map((app) => {
                const job = app.job_listings;
                const company = job?.companies;
                const statusConfig = STATUS_CONFIG[app.status] ?? STATUS_CONFIG.pending;
                const StatusIcon = statusConfig.icon;

                return (
                  <Card
                    key={app.id}
                    className="hover:border-indigo-500/40 transition-colors"
                  >
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
                              <h3 className="font-semibold">{job?.title ?? "Unknown Position"}</h3>
                              {company && (
                                <Link
                                  href={`/company/${company.slug}`}
                                  className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                                >
                                  {company.name}
                                </Link>
                              )}
                            </div>
                            <div className="flex items-center gap-2 shrink-0">
                              <Badge className={`text-xs gap-1 border ${statusConfig.className}`}>
                                <StatusIcon className="h-3 w-3" />
                                {statusConfig.label}
                              </Badge>
                              <Button size="sm" variant="outline" className="gap-1" asChild>
                                <Link href={`/jobs/${app.job_id}`}>
                                  View
                                  <ArrowRight className="h-3.5 w-3.5" />
                                </Link>
                              </Button>
                            </div>
                          </div>

                          <div className="flex flex-wrap items-center gap-3 text-xs text-muted-foreground mt-2">
                            {job && (
                              <>
                                <span className="flex items-center gap-1">
                                  <Clock className="h-3 w-3" />
                                  {JOB_TYPE_LABELS[job.type] ?? job.type}
                                </span>
                                <span className="flex items-center gap-1">
                                  <MapPin className="h-3 w-3" />
                                  {LOCATION_TYPE_LABELS[job.location_type] ?? job.location_type}
                                  {job.location ? ` · ${job.location}` : ""}
                                </span>
                              </>
                            )}
                            <span>
                              Applied{" "}
                              {new Date(app.applied_at).toLocaleDateString("en-US", {
                                month: "short",
                                day: "numeric",
                                year: "numeric",
                              })}
                            </span>
                            {job?.status === "closed" && (
                              <Badge variant="secondary" className="text-xs">
                                Position Closed
                              </Badge>
                            )}
                          </div>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                );
              })}
            </div>
          )}
        </div>
      </div>
      <Footer />
    </>
  );
}
