-- Ajouter un champ pour configurer les points d'inscription par défaut
ALTER TABLE public.users
ADD COLUMN signup_points INTEGER DEFAULT 50 CHECK (signup_points >= 0);

-- Ajouter un commentaire pour documenter le champ
COMMENT ON COLUMN public.users.signup_points IS 'Points attribués automatiquement lors de l''inscription d''un nouveau client (par défaut 50, configurable)';