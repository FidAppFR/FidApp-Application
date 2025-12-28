-- Script à exécuter dans le SQL Editor de votre dashboard Supabase
-- Ce script ajoute le champ signup_points pour configurer les points d'inscription

-- 1. Ajouter le champ signup_points à la table users
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS signup_points INTEGER DEFAULT 50 CHECK (signup_points >= 0);

-- 2. Ajouter un commentaire pour documenter le champ
COMMENT ON COLUMN public.users.signup_points IS 'Points attribués automatiquement lors de l''inscription d''un nouveau client (par défaut 50, configurable)';

-- 3. Vérifier que le champ a bien été ajouté
SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'users' 
AND column_name = 'signup_points';

-- 4. Mettre à jour les enregistrements existants si nécessaire (optionnel)
-- UPDATE public.users SET signup_points = 50 WHERE signup_points IS NULL;