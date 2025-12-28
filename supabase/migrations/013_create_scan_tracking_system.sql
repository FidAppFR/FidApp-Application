-- Migration pour le système de compteur de scans QR
-- Ajoute le tracking des scans et les statistiques

-- Ajouter les colonnes de compteurs à la table users (entreprises)
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_scans INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_unique_clients INTEGER DEFAULT 0;

-- Ajouter les colonnes de scan à la table customers (clients)
ALTER TABLE customers ADD COLUMN IF NOT EXISTS total_scans INTEGER DEFAULT 0;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS last_scanned_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS first_scanned_at TIMESTAMP WITH TIME ZONE;

-- Créer la table d'historique des scans
CREATE TABLE IF NOT EXISTS qr_scan_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Qui a scanné
    scanned_by UUID REFERENCES users(id),
    scanned_by_name TEXT,
    
    -- Contexte du scan
    scan_type TEXT NOT NULL CHECK (scan_type IN ('points_add', 'reward_claim', 'check_balance', 'attendance', 'registration')),
    points_added INTEGER,
    euro_amount DECIMAL(10, 2),
    
    -- Métadonnées
    location TEXT,
    device TEXT,
    ip_address TEXT,
    user_agent TEXT,
    
    -- Timestamps
    scanned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Index pour les requêtes fréquentes
    CONSTRAINT valid_points CHECK (points_added IS NULL OR points_added >= 0),
    CONSTRAINT valid_amount CHECK (euro_amount IS NULL OR euro_amount >= 0)
);

-- Créer les index pour les performances
CREATE INDEX IF NOT EXISTS idx_scan_history_customer ON qr_scan_history(customer_id);
CREATE INDEX IF NOT EXISTS idx_scan_history_company ON qr_scan_history(company_id);
CREATE INDEX IF NOT EXISTS idx_scan_history_date ON qr_scan_history(scanned_at);
CREATE INDEX IF NOT EXISTS idx_scan_history_type ON qr_scan_history(scan_type);

-- Fonction pour incrémenter les compteurs lors d'un scan
CREATE OR REPLACE FUNCTION increment_scan_counters()
RETURNS TRIGGER AS $$
BEGIN
    -- Incrémenter le compteur du client
    UPDATE customers 
    SET 
        total_scans = COALESCE(total_scans, 0) + 1,
        last_scanned_at = NEW.scanned_at,
        first_scanned_at = COALESCE(first_scanned_at, NEW.scanned_at),
        updated_at = NOW()
    WHERE id = NEW.customer_id;
    
    -- Incrémenter le compteur de l'entreprise
    UPDATE users
    SET 
        total_scans = COALESCE(total_scans, 0) + 1,
        updated_at = NOW()
    WHERE id = NEW.company_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour incrémenter les compteurs
DROP TRIGGER IF EXISTS trigger_increment_scan_counters ON qr_scan_history;
CREATE TRIGGER trigger_increment_scan_counters
    AFTER INSERT ON qr_scan_history
    FOR EACH ROW
    EXECUTE FUNCTION increment_scan_counters();

-- Fonction pour mettre à jour le nombre de clients uniques scannés
CREATE OR REPLACE FUNCTION update_unique_clients_scanned()
RETURNS TRIGGER AS $$
DECLARE
    unique_count INTEGER;
BEGIN
    -- Compter le nombre de clients uniques avec au moins 1 scan
    SELECT COUNT(DISTINCT customer_id) INTO unique_count
    FROM qr_scan_history
    WHERE company_id = NEW.company_id;
    
    -- Mettre à jour
    UPDATE users
    SET total_unique_clients = unique_count
    WHERE id = NEW.company_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour les clients uniques
DROP TRIGGER IF EXISTS trigger_update_unique_clients ON qr_scan_history;
CREATE TRIGGER trigger_update_unique_clients
    AFTER INSERT ON qr_scan_history
    FOR EACH ROW
    EXECUTE FUNCTION update_unique_clients_scanned();

-- Vue pour les statistiques de scans par jour
CREATE OR REPLACE VIEW scan_stats_daily AS
SELECT 
    company_id,
    DATE(scanned_at) as scan_date,
    COUNT(*) as total_scans,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(points_added) as total_points_added,
    SUM(euro_amount) as total_euros
FROM qr_scan_history
GROUP BY company_id, DATE(scanned_at)
ORDER BY scan_date DESC;

-- Vue pour les top clients par nombre de scans
CREATE OR REPLACE VIEW top_scanned_customers AS
SELECT 
    h.company_id,
    h.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(*) as scan_count,
    MAX(h.scanned_at) as last_scan,
    MIN(h.scanned_at) as first_scan
FROM qr_scan_history h
JOIN customers c ON h.customer_id = c.id
GROUP BY h.company_id, h.customer_id, c.first_name, c.last_name, c.email
ORDER BY scan_count DESC;

-- Fonction pour obtenir les stats de scan pour une entreprise
CREATE OR REPLACE FUNCTION get_scan_stats(p_company_id UUID)
RETURNS TABLE (
    total_scans INTEGER,
    total_unique_clients INTEGER,
    scans_today INTEGER,
    scans_this_week INTEGER,
    scans_this_month INTEGER,
    average_scans_per_day NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE((SELECT total_scans FROM users WHERE id = p_company_id), 0) as total_scans,
        COALESCE((SELECT total_unique_clients FROM users WHERE id = p_company_id), 0) as total_unique_clients,
        COALESCE((
            SELECT COUNT(*)::INTEGER FROM qr_scan_history 
            WHERE company_id = p_company_id 
            AND DATE(scanned_at) = CURRENT_DATE
        ), 0) as scans_today,
        COALESCE((
            SELECT COUNT(*)::INTEGER FROM qr_scan_history 
            WHERE company_id = p_company_id 
            AND scanned_at >= date_trunc('week', CURRENT_DATE)
        ), 0) as scans_this_week,
        COALESCE((
            SELECT COUNT(*)::INTEGER FROM qr_scan_history 
            WHERE company_id = p_company_id 
            AND scanned_at >= date_trunc('month', CURRENT_DATE)
        ), 0) as scans_this_month,
        COALESCE((
            SELECT ROUND(COUNT(*)::NUMERIC / GREATEST(
                EXTRACT(EPOCH FROM (NOW() - MIN(scanned_at))) / 86400, 1
            ), 1) 
            FROM qr_scan_history 
            WHERE company_id = p_company_id
        ), 0) as average_scans_per_day;
END;
$$ LANGUAGE plpgsql;

-- Politique de sécurité RLS
ALTER TABLE qr_scan_history ENABLE ROW LEVEL SECURITY;

-- Les entreprises peuvent voir leurs propres scans
CREATE POLICY "Companies can view own scan history" ON qr_scan_history
    FOR SELECT
    USING (company_id = auth.uid());

-- Les entreprises peuvent créer des scans pour leurs clients
CREATE POLICY "Companies can create scans" ON qr_scan_history
    FOR INSERT
    WITH CHECK (company_id = auth.uid());

-- Grant permissions
GRANT ALL ON qr_scan_history TO authenticated;
GRANT ALL ON scan_stats_daily TO authenticated;
GRANT ALL ON top_scanned_customers TO authenticated;