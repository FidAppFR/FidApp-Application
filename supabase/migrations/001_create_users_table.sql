-- Créer l'extension UUID si elle n'existe pas
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Créer la table users pour stocker les informations complètes des utilisateurs
CREATE TABLE IF NOT EXISTS public.users (
    -- ID unique généré automatiquement
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    
    -- Informations d'authentification
    auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    
    -- Informations personnelles
    company VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    
    -- Consentements
    accept_terms BOOLEAN DEFAULT false NOT NULL,
    accept_newsletter BOOLEAN DEFAULT false,
    
    -- Métadonnées
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    
    -- Statut du compte
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    
    -- Informations supplémentaires
    phone VARCHAR(20),
    language VARCHAR(2) DEFAULT 'FR',
    
    -- Index pour les recherches
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);

-- Créer les index pour optimiser les performances
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_company ON public.users(company);
CREATE INDEX idx_users_auth_id ON public.users(auth_id);
CREATE INDEX idx_users_created_at ON public.users(created_at DESC);

-- Créer une fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Créer un trigger pour mettre à jour updated_at automatiquement
CREATE TRIGGER update_users_updated_at BEFORE UPDATE
    ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Créer la table de sessions pour gérer les connexions
CREATE TABLE IF NOT EXISTS public.sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    token TEXT UNIQUE NOT NULL,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- Créer les index pour les sessions
CREATE INDEX idx_sessions_user_id ON public.sessions(user_id);
CREATE INDEX idx_sessions_token ON public.sessions(token);
CREATE INDEX idx_sessions_expires_at ON public.sessions(expires_at);

-- Créer la table de logs d'activité
CREATE TABLE IF NOT EXISTS public.activity_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    description TEXT,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Créer un index pour les logs
CREATE INDEX idx_activity_logs_user_id ON public.activity_logs(user_id);
CREATE INDEX idx_activity_logs_created_at ON public.activity_logs(created_at DESC);

-- Activer Row Level Security (RLS) pour sécuriser les données
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;

-- Créer les politiques de sécurité pour users
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = auth_id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = auth_id);

-- Créer les politiques pour sessions
CREATE POLICY "Users can view own sessions" ON public.sessions
    FOR SELECT USING (user_id IN (
        SELECT id FROM public.users WHERE auth_id = auth.uid()
    ));

-- Créer les politiques pour activity_logs
CREATE POLICY "Users can view own activity" ON public.activity_logs
    FOR SELECT USING (user_id IN (
        SELECT id FROM public.users WHERE auth_id = auth.uid()
    ));

-- Fonction pour créer un nouvel utilisateur après inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (auth_id, email, company, first_name, last_name, accept_newsletter)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'company', ''),
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        COALESCE((NEW.raw_user_meta_data->>'accept_newsletter')::boolean, false)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Créer un trigger pour gérer automatiquement les nouveaux utilisateurs
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Fonction pour logger les activités
CREATE OR REPLACE FUNCTION public.log_activity(
    p_user_id UUID,
    p_action VARCHAR(100),
    p_description TEXT DEFAULT NULL,
    p_ip_address INET DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO public.activity_logs (user_id, action, description, ip_address, user_agent)
    VALUES (p_user_id, p_action, p_description, p_ip_address, p_user_agent);
END;
$$ LANGUAGE plpgsql;

-- Fonction pour nettoyer les sessions expirées
CREATE OR REPLACE FUNCTION public.cleanup_expired_sessions()
RETURNS VOID AS $$
BEGIN
    UPDATE public.sessions 
    SET is_active = false 
    WHERE expires_at < NOW() AND is_active = true;
    
    DELETE FROM public.sessions 
    WHERE expires_at < NOW() - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;