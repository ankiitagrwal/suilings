import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'
import exercisesData from '@/lib/exercises-data.json'

export async function GET() {
  try {
    // Always use local exercises data as the source of truth
    const exercises = exercisesData.exercises

    // Check if Supabase is configured for progress tracking
    if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
      return NextResponse.json({ exercises })
    }

    const supabase = await createClient()

    // Get current user (if authenticated)
    const { data: { user } } = await supabase.auth.getUser()

    // If user is authenticated, fetch their progress and merge with local exercises
    if (user) {
      const { data: progress, error: progressError } = await supabase
        .from('exercise_progress')
        .select('*')
        .eq('user_id', user.id)

      if (!progressError && progress) {
        // Map progress to exercises
        const progressMap = new Map(
          progress?.map(p => [p.exercise_id, p]) || []
        )

        const exercisesWithProgress = exercises.map(exercise => {
          const prog = progressMap.get(exercise.name)
          return {
            ...exercise,
            status: prog?.status || 'pending',
            progress: prog || null,
          }
        })

        return NextResponse.json({ exercises: exercisesWithProgress })
      }
    }

    // Return exercises without progress for unauthenticated users
    return NextResponse.json({ exercises })
  } catch (error) {
    console.error('Error in exercises API:', error)
    
    // Final fallback to local data
    return NextResponse.json({ exercises: exercisesData.exercises })
  }
}
