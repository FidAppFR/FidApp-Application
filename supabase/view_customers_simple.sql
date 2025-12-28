-- REQUÊTES SIMPLES POUR VOIR LES CLIENTS
-- Exécutez chaque requête individuellement

-- ========================================
-- REQUÊTE 1: Nombre total de clients
-- ========================================
SELECT 
    COUNT(*) as total_clients,
    COUNT(DISTINCT company_id) as nombre_entreprises
FROM customers;

-- ========================================
-- REQUÊTE 2: Liste simple de tous les clients
-- ========================================
SELECT 
    c.id,
    c.first_name,
    c.last_name,
    c.email,
    c.points,
    u.company as entreprise
FROM customers c
LEFT JOIN users u ON c.company_id = u.id
ORDER BY c.created_at DESC;

-- ========================================
-- REQUÊTE 3: Clients par entreprise
-- ========================================
SELECT 
    u.company as entreprise,
    COUNT(c.id) as nombre_clients,
    COALESCE(AVG(c.points)::INTEGER, 0) as moyenne_points
FROM users u
LEFT JOIN customers c ON u.id = c.company_id
GROUP BY u.company
ORDER BY nombre_clients DESC;

-- ========================================
-- REQUÊTE 4: Top 10 clients (plus de points)
-- ========================================
SELECT 
    c.first_name,
    c.last_name,
    c.email,
    c.points,
    u.company as entreprise
FROM customers c
LEFT JOIN users u ON c.company_id = u.id
ORDER BY c.points DESC
LIMIT 10;

-- ========================================
-- REQUÊTE 5: Derniers clients inscrits
-- ========================================
SELECT 
    c.first_name,
    c.last_name,
    c.email,
    c.created_at as date_inscription,
    u.company as entreprise
FROM customers c
LEFT JOIN users u ON c.company_id = u.id
ORDER BY c.created_at DESC
LIMIT 20;