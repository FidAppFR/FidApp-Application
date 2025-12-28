-- REQUÊTES POUR SUPPRIMER DES CUSTOMERS
-- ⚠️ ATTENTION: Ces requêtes suppriment définitivement les données !

-- ========================================
-- 1. VOIR d'abord le client avant suppression
-- ========================================
-- Remplacez 'email@example.com' par l'email du client
SELECT 
    c.id,
    c.first_name,
    c.last_name,
    c.email,
    c.points,
    u.company as entreprise,
    c.created_at
FROM customers c
LEFT JOIN users u ON c.company_id = u.id
WHERE c.email = 'email@example.com';

-- ========================================
-- 2. SUPPRIMER un client par email
-- ========================================
-- ⚠️ ATTENTION: Suppression définitive !
-- Remplacez 'email@example.com' par l'email à supprimer
DELETE FROM customers 
WHERE email = 'email@example.com';

-- ========================================
-- 3. SUPPRIMER plusieurs clients par email
-- ========================================
-- ⚠️ ATTENTION: Suppression définitive de plusieurs clients !
DELETE FROM customers 
WHERE email IN (
    'email1@example.com',
    'email2@example.com',
    'email3@example.com'
);

-- ========================================
-- 4. SUPPRIMER un client d'une entreprise spécifique
-- ========================================
-- Plus sûr car vérifie aussi l'entreprise
DELETE FROM customers 
WHERE email = 'email@example.com'
AND company_id = (
    SELECT id FROM users WHERE company = 'Nom de l\'entreprise'
);

-- ========================================
-- 5. SUPPRIMER tous les clients non vérifiés
-- ========================================
-- ⚠️ DANGER: Supprime TOUS les clients non vérifiés !
-- D'abord, voir combien seront supprimés:
SELECT COUNT(*) as clients_a_supprimer 
FROM customers 
WHERE is_verified = false OR is_verified IS NULL;

-- Puis supprimer (décommenter pour exécuter):
-- DELETE FROM customers 
-- WHERE is_verified = false OR is_verified IS NULL;

-- ========================================
-- 6. SUPPRIMER les clients inactifs (pas de visite depuis 30 jours)
-- ========================================
-- D'abord voir qui sera supprimé:
SELECT 
    email,
    first_name,
    last_name,
    last_visit_at,
    CURRENT_DATE - last_visit_at::date as jours_inactif
FROM customers 
WHERE last_visit_at < CURRENT_DATE - INTERVAL '30 days'
OR last_visit_at IS NULL;

-- Puis supprimer (décommenter pour exécuter):
-- DELETE FROM customers 
-- WHERE last_visit_at < CURRENT_DATE - INTERVAL '30 days'
-- OR last_visit_at IS NULL;

-- ========================================
-- 7. SUPPRIMER tous les clients d'une entreprise
-- ========================================
-- ⚠️ DANGER: Supprime TOUS les clients d'une entreprise !
-- Remplacez 'ID_ENTREPRISE' par l'ID réel
DELETE FROM customers 
WHERE company_id = 'ID_ENTREPRISE';

-- ========================================
-- 8. SUPPRESSION avec confirmation du nombre
-- ========================================
-- Méthode sûre qui retourne le nombre de lignes supprimées
WITH deleted AS (
    DELETE FROM customers 
    WHERE email = 'email@example.com'
    RETURNING *
)
SELECT COUNT(*) as nombre_supprimes FROM deleted;

-- ========================================
-- 9. VOIR les détails avant suppression multiple
-- ========================================
-- Pour vérifier avant de supprimer plusieurs clients
SELECT 
    c.email,
    c.first_name || ' ' || c.last_name as nom,
    c.points,
    u.company as entreprise
FROM customers c
LEFT JOIN users u ON c.company_id = u.id
WHERE c.email LIKE '%@test.com'  -- Exemple: tous les emails de test
ORDER BY c.email;

-- ========================================
-- 10. SUPPRESSION SOFT (alternative recommandée)
-- ========================================
-- Au lieu de supprimer, vous pouvez ajouter une colonne 'deleted_at'
-- D'abord ajouter la colonne si elle n'existe pas:
ALTER TABLE customers 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- Puis "supprimer" en marquant comme supprimé:
UPDATE customers 
SET deleted_at = NOW()
WHERE email = 'email@example.com';

-- Pour voir les clients "supprimés":
SELECT * FROM customers WHERE deleted_at IS NOT NULL;

-- Pour restaurer un client "supprimé":
UPDATE customers 
SET deleted_at = NULL
WHERE email = 'email@example.com';

-- ========================================
-- NOTES IMPORTANTES
-- ========================================
/*
⚠️ PRÉCAUTIONS:
1. TOUJOURS vérifier avec SELECT avant DELETE
2. Les suppressions sont DÉFINITIVES (sauf soft delete)
3. Les points_history liés seront aussi supprimés (CASCADE)
4. Faire une sauvegarde avant suppression massive
5. Préférer le soft delete pour garder l'historique

EXEMPLES D'UTILISATION:

-- Supprimer un client spécifique:
DELETE FROM customers WHERE email = 'jean.dupont@email.com';

-- Supprimer les comptes de test:
DELETE FROM customers WHERE email LIKE '%@test.%';

-- Supprimer les doublons (garde le plus récent):
DELETE FROM customers c1
USING customers c2
WHERE c1.email = c2.email 
AND c1.company_id = c2.company_id
AND c1.created_at < c2.created_at;
*/