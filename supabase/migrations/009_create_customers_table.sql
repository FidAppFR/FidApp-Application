-- Créer la table des clients (un compte par client par entreprise)
CREATE TABLE IF NOT EXISTS customers (
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
    UNIQUE(company_id, email),
    UNIQUE(company_id, phone)
);

-- Index pour les recherches
CREATE INDEX idx_customers_company_id ON customers(company_id);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_phone ON customers(phone);

-- Table pour stocker l'historique des transactions de points
CREATE TABLE IF NOT EXISTS points_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    company_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    type VARCHAR(50) NOT NULL, -- 'earned', 'spent', 'expired', 'bonus'
    amount INTEGER NOT NULL,
    balance_after INTEGER NOT NULL,
    
    description TEXT,
    reward_id UUID REFERENCES rewards(id) ON DELETE SET NULL,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour l'historique
CREATE INDEX idx_points_history_customer ON points_history(customer_id);
CREATE INDEX idx_points_history_company ON points_history(company_id);

-- RLS (Row Level Security)
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE points_history ENABLE ROW LEVEL SECURITY;

-- Politique pour les entreprises : voir et gérer leurs clients
CREATE POLICY "Companies can view their customers" ON customers
    FOR ALL
    USING (company_id IN (
        SELECT id FROM users WHERE auth_id = auth.uid()
    ));

-- Politique pour les clients : voir leurs propres informations
CREATE POLICY "Customers can view their own data" ON customers
    FOR SELECT
    USING (email = current_setting('app.current_customer_email', true));

-- Politique pour l'historique
CREATE POLICY "View points history" ON points_history
    FOR SELECT
    USING (
        company_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
        OR
        customer_id IN (SELECT id FROM customers WHERE email = current_setting('app.current_customer_email', true))
    );

-- Message de confirmation
SELECT 'Tables customers et points_history créées avec succès!' as message;