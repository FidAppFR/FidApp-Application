const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

// Script SQL divisé en parties
const migrations = [
  // 1. Extension UUID
  `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`,
  
  // 2. Table users
  `CREATE TABLE IF NOT EXISTS public.users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    company VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    accept_terms BOOLEAN DEFAULT false NOT NULL,
    accept_newsletter BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    phone VARCHAR(20),
    language VARCHAR(2) DEFAULT 'FR',
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
  );`,
  
  // 3. Index users
  `CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);`,
  `CREATE INDEX IF NOT EXISTS idx_users_company ON public.users(company);`,
  `CREATE INDEX IF NOT EXISTS idx_users_auth_id ON public.users(auth_id);`,
  `CREATE INDEX IF NOT EXISTS idx_users_created_at ON public.users(created_at DESC);`,
  
  // 4. Function update_updated_at
  `CREATE OR REPLACE FUNCTION update_updated_at_column()
  RETURNS TRIGGER AS $$
  BEGIN
      NEW.updated_at = NOW();
      RETURN NEW;
  END;
  $$ language 'plpgsql';`,
  
  // 5. Trigger updated_at
  `DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;`,
  `CREATE TRIGGER update_users_updated_at BEFORE UPDATE
    ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();`,
  
  // 6. Table sessions
  `CREATE TABLE IF NOT EXISTS public.sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    token TEXT UNIQUE NOT NULL,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
  );`,
  
  // 7. Index sessions
  `CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions(user_id);`,
  `CREATE INDEX IF NOT EXISTS idx_sessions_token ON public.sessions(token);`,
  `CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON public.sessions(expires_at);`,
  
  // 8. Table activity_logs
  `CREATE TABLE IF NOT EXISTS public.activity_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    description TEXT,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
  );`,
  
  // 9. Index activity_logs
  `CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id ON public.activity_logs(user_id);`,
  `CREATE INDEX IF NOT EXISTS idx_activity_logs_created_at ON public.activity_logs(created_at DESC);`,
  
  // 10. Enable RLS
  `ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;`,
  `ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;`,
  `ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;`,
  
  // 11. Policies users
  `CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = auth_id);`,
  `CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = auth_id);`,
  
  // 12. Policies sessions
  `CREATE POLICY "Users can view own sessions" ON public.sessions
    FOR SELECT USING (user_id IN (
      SELECT id FROM public.users WHERE auth_id = auth.uid()
    ));`,
  
  // 13. Policies activity_logs
  `CREATE POLICY "Users can view own activity" ON public.activity_logs
    FOR SELECT USING (user_id IN (
      SELECT id FROM public.users WHERE auth_id = auth.uid()
    ));`,
  
  // 14. Function handle_new_user
  `CREATE OR REPLACE FUNCTION public.handle_new_user()
  RETURNS TRIGGER AS $$
  BEGIN
      INSERT INTO public.users (auth_id, email, company, first_name, last_name, accept_newsletter)
      VALUES (
          NEW.id,
          NEW.email,
          COALESCE(NEW.raw_user_meta_data->>'company', ''),
          COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
          COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
          COALESCE((NEW.raw_user_meta_data->>'accept_newsletter')::boolean, false)
      );
      RETURN NEW;
  END;
  $$ LANGUAGE plpgsql SECURITY DEFINER;`,
  
  // 15. Trigger on_auth_user_created
  `DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;`,
  `CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();`
];

async function executeMigration(sql, index) {
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ 
        query_text: sql 
      })
    });
    
    if (response.ok) {
      console.log(`✅ Migration ${index + 1}/${migrations.length} exécutée`);
      return true;
    } else {
      console.log(`⚠️ Migration ${index + 1} - Tentative alternative`);
      return false;
    }
  } catch (error) {
    console.log(`❌ Erreur migration ${index + 1}: ${error.message}`);
    return false;
  }
}

async function checkTables() {
  try {
    // Vérifier si les tables existent
    const tables = ['users', 'sessions', 'activity_logs'];
    
    for (const table of tables) {
      const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}?select=*&limit=1`, {
        method: 'GET',
        headers: {
          'apikey': SUPABASE_KEY,
          'Authorization': `Bearer ${SUPABASE_KEY}`
        }
      });
      
      if (response.ok) {
        console.log(`✅ Table '${table}' accessible`);
      } else if (response.status === 404 || response.status === 406) {
        console.log(`⚠️ Table '${table}' n'existe pas encore`);
      }
    }
  } catch (error) {
    console.log('Erreur vérification:', error);
  }
}

async function main() {
  console.log('🚀 Démarrage des migrations Supabase...\n');
  
  // Vérifier l'état avant
  console.log('📊 État initial des tables:');
  await checkTables();
  
  console.log('\n⚙️ Exécution des migrations...');
  
  let successCount = 0;
  for (let i = 0; i < migrations.length; i++) {
    const success = await executeMigration(migrations[i], i);
    if (success) successCount++;
    // Petite pause entre les requêtes
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  
  console.log(`\n📈 Résultat: ${successCount}/${migrations.length} migrations réussies`);
  
  // Vérifier l'état après
  console.log('\n📊 État final des tables:');
  await checkTables();
  
  console.log('\n✨ Migration terminée !');
  console.log('📝 Note: Si certaines migrations ont échoué, exécutez le script SQL complet dans le dashboard Supabase');
}

main().catch(console.error);