-- ============================================================
-- Migration: Ajout des types de comptes et système de permissions
-- Date: 2024
-- Description: Création de la structure pour gérer différents types de comptes
-- ============================================================

-- 1. Créer l'enum pour les types de comptes
CREATE TYPE account_type AS ENUM (
    'free',      -- Entreprise Free: accès basique
    'starter',   -- Entreprise Starter: fonctionnalités étendues
    'premium',   -- Entreprise Premium: accès presque complet
    'admin'      -- Admin: accès complet avec interface d'administration
);

-- 2. Créer l'enum pour les rôles utilisateurs
CREATE TYPE user_role AS ENUM (
    'owner',     -- Propriétaire de l'entreprise
    'admin',     -- Administrateur de l'entreprise
    'manager',   -- Manager avec permissions limitées
    'employee',  -- Employé avec accès basique
    'super_admin' -- Super admin système (pour vous)
);

-- 3. Ajouter les colonnes à la table users
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS account_type account_type DEFAULT 'free',
ADD COLUMN IF NOT EXISTS role user_role DEFAULT 'employee',
ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP,
ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP,
ADD COLUMN IF NOT EXISTS max_users INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS current_users INTEGER DEFAULT 1;

-- 4. Créer la table des fonctionnalités
CREATE TABLE IF NOT EXISTS features (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Créer la table des permissions par type de compte
CREATE TABLE IF NOT EXISTS account_permissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    account_type account_type NOT NULL,
    feature_id UUID REFERENCES features(id) ON DELETE CASCADE,
    is_enabled BOOLEAN DEFAULT false,
    limits JSONB, -- Pour stocker des limites spécifiques (ex: max 10 produits pour Free)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(account_type, feature_id)
);

-- 6. Créer la table des limites par type de compte
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

-- 7. Insérer les fonctionnalités de base
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
    ('team_management', 'Gestion d\'équipe', 'team'),
    ('custom_branding', 'Personnalisation de la marque', 'branding'),
    ('admin_panel', 'Panneau d\'administration', 'admin'),
    ('user_management', 'Gestion des utilisateurs', 'admin'),
    ('system_settings', 'Paramètres système', 'admin'),
    ('billing_management', 'Gestion de la facturation', 'billing')
ON CONFLICT (name) DO NOTHING;

-- 8. Définir les permissions par type de compte
-- FREE Account
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

-- STARTER Account
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

-- PREMIUM Account
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

-- ADMIN Account (accès complet)
INSERT INTO account_permissions (account_type, feature_id, is_enabled, limits)
SELECT 'admin', id, true, NULL
FROM features
ON CONFLICT (account_type, feature_id) DO NOTHING;

-- 9. Insérer les limites par type de compte
INSERT INTO account_limits (
    account_type, 
    max_products, 
    max_campaigns, 
    max_customers, 
    max_analytics_days,
    max_exports_per_month,
    max_api_calls_per_day,
    custom_branding,
    priority_support,
    advanced_analytics,
    api_access
) VALUES 
    ('free', 10, 1, 100, 7, 5, 0, false, false, false, false),
    ('starter', 50, 5, 500, 30, 20, 0, false, false, false, false),
    ('premium', 500, 50, 5000, 365, 100, 1000, true, true, true, true),
    ('admin', NULL, NULL, NULL, NULL, NULL, NULL, true, true, true, true)
ON CONFLICT (account_type) DO NOTHING;

-- 10. Créer une fonction pour vérifier les permissions
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

-- 11. Créer une vue pour les permissions utilisateur
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
JOIN account_permissions ap ON ap.account_type = u.account_type
JOIN features f ON f.id = ap.feature_id;

-- 12. Créer une table de logs pour les changements de plan
CREATE TABLE IF NOT EXISTS subscription_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    old_account_type account_type,
    new_account_type account_type,
    reason TEXT,
    changed_by UUID REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. Mettre à jour les utilisateurs existants
-- Mettre votre compte en admin
UPDATE users 
SET account_type = 'admin', role = 'super_admin'
WHERE email = 'ravinesiva@gmail.com';

-- Mettre les autres comptes existants en free par défaut
UPDATE users 
SET account_type = 'free', role = 'owner'
WHERE account_type IS NULL AND email != 'ravinesiva@gmail.com';

-- 14. Créer des index pour les performances
CREATE INDEX IF NOT EXISTS idx_users_account_type ON users(account_type);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_account_permissions_type ON account_permissions(account_type);
CREATE INDEX IF NOT EXISTS idx_subscription_logs_user ON subscription_logs(user_id);

-- 15. Ajouter des triggers pour l'audit
CREATE OR REPLACE FUNCTION log_subscription_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.account_type IS DISTINCT FROM NEW.account_type THEN
        INSERT INTO subscription_logs (user_id, old_account_type, new_account_type)
        VALUES (NEW.id, OLD.account_type, NEW.account_type);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_subscription_change
AFTER UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION log_subscription_change();

-- ============================================================
-- FIN DE LA MIGRATION
-- Pour exécuter : 
-- 1. Copier tout ce SQL
-- 2. Aller sur https://supabase.com/dashboard/project/sdbtjaxyhkicnucktkuj/sql/new
-- 3. Coller et exécuter
-- ============================================================