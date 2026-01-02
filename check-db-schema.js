import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'

// Load environment variables
dotenv.config()

const supabaseUrl = process.env.VITE_SUPABASE_URL
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase credentials in .env file')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseKey)

async function checkSchema() {
  try {
    // Get current user
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      console.log('No user logged in. Please log in first.')
      process.exit(1)
    }
    
    // Query users table to check columns
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('auth_id', user.id)
      .single()
    
    if (error) {
      console.error('Error querying users table:', error)
    } else {
      console.log('User data columns:')
      console.log(Object.keys(data))
      console.log('\nChecking for card background columns:')
      console.log('- card_background_url:', data.hasOwnProperty('card_background_url') ? '✅ EXISTS' : '❌ MISSING')
      console.log('- card_theme:', data.hasOwnProperty('card_theme') ? '✅ EXISTS' : '❌ MISSING')
      console.log('- card_gradient:', data.hasOwnProperty('card_gradient') ? '✅ EXISTS' : '❌ MISSING')
      
      if (data.hasOwnProperty('card_background_url')) {
        console.log('\n✅ Card background columns already exist in the database!')
        console.log('Current values:')
        console.log('- card_background_url:', data.card_background_url || 'null')
        console.log('- card_theme:', data.card_theme || 'null')
        console.log('- card_gradient:', data.card_gradient || 'null')
      } else {
        console.log('\n❌ Card background columns are missing. Migration needs to be applied.')
      }
    }
    
  } catch (error) {
    console.error('Error:', error)
  }
  
  process.exit(0)
}

checkSchema()