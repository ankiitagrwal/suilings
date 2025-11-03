"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import { ThemeToggle } from "@/components/theme-toggle";
import { LoginButton } from "@/components/auth/LoginButton";
import { UserMenu } from "@/components/auth/UserMenu";
import { useAuth } from "@/lib/hooks/useAuth";
import { LayoutDashboard, BookOpen, Home, Trophy } from "lucide-react";

interface SimpleHeaderProps {
  showNavigation?: boolean;
}

export function SimpleHeader({ showNavigation = true }: SimpleHeaderProps) {
  const { user, loading } = useAuth();

  return (
    <header className="border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 sticky top-0 z-50">
      <div className="container flex h-16 items-center justify-between px-4">
        {/* Logo */}
        <div className="flex items-center gap-6">
          <Link href="/" className="flex items-center gap-2 hover:opacity-80 transition-opacity">
            <div className="text-2xl font-bold bg-gradient-to-r from-indigo-500 to-purple-500 bg-clip-text text-transparent">
              Suilings
            </div>
          </Link>
          
          {showNavigation && (
            <nav className="hidden md:flex items-center gap-2">
              <Link href="/">
                <Button variant="ghost" size="sm" className="gap-2">
                  <Home className="h-4 w-4" />
                  Home
                </Button>
              </Link>
              <Link href="/dashboard">
                <Button variant="ghost" size="sm" className="gap-2">
                  <LayoutDashboard className="h-4 w-4" />
                  Dashboard
                </Button>
              </Link>
              <Link href="/exercise">
                <Button variant="ghost" size="sm" className="gap-2">
                  <BookOpen className="h-4 w-4" />
                  Exercises
                </Button>
              </Link>
              <Link href="/leaderboard">
                <Button variant="ghost" size="sm" className="gap-2">
                  <Trophy className="h-4 w-4" />
                  Leaderboard
                </Button>
              </Link>
            </nav>
          )}
        </div>

        {/* Right Side - Auth & Theme Toggle */}
        <div className="flex items-center gap-3">
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

