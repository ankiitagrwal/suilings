import { createClient } from '@supabase/supabase-js'

/**
 * Admin Supabase client with service role key
 * Use this for server-side operations that need to bypass RLS
 * 
 * WARNING: Never expose this client to the browser!
 * Only use in API routes and server components
 */
export function createAdminClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

  if (!supabaseUrl || !supabaseServiceKey) {
    throw new Error('Missing Supabase environment variables')
  }

  return createClient(supabaseUrl, supabaseServiceKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  })
}
