import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

console.log(`
⚠️  MIGRATION IMPORTANTE - ACTION REQUISE
=========================================

Vous DEVEZ exécuter ces migrations SQL manuellement dans Supabase:

1. 🔗 Cliquez sur ce lien pour ouvrir l'éditeur SQL:
   https://supabase.com/dashboard/project/sdbtjaxyhkicnucktkuj/sql/new

2. 📋 Copiez et collez CE CODE SQL COMPLET:

==============================================================
-- MIGRATION 1: Ajouter la colonne birth_date
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS birth_date DATE;

-- MIGRATION 2: Créer les types enum
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_type') THEN
    CREATE TYPE account_type AS ENUM ('free', 'starter', 'premium', 'admin');
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('owner', 'admin', 'manager', 'employee', 'super_admin');
  END IF;
END $$;

-- MIGRATION 3: Ajouter les colonnes de permissions
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS account_type account_type DEFAULT 'free',
ADD COLUMN IF NOT EXISTS role user_role DEFAULT 'employee',
ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP,
ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP,
ADD COLUMN IF NOT EXISTS max_users INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS current_users INTEGER DEFAULT 1;

-- MIGRATION 4: Créer la table features
CREATE TABLE IF NOT EXISTS features (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  category VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- MIGRATION 5: Insérer les features
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

-- MIGRATION 6: Créer la table account_permissions
CREATE TABLE IF NOT EXISTS account_permissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  account_type account_type NOT NULL,
  feature_id UUID REFERENCES features(id) ON DELETE CASCADE,
  is_enabled BOOLEAN DEFAULT false,
  limits JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(account_type, feature_id)
);

-- MIGRATION 7: Créer la table account_limits
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

-- MIGRATION 8: Insérer les limites
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

-- MIGRATION 9: Créer la vue user_permissions
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

-- MIGRATION 10: Mettre votre compte en admin
UPDATE users 
SET account_type = 'admin', role = 'super_admin'
WHERE email = 'ravinesiva@gmail.com';

-- MIGRATION 11: Configurer les permissions FREE
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

-- MIGRATION 12: Configurer les permissions ADMIN
INSERT INTO account_permissions (account_type, feature_id, is_enabled, limits)
SELECT 'admin', id, true, NULL
FROM features
ON CONFLICT (account_type, feature_id) DO NOTHING;

-- VÉRIFICATION: Afficher votre compte
SELECT email, account_type, role, birth_date
FROM users
WHERE email = 'ravinesiva@gmail.com';

-- VÉRIFICATION: Afficher les colonnes de la table users
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'users';
==============================================================

3. 🚀 Cliquez sur "RUN" pour exécuter

4. ✅ Vous devriez voir:
   - Votre compte avec account_type = 'admin'
   - La liste des colonnes incluant birth_date, account_type, role

`);

// Vérifier l'état actuel
async function checkCurrentState() {
  console.log('\n📊 Vérification de l\'état actuel...\n');
  
  try {
    // Tester la connexion
    const { data: testData, error: testError } = await supabase
      .from('users')
      .select('*')
      .limit(1);
    
    if (testError) {
      console.log('❌ Erreur de connexion:', testError.message);
      return;
    }
    
    console.log('✅ Connexion à Supabase réussie');
    
    // Vérifier les colonnes existantes
    if (testData && testData.length > 0) {
      const columns = Object.keys(testData[0]);
      console.log('\n📋 Colonnes actuelles dans la table users:');
      
      const requiredColumns = ['birth_date', 'account_type', 'role'];
      requiredColumns.forEach(col => {
        if (columns.includes(col)) {
          console.log(`✅ ${col} existe`);
        } else {
          console.log(`❌ ${col} MANQUANT - Migration requise!`);
        }
      });
      
      // Vérifier votre compte
      const { data: yourAccount } = await supabase
        .from('users')
        .select('email, account_type, role')
        .eq('email', 'ravinesiva@gmail.com')
        .single();
      
      if (yourAccount) {
        console.log('\n👤 Votre compte:');
        console.log('   Email:', yourAccount.email);
        if ('account_type' in yourAccount) {
          console.log('   Type de compte:', yourAccount.account_type || '❌ Non défini');
        }
        if ('role' in yourAccount) {
          console.log('   Rôle:', yourAccount.role || '❌ Non défini');
        }
      }
    }
    
  } catch (error) {
    console.log('❌ Erreur:', error.message);
  }
}

// Exécuter la vérification
await checkCurrentState();

console.log('\n' + '='.repeat(60));
console.log('👆 SUIVEZ LES INSTRUCTIONS CI-DESSUS POUR TERMINER LA MIGRATION');
console.log('='.repeat(60) + '\n');