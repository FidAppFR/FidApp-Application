-- Création de la table des récompenses
CREATE TABLE IF NOT EXISTS rewards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    points_required INTEGER NOT NULL DEFAULT 0,
    category VARCHAR(50) NOT NULL DEFAULT 'general',
    discount_percentage INTEGER,
    discount_amount DECIMAL(10,2),
    is_active BOOLEAN DEFAULT true,
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_until TIMESTAMP WITH TIME ZONE,
    max_uses_per_customer INTEGER,
    total_uses INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_rewards_company_id ON rewards(company_id);
CREATE INDEX IF NOT EXISTS idx_rewards_is_active ON rewards(is_active);
CREATE INDEX IF NOT EXISTS idx_rewards_category ON rewards(category);

-- RLS (Row Level Security)
ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes politiques si elles existent
DROP POLICY IF EXISTS "Companies can view their own rewards" ON rewards;
DROP POLICY IF EXISTS "Companies can insert their own rewards" ON rewards;
DROP POLICY IF EXISTS "Companies can update their own rewards" ON rewards;
DROP POLICY IF EXISTS "Companies can delete their own rewards" ON rewards;

-- Politique pour que chaque entreprise ne voie que ses récompenses
CREATE POLICY "Companies can view their own rewards" ON rewards
    FOR SELECT 
    USING (
        company_id IN (
            SELECT id FROM users WHERE auth_id = auth.uid()::text
        )
    );

CREATE POLICY "Companies can insert their own rewards" ON rewards
    FOR INSERT 
    WITH CHECK (
        company_id IN (
            SELECT id FROM users WHERE auth_id = auth.uid()::text
        )
    );

CREATE POLICY "Companies can update their own rewards" ON rewards
    FOR UPDATE 
    USING (
        company_id IN (
            SELECT id FROM users WHERE auth_id = auth.uid()::text
        )
    );

CREATE POLICY "Companies can delete their own rewards" ON rewards
    FOR DELETE 
    USING (
        company_id IN (
            SELECT id FROM users WHERE auth_id = auth.uid()::text
        )
    );

-- Fonction pour mettre à jour le updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger pour auto-update updated_at
DROP TRIGGER IF EXISTS update_rewards_updated_at ON rewards;
CREATE TRIGGER update_rewards_updated_at BEFORE UPDATE ON rewards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();