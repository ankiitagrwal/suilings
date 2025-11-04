"use client";

import { ScrollArea } from "@/components/ui/scroll-area";
import { Separator } from "@/components/ui/separator";
import { Button } from "@/components/ui/button";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { groupExercisesByCategory } from "@/lib/exerciseLoader";
import { CheckCircle2, Circle, Zap, ChevronLeft } from "lucide-react";
import { cn } from "@/lib/utils";

interface SidebarProps {
  onToggle?: () => void;
}

export function Sidebar({ onToggle }: SidebarProps) {
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
    <aside className="w-64 border-r border-border bg-muted/10 flex flex-col overflow-hidden h-full">
      <div className="p-4 border-b border-border shrink-0 flex items-center justify-between gap-2">
        <div className="flex-1 min-w-0">
          <h2 className="text-sm font-semibold text-foreground">All Exercises</h2>
          <p className="text-xs text-muted-foreground mt-1">
            {exercises.length} exercises available
          </p>
        </div>
        {onToggle && (
          <Button
            variant="ghost"
            size="icon"
            className="h-8 w-8 shrink-0"
            onClick={onToggle}
            title="Hide sidebar"
          >
            <ChevronLeft className="h-4 w-4" />
          </Button>
        )}
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
                <div className="w-full px-3 py-2 flex items-center justify-between gap-2">
                  <h3 className="text-xs font-semibold text-foreground uppercase tracking-wide flex-1 truncate">
                    {capitalizeFirst(category)}
                  </h3>
                  <span className="text-xs text-muted-foreground shrink-0">
                    {completedCount}/{totalCount}
                  </span>
                </div>

                <div className="space-y-1 mt-1">
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

