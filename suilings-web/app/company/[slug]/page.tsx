import { notFound } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { createAdminClient } from "@/lib/supabase/admin";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { Footer } from "@/components/layout/Footer";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  Globe,
  Mail,
  ShieldCheck,
  Briefcase,
  MapPin,
  ArrowRight,
  Building2,
  Clock,
} from "lucide-react";
import type { JobListing } from "@/types/jobs";

interface CompanyPageProps {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({ params }: CompanyPageProps) {
  const { slug } = await params;
  const admin = createAdminClient();
  const { data: company } = await admin
    .from("companies")
    .select("name, description")
    .eq("slug", slug)
    .single();

  return {
    title: company ? `${company.name} — Suilings Jobs` : "Company Not Found",
    description: company?.description ?? "",
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
  const fmt = (n: number) =>
    n >= 1000 ? `${currency}${(n / 1000).toFixed(0)}k` : `${currency}${n}`;
  if (min && max) return `${fmt(min)} – ${fmt(max)}`;
  if (min) return `From ${fmt(min)}`;
  return `Up to ${fmt(max!)}`;
}

export default async function CompanyProfilePage({ params }: CompanyPageProps) {
  const { slug } = await params;
  const admin = createAdminClient();

  const { data: company } = await admin
    .from("companies")
    .select("*")
    .eq("slug", slug)
    .single();

  if (!company) notFound();

  const { data: listings } = await admin
    .from("job_listings")
    .select("*")
    .eq("company_id", company.id)
    .eq("status", "open")
    .order("created_at", { ascending: false });

  const jobs = (listings ?? []) as JobListing[];

  return (
    <>
      <SimpleHeader />
      <div className="min-h-screen bg-background">
        {/* Hero */}
        <div className="border-b border-border bg-card">
          <div className="container mx-auto px-4 py-10 max-w-5xl">
            <div className="flex flex-col sm:flex-row gap-6 items-start">
              <div className="h-20 w-20 rounded-2xl border border-border bg-background flex items-center justify-center shrink-0 overflow-hidden">
                {company.logo_url ? (
                  <Image
                    src={company.logo_url}
                    alt={company.name}
                    width={80}
                    height={80}
                    className="object-contain"
                  />
                ) : (
                  <Building2 className="h-10 w-10 text-muted-foreground" />
                )}
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex flex-wrap items-center gap-2 mb-1">
                  <h1 className="text-3xl font-bold">{company.name}</h1>
                  {company.verified && (
                    <Badge className="gap-1 bg-indigo-500/10 text-indigo-600 border-indigo-500/20">
                      <ShieldCheck className="h-3 w-3" />
                      Verified
                    </Badge>
                  )}
                </div>

                {company.description && (
                  <p className="text-muted-foreground mt-2 max-w-2xl">{company.description}</p>
                )}

                <div className="flex flex-wrap gap-4 mt-4">
                  {company.website && (
                    <a
                      href={company.website}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
                    >
                      <Globe className="h-3.5 w-3.5" />
                      {company.website.replace(/^https?:\/\//, "")}
                    </a>
                  )}
                  {company.contact_email && (
                    <a
                      href={`mailto:${company.contact_email}`}
                      className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
                    >
                      <Mail className="h-3.5 w-3.5" />
                      {company.contact_email}
                    </a>
                  )}
                </div>
              </div>

              <div className="shrink-0">
                <Badge variant="secondary" className="gap-1.5">
                  <Briefcase className="h-3.5 w-3.5" />
                  {jobs.length} open {jobs.length === 1 ? "role" : "roles"}
                </Badge>
              </div>
            </div>
          </div>
        </div>

        {/* Job Listings */}
        <div className="container mx-auto px-4 py-10 max-w-5xl">
          <h2 className="text-xl font-semibold mb-6">Open Positions</h2>

          {jobs.length === 0 ? (
            <div className="text-center py-16 text-muted-foreground border border-dashed border-border rounded-xl">
              <Briefcase className="h-10 w-10 mx-auto mb-3 opacity-40" />
              <p>No open positions at the moment.</p>
              <p className="text-sm mt-1">Check back later or browse all jobs.</p>
              <Button variant="outline" className="mt-4" asChild>
                <Link href="/jobs">Browse All Jobs</Link>
              </Button>
            </div>
          ) : (
            <div className="space-y-4">
              {jobs.map((job) => {
                const salary = formatSalary(job.salary_min, job.salary_max, job.currency ?? "USD");
                return (
                  <Card
                    key={job.id}
                    className="hover:border-indigo-500/50 transition-colors cursor-pointer group"
                  >
                    <CardContent className="p-5">
                      <div className="flex flex-col sm:flex-row sm:items-center gap-3 justify-between">
                        <div className="min-w-0">
                          <div className="flex flex-wrap items-center gap-2 mb-1">
                            <h3 className="font-semibold text-base group-hover:text-indigo-500 transition-colors">
                              {job.title}
                            </h3>
                            {job.requires_credential && (
                              <Badge
                                variant="outline"
                                className="text-xs gap-1 border-amber-500/40 text-amber-600"
                              >
                                <ShieldCheck className="h-2.5 w-2.5" />
                                Credential required
                              </Badge>
                            )}
                          </div>
                          <div className="flex flex-wrap items-center gap-3 text-sm text-muted-foreground">
                            <span className="flex items-center gap-1">
                              <Clock className="h-3.5 w-3.5" />
                              {JOB_TYPE_LABELS[job.type] ?? job.type}
                            </span>
                            <span className="flex items-center gap-1">
                              <MapPin className="h-3.5 w-3.5" />
                              {LOCATION_TYPE_LABELS[job.location_type] ?? job.location_type}
                              {job.location ? ` · ${job.location}` : ""}
                            </span>
                            {salary && <span>{salary}</span>}
                            {job.min_exercises_required > 0 && (
                              <span>{job.min_exercises_required}+ exercises</span>
                            )}
                          </div>
                          {job.tags && job.tags.length > 0 && (
                            <div className="flex flex-wrap gap-1 mt-1.5">
                              {job.tags.slice(0, 5).map((tag: string) => (
                                <span key={tag} className="px-1.5 py-0.5 rounded text-[10px] font-medium bg-muted text-muted-foreground">
                                  {tag}
                                </span>
                              ))}
                              {job.tags.length > 5 && (
                                <span className="text-[10px] text-muted-foreground">+{job.tags.length - 5}</span>
                              )}
                            </div>
                          )}
                        </div>
                        <Button size="sm" className="shrink-0 gap-1" asChild>
                          <Link href={`/jobs/${job.id}`}>
                            View Role
                            <ArrowRight className="h-3.5 w-3.5" />
                          </Link>
                        </Button>
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
