"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { calculateProgress } from "@/lib/exerciseLoader";
import { ThemeToggle } from "@/components/theme-toggle";
import { ChevronLeft, ChevronRight, Play, RotateCcw, Lightbulb } from "lucide-react";
import { LoginButton } from "@/components/auth/LoginButton";
import { UserMenu } from "@/components/auth/UserMenu";
import { useAuth } from "@/lib/hooks/useAuth";

interface HeaderProps {
  onRun: () => void;
  onReset: () => void;
  onShowHint: () => void;
}

export function Header({ onRun, onReset, onShowHint }: HeaderProps) {
  const { exercises, currentExerciseIndex, isCompiling, nextExercise, previousExercise } =
    useExerciseStore();
  const { user, loading } = useAuth();
  const currentExercise = exercises[currentExerciseIndex];
  const { completed, total, percentage } = calculateProgress(exercises);

  const canGoPrevious = currentExerciseIndex > 0;
  const canGoNext = currentExerciseIndex < exercises.length - 1;

  return (
    <header className="border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-16 items-center justify-between px-4">
        {/* Logo and Exercise Name */}
        <div className="flex items-center gap-4">
          <Link href="/" className="flex items-center gap-2 hover:opacity-80 transition-opacity">
            <div className="text-2xl font-bold bg-gradient-to-r from-indigo-500 to-purple-500 bg-clip-text text-transparent">
              Suilings
            </div>
          </Link>
          
          {currentExercise && (
            <>
              <div className="h-6 w-px bg-border" />
              <span className="text-sm font-medium text-muted-foreground">
                Exercise: <span className="text-foreground">{currentExercise.name}</span>
              </span>
            </>
          )}
        </div>

        {/* Center Actions */}
        <div className="flex items-center gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={previousExercise}
            disabled={!canGoPrevious}
          >
            <ChevronLeft className="h-4 w-4 mr-1" />
            Prev
          </Button>

          <Button
            variant="default"
            size="sm"
            onClick={onRun}
            disabled={isCompiling}
            className="min-w-24"
          >
            {isCompiling ? (
              <>
                <span className="animate-spin mr-2">⚡</span>
                Running...
              </>
            ) : (
              <>
                <Play className="h-4 w-4 mr-1" />
                Run
              </>
            )}
          </Button>

          <Button variant="outline" size="sm" onClick={onShowHint}>
            <Lightbulb className="h-4 w-4 mr-1" />
            Hint
          </Button>

          <Button variant="outline" size="sm" onClick={onReset}>
            <RotateCcw className="h-4 w-4 mr-1" />
            Reset
          </Button>

          <Button
            variant="outline"
            size="sm"
            onClick={nextExercise}
            disabled={!canGoNext}
          >
            Next
            <ChevronRight className="h-4 w-4 ml-1" />
          </Button>
        </div>

        {/* Right Side - Progress, Auth & Theme Toggle */}
        <div className="flex items-center gap-4 min-w-64">
          <div className="flex-1">
            <div className="flex items-center justify-between mb-1">
              <span className="text-xs text-muted-foreground">Progress</span>
              <span className="text-xs font-medium">
                {completed}/{total} ({percentage}%)
              </span>
            </div>
            <Progress value={percentage} className="h-2" />
          </div>
          
          {/* Auth UI */}
          {!loading && (
            <>
              {user ? (
                <UserMenu />
              ) : (
                <LoginButton />
              )}
            </>
          )}
          
          <ThemeToggle />
        </div>
      </div>
    </header>
  );
}

