-- Ajouter les colonnes manquantes pour le profil utilisateur
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS city VARCHAR(100),
ADD COLUMN IF NOT EXISTS postal_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS country VARCHAR(100) DEFAULT 'France';

-- Créer un index sur birth_date pour les requêtes d'anniversaire
CREATE INDEX IF NOT EXISTS idx_users_birth_date ON public.users(birth_date);

-- Mettre à jour la politique RLS pour permettre aux utilisateurs de voir leur profil complet
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = auth_id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = auth_id)
    WITH CHECK (auth.uid() = auth_id);

-- Créer une fonction pour mettre à jour le profil
CREATE OR REPLACE FUNCTION public.update_user_profile(
    user_id UUID,
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_phone VARCHAR,
    p_birth_date DATE,
    p_accept_newsletter BOOLEAN,
    p_language VARCHAR
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE public.users
    SET
        first_name = p_first_name,
        last_name = p_last_name,
        phone = p_phone,
        birth_date = p_birth_date,
        accept_newsletter = p_accept_newsletter,
        language = p_language,
        updated_at = NOW()
    WHERE id = user_id AND auth_id = auth.uid();
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;