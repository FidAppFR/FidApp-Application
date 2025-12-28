-- Script pour ajouter les colonnes de consentement à la table customers

-- Ajouter les colonnes de consentement si elles n'existent pas
ALTER TABLE customers
ADD COLUMN IF NOT EXISTS accept_terms BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS accept_marketing BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS accept_partners BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS consent_updated_at TIMESTAMPTZ DEFAULT NOW();

-- Vérifier que les colonnes ont été ajoutées
SELECT 
    column_name, 
    data_type, 
    column_default
FROM information_schema.columns
WHERE table_name = 'customers' 
AND column_name IN ('accept_terms', 'accept_marketing', 'accept_partners', 'consent_updated_at')
ORDER BY column_name;

-- Mettre à jour les enregistrements existants pour avoir accept_terms à true
UPDATE customers 
SET accept_terms = true 
WHERE accept_terms IS NULL;

-- Message de confirmation
SELECT 
    'Colonnes de consentement ajoutées avec succès!' as message,
    COUNT(*) as total_customers
FROM customers;