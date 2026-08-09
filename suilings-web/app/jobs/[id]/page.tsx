import { notFound } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { createAdminClient } from "@/lib/supabase/admin";
import { createClient } from "@/lib/supabase/server";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { Footer } from "@/components/layout/Footer";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import {
  Building2,
  MapPin,
  Clock,
  ShieldCheck,
  Globe,
  ArrowLeft,
  BookOpen,
  Users,
  CheckCircle2,
  ExternalLink,
} from "lucide-react";
import ReactMarkdown from "react-markdown";
import { JobApplySection } from "@/components/jobs/JobApplySection";
import type { JobListing, Company } from "@/types/jobs";

interface JobPageProps {
  params: Promise<{ id: string }>;
}

interface JobWithCompany extends JobListing {
  companies: Company;
}

export async function generateMetadata({ params }: JobPageProps) {
  const { id } = await params;
  const admin = createAdminClient();
  const { data: job } = await admin
    .from("job_listings")
    .select("title, companies(name)")
    .eq("id", id)
    .single();

  if (!job) return { title: "Job Not Found — Suilings" };
  const company = Array.isArray(job.companies) ? job.companies[0] : job.companies;
  return {
    title: `${job.title} at ${company?.name ?? "Unknown"} — Suilings Jobs`,
  };
}

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
  if (min && max) return `${symbol}${fmt(min)} – ${symbol}${fmt(max)} / year`;
  if (min) return `From ${symbol}${fmt(min)} / year`;
  return `Up to ${symbol}${fmt(max!)} / year`;
}

export default async function JobDetailPage({ params }: JobPageProps) {
  const { id } = await params;
  const admin = createAdminClient();

  const { data: jobData } = await admin
    .from("job_listings")
    .select(`*, companies (*)`)
    .eq("id", id)
    .single();

  if (!jobData) notFound();

  const job = jobData as JobWithCompany;
  const company = Array.isArray(job.companies) ? job.companies[0] : job.companies;

  const { count: applicationCount } = await admin
    .from("job_applications")
    .select("id", { count: "exact", head: true })
    .eq("job_id", id);

  // Check current user
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  let userProfile: {
    username: string;
    full_name: string | null;
    avatar_url: string | null;
    completed_exercises: number;
    has_credential: boolean;
  } | null = null;

  let alreadyApplied = false;

  if (user) {
    const [{ data: profile }, { count: completedCount }, { data: credential }, { data: existingApp }] =
      await Promise.all([
        admin.from("profiles").select("username, full_name, avatar_url").eq("id", user.id).single(),
        admin
          .from("exercise_progress")
          .select("id", { count: "exact", head: true })
          .eq("user_id", user.id)
          .eq("status", "completed"),
        admin.from("sbt_credentials").select("id").eq("user_id", user.id).single(),
        admin
          .from("job_applications")
          .select("id")
          .eq("job_id", id)
          .eq("user_id", user.id)
          .single(),
      ]);

    if (profile) {
      userProfile = {
        username: profile.username,
        full_name: profile.full_name,
        avatar_url: profile.avatar_url,
        completed_exercises: completedCount ?? 0,
        has_credential: !!credential,
      };
    }
    alreadyApplied = !!existingApp;
  }

  const salary = formatSalary(job.salary_min, job.salary_max, job.currency ?? "USD");

  return (
    <>
      <SimpleHeader />
      <div className="min-h-screen bg-background">
        <div className="container mx-auto px-4 py-8 max-w-5xl">
          <Button variant="ghost" size="sm" className="mb-6 -ml-2 gap-1 text-muted-foreground" asChild>
            <Link href="/jobs">
              <ArrowLeft className="h-4 w-4" />
              All Jobs
            </Link>
          </Button>

          <div className="grid lg:grid-cols-[1fr_320px] gap-8">
            {/* Main Content */}
            <div className="space-y-6">
              {/* Header */}
              <div>
                <div className="flex flex-wrap items-center gap-2 mb-3">
                  <Badge variant="secondary">{JOB_TYPE_LABELS[job.type] ?? job.type}</Badge>
                  <Badge variant="secondary">
                    <MapPin className="h-3 w-3 mr-1" />
                    {LOCATION_TYPE_LABELS[job.location_type] ?? job.location_type}
                    {job.location ? ` · ${job.location}` : ""}
                  </Badge>
                  {job.requires_credential && (
                    <Badge className="gap-1 bg-amber-500/10 text-amber-600 border-amber-500/20">
                      <ShieldCheck className="h-3 w-3" />
                      Credential required
                    </Badge>
                  )}
                  {job.status === "closed" && (
                    <Badge variant="destructive">Closed</Badge>
                  )}
                </div>

                <h1 className="text-3xl font-bold mb-2">{job.title}</h1>

                {company && (
                  <Link
                    href={`/company/${company.slug}`}
                    className="inline-flex items-center gap-2 text-muted-foreground hover:text-foreground transition-colors"
                  >
                    <div className="h-7 w-7 rounded-lg border border-border bg-card flex items-center justify-center overflow-hidden">
                      {company.logo_url ? (
                        <Image
                          src={company.logo_url}
                          alt={company.name}
                          width={28}
                          height={28}
                          className="object-contain"
                        />
                      ) : (
                        <Building2 className="h-4 w-4" />
                      )}
                    </div>
                    <span className="font-medium">{company.name}</span>
                    {company.verified ? (
                      <ShieldCheck className="h-4 w-4 text-indigo-500" />
                    ) : (
                      <span className="text-xs text-muted-foreground border border-border rounded px-1.5 py-0.5">Unverified</span>
                    )}
                    <ExternalLink className="h-3.5 w-3.5 opacity-60" />
                  </Link>
                )}
              </div>

              <Separator />

              {/* Description */}
              <div>
                <h2 className="text-lg font-semibold mb-4">About this role</h2>
                <div className="prose prose-sm dark:prose-invert max-w-none text-muted-foreground leading-relaxed">
                  <ReactMarkdown>{job.description}</ReactMarkdown>
                </div>
              </div>

              {/* Requirements */}
              {(job.min_exercises_required > 0 || job.requires_credential) && (
                <>
                  <Separator />
                  <div>
                    <h2 className="text-lg font-semibold mb-4">Requirements</h2>
                    <ul className="space-y-3">
                      {job.min_exercises_required > 0 && (
                        <li className="flex items-start gap-3">
                          <div className="h-6 w-6 rounded-full bg-indigo-500/10 flex items-center justify-center shrink-0 mt-0.5">
                            <BookOpen className="h-3.5 w-3.5 text-indigo-500" />
                          </div>
                          <div>
                            <p className="font-medium text-sm">
                              {job.min_exercises_required}+ exercises completed
                            </p>
                            <p className="text-xs text-muted-foreground">
                              Demonstrates practical Move programming proficiency
                            </p>
                          </div>
                        </li>
                      )}
                      {job.requires_credential && (
                        <li className="flex items-start gap-3">
                          <div className="h-6 w-6 rounded-full bg-amber-500/10 flex items-center justify-center shrink-0 mt-0.5">
                            <ShieldCheck className="h-3.5 w-3.5 text-amber-500" />
                          </div>
                          <div>
                            <p className="font-medium text-sm">Suilings credential (SBT) required</p>
                            <p className="text-xs text-muted-foreground">
                              On-chain proof of completing all Suilings exercises
                            </p>
                          </div>
                        </li>
                      )}
                    </ul>
                  </div>
                </>
              )}
            </div>

            {/* Sidebar */}
            <div className="space-y-4">
              {/* Apply Card */}
              <Card className="sticky top-24">
                <CardContent className="p-5 space-y-4">
                  {salary && (
                    <div>
                      <p className="text-xs text-muted-foreground uppercase tracking-wide font-medium mb-0.5">
                        Compensation
                      </p>
                      <p className="font-semibold">{salary}</p>
                    </div>
                  )}

                  <div className="flex flex-col gap-1.5 text-sm">
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <Clock className="h-3.5 w-3.5 shrink-0" />
                      {JOB_TYPE_LABELS[job.type] ?? job.type}
                    </div>
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <MapPin className="h-3.5 w-3.5 shrink-0" />
                      {LOCATION_TYPE_LABELS[job.location_type] ?? job.location_type}
                      {job.location ? ` · ${job.location}` : ""}
                    </div>
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <Users className="h-3.5 w-3.5 shrink-0" />
                      {applicationCount ?? 0} applicant{applicationCount !== 1 ? "s" : ""}
                    </div>
                  </div>

                  <Separator />

                  {job.status === "closed" ? (
                    <div className="text-center py-2">
                      <p className="text-sm text-muted-foreground">This position is closed.</p>
                    </div>
                  ) : alreadyApplied ? (
                    <div className="flex items-center gap-2 text-sm text-green-600 justify-center py-1">
                      <CheckCircle2 className="h-4 w-4" />
                      <span className="font-medium">Application submitted</span>
                    </div>
                  ) : (
                    <JobApplySection
                      jobId={job.id}
                      jobTitle={job.title}
                      companyName={company?.name ?? ""}
                      isLoggedIn={!!user}
                      userProfile={
                        userProfile
                          ? {
                              username: userProfile.username,
                              displayName: userProfile.full_name || userProfile.username,
                              avatarUrl: userProfile.avatar_url,
                              completedExercises: userProfile.completed_exercises,
                              hasCredential: userProfile.has_credential,
                              profileUrl: `https://suilings.xyz/u/${userProfile.username}`,
                            }
                          : null
                      }
                    />
                  )}

                  {company && (
                    <Button variant="ghost" size="sm" className="w-full text-muted-foreground" asChild>
                      <Link href={`/company/${company.slug}`}>
                        <Globe className="h-3.5 w-3.5 mr-2" />
                        View company profile
                      </Link>
                    </Button>
                  )}
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </div>
      <Footer />
    </>
  );
}
