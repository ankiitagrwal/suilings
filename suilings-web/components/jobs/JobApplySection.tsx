"use client";

import { useState } from "react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { ApplyDialog } from "@/components/jobs/ApplyDialog";
import { CheckCircle2, LogIn } from "lucide-react";

interface UserProfile {
  username: string;
  displayName: string;
  avatarUrl: string | null;
  completedExercises: number;
  hasCredential: boolean;
  profileUrl: string;
}

interface JobApplySectionProps {
  jobId: string;
  jobTitle: string;
  companyName: string;
  isLoggedIn: boolean;
  userProfile: UserProfile | null;
}

export function JobApplySection({
  jobId,
  jobTitle,
  companyName,
  isLoggedIn,
  userProfile,
}: JobApplySectionProps) {
  const [applied, setApplied] = useState(false);

  if (applied) {
    return (
      <div className="flex items-center gap-2 text-sm text-green-600 justify-center py-1">
        <CheckCircle2 className="h-4 w-4" />
        <span className="font-medium">Application submitted</span>
      </div>
    );
  }

  if (!isLoggedIn) {
    return (
      <div className="space-y-2">
        <Button className="w-full gap-2" asChild>
          <Link href={`/login?redirect=/jobs/${jobId}`}>
            <LogIn className="h-4 w-4" />
            Sign in to Apply
          </Link>
        </Button>
        <p className="text-xs text-center text-muted-foreground">
          Sign in with GitHub to apply with your Suilings profile
        </p>
      </div>
    );
  }

  if (!userProfile) {
    return (
      <p className="text-xs text-center text-muted-foreground py-1">
        Unable to load your profile. Please refresh and try again.
      </p>
    );
  }

  return (
    <ApplyDialog
      jobId={jobId}
      jobTitle={jobTitle}
      companyName={companyName}
      applicant={userProfile}
      onApplied={() => setApplied(true)}
    />
  );
}
