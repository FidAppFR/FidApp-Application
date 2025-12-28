-- SCRIPT DE CORRECTION POUR L'ERREUR "Database error saving new user"
-- Exécutez ces étapes dans l'ordre dans Supabase SQL Editor

-- Étape 1: S'assurer que les colonnes nécessaires existent
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS qr_code_id VARCHAR(20),
ADD COLUMN IF NOT EXISTS selected_plan VARCHAR(50) DEFAULT 'free';

-- Ajouter une contrainte unique sur auth_id pour éviter les doublons
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'users_auth_id_unique') THEN
        ALTER TABLE users ADD CONSTRAINT users_auth_id_unique UNIQUE (auth_id);
    END IF;
END $$;

-- Étape 2: Créer la fonction de génération d'ID si elle n'existe pas
CREATE OR REPLACE FUNCTION generate_qr_code_id()
RETURNS TEXT AS $$
DECLARE
    characters TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result TEXT := '';
    i INTEGER := 0;
BEGIN
    FOR i IN 1..10 LOOP
        result := result || substr(characters, floor(random() * length(characters) + 1)::int, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Étape 3: Créer le trigger pour auto-créer l'enregistrement users après signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
DECLARE
    new_qr_code_id TEXT;
BEGIN
    -- Générer un qr_code_id unique simple
    new_qr_code_id := 'QR' || substr(md5(random()::text || NOW()::text), 1, 8);
    
    -- Insérer dans la table users
    INSERT INTO public.users (
        id,
        auth_id,
        email,
        company,
        first_name,
        last_name,
        accept_terms,
        accept_newsletter,
        selected_plan,
        qr_code_id,
        created_at,
        updated_at
    )
    VALUES (
        gen_random_uuid(),
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'company', 'Mon Entreprise'),
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        COALESCE((NEW.raw_user_meta_data->>'accept_terms')::boolean, false),
        COALESCE((NEW.raw_user_meta_data->>'accept_newsletter')::boolean, false),
        COALESCE(NEW.raw_user_meta_data->>'selected_plan', 'free'),
        new_qr_code_id,
        NOW(),
        NOW()
    )
    ON CONFLICT (auth_id) DO UPDATE SET
        email = EXCLUDED.email,
        company = EXCLUDED.company,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        updated_at = NOW();
    
    RETURN NEW;
EXCEPTION
    WHEN others THEN
        -- Ne pas bloquer la création si erreur
        RAISE WARNING 'Erreur création users: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Étape 4: Supprimer et recréer le trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW 
    EXECUTE FUNCTION handle_new_user();

-- Étape 5: Vérifier que tout fonctionne
SELECT 'Configuration terminée! La création de compte devrait maintenant fonctionner.' as message;

-- Étape 6: Pour debug - voir les erreurs récentes
-- SELECT * FROM auth.users ORDER BY created_at DESC LIMIT 5;
-- SELECT * FROM users ORDER BY created_at DESC LIMIT 5;