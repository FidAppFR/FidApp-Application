-- SCRIPT DE DEBUG ET CORRECTION POUR LE PROBLÈME DE PROFIL
-- Exécutez ces requêtes dans l'ordre dans Supabase SQL Editor

-- 1. Vérifier les utilisateurs Auth existants
SELECT id, email, created_at, raw_user_meta_data
FROM auth.users
ORDER BY created_at DESC
LIMIT 5;

-- 2. Vérifier les enregistrements dans la table users
SELECT id, auth_id, email, company, first_name, last_name, created_at
FROM users
ORDER BY created_at DESC
LIMIT 5;

-- 3. Identifier les utilisateurs Auth sans correspondance dans users
SELECT au.id, au.email, au.created_at
FROM auth.users au
LEFT JOIN users u ON u.auth_id = au.id
WHERE u.id IS NULL
ORDER BY au.created_at DESC;

-- 4. Créer manuellement les enregistrements manquants
-- Cette requête crée les enregistrements users pour les comptes Auth existants
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
    COALESCE((au.raw_user_meta_data->>'accept_terms')::boolean, false),
    COALESCE((au.raw_user_meta_data->>'accept_newsletter')::boolean, false),
    COALESCE(au.raw_user_meta_data->>'selected_plan', 'free'),
    'QR' || substr(md5(random()::text || NOW()::text), 1, 8),
    au.created_at,
    NOW()
FROM auth.users au
LEFT JOIN users u ON u.auth_id = au.id
WHERE u.id IS NULL;

-- 5. Vérifier que le trigger existe et fonctionne
SELECT 
    tgname as trigger_name,
    tgisinternal as is_internal,
    tgenabled as is_enabled
FROM pg_trigger 
WHERE tgname = 'on_auth_user_created';

-- 6. Recréer le trigger s'il n'existe pas ou est désactivé
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
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
        'QR' || substr(md5(random()::text || NEW.id::text), 1, 8),
        NOW(),
        NOW()
    )
    ON CONFLICT (auth_id) DO UPDATE SET
        email = EXCLUDED.email,
        updated_at = NOW()
    WHERE users.email IS DISTINCT FROM EXCLUDED.email;
    
    RETURN NEW;
EXCEPTION
    WHEN others THEN
        -- Log mais ne bloque pas
        RAISE WARNING 'handle_new_user error: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW 
    EXECUTE FUNCTION handle_new_user();

-- 7. Activer les RLS policies pour la table users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre aux utilisateurs de voir leurs propres données
CREATE POLICY "Users can view own data" ON users
    FOR SELECT
    USING (auth.uid() = auth_id);

-- Politique pour permettre aux utilisateurs de mettre à jour leurs propres données
CREATE POLICY "Users can update own data" ON users
    FOR UPDATE
    USING (auth.uid() = auth_id);

-- 8. Message de confirmation
SELECT 'Debug et correction terminés!' as message,
       COUNT(*) as total_auth_users,
       (SELECT COUNT(*) FROM users) as total_users_records
FROM auth.users;