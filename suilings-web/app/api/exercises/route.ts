import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'
import exercisesData from '@/lib/exercises-data.json'

export async function GET() {
  try {
    // Check if Supabase is configured
    if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
      return NextResponse.json({ exercises: exercisesData.exercises })
    }

    const supabase = await createClient()

    // Get current user (if authenticated)
    const { data: { user } } = await supabase.auth.getUser()

    // Fetch all exercises from Supabase
    const { data: exercises, error: exercisesError } = await supabase
      .from('exercises')
      .select('*')
      .order('order_index', { ascending: true })

    // If no exercises in Supabase, fallback to local data
    if (exercisesError || !exercises || exercises.length === 0) {
      return NextResponse.json({ exercises: exercisesData.exercises })
    }

    // Map exercises from Supabase to the format expected by frontend
    const mappedExercises = exercises.map(ex => {
      // Find matching exercise from local data to get initialCode and description
      const localEx = exercisesData.exercises.find(e => e.name === ex.name)
      
      return {
        name: ex.name,
        path: ex.path,
        mode: ex.mode,
        hint: ex.hint,
        description: localEx?.description || '',
        initialCode: localEx?.initialCode || '',
        status: 'pending' as const,
      }
    })

    // If user is authenticated, also fetch their progress
    if (user) {
      const { data: progress, error: progressError } = await supabase
        .from('user_progress')
        .select('*')
        .eq('user_id', user.id)

      if (!progressError && progress) {
        // Map progress to exercises
        const progressMap = new Map(
          progress?.map(p => [p.exercise_id, p]) || []
        )

        const exercisesWithProgress = mappedExercises.map(exercise => {
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
    return NextResponse.json({ exercises: mappedExercises })
  } catch (error) {
    console.error('Error in exercises API:', error)
    
    // Final fallback to local data
    return NextResponse.json({ exercises: exercisesData.exercises })
  }
}
