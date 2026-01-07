-- Désactiver le trigger de synchronisation automatique qui cause des problèmes
DROP TRIGGER IF EXISTS sync_reward_to_offer_trigger ON rewards;

-- Supprimer la fonction de synchronisation automatique
DROP FUNCTION IF EXISTS sync_reward_to_offer();

-- S'assurer que la table rewards existe avec tous les champs nécessaires
CREATE TABLE IF NOT EXISTS rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL DEFAULT 'general',
    points_required INTEGER NOT NULL DEFAULT 0,
    discount_percentage DECIMAL(5,2),
    discount_amount DECIMAL(10,2),
    is_active BOOLEAN DEFAULT true,
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,
    max_uses_per_customer INTEGER,
    total_uses INTEGER DEFAULT 0,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Créer les index si ils n'existent pas
CREATE INDEX IF NOT EXISTS idx_rewards_company_id ON rewards(company_id);
CREATE INDEX IF NOT EXISTS idx_rewards_is_active ON rewards(is_active);
CREATE INDEX IF NOT EXISTS idx_rewards_category ON rewards(category);

-- Ajouter les permissions
GRANT ALL ON rewards TO authenticated;
GRANT USAGE ON SEQUENCE rewards_id_seq TO authenticated;

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour updated_at
DROP TRIGGER IF EXISTS update_rewards_updated_at ON rewards;
CREATE TRIGGER update_rewards_updated_at
BEFORE UPDATE ON rewards
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();