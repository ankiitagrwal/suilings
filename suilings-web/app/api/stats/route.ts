import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

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
    const completedExercises = progress?.filter((p: any) => p.status === 'completed').length || 0;
    const inProgressExercises = progress?.filter((p: any) => p.status === 'in_progress').length || 0;
    const totalTimeSpent = progress?.reduce((sum: number, p: any) => sum + (p.time_spent || 0), 0) || 0;
    const streakDays = 5;
    
    const recentActivity = progress
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
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || 'Failed to fetch stats' },
      { status: 500 }
    );
  }
}

