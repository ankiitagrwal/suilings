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
    <div className="h-full flex flex-col overflow-hidden">
      <div className="border-b border-border p-4 flex-shrink-0">
        <div className="flex items-center justify-between mb-2">
          <h2 className="text-lg font-semibold flex items-center gap-2">
            <BookOpen className="h-5 w-5" />
            {currentExercise.name}
          </h2>
          <Badge
            variant={currentExercise.mode === "test" ? "default" : "secondary"}
          >
            {currentExercise.mode}
          </Badge>
        </div>
        <p className="text-sm text-muted-foreground">
          Exercise {currentExerciseIndex + 1} of {exercises.length}
        </p>
      </div>

      <ScrollArea className="flex-1 overflow-y-auto">
        <div className="p-4 space-y-4 pb-8">
          {currentExercise.description && (
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-sm font-medium flex items-center gap-2">
                  <Info className="h-4 w-4" />
                  About This Exercise
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-muted-foreground whitespace-pre-wrap">
                  {currentExercise.description}
                </p>
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

