import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { createAdminClient } from '@/lib/supabase/admin';

export async function GET(request: NextRequest) {
  try {
    const supabase = await createClient();
    
    // Use admin client to bypass RLS for leaderboard aggregation
    // This is safe because we only expose aggregated stats, not individual progress details
    const adminClient = createAdminClient();
    
    const { data: { user } } = await supabase.auth.getUser();
    
    const currentUser = user;
    const currentUserId = user?.id;

    const searchParams = request.nextUrl.searchParams;
    const filter = searchParams.get('filter') || 'all-time';
    
    let query = adminClient
      .from('exercise_progress')
      .select(`
        user_id,
        status,
        completed_at,
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

    // Get users based on filter
    // For time-filtered views (monthly/weekly), only show users with activity in that period
    // For all-time view, show all users including those with no progress
    const progressUserIds = [...new Set(progressData?.map((p: any) => p.user_id) || [])];
    
    let allUserIds = progressUserIds;
    
    // Only fetch all users for "all-time" filter
    if (filter === 'all-time') {
      try {
        const { data: { users: allAuthUsers }, error: usersError } = await adminClient.auth.admin.listUsers();
        
        // Combine: users with progress + users without progress
        if (allAuthUsers && !usersError) {
          allUserIds = [...new Set([...progressUserIds, ...allAuthUsers.map(u => u.id)])];
        }
      } catch (error) {
        // If admin access fails, fall back to showing only users with progress
        console.warn('Could not fetch all users, showing only users with progress');
      }
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

    const totalExercises = totalExercisesCount || 82;

    // Fetch user metadata (for GitHub usernames) from auth
    let userMetadataMap: Map<string, any> = new Map();
    
    try {
      const { data: { users: allAuthUsers }, error: usersError } = await adminClient.auth.admin.listUsers();
      if (allAuthUsers && !usersError) {
        allAuthUsers.forEach(u => {
          userMetadataMap.set(u.id, u.user_metadata || {});
        });
      }
    } catch (error) {
      console.warn('Could not fetch user metadata for leaderboard');
    }

    // Fetch profiles so leaderboard links use same username as profile page (avoids wrong profile when clicking)
    const profileByUserId = new Map<string, { username?: string; github_username?: string }>();
    try {
      const { data: profiles } = await adminClient.from('profiles').select('id, username, github_username').in('id', allUserIds);
      profiles?.forEach((p: any) => {
        profileByUserId.set(p.id, { username: p.username, github_username: p.github_username });
      });
    } catch (error) {
      console.warn('Could not fetch profiles for leaderboard');
    }

    const userStats = allUserIds.map(userId => {
      const userProgress = progressData?.filter((p: any) => p.user_id === userId) || [];
      const completed = userProgress.filter((p: any) => p.status === 'completed').length;
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
      
      // Prefer profile table for username so /u/username resolves to same user's profile (fixes leaderboard→profile mismatch)
      const profile = profileByUserId.get(userId);
      const metadata = userMetadataMap.get(userId) || {};
      const linkUsername = (profile?.username || profile?.github_username) || userId;
      const displayUsername = metadata.user_name || metadata.preferred_username || profile?.username || profile?.github_username || userId.substring(0, 8);

      return {
        user_id: userId,
        username: linkUsername, // Used for profile URL – must match profiles table
        displayName: isCurrentUser ? 'You' : displayUsername,
        email: isCurrentUser ? currentUser?.email || '' : '',
        github_username: displayUsername,
        completed_exercises: completed,
        total_exercises: totalExercises,
        completion_rate: completionRate,
        streak_days: streakDays,
        last_active: lastActive.toISOString(),
      };
    });

    userStats.sort((a, b) => {
      if (b.completed_exercises !== a.completed_exercises) {
        return b.completed_exercises - a.completed_exercises;
      }
      return b.completion_rate - a.completion_rate;
    });

    // Assign ranks (keep usernames empty for privacy)
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

