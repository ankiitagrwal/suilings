
import { createClient } from '@supabase/supabase-js'
import * as fs from 'fs'
import * as path from 'path'
import * as TOML from '@iarna/toml'

// Load environment variables
import * as dotenv from 'dotenv'
const envLocalPath = path.resolve(__dirname, '../.env.local')
const envPath = path.resolve(__dirname, '../.env')

// Try .env.local first, then fall back to .env
if (fs.existsSync(envLocalPath)) {
  dotenv.config({ path: envLocalPath })
  console.log('📄 Loaded environment from .env.local')
} else if (fs.existsSync(envPath)) {
  dotenv.config({ path: envPath })
  console.log('📄 Loaded environment from .env')
} else {
  // Try default dotenv behavior (checks .env in current directory)
  dotenv.config()
  console.log('📄 Loaded environment from default .env')
}

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing SUPABASE environment variables')
  console.error('Make sure NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are set in .env or .env.local')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseServiceKey)

interface Exercise {
  name: string
  path: string
  mode: string
  hint: string
}

async function loadInfoToml(): Promise<Exercise[]> {
  const infoTomlPath = path.resolve(__dirname, '../../info.toml')
  
  if (!fs.existsSync(infoTomlPath)) {
    throw new Error(`info.toml not found at: ${infoTomlPath}`)
  }

  const tomlContent = fs.readFileSync(infoTomlPath, 'utf-8')
  const parsed = TOML.parse(tomlContent) as any

  if (!parsed.exercises || !Array.isArray(parsed.exercises)) {
    throw new Error('No exercises array found in info.toml')
  }

  return parsed.exercises as Exercise[]
}

function extractCategory(exercisePath: string): string {
  // Extract category from path like "exercises/structs/structs1.move"
  const parts = exercisePath.split('/')
  if (parts.length >= 2) {
    return parts[1]
  }
  return 'general'
}

async function seedExercises() {
  console.log('🌱 Starting exercise seeding...\n')

  try {
    // Load exercises from info.toml
    const exercises = await loadInfoToml()
    console.log(`📚 Found ${exercises.length} exercises in info.toml\n`)

    // Clear existing exercises (optional - comment out if you want to keep existing data)
    console.log('🗑️  Clearing existing exercises...')
    const { error: deleteError } = await supabase
      .from('exercises')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000') // Delete all (this condition is always true)

    if (deleteError) {
      console.error('❌ Error clearing exercises:', deleteError)
    } else {
      console.log('✅ Cleared existing exercises\n')
    }

    // Insert exercises
    let successCount = 0
    let errorCount = 0

    for (let i = 0; i < exercises.length; i++) {
      const exercise = exercises[i]
      const category = extractCategory(exercise.path)

      console.log(`📝 Seeding: ${exercise.name} (${category})...`)

      const { error } = await supabase
        .from('exercises')
        .insert({
          name: exercise.name,
          path: exercise.path,
          category: category,
          mode: exercise.mode,
          hint: exercise.hint || '',
          order_index: i,
        })

      if (error) {
        console.error(`   ❌ Error: ${error.message}`)
        errorCount++
      } else {
        console.log(`   ✅ Success`)
        successCount++
      }
    }

    console.log('\n' + '='.repeat(50))
    console.log(`✨ Seeding complete!`)
    console.log(`   ✅ Successful: ${successCount}`)
    if (errorCount > 0) {
      console.log(`   ❌ Failed: ${errorCount}`)
    }
    console.log('='.repeat(50))

  } catch (error) {
    console.error('\n❌ Fatal error:', error)
    process.exit(1)
  }
}

// Run the seed function
seedExercises()
  .then(() => {
    console.log('\n👋 Done!')
    process.exit(0)
  })
  .catch((error) => {
    console.error('\n💥 Unhandled error:', error)
    process.exit(1)
  })

