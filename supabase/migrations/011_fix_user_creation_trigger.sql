-- Créer une fonction trigger pour automatiquement créer une ligne dans la table users
-- quand un utilisateur s'inscrit via Supabase Auth

-- Fonction pour créer automatiquement un enregistrement dans users après signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
DECLARE
    new_qr_code_id TEXT;
    done BOOLEAN := FALSE;
BEGIN
    -- Générer un qr_code_id unique
    WHILE NOT done LOOP
        new_qr_code_id := generate_qr_code_id();
        -- Vérifier l'unicité
        IF NOT EXISTS (SELECT 1 FROM public.users WHERE qr_code_id = new_qr_code_id) THEN
            done := TRUE;
        END IF;
    END LOOP;

    -- Insérer dans la table users avec les métadonnées du profil Auth
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
        COALESCE(NEW.raw_user_meta_data->>'company', ''),
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        COALESCE((NEW.raw_user_meta_data->>'accept_terms')::boolean, false),
        COALESCE((NEW.raw_user_meta_data->>'accept_newsletter')::boolean, false),
        COALESCE(NEW.raw_user_meta_data->>'selected_plan', 'free'),
        new_qr_code_id,
        NOW(),
        NOW()
    );
    
    RETURN NEW;
EXCEPTION
    WHEN others THEN
        -- Log l'erreur mais ne bloque pas la création de l'utilisateur Auth
        RAISE LOG 'Erreur dans handle_new_user: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Supprimer l'ancien trigger s'il existe
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Créer le nouveau trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW 
    EXECUTE FUNCTION handle_new_user();

-- Donner les permissions appropriées
GRANT USAGE ON SCHEMA auth TO postgres, service_role;

-- Message de confirmation
SELECT 'Trigger de création d''utilisateur configuré avec succès!' as message;