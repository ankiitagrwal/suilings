"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { toast } from "sonner";
import { Loader2, Briefcase } from "lucide-react";
import type { JobType, LocationType, CreateJobPayload, JobListing } from "@/types/jobs";

interface PostJobFormProps {
  onJobCreated: () => void;
  editingJob?: JobListing | null;
  onCancelEdit?: () => void;
}

const JOB_TYPES: { value: JobType; label: string }[] = [
  { value: "full-time", label: "Full-time" },
  { value: "part-time", label: "Part-time" },
  { value: "contract", label: "Contract" },
];

const LOCATION_TYPES: { value: LocationType; label: string }[] = [
  { value: "remote", label: "Remote" },
  { value: "onsite", label: "On-site" },
  { value: "hybrid", label: "Hybrid" },
];

export function PostJobForm({ onJobCreated, editingJob, onCancelEdit }: PostJobFormProps) {
  const isEditing = !!editingJob;
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [form, setForm] = useState<CreateJobPayload>({
    title: editingJob?.title ?? "",
    description: editingJob?.description ?? "",
    type: editingJob?.type ?? "full-time",
    location_type: editingJob?.location_type ?? "remote",
    location: editingJob?.location ?? "",
    salary_min: editingJob?.salary_min ?? undefined,
    salary_max: editingJob?.salary_max ?? undefined,
    currency: editingJob?.currency ?? "USD",
    min_exercises_required: editingJob?.min_exercises_required ?? 0,
    requires_credential: editingJob?.requires_credential ?? false,
    tags: editingJob?.tags ?? [],
    expires_at: editingJob?.expires_at ?? undefined,
  });
  const [tagInput, setTagInput] = useState("");

  function setField<K extends keyof CreateJobPayload>(key: K, value: CreateJobPayload[K]) {
    setForm((prev) => ({ ...prev, [key]: value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!form.title.trim() || !form.description.trim()) {
      toast.error("Title and description are required");
      return;
    }

    if (form.salary_min != null && form.salary_min < 0) {
      toast.error("Minimum salary cannot be negative");
      return;
    }
    if (form.salary_max != null && form.salary_max < 0) {
      toast.error("Maximum salary cannot be negative");
      return;
    }
    if (form.salary_min && form.salary_max && form.salary_min > form.salary_max) {
      toast.error("Maximum salary must be greater than minimum salary");
      return;
    }

    setIsSubmitting(true);
    try {
      const url = isEditing ? `/api/jobs/${editingJob.id}` : "/api/jobs";
      const method = isEditing ? "PATCH" : "POST";

      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...form,
          salary_min: form.salary_min || undefined,
          salary_max: form.salary_max || undefined,
          location: form.location?.trim() || undefined,
          tags: form.tags?.length ? form.tags : undefined,
          expires_at: form.expires_at || undefined,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        toast.error(data.error ?? `Failed to ${isEditing ? "update" : "create"} listing`);
        return;
      }

      toast.success(isEditing ? "Job listing updated!" : "Job listing published!");
      if (!isEditing) {
        setForm({
          title: "",
          description: "",
          type: "full-time",
          location_type: "remote",
          location: "",
          salary_min: undefined,
          salary_max: undefined,
          currency: "USD",
          min_exercises_required: 0,
          requires_credential: false,
          tags: [],
          expires_at: undefined,
        });
        setTagInput("");
      }
      onJobCreated();
    } catch {
      toast.error("Something went wrong. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-5">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-base">
            <Briefcase className="h-4 w-4" />
            {isEditing ? "Edit Job Listing" : "Job Details"}
          </CardTitle>
          <CardDescription>
            {isEditing ? "Update the listing details below." : "Describe the role clearly to attract the right candidates."}
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="title">Job Title *</Label>
            <Input
              id="title"
              placeholder="e.g. Senior Move Smart Contract Developer"
              value={form.title}
              onChange={(e) => setField("title", e.target.value)}
              required
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">Job Description *</Label>
            <Textarea
              id="description"
              placeholder="Describe the role, responsibilities, tech stack, and what you're looking for in a candidate…"
              value={form.description}
              onChange={(e) => setField("description", e.target.value)}
              rows={8}
              required
            />
          </div>

          <div className="space-y-2">
            <Label>
              Tags
              <span className="text-muted-foreground font-normal ml-2 text-xs">
                (press Enter or comma to add)
              </span>
            </Label>
            <div className="flex flex-wrap gap-1.5 mb-2">
              {(form.tags ?? []).map((tag) => (
                <span
                  key={tag}
                  className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-indigo-500/10 text-indigo-600 text-xs font-medium border border-indigo-500/20"
                >
                  {tag}
                  <button
                    type="button"
                    onClick={() => setField("tags", (form.tags ?? []).filter((t) => t !== tag))}
                    className="hover:text-red-500 transition-colors"
                  >
                    &times;
                  </button>
                </span>
              ))}
            </div>
            <Input
              placeholder="e.g. Move, DeFi, TypeScript, Sui SDK"
              value={tagInput}
              onChange={(e) => setTagInput(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter" || e.key === ",") {
                  e.preventDefault();
                  const tag = tagInput.trim().replace(/,/g, "");
                  if (tag && !(form.tags ?? []).includes(tag)) {
                    setField("tags", [...(form.tags ?? []), tag]);
                  }
                  setTagInput("");
                }
              }}
            />
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label>Job Type</Label>
              <div className="flex gap-1 flex-wrap">
                {JOB_TYPES.map((opt) => (
                  <button
                    key={opt.value}
                    type="button"
                    onClick={() => setField("type", opt.value)}
                    className={`px-3 py-1.5 rounded-lg text-sm font-medium border transition-colors ${
                      form.type === opt.value
                        ? "bg-indigo-500 text-white border-indigo-500"
                        : "border-border hover:border-indigo-500/50 text-muted-foreground hover:text-foreground"
                    }`}
                  >
                    {opt.label}
                  </button>
                ))}
              </div>
            </div>

            <div className="space-y-2">
              <Label>Location Type</Label>
              <div className="flex gap-1 flex-wrap">
                {LOCATION_TYPES.map((opt) => (
                  <button
                    key={opt.value}
                    type="button"
                    onClick={() => setField("location_type", opt.value)}
                    className={`px-3 py-1.5 rounded-lg text-sm font-medium border transition-colors ${
                      form.location_type === opt.value
                        ? "bg-indigo-500 text-white border-indigo-500"
                        : "border-border hover:border-indigo-500/50 text-muted-foreground hover:text-foreground"
                    }`}
                  >
                    {opt.label}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {form.location_type !== "remote" && (
            <div className="space-y-2">
              <Label htmlFor="location">Office Location</Label>
              <Input
                id="location"
                placeholder="e.g. San Francisco, CA"
                value={form.location}
                onChange={(e) => setField("location", e.target.value)}
              />
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Compensation & Requirements</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-3">
            <div className="space-y-2">
              <Label htmlFor="salary_min">Min Salary (annual)</Label>
              <Input
                id="salary_min"
                type="number"
                placeholder="80000"
                value={form.salary_min ?? ""}
                onChange={(e) => setField("salary_min", e.target.value ? Number(e.target.value) : undefined)}
                min={0}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="salary_max">Max Salary (annual)</Label>
              <Input
                id="salary_max"
                type="number"
                placeholder="150000"
                value={form.salary_max ?? ""}
                onChange={(e) => setField("salary_max", e.target.value ? Number(e.target.value) : undefined)}
                min={0}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="currency">Currency</Label>
              <Input
                id="currency"
                placeholder="USD"
                value={form.currency}
                onChange={(e) => setField("currency", e.target.value.toUpperCase())}
                maxLength={5}
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="min_exercises">
              Minimum Exercises Completed
              <span className="text-muted-foreground font-normal ml-2 text-xs">
                (0 = no minimum)
              </span>
            </Label>
            <Input
              id="min_exercises"
              type="number"
              placeholder="0"
              value={form.min_exercises_required ?? 0}
              onChange={(e) => setField("min_exercises_required", Math.max(0, Number(e.target.value)))}
              min={0}
              className="max-w-xs"
            />
          </div>

          <div className="flex items-center gap-3">
            <Switch
              id="requires_credential"
              checked={form.requires_credential ?? false}
              onCheckedChange={(checked) => setField("requires_credential", checked)}
            />
            <div>
              <Label htmlFor="requires_credential" className="cursor-pointer">
                Require Suilings Credential (SBT)
              </Label>
              <p className="text-xs text-muted-foreground">
                Only applicants with an on-chain credential can apply
              </p>
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="expires_at">
              Expiry Date
              <span className="text-muted-foreground font-normal ml-2 text-xs">
                (optional — listing auto-closes after this date)
              </span>
            </Label>
            <Input
              id="expires_at"
              type="date"
              value={form.expires_at ? form.expires_at.split("T")[0] : ""}
              onChange={(e) => setField("expires_at", e.target.value ? `${e.target.value}T23:59:59Z` : undefined)}
              className="max-w-xs"
            />
          </div>
        </CardContent>
      </Card>

      <div className="flex justify-end gap-2">
        {isEditing && onCancelEdit && (
          <Button type="button" variant="outline" onClick={onCancelEdit}>
            Cancel
          </Button>
        )}
        <Button type="submit" disabled={isSubmitting} className="min-w-36">
          {isSubmitting ? (
            <>
              <Loader2 className="h-4 w-4 mr-2 animate-spin" />
              {isEditing ? "Saving…" : "Publishing…"}
            </>
          ) : isEditing ? (
            "Save Changes"
          ) : (
            "Publish Listing"
          )}
        </Button>
      </div>
    </form>
  );
}
