-- Ajouter la colonne theme_preference à la table users pour sauvegarder le choix de l'utilisateur
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS theme_preference TEXT DEFAULT 'system' 
CHECK (theme_preference IN ('light', 'dark', 'system'));

-- Créer un index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_theme_preference ON users(auth_id, theme_preference);

-- Commentaire sur la colonne
COMMENT ON COLUMN users.theme_preference IS 'Préférence de thème de l''utilisateur: light, dark ou system (suit le système)';