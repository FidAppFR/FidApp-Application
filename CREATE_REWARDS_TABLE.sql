-- EXÉCUTEZ CE SQL DANS SUPABASE SQL EDITOR

-- Étape 1: Créer la table rewards
CREATE TABLE rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    points_required INTEGER NOT NULL DEFAULT 0,
    category VARCHAR(50) NOT NULL DEFAULT 'general',
    discount_percentage INTEGER,
    discount_amount DECIMAL(10,2),
    is_active BOOLEAN DEFAULT true,
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,
    max_uses_per_customer INTEGER,
    total_uses INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Étape 2: Activer RLS (Row Level Security)
ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;

-- Étape 3: Créer une politique pour permettre tout aux utilisateurs authentifiés
CREATE POLICY "Users can manage rewards" ON rewards
    FOR ALL 
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Étape 4: Créer les index pour les performances
CREATE INDEX idx_rewards_company_id ON rewards(company_id);
CREATE INDEX idx_rewards_is_active ON rewards(is_active);

-- Message de confirmation
SELECT 'Table rewards créée avec succès!' as message;