-- ========================================================
-- CORRECTION COMPLÈTE : Table points_history et permissions
-- À exécuter dans le SQL Editor de votre dashboard Supabase
-- ========================================================

-- 1. Supprimer les anciennes politiques si elles existent
DROP POLICY IF EXISTS "Customers can view own history" ON points_history;
DROP POLICY IF EXISTS "Companies can insert history" ON points_history;

-- 2. Créer la table points_history si elle n'existe pas
CREATE TABLE IF NOT EXISTS public.points_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    points_amount INTEGER NOT NULL,
    points_before INTEGER NOT NULL,
    points_after INTEGER NOT NULL,
    transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN ('welcome', 'admin_add', 'admin_remove', 'earned', 'spent', 'expired')),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    reward_id UUID REFERENCES rewards(id) ON DELETE SET NULL
);

-- 3. Créer les index pour les performances
CREATE INDEX IF NOT EXISTS idx_points_history_customer_id ON points_history(customer_id);
CREATE INDEX IF NOT EXISTS idx_points_history_company_id ON points_history(company_id);
CREATE INDEX IF NOT EXISTS idx_points_history_created_at ON points_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_points_history_type ON points_history(transaction_type);

-- 4. Activer RLS
ALTER TABLE points_history ENABLE ROW LEVEL SECURITY;

-- 5. Créer des politiques plus permissives pour le développement
-- Politique pour SELECT (lecture)
CREATE POLICY "Enable read access for all users" ON points_history
    FOR SELECT
    USING (true);

-- Politique pour INSERT (insertion)
CREATE POLICY "Enable insert for all users" ON points_history
    FOR INSERT
    WITH CHECK (true);

-- Politique pour UPDATE (mise à jour)
CREATE POLICY "Enable update for all users" ON points_history
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- 6. Fonction pour faciliter l'insertion d'historique
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

-- 7. Créer un déclencheur pour enregistrer automatiquement les changements de points
CREATE OR REPLACE FUNCTION trigger_log_points_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Ne rien faire si les points n'ont pas changé
    IF OLD.points = NEW.points THEN
        RETURN NEW;
    END IF;
    
    -- Déterminer le type de transaction
    DECLARE
        v_transaction_type VARCHAR(50);
        v_description TEXT;
    BEGIN
        IF NEW.points > OLD.points THEN
            v_transaction_type := 'admin_add';
            v_description := 'Points ajoutés par l''administrateur';
        ELSE
            v_transaction_type := 'admin_remove';
            v_description := 'Points retirés par l''administrateur';
        END IF;
        
        -- Insérer dans l'historique
        INSERT INTO points_history (
            customer_id,
            company_id,
            points_amount,
            points_before,
            points_after,
            transaction_type,
            description
        ) VALUES (
            NEW.id,
            NEW.company_id,
            NEW.points - OLD.points,
            OLD.points,
            NEW.points,
            v_transaction_type,
            v_description
        );
    END;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Note: Le déclencheur automatique est commenté car il peut créer des doublons
-- avec les insertions manuelles depuis l'application
-- Décommentez si vous voulez l'automatisation complète

-- DROP TRIGGER IF EXISTS log_customer_points_change ON customers;
-- CREATE TRIGGER log_customer_points_change
--     AFTER UPDATE OF points ON customers
--     FOR EACH ROW
--     EXECUTE FUNCTION trigger_log_points_change();

-- 8. Insérer quelques données de test (optionnel)
-- Remplacez les UUID par de vraies valeurs de votre base
/*
DO $$
DECLARE
    v_customer_id UUID;
    v_company_id UUID;
BEGIN
    -- Récupérer un client et une entreprise existants
    SELECT c.id, c.company_id INTO v_customer_id, v_company_id
    FROM customers c
    LIMIT 1;
    
    IF v_customer_id IS NOT NULL THEN
        -- Insérer un historique de test
        INSERT INTO points_history (
            customer_id,
            company_id,
            points_amount,
            points_before,
            points_after,
            transaction_type,
            description
        ) VALUES 
        (v_customer_id, v_company_id, 100, 0, 100, 'admin_add', 'Test - Points ajoutés'),
        (v_customer_id, v_company_id, -50, 100, 50, 'spent', 'Test - Récompense échangée'),
        (v_customer_id, v_company_id, 25, 50, 75, 'earned', 'Test - Points gagnés');
        
        RAISE NOTICE 'Données de test insérées pour le client %', v_customer_id;
    END IF;
END $$;
*/

-- 9. Vérifier que tout fonctionne
SELECT 
    'Table créée' as status,
    COUNT(*) as nombre_enregistrements,
    COUNT(DISTINCT customer_id) as clients_uniques,
    COUNT(DISTINCT transaction_type) as types_transactions
FROM points_history;

-- 10. Afficher les derniers enregistrements
SELECT 
    ph.id,
    ph.created_at,
    c.first_name || ' ' || c.last_name as customer,
    ph.transaction_type,
    ph.points_amount,
    ph.points_before || ' → ' || ph.points_after as changement,
    ph.description
FROM points_history ph
JOIN customers c ON c.id = ph.customer_id
ORDER BY ph.created_at DESC
LIMIT 20;