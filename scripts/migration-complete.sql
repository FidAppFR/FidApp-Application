-- ============================================================
-- MIGRATION COMPLÈTE FIDAPP - SUPABASE
-- Date: 2025-11-27
-- Description: Migration pour ajouter birth_date, account_type, role et système de permissions
-- Email admin: ravinesiva@gmail.com
-- ============================================================

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
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS max_users INTEGER DEFAULT 1;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS current_users INTEGER DEFAULT 1;

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

-- Permissions FREE (accès limité)
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

-- Permissions STARTER (accès étendu)
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
    WHEN 'export_data' THEN '{"max_per_month": 20}'::jsonb
    ELSE NULL
  END
FROM features
ON CONFLICT (account_type, feature_id) DO NOTHING;

-- Permissions PREMIUM (accès presque complet)
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

-- Permissions ADMIN (accès complet)
INSERT INTO account_permissions (account_type, feature_id, is_enabled)
SELECT 'admin', id, true
FROM features
ON CONFLICT (account_type, feature_id) DO NOTHING;

-- 11. Créer des index pour les performances
CREATE INDEX IF NOT EXISTS idx_users_account_type ON users(account_type);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_birth_date ON users(birth_date);
CREATE INDEX IF NOT EXISTS idx_account_permissions_type ON account_permissions(account_type);
CREATE INDEX IF NOT EXISTS idx_features_category ON features(category);
CREATE INDEX IF NOT EXISTS idx_account_limits_type ON account_limits(account_type);

-- 12. Créer une vue pour faciliter les requêtes de permissions
CREATE OR REPLACE VIEW user_permissions AS
SELECT 
  u.id as user_id,
  u.email,
  u.first_name,
  u.last_name,
  u.company,
  u.account_type,
  u.role,
  u.subscription_start_date,
  u.subscription_end_date,
  f.name as feature_name,
  f.description as feature_description,
  f.category as feature_category,
  ap.is_enabled,
  ap.limits
FROM users u
LEFT JOIN account_permissions ap ON ap.account_type = u.account_type
LEFT JOIN features f ON f.id = ap.feature_id;

-- 13. Créer une fonction pour vérifier les permissions utilisateur
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
  
  -- Si pas d'utilisateur trouvé
  IF v_account_type IS NULL THEN
    RETURN false;
  END IF;
  
  -- Vérifier si l'utilisateur a la permission
  SELECT ap.is_enabled INTO v_has_permission
  FROM account_permissions ap
  JOIN features f ON ap.feature_id = f.id
  WHERE ap.account_type = v_account_type
  AND f.name = p_feature_name;
  
  RETURN COALESCE(v_has_permission, false);
END;
$$ LANGUAGE plpgsql;

-- 14. Créer une fonction pour obtenir les limites utilisateur
CREATE OR REPLACE FUNCTION get_user_limits(p_user_id UUID)
RETURNS TABLE(
  feature_name VARCHAR,
  limits JSONB,
  account_type account_type
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.name,
    ap.limits,
    u.account_type
  FROM users u
  JOIN account_permissions ap ON ap.account_type = u.account_type
  JOIN features f ON f.id = ap.feature_id
  WHERE u.id = p_user_id
  AND ap.is_enabled = true
  AND ap.limits IS NOT NULL;
END;
$$ LANGUAGE plpgsql;

-- 15. Créer une table pour logger les changements de plan
CREATE TABLE IF NOT EXISTS subscription_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  old_account_type account_type,
  new_account_type account_type,
  reason TEXT,
  changed_by UUID REFERENCES users(id),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 16. Créer un trigger pour logger les changements de plan
CREATE OR REPLACE FUNCTION log_account_type_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.account_type IS DISTINCT FROM NEW.account_type THEN
    INSERT INTO subscription_logs (user_id, old_account_type, new_account_type, reason)
    VALUES (NEW.id, OLD.account_type, NEW.account_type, 'Account type changed');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_account_change
AFTER UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION log_account_type_change();

-- ============================================================
-- VÉRIFICATIONS FINALES
-- ============================================================

-- Afficher votre compte
SELECT 'VOTRE COMPTE:' as info;
SELECT 
  email, 
  account_type, 
  role, 
  birth_date, 
  subscription_start_date,
  created_at
FROM users
WHERE email = 'ravinesiva@gmail.com';

-- Afficher les nouvelles colonnes
SELECT 'NOUVELLES COLONNES:' as info;
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'users'
AND column_name IN ('birth_date', 'account_type', 'role', 'subscription_start_date', 'subscription_end_date', 'max_users', 'current_users')
ORDER BY column_name;

-- Afficher les nouvelles tables
SELECT 'NOUVELLES TABLES:' as info;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('features', 'account_permissions', 'account_limits', 'subscription_logs')
ORDER BY table_name;

-- Compter les fonctionnalités
SELECT 'FONCTIONNALITÉS:' as info;
SELECT COUNT(*) as total_features FROM features;

-- Afficher toutes les features
SELECT 'LISTE DES FEATURES:' as info;
SELECT name, category, description FROM features ORDER BY category, name;

-- Compter les permissions par type
SELECT 'PERMISSIONS PAR TYPE:' as info;
SELECT 
  account_type, 
  COUNT(*) as total_permissions,
  COUNT(CASE WHEN is_enabled THEN 1 END) as enabled_permissions
FROM account_permissions 
GROUP BY account_type 
ORDER BY account_type;

-- Afficher les limites par type
SELECT 'LIMITES PAR TYPE:' as info;
SELECT * FROM account_limits ORDER BY account_type;

-- Vérifier les permissions de l'admin
SELECT 'PERMISSIONS ADMIN:' as info;
SELECT 
  f.name as feature,
  f.category,
  ap.is_enabled
FROM account_permissions ap
JOIN features f ON f.id = ap.feature_id
WHERE ap.account_type = 'admin'
ORDER BY f.category, f.name;

-- Test des fonctions
SELECT 'TEST PERMISSION FONCTION:' as info;
SELECT check_user_permission(
  (SELECT id FROM users WHERE email = 'ravinesiva@gmail.com'),
  'admin_panel'
) as has_admin_panel;

SELECT 'MIGRATION TERMINÉE AVEC SUCCÈS!' as status;

-- ============================================================
-- FIN DE LA MIGRATION
-- 
-- RÉSULTATS ATTENDUS:
-- - Colonne birth_date ajoutée
-- - Types account_type et user_role créés
-- - Colonnes account_type, role ajoutées
-- - Tables features, account_permissions, account_limits créées
-- - Votre compte mis en admin/super_admin
-- - Permissions configurées pour tous les types
-- - Index et vues créés
-- - Fonctions utilitaires disponibles
-- ============================================================