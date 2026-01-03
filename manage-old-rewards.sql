-- Script pour gérer les anciennes récompenses

-- 1. VOIR TOUTES VOS RÉCOMPENSES (anciennes)
-- Remplacez 'VOTRE_USER_ID' par votre ID utilisateur
SELECT 
    id,
    name,
    description,
    points_required,
    category,
    is_active,
    created_at,
    total_uses
FROM rewards
WHERE company_id = (SELECT id FROM users WHERE auth_id = auth.uid())
ORDER BY created_at DESC;

-- 2. VOIR UNIQUEMENT LES RÉCOMPENSES ACTIVES
SELECT 
    id,
    name,
    points_required,
    is_active
FROM rewards
WHERE company_id = (SELECT id FROM users WHERE auth_id = auth.uid())
AND is_active = true;

-- 3. DÉSACTIVER UNE RÉCOMPENSE SPÉCIFIQUE
-- Remplacez 'NOM_DE_LA_RECOMPENSE' par le nom exact de votre récompense
UPDATE rewards
SET is_active = false
WHERE company_id = (SELECT id FROM users WHERE auth_id = auth.uid())
AND name = 'NOM_DE_LA_RECOMPENSE';

-- 4. SUPPRIMER UNE RÉCOMPENSE PAR SON NOM
-- ⚠️ ATTENTION: Suppression définitive!
-- Remplacez 'NOM_DE_LA_RECOMPENSE' par le nom exact
DELETE FROM rewards
WHERE company_id = (SELECT id FROM users WHERE auth_id = auth.uid())
AND name = 'NOM_DE_LA_RECOMPENSE';

-- 5. SUPPRIMER TOUTES LES RÉCOMPENSES INACTIVES
DELETE FROM rewards
WHERE company_id = (SELECT id FROM users WHERE auth_id = auth.uid())
AND is_active = false;

-- 6. VOIR LES NOUVELLES OFFRES (pour comparaison)
SELECT 
    id,
    name,
    description,
    points_cost,
    type,
    is_active,
    created_at
FROM offers
WHERE company_id = (SELECT id FROM users WHERE auth_id = auth.uid())
ORDER BY created_at DESC;