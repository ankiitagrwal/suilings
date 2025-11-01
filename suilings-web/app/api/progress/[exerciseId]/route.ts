import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function POST(
  request: Request,
  { params }: { params: Promise<{ exerciseId: string }> }
) {
  try {
    const { exerciseId } = await params
    const supabase = await createClient()

    // Get current user
    const { data: { user }, error: userError } = await supabase.auth.getUser()

    if (userError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const body = await request.json()
    const { status, last_code, completed } = body

    // Prepare update data
    const updateData: any = {
      user_id: user.id,
      exercise_id: exerciseId,
      status: status || 'in_progress',
      updated_at: new Date().toISOString(),
    }

    if (last_code !== undefined) {
      updateData.last_code = last_code
    }

    if (completed) {
      updateData.status = 'completed'
      updateData.completed_at = new Date().toISOString()
    }

    // Increment attempts count
    const { data: existingProgress } = await supabase
      .from('user_progress')
      .select('attempts_count')
      .eq('user_id', user.id)
      .eq('exercise_id', exerciseId)
      .single()

    updateData.attempts_count = (existingProgress?.attempts_count || 0) + 1

    // Upsert progress
    const { data, error } = await supabase
      .from('user_progress')
      .upsert(updateData, {
        onConflict: 'user_id,exercise_id',
      })
      .select()
      .single()

    if (error) {
      console.error('Error upserting progress:', error)
      return NextResponse.json(
        { error: 'Failed to update progress' },
        { status: 500 }
      )
    }

    return NextResponse.json({ progress: data })
  } catch (error) {
    console.error('Error in progress update API:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

export async function GET(
  request: Request,
  { params }: { params: Promise<{ exerciseId: string }> }
) {
  try {
    const { exerciseId } = await params
    const supabase = await createClient()

    // Get current user
    const { data: { user }, error: userError } = await supabase.auth.getUser()

    if (userError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      )
    }

    // Fetch specific progress
    const { data: progress, error } = await supabase
      .from('user_progress')
      .select('*')
      .eq('user_id', user.id)
      .eq('exercise_id', exerciseId)
      .single()

    if (error && error.code !== 'PGRST116') { // PGRST116 is "not found" error
      return NextResponse.json(
        { error: 'Failed to fetch progress' },
        { status: 500 }
      )
    }

    return NextResponse.json({ progress: progress || null })
  } catch (error) {
    console.error('Error in progress fetch API:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

