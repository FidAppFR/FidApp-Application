-- ========================================================
-- MIGRATION : Créer une table pour l'historique des points
-- À exécuter dans le SQL Editor de votre dashboard Supabase
-- ========================================================

-- 1. Créer la table points_history pour suivre toutes les transactions
CREATE TABLE IF NOT EXISTS public.points_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    points_amount INTEGER NOT NULL, -- Positif pour ajout, négatif pour retrait
    points_before INTEGER NOT NULL, -- Solde avant la transaction
    points_after INTEGER NOT NULL,  -- Solde après la transaction
    transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN ('welcome', 'admin_add', 'admin_remove', 'earned', 'spent', 'expired')),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- ID de l'admin qui a fait la modification (si applicable)
    reward_id UUID REFERENCES rewards(id) ON DELETE SET NULL -- Si lié à une récompense
);

-- 2. Créer des index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_points_history_customer_id ON points_history(customer_id);
CREATE INDEX IF NOT EXISTS idx_points_history_company_id ON points_history(company_id);
CREATE INDEX IF NOT EXISTS idx_points_history_created_at ON points_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_points_history_type ON points_history(transaction_type);

-- 3. Ajouter des commentaires pour documenter
COMMENT ON TABLE points_history IS 'Historique complet des transactions de points de fidélité';
COMMENT ON COLUMN points_history.transaction_type IS 'Type de transaction : welcome (bienvenue), admin_add (ajout admin), admin_remove (retrait admin), earned (gagné), spent (dépensé), expired (expiré)';
COMMENT ON COLUMN points_history.points_amount IS 'Montant de la transaction (positif = ajout, négatif = retrait)';
COMMENT ON COLUMN points_history.created_by IS 'ID de l''administrateur qui a effectué la modification (null pour les transactions automatiques)';

-- 4. Créer une fonction pour enregistrer automatiquement les transactions
CREATE OR REPLACE FUNCTION log_points_transaction(
    p_customer_id UUID,
    p_company_id UUID,
    p_points_amount INTEGER,
    p_points_before INTEGER,
    p_points_after INTEGER,
    p_transaction_type VARCHAR(50),
    p_description TEXT DEFAULT NULL,
    p_created_by UUID DEFAULT NULL,
    p_reward_id UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_history_id UUID;
BEGIN
    INSERT INTO points_history (
        customer_id,
        company_id,
        points_amount,
        points_before,
        points_after,
        transaction_type,
        description,
        created_by,
        reward_id
    ) VALUES (
        p_customer_id,
        p_company_id,
        p_points_amount,
        p_points_before,
        p_points_after,
        p_transaction_type,
        p_description,
        p_created_by,
        p_reward_id
    ) RETURNING id INTO v_history_id;
    
    RETURN v_history_id;
END;
$$ LANGUAGE plpgsql;

-- 5. Vérifier que tout est créé correctement
SELECT 
    'Table points_history créée' as message,
    COUNT(*) as nombre_colonnes
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'points_history';

-- 6. Exemple d'insertion pour tester
-- INSERT INTO points_history (customer_id, company_id, points_amount, points_before, points_after, transaction_type, description)
-- VALUES (
--     'customer-uuid-here',
--     'company-uuid-here',
--     50,
--     0,
--     50,
--     'welcome',
--     'Points de bienvenue'
-- );