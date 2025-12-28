-- SCRIPT SIMPLIFIÉ POUR CORRIGER LE PROBLÈME DE PROFIL
-- Exécutez ce script étape par étape dans Supabase SQL Editor

-- ÉTAPE 1: Vérifier les colonnes manquantes et les ajouter
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS qr_code_id VARCHAR(20),
ADD COLUMN IF NOT EXISTS phone VARCHAR(20),
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS language VARCHAR(10) DEFAULT 'FR',
ADD COLUMN IF NOT EXISTS selected_plan VARCHAR(50) DEFAULT 'free';

-- ÉTAPE 2: Ajouter l'ID unique pour la colonne auth_id si elle n'existe pas
DO $$ 
BEGIN
    -- Supprimer l'ancienne contrainte si elle existe
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'users_auth_id_key') THEN
        ALTER TABLE users DROP CONSTRAINT users_auth_id_key;
    END IF;
    
    -- Ajouter la nouvelle contrainte
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'users_auth_id_unique') THEN
        ALTER TABLE users ADD CONSTRAINT users_auth_id_unique UNIQUE (auth_id);
    END IF;
END $$;

-- ÉTAPE 3: Générer des QR codes pour les utilisateurs existants qui n'en ont pas
UPDATE users 
SET qr_code_id = 'QR' || substr(md5(random()::text || auth_id::text), 1, 8)
WHERE qr_code_id IS NULL OR qr_code_id = '';

-- ÉTAPE 4: Créer les enregistrements manquants pour tous les utilisateurs Auth
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
    'QR' || substr(md5(random()::text || au.id::text), 1, 8),
    COALESCE(au.created_at, NOW()),
    NOW()
FROM auth.users au
WHERE NOT EXISTS (
    SELECT 1 FROM users u WHERE u.auth_id = au.id
);

-- ÉTAPE 5: Vérifier les policies RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes policies si elles existent
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can insert own data" ON users;

-- Créer des policies permissives pour le debug
CREATE POLICY "Users can view own data" ON users
    FOR SELECT
    USING (auth.uid() = auth_id);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE
    USING (auth.uid() = auth_id);

CREATE POLICY "Users can insert own data" ON users
    FOR INSERT
    WITH CHECK (auth.uid() = auth_id);

-- ÉTAPE 6: Vérifier le résultat
SELECT 
    'Vérification terminée' as status,
    (SELECT COUNT(*) FROM auth.users) as total_auth_users,
    (SELECT COUNT(*) FROM users) as total_users_records,
    (SELECT COUNT(*) FROM auth.users au LEFT JOIN users u ON u.auth_id = au.id WHERE u.id IS NULL) as missing_records;

-- ÉTAPE 7: Afficher les 5 derniers utilisateurs pour vérification
SELECT 
    u.id,
    u.auth_id,
    u.email,
    u.company,
    u.first_name,
    u.last_name,
    u.qr_code_id,
    u.created_at
FROM users u
ORDER BY u.created_at DESC
LIMIT 5;