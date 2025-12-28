-- Mettre à jour la fonction pour gérer tous les champs du formulaire d'inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (
        auth_id, 
        email, 
        company, 
        first_name, 
        last_name, 
        accept_terms,
        accept_newsletter,
        language,
        created_at,
        is_active,
        email_verified
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'company', ''),
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        COALESCE((NEW.raw_user_meta_data->>'accept_terms')::boolean, false),
        COALESCE((NEW.raw_user_meta_data->>'accept_newsletter')::boolean, false),
        COALESCE(NEW.raw_user_meta_data->>'language', 'FR'),
        NOW(),
        true,
        false
    );
    
    -- Logger la création du compte
    INSERT INTO public.activity_logs (
        user_id,
        action,
        description,
        created_at
    )
    VALUES (
        (SELECT id FROM public.users WHERE auth_id = NEW.id),
        'ACCOUNT_CREATED',
        'Compte créé avec succès - Plan: ' || COALESCE(NEW.raw_user_meta_data->>'selected_plan', 'free'),
        NOW()
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recréer le trigger si nécessaire
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Ajouter une colonne pour le plan sélectionné si elle n'existe pas
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS selected_plan VARCHAR(50) DEFAULT 'free';

-- Mettre à jour la fonction pour inclure le plan
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (
        auth_id, 
        email, 
        company, 
        first_name, 
        last_name, 
        accept_terms,
        accept_newsletter,
        selected_plan,
        language,
        created_at,
        is_active,
        email_verified
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'company', ''),
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        COALESCE((NEW.raw_user_meta_data->>'accept_terms')::boolean, false),
        COALESCE((NEW.raw_user_meta_data->>'accept_newsletter')::boolean, false),
        COALESCE(NEW.raw_user_meta_data->>'selected_plan', 'free'),
        COALESCE(NEW.raw_user_meta_data->>'language', 'FR'),
        NOW(),
        true,
        false
    )
    ON CONFLICT (auth_id) 
    DO UPDATE SET
        company = EXCLUDED.company,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        accept_terms = EXCLUDED.accept_terms,
        accept_newsletter = EXCLUDED.accept_newsletter,
        selected_plan = EXCLUDED.selected_plan,
        updated_at = NOW();
    
    -- Logger la création du compte
    INSERT INTO public.activity_logs (
        user_id,
        action,
        description,
        created_at
    )
    VALUES (
        (SELECT id FROM public.users WHERE auth_id = NEW.id),
        'ACCOUNT_CREATED',
        json_build_object(
            'company', NEW.raw_user_meta_data->>'company',
            'plan', NEW.raw_user_meta_data->>'selected_plan',
            'newsletter', NEW.raw_user_meta_data->>'accept_newsletter',
            'terms', NEW.raw_user_meta_data->>'accept_terms'
        )::text,
        NOW()
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;