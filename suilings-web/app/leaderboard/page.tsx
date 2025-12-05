"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Trophy,
  Medal,
  Crown,
  TrendingUp,
  Flame,
  Target,
  Award,
  User
} from "lucide-react";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { Footer } from "@/components/layout/Footer";
import { useAuth } from "@/lib/hooks/useAuth";

interface LeaderboardEntry {
  rank: number;
  user_id: string;
  username: string;
  email: string;
  github_username?: string;
  completed_exercises: number;
  total_exercises: number;
  completion_rate: number;
  streak_days: number;
  total_time_spent: number;
  last_active: string;
}

type TimeFilter = 'all-time' | 'monthly' | 'weekly';

export default function LeaderboardPage() {
  const { user } = useAuth();
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntry[]>([]);
  const [userPosition, setUserPosition] = useState<LeaderboardEntry | null>(null);
  const [totalUsers, setTotalUsers] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [timeFilter, setTimeFilter] = useState<TimeFilter>('all-time');

  useEffect(() => {
    fetchLeaderboard(timeFilter);
  }, [timeFilter]);

  const fetchLeaderboard = async (filter: TimeFilter) => {
    setIsLoading(true);
    try {
      const response = await fetch(`/api/leaderboard?filter=${filter}`);
      if (response.ok) {
        const data = await response.json();
        setLeaderboard(data.leaderboard || []);
        setUserPosition(data.userPosition || null);
        setTotalUsers(data.totalUsers || 0);
      }
    } catch {
      setLeaderboard([]);
      setUserPosition(null);
    } finally {
      setIsLoading(false);
    }
  };

  const getRankIcon = (rank: number) => {
    switch (rank) {
      case 1:
        return <Crown className="h-6 w-6 text-yellow-500" />;
      case 2:
        return <Medal className="h-6 w-6 text-gray-400" />;
      case 3:
        return <Medal className="h-6 w-6 text-orange-600" />;
      default:
        return <span className="text-lg font-bold text-muted-foreground">#{rank}</span>;
    }
  };

  const getRankBadgeColor = (rank: number) => {
    if (rank === 1) return "bg-yellow-500/10 text-yellow-500 border-yellow-500/20";
    if (rank === 2) return "bg-gray-400/10 text-gray-400 border-gray-400/20";
    if (rank === 3) return "bg-orange-600/10 text-orange-600 border-orange-600/20";
    return "bg-muted";
  };

  const getInitials = (username: string, githubUsername?: string) => {
    // For "You", show "YO"
    if (username === 'You') return 'YO';
    // For others, use first 2 characters of GitHub username
    if (githubUsername && githubUsername.length >= 2) {
      return githubUsername.substring(0, 2).toUpperCase();
    }
    // Fallback if no GitHub username
    return '??';
  };

  const formatTime = (seconds: number) => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    if (hours > 0) return `${hours}h ${minutes}m`;
    return `${minutes}m`;
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    
    // Check if user has never been active (Unix epoch or very old date)
    if (date.getTime() < 86400000) { // Less than 1 day from epoch (Jan 1, 1970)
      return 'Never';
    }
    
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) return 'Today';
    if (diffDays === 1) return 'Yesterday';
    if (diffDays < 7) return `${diffDays} days ago`;
    return date.toLocaleDateString();
  };

  return (
    <div className="min-h-screen flex flex-col bg-background">
      <SimpleHeader />
      
      <main className="flex-1">
        <div className="container mx-auto p-6 space-y-6 pb-16">
          {/* Header */}
          <div className="text-center space-y-2">
            <div className="flex items-center justify-center gap-3">
              <Trophy className="h-10 w-10 text-primary" />
              <h1 className="text-4xl font-bold tracking-tight">Leaderboard</h1>
            </div>
            <p className="text-muted-foreground text-lg">
              Compete with fellow learners and climb the ranks
            </p>
          </div>

          {/* Time Filter Tabs */}
          <Tabs value={timeFilter} onValueChange={(v) => setTimeFilter(v as TimeFilter)} className="w-full">
            <TabsList className="grid w-full max-w-md mx-auto grid-cols-3">
              <TabsTrigger value="all-time">All Time</TabsTrigger>
              <TabsTrigger value="monthly">This Month</TabsTrigger>
              <TabsTrigger value="weekly">This Week</TabsTrigger>
            </TabsList>
          </Tabs>

          {/* User Position Card */}
          {userPosition && (
            <Card className="border-primary/50 bg-primary/5">
              <CardHeader>
                <CardTitle className="text-lg flex items-center gap-2">
                  <User className="h-5 w-5" />
                  Your Position
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="flex items-center justify-center w-12">
                      {getRankIcon(userPosition.rank)}
                    </div>
                    <Avatar className="h-12 w-12">
                      <AvatarFallback className="bg-primary text-primary-foreground">
                        {getInitials(userPosition.username, userPosition.github_username)}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <div className="font-semibold">{userPosition.username || '\u00A0'}</div>
                      <div className="text-sm text-muted-foreground">
                        {userPosition.email ? userPosition.email : `Rank #${userPosition.rank}`}
                      </div>
                    </div>
                  </div>
                  <div className="flex gap-6 text-center">
                    <div>
                      <div className="text-2xl font-bold text-primary">
                        {userPosition.completed_exercises}
                      </div>
                      <div className="text-xs text-muted-foreground">Completed</div>
                    </div>
                    <div>
                      <div className="text-2xl font-bold text-orange-500">
                        {userPosition.streak_days}
                      </div>
                      <div className="text-xs text-muted-foreground">Streak 🔥</div>
                    </div>
                    <div>
                      <div className="text-2xl font-bold text-green-500">
                        {userPosition.completion_rate.toFixed(0)}%
                      </div>
                      <div className="text-xs text-muted-foreground">Complete</div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Leaderboard Table */}
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle className="flex items-center gap-2">
                    <TrendingUp className="h-5 w-5" />
                    Top Performers
                  </CardTitle>
                  <CardDescription>
                    {timeFilter === 'all-time' && 'All-time rankings based on total exercises completed'}
                    {timeFilter === 'monthly' && 'Rankings for this month'}
                    {timeFilter === 'weekly' && 'Rankings for this week'}
                  </CardDescription>
                </div>
                {!isLoading && totalUsers > 0 && (
                  <div className="text-sm text-muted-foreground">
                    Showing <span className="font-semibold text-foreground">{leaderboard.length}</span> of{' '}
                    <span className="font-semibold text-foreground">{totalUsers}</span> users
                  </div>
                )}
              </div>
            </CardHeader>
            <CardContent>
              {isLoading ? (
                <div className="text-center py-12">
                  <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto"></div>
                  <p className="text-muted-foreground mt-4">Loading rankings...</p>
                </div>
              ) : leaderboard.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <Trophy className="h-16 w-16 mx-auto mb-4 opacity-50" />
                  <p>No rankings available yet</p>
                  <p className="text-sm">Be the first to complete exercises!</p>
                </div>
              ) : (
                <div className="space-y-2 max-h-[600px] overflow-y-auto pr-2">
                  {leaderboard.map((entry) => (
                    <div
                      key={entry.user_id}
                      className={`flex items-center justify-between p-4 rounded-lg border transition-colors ${
                        entry.user_id === user?.id 
                          ? 'bg-primary/5 border-primary/50' 
                          : 'hover:bg-accent'
                      }`}
                    >
                      {/* Rank and User Info */}
                      <div className="flex items-center gap-4 flex-1">
                        <div className="flex items-center justify-center w-12">
                          {getRankIcon(entry.rank)}
                        </div>
                        
                        <Avatar className="h-10 w-10">
                          <AvatarFallback className={entry.rank <= 3 ? getRankBadgeColor(entry.rank) : ''}>
                            {getInitials(entry.username, entry.github_username)}
                          </AvatarFallback>
                        </Avatar>
                        
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2">
                            <span className="font-semibold truncate text-muted-foreground">
                              {entry.username || '\u00A0'}
                            </span>
                            {entry.user_id === user?.id && (
                              <Badge variant="outline" className="text-xs">You</Badge>
                            )}
                          </div>
                          <div className="text-sm text-muted-foreground">
                            Last active {formatDate(entry.last_active)}
                          </div>
                        </div>
                      </div>

                      {/* Stats */}
                      <div className="flex gap-6 text-center">
                        <div className="hidden sm:block">
                          <div className="flex items-center gap-1 text-lg font-bold">
                            <Target className="h-4 w-4 text-primary" />
                            {entry.completed_exercises}
                          </div>
                          <div className="text-xs text-muted-foreground">Exercises</div>
                        </div>
                        
                        <div className="hidden md:block">
                          <div className="flex items-center gap-1 text-lg font-bold text-orange-500">
                            <Flame className="h-4 w-4" />
                            {entry.streak_days}
                          </div>
                          <div className="text-xs text-muted-foreground">Streak</div>
                        </div>
                        
                        <div>
                          <div className="text-lg font-bold text-green-500">
                            {entry.completion_rate.toFixed(0)}%
                          </div>
                          <div className="text-xs text-muted-foreground">Rate</div>
                        </div>
                        
                        <div className="hidden lg:block">
                          <div className="text-lg font-bold text-blue-500">
                            {formatTime(entry.total_time_spent)}
                          </div>
                          <div className="text-xs text-muted-foreground">Time</div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Stats Cards */}
          <div className="grid md:grid-cols-3 gap-4">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Total Learners</CardTitle>
                <Award className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{leaderboard.length}</div>
                <p className="text-xs text-muted-foreground">
                  Active community members
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Top Completion</CardTitle>
                <Trophy className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {leaderboard[0]?.completion_rate.toFixed(0) || 0}%
                </div>
                <p className="text-xs text-muted-foreground">
                  Highest completion rate
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Longest Streak</CardTitle>
                <Flame className="h-4 w-4 text-orange-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-orange-500">
                  {Math.max(...leaderboard.map(e => e.streak_days), 0)} days
                </div>
                <p className="text-xs text-muted-foreground">
                  Most consistent learner 🔥
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}

