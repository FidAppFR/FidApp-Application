-- Correction des politiques RLS pour la table offers
-- Permet aux utilisateurs authentifiés de gérer leurs offres

-- D'abord, s'assurer que RLS est activé sur la table
ALTER TABLE offers ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes politiques si elles existent
DROP POLICY IF EXISTS "Companies can view their own offers" ON offers;
DROP POLICY IF EXISTS "Companies can create their own offers" ON offers;
DROP POLICY IF EXISTS "Companies can update their own offers" ON offers;
DROP POLICY IF EXISTS "Companies can delete their own offers" ON offers;
DROP POLICY IF EXISTS "Public can view active offers" ON offers;

-- Politique pour voir les offres
-- Les entreprises peuvent voir leurs propres offres
CREATE POLICY "Companies can view their own offers" ON offers
    FOR SELECT
    USING (
        auth.uid() IN (
            SELECT auth_id FROM users WHERE id = offers.company_id
        )
    );

-- Politique pour créer des offres
-- Les utilisateurs authentifiés peuvent créer des offres pour leur entreprise
CREATE POLICY "Companies can create their own offers" ON offers
    FOR INSERT
    WITH CHECK (
        auth.uid() IN (
            SELECT auth_id FROM users WHERE id = offers.company_id
        )
    );

-- Politique pour mettre à jour les offres
-- Les entreprises peuvent modifier leurs propres offres
CREATE POLICY "Companies can update their own offers" ON offers
    FOR UPDATE
    USING (
        auth.uid() IN (
            SELECT auth_id FROM users WHERE id = offers.company_id
        )
    )
    WITH CHECK (
        auth.uid() IN (
            SELECT auth_id FROM users WHERE id = offers.company_id
        )
    );

-- Politique pour supprimer les offres
-- Les entreprises peuvent supprimer leurs propres offres
CREATE POLICY "Companies can delete their own offers" ON offers
    FOR DELETE
    USING (
        auth.uid() IN (
            SELECT auth_id FROM users WHERE id = offers.company_id
        )
    );

-- Politique publique pour voir les offres actives
-- Tout le monde peut voir les offres actives (pour les clients)
CREATE POLICY "Public can view active offers" ON offers
    FOR SELECT
    USING (is_active = true);

-- Donner les permissions nécessaires
GRANT ALL ON offers TO authenticated;
GRANT SELECT ON offers TO anon;

-- S'assurer que la séquence est accessible si elle existe
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'offers_id_seq') THEN
        GRANT USAGE ON SEQUENCE offers_id_seq TO authenticated;
    END IF;
END $$;