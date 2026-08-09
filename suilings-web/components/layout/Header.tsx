"use client";

import { memo, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { calculateProgress } from "@/lib/exerciseLoader";
import { ThemeToggle } from "@/components/theme-toggle";
import { Badge } from "@/components/ui/badge";
import { ChevronLeft, ChevronRight, Play, RotateCcw, Lightbulb, LayoutDashboard, Trophy, MessageSquare, MoreVertical, Code2, Users, Briefcase } from "lucide-react";
import { LoginButton } from "@/components/auth/LoginButton";
import { UserMenu } from "@/components/auth/UserMenu";
import { useAuth } from "@/lib/hooks/useAuth";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

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
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const canGoPrevious = currentExerciseIndex > 0;
  const canGoNext = currentExerciseIndex < exercises.length - 1;
  const hasExercises = exercises.length > 0;

  return (
    <header className="border-b border-border bg-background/95 backdrop-blur supports-backdrop-filter:bg-background/60 sticky top-0 z-50">
      <div className="container h-16 px-2 sm:px-4 max-w-screen-2xl mx-auto">
        <div className="flex h-full items-center justify-between gap-2 md:gap-4">
          {/* Left: Logo + Navigation */}
          <div className="flex items-center gap-2 md:gap-3 min-w-0 justify-start shrink">
            <Link href="/" className="flex items-center gap-2 hover:opacity-80 transition-opacity shrink-0">
              <Image 
                src="/suilings-logo.svg" 
                alt="Suilings Logo" 
                width={28} 
                height={28}
                className="shrink-0 sm:w-8 sm:h-8"
              />
              <div className="text-lg sm:text-xl font-bold bg-linear-to-r from-indigo-500 to-purple-500 bg-clip-text text-transparent whitespace-nowrap hidden xs:block">
                Suilings
              </div>
            </Link>
            
            <div className="h-6 w-px bg-border hidden lg:block shrink-0" />
            
            <div className="hidden lg:flex items-center gap-1 shrink-0">
              <Button variant="ghost" size="sm" className="gap-1.5 text-xs" asChild>
                <Link href="/dashboard">
                  <LayoutDashboard className="h-3.5 w-3.5" />
                  Dashboard
                </Link>
              </Button>
              <Button variant="ghost" size="sm" className="gap-1.5 text-xs" asChild>
                <Link href="/playground">
                  <Code2 className="h-3.5 w-3.5" />
                  Playground
                </Link>
              </Button>
              <Button variant="ghost" size="sm" className="gap-1.5 text-xs" asChild>
                <Link href="/leaderboard">
                  <Trophy className="h-3.5 w-3.5" />
                  Leaderboard
                </Link>
              </Button>
              <Button variant="ghost" size="sm" className="gap-1.5 text-xs" asChild>
                <Link href="/developers">
                  <Users className="h-3.5 w-3.5" />
                  Developers
                </Link>
              </Button>
              <Button variant="ghost" size="sm" className="gap-1.5 text-xs" asChild>
                <Link href="/jobs">
                  <Briefcase className="h-3.5 w-3.5" />
                  Jobs
                </Link>
              </Button>
              <Button variant="ghost" size="sm" className="gap-1.5 text-xs" asChild>
                <Link href="/feedback">
                  <MessageSquare className="h-3.5 w-3.5" />
                  Feedback
                </Link>
              </Button>
            </div>
          </div>

          {/* Center: Exercise Controls */}
          <div className="flex items-center justify-center gap-1 sm:gap-2 shrink-0">
            <Button
              variant="outline"
              size="sm"
              onClick={previousExercise}
              disabled={!hasExercises || !canGoPrevious}
              className="h-8 px-2 sm:px-3"
            >
              <ChevronLeft className="h-4 w-4" />
              <span className="hidden sm:inline ml-1">Prev</span>
            </Button>

            <Button
              variant="default"
              size="sm"
              onClick={onRun}
              disabled={!hasExercises || isCompiling}
              className="min-w-16 sm:min-w-20 h-8 px-2 sm:px-3"
            >
              {isCompiling ? (
                <>
                  <span className="animate-spin mr-1">⚡</span>
                  <span className="hidden xs:inline">Run...</span>
                  <span className="xs:hidden">...</span>
                </>
              ) : (
                <>
                  <Play className="h-4 w-4" />
                  <span className="hidden xs:inline ml-1">Run</span>
                </>
              )}
            </Button>

            <Button variant="outline" size="sm" onClick={onShowHint} disabled={!hasExercises} className="hidden md:flex h-8 px-2 sm:px-3">
              <Lightbulb className="h-4 w-4" />
              <span className="hidden lg:inline ml-1">Hint</span>
            </Button>

            <Button variant="outline" size="sm" onClick={onReset} disabled={!hasExercises} className="hidden md:flex h-8 px-2 sm:px-3">
              <RotateCcw className="h-4 w-4" />
              <span className="hidden lg:inline ml-1">Reset</span>
            </Button>

            <Button
              variant="outline"
              size="sm"
              onClick={nextExercise}
              disabled={!hasExercises || !canGoNext}
              className="h-8 px-2 sm:px-3"
            >
              <span className="hidden sm:inline mr-1">Next</span>
              <ChevronRight className="h-4 w-4" />
            </Button>

            {/* Mobile Menu (Triple Dot) */}
            <DropdownMenu open={isMobileMenuOpen} onOpenChange={setIsMobileMenuOpen}>
              <DropdownMenuTrigger asChild>
                <Button 
                  variant="outline" 
                  size="sm" 
                  className="md:hidden h-8 px-2"
                  disabled={!hasExercises}
                >
                  <MoreVertical className="h-4 w-4" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-48">
                <DropdownMenuItem onClick={() => { onShowHint(); setIsMobileMenuOpen(false); }}>
                  <Lightbulb className="h-4 w-4 mr-2" />
                  Show Hint
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => { onReset(); setIsMobileMenuOpen(false); }}>
                  <RotateCcw className="h-4 w-4 mr-2" />
                  Reset Exercise
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem asChild>
                  <Link href="/dashboard" className="flex items-center">
                    <LayoutDashboard className="h-4 w-4 mr-2" />
                    Dashboard
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link href="/playground" className="flex items-center">
                    <Code2 className="h-4 w-4 mr-2" />
                    Playground
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link href="/leaderboard" className="flex items-center">
                    <Trophy className="h-4 w-4 mr-2" />
                    Leaderboard
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link href="/developers" className="flex items-center">
                    <Users className="h-4 w-4 mr-2" />
                    Developers
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link href="/jobs" className="flex items-center">
                    <Briefcase className="h-4 w-4 mr-2" />
                    Jobs
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link href="/feedback" className="flex items-center">
                    <MessageSquare className="h-4 w-4 mr-2" />
                    Feedback
                  </Link>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>

          {/* Right: Progress + Auth */}
          <div className="flex items-center justify-end gap-2 md:gap-3 min-w-0 shrink">
            <div className="hidden xl:flex items-center gap-2 shrink-0">
              <span className="text-xs text-muted-foreground whitespace-nowrap">
                {completed}/{total}
              </span>
              <Progress value={percentage} className="h-2 w-20" />
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

