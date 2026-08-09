"use client";

import { useState } from "react";
import Link from "next/link";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { toast } from "sonner";
import {
  ShieldCheck,
  BookOpen,
  MapPin,
  ExternalLink,
  MoreVertical,
  CheckCircle2,
  Eye,
  Star,
  XCircle,
  Clock,
} from "lucide-react";
import type { ApplicationStatus } from "@/types/jobs";

interface Applicant {
  id: string;
  username: string;
  full_name: string | null;
  avatar_url: string | null;
  location: string | null;
  github_username: string | null;
  completed_exercises: number;
  has_credential: boolean;
  profile_url: string;
  bio?: string | null;
  skills_summary?: string | null;
  available_roles?: string[];
}

interface Application {
  id: string;
  job_id: string;
  user_id: string;
  status: ApplicationStatus;
  cover_note: string | null;
  applied_at: string;
  applicant: Applicant | null;
}

interface ApplicationsPanelProps {
  applications: Application[];
  jobTitles: Record<string, string>;
  selectedJobId?: string;
}

const STATUS_CONFIG: Record<
  ApplicationStatus,
  { label: string; icon: React.ElementType; className: string }
> = {
  pending: {
    label: "Pending",
    icon: Clock,
    className: "bg-secondary text-secondary-foreground",
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
  rejected: {
    label: "Rejected",
    icon: XCircle,
    className: "bg-red-500/10 text-red-600 border-red-500/20",
  },
  hired: {
    label: "Hired",
    icon: CheckCircle2,
    className: "bg-green-500/10 text-green-600 border-green-500/20",
  },
};

const NEXT_STATUSES: Record<ApplicationStatus, ApplicationStatus[]> = {
  pending: ["reviewed", "shortlisted", "rejected"],
  reviewed: ["shortlisted", "rejected", "pending"],
  shortlisted: ["hired", "reviewed", "rejected"],
  rejected: ["pending"],
  hired: [],
};

function ApplicationCard({
  application,
  jobTitle,
}: {
  application: Application;
  jobTitle?: string;
}) {
  const [status, setStatus] = useState<ApplicationStatus>(application.status);
  const [isUpdating, setIsUpdating] = useState(false);
  const applicant = application.applicant;

  async function updateStatus(newStatus: ApplicationStatus) {
    setIsUpdating(true);
    try {
      const res = await fetch("/api/company/applications", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ application_id: application.id, status: newStatus }),
      });
      const data = await res.json();
      if (!res.ok) {
        toast.error(data.error ?? "Failed to update status");
        return;
      }
      setStatus(newStatus);
      toast.success(`Status updated to "${newStatus}"`);
    } catch {
      toast.error("Something went wrong");
    } finally {
      setIsUpdating(false);
    }
  }

  const statusConfig = STATUS_CONFIG[status];
  const StatusIcon = statusConfig.icon;
  const initials = (applicant?.full_name || applicant?.username || "?")
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);

  return (
    <Card className="hover:border-border/80 transition-colors">
      <CardContent className="p-4">
        <div className="flex gap-3 items-start">
          <Avatar className="h-10 w-10 shrink-0">
            <AvatarImage src={applicant?.avatar_url ?? undefined} />
            <AvatarFallback>{initials}</AvatarFallback>
          </Avatar>

          <div className="flex-1 min-w-0">
            <div className="flex flex-wrap items-center gap-2 justify-between mb-1">
              <div className="flex flex-wrap items-center gap-2">
                <span className="font-medium text-sm">
                  {applicant?.full_name || applicant?.username || "Unknown"}
                </span>
                {applicant?.username && (
                  <span className="text-xs text-muted-foreground">@{applicant.username}</span>
                )}
              </div>

              <div className="flex items-center gap-2">
                <Badge className={`text-xs gap-1 border ${statusConfig.className}`}>
                  <StatusIcon className="h-3 w-3" />
                  {statusConfig.label}
                </Badge>

                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="ghost" size="icon" className="h-7 w-7" disabled={isUpdating}>
                      <MoreVertical className="h-3.5 w-3.5" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end" className="w-44">
                    {applicant && (
                      <>
                        <DropdownMenuItem asChild>
                          <Link href={applicant.profile_url} target="_blank">
                            <ExternalLink className="h-3.5 w-3.5 mr-2" />
                            View Profile
                          </Link>
                        </DropdownMenuItem>
                        <DropdownMenuSeparator />
                      </>
                    )}
                    {NEXT_STATUSES[status].map((s) => {
                      const conf = STATUS_CONFIG[s];
                      const Icon = conf.icon;
                      return (
                        <DropdownMenuItem key={s} onClick={() => updateStatus(s)}>
                          <Icon className="h-3.5 w-3.5 mr-2" />
                          Mark as {conf.label}
                        </DropdownMenuItem>
                      );
                    })}
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>
            </div>

            <div className="flex flex-wrap gap-3 text-xs text-muted-foreground mb-2">
              {applicant?.location && (
                <span className="flex items-center gap-1">
                  <MapPin className="h-3 w-3" />
                  {applicant.location}
                </span>
              )}
              <span className="flex items-center gap-1">
                <BookOpen className="h-3 w-3" />
                {applicant?.completed_exercises ?? 0} exercises
              </span>
              {applicant?.has_credential && (
                <span className="flex items-center gap-1 text-indigo-600">
                  <ShieldCheck className="h-3 w-3" />
                  Credential
                </span>
              )}
              {jobTitle && (
                <span className="flex items-center gap-1">
                  <CheckCircle2 className="h-3 w-3" />
                  {jobTitle}
                </span>
              )}
            </div>

            {applicant?.available_roles && applicant.available_roles.length > 0 && (
              <div className="flex flex-wrap gap-1 mb-2">
                {applicant.available_roles.map((role) => (
                  <Badge key={role} variant="secondary" className="text-[10px] px-1.5 py-0">
                    {role}
                  </Badge>
                ))}
              </div>
            )}

            {applicant?.skills_summary && (
              <p className="text-xs text-muted-foreground mb-2 line-clamp-2">
                {applicant.skills_summary}
              </p>
            )}

            {application.cover_note && (
              <div className="mt-2 text-xs text-muted-foreground bg-muted/40 rounded-lg p-3 border border-border/50 line-clamp-3">
                {application.cover_note}
              </div>
            )}

            <p className="text-xs text-muted-foreground mt-2">
              Applied {new Date(application.applied_at).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })}
            </p>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

