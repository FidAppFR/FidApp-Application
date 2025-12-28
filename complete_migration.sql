-- ========================================================
-- SCRIPT COMPLET DE MIGRATION POUR FIDAPP
-- À exécuter dans le SQL Editor de votre dashboard Supabase
-- ========================================================

-- --------------------------------------------------------
-- 1. AJOUTER LES POINTS DE BIENVENUE CONFIGURABLES
-- --------------------------------------------------------
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS signup_points INTEGER DEFAULT 50 CHECK (signup_points >= 0);

COMMENT ON COLUMN public.users.signup_points IS 'Points attribués automatiquement lors de l''inscription d''un nouveau client (par défaut 50, configurable)';

-- --------------------------------------------------------
-- 2. AJOUTER LES COLONNES DE CONSENTEMENT POUR LES CLIENTS
-- --------------------------------------------------------
ALTER TABLE public.customers
ADD COLUMN IF NOT EXISTS accept_terms BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS accept_marketing BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS accept_partners BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS consent_updated_at TIMESTAMP WITH TIME ZONE;

-- Ajouter les commentaires
COMMENT ON COLUMN public.customers.accept_terms IS 'Acceptation des conditions d''utilisation';
COMMENT ON COLUMN public.customers.accept_marketing IS 'Acceptation de recevoir des communications marketing';
COMMENT ON COLUMN public.customers.accept_partners IS 'Acceptation de recevoir des offres des partenaires';
COMMENT ON COLUMN public.customers.consent_updated_at IS 'Date de dernière mise à jour des consentements';

-- --------------------------------------------------------
-- 3. VÉRIFICATION DE LA MIGRATION
-- --------------------------------------------------------
-- Vérifier les colonnes ajoutées dans la table users
SELECT 
    'users' as table_name,
    column_name, 
    data_type, 
    column_default, 
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'users' 
AND column_name = 'signup_points'

UNION ALL

-- Vérifier les colonnes ajoutées dans la table customers
SELECT 
    'customers' as table_name,
    column_name, 
    data_type, 
    column_default, 
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'customers' 
AND column_name IN ('accept_terms', 'accept_marketing', 'accept_partners', 'consent_updated_at')
ORDER BY table_name, column_name;

-- --------------------------------------------------------
-- 4. MESSAGE DE CONFIRMATION
-- --------------------------------------------------------
-- Si toutes les colonnes apparaissent dans le résultat ci-dessus,
-- la migration a été effectuée avec succès !
-- 
-- Vous devriez voir :
-- - 1 ligne pour signup_points dans la table users
-- - 4 lignes pour les colonnes de consentement dans la table customers