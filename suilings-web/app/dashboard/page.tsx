"use client";

import { useEffect, useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { 
  Trophy, 
  Target, 
  Clock, 
  Zap, 
  BookOpen, 
  Play,
  CheckCircle2,
  Circle,
  ArrowRight,
  Flame,
  Award
} from "lucide-react";
import Link from "next/link";
import { SimpleHeader } from "@/components/layout/SimpleHeader";

interface CategoryStats {
  name: string;
  total: number;
  completed: number;
  inProgress: number;
  pending: number;
}

export default function DashboardPage() {
  const router = useRouter();
  const { exercises, setCurrentExercise, fetchProgress } = useExerciseStore();
  const [streakDays, setStreakDays] = useState(0);

  // Calculate stats using useMemo to avoid cascading renders
  const stats = useMemo(() => {
    if (exercises.length === 0) {
      return {
        total: 0,
        completed: 0,
        inProgress: 0,
        pending: 0,
        completionRate: 0,
      };
    }

    const completed = exercises.filter(e => e.status === 'completed').length;
    const inProgress = exercises.filter(e => e.status === 'in-progress').length;
    const pending = exercises.filter(e => e.status === 'pending' || !e.status).length;
    
    return {
      total: exercises.length,
      completed,
      inProgress,
      pending,
      completionRate: exercises.length > 0 ? (completed / exercises.length) * 100 : 0,
    };
  }, [exercises]);

  // Calculate category stats using useMemo
  const categoryStats = useMemo(() => {
    if (exercises.length === 0) return [];
    
    const categories = new Map<string, CategoryStats>();
    
    exercises.forEach(ex => {
      const category = ex.path.split('/')[1] || 'other';
      const categoryName = category.charAt(0).toUpperCase() + category.slice(1);
      
      if (!categories.has(category)) {
        categories.set(category, {
          name: categoryName,
          total: 0,
          completed: 0,
          inProgress: 0,
          pending: 0,
        });
      }
      
      const cat = categories.get(category)!;
      cat.total++;
      
      if (ex.status === 'completed') cat.completed++;
      else if (ex.status === 'in-progress') cat.inProgress++;
      else cat.pending++;
    });
    
    return Array.from(categories.values());
  }, [exercises]);

  // Calculate recent exercises using useMemo
  const recentExercises = useMemo(() => {
    if (exercises.length === 0) return [];
    
    return exercises
      .map((ex, idx) => ({ 
        name: ex.name,
        path: ex.path,
        status: ex.status,
        index: idx 
      }))
      .filter(ex => ex.status === 'in-progress' || ex.status === 'completed')
      .slice(-5)
      .reverse();
  }, [exercises]);

  useEffect(() => {
    // Fetch progress from backend
    fetchProgress();
  }, [fetchProgress]);

  // Fetch streak from backend
  useEffect(() => {
    const fetchStreak = async () => {
      try {
        const response = await fetch('/api/stats');
        if (response.ok) {
          const data = await response.json();
          setStreakDays(data.stats?.streakDays || 0);
        }
      } catch {
        setStreakDays(0);
      }
    };
    
    if (exercises.length > 0) {
      fetchStreak();
    }
  }, [exercises]);

  return (
    <div className="min-h-screen flex flex-col bg-background">
      <SimpleHeader />
      
      <main className="flex-1 overflow-y-auto">
        <div className="container mx-auto p-6 space-y-6 pb-16">
          {/* Header */}
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>
              <p className="text-muted-foreground mt-1">
                Track your progress and continue learning
              </p>
            </div>
            <Link href="/exercise">
              <Button size="lg" className="gap-2">
                <Play className="h-5 w-5" />
                Continue Learning
              </Button>
            </Link>
          </div>

          {/* Stats Overview */}
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">
                  Total Progress
                </CardTitle>
                <Target className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {stats.completed}/{stats.total}
                </div>
                <p className="text-xs text-muted-foreground">
                  {stats.completionRate.toFixed(1)}% complete
                </p>
                <Progress value={stats.completionRate} className="mt-2" />
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">
                  Completed
                </CardTitle>
                <CheckCircle2 className="h-4 w-4 text-green-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-green-500">
                  {stats.completed}
                </div>
                <p className="text-xs text-muted-foreground">
                  Exercises mastered
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">
                  In Progress
                </CardTitle>
                <Zap className="h-4 w-4 text-yellow-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-yellow-500">
                  {stats.inProgress}
                </div>
                <p className="text-xs text-muted-foreground">
                  Currently working on
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">
                  Streak
                </CardTitle>
                <Flame className="h-4 w-4 text-orange-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-orange-500">
                  {streakDays} days
                </div>
                <p className="text-xs text-muted-foreground">
                  {streakDays > 0 ? `Keep it going! 🔥` : `Start your streak today!`}
                </p>
              </CardContent>
            </Card>
          </div>

          {/* Main Content Grid */}
          <div className="grid gap-6 lg:grid-cols-2">
            {/* Category Progress */}
            <Card className="lg:col-span-1">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <BookOpen className="h-5 w-5" />
                  Progress by Category
                </CardTitle>
                <CardDescription>
                  Your progress across different topics
                </CardDescription>
              </CardHeader>
              <CardContent className="max-h-[400px] overflow-y-auto space-y-4 scrollbar-thin scrollbar-thumb-primary scrollbar-track-muted">
                {categoryStats.length === 0 ? (
                  <div className="text-center py-8 text-muted-foreground">
                    <BookOpen className="h-12 w-12 mx-auto mb-4 opacity-50" />
                    <p>No exercises loaded yet</p>
                    <p className="text-sm">Start learning to see your progress</p>
                  </div>
                ) : (
                  categoryStats.map((cat) => (
                  <div key={cat.name} className="space-y-2">
                    <div className="flex items-center justify-between">
                      <div className="font-medium">{cat.name}</div>
                      <div className="text-sm text-muted-foreground">
                        {cat.completed}/{cat.total}
                      </div>
                    </div>
                    <Progress 
                      value={(cat.completed / cat.total) * 100} 
                      className="h-2"
                    />
                    <div className="flex gap-2 text-xs text-muted-foreground">
                      <span className="flex items-center gap-1">
                        <CheckCircle2 className="h-3 w-3 text-green-500" />
                        {cat.completed} done
                      </span>
                      {cat.inProgress > 0 && (
                        <span className="flex items-center gap-1">
                          <Zap className="h-3 w-3 text-yellow-500" />
                          {cat.inProgress} in progress
                        </span>
                      )}
                      {cat.pending > 0 && (
                        <span className="flex items-center gap-1">
                          <Circle className="h-3 w-3" />
                          {cat.pending} remaining
                        </span>
                      )}
                    </div>
                  </div>
                )))}
              </CardContent>
            </Card>

            {/* Recent Activity */}
            <Card className="lg:col-span-1">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Clock className="h-5 w-5" />
                  Recent Activity
                </CardTitle>
                <CardDescription>
                  Your recently worked exercises
                </CardDescription>
              </CardHeader>
              <CardContent>
                {recentExercises.length === 0 ? (
                  <div className="text-center py-8 text-muted-foreground">
                    <BookOpen className="h-12 w-12 mx-auto mb-4 opacity-50" />
                    <p>No recent activity yet</p>
                    <p className="text-sm">Start an exercise to see it here</p>
                  </div>
                ) : (
                  <div className="space-y-3">
                    {recentExercises.map((ex) => (
                      <div
                        key={ex.name}
                        className="flex items-center justify-between p-3 rounded-lg border hover:bg-accent transition-colors cursor-pointer"
                        onClick={() => {
                          setCurrentExercise(ex.index);
                          router.push('/exercise');
                        }}
                      >
                        <div className="flex items-center gap-3">
                          {ex.status === 'completed' ? (
                            <CheckCircle2 className="h-5 w-5 text-green-500" />
                          ) : (
                            <Zap className="h-5 w-5 text-yellow-500" />
                          )}
                          <div>
                            <div className="font-medium">{ex.name}</div>
                            <div className="text-xs text-muted-foreground">
                              {ex.path.split('/')[1]}
                            </div>
                          </div>
                        </div>
                        <ArrowRight className="h-4 w-4 text-muted-foreground" />
                      </div>
                    ))}
                  </div>
                )}
              </CardContent>
            </Card>

            {/* Achievements */}
            <Card className="lg:col-span-2">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Trophy className="h-5 w-5" />
                  Achievements
                </CardTitle>
                <CardDescription>
                  Milestones you&apos;ve reached
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div className={`p-4 rounded-lg border text-center ${stats.completed >= 1 ? 'bg-primary/10 border-primary' : 'opacity-50'}`}>
                    <Award className={`h-8 w-8 mx-auto mb-2 ${stats.completed >= 1 ? 'text-primary' : 'text-muted-foreground'}`} />
                    <div className="font-medium text-sm">First Steps</div>
                    <div className="text-xs text-muted-foreground">Complete 1 exercise</div>
                  </div>
                  
                  <div className={`p-4 rounded-lg border text-center ${stats.completed >= 5 ? 'bg-primary/10 border-primary' : 'opacity-50'}`}>
                    <Award className={`h-8 w-8 mx-auto mb-2 ${stats.completed >= 5 ? 'text-primary' : 'text-muted-foreground'}`} />
                    <div className="font-medium text-sm">Getting Started</div>
                    <div className="text-xs text-muted-foreground">Complete 5 exercises</div>
                  </div>
                  
                  <div className={`p-4 rounded-lg border text-center ${stats.completed >= 10 ? 'bg-primary/10 border-primary' : 'opacity-50'}`}>
                    <Award className={`h-8 w-8 mx-auto mb-2 ${stats.completed >= 10 ? 'text-primary' : 'text-muted-foreground'}`} />
                    <div className="font-medium text-sm">Making Progress</div>
                    <div className="text-xs text-muted-foreground">Complete 10 exercises</div>
                  </div>
                  
                  <div className={`p-4 rounded-lg border text-center ${stats.completed >= stats.total && stats.total > 0 ? 'bg-primary/10 border-primary' : 'opacity-50'}`}>
                    <Trophy className={`h-8 w-8 mx-auto mb-2 ${stats.completed >= stats.total && stats.total > 0 ? 'text-primary' : 'text-muted-foreground'}`} />
                    <div className="font-medium text-sm">Master</div>
                    <div className="text-xs text-muted-foreground">Complete all exercises</div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Quick Actions */}
          <Card>
            <CardHeader>
              <CardTitle>Quick Actions</CardTitle>
              <CardDescription>
                Jump back into learning or explore resources
              </CardDescription>
            </CardHeader>
            <CardContent className="flex flex-wrap gap-3">
              <Link href="/exercise">
                <Button variant="default" className="gap-2">
                  <Play className="h-4 w-4" />
                  Continue Learning
                </Button>
              </Link>
              <Link href="https://docs.sui.io/concepts/sui-move-concepts" target="_blank" rel="noopener noreferrer">
                <Button variant="outline" className="gap-2">
                  <BookOpen className="h-4 w-4" />
                  Sui Move Documentation
                </Button>
              </Link>
              <Link href="/leaderboard">
                <Button variant="outline" className="gap-2">
                  <Trophy className="h-4 w-4" />
                  View Leaderboard
                </Button>
              </Link>
            </CardContent>
          </Card>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-border bg-background">
        <div className="container mx-auto px-4 py-6">
          <div className="flex flex-col md:flex-row items-center justify-between gap-4">
            <div className="text-sm text-muted-foreground">
              <p>Suilings © 2025 • Learn Move on Sui</p>
            </div>
            <div className="flex items-center gap-6">
              <Link href="https://docs.sui.io" target="_blank" rel="noopener noreferrer" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                Sui Docs
              </Link>
              <Link href="/" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                Home
              </Link>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}

