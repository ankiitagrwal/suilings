import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function calculateStreak(userProgress: any[]): number {
  if (!userProgress || userProgress.length === 0) return 0;

  const sortedProgress = [...userProgress]
    .filter(p => p.completed_at || p.updated_at)
    .sort((a, b) => {
      const dateA = new Date(a.completed_at || a.updated_at).getTime();
      const dateB = new Date(b.completed_at || b.updated_at).getTime();
      return dateB - dateA;
    });

  if (sortedProgress.length === 0) return 0;

  const uniqueDays = new Set(
    sortedProgress.map(p => {
      const date = new Date(p.completed_at || p.updated_at);
      return date.toDateString();
    })
  );

  const daysArray = Array.from(uniqueDays)
    .map(d => new Date(d))
    .sort((a, b) => b.getTime() - a.getTime());

  let streak = 1;
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const mostRecent = daysArray[0];
  const daysDiff = Math.floor((today.getTime() - mostRecent.getTime()) / (1000 * 60 * 60 * 24));
  
  if (daysDiff > 1) {
    return 0;
  }

  for (let i = 1; i < daysArray.length; i++) {
    const dayDiff = Math.floor(
      (daysArray[i - 1].getTime() - daysArray[i].getTime()) / (1000 * 60 * 60 * 24)
    );
    
    if (dayDiff === 1) {
      streak++;
    } else {
      break;
    }
  }

  return streak;
}

export async function GET() {
  try {
    const supabase = await createClient();
    
    const { data: { user }, error: userError } = await supabase.auth.getUser();
    
    if (userError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    const { data: progress, error: progressError } = await supabase
      .from('exercise_progress')
      .select('*')
      .eq('user_id', user.id);

    if (progressError) {
      throw progressError;
    }

    const totalExercises = progress?.length || 0;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const completedExercises = progress?.filter((p: any) => p.status === 'completed').length || 0;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const inProgressExercises = progress?.filter((p: any) => p.status === 'in-progress').length || 0;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const totalTimeSpent = progress?.reduce((sum: number, p: any) => sum + (p.time_spent || 0), 0) || 0;
    const streakDays = calculateStreak(progress || []);
    
    const recentActivity = progress
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      ?.sort((a: any, b: any) => new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime())
      .slice(0, 10) || [];

    return NextResponse.json({
      stats: {
        totalExercises,
        completedExercises,
        inProgressExercises,
        completionRate: totalExercises > 0 ? (completedExercises / totalExercises) * 100 : 0,
        totalTimeSpent,
        streakDays,
      },
      recentActivity,
      progress,
    });
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || 'Failed to fetch stats' },
      { status: 500 }
    );
  }
}

