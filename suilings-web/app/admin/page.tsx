"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { Footer } from "@/components/layout/Footer";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Building2,
  ShieldCheck,
  ShieldX,
  Globe,
  Briefcase,
  Users,
  Loader2,
  CheckCircle2,
  XCircle,
  ExternalLink,
  Clock,
} from "lucide-react";
import { toast } from "sonner";
import { useAuth } from "@/lib/hooks/useAuth";

interface AdminCompany {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  website: string | null;
  logo_url: string | null;
  contact_email: string | null;
  verified: boolean;
  admin_user_id: string;
  created_at: string;
  updated_at: string;
  admin_profile: {
    username: string;
    full_name: string | null;
    avatar_url: string | null;
    github_username: string | null;
  } | null;
  job_count: number;
  application_count: number;
}

export default function AdminPage() {
  const { user, loading: authLoading } = useAuth();
  const [companies, setCompanies] = useState<AdminCompany[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const [filter, setFilter] = useState<"all" | "pending" | "verified">("all");

  useEffect(() => {
    if (authLoading) return;
    if (!user) {
      setIsLoading(false);
      return;
    }
    fetchCompanies();
  }, [user, authLoading]);

  async function fetchCompanies() {
    try {
      const res = await fetch("/api/admin/companies");
      if (res.status === 403) {
        setError("forbidden");
        return;
      }
      const data = await res.json();
      if (!res.ok) throw new Error(data.error);
      setCompanies(data.companies ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load");
    } finally {
      setIsLoading(false);
    }
  }

  async function updateVerification(companyId: string, verified: boolean) {
    setUpdatingId(companyId);
    try {
      const res = await fetch("/api/admin/companies", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ company_id: companyId, verified }),
      });
      const data = await res.json();
      if (!res.ok) {
        toast.error(data.error ?? "Failed to update");
        return;
      }
      setCompanies((prev) =>
        prev.map((c) => (c.id === companyId ? { ...c, verified } : c))
      );
      toast.success(verified ? "Company verified!" : "Verification revoked");
    } catch {
      toast.error("Something went wrong");
    } finally {
      setUpdatingId(null);
    }
  }

  const filtered = companies.filter((c) => {
    if (filter === "pending") return !c.verified;
    if (filter === "verified") return c.verified;
    return true;
  });

  const pendingCount = companies.filter((c) => !c.verified).length;
  const verifiedCount = companies.filter((c) => c.verified).length;

  // Forbidden or not logged in
  if (!authLoading && (!user || error === "forbidden")) {
    return (
      <>
        <SimpleHeader />
        <div className="min-h-screen bg-background flex items-center justify-center">
          <div className="text-center">
            <ShieldX className="h-12 w-12 mx-auto mb-4 text-red-500 opacity-50" />
            <p className="text-lg font-medium">Access Denied</p>
            <p className="text-sm text-muted-foreground mt-1">This page is restricted to platform administrators.</p>
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
          <div className="container mx-auto px-4 py-8 max-w-5xl">
            <div className="flex items-center gap-3 mb-2">
              <ShieldCheck className="h-6 w-6 text-indigo-500" />
              <h1 className="text-3xl font-bold">Admin Panel</h1>
            </div>
            <p className="text-muted-foreground">
              Manage company registrations and verification
            </p>
          </div>
        </div>

        <div className="container mx-auto px-4 py-8 max-w-5xl">
          {/* Stats */}
          <div className="grid grid-cols-3 gap-4 mb-8">
            <Card>
              <CardContent className="p-4 flex items-center gap-3">
                <Building2 className="h-5 w-5 text-muted-foreground" />
                <div>
                  <p className="text-2xl font-bold">{companies.length}</p>
                  <p className="text-xs text-muted-foreground">Total Companies</p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4 flex items-center gap-3">
                <Clock className="h-5 w-5 text-amber-500" />
                <div>
                  <p className="text-2xl font-bold">{pendingCount}</p>
                  <p className="text-xs text-muted-foreground">Pending Verification</p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4 flex items-center gap-3">
                <CheckCircle2 className="h-5 w-5 text-green-500" />
                <div>
                  <p className="text-2xl font-bold">{verifiedCount}</p>
                  <p className="text-xs text-muted-foreground">Verified</p>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Filters */}
          <div className="flex gap-2 mb-6">
            {(
              [
                { key: "all", label: `All (${companies.length})` },
                { key: "pending", label: `Pending (${pendingCount})` },
                { key: "verified", label: `Verified (${verifiedCount})` },
              ] as const
            ).map((opt) => (
              <button
                key={opt.key}
                onClick={() => setFilter(opt.key)}
                className={`px-3 py-1 rounded-full text-xs font-medium border transition-colors ${
                  filter === opt.key
                    ? "bg-indigo-500 text-white border-indigo-500"
                    : "border-border hover:border-indigo-500/50 text-muted-foreground hover:text-foreground"
                }`}
              >
                {opt.label}
              </button>
            ))}
          </div>

          {/* Company List */}
          {isLoading ? (
            <div className="flex justify-center py-20">
              <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
            </div>
          ) : filtered.length === 0 ? (
            <div className="text-center py-20 text-muted-foreground">
              <Building2 className="h-12 w-12 mx-auto mb-4 opacity-30" />
              <p className="text-lg font-medium">No companies found</p>
            </div>
          ) : (
            <div className="space-y-4">
              {filtered.map((company) => (
                <Card key={company.id} className="hover:border-border/80 transition-colors">
                  <CardContent className="p-5">
                    <div className="flex gap-4 items-start">
                      {/* Logo */}
                      <div className="h-14 w-14 rounded-xl border border-border bg-background flex items-center justify-center shrink-0 overflow-hidden">
                        {company.logo_url ? (
                          <Image
                            src={company.logo_url}
                            alt={company.name}
                            width={56}
                            height={56}
                            className="object-contain"
                          />
                        ) : (
                          <Building2 className="h-6 w-6 text-muted-foreground" />
                        )}
                      </div>

                      <div className="flex-1 min-w-0">
                        {/* Header */}
                        <div className="flex flex-wrap items-start justify-between gap-3">
                          <div>
                            <div className="flex items-center gap-2 mb-1">
                              <h3 className="font-semibold text-lg">{company.name}</h3>
                              {company.verified ? (
                                <Badge className="gap-1 bg-green-500/10 text-green-600 border-green-500/20 text-xs">
                                  <CheckCircle2 className="h-3 w-3" />
                                  Verified
                                </Badge>
                              ) : (
                                <Badge variant="outline" className="gap-1 text-xs text-amber-600 border-amber-500/30">
                                  <Clock className="h-3 w-3" />
                                  Pending
                                </Badge>
                              )}
                            </div>
                            <p className="text-sm text-muted-foreground">{company.slug}</p>
                          </div>

                          {/* Actions */}
                          <div className="flex gap-2 shrink-0">
                            <Button variant="ghost" size="sm" className="h-8 text-xs gap-1" asChild>
                              <Link href={`/company/${company.slug}`} target="_blank">
                                <ExternalLink className="h-3 w-3" />
                                View
                              </Link>
                            </Button>
                            {company.verified ? (
                              <Button
                                variant="outline"
                                size="sm"
                                className="h-8 text-xs gap-1 text-red-600 hover:text-red-700 hover:bg-red-500/5"
                                disabled={updatingId === company.id}
                                onClick={() => updateVerification(company.id, false)}
                              >
                                {updatingId === company.id ? (
                                  <Loader2 className="h-3 w-3 animate-spin" />
                                ) : (
                                  <XCircle className="h-3 w-3" />
                                )}
                                Revoke
                              </Button>
                            ) : (
                              <Button
                                size="sm"
                                className="h-8 text-xs gap-1 bg-green-600 hover:bg-green-700"
                                disabled={updatingId === company.id}
                                onClick={() => updateVerification(company.id, true)}
                              >
                                {updatingId === company.id ? (
                                  <Loader2 className="h-3 w-3 animate-spin" />
                                ) : (
                                  <CheckCircle2 className="h-3 w-3" />
                                )}
                                Verify
                              </Button>
                            )}
                          </div>
                        </div>

                        {/* Details */}
                        {company.description && (
                          <p className="text-sm text-muted-foreground mt-2 line-clamp-2">
                            {company.description}
                          </p>
                        )}

                        <div className="flex flex-wrap gap-4 mt-3 text-xs text-muted-foreground">
                          {company.website && (
                            <a
                              href={company.website}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="flex items-center gap-1 hover:text-foreground"
                            >
                              <Globe className="h-3 w-3" />
                              {company.website.replace(/^https?:\/\//, "")}
                            </a>
                          )}
                          {company.contact_email && (
                            <span className="flex items-center gap-1">
                              {company.contact_email}
                            </span>
                          )}
                          <span className="flex items-center gap-1">
                            <Briefcase className="h-3 w-3" />
                            {company.job_count} jobs
                          </span>
                          <span className="flex items-center gap-1">
                            <Users className="h-3 w-3" />
                            {company.application_count} applications
                          </span>
                          <span>
                            Registered {new Date(company.created_at).toLocaleDateString("en-US", {
                              month: "short",
                              day: "numeric",
                              year: "numeric",
                            })}
                          </span>
                        </div>

                        {/* Admin Info */}
                        {company.admin_profile && (
                          <div className="flex items-center gap-2 mt-3 pt-3 border-t border-border">
                            <Avatar className="h-6 w-6">
                              <AvatarImage src={company.admin_profile.avatar_url ?? undefined} />
                              <AvatarFallback className="text-xs">
                                {(company.admin_profile.full_name || company.admin_profile.username)?.[0]?.toUpperCase()}
                              </AvatarFallback>
                            </Avatar>
                            <span className="text-xs text-muted-foreground">
                              Registered by{" "}
                              <Link
                                href={`/u/${company.admin_profile.username}`}
                                className="text-foreground hover:underline"
                              >
                                @{company.admin_profile.username}
                              </Link>
                              {company.admin_profile.github_username && (
                                <span className="ml-1">
                                  (
                                  <a
                                    href={`https://github.com/${company.admin_profile.github_username}`}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="hover:underline"
                                  >
                                    GitHub
                                  </a>
                                  )
                                </span>
                              )}
                            </span>
                          </div>
                        )}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </div>
      </div>
      <Footer />
    </>
  );
}
