import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { createAdminClient } from '@/lib/supabase/admin';

export async function GET(request: NextRequest) {
  try {
    const supabase = await createClient();
    
    const { data: { user } } = await supabase.auth.getUser();
    
    const currentUser = user;
    const currentUserId = user?.id;

    const searchParams = request.nextUrl.searchParams;
    const filter = searchParams.get('filter') || 'all-time';

    let query = supabase
      .from('exercise_progress')
      .select(`
        user_id,
        status,
        completed_at,
        time_spent,
        updated_at
      `);

    if (filter === 'monthly') {
      const firstDayOfMonth = new Date();
      firstDayOfMonth.setDate(1);
      firstDayOfMonth.setHours(0, 0, 0, 0);
      query = query.or(`completed_at.gte.${firstDayOfMonth.toISOString()},updated_at.gte.${firstDayOfMonth.toISOString()}`);
    } else if (filter === 'weekly') {
      const firstDayOfWeek = new Date();
      firstDayOfWeek.setDate(firstDayOfWeek.getDate() - firstDayOfWeek.getDay());
      firstDayOfWeek.setHours(0, 0, 0, 0);
      query = query.or(`completed_at.gte.${firstDayOfWeek.toISOString()},updated_at.gte.${firstDayOfWeek.toISOString()}`);
    }

    const { data: progressData, error: progressError } = await query;

    if (progressError) {
      throw progressError;
    }

    // Get ALL users who have ever logged in (via exercise_progress or auth)
    // First get user IDs from progress
    const progressUserIds = [...new Set(progressData?.map((p: any) => p.user_id) || [])];
    
    // Also get all users from auth to include users with no progress
    let allUserIds = progressUserIds;
    try {
      const adminClient = createAdminClient();
      const { data: { users: allAuthUsers }, error: usersError } = await adminClient.auth.admin.listUsers();
      
      if (usersError) {
        console.error('❌ Supabase admin.listUsers() error:', usersError);
      }
      
      // Combine: users with progress + users without progress
      if (allAuthUsers && !usersError) {
        console.log(`✅ Admin client success: Found ${allAuthUsers.length} total users, ${progressUserIds.length} with progress`);
        allUserIds = [...new Set([...progressUserIds, ...allAuthUsers.map(u => u.id)])];
      } else {
        console.warn('⚠️ Admin client returned no users or had error');
      }
    } catch (error: any) {
      // If admin access fails, fall back to showing only users with progress
      console.error('❌ Admin client failed:', error.message);
      console.error('Environment check:', {
        hasUrl: !!process.env.NEXT_PUBLIC_SUPABASE_URL,
        hasServiceKey: !!process.env.SUPABASE_SERVICE_ROLE_KEY,
        serviceKeyLength: process.env.SUPABASE_SERVICE_ROLE_KEY?.length || 0
      });
    }
    
    if (allUserIds.length === 0) {
      return NextResponse.json({
        leaderboard: [],
        userPosition: null,
        totalUsers: 0,
      });
    }

    const { count: totalExercisesCount } = await supabase
      .from('exercises')
      .select('*', { count: 'exact', head: true });

    const totalExercises = totalExercisesCount || 31;

    const userStats = allUserIds.map(userId => {
      const userProgress = progressData?.filter((p: any) => p.user_id === userId) || [];
      const completed = userProgress.filter((p: any) => p.status === 'completed').length;
      const totalTimeSpent = userProgress.reduce((sum: number, p: any) => sum + (p.time_spent || 0), 0);
      const streakDays = calculateStreak(userProgress);
      
      const lastActive = userProgress.length > 0 
        ? new Date(Math.max(
            ...userProgress.map((p: any) => {
              const completedDate = p.completed_at ? new Date(p.completed_at).getTime() : 0;
              const updatedDate = p.updated_at ? new Date(p.updated_at).getTime() : 0;
              return Math.max(completedDate, updatedDate);
            })
          ))
        : new Date(0); // Unix epoch for users with no activity

      const completionRate = totalExercises > 0 ? (completed / totalExercises) * 100 : 0;
      const isCurrentUser = userId === currentUserId;
      const username = isCurrentUser ? 'You' : `User ${userId.substring(0, 8)}`;

      return {
        user_id: userId,
        username: username,
        email: isCurrentUser ? currentUser?.email || '' : '',
        completed_exercises: completed,
        total_exercises: totalExercises,
        completion_rate: completionRate,
        streak_days: streakDays,
        total_time_spent: totalTimeSpent,
        last_active: lastActive.toISOString(),
      };
    });

    userStats.sort((a, b) => {
      if (b.completed_exercises !== a.completed_exercises) {
        return b.completed_exercises - a.completed_exercises;
      }
      return b.completion_rate - a.completion_rate;
    });

    const leaderboard = userStats.map((entry, index) => ({
      ...entry,
      rank: index + 1,
    }));

    const userPosition = currentUserId ? leaderboard.find(entry => entry.user_id === currentUserId) : null;
    const topLeaderboard = leaderboard.slice(0, 100);

    return NextResponse.json({
      leaderboard: topLeaderboard,
      userPosition,
      totalUsers: leaderboard.length,
    });
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || 'Failed to fetch leaderboard' },
      { status: 500 }
    );
  }
}

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

