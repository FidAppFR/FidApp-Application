-- SCRIPT COMPLET DE CORRECTION DU PROBLÈME DE PROFIL
-- Exécutez ce script dans Supabase SQL Editor pour corriger définitivement le problème

-- Étape 1: Vérifier et corriger la structure de la table users
-- Ajouter les colonnes manquantes si elles n'existent pas
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS qr_code_id VARCHAR(20),
ADD COLUMN IF NOT EXISTS phone VARCHAR(20),
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS language VARCHAR(10) DEFAULT 'FR',
ADD COLUMN IF NOT EXISTS logo_url TEXT,
ADD COLUMN IF NOT EXISTS card_settings JSONB DEFAULT '{}';

-- Ajouter contrainte unique sur auth_id si elle n'existe pas
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'users_auth_id_unique') THEN
        ALTER TABLE users ADD CONSTRAINT users_auth_id_unique UNIQUE (auth_id);
    END IF;
END $$;

-- Ajouter contrainte unique sur qr_code_id si elle n'existe pas
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'users_qr_code_id_unique') THEN
        ALTER TABLE users ADD CONSTRAINT users_qr_code_id_unique UNIQUE (qr_code_id);
    END IF;
END $$;

-- Étape 2: Créer la fonction de génération de QR Code ID
CREATE OR REPLACE FUNCTION generate_unique_qr_code_id()
RETURNS TEXT AS $$
DECLARE
    new_id TEXT;
    done BOOLEAN := FALSE;
    counter INT := 0;
BEGIN
    WHILE NOT done AND counter < 100 LOOP
        -- Générer un ID de 10 caractères alphanumériques
        new_id := 'QR' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 8));
        
        -- Vérifier l'unicité
        IF NOT EXISTS (SELECT 1 FROM users WHERE qr_code_id = new_id) THEN
            done := TRUE;
        END IF;
        
        counter := counter + 1;
    END LOOP;
    
    IF NOT done THEN
        -- En cas d'échec, utiliser timestamp + random
        new_id := 'QR' || to_char(current_timestamp, 'YYMMDD') || substr(md5(random()::text), 1, 4);
    END IF;
    
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- Étape 3: Mettre à jour tous les enregistrements existants sans qr_code_id
UPDATE users 
SET qr_code_id = generate_unique_qr_code_id()
WHERE qr_code_id IS NULL OR qr_code_id = '';

-- Étape 4: Créer les enregistrements manquants pour les utilisateurs auth existants
INSERT INTO users (
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
SELECT 
    gen_random_uuid(),
    au.id,
    au.email,
    COALESCE(au.raw_user_meta_data->>'company', 'Mon Entreprise'),
    COALESCE(au.raw_user_meta_data->>'first_name', ''),
    COALESCE(au.raw_user_meta_data->>'last_name', ''),
    COALESCE((au.raw_user_meta_data->>'accept_terms')::boolean, true),
    COALESCE((au.raw_user_meta_data->>'accept_newsletter')::boolean, false),
    COALESCE(au.raw_user_meta_data->>'selected_plan', 'free'),
    generate_unique_qr_code_id(),
    au.created_at,
    NOW()
FROM auth.users au
LEFT JOIN users u ON u.auth_id = au.id
WHERE u.id IS NULL;

-- Étape 5: Créer un trigger amélioré pour les nouveaux utilisateurs
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
DECLARE
    new_qr_id TEXT;
BEGIN
    -- Générer un QR code ID unique
    new_qr_id := generate_unique_qr_code_id();
    
    -- Créer l'enregistrement dans la table users
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
        COALESCE((NEW.raw_user_meta_data->>'accept_terms')::boolean, true),
        COALESCE((NEW.raw_user_meta_data->>'accept_newsletter')::boolean, false),
        COALESCE(NEW.raw_user_meta_data->>'selected_plan', 'free'),
        new_qr_id,
        NOW(),
        NOW()
    )
    ON CONFLICT (auth_id) DO UPDATE SET
        email = EXCLUDED.email,
        company = CASE 
            WHEN users.company IS NULL OR users.company = '' 
            THEN EXCLUDED.company 
            ELSE users.company 
        END,
        first_name = CASE 
            WHEN users.first_name IS NULL OR users.first_name = '' 
            THEN EXCLUDED.first_name 
            ELSE users.first_name 
        END,
        last_name = CASE 
            WHEN users.last_name IS NULL OR users.last_name = '' 
            THEN EXCLUDED.last_name 
            ELSE users.last_name 
        END,
        qr_code_id = CASE 
            WHEN users.qr_code_id IS NULL OR users.qr_code_id = '' 
            THEN new_qr_id 
            ELSE users.qr_code_id 
        END,
        updated_at = NOW();
    
    RETURN NEW;
EXCEPTION
    WHEN others THEN
        -- Log l'erreur mais ne bloque pas la création
        RAISE LOG 'Erreur dans handle_new_user: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Étape 6: Supprimer et recréer le trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW 
    EXECUTE FUNCTION handle_new_user();

-- Étape 7: Créer aussi un trigger pour les mises à jour auth
CREATE OR REPLACE FUNCTION handle_user_update()
RETURNS trigger AS $$
BEGIN
    -- Mettre à jour les informations dans la table users si elles ont changé
    UPDATE users
    SET 
        email = NEW.email,
        updated_at = NOW()
    WHERE auth_id = NEW.id;
    
    RETURN NEW;
EXCEPTION
    WHEN others THEN
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;

CREATE TRIGGER on_auth_user_updated
    AFTER UPDATE ON auth.users
    FOR EACH ROW 
    WHEN (OLD.email IS DISTINCT FROM NEW.email)
    EXECUTE FUNCTION handle_user_update();

-- Étape 8: Configurer les policies RLS correctement
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes policies
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can insert own data" ON users;

-- Créer les nouvelles policies
CREATE POLICY "Users can view own data" ON users
    FOR SELECT
    USING (auth.uid() = auth_id);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE
    USING (auth.uid() = auth_id);

CREATE POLICY "Users can insert own data" ON users
    FOR INSERT
    WITH CHECK (auth.uid() = auth_id);

-- Étape 9: Créer une fonction pour récupérer ou créer le profil utilisateur
CREATE OR REPLACE FUNCTION get_or_create_user_profile(user_auth_id UUID)
RETURNS SETOF users AS $$
DECLARE
    user_record users%ROWTYPE;
    auth_record auth.users%ROWTYPE;
BEGIN
    -- Essayer de récupérer l'enregistrement existant
    SELECT * INTO user_record FROM users WHERE auth_id = user_auth_id;
    
    -- Si pas trouvé, le créer
    IF NOT FOUND THEN
        -- Récupérer les infos auth
        SELECT * INTO auth_record FROM auth.users WHERE id = user_auth_id;
        
        IF FOUND THEN
            INSERT INTO users (
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
                auth_record.id,
                auth_record.email,
                COALESCE(auth_record.raw_user_meta_data->>'company', 'Mon Entreprise'),
                COALESCE(auth_record.raw_user_meta_data->>'first_name', ''),
                COALESCE(auth_record.raw_user_meta_data->>'last_name', ''),
                COALESCE((auth_record.raw_user_meta_data->>'accept_terms')::boolean, true),
                COALESCE((auth_record.raw_user_meta_data->>'accept_newsletter')::boolean, false),
                COALESCE(auth_record.raw_user_meta_data->>'selected_plan', 'free'),
                generate_unique_qr_code_id(),
                NOW(),
                NOW()
            )
            RETURNING * INTO user_record;
        END IF;
    END IF;
    
    RETURN NEXT user_record;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Étape 10: Donner les permissions nécessaires
GRANT EXECUTE ON FUNCTION get_or_create_user_profile(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION generate_unique_qr_code_id() TO authenticated;

-- Étape 11: Vérification finale
DO $$
DECLARE
    auth_count INT;
    users_count INT;
    missing_count INT;
BEGIN
    SELECT COUNT(*) INTO auth_count FROM auth.users;
    SELECT COUNT(*) INTO users_count FROM users;
    SELECT COUNT(*) INTO missing_count 
    FROM auth.users au 
    LEFT JOIN users u ON u.auth_id = au.id 
    WHERE u.id IS NULL;
    
    RAISE NOTICE 'Rapport de vérification:';
    RAISE NOTICE '- Utilisateurs Auth: %', auth_count;
    RAISE NOTICE '- Enregistrements Users: %', users_count;
    RAISE NOTICE '- Enregistrements manquants: %', missing_count;
    
    IF missing_count = 0 THEN
        RAISE NOTICE '✅ Tous les utilisateurs sont correctement synchronisés!';
    ELSE
        RAISE WARNING '⚠️ Il reste % enregistrements non synchronisés', missing_count;
    END IF;
END $$;

-- Message de succès
SELECT 
    '✅ Script exécuté avec succès!' as status,
    COUNT(*) as total_users,
    COUNT(DISTINCT qr_code_id) as unique_qr_codes
FROM users;