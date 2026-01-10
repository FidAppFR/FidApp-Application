-- Changer la valeur par defaut du theme de 'system' a 'light'
ALTER TABLE users
ALTER COLUMN theme_preference SET DEFAULT 'light';

-- Mettre a jour les utilisateurs existants qui ont 'system' vers 'light'
UPDATE users
SET theme_preference = 'light'
WHERE theme_preference = 'system' OR theme_preference IS NULL;

-- Mettre a jour la contrainte CHECK pour ne plus accepter 'system'
ALTER TABLE users
DROP CONSTRAINT IF EXISTS users_theme_preference_check;

ALTER TABLE users
ADD CONSTRAINT users_theme_preference_check
CHECK (theme_preference IN ('light', 'dark'));
