'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { LoginButton } from '@/components/auth/LoginButton'
import { useAuth } from '@/lib/hooks/useAuth'

export default function LoginPage() {
  const { user, loading } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (user && !loading) {
      router.push('/')
    }
  }, [user, loading, router])

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    )
  }

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-background to-secondary/20">
      <div className="w-full max-w-md p-8 space-y-6 bg-card rounded-lg shadow-lg border">
        <div className="text-center space-y-2">
          <h1 className="text-3xl font-bold">Welcome to Suilings</h1>
          <p className="text-muted-foreground">
            Learn Move programming with interactive exercises
          </p>
        </div>
        
        <div className="space-y-4">
          <div className="text-sm text-muted-foreground text-center">
            Sign in to save your progress and track your learning journey
          </div>
          
          <div className="flex justify-center">
            <LoginButton />
          </div>
        </div>

        <div className="text-xs text-center text-muted-foreground">
          By signing in, you agree to our terms of service
        </div>
      </div>
    </div>
  )
}

