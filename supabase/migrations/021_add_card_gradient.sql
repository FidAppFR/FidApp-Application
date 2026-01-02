-- Ajouter la colonne card_gradient si elle n'existe pas
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS card_gradient TEXT DEFAULT 'from-violet-600 to-pink-600';