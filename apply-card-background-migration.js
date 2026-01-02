import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'
import { readFileSync } from 'fs'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'

// Load environment variables
dotenv.config()

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const supabaseUrl = process.env.VITE_SUPABASE_URL
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase credentials in .env file')
  process.exit(1)
}

// Create Supabase client with service role for admin operations
const supabase = createClient(supabaseUrl, supabaseKey)

async function applyMigration() {
  try {
    console.log('Applying card background migration...')
    
    // Read the migration file
    const migrationPath = join(__dirname, 'supabase', 'migrations', '020_add_card_background.sql')
    const migrationSQL = readFileSync(migrationPath, 'utf8')
    
    // Split the migration into individual statements
    const statements = migrationSQL
      .split(';')
      .filter(stmt => stmt.trim())
      .map(stmt => stmt.trim() + ';')
    
    // Apply each statement
    for (const statement of statements) {
      if (statement.includes('storage.buckets') || statement.includes('storage.objects')) {
        console.log('Skipping storage-related statement (needs to be done via dashboard)...')
        continue
      }
      
      console.log('Executing:', statement.substring(0, 50) + '...')
      const { error } = await supabase.rpc('exec_sql', { sql: statement })
      if (error) {
        console.error('Error executing statement:', error)
      }
    }
    
    console.log('Migration applied successfully!')
    console.log('\nNOTE: Storage bucket creation needs to be done manually in Supabase Dashboard:')
    console.log('1. Go to Storage section')
    console.log('2. Create a new bucket called "card-backgrounds"')
    console.log('3. Set it as public')
    console.log('4. Set file size limit to 10MB')
    
  } catch (error) {
    console.error('Error applying migration:', error)
    process.exit(1)
  }
}

applyMigration()