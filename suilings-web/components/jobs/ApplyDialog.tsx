"use client";

import { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { toast } from "sonner";
import Link from "next/link";
import { Loader2, CheckCircle2, ShieldCheck, BookOpen, User, AlertTriangle } from "lucide-react";

interface ApplicantProfile {
  username: string;
  displayName: string;
  avatarUrl: string | null;
  completedExercises: number;
  hasCredential: boolean;
  profileUrl: string;
}

interface ApplyDialogProps {
  jobId: string;
  jobTitle: string;
  companyName: string;
  applicant: ApplicantProfile;
  onApplied: () => void;
}

export function ApplyDialog({
  jobId,
  jobTitle,
  companyName,
  applicant,
  onApplied,
}: ApplyDialogProps) {
  const [open, setOpen] = useState(false);
  const [coverNote, setCoverNote] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleApply() {
    setIsSubmitting(true);
    try {
      const res = await fetch(`/api/jobs/${jobId}/apply`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ cover_note: coverNote }),
      });

      const data = await res.json();

      if (!res.ok) {
        toast.error(data.error ?? "Failed to submit application");
        return;
      }

      toast.success("Application submitted! The company will review your profile.");
      setOpen(false);
      onApplied();
    } catch {
      toast.error("Something went wrong. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  }

  const initials = applicant.displayName
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button size="lg" className="w-full sm:w-auto gap-2">
          Apply with Suilings
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Apply to {companyName}</DialogTitle>
          <DialogDescription>
            Applying for <strong>{jobTitle}</strong>. Your Suilings profile will be shared with the
            company.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          {/* Applicant summary */}
          <div className="rounded-xl border border-border p-4 bg-card space-y-3">
            <div className="flex items-center gap-3">
              <Avatar className="h-10 w-10">
                <AvatarImage src={applicant.avatarUrl ?? undefined} />
                <AvatarFallback>{initials}</AvatarFallback>
              </Avatar>
              <div>
                <p className="font-medium text-sm">{applicant.displayName}</p>
                <p className="text-xs text-muted-foreground">@{applicant.username}</p>
              </div>
            </div>

            <div className="flex flex-wrap gap-2">
              <Badge variant="secondary" className="gap-1 text-xs">
                <BookOpen className="h-3 w-3" />
                {applicant.completedExercises} exercises completed
              </Badge>
              {applicant.hasCredential ? (
                <Badge className="gap-1 text-xs bg-indigo-500/10 text-indigo-600 border-indigo-500/20">
                  <ShieldCheck className="h-3 w-3" />
                  Suilings Credential
                </Badge>
              ) : (
                <Badge variant="outline" className="gap-1 text-xs text-muted-foreground">
                  <ShieldCheck className="h-3 w-3" />
                  No credential yet
                </Badge>
              )}
            </div>

            <p className="text-xs text-muted-foreground flex items-center gap-1">
              <User className="h-3 w-3" />
              Profile link will be shared:{" "}
              <span className="font-mono">{applicant.profileUrl}</span>
            </p>
          </div>

          {/* Profile completeness prompt */}
          {applicant.completedExercises === 0 && (
            <div className="rounded-lg border border-amber-500/30 bg-amber-500/5 p-3 flex items-start gap-2">
              <AlertTriangle className="h-4 w-4 text-amber-500 shrink-0 mt-0.5" />
              <div className="text-xs text-muted-foreground">
                <p className="font-medium text-foreground mb-0.5">Complete your profile to stand out</p>
                <p>
                  Employers look at your exercise progress, bio, and skills.{" "}
                  <Link href={`/u/${applicant.username}/edit`} className="text-indigo-500 hover:underline" target="_blank">
                    Edit your profile
                  </Link>{" "}
                  to make a stronger impression.
                </p>
              </div>
            </div>
          )}

          {/* Cover note */}
          <div className="space-y-2">
            <Label htmlFor="cover-note">
              Cover Note{" "}
              <span className="text-muted-foreground font-normal">(optional)</span>
            </Label>
            <Textarea
              id="cover-note"
              placeholder="Briefly introduce yourself and why you're interested in this role…"
              value={coverNote}
              onChange={(e) => setCoverNote(e.target.value)}
              rows={4}
              maxLength={1000}
            />
            <p className="text-xs text-muted-foreground text-right">
              {coverNote.length}/1000
            </p>
          </div>

          <div className="flex gap-3 justify-end">
            <Button variant="outline" onClick={() => setOpen(false)} disabled={isSubmitting}>
              Cancel
            </Button>
            <Button onClick={handleApply} disabled={isSubmitting} className="gap-2">
              {isSubmitting ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" />
                  Submitting…
                </>
              ) : (
                <>
                  <CheckCircle2 className="h-4 w-4" />
                  Submit Application
                </>
              )}
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
