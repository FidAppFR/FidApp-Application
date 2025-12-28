-- Script pour ajouter les colonnes de consentement manquantes dans la table customers
-- À exécuter dans le SQL Editor de votre dashboard Supabase

-- 1. Ajouter les colonnes de consentement
ALTER TABLE public.customers
ADD COLUMN IF NOT EXISTS accept_terms BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS accept_marketing BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS accept_partners BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS consent_updated_at TIMESTAMP WITH TIME ZONE;

-- 2. Ajouter des commentaires pour documenter les colonnes
COMMENT ON COLUMN public.customers.accept_terms IS 'Acceptation des conditions d''utilisation';
COMMENT ON COLUMN public.customers.accept_marketing IS 'Acceptation de recevoir des communications marketing';
COMMENT ON COLUMN public.customers.accept_partners IS 'Acceptation de recevoir des offres des partenaires';
COMMENT ON COLUMN public.customers.consent_updated_at IS 'Date de dernière mise à jour des consentements';

-- 3. Vérifier que les colonnes ont bien été ajoutées
SELECT 
    column_name, 
    data_type, 
    column_default, 
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'customers' 
AND column_name IN ('accept_terms', 'accept_marketing', 'accept_partners', 'consent_updated_at')
ORDER BY column_name;

-- 4. Mettre à jour les enregistrements existants avec des valeurs par défaut (optionnel)
-- Décommentez la ligne suivante si vous voulez définir accept_terms à true pour les clients existants
-- UPDATE public.customers SET accept_terms = true, consent_updated_at = NOW() WHERE accept_terms IS NULL;