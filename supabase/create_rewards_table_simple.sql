-- COPIEZ ET EXÉCUTEZ CE SQL DANS LE SQL EDITOR DE SUPABASE

-- 1. Créer la table rewards
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

-- 2. Créer les index
CREATE INDEX IF NOT EXISTS idx_rewards_company_id ON rewards(company_id);
CREATE INDEX IF NOT EXISTS idx_rewards_is_active ON rewards(is_active);
CREATE INDEX IF NOT EXISTS idx_rewards_category ON rewards(category);

-- 3. Activer RLS
ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;

-- 4. Créer une politique simple pour tout permettre aux utilisateurs authentifiés
-- (temporaire pour tester)
CREATE POLICY "Enable all for authenticated users" ON rewards
    FOR ALL 
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- 5. Vérifier que la table existe
SELECT COUNT(*) FROM rewards;