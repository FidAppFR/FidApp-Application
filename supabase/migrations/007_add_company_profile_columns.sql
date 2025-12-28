-- Ajouter les colonnes manquantes pour le profil d'entreprise
-- Exécutez ce script dans Supabase SQL Editor si vous avez des erreurs lors de la sauvegarde

-- Colonnes d'adresse
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS city VARCHAR(100),
ADD COLUMN IF NOT EXISTS postal_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS phone VARCHAR(30);

-- Colonnes d'information d'entreprise
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS sector VARCHAR(50),
ADD COLUMN IF NOT EXISTS website TEXT,
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS logo_url TEXT;

-- Horaires d'ouverture (format JSON)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS opening_hours JSONB DEFAULT '{
  "lundi": {"open": "09:00", "close": "19:00", "closed": false},
  "mardi": {"open": "09:00", "close": "19:00", "closed": false},
  "mercredi": {"open": "09:00", "close": "19:00", "closed": false},
  "jeudi": {"open": "09:00", "close": "19:00", "closed": false},
  "vendredi": {"open": "09:00", "close": "19:00", "closed": false},
  "samedi": {"open": "09:00", "close": "19:00", "closed": false},
  "dimanche": {"open": "09:00", "close": "19:00", "closed": true}
}'::jsonb;

-- Colonnes de timestamps
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Message de confirmation
SELECT 'Colonnes du profil entreprise ajoutées avec succès!' as message;