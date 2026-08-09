"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { PostJobForm } from "@/components/company/PostJobForm";
import { ApplicationsPanel } from "@/components/company/ApplicationsPanel";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import {
  Building2,
  Briefcase,
  Users,
  Plus,
  ExternalLink,
  ShieldCheck,
  Globe,
  Eye,
  EyeOff,
  Loader2,
  Pencil,
  Settings,
} from "lucide-react";
import { toast } from "sonner";
import type { Company, JobListing, ApplicationStatus } from "@/types/jobs";

interface ApplicationWithApplicant {
  id: string;
  job_id: string;
  user_id: string;
  status: ApplicationStatus;
  cover_note: string | null;
  applied_at: string;
  applicant: {
    id: string;
    username: string;
    full_name: string | null;
    avatar_url: string | null;
    location: string | null;
    github_username: string | null;
    completed_exercises: number;
    has_credential: boolean;
    profile_url: string;
  } | null;
}

interface CompanyDashboardClientProps {
  company: Company;
  listings: JobListing[];
  applications: ApplicationWithApplicant[];
}

function JobListingRow({
  job,
  applicationCount,
  onSelect,
  isSelected,
  onToggleStatus,
  isTogglingId,
  onEdit,
}: {
  job: JobListing;
  applicationCount: number;
  onSelect: () => void;
  isSelected: boolean;
  onToggleStatus: (id: string, current: "open" | "closed") => void;
  isTogglingId: string | null;
  onEdit: (job: JobListing) => void;
}) {
  const JOB_TYPE_LABELS: Record<string, string> = {
    "full-time": "Full-time",
    "part-time": "Part-time",
    contract: "Contract",
  };

  return (
    <div
      className={`p-4 rounded-xl border transition-colors cursor-pointer ${
        isSelected
          ? "border-indigo-500/60 bg-indigo-500/5"
          : "border-border hover:border-border/80 bg-card"
      }`}
      onClick={onSelect}
    >
      <div className="flex flex-wrap items-start gap-3 justify-between">
        <div className="min-w-0">
          <div className="flex flex-wrap items-center gap-2 mb-1">
            <span className="font-medium text-sm">{job.title}</span>
            <Badge
              variant={job.status === "open" ? "default" : "secondary"}
              className={`text-xs ${job.status === "open" ? "bg-green-500/10 text-green-600 border-green-500/20" : ""}`}
            >
              {job.status === "open" ? "Open" : "Closed"}
            </Badge>
          </div>
          <div className="flex flex-wrap gap-2 text-xs text-muted-foreground">
            <span>{JOB_TYPE_LABELS[job.type] ?? job.type}</span>
            <span>·</span>
            <span>{applicationCount} application{applicationCount !== 1 ? "s" : ""}</span>
            <span>·</span>
            <span>
              {new Date(job.created_at).toLocaleDateString("en-US", {
                month: "short",
                day: "numeric",
              })}
            </span>
          </div>
        </div>
        <div className="flex gap-2 shrink-0" onClick={(e) => e.stopPropagation()}>
          <Button variant="ghost" size="sm" className="h-7 text-xs gap-1" onClick={() => onEdit(job)}>
            <Pencil className="h-3 w-3" />
            Edit
          </Button>
          <Button variant="ghost" size="sm" className="h-7 text-xs gap-1" asChild>
            <Link href={`/jobs/${job.id}`} target="_blank">
              <ExternalLink className="h-3 w-3" />
              View
            </Link>
          </Button>
          <Button
            variant="outline"
            size="sm"
            className="h-7 text-xs gap-1"
            disabled={isTogglingId === job.id}
            onClick={() => onToggleStatus(job.id, job.status as "open" | "closed")}
          >
            {isTogglingId === job.id ? (
              <Loader2 className="h-3 w-3 animate-spin" />
            ) : job.status === "open" ? (
              <>
                <EyeOff className="h-3 w-3" />
                Close
              </>
            ) : (
              <>
                <Eye className="h-3 w-3" />
                Reopen
              </>
            )}
          </Button>
        </div>
      </div>
    </div>
  );
}

export function CompanyDashboardClient({
  company,
  listings: initialListings,
  applications,
}: CompanyDashboardClientProps) {
  const router = useRouter();
  const [listings, setListings] = useState<JobListing[]>(initialListings);
  const [activeTab, setActiveTab] = useState("overview");
  const [selectedJobId, setSelectedJobId] = useState<string | undefined>();
  const [isTogglingId, setIsTogglingId] = useState<string | null>(null);
  const [editingJob, setEditingJob] = useState<JobListing | null>(null);
  const [companyForm, setCompanyForm] = useState({
    name: company.name,
    description: company.description ?? "",
    website: company.website ?? "",
    logo_url: company.logo_url ?? "",
    contact_email: company.contact_email ?? "",
  });
  const [isSavingCompany, setIsSavingCompany] = useState(false);
  const [, startTransition] = useTransition();

  const jobTitles = Object.fromEntries(listings.map((j) => [j.id, j.title]));

  const openCount = listings.filter((j) => j.status === "open").length;
  const totalApplications = applications.length;
  const pendingApplications = applications.filter((a) => a.status === "pending").length;

  function handleJobCreated() {
    setEditingJob(null);
    startTransition(() => {
      router.refresh();
    });
    setActiveTab("listings");
  }

  function handleEditJob(job: JobListing) {
    setEditingJob(job);
    setActiveTab("post-job");
  }

  async function handleSaveCompany(e: React.FormEvent) {
    e.preventDefault();
    setIsSavingCompany(true);
    try {
      const res = await fetch(`/api/companies/${company.slug}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: companyForm.name.trim(),
          description: companyForm.description.trim() || null,
          website: companyForm.website.trim() || null,
          logo_url: companyForm.logo_url.trim() || null,
          contact_email: companyForm.contact_email.trim() || null,
        }),
      });
      const data = await res.json();
      if (!res.ok) {
        toast.error(data.error ?? "Failed to update company");
        return;
      }
      toast.success("Company profile updated!");
      startTransition(() => router.refresh());
    } catch {
      toast.error("Something went wrong");
    } finally {
      setIsSavingCompany(false);
    }
  }

  async function toggleJobStatus(jobId: string, current: "open" | "closed") {
    setIsTogglingId(jobId);
    try {
      const res = await fetch(`/api/jobs/${jobId}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status: current === "open" ? "closed" : "open" }),
      });
      const data = await res.json();
      if (!res.ok) {
        toast.error(data.error ?? "Failed to update listing");
        return;
      }
      setListings((prev) =>
        prev.map((j) => (j.id === jobId ? { ...j, status: data.job.status } : j))
      );
      toast.success(`Listing ${data.job.status === "open" ? "reopened" : "closed"}`);
    } catch {
      toast.error("Something went wrong");
    } finally {
      setIsTogglingId(null);
    }
  }

  return (
    <div className="container mx-auto px-4 py-8 max-w-6xl">
      {/* Company Header */}
      <div className="flex flex-col sm:flex-row gap-4 items-start justify-between mb-8">
        <div className="flex gap-4 items-center">
          <div className="h-14 w-14 rounded-2xl border border-border bg-card flex items-center justify-center overflow-hidden shrink-0">
            {company.logo_url ? (
              <Image
                src={company.logo_url}
                alt={company.name}
                width={56}
                height={56}
                className="object-contain"
              />
            ) : (
              <Building2 className="h-7 w-7 text-muted-foreground" />
            )}
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-bold">{company.name}</h1>
              {company.verified && (
                <Badge className="gap-1 bg-indigo-500/10 text-indigo-600 border-indigo-500/20 text-xs">
                  <ShieldCheck className="h-3 w-3" />
                  Verified
                </Badge>
              )}
              {!company.verified && (
                <Badge variant="outline" className="text-xs text-muted-foreground">
                  Pending verification
                </Badge>
              )}
            </div>
            {company.website && (
              <a
                href={company.website}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-muted-foreground hover:text-foreground flex items-center gap-1 mt-0.5"
              >
                <Globe className="h-3 w-3" />
                {company.website.replace(/^https?:\/\//, "")}
              </a>
            )}
          </div>
        </div>

        <div className="flex gap-2 shrink-0">
          <Button variant="outline" size="sm" asChild>
            <Link href={`/company/${company.slug}`} target="_blank">
              <ExternalLink className="h-3.5 w-3.5 mr-1" />
              Public Profile
            </Link>
          </Button>
          <Button
            size="sm"
            onClick={() => setActiveTab("post-job")}
            disabled={!company.verified}
            title={!company.verified ? "Verification required to post jobs" : undefined}
          >
            <Plus className="h-3.5 w-3.5 mr-1" />
            Post a Job
          </Button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 mb-8">
        {[
          {
            label: "Open Listings",
            value: openCount,
            icon: Briefcase,
            color: "text-indigo-500",
          },
          {
            label: "Total Applications",
            value: totalApplications,
            icon: Users,
            color: "text-green-500",
          },
          {
            label: "Pending Review",
            value: pendingApplications,
            icon: Users,
            color: "text-amber-500",
          },
        ].map(({ label, value, icon: Icon, color }) => (
          <Card key={label}>
            <CardContent className="p-4">
              <div className="flex items-center gap-3">
                <div className={`h-9 w-9 rounded-xl bg-background border border-border flex items-center justify-center ${color}`}>
                  <Icon className="h-4 w-4" />
                </div>
                <div>
                  <p className="text-2xl font-bold">{value}</p>
                  <p className="text-xs text-muted-foreground">{label}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="mb-6">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="listings">
            Listings
            {listings.length > 0 && (
              <Badge variant="secondary" className="ml-1.5 text-xs px-1.5 py-0 h-4">
                {listings.length}
              </Badge>
            )}
          </TabsTrigger>
          <TabsTrigger value="applications">
            Applications
            {pendingApplications > 0 && (
              <Badge className="ml-1.5 text-xs px-1.5 py-0 h-4 bg-amber-500">
                {pendingApplications}
              </Badge>
            )}
          </TabsTrigger>
          <TabsTrigger value="post-job">
            {editingJob ? "Edit Job" : "+ Post a Job"}
          </TabsTrigger>
          <TabsTrigger value="settings">
            <Settings className="h-3.5 w-3.5 mr-1" />
            Settings
          </TabsTrigger>
        </TabsList>

        {/* Overview Tab */}
        <TabsContent value="overview" className="space-y-4">
          <div className="grid lg:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="text-sm font-semibold flex items-center gap-2">
                  <Briefcase className="h-4 w-4" />
                  Recent Listings
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {listings.length === 0 ? (
                  <div className="text-center py-8 text-muted-foreground">
                    <p className="text-sm">No listings yet.</p>
                    <Button
                      variant="outline"
                      size="sm"
                      className="mt-3"
                      onClick={() => setActiveTab("post-job")}
                    >
                      <Plus className="h-3.5 w-3.5 mr-1" />
                      Post your first job
                    </Button>
                  </div>
                ) : (
                  listings.slice(0, 3).map((job) => {
                    const count = applications.filter((a) => a.job_id === job.id).length;
                    return (
                      <div
                        key={job.id}
                        className="flex items-center justify-between gap-3 py-2 border-b border-border last:border-0"
                      >
                        <div>
                          <p className="font-medium text-sm">{job.title}</p>
                          <p className="text-xs text-muted-foreground">
                            {count} application{count !== 1 ? "s" : ""}
                          </p>
                        </div>
                        <Badge
                          variant={job.status === "open" ? "default" : "secondary"}
                          className="text-xs shrink-0"
                        >
                          {job.status}
                        </Badge>
                      </div>
                    );
                  })
                )}
                {listings.length > 3 && (
                  <Button
                    variant="ghost"
                    size="sm"
                    className="w-full text-muted-foreground"
                    onClick={() => setActiveTab("listings")}
                  >
                    View all {listings.length} listings
                  </Button>
                )}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-sm font-semibold flex items-center gap-2">
                  <Users className="h-4 w-4" />
                  Recent Applications
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {applications.length === 0 ? (
                  <div className="text-center py-8 text-muted-foreground">
                    <p className="text-sm">No applications yet.</p>
                    <p className="text-xs mt-1">Applications will appear here once developers apply.</p>
                  </div>
                ) : (
                  applications.slice(0, 4).map((app) => (
                    <div
                      key={app.id}
                      className="flex items-center gap-3 py-2 border-b border-border last:border-0"
                    >
                      <div className="flex-1 min-w-0">
                        <p className="font-medium text-sm truncate">
                          {app.applicant?.full_name || app.applicant?.username || "Unknown"}
                        </p>
                        <p className="text-xs text-muted-foreground truncate">
                          {jobTitles[app.job_id]}
                        </p>
                      </div>
                      <Badge
                        className={`text-xs shrink-0 border ${
                          app.status === "shortlisted"
                            ? "bg-amber-500/10 text-amber-600 border-amber-500/20"
                            : app.status === "reviewed"
                            ? "bg-blue-500/10 text-blue-600 border-blue-500/20"
                            : app.status === "rejected"
                            ? "bg-red-500/10 text-red-600 border-red-500/20"
                            : "bg-secondary text-secondary-foreground border-border"
                        }`}
                      >
                        {app.status}
                      </Badge>
                    </div>
                  ))
                )}
                {applications.length > 4 && (
                  <Button
                    variant="ghost"
                    size="sm"
                    className="w-full text-muted-foreground"
                    onClick={() => setActiveTab("applications")}
                  >
                    View all {applications.length} applications
                  </Button>
                )}
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* Listings Tab */}
        <TabsContent value="listings" className="space-y-3">
          {listings.length === 0 ? (
            <div className="text-center py-16 text-muted-foreground border border-dashed border-border rounded-xl">
              <Briefcase className="h-10 w-10 mx-auto mb-3 opacity-30" />
              <p>No job listings yet</p>
              <Button
                variant="outline"
                size="sm"
                className="mt-4"
                onClick={() => setActiveTab("post-job")}
              >
                <Plus className="h-3.5 w-3.5 mr-1" />
                Post your first job
              </Button>
            </div>
          ) : (
            <>
              {selectedJobId && (
                <div className="flex items-center gap-2 mb-2">
                  <p className="text-sm text-muted-foreground">
                    Showing applications for: <strong>{jobTitles[selectedJobId]}</strong>
                  </p>
                  <Button
                    variant="ghost"
                    size="sm"
                    className="h-6 text-xs"
                    onClick={() => setSelectedJobId(undefined)}
                  >
                    Show all
                  </Button>
                </div>
              )}
              {listings.map((job) => (
                <JobListingRow
                  key={job.id}
                  job={job}
                  applicationCount={applications.filter((a) => a.job_id === job.id).length}
                  isSelected={selectedJobId === job.id}
                  onSelect={() => {
                    setSelectedJobId(selectedJobId === job.id ? undefined : job.id);
                    if (selectedJobId !== job.id) setActiveTab("applications");
                  }}
                  onToggleStatus={toggleJobStatus}
                  isTogglingId={isTogglingId}
                  onEdit={handleEditJob}
                />
              ))}
            </>
          )}
        </TabsContent>

        {/* Applications Tab */}
        <TabsContent value="applications">
          {applications.length === 0 ? (
            <div className="text-center py-16 text-muted-foreground border border-dashed border-border rounded-xl">
              <Users className="h-10 w-10 mx-auto mb-3 opacity-30" />
              <p>No applications yet</p>
              <p className="text-sm mt-1">Applications will appear here once developers apply to your listings.</p>
            </div>
          ) : (
            <ApplicationsPanel
              applications={applications}
              jobTitles={jobTitles}
              selectedJobId={selectedJobId}
            />
          )}
        </TabsContent>

        {/* Post Job Tab */}
        <TabsContent value="post-job">
          {!company.verified && !editingJob ? (
            <div className="text-center py-16 border border-dashed border-amber-500/30 rounded-xl bg-amber-500/5">
              <ShieldCheck className="h-10 w-10 mx-auto mb-3 text-amber-500 opacity-60" />
              <p className="text-lg font-medium mb-1">Verification Required</p>
              <p className="text-sm text-muted-foreground max-w-md mx-auto">
                Your company is pending verification. Once our team verifies your company,
                you&apos;ll be able to post job listings. This usually takes 1-2 business days.
              </p>
            </div>
          ) : (
            <PostJobForm
              key={editingJob?.id ?? "new"}
              onJobCreated={handleJobCreated}
              editingJob={editingJob}
              onCancelEdit={() => {
                setEditingJob(null);
                setActiveTab("listings");
              }}
            />
          )}
        </TabsContent>

        {/* Settings Tab */}
        <TabsContent value="settings">
          <form onSubmit={handleSaveCompany} className="space-y-5 max-w-2xl">
            <Card>
              <CardHeader>
                <CardTitle className="text-base flex items-center gap-2">
                  <Settings className="h-4 w-4" />
                  Company Profile
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="company-name">Company Name</Label>
                  <Input
                    id="company-name"
                    value={companyForm.name}
                    onChange={(e) => setCompanyForm((f) => ({ ...f, name: e.target.value }))}
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="company-description">About</Label>
                  <Textarea
                    id="company-description"
                    value={companyForm.description}
                    onChange={(e) => setCompanyForm((f) => ({ ...f, description: e.target.value }))}
                    rows={4}
                    placeholder="Describe your company…"
                  />
                </div>
                <div className="grid gap-4 sm:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor="company-website">Website</Label>
                    <Input
                      id="company-website"
                      type="url"
                      value={companyForm.website}
                      onChange={(e) => setCompanyForm((f) => ({ ...f, website: e.target.value }))}
                      placeholder="https://example.com"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="company-email">Contact Email</Label>
                    <Input
                      id="company-email"
                      type="email"
                      value={companyForm.contact_email}
                      onChange={(e) => setCompanyForm((f) => ({ ...f, contact_email: e.target.value }))}
                      placeholder="hiring@example.com"
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="company-logo">Logo URL</Label>
                  <Input
                    id="company-logo"
                    type="url"
                    value={companyForm.logo_url}
                    onChange={(e) => setCompanyForm((f) => ({ ...f, logo_url: e.target.value }))}
                    placeholder="https://example.com/logo.png"
                  />
                  <p className="text-xs text-muted-foreground">128x128px minimum recommended</p>
                </div>
              </CardContent>
            </Card>
            <div className="flex justify-end">
              <Button type="submit" disabled={isSavingCompany} className="min-w-36">
                {isSavingCompany ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Saving…
                  </>
                ) : (
                  "Save Changes"
                )}
              </Button>
            </div>
          </form>
        </TabsContent>
      </Tabs>
    </div>
  );
}
