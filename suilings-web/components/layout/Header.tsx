"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { calculateProgress } from "@/lib/exerciseLoader";
import { ThemeToggle } from "@/components/theme-toggle";
import { ChevronLeft, ChevronRight, Play, RotateCcw, Lightbulb, LayoutDashboard, Trophy } from "lucide-react";
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
      <div className="container flex h-16 items-center gap-4 px-4 max-w-screen-2xl">
        {/* Left: Logo + Navigation */}
        <div className="flex items-center gap-3 min-w-fit">
          <Link href="/" className="flex items-center hover:opacity-80 transition-opacity">
            <div className="text-xl font-bold bg-gradient-to-r from-indigo-500 to-purple-500 bg-clip-text text-transparent whitespace-nowrap">
              Suilings
            </div>
          </Link>
          
          <div className="h-6 w-px bg-border hidden md:block" />
          
          <div className="hidden md:flex items-center gap-1">
            <Link href="/dashboard">
              <Button variant="ghost" size="sm" className="gap-1.5 text-xs">
                <LayoutDashboard className="h-3.5 w-3.5" />
                Dashboard
              </Button>
            </Link>
            <Link href="/leaderboard">
              <Button variant="ghost" size="sm" className="gap-1.5 text-xs">
                <Trophy className="h-3.5 w-3.5" />
                Leaderboard
              </Button>
            </Link>
          </div>
        </div>

        {/* Center: Exercise Controls */}
        <div className="flex items-center justify-center gap-2 flex-1">
          <Button
            variant="outline"
            size="sm"
            onClick={previousExercise}
            disabled={!canGoPrevious}
          >
            <ChevronLeft className="h-4 w-4 md:mr-1" />
            <span className="hidden md:inline">Prev</span>
          </Button>

          <Button
            variant="default"
            size="sm"
            onClick={onRun}
            disabled={isCompiling}
            className="min-w-20"
          >
            {isCompiling ? (
              <>
                <span className="animate-spin mr-2">⚡</span>
                <span className="hidden sm:inline">Running...</span>
                <span className="sm:hidden">...</span>
              </>
            ) : (
              <>
                <Play className="h-4 w-4 md:mr-1" />
                <span className="hidden md:inline">Run</span>
              </>
            )}
          </Button>

          <Button variant="outline" size="sm" onClick={onShowHint} className="hidden sm:flex">
            <Lightbulb className="h-4 w-4 md:mr-1" />
            <span className="hidden md:inline">Hint</span>
          </Button>

          <Button variant="outline" size="sm" onClick={onReset} className="hidden sm:flex">
            <RotateCcw className="h-4 w-4 md:mr-1" />
            <span className="hidden md:inline">Reset</span>
          </Button>

          <Button
            variant="outline"
            size="sm"
            onClick={nextExercise}
            disabled={!canGoNext}
          >
            <span className="hidden md:inline">Next</span>
            <ChevronRight className="h-4 w-4 md:ml-1" />
          </Button>
        </div>

        {/* Right: Progress + Auth */}
        <div className="flex items-center gap-3 min-w-fit">
          <div className="hidden lg:flex items-center gap-2 min-w-32">
            <span className="text-xs text-muted-foreground whitespace-nowrap">
              {completed}/{total}
            </span>
            <Progress value={percentage} className="h-2 w-24" />
          </div>
          
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

