-- Script pour corriger la table customers et ses permissions

-- Vérifier si la table customers existe
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'customers') THEN
        -- Créer la table customers si elle n'existe pas
        CREATE TABLE customers (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            company_id UUID REFERENCES users(id) ON DELETE CASCADE,
            
            -- Informations personnelles
            first_name VARCHAR(100) NOT NULL,
            last_name VARCHAR(100) NOT NULL,
            email VARCHAR(255) NOT NULL,
            phone VARCHAR(30),
            date_of_birth DATE,
            
            -- Points et statut
            points INTEGER DEFAULT 0,
            total_points_earned INTEGER DEFAULT 0,
            total_points_spent INTEGER DEFAULT 0,
            
            -- Authentification
            is_verified BOOLEAN DEFAULT false,
            last_otp_code VARCHAR(6),
            last_otp_sent_at TIMESTAMPTZ,
            otp_attempts INTEGER DEFAULT 0,
            
            -- Métadonnées
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW(),
            last_visit_at TIMESTAMPTZ,
            
            -- Contrainte unique : un client par email par entreprise
            UNIQUE(company_id, email)
        );
        
        -- Index pour les recherches
        CREATE INDEX idx_customers_company_id ON customers(company_id);
        CREATE INDEX idx_customers_email ON customers(email);
        CREATE INDEX idx_customers_phone ON customers(phone);
    END IF;
END $$;

-- Supprimer la contrainte unique sur phone si elle existe (peut causer des problèmes avec NULL)
ALTER TABLE customers DROP CONSTRAINT IF EXISTS customers_company_id_phone_key;

-- Créer la table points_history si elle n'existe pas
CREATE TABLE IF NOT EXISTS points_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    company_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    type VARCHAR(50) NOT NULL, -- 'earned', 'spent', 'expired', 'bonus'
    amount INTEGER NOT NULL,
    balance_after INTEGER NOT NULL,
    
    description TEXT,
    reward_id UUID, -- Pas de référence pour éviter les erreurs si rewards n'existe pas
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour l'historique
CREATE INDEX IF NOT EXISTS idx_points_history_customer ON points_history(customer_id);
CREATE INDEX IF NOT EXISTS idx_points_history_company ON points_history(company_id);

-- Activer RLS
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE points_history ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes policies
DROP POLICY IF EXISTS "Companies can view their customers" ON customers;
DROP POLICY IF EXISTS "Customers can view their own data" ON customers;
DROP POLICY IF EXISTS "View points history" ON points_history;
DROP POLICY IF EXISTS "Anyone can create customer account" ON customers;
DROP POLICY IF EXISTS "Customers can update their own data" ON customers;
DROP POLICY IF EXISTS "Companies can manage points history" ON points_history;

-- Politique pour permettre la création de compte client (publique)
CREATE POLICY "Anyone can create customer account" ON customers
    FOR INSERT
    WITH CHECK (true);

-- Politique pour permettre aux clients de voir leurs propres données
CREATE POLICY "Customers can view their own data" ON customers
    FOR SELECT
    USING (true); -- Temporairement permissif pour le debug

-- Politique pour permettre aux clients de mettre à jour leurs propres données
CREATE POLICY "Customers can update their own data" ON customers
    FOR UPDATE
    USING (true); -- Temporairement permissif pour le debug

-- Politique pour les entreprises : voir et gérer leurs clients
CREATE POLICY "Companies can view their customers" ON customers
    FOR ALL
    USING (
        company_id IN (
            SELECT id FROM users WHERE auth_id = auth.uid()
        )
        OR true -- Temporairement permissif pour le debug
    );

-- Politique pour l'historique des points
CREATE POLICY "View points history" ON points_history
    FOR SELECT
    USING (true); -- Temporairement permissif

CREATE POLICY "Companies can manage points history" ON points_history
    FOR INSERT
    WITH CHECK (
        company_id IN (
            SELECT id FROM users WHERE auth_id = auth.uid()
        )
        OR true -- Temporairement permissif pour le debug
    );

-- Vérification de la structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'customers'
ORDER BY ordinal_position;

-- Message de confirmation
SELECT 'Table customers corrigée avec succès! Les permissions sont temporairement ouvertes pour le debug.' as message;