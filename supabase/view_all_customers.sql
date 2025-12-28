-- REQUÊTES POUR VOIR TOUS LES CLIENTS INSCRITS DANS SUPABASE

-- ========================================
-- 1. VUE GLOBALE : Nombre total de clients
-- ========================================
SELECT 
    COUNT(*) as total_clients,
    COUNT(DISTINCT company_id) as nombre_entreprises,
    COUNT(CASE WHEN is_verified = true THEN 1 END) as clients_verifies,
    COUNT(CASE WHEN is_verified = false OR is_verified IS NULL THEN 1 END) as clients_non_verifies
FROM customers;

-- ========================================
-- 2. LISTE DÉTAILLÉE DE TOUS LES CLIENTS
-- ========================================
SELECT 
    c.id,
    c.first_name || ' ' || c.last_name as nom_complet,
    c.email,
    c.phone,
    c.points as points_actuels,
    c.total_points_earned as total_points_gagnes,
    c.total_points_spent as total_points_depenses,
    c.is_verified as compte_verifie,
    c.created_at as date_inscription,
    c.last_visit_at as derniere_visite,
    u.company as entreprise,
    u.id as entreprise_id
FROM customers c
LEFT JOIN users u ON c.company_id = u.id
ORDER BY c.created_at DESC;

-- ========================================
-- 3. STATISTIQUES PAR ENTREPRISE
-- ========================================
SELECT 
    u.company as nom_entreprise,
    u.id as entreprise_id,
    COUNT(c.id) as nombre_clients,
    AVG(c.points) as moyenne_points,
    SUM(c.points) as total_points_distribues,
    MAX(c.points) as client_max_points,
    MIN(c.created_at) as premier_client_inscrit,
    MAX(c.created_at) as dernier_client_inscrit
FROM users u
LEFT JOIN customers c ON u.id = c.company_id
GROUP BY u.id, u.company
ORDER BY nombre_clients DESC;

-- ========================================
-- 4. CLIENTS LES PLUS FIDÈLES (TOP 10)
-- ========================================
SELECT 
    c.first_name || ' ' || c.last_name as nom_client,
    c.email,
    c.points as points_actuels,
    c.total_points_earned as total_points_gagnes,
    c.total_points_spent as total_points_depenses,
    u.company as entreprise,
    c.created_at as membre_depuis,
    CASE 
        WHEN c.last_visit_at IS NOT NULL 
        THEN (CURRENT_DATE - c.last_visit_at::date) || ' jours'
        ELSE 'Jamais connecté'
    END as derniere_activite
FROM customers c
LEFT JOIN users u ON c.company_id = u.id
WHERE c.is_verified = true
ORDER BY c.points DESC
LIMIT 10;

-- ========================================
-- 5. ACTIVITÉ RÉCENTE (derniers 7 jours)
-- ========================================
SELECT 
    DATE(c.created_at) as date,
    COUNT(*) as nouvelles_inscriptions,
    COUNT(CASE WHEN c.is_verified = true THEN 1 END) as comptes_verifies
FROM customers c
WHERE c.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(c.created_at)
ORDER BY date DESC;

-- ========================================
-- 6. CLIENTS NON VÉRIFIÉS
-- ========================================
SELECT 
    c.first_name || ' ' || c.last_name as nom,
    c.email,
    u.company as entreprise,
    c.created_at as inscrit_le,
    CASE 
        WHEN c.last_otp_sent_at IS NOT NULL 
        THEN 'OTP envoyé le ' || TO_CHAR(c.last_otp_sent_at, 'DD/MM/YYYY HH24:MI')
        ELSE 'OTP jamais envoyé'
    END as statut_otp
FROM customers c
LEFT JOIN users u ON c.company_id = u.id
WHERE c.is_verified = false OR c.is_verified IS NULL
ORDER BY c.created_at DESC;

-- ========================================
-- 7. DISTRIBUTION DES POINTS
-- ========================================
SELECT 
    CASE 
        WHEN points = 0 THEN '0 points'
        WHEN points BETWEEN 1 AND 50 THEN '1-50 points'
        WHEN points BETWEEN 51 AND 100 THEN '51-100 points'
        WHEN points BETWEEN 101 AND 200 THEN '101-200 points'
        WHEN points BETWEEN 201 AND 500 THEN '201-500 points'
        WHEN points > 500 THEN 'Plus de 500 points'
    END as tranche_points,
    COUNT(*) as nombre_clients,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) as pourcentage
FROM customers
GROUP BY 
    CASE 
        WHEN points = 0 THEN '0 points'
        WHEN points BETWEEN 1 AND 50 THEN '1-50 points'
        WHEN points BETWEEN 51 AND 100 THEN '51-100 points'
        WHEN points BETWEEN 101 AND 200 THEN '101-200 points'
        WHEN points BETWEEN 201 AND 500 THEN '201-500 points'
        WHEN points > 500 THEN 'Plus de 500 points'
    END
ORDER BY 
    MIN(points);

-- ========================================
-- 8. HISTORIQUE DES POINTS (si la table existe)
-- ========================================
-- Décommenter si la table points_history existe
/*
SELECT 
    ph.type as type_transaction,
    COUNT(*) as nombre_transactions,
    SUM(ABS(ph.amount)) as total_points,
    AVG(ABS(ph.amount)) as moyenne_points
FROM points_history ph
GROUP BY ph.type
ORDER BY nombre_transactions DESC;
*/

-- ========================================
-- 9. RÉSUMÉ GLOBAL
-- ========================================
WITH stats AS (
    SELECT 
        COUNT(*) as total_clients,
        COUNT(DISTINCT company_id) as total_entreprises,
        AVG(points) as moyenne_points_global,
        SUM(points) as total_points_en_circulation,
        COUNT(CASE WHEN is_verified = true THEN 1 END) as clients_actifs
    FROM customers
)
SELECT 
    'Total Clients' as metrique,
    total_clients::text as valeur
FROM stats
UNION ALL
SELECT 
    'Entreprises actives',
    total_entreprises::text
FROM stats
UNION ALL
SELECT 
    'Moyenne points/client',
    ROUND(moyenne_points_global, 2)::text
FROM stats
UNION ALL
SELECT 
    'Total points en circulation',
    total_points_en_circulation::text
FROM stats
UNION ALL
SELECT 
    'Taux d''activation',
    ROUND(clients_actifs * 100.0 / NULLIF(total_clients, 0), 2) || '%'
FROM stats;

-- ========================================
-- MESSAGE FINAL
-- ========================================
SELECT 
    '✅ Requêtes exécutées avec succès!' as status,
    'Utilisez les requêtes ci-dessus pour analyser vos données clients' as message;