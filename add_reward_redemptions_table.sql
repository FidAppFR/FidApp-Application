-- ========================================================
-- MIGRATION : Ajouter une table pour suivre les échanges de récompenses
-- À exécuter dans le SQL Editor de votre dashboard Supabase
-- ========================================================

-- 1. Créer la table reward_redemptions pour suivre les échanges
CREATE TABLE IF NOT EXISTS public.reward_redemptions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    reward_id UUID NOT NULL REFERENCES rewards(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    points_used INTEGER NOT NULL,
    redeemed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'cancelled')),
    notes TEXT
);

-- 2. Créer des index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_redemptions_reward_id ON reward_redemptions(reward_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_customer_id ON reward_redemptions(customer_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_company_id ON reward_redemptions(company_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_redeemed_at ON reward_redemptions(redeemed_at DESC);

-- 3. Ajouter des commentaires pour documenter
COMMENT ON TABLE reward_redemptions IS 'Table pour suivre tous les échanges de récompenses';
COMMENT ON COLUMN reward_redemptions.status IS 'Statut de l''échange : pending, completed, cancelled';
COMMENT ON COLUMN reward_redemptions.points_used IS 'Nombre de points utilisés pour cette récompense';

-- 4. Créer une vue pour obtenir facilement les statistiques des récompenses
CREATE OR REPLACE VIEW reward_statistics AS
SELECT 
    r.id,
    r.name,
    r.description,
    r.category,
    r.points_required,
    r.company_id,
    r.is_active,
    COUNT(rr.id) as total_redemptions,
    COALESCE(SUM(rr.points_used), 0) as total_points_used,
    MAX(rr.redeemed_at) as last_redeemed_at
FROM rewards r
LEFT JOIN reward_redemptions rr ON r.id = rr.reward_id AND rr.status = 'completed'
GROUP BY r.id, r.name, r.description, r.category, r.points_required, r.company_id, r.is_active;

-- 5. Vérifier que tout est créé correctement
SELECT 
    'Table reward_redemptions créée' as message,
    COUNT(*) as nombre_colonnes
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'reward_redemptions';

-- Note : Pour tester, vous pouvez insérer des données de test
-- INSERT INTO reward_redemptions (reward_id, customer_id, company_id, points_used)
-- SELECT 
--     (SELECT id FROM rewards WHERE company_id = 'votre-company-id' LIMIT 1),
--     (SELECT id FROM customers WHERE company_id = 'votre-company-id' LIMIT 1),
--     'votre-company-id',
--     100;