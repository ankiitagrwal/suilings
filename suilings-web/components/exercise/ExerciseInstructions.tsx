"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { BookOpen, Info } from "lucide-react";

export function ExerciseInstructions() {
  const { exercises, currentExerciseIndex } = useExerciseStore();
  const currentExercise = exercises[currentExerciseIndex];

  if (!currentExercise) {
    return (
      <div className="h-full flex items-center justify-center p-8 text-center">
        <div className="space-y-2">
          <BookOpen className="h-12 w-12 mx-auto text-muted-foreground" />
          <h3 className="text-lg font-semibold">No Exercise Selected</h3>
          <p className="text-sm text-muted-foreground">
            Select an exercise from the sidebar to get started.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full flex flex-col overflow-hidden bg-background">
      <ScrollArea className="flex-1 overflow-y-auto">
        <div className="p-6 space-y-4 pb-8">
          {/* Exercise Title */}
          <div className="space-y-2">
            <h2 className="text-2xl font-bold flex items-center gap-2">
              <Info className="h-6 w-6 text-primary shrink-0" />
              <span>{currentExercise.name}</span>
            </h2>
          </div>

          {/* Exercise Description */}
          {currentExercise.description && (
            <Card className="border-blue-500/30 bg-blue-500/5">
              <CardHeader>
                <CardTitle className="text-lg font-semibold flex items-center gap-2 text-blue-600 dark:text-blue-400">
                  <BookOpen className="h-5 w-5" />
                  Instructions
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="prose prose-sm dark:prose-invert max-w-none">
                  <p className="text-base leading-relaxed whitespace-pre-wrap font-medium text-foreground">
                    {currentExercise.description}
                  </p>
                </div>
              </CardContent>
            </Card>
          )}

          <Card className="border-amber-500/20 bg-amber-500/5">
            <CardHeader className="pb-3">
              <CardTitle className="text-sm font-medium text-amber-600 dark:text-amber-400">
                💡 Need Help?
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Click the <span className="font-semibold">Hint</span> button in the header to get a
                helpful hint for this exercise.
              </p>
            </CardContent>
          </Card>
        </div>
      </ScrollArea>
    </div>
  );
}

