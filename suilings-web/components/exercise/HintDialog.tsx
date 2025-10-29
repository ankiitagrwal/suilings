"use client";

import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { Lightbulb } from "lucide-react";

interface HintDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function HintDialog({ open, onOpenChange }: HintDialogProps) {
  const { exercises, currentExerciseIndex } = useExerciseStore();
  const currentExercise = exercises[currentExerciseIndex];

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Lightbulb className="h-5 w-5 text-amber-500" />
            Exercise Hint
          </DialogTitle>
          <DialogDescription>
            Here's a hint to help you solve {currentExercise?.name}
          </DialogDescription>
        </DialogHeader>
        <div className="bg-amber-500/5 border border-amber-500/20 rounded-md p-4">
          <p className="text-sm text-foreground whitespace-pre-wrap">
            {currentExercise?.hint || "No hint available for this exercise."}
          </p>
        </div>
      </DialogContent>
    </Dialog>
  );
}

