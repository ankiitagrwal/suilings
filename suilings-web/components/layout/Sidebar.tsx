"use client";

import { ScrollArea } from "@/components/ui/scroll-area";
import { Separator } from "@/components/ui/separator";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { groupExercisesByCategory } from "@/lib/exerciseLoader";
import { CheckCircle2, Circle, Zap } from "lucide-react";
import { cn } from "@/lib/utils";

export function Sidebar() {
  const { exercises, currentExerciseIndex, setCurrentExercise } = useExerciseStore();
  const groupedExercises = groupExercisesByCategory(exercises);

  const handleExerciseClick = (exerciseIndex: number) => {
    setCurrentExercise(exerciseIndex);
  };

  const getExerciseIcon = (status?: string, isActive?: boolean) => {
    if (isActive) {
      return <Zap className="h-4 w-4 text-yellow-500 fill-yellow-500" />;
    }
    if (status === "completed") {
      return <CheckCircle2 className="h-4 w-4 text-green-500" />;
    }
    return <Circle className="h-4 w-4 text-muted-foreground" />;
  };

  const capitalizeFirst = (str: string) => {
    return str.charAt(0).toUpperCase() + str.slice(1);
  };

  return (
    <aside className="w-64 border-r border-border bg-muted/10 flex flex-col overflow-hidden">
      <div className="p-4 border-b border-border flex-shrink-0">
        <h2 className="text-sm font-semibold text-foreground">All Exercises</h2>
        <p className="text-xs text-muted-foreground mt-1">
          {exercises.length} exercises available
        </p>
      </div>

      <ScrollArea className="flex-1 overflow-y-auto">
        <div className="p-2 pb-8">
          {Object.entries(groupedExercises).map(([category, categoryExercises]) => {
            const completedCount = categoryExercises.filter(
              (ex) => ex.status === "completed"
            ).length;
            const totalCount = categoryExercises.length;

            return (
              <div key={category} className="mb-4">
                <div className="px-3 py-2 flex items-center justify-between">
                  <h3 className="text-xs font-semibold text-foreground uppercase tracking-wide">
                    {capitalizeFirst(category)}
                  </h3>
                  <span className="text-xs text-muted-foreground">
                    {completedCount}/{totalCount}
                  </span>
                </div>

                <div className="space-y-1">
                  {categoryExercises.map((exercise) => {
                    const exerciseIndex = exercises.findIndex(
                      (ex) => ex.name === exercise.name
                    );
                    const isActive = exerciseIndex === currentExerciseIndex;

                    return (
                      <button
                        key={exercise.name}
                        onClick={() => handleExerciseClick(exerciseIndex)}
                        className={cn(
                          "w-full flex items-center gap-2 px-3 py-2 rounded-md text-sm transition-colors",
                          "hover:bg-accent hover:text-accent-foreground",
                          isActive && "bg-accent text-accent-foreground font-medium"
                        )}
                      >
                        {getExerciseIcon(exercise.status, isActive)}
                        <span className="flex-1 text-left truncate">
                          {exercise.name}
                        </span>
                        <span
                          className={cn(
                            "text-xs px-1.5 py-0.5 rounded",
                            exercise.mode === "test"
                              ? "bg-blue-500/10 text-blue-500"
                              : "bg-green-500/10 text-green-500"
                          )}
                        >
                          {exercise.mode}
                        </span>
                      </button>
                    );
                  })}
                </div>

                <Separator className="mt-4" />
              </div>
            );
          })}
        </div>
      </ScrollArea>
    </aside>
  );
}

