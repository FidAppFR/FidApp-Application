-- Ajouter les champs de facturation manquants à la table users

-- SIRET de l'entreprise
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS siret TEXT;

-- Adresse de facturation
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS address TEXT;

-- Ville
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS city TEXT;

-- Code postal
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS postal_code TEXT;

-- Pays
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS country TEXT DEFAULT 'France';

-- Téléphone (si pas déjà présent)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS phone TEXT;

-- Créer des index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_siret ON users(siret);
CREATE INDEX IF NOT EXISTS idx_users_company_billing ON users(company, siret);

-- Commentaires sur les colonnes
COMMENT ON COLUMN users.siret IS 'Numéro SIRET de l''entreprise pour la facturation';
COMMENT ON COLUMN users.address IS 'Adresse de facturation';
COMMENT ON COLUMN users.city IS 'Ville de facturation';
COMMENT ON COLUMN users.postal_code IS 'Code postal de facturation';
COMMENT ON COLUMN users.country IS 'Pays de facturation';
COMMENT ON COLUMN users.phone IS 'Numéro de téléphone pour la facturation';