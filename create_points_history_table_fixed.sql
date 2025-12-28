-- ========================================================
-- MIGRATION : Créer une table pour l'historique des points (CORRIGÉ)
-- À exécuter dans le SQL Editor de votre dashboard Supabase
-- ========================================================

-- 1. Supprimer la table si elle existe (pour repartir proprement)
DROP TABLE IF EXISTS public.points_history CASCADE;

-- 2. Créer la table points_history pour suivre toutes les transactions
CREATE TABLE public.points_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL,
    company_id UUID NOT NULL,
    points_amount INTEGER NOT NULL,
    points_before INTEGER NOT NULL,
    points_after INTEGER NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    reward_id UUID
);

-- 3. Ajouter les contraintes de clés étrangères séparément
ALTER TABLE points_history 
    ADD CONSTRAINT fk_points_history_customer 
    FOREIGN KEY (customer_id) 
    REFERENCES customers(id) 
    ON DELETE CASCADE;

ALTER TABLE points_history 
    ADD CONSTRAINT fk_points_history_company 
    FOREIGN KEY (company_id) 
    REFERENCES users(id) 
    ON DELETE CASCADE;

ALTER TABLE points_history 
    ADD CONSTRAINT fk_points_history_reward 
    FOREIGN KEY (reward_id) 
    REFERENCES rewards(id) 
    ON DELETE SET NULL;

-- 4. Ajouter la contrainte CHECK séparément
ALTER TABLE points_history 
    ADD CONSTRAINT check_transaction_type 
    CHECK (transaction_type IN ('welcome', 'admin_add', 'admin_remove', 'earned', 'spent', 'expired'));

-- 5. Créer des index pour améliorer les performances
CREATE INDEX idx_points_history_customer_id ON points_history(customer_id);
CREATE INDEX idx_points_history_company_id ON points_history(company_id);
CREATE INDEX idx_points_history_created_at ON points_history(created_at DESC);
CREATE INDEX idx_points_history_type ON points_history(transaction_type);

-- 6. Ajouter des commentaires pour documenter
COMMENT ON TABLE points_history IS 'Historique complet des transactions de points de fidélité';
COMMENT ON COLUMN points_history.transaction_type IS 'Type de transaction : welcome (bienvenue), admin_add (ajout admin), admin_remove (retrait admin), earned (gagné), spent (dépensé), expired (expiré)';
COMMENT ON COLUMN points_history.points_amount IS 'Montant de la transaction (positif = ajout, négatif = retrait)';
COMMENT ON COLUMN points_history.created_by IS 'ID de l''administrateur qui a effectué la modification (null pour les transactions automatiques)';

-- 7. Activer RLS (Row Level Security)
ALTER TABLE points_history ENABLE ROW LEVEL SECURITY;

-- 8. Créer des politiques de sécurité permissives
-- Permettre la lecture à tous (temporaire pour le développement)
CREATE POLICY "Enable read access for all" ON points_history
    FOR SELECT
    USING (true);

-- Permettre l'insertion à tous (temporaire pour le développement)
CREATE POLICY "Enable insert for all" ON points_history
    FOR INSERT
    WITH CHECK (true);

-- 9. Créer une fonction pour enregistrer facilement les transactions
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

-- 10. Vérifier que tout est créé correctement
SELECT 
    'Table points_history créée avec succès' as message,
    COUNT(*) as nombre_colonnes
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'points_history';

-- 11. Vérifier la structure de la table
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'points_history'
ORDER BY ordinal_position;

-- 12. Test d'insertion (optionnel - décommentez et adaptez avec vos IDs)
/*
-- Récupérer un client et une entreprise pour tester
DO $$
DECLARE
    v_customer_id UUID;
    v_company_id UUID;
BEGIN
    -- Récupérer le premier client disponible
    SELECT c.id, c.company_id 
    INTO v_customer_id, v_company_id
    FROM customers c
    LIMIT 1;
    
    IF v_customer_id IS NOT NULL THEN
        -- Insérer un enregistrement de test
        INSERT INTO points_history (
            customer_id,
            company_id,
            points_amount,
            points_before,
            points_after,
            transaction_type,
            description
        ) VALUES (
            v_customer_id,
            v_company_id,
            50,
            0,
            50,
            'welcome',
            'Points de bienvenue - Test'
        );
        
        RAISE NOTICE 'Enregistrement de test créé avec succès pour le client %', v_customer_id;
    ELSE
        RAISE NOTICE 'Aucun client trouvé pour le test';
    END IF;
END $$;
*/