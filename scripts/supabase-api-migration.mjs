import fetch from 'node-fetch';

// Configuration
const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

console.log(`
🚀 MIGRATION SUPABASE VIA API MANAGEMENT
=======================================

Ce script va créer une fonction PL/pgSQL pour exécuter nos migrations
directement dans Supabase via l'API Management.

URL: ${SUPABASE_URL}
`);

async function createMigrationFunction() {
  console.log('📝 Création de la fonction de migration...\n');
  
  const migrationFunction = `
CREATE OR REPLACE FUNCTION execute_fidapp_migration()
RETURNS TEXT AS $$
DECLARE
  result_text TEXT := 'Migration FidApp commencée:\\n';
BEGIN
  -- 1. Ajouter la colonne birth_date
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'public' 
      AND table_name = 'users' 
      AND column_name = 'birth_date'
    ) THEN
      ALTER TABLE public.users ADD COLUMN birth_date DATE;
      result_text := result_text || '✅ Colonne birth_date ajoutée\\n';
    ELSE
      result_text := result_text || 'ℹ️ Colonne birth_date existe déjà\\n';
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result_text := result_text || '❌ Erreur birth_date: ' || SQLERRM || '\\n';
  END;

  -- 2. Créer l'enum account_type
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_type') THEN
      CREATE TYPE account_type AS ENUM ('free', 'starter', 'premium', 'admin');
      result_text := result_text || '✅ Type account_type créé\\n';
    ELSE
      result_text := result_text || 'ℹ️ Type account_type existe déjà\\n';
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result_text := result_text || '❌ Erreur account_type: ' || SQLERRM || '\\n';
  END;

  -- 3. Créer l'enum user_role
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
      CREATE TYPE user_role AS ENUM ('owner', 'admin', 'manager', 'employee', 'super_admin');
      result_text := result_text || '✅ Type user_role créé\\n';
    ELSE
      result_text := result_text || 'ℹ️ Type user_role existe déjà\\n';
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result_text := result_text || '❌ Erreur user_role: ' || SQLERRM || '\\n';
  END;

  -- 4. Ajouter la colonne account_type
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'account_type'
    ) THEN
      ALTER TABLE public.users ADD COLUMN account_type account_type DEFAULT 'free';
      result_text := result_text || '✅ Colonne account_type ajoutée\\n';
    ELSE
      result_text := result_text || 'ℹ️ Colonne account_type existe déjà\\n';
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result_text := result_text || '❌ Erreur colonne account_type: ' || SQLERRM || '\\n';
  END;

  -- 5. Ajouter la colonne role
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'role'
    ) THEN
      ALTER TABLE public.users ADD COLUMN role user_role DEFAULT 'employee';
      result_text := result_text || '✅ Colonne role ajoutée\\n';
    ELSE
      result_text := result_text || 'ℹ️ Colonne role existe déjà\\n';
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result_text := result_text || '❌ Erreur colonne role: ' || SQLERRM || '\\n';
  END;

  -- 6. Créer la table features
  BEGIN
    CREATE TABLE IF NOT EXISTS features (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      name VARCHAR(100) NOT NULL UNIQUE,
      description TEXT,
      category VARCHAR(50),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    result_text := result_text || '✅ Table features créée\\n';
  EXCEPTION WHEN OTHERS THEN
    result_text := result_text || '❌ Erreur table features: ' || SQLERRM || '\\n';
  END;

  -- 7. Insérer les features de base
  BEGIN
    INSERT INTO features (name, description, category) VALUES
    ('dashboard_view', 'Accès au tableau de bord', 'dashboard'),
    ('profile_edit', 'Modifier le profil', 'profile'),
    ('analytics_basic', 'Analytics de base', 'analytics'),
    ('analytics_advanced', 'Analytics avancées', 'analytics'),
    ('product_management', 'Gestion des produits', 'products'),
    ('admin_panel', 'Panneau d''administration', 'admin')
    ON CONFLICT (name) DO NOTHING;
    result_text := result_text || '✅ Features insérées\\n';
  EXCEPTION WHEN OTHERS THEN
    result_text := result_text || '❌ Erreur insertion features: ' || SQLERRM || '\\n';
  END;

  -- 8. Créer la table account_permissions
  BEGIN
    CREATE TABLE IF NOT EXISTS account_permissions (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      account_type account_type NOT NULL,
      feature_id UUID REFERENCES features(id) ON DELETE CASCADE,
      is_enabled BOOLEAN DEFAULT false,
      limits JSONB,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(account_type, feature_id)
    );
    result_text := result_text || '✅ Table account_permissions créée\\n';
  EXCEPTION WHEN OTHERS THEN
    result_text := result_text || '❌ Erreur table permissions: ' || SQLERRM || '\\n';
  END;

  -- 9. IMPORTANT: Mettre le compte ravinesiva@gmail.com en admin
  BEGIN
    UPDATE users 
    SET account_type = 'admin', role = 'super_admin'
    WHERE email = 'ravinesiva@gmail.com';
    
    IF FOUND THEN
      result_text := result_text || '✅ Compte ravinesiva@gmail.com mis en ADMIN\\n';
    ELSE
      result_text := result_text || '⚠️ Compte ravinesiva@gmail.com non trouvé\\n';
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result_text := result_text || '❌ Erreur mise à jour admin: ' || SQLERRM || '\\n';
  END;

  -- 10. Configurer les permissions admin
  BEGIN
    INSERT INTO account_permissions (account_type, feature_id, is_enabled)
    SELECT 'admin', id, true
    FROM features
    ON CONFLICT (account_type, feature_id) DO NOTHING;
    result_text := result_text || '✅ Permissions admin configurées\\n';
  EXCEPTION WHEN OTHERS THEN
    result_text := result_text || '❌ Erreur permissions admin: ' || SQLERRM || '\\n';
  END;

  -- 11. Ajouter des index
  BEGIN
    CREATE INDEX IF NOT EXISTS idx_users_account_type ON users(account_type);
    CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
    CREATE INDEX IF NOT EXISTS idx_users_birth_date ON users(birth_date);
    result_text := result_text || '✅ Index créés\\n';
  EXCEPTION WHEN OTHERS THEN
    result_text := result_text || '❌ Erreur index: ' || SQLERRM || '\\n';
  END;

  result_text := result_text || '\\n🎉 Migration FidApp terminée!';
  RETURN result_text;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
`;

  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/execute_sql`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SERVICE_KEY}`,
        'apikey': SERVICE_KEY
      },
      body: JSON.stringify({ 
        query: migrationFunction
      })
    });

    if (response.ok) {
      console.log('✅ Fonction de migration créée avec succès!');
      return true;
    } else {
      const errorText = await response.text();
      console.log('❌ Erreur création fonction:', response.status, errorText);
      return false;
    }
  } catch (error) {
    console.log('❌ Erreur réseau:', error.message);
    return false;
  }
}

async function executeMigrationFunction() {
  console.log('🚀 Exécution de la fonction de migration...\n');
  
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/execute_fidapp_migration`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SERVICE_KEY}`,
        'apikey': SERVICE_KEY
      },
      body: JSON.stringify({})
    });

    if (response.ok) {
      const result = await response.text();
      console.log('✅ Migration exécutée!');
      console.log('📊 Résultat:');
      console.log(result);
      return true;
    } else {
      const errorText = await response.text();
      console.log('❌ Erreur exécution:', response.status, errorText);
      return false;
    }
  } catch (error) {
    console.log('❌ Erreur réseau:', error.message);
    return false;
  }
}

async function createSimpleExecutionFunction() {
  console.log('📝 Création de fonction d\'exécution SQL simple...\n');
  
  const simpleFunction = `
CREATE OR REPLACE FUNCTION exec_migration_sql(sql_query TEXT)
RETURNS TEXT AS $$
BEGIN
  EXECUTE sql_query;
  RETURN 'SQL exécuté avec succès: ' || left(sql_query, 100) || '...';
EXCEPTION WHEN OTHERS THEN
  RETURN 'Erreur SQL: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
`;

  return await executeDirectSQL(simpleFunction);
}

async function executeDirectSQL(sql) {
  try {
    // Essayer avec l'endpoint SQL direct
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/exec`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SERVICE_KEY}`,
        'apikey': SERVICE_KEY,
        'Prefer': 'return=representation'
      },
      body: JSON.stringify({ query: sql })
    });

    if (response.ok) {
      const result = await response.json();
      return { success: true, data: result };
    } else {
      const errorText = await response.text();
      return { success: false, error: `${response.status}: ${errorText}` };
    }
  } catch (error) {
    return { success: false, error: error.message };
  }
}

async function tryManualExecution() {
  console.log('🔧 Tentative d\'exécution manuelle...\n');
  
  const queries = [
    `SELECT current_database(), version();`,
    `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' LIMIT 5;`,
    `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'users' LIMIT 10;`
  ];
  
  for (let i = 0; i < queries.length; i++) {
    console.log(`🔍 Test ${i + 1}/${queries.length}...`);
    const result = await executeDirectSQL(queries[i]);
    
    if (result.success) {
      console.log(`✅ Succès:`, result.data);
    } else {
      console.log(`❌ Échec:`, result.error);
    }
  }
}

async function showManualInstructions() {
  console.log(`
⚠️ MIGRATION AUTOMATIQUE ÉCHOUÉE - INSTRUCTIONS MANUELLES
=========================================================

Veuillez suivre ces étapes pour terminer la migration:

🔗 1. Allez sur le tableau de bord Supabase:
   https://supabase.com/dashboard/project/sdbtjaxyhkicnucktkuj/sql

📋 2. Copiez et exécutez ce SQL COMPLET dans l'éditeur SQL:

=== DÉBUT DU SQL ===
-- Migration FidApp - Exécution manuelle

-- 1. Ajouter la colonne birth_date
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS birth_date DATE;

-- 2. Créer les types enum
DO $$ 
BEGIN
  -- Type account_type
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_type') THEN
    CREATE TYPE account_type AS ENUM ('free', 'starter', 'premium', 'admin');
  END IF;
  
  -- Type user_role
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('owner', 'admin', 'manager', 'employee', 'super_admin');
  END IF;
END $$;

-- 3. Ajouter les colonnes de permissions
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS account_type account_type DEFAULT 'free';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS role user_role DEFAULT 'employee';

-- 4. Créer la table features
CREATE TABLE IF NOT EXISTS features (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  category VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Insérer les fonctionnalités de base
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

-- 6. Créer la table account_permissions
CREATE TABLE IF NOT EXISTS account_permissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  account_type account_type NOT NULL,
  feature_id UUID REFERENCES features(id) ON DELETE CASCADE,
  is_enabled BOOLEAN DEFAULT false,
  limits JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(account_type, feature_id)
);

-- 7. Créer la table account_limits
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

-- 8. Insérer les limites par type de compte
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

-- 9. TRÈS IMPORTANT: Mettre votre compte en ADMIN
UPDATE users 
SET account_type = 'admin', role = 'super_admin'
WHERE email = 'ravinesiva@gmail.com';

-- 10. Configurer les permissions pour tous les types de comptes
-- Permissions FREE
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

-- Permissions ADMIN (toutes activées)
INSERT INTO account_permissions (account_type, feature_id, is_enabled)
SELECT 'admin', id, true
FROM features
ON CONFLICT (account_type, feature_id) DO NOTHING;

-- 11. Créer des index pour les performances
CREATE INDEX IF NOT EXISTS idx_users_account_type ON users(account_type);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_birth_date ON users(birth_date);
CREATE INDEX IF NOT EXISTS idx_account_permissions_type ON account_permissions(account_type);

-- 12. Créer une vue pour faciliter les requêtes de permissions
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

-- 13. VÉRIFICATIONS FINALES --
-- Afficher votre compte
SELECT 'VOTRE COMPTE:' as info;
SELECT email, account_type, role, birth_date, created_at
FROM users
WHERE email = 'ravinesiva@gmail.com';

-- Afficher les nouvelles colonnes
SELECT 'NOUVELLES COLONNES:' as info;
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'users'
AND column_name IN ('birth_date', 'account_type', 'role');

-- Afficher les nouvelles tables
SELECT 'NOUVELLES TABLES:' as info;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('features', 'account_permissions', 'account_limits');

-- Compter les fonctionnalités
SELECT 'FONCTIONNALITÉS:' as info;
SELECT COUNT(*) as total_features FROM features;

-- Compter les permissions
SELECT 'PERMISSIONS CONFIGURÉES:' as info;
SELECT account_type, COUNT(*) as permissions_count
FROM account_permissions 
GROUP BY account_type 
ORDER BY account_type;

=== FIN DU SQL ===

✅ 3. Cliquez sur "RUN" pour exécuter

✅ 4. Vérifiez que vous voyez:
   - Votre compte avec account_type = 'admin' et role = 'super_admin'
   - Les nouvelles colonnes listées
   - Les nouvelles tables créées
   - Le nombre de fonctionnalités et permissions

🎉 5. Si tout s'affiche correctement, la migration est RÉUSSIE!

Si vous rencontrez des erreurs, copiez-les et je vous aiderai à les résoudre.
`);
}

// FONCTION PRINCIPALE
async function main() {
  console.log('🚀 DÉMARRAGE DE LA MIGRATION API...\n');
  
  // Test 1: Essayer les fonctions RPC
  console.log('🔧 Test 1: Création et exécution via RPC...');
  const funcCreated = await createMigrationFunction();
  
  if (funcCreated) {
    const migrationSuccess = await executeMigrationFunction();
    if (migrationSuccess) {
      console.log('\n🎉 MIGRATION RÉUSSIE VIA RPC!');
      return;
    }
  }
  
  // Test 2: Essayer fonction simple
  console.log('\n🔧 Test 2: Fonction d\'exécution simple...');
  const simpleFunc = await createSimpleExecutionFunction();
  if (simpleFunc.success) {
    console.log('✅ Fonction simple créée');
  }
  
  // Test 3: Tests manuels
  console.log('\n🔧 Test 3: Tests de connectivité...');
  await tryManualExecution();
  
  // Instructions manuelles
  console.log('\n📋 Affichage des instructions manuelles...');
  await showManualInstructions();
}

// Exécuter
await main();