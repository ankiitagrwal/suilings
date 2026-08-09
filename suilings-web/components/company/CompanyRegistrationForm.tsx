"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { toast } from "sonner";
import { Building2, Globe, Mail, Link as LinkIcon, Loader2 } from "lucide-react";

export function CompanyRegistrationForm() {
  const router = useRouter();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [form, setForm] = useState({
    name: "",
    slug: "",
    description: "",
    website: "",
    logo_url: "",
    contact_email: "",
  });

  function handleNameChange(value: string) {
    setForm((prev) => ({
      ...prev,
      name: value,
      slug: value
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9\s-]/g, "")
        .replace(/\s+/g, "-")
        .replace(/-+/g, "-"),
    }));
  }

  function handleChange(field: keyof typeof form, value: string) {
    setForm((prev) => ({ ...prev, [field]: value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!form.name.trim() || !form.slug.trim()) {
      toast.error("Company name and slug are required");
      return;
    }

    setIsSubmitting(true);
    try {
      const res = await fetch("/api/companies", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });

      const data = await res.json();

      if (!res.ok) {
        toast.error(data.error ?? "Failed to register company");
        return;
      }

      toast.success("Company registered! Redirecting to your dashboard…");
      router.push("/company/dashboard");
    } catch {
      toast.error("Something went wrong. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Building2 className="h-5 w-5" />
            Company Details
          </CardTitle>
          <CardDescription>
            Basic information about your company that developers will see.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="name">Company Name *</Label>
              <Input
                id="name"
                placeholder="Mysten Labs"
                value={form.name}
                onChange={(e) => handleNameChange(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="slug">
                URL Slug *
                <span className="text-muted-foreground text-xs ml-2">
                  suilings.xyz/company/<strong>{form.slug || "your-slug"}</strong>
                </span>
              </Label>
              <Input
                id="slug"
                placeholder="mysten-labs"
                value={form.slug}
                onChange={(e) => handleChange("slug", e.target.value.toLowerCase().replace(/[^a-z0-9-]/g, "-"))}
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">About Your Company</Label>
            <Textarea
              id="description"
              placeholder="Tell developers what your company does, your mission, and what it's like to work there…"
              value={form.description}
              onChange={(e) => handleChange("description", e.target.value)}
              rows={4}
            />
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <LinkIcon className="h-5 w-5" />
            Links & Contact
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="website" className="flex items-center gap-1.5">
                <Globe className="h-3.5 w-3.5" />
                Website
              </Label>
              <Input
                id="website"
                type="url"
                placeholder="https://mystenlabs.com"
                value={form.website}
                onChange={(e) => handleChange("website", e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="contact_email" className="flex items-center gap-1.5">
                <Mail className="h-3.5 w-3.5" />
                Contact Email
              </Label>
              <Input
                id="contact_email"
                type="email"
                placeholder="hiring@yourcompany.com"
                value={form.contact_email}
                onChange={(e) => handleChange("contact_email", e.target.value)}
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="logo_url">Logo URL</Label>
            <Input
              id="logo_url"
              type="url"
              placeholder="https://yourcompany.com/logo.png"
              value={form.logo_url}
              onChange={(e) => handleChange("logo_url", e.target.value)}
            />
            <p className="text-xs text-muted-foreground">
              Public URL to your company logo (square, at least 128×128px)
            </p>
          </div>
        </CardContent>
      </Card>

      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          Your company will be reviewed and manually verified before being featured in search results.
        </p>
        <Button type="submit" disabled={isSubmitting} className="min-w-32">
          {isSubmitting ? (
            <>
              <Loader2 className="h-4 w-4 mr-2 animate-spin" />
              Registering…
            </>
          ) : (
            "Register Company"
          )}
        </Button>
      </div>
    </form>
  );
}
