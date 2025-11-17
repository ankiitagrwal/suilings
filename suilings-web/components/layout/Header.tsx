"use client";

import { memo } from "react";
import Link from "next/link";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { calculateProgress } from "@/lib/exerciseLoader";
import { ThemeToggle } from "@/components/theme-toggle";
import { Badge } from "@/components/ui/badge";
import { ChevronLeft, ChevronRight, Play, RotateCcw, Lightbulb, LayoutDashboard, Trophy } from "lucide-react";
import { LoginButton } from "@/components/auth/LoginButton";
import { UserMenu } from "@/components/auth/UserMenu";
import { useAuth } from "@/lib/hooks/useAuth";

interface HeaderProps {
  onRun: () => void;
  onReset: () => void;
  onShowHint: () => void;
}

export const Header = memo(function Header({ onRun, onReset, onShowHint }: HeaderProps) {
  const { exercises, currentExerciseIndex, isCompiling, nextExercise, previousExercise } =
    useExerciseStore();
  const { user, loading } = useAuth();
  const { completed, total, percentage } = calculateProgress(exercises);

  const canGoPrevious = currentExerciseIndex > 0;
  const canGoNext = currentExerciseIndex < exercises.length - 1;
  const hasExercises = exercises.length > 0;

  return (
    <header className="border-b border-border bg-background/95 backdrop-blur supports-backdrop-filter:bg-background/60 sticky top-0 z-50">
      <div className="container h-16 px-4 max-w-screen-2xl mx-auto">
        <div className="grid grid-cols-[1fr_auto_1fr] h-full items-center gap-4">
          {/* Left: Logo + Navigation */}
          <div className="flex items-center gap-3 min-w-0 justify-start">
            <Link href="/" className="flex items-center gap-2 hover:opacity-80 transition-opacity shrink-0">
              <Image 
                src="/suilings-logo.svg" 
                alt="Suilings Logo" 
                width={32} 
                height={32}
                className="shrink-0"
              />
              <div className="text-xl font-bold bg-linear-to-r from-indigo-500 to-purple-500 bg-clip-text text-transparent whitespace-nowrap">
                Suilings
              </div>
            </Link>
            
            <div className="h-6 w-px bg-border hidden md:block shrink-0" />
            
            <div className="hidden md:flex items-center gap-1 shrink-0">
              <Button variant="ghost" size="sm" className="gap-1.5 text-xs" asChild>
                <Link href="/dashboard">
                  <LayoutDashboard className="h-3.5 w-3.5" />
                  Dashboard
                </Link>
              </Button>
              <Button variant="ghost" size="sm" className="gap-1.5 text-xs" asChild>
                <Link href="/leaderboard">
                  <Trophy className="h-3.5 w-3.5" />
                  Leaderboard
                </Link>
              </Button>
            </div>
          </div>

          {/* Center: Exercise Controls */}
          <div className="flex items-center justify-center gap-2 shrink-0">
            <Button
              variant="outline"
              size="sm"
              onClick={previousExercise}
              disabled={!hasExercises || !canGoPrevious}
            >
              <ChevronLeft className="h-4 w-4 md:mr-1" />
              <span className="hidden md:inline">Prev</span>
            </Button>

            <Button
              variant="default"
              size="sm"
              onClick={onRun}
              disabled={!hasExercises || isCompiling}
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

            <Button variant="outline" size="sm" onClick={onShowHint} disabled={!hasExercises} className="hidden sm:flex">
              <Lightbulb className="h-4 w-4 md:mr-1" />
              <span className="hidden md:inline">Hint</span>
            </Button>

            <Button variant="outline" size="sm" onClick={onReset} disabled={!hasExercises} className="hidden sm:flex">
              <RotateCcw className="h-4 w-4 md:mr-1" />
              <span className="hidden md:inline">Reset</span>
            </Button>

            <Button
              variant="outline"
              size="sm"
              onClick={nextExercise}
              disabled={!hasExercises || !canGoNext}
            >
              <span className="hidden md:inline">Next</span>
              <ChevronRight className="h-4 w-4 md:ml-1" />
            </Button>
          </div>

          {/* Right: Progress + Auth */}
          <div className="flex items-center justify-end gap-3 min-w-0">
            <div className="hidden lg:flex items-center gap-2 shrink-0">
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
      </div>
    </header>
  );
});

