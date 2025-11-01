import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const requestUrl = new URL(request.url)
  const code = requestUrl.searchParams.get('code')
  const origin = requestUrl.origin

  if (code) {
    const supabase = await createClient()
    const { data, error } = await supabase.auth.exchangeCodeForSession(code)
    
    if (error) {
      console.error('Error exchanging code for session:', error)
      return NextResponse.redirect(`${origin}/login?error=auth_error`)
    }
    
    if (data.user) {
      // Create or update user profile with upsert
      const profileData = {
        id: data.user.id,
        username: data.user.user_metadata.user_name || 
                 data.user.user_metadata.preferred_username ||
                 data.user.email?.split('@')[0] ||
                 'user',
        full_name: data.user.user_metadata.full_name || 
                  data.user.user_metadata.name ||
                  data.user.user_metadata.user_name ||
                  null,
        avatar_url: data.user.user_metadata.avatar_url || null,
        updated_at: new Date().toISOString(),
      }

      const { error: profileError } = await supabase
        .from('profiles')
        .upsert(profileData, {
          onConflict: 'id'
        })

      if (profileError) {
        console.error('Error creating/updating profile:', profileError)
        // Don't fail the login if profile creation fails
        // The user can still use the app
      }
    }
  }

  // URL to redirect to after sign in process completes
  return NextResponse.redirect(`${origin}/exercise`)
}

