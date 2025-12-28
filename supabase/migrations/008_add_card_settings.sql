-- Ajouter la colonne card_settings pour stocker les paramètres de la carte de fidélité
-- Exécutez ce script dans Supabase SQL Editor

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS card_settings JSONB DEFAULT '{
  "gradient": "from-violet-600 to-pink-600",
  "welcomeMessage": "Merci de votre fidélité !",
  "showPoints": true,
  "showQR": true,
  "showExpiry": true
}'::jsonb;

-- Message de confirmation
SELECT 'Colonne card_settings ajoutée avec succès!' as message;