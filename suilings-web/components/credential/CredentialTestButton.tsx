"use client";

import { Button } from "@/components/ui/button";
import { Award } from "lucide-react";

interface CredentialTestButtonProps {
  completedCount: number;
  onTriggerModal: () => void;
}

/**
 * Temporary test button to manually trigger credential modal
 * Remove this after testing is complete
 */
export function CredentialTestButton({ completedCount, onTriggerModal }: CredentialTestButtonProps) {
  if (completedCount < 50) {
    return (
      <div className="fixed bottom-20 right-6 z-50">
        <div className="bg-muted p-3 rounded-lg shadow-lg text-sm">
          <p className="text-muted-foreground">
            Complete {50 - completedCount} more exercises to test credential
          </p>
          <p className="text-xs text-muted-foreground mt-1">
            Current: {completedCount}/50
          </p>
        </div>
      </div>
    );
  }

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