export function ApplicationsPanel({
  applications,
  jobTitles,
  selectedJobId,
}: ApplicationsPanelProps) {
  const [filter, setFilter] = useState<ApplicationStatus | "all">("all");

  const filtered = applications
    .filter((a) => !selectedJobId || a.job_id === selectedJobId)
    .filter((a) => filter === "all" || a.status === filter);

  const scoped = applications.filter((a) => !selectedJobId || a.job_id === selectedJobId);
  const counts = {
    all: scoped.length,
    pending: scoped.filter((a) => a.status === "pending").length,
    reviewed: scoped.filter((a) => a.status === "reviewed").length,
    shortlisted: scoped.filter((a) => a.status === "shortlisted").length,
    hired: scoped.filter((a) => a.status === "hired").length,
    rejected: scoped.filter((a) => a.status === "rejected").length,
  };

  const filterOptions: { value: ApplicationStatus | "all"; label: string }[] = [
    { value: "all", label: `All (${counts.all})` },
    { value: "pending", label: `Pending (${counts.pending})` },
    { value: "reviewed", label: `Reviewed (${counts.reviewed})` },
    { value: "shortlisted", label: `Shortlisted (${counts.shortlisted})` },
    { value: "hired", label: `Hired (${counts.hired})` },
    { value: "rejected", label: `Rejected (${counts.rejected})` },
  ];

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap gap-1">
        {filterOptions.map((opt) => (
          <button
            key={opt.value}
            onClick={() => setFilter(opt.value)}
            className={`px-3 py-1 rounded-full text-xs font-medium border transition-colors ${
              filter === opt.value
                ? "bg-indigo-500 text-white border-indigo-500"
                : "border-border text-muted-foreground hover:text-foreground hover:border-indigo-500/50"
            }`}
          >
            {opt.label}
          </button>
        ))}
      </div>

      {filtered.length === 0 ? (
        <div className="text-center py-12 text-muted-foreground border border-dashed border-border rounded-xl">
          <CheckCircle2 className="h-8 w-8 mx-auto mb-2 opacity-30" />
          <p className="text-sm">No applications in this category</p>
        </div>
      ) : (
        <div className="space-y-3">
          {filtered.map((app) => (
            <ApplicationCard
              key={app.id}
              application={app}
              jobTitle={jobTitles[app.job_id]}
            />
          ))}
        </div>
      )}
    </div>
  );
}
