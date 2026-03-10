"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Loader2, Save, Briefcase } from "lucide-react";
import { toast } from "sonner";

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

interface ProfileEditFormProps {
  initialData: {
    displayName?: string | null;
    bio?: string | null;
    githubUsername?: string | null;
    twitterUsername?: string | null;
    websiteUrl?: string | null;
    location?: string | null;
    openToWork?: boolean | null;
    skillsSummary?: string | null;
    availableRoles?: string[] | null;
  };
  username: string;
}

export function ProfileEditForm({ initialData, username }: ProfileEditFormProps) {
  const router = useRouter();
  const [isSaving, setIsSaving] = useState(false);
  const [formData, setFormData] = useState({
    ...initialData,
    openToWork: initialData.openToWork ?? false,
    availableRoles: initialData.availableRoles ?? [],
  });

  const toggleRole = (role: string) => {
    const current = formData.availableRoles ?? [];
    setFormData({
      ...formData,
      availableRoles: current.includes(role)
        ? current.filter((r) => r !== role)
        : [...current, role],
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);

    try {
      const response = await fetch("/api/profile/update", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        throw new Error("Failed to update profile");
      }

      toast.success("Profile updated successfully!");
      router.push(`/u/${username}`);
      router.refresh();
    } catch (error) {
      console.error("Update error:", error);
      toast.error("Failed to update profile");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Basic Info */}
      <Card>
        <CardHeader>
          <CardTitle>Basic Information</CardTitle>
          <CardDescription>Your public profile information</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <Label htmlFor="displayName">Display Name</Label>
            <Input
              id="displayName"
              value={formData.displayName || ""}
              onChange={(e) => setFormData({ ...formData, displayName: e.target.value })}
              placeholder="Your name"
              maxLength={50}
            />
          </div>

          <div>
            <Label htmlFor="bio">Bio</Label>
            <Textarea
              id="bio"
              value={formData.bio || ""}
              onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
              placeholder="Tell us about yourself"
              maxLength={500}
              rows={4}
            />
            <p className="text-xs text-muted-foreground mt-1">
              {formData.bio?.length || 0}/500 characters
            </p>
          </div>

          <div>
            <Label htmlFor="location">Location</Label>
            <Input
              id="location"
              value={formData.location || ""}
              onChange={(e) => setFormData({ ...formData, location: e.target.value })}
              placeholder="City, Country"
              maxLength={100}
            />
          </div>
        </CardContent>
      </Card>

      {/* Open to Work */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Briefcase className="h-5 w-5" />
            Work Availability
          </CardTitle>
          <CardDescription>
            Signal to companies that you&apos;re open to new opportunities
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-5">
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-sm">Open to Work</p>
              <p className="text-xs text-muted-foreground mt-0.5">
                Show a badge on your profile and appear in the developer directory
              </p>
            </div>
            <Switch
              id="openToWork"
              checked={formData.openToWork}
              onCheckedChange={(checked) =>
                setFormData({ ...formData, openToWork: checked })
              }
            />
          </div>

          {formData.openToWork && (
            <>
              <div>
                <Label htmlFor="skillsSummary">What are you looking for?</Label>
                <Textarea
                  id="skillsSummary"
                  value={formData.skillsSummary || ""}
                  onChange={(e) =>
                    setFormData({ ...formData, skillsSummary: e.target.value })
                  }
                  placeholder="Describe the kind of work you're interested in, your expertise, what excites you..."
                  maxLength={300}
                  rows={3}
                  className="mt-1.5"
                />
                <p className="text-xs text-muted-foreground mt-1">
                  {formData.skillsSummary?.length || 0}/300 characters
                </p>
              </div>

              <div>
                <Label className="mb-2 block">Roles I&apos;m interested in</Label>
                <div className="flex flex-wrap gap-2">
                  {ROLE_OPTIONS.map((role) => {
                    const selected = formData.availableRoles?.includes(role);
                    return (
                      <button
                        key={role}
                        type="button"
                        onClick={() => toggleRole(role)}
                        className="focus:outline-none"
                      >
                        <Badge
                          variant={selected ? "default" : "outline"}
                          className="cursor-pointer select-none transition-colors"
                        >
                          {role}
                        </Badge>
                      </button>
                    );
                  })}
                </div>
              </div>
            </>
          )}
        </CardContent>
      </Card>

      {/* Social Links */}
      <Card>
        <CardHeader>
          <CardTitle>Social Links</CardTitle>
          <CardDescription>Connect your social profiles</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <Label htmlFor="github">GitHub Username</Label>
            <Input
              id="github"
              value={formData.githubUsername || ""}
              onChange={(e) => setFormData({ ...formData, githubUsername: e.target.value })}
              placeholder="username"
            />
          </div>

          <div>
            <Label htmlFor="twitter">Twitter Username</Label>
            <Input
              id="twitter"
              value={formData.twitterUsername || ""}
              onChange={(e) => setFormData({ ...formData, twitterUsername: e.target.value })}
              placeholder="username"
            />
          </div>

          <div>
            <Label htmlFor="website">Website URL</Label>
            <Input
              id="website"
              type="url"
              value={formData.websiteUrl || ""}
              onChange={(e) => setFormData({ ...formData, websiteUrl: e.target.value })}
              placeholder="https://yourwebsite.com"
            />
          </div>
        </CardContent>
      </Card>

      {/* Actions */}
      <div className="flex gap-3">
        <Button type="submit" disabled={isSaving} className="gap-2">
          {isSaving ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" />
              Saving...
            </>
          ) : (
            <>
              <Save className="h-4 w-4" />
              Save Changes
            </>
          )}
        </Button>
        <Button
          type="button"
          variant="outline"
          onClick={() => router.push(`/u/${username}`)}
          disabled={isSaving}
        >
          Cancel
        </Button>
      </div>
    </form>
  );
}
