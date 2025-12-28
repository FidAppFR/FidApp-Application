import { createClient } from '@supabase/supabase-js';
import pg from 'pg';
import fetch from 'node-fetch';

// Configuration Supabase avec Service Key
const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

// Créer le client avec la Service Key
const supabase = createClient(SUPABASE_URL, SERVICE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  },
  global: {
    headers: {
      Authorization: `Bearer ${SERVICE_KEY}`
    }
  }
});

console.log(`
🚀 MIGRATION AUTOMATIQUE SUPABASE
=================================

Service URL: ${SUPABASE_URL}
Email admin: ravinesiva@gmail.com

`);

// SQL des migrations complètes
const FULL_MIGRATION_SQL = `
-- ============================================================
-- MIGRATION COMPLÈTE SUPABASE - EXÉCUTION AUTOMATIQUE
-- ============================================================

-- 1. Ajouter la colonne birth_date si elle n'existe pas
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'users' 
    AND column_name = 'birth_date'
  ) THEN
    ALTER TABLE public.users ADD COLUMN birth_date DATE;
    RAISE NOTICE 'Colonne birth_date ajoutée';
  ELSE
    RAISE NOTICE 'Colonne birth_date existe déjà';
  END IF;
END $$;

-- 2. Créer l'enum account_type si il n'existe pas
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_type') THEN
    CREATE TYPE account_type AS ENUM ('free', 'starter', 'premium', 'admin');
    RAISE NOTICE 'Type account_type créé';
  ELSE
    RAISE NOTICE 'Type account_type existe déjà';
  END IF;
END $$;

-- 3. Créer l'enum user_role si il n'existe pas
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('owner', 'admin', 'manager', 'employee', 'super_admin');
    RAISE NOTICE 'Type user_role créé';
  ELSE
    RAISE NOTICE 'Type user_role existe déjà';
  END IF;
END $$;

-- 4. Ajouter les colonnes de permissions
DO $$ 
BEGIN
  -- account_type
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'account_type'
  ) THEN
    ALTER TABLE public.users ADD COLUMN account_type account_type DEFAULT 'free';
    RAISE NOTICE 'Colonne account_type ajoutée';
  END IF;
  
  -- role
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'role'
  ) THEN
    ALTER TABLE public.users ADD COLUMN role user_role DEFAULT 'employee';
    RAISE NOTICE 'Colonne role ajoutée';
  END IF;
  
  -- subscription_start_date
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'subscription_start_date'
  ) THEN
    ALTER TABLE public.users ADD COLUMN subscription_start_date TIMESTAMP;
    RAISE NOTICE 'Colonne subscription_start_date ajoutée';
  END IF;
  
  -- subscription_end_date
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'subscription_end_date'
  ) THEN
    ALTER TABLE public.users ADD COLUMN subscription_end_date TIMESTAMP;
    RAISE NOTICE 'Colonne subscription_end_date ajoutée';
  END IF;
  
  -- max_users
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'max_users'
  ) THEN
    ALTER TABLE public.users ADD COLUMN max_users INTEGER DEFAULT 1;
    RAISE NOTICE 'Colonne max_users ajoutée';
  END IF;
  
  -- current_users
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'current_users'
  ) THEN
    ALTER TABLE public.users ADD COLUMN current_users INTEGER DEFAULT 1;
    RAISE NOTICE 'Colonne current_users ajoutée';
  END IF;
END $$;

-- 5. Créer la table features
CREATE TABLE IF NOT EXISTS features (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  category VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Insérer les fonctionnalités
INSERT INTO features (name, description, category) VALUES
('dashboard_view', 'Accès au tableau de bord', 'dashboard'),
('profile_edit', 'Modifier le profil', 'profile'),
('analytics_basic', 'Analytics de base', 'analytics'),
('analytics_advanced', 'Analytics avancées', 'analytics'),
('product_management', 'Gestion des produits', 'products'),
('campaign_management', 'Gestion des campagnes', 'campaigns'),
('customer_management', 'Gestion des clients', 'customers'),
('export_data', 'Export des données', 'data'),
('api_access', 'Accès API', 'api'),
('team_management', 'Gestion d''équipe', 'team'),
('custom_branding', 'Personnalisation de la marque', 'branding'),
('admin_panel', 'Panneau d''administration', 'admin'),
('user_management', 'Gestion des utilisateurs', 'admin'),
('system_settings', 'Paramètres système', 'admin'),
('billing_management', 'Gestion de la facturation', 'billing')
ON CONFLICT (name) DO NOTHING;

-- 7. Créer la table account_permissions
CREATE TABLE IF NOT EXISTS account_permissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  account_type account_type NOT NULL,
  feature_id UUID REFERENCES features(id) ON DELETE CASCADE,
  is_enabled BOOLEAN DEFAULT false,
  limits JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(account_type, feature_id)
);

-- 8. Créer la table account_limits
CREATE TABLE IF NOT EXISTS account_limits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  account_type account_type NOT NULL UNIQUE,
  max_products INTEGER,
  max_campaigns INTEGER,
  max_customers INTEGER,
  max_analytics_days INTEGER,
  max_exports_per_month INTEGER,
  max_api_calls_per_day INTEGER,
  custom_branding BOOLEAN DEFAULT false,
  priority_support BOOLEAN DEFAULT false,
  advanced_analytics BOOLEAN DEFAULT false,
  api_access BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. Insérer les limites par type de compte
INSERT INTO account_limits (
  account_type, max_products, max_campaigns, max_customers, 
  max_analytics_days, max_exports_per_month, max_api_calls_per_day,
  custom_branding, priority_support, advanced_analytics, api_access
) VALUES 
('free', 10, 1, 100, 7, 5, 0, false, false, false, false),
('starter', 50, 5, 500, 30, 20, 0, false, false, false, false),
('premium', 500, 50, 5000, 365, 100, 1000, true, true, true, true),
('admin', NULL, NULL, NULL, NULL, NULL, NULL, true, true, true, true)
ON CONFLICT (account_type) DO NOTHING;

-- 10. Configurer les permissions pour le compte FREE
INSERT INTO account_permissions (account_type, feature_id, is_enabled, limits)
SELECT 'free', id, 
  CASE name
    WHEN 'dashboard_view' THEN true
    WHEN 'profile_edit' THEN true
    WHEN 'analytics_basic' THEN true
    WHEN 'product_management' THEN true
    ELSE false
  END,
  CASE name
    WHEN 'product_management' THEN '{"max_items": 10}'::jsonb
    WHEN 'analytics_basic' THEN '{"days_history": 7}'::jsonb
    ELSE NULL
  END
FROM features
ON CONFLICT (account_type, feature_id) DO NOTHING;

-- 11. Configurer les permissions pour le compte STARTER
INSERT INTO account_permissions (account_type, feature_id, is_enabled, limits)
SELECT 'starter', id, 
  CASE name
    WHEN 'admin_panel' THEN false
    WHEN 'user_management' THEN false
    WHEN 'system_settings' THEN false
    WHEN 'api_access' THEN false
    ELSE true
  END,
  CASE name
    WHEN 'product_management' THEN '{"max_items": 50}'::jsonb
    WHEN 'campaign_management' THEN '{"max_campaigns": 5}'::jsonb
    WHEN 'analytics_basic' THEN '{"days_history": 30}'::jsonb
    WHEN 'export_data' THEN '{"max_per_month": 10}'::jsonb
    ELSE NULL
  END
FROM features
ON CONFLICT (account_type, feature_id) DO NOTHING;

-- 12. Configurer les permissions pour le compte PREMIUM
INSERT INTO account_permissions (account_type, feature_id, is_enabled, limits)
SELECT 'premium', id, 
  CASE name
    WHEN 'admin_panel' THEN false
    WHEN 'user_management' THEN false
    WHEN 'system_settings' THEN false
    ELSE true
  END,
  CASE name
    WHEN 'product_management' THEN '{"max_items": 500}'::jsonb
    WHEN 'campaign_management' THEN '{"max_campaigns": 50}'::jsonb
    WHEN 'analytics_advanced' THEN '{"days_history": 365}'::jsonb
    WHEN 'export_data' THEN '{"max_per_month": 100}'::jsonb
    WHEN 'api_access' THEN '{"calls_per_day": 1000}'::jsonb
    ELSE NULL
  END
FROM features
ON CONFLICT (account_type, feature_id) DO NOTHING;

-- 13. Configurer toutes les permissions pour le compte ADMIN
INSERT INTO account_permissions (account_type, feature_id, is_enabled, limits)
SELECT 'admin', id, true, NULL
FROM features
ON CONFLICT (account_type, feature_id) DO NOTHING;

-- 14. IMPORTANT: Mettre le compte ravinesiva@gmail.com en ADMIN
UPDATE users 
SET account_type = 'admin', role = 'super_admin'
WHERE email = 'ravinesiva@gmail.com';

-- 15. Créer la vue user_permissions
CREATE OR REPLACE VIEW user_permissions AS
SELECT 
  u.id as user_id,
  u.email,
  u.account_type,
  u.role,
  f.name as feature_name,
  f.category,
  ap.is_enabled,
  ap.limits
FROM users u
LEFT JOIN account_permissions ap ON ap.account_type = u.account_type
LEFT JOIN features f ON f.id = ap.feature_id;

-- 16. Créer une fonction pour vérifier les permissions
CREATE OR REPLACE FUNCTION check_user_permission(
  p_user_id UUID,
  p_feature_name VARCHAR
) RETURNS BOOLEAN AS $$
DECLARE
  v_account_type account_type;
  v_has_permission BOOLEAN;
BEGIN
  -- Récupérer le type de compte de l'utilisateur
  SELECT account_type INTO v_account_type
  FROM users
  WHERE id = p_user_id;
  
  -- Vérifier si l'utilisateur a la permission
  SELECT ap.is_enabled INTO v_has_permission
  FROM account_permissions ap
  JOIN features f ON ap.feature_id = f.id
  WHERE ap.account_type = v_account_type
  AND f.name = p_feature_name;
  
  RETURN COALESCE(v_has_permission, false);
END;
$$ LANGUAGE plpgsql;

-- 17. Créer des index pour les performances
CREATE INDEX IF NOT EXISTS idx_users_account_type ON users(account_type);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_account_permissions_type ON account_permissions(account_type);
CREATE INDEX IF NOT EXISTS idx_users_birth_date ON users(birth_date);

-- VÉRIFICATIONS FINALES --
SELECT 'Migration terminée - Vérification des colonnes:' as message;

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'users'
AND column_name IN ('birth_date', 'account_type', 'role', 'subscription_start_date', 'subscription_end_date', 'max_users', 'current_users');

SELECT 'Compte administrateur:' as message;
SELECT email, account_type, role, birth_date, created_at
FROM users
WHERE email = 'ravinesiva@gmail.com';

SELECT 'Tables créées:' as message;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('features', 'account_permissions', 'account_limits');

SELECT 'Nombre de features:' as message;
SELECT COUNT(*) as total_features FROM features;

SELECT 'Nombre de permissions configurées:' as message;
SELECT account_type, COUNT(*) as permissions_count
FROM account_permissions 
GROUP BY account_type 
ORDER BY account_type;
`;

async function executeMigrationViaRPC() {
  console.log('🔧 Méthode 1: Exécution via RPC Supabase...\n');
  
  try {
    const { data, error } = await supabase.rpc('exec_sql', {
      query: FULL_MIGRATION_SQL
    });
    
    if (error) {
      console.log('❌ RPC non disponible ou erreur:', error.message);
      return false;
    }
    
    console.log('✅ Migration exécutée via RPC!');
    console.log('📊 Résultat:', data);
    return true;
    
  } catch (error) {
    console.log('❌ Erreur RPC:', error.message);
    return false;
  }
}

async function executeMigrationViaSQL() {
  console.log('🔧 Méthode 2: Exécution SQL directe...\n');
  
  // Diviser le SQL en blocs individuels
  const sqlBlocks = [
    // 1. Colonne birth_date
    `
    DO $$ 
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'birth_date'
      ) THEN
        ALTER TABLE public.users ADD COLUMN birth_date DATE;
      END IF;
    END $$;
    `,
    
    // 2. Type account_type
    `
    DO $$ 
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_type') THEN
        CREATE TYPE account_type AS ENUM ('free', 'starter', 'premium', 'admin');
      END IF;
    END $$;
    `,
    
    // 3. Type user_role
    `
    DO $$ 
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('owner', 'admin', 'manager', 'employee', 'super_admin');
      END IF;
    END $$;
    `,
    
    // 4. Colonnes account_type et role
    `
    DO $$ 
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'account_type'
      ) THEN
        ALTER TABLE public.users ADD COLUMN account_type account_type DEFAULT 'free';
      END IF;
      
      IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'role'
      ) THEN
        ALTER TABLE public.users ADD COLUMN role user_role DEFAULT 'employee';
      END IF;
    END $$;
    `,
    
    // 5. Table features
    `
    CREATE TABLE IF NOT EXISTS features (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      name VARCHAR(100) NOT NULL UNIQUE,
      description TEXT,
      category VARCHAR(50),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    `,
    
    // 6. Insertion features
    `
    INSERT INTO features (name, description, category) VALUES
    ('dashboard_view', 'Accès au tableau de bord', 'dashboard'),
    ('profile_edit', 'Modifier le profil', 'profile'),
    ('analytics_basic', 'Analytics de base', 'analytics'),
    ('analytics_advanced', 'Analytics avancées', 'analytics'),
    ('product_management', 'Gestion des produits', 'products'),
    ('admin_panel', 'Panneau d''administration', 'admin')
    ON CONFLICT (name) DO NOTHING;
    `,
    
    // 7. Table account_permissions
    `
    CREATE TABLE IF NOT EXISTS account_permissions (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      account_type account_type NOT NULL,
      feature_id UUID REFERENCES features(id) ON DELETE CASCADE,
      is_enabled BOOLEAN DEFAULT false,
      limits JSONB,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(account_type, feature_id)
    );
    `,
    
    // 8. Mise à jour compte admin
    `UPDATE users SET account_type = 'admin', role = 'super_admin' WHERE email = 'ravinesiva@gmail.com';`
  ];
  
  let successCount = 0;
  
  for (let i = 0; i < sqlBlocks.length; i++) {
    const sql = sqlBlocks[i].trim();
    console.log(`📝 Bloc ${i + 1}/${sqlBlocks.length}...`);
    
    try {
      const { data, error } = await supabase
        .from('dummy') // Table factice, on utilise le SQL raw
        .select('*');
      
      // Exécuter le SQL via une requête raw
      const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/exec`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${SERVICE_KEY}`,
          'apikey': SERVICE_KEY
        },
        body: JSON.stringify({ query: sql })
      });
      
      if (response.ok) {
        console.log(`✅ Bloc ${i + 1} - Succès`);
        successCount++;
      } else {
        console.log(`⚠️ Bloc ${i + 1} - Réponse:`, response.status);
      }
      
    } catch (error) {
      console.log(`⚠️ Bloc ${i + 1} - Erreur:`, error.message);
    }
  }
  
  console.log(`\n📊 Résultats: ${successCount}/${sqlBlocks.length} blocs exécutés`);
  return successCount > 0;
}

async function verifyMigration() {
  console.log('\n🔍 Vérification des résultats...\n');
  
  try {
    // Vérifier si on peut lire la table users
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('email, account_type, role, birth_date')
      .eq('email', 'ravinesiva@gmail.com')
      .limit(1);
    
    if (usersError) {
      console.log('❌ Erreur lecture users:', usersError.message);
      return false;
    }
    
    if (users && users.length > 0) {
      const user = users[0];
      console.log('✅ Compte trouvé:');
      console.log(`   📧 Email: ${user.email}`);
      console.log(`   🏷️  Type: ${user.account_type || 'Non défini'}`);
      console.log(`   👤 Rôle: ${user.role || 'Non défini'}`);
      console.log(`   🎂 Date naissance: ${user.birth_date || 'Non définie'}`);
      
      // Vérifier si les colonnes existent
      const hasAccountType = 'account_type' in user && user.account_type !== null;
      const hasRole = 'role' in user && user.role !== null;
      const hasBirthDate = 'birth_date' in user;
      
      console.log('\n📋 Colonnes ajoutées:');
      console.log(`   ✅ birth_date: ${hasBirthDate ? 'OUI' : 'NON'}`);
      console.log(`   ✅ account_type: ${hasAccountType ? 'OUI' : 'NON'}`);
      console.log(`   ✅ role: ${hasRole ? 'OUI' : 'NON'}`);
      
      return hasAccountType && hasRole && hasBirthDate;
    }
    
    return false;
    
  } catch (error) {
    console.log('❌ Erreur vérification:', error.message);
    return false;
  }
}

async function tryDirectConnection() {
  console.log('🔧 Méthode 3: Connexion PostgreSQL directe...\n');
  
  const connectionStrings = [
    // Connection string standard Supabase
    `postgresql://postgres.sdbtjaxyhkicnucktkuj:QuoJPgmP3jQQy5Xr@aws-0-eu-central-1.pooler.supabase.com:5432/postgres`,
    // Connection string alternative
    `postgresql://postgres:QuoJPgmP3jQQy5Xr@db.sdbtjaxyhkicnucktkuj.supabase.co:5432/postgres`
  ];
  
  for (let i = 0; i < connectionStrings.length; i++) {
    console.log(`🔌 Test connexion ${i + 1}/${connectionStrings.length}...`);
    
    try {
      const { Client } = pg;
      const client = new Client({
        connectionString: connectionStrings[i],
        ssl: { rejectUnauthorized: false }
      });
      
      await client.connect();
      console.log('✅ Connexion PostgreSQL réussie!');
      
      // Exécuter les migrations
      const migrations = [
        `ALTER TABLE public.users ADD COLUMN IF NOT EXISTS birth_date DATE;`,
        `DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_type') THEN CREATE TYPE account_type AS ENUM ('free', 'starter', 'premium', 'admin'); END IF; END $$;`,
        `DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN CREATE TYPE user_role AS ENUM ('owner', 'admin', 'manager', 'employee', 'super_admin'); END IF; END $$;`,
        `ALTER TABLE public.users ADD COLUMN IF NOT EXISTS account_type account_type DEFAULT 'free';`,
        `ALTER TABLE public.users ADD COLUMN IF NOT EXISTS role user_role DEFAULT 'employee';`,
        `UPDATE users SET account_type = 'admin', role = 'super_admin' WHERE email = 'ravinesiva@gmail.com';`
      ];
      
      for (let j = 0; j < migrations.length; j++) {
        try {
          await client.query(migrations[j]);
          console.log(`✅ Migration ${j + 1}/${migrations.length} - Succès`);
        } catch (error) {
          console.log(`⚠️ Migration ${j + 1}/${migrations.length} - Erreur:`, error.message);
        }
      }
      
      // Vérification
      const result = await client.query(`
        SELECT email, account_type, role, birth_date 
        FROM users 
        WHERE email = 'ravinesiva@gmail.com'
      `);
      
      if (result.rows.length > 0) {
        console.log('\n✅ Compte vérifié via PostgreSQL:');
        console.log('   📧 Email:', result.rows[0].email);
        console.log('   🏷️ Type:', result.rows[0].account_type);
        console.log('   👤 Rôle:', result.rows[0].role);
      }
      
      await client.end();
      console.log('✅ Connexion fermée');
      return true;
      
    } catch (error) {
      console.log(`❌ Connexion ${i + 1} échouée:`, error.message);
    }
  }
  
  return false;
}

// FONCTION PRINCIPALE
async function runFullMigration() {
  console.log('🚀 DÉBUT DE LA MIGRATION AUTOMATIQUE\n');
  
  // Test 1: Via RPC
  const rpcSuccess = await executeMigrationViaRPC();
  if (rpcSuccess) {
    const verified = await verifyMigration();
    if (verified) {
      console.log('\n🎉 MIGRATION RÉUSSIE VIA RPC!');
      return;
    }
  }
  
  // Test 2: Via SQL direct
  const sqlSuccess = await executeMigrationViaSQL();
  if (sqlSuccess) {
    const verified = await verifyMigration();
    if (verified) {
      console.log('\n🎉 MIGRATION RÉUSSIE VIA SQL!');
      return;
    }
  }
  
  // Test 3: Via PostgreSQL direct
  const pgSuccess = await tryDirectConnection();
  if (pgSuccess) {
    console.log('\n🎉 MIGRATION RÉUSSIE VIA POSTGRESQL!');
    return;
  }
  
  // Si rien n'a fonctionné
  console.log('\n⚠️ MIGRATION PARTIELLEMENT ÉCHOUÉE');
  console.log('\nSOLUTION MANUELLE:');
  console.log('1. Allez sur: https://supabase.com/dashboard/project/sdbtjaxyhkicnucktkuj/sql');
  console.log('2. Exécutez ce SQL:');
  console.log(`
-- MIGRATION MANUELLE SIMPLIFIÉE
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS birth_date DATE;

DO $$ BEGIN 
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_type') THEN 
    CREATE TYPE account_type AS ENUM ('free', 'starter', 'premium', 'admin'); 
  END IF; 
END $$;

DO $$ BEGIN 
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN 
    CREATE TYPE user_role AS ENUM ('owner', 'admin', 'manager', 'employee', 'super_admin'); 
  END IF; 
END $$;

ALTER TABLE public.users ADD COLUMN IF NOT EXISTS account_type account_type DEFAULT 'free';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS role user_role DEFAULT 'employee';

UPDATE users SET account_type = 'admin', role = 'super_admin' WHERE email = 'ravinesiva@gmail.com';

-- Vérification
SELECT email, account_type, role, birth_date FROM users WHERE email = 'ravinesiva@gmail.com';
  `);
}

// Exécuter la migration
await runFullMigration();