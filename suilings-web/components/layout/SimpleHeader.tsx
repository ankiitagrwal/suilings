"use client";

import { memo, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import { ThemeToggle } from "@/components/theme-toggle";
import { LoginButton } from "@/components/auth/LoginButton";
import { UserMenu } from "@/components/auth/UserMenu";
import { useAuth } from "@/lib/hooks/useAuth";
import { LayoutDashboard, BookOpen, Trophy, MessageSquare, Code2, Users, Briefcase, Menu } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

interface SimpleHeaderProps {
  showNavigation?: boolean;
}

export const SimpleHeader = memo(function SimpleHeader({ showNavigation = true }: SimpleHeaderProps) {
  const { user, loading } = useAuth();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  return (
    <header className="border-b border-border bg-background/95 backdrop-blur supports-backdrop-filter:bg-background/60 sticky top-0 z-50">
      <div className="container h-16 px-4 max-w-screen-2xl mx-auto">
        <div className="flex h-full items-center justify-between gap-4">
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
              </nav>
            )}
          </div>

          {/* Right: Mobile Menu + Auth & Theme Toggle */}
          <div className="flex items-center justify-end gap-3 min-w-0">
            {showNavigation && (
              <DropdownMenu open={isMobileMenuOpen} onOpenChange={setIsMobileMenuOpen}>
                <DropdownMenuTrigger asChild>
                  <Button variant="outline" size="sm" className="md:hidden h-8 px-2">
                    <Menu className="h-4 w-4" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="w-48">
                  <DropdownMenuItem asChild>
                    <Link href="/dashboard" className="flex items-center">
                      <LayoutDashboard className="h-4 w-4 mr-2" />
                      Dashboard
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem asChild>
                    <Link href="/exercise" className="flex items-center">
                      <BookOpen className="h-4 w-4 mr-2" />
                      Exercises
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
            )}

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

