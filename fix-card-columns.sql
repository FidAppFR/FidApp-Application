-- Script complet pour ajouter toutes les colonnes nécessaires pour la personnalisation de carte

-- 1. Ajouter les colonnes si elles n'existent pas
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS card_background_url TEXT,
ADD COLUMN IF NOT EXISTS card_theme TEXT DEFAULT 'gradient' CHECK (card_theme IN ('gradient', 'custom', 'solid')),
ADD COLUMN IF NOT EXISTS card_gradient TEXT DEFAULT 'from-violet-600 to-pink-600';

-- 2. Vérifier que les colonnes ont été ajoutées
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name IN ('card_background_url', 'card_theme', 'card_gradient')
ORDER BY column_name;

-- 3. Afficher un utilisateur pour vérifier
SELECT 
    id,
    company,
    card_background_url,
    card_theme,
    card_gradient
FROM users
LIMIT 1;