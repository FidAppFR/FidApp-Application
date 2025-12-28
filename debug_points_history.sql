-- ========================================================
-- SCRIPT DE DÉBOGAGE : Vérifier et créer la table points_history
-- À exécuter dans le SQL Editor de votre dashboard Supabase
-- ========================================================

-- 1. Vérifier si la table points_history existe
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'points_history'
) as table_exists;

-- 2. Si elle n'existe pas, la créer
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

-- 3. Créer les index si nécessaire
CREATE INDEX IF NOT EXISTS idx_points_history_customer_id ON points_history(customer_id);
CREATE INDEX IF NOT EXISTS idx_points_history_company_id ON points_history(company_id);
CREATE INDEX IF NOT EXISTS idx_points_history_created_at ON points_history(created_at DESC);

-- 4. Vérifier les permissions RLS (Row Level Security)
ALTER TABLE points_history ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre aux clients de voir leur propre historique
CREATE POLICY IF NOT EXISTS "Customers can view own history" ON points_history
    FOR SELECT
    USING (true);  -- Temporairement permettre tout accès en lecture

-- Politique pour permettre aux entreprises d'insérer
CREATE POLICY IF NOT EXISTS "Companies can insert history" ON points_history
    FOR INSERT
    WITH CHECK (true);  -- Temporairement permettre toute insertion

-- 5. Insérer des données de test pour vérifier
-- Remplacez les IDs par des valeurs réelles de votre base
/*
INSERT INTO points_history (
    customer_id, 
    company_id, 
    points_amount, 
    points_before, 
    points_after, 
    transaction_type, 
    description
) VALUES (
    'CUSTOMER_ID_ICI',  -- Remplacer par un vrai customer_id
    'COMPANY_ID_ICI',   -- Remplacer par un vrai company_id
    50,
    0,
    50,
    'admin_add',
    'Test - Points ajoutés par admin'
);
*/

-- 6. Vérifier le contenu de la table
SELECT 
    ph.*,
    c.first_name || ' ' || c.last_name as customer_name,
    u.company as company_name
FROM points_history ph
LEFT JOIN customers c ON c.id = ph.customer_id
LEFT JOIN users u ON u.id = ph.company_id
ORDER BY ph.created_at DESC
LIMIT 10;

-- 7. Compter les enregistrements par type
SELECT 
    transaction_type,
    COUNT(*) as count
FROM points_history
GROUP BY transaction_type;