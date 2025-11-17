"use client";

import { memo } from "react";
import Link from "next/link";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import { ThemeToggle } from "@/components/theme-toggle";
import { LoginButton } from "@/components/auth/LoginButton";
import { UserMenu } from "@/components/auth/UserMenu";
import { useAuth } from "@/lib/hooks/useAuth";
import { LayoutDashboard, BookOpen, Trophy } from "lucide-react";

interface SimpleHeaderProps {
  showNavigation?: boolean;
}

export const SimpleHeader = memo(function SimpleHeader({ showNavigation = true }: SimpleHeaderProps) {
  const { user, loading } = useAuth();

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
            
            {showNavigation && (
              <nav className="hidden md:flex items-center gap-1 shrink-0">
                <Button variant="ghost" size="sm" className="gap-1.5 text-xs" asChild>
                  <Link href="/dashboard">
                    <LayoutDashboard className="h-3.5 w-3.5" />
                    Dashboard
                  </Link>
                </Button>
                <Button variant="ghost" size="sm" className="gap-1.5 text-xs" asChild>
                  <Link href="/exercise">
                    <BookOpen className="h-3.5 w-3.5" />
                    Exercises
                  </Link>
                </Button>
                <Button variant="ghost" size="sm" className="gap-1.5 text-xs" asChild>
                  <Link href="/leaderboard">
                    <Trophy className="h-3.5 w-3.5" />
                    Leaderboard
                  </Link>
                </Button>
              </nav>
            )}
          </div>

          {/* Center: Empty spacer to match Header structure */}
          <div className="flex items-center justify-center gap-2 shrink-0" />

          {/* Right: Auth & Theme Toggle */}
          <div className="flex items-center justify-end gap-3 min-w-0">
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

