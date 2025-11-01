import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

export async function GET() {
  try {
    const supabase = await createClient();
    
    // Get current user
    const { data: { user }, error: userError } = await supabase.auth.getUser();
    
    if (userError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    // Fetch user's progress
    const { data: progress, error: progressError } = await supabase
      .from('exercise_progress')
      .select('*')
      .eq('user_id', user.id);

    if (progressError) {
      throw progressError;
    }

    // Calculate statistics
    const totalExercises = progress?.length || 0;
    const completedExercises = progress?.filter((p: any) => p.status === 'completed').length || 0;
    const inProgressExercises = progress?.filter((p: any) => p.status === 'in_progress').length || 0;
    
    // Calculate total time spent (sum of time_spent from all exercises)
    const totalTimeSpent = progress?.reduce((sum: number, p: any) => sum + (p.time_spent || 0), 0) || 0;
    
    // Calculate streak (mock for now - in production, query daily activity)
    const streakDays = 5; // TODO: Implement proper streak calculation
    
    // Get recent activity (last 10 exercises updated)
    const recentActivity = progress
      ?.sort((a: any, b: any) => new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime())
      .slice(0, 10) || [];

    return NextResponse.json({
      stats: {
        totalExercises,
        completedExercises,
        inProgressExercises,
        completionRate: totalExercises > 0 ? (completedExercises / totalExercises) * 100 : 0,
        totalTimeSpent, // in seconds
        streakDays,
      },
      recentActivity,
      progress,
    });
  } catch (error: any) {
    console.error('Error fetching stats:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to fetch stats' },
      { status: 500 }
    );
  }
}

