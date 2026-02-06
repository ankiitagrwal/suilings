"use client";

import { Button } from "@/components/ui/button";
import { Award } from "lucide-react";
import { REQUIRED_EXERCISES_FOR_CREDENTIAL } from "@/lib/config/credential-config";

interface CredentialTestButtonProps {
  completedCount: number;
  onTriggerModal: () => void;
}

/**
 * Development-only test button to manually trigger credential modal
 * This bypasses eligibility checks for testing purposes
 * 
 * IMPORTANT: This component should ONLY render in development mode
 * The parent component should check: process.env.NODE_ENV === 'development'
 */
export function CredentialTestButton({ completedCount, onTriggerModal }: CredentialTestButtonProps) {
  // Show progress indicator if requirements not met
  if (completedCount < REQUIRED_EXERCISES_FOR_CREDENTIAL) {
    return (
      <div className="fixed bottom-20 right-6 z-50">
        <div className="bg-muted p-3 rounded-lg shadow-lg text-sm border-2 border-amber-500">
          <div className="flex items-center gap-2 mb-2">
            <Award className="h-4 w-4 text-amber-500" />
            <span className="font-semibold text-amber-500">DEV MODE</span>
          </div>
          <p className="text-muted-foreground">
            Complete {REQUIRED_EXERCISES_FOR_CREDENTIAL - completedCount} more exercises to test credential
          </p>
          <p className="text-xs text-muted-foreground mt-1">
            Current: {completedCount}/{REQUIRED_EXERCISES_FOR_CREDENTIAL}
          </p>
        </div>
      </div>
    );
  }

  // Show test button when requirements are met
  return (
    <Button
      onClick={onTriggerModal}
      className="fixed bottom-20 right-6 shadow-lg hover:shadow-xl transition-all z-50 gap-2"
      size="lg"
    >
      <Award className="w-5 h-5" />
      Test Credential Modal
    </Button>
  );
}
