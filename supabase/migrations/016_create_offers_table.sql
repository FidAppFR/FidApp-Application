-- Migration pour créer la table des offres et récompenses
-- Permet aux entreprises de créer des offres échangeables contre des points

-- Table pour les offres et récompenses
CREATE TABLE IF NOT EXISTS offers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Informations de l'offre
    name TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('discount', 'gift', 'points', 'upgrade')),
    
    -- Valeur de l'offre
    value DECIMAL(10, 2), -- Pour les pourcentages ou montants
    value_text TEXT, -- Pour les descriptions textuelles (ex: "1 café offert")
    
    -- Coût en points
    points_cost INTEGER NOT NULL CHECK (points_cost >= 0),
    
    -- Conditions
    conditions TEXT,
    
    -- Période de validité
    start_date DATE,
    end_date DATE,
    
    -- Limites d'utilisation
    max_uses INTEGER, -- NULL = illimité
    max_uses_per_customer INTEGER, -- NULL = illimité
    
    -- État et statistiques
    is_active BOOLEAN DEFAULT true,
    total_uses INTEGER DEFAULT 0,
    
    -- Ordre d'affichage
    display_order INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table pour tracker l'utilisation des offres
CREATE TABLE IF NOT EXISTS offer_redemptions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    offer_id UUID NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Détails de l'échange
    points_spent INTEGER NOT NULL,
    redeemed_by UUID REFERENCES users(id),
    redeemed_by_name TEXT,
    
    -- Code de validation unique
    redemption_code TEXT UNIQUE DEFAULT substr(md5(random()::text), 1, 8),
    
    -- État de l'échange
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'used', 'expired', 'cancelled')),
    used_at TIMESTAMP WITH TIME ZONE,
    
    -- Notes
    notes TEXT,
    
    -- Timestamps
    redeemed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() + INTERVAL '30 days'
);

-- Index pour les performances
CREATE INDEX idx_offers_company ON offers(company_id);
CREATE INDEX idx_offers_active ON offers(is_active);
CREATE INDEX idx_offers_dates ON offers(start_date, end_date);
CREATE INDEX idx_redemptions_customer ON offer_redemptions(customer_id);
CREATE INDEX idx_redemptions_offer ON offer_redemptions(offer_id);
CREATE INDEX idx_redemptions_code ON offer_redemptions(redemption_code);
CREATE INDEX idx_redemptions_status ON offer_redemptions(status);

-- Fonction pour échanger une offre
CREATE OR REPLACE FUNCTION redeem_offer(
    p_customer_id UUID,
    p_offer_id UUID,
    p_redeemed_by UUID DEFAULT NULL,
    p_redeemed_by_name TEXT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    redemption_code TEXT,
    remaining_points INTEGER
) AS $$
DECLARE
    v_customer customers%ROWTYPE;
    v_offer offers%ROWTYPE;
    v_company_id UUID;
    v_customer_redemptions INTEGER;
    v_total_redemptions INTEGER;
    v_redemption_code TEXT;
BEGIN
    -- Récupérer le client
    SELECT * INTO v_customer FROM customers WHERE id = p_customer_id;
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Client non trouvé', NULL::TEXT, 0;
        RETURN;
    END IF;
    
    v_company_id := v_customer.company_id;
    
    -- Récupérer l'offre
    SELECT * INTO v_offer FROM offers 
    WHERE id = p_offer_id 
      AND company_id = v_company_id
      AND is_active = true;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Offre non trouvée ou inactive', NULL::TEXT, v_customer.points;
        RETURN;
    END IF;
    
    -- Vérifier les dates de validité
    IF v_offer.start_date IS NOT NULL AND v_offer.start_date > CURRENT_DATE THEN
        RETURN QUERY SELECT false, 'Offre pas encore valide', NULL::TEXT, v_customer.points;
        RETURN;
    END IF;
    
    IF v_offer.end_date IS NOT NULL AND v_offer.end_date < CURRENT_DATE THEN
        RETURN QUERY SELECT false, 'Offre expirée', NULL::TEXT, v_customer.points;
        RETURN;
    END IF;
    
    -- Vérifier les points du client
    IF v_customer.points < v_offer.points_cost THEN
        RETURN QUERY SELECT false, 'Points insuffisants', NULL::TEXT, v_customer.points;
        RETURN;
    END IF;
    
    -- Vérifier les limites d'utilisation par client
    IF v_offer.max_uses_per_customer IS NOT NULL THEN
        SELECT COUNT(*) INTO v_customer_redemptions
        FROM offer_redemptions
        WHERE customer_id = p_customer_id
          AND offer_id = p_offer_id
          AND status != 'cancelled';
        
        IF v_customer_redemptions >= v_offer.max_uses_per_customer THEN
            RETURN QUERY SELECT false, 'Limite d''utilisation atteinte pour ce client', NULL::TEXT, v_customer.points;
            RETURN;
        END IF;
    END IF;
    
    -- Vérifier les limites d'utilisation globales
    IF v_offer.max_uses IS NOT NULL THEN
        SELECT COUNT(*) INTO v_total_redemptions
        FROM offer_redemptions
        WHERE offer_id = p_offer_id
          AND status != 'cancelled';
        
        IF v_total_redemptions >= v_offer.max_uses THEN
            RETURN QUERY SELECT false, 'Offre épuisée', NULL::TEXT, v_customer.points;
            RETURN;
        END IF;
    END IF;
    
    -- Déduire les points
    UPDATE customers
    SET points = points - v_offer.points_cost,
        updated_at = NOW()
    WHERE id = p_customer_id;
    
    -- Générer un code unique
    v_redemption_code := upper(substr(md5(random()::text || now()::text), 1, 8));
    
    -- Créer l'échange
    INSERT INTO offer_redemptions (
        offer_id,
        customer_id,
        company_id,
        points_spent,
        redeemed_by,
        redeemed_by_name,
        redemption_code
    ) VALUES (
        p_offer_id,
        p_customer_id,
        v_company_id,
        v_offer.points_cost,
        p_redeemed_by,
        p_redeemed_by_name,
        v_redemption_code
    );
    
    -- Mettre à jour les statistiques
    UPDATE offers
    SET total_uses = total_uses + 1,
        updated_at = NOW()
    WHERE id = p_offer_id;
    
    RETURN QUERY SELECT 
        true, 
        'Offre échangée avec succès', 
        v_redemption_code,
        v_customer.points - v_offer.points_cost;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour valider un code d'échange
CREATE OR REPLACE FUNCTION validate_redemption_code(
    p_code TEXT,
    p_validated_by UUID DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    offer_name TEXT,
    customer_name TEXT
) AS $$
DECLARE
    v_redemption offer_redemptions%ROWTYPE;
    v_offer offers%ROWTYPE;
    v_customer customers%ROWTYPE;
BEGIN
    -- Récupérer l'échange
    SELECT * INTO v_redemption
    FROM offer_redemptions
    WHERE redemption_code = upper(p_code);
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Code invalide', NULL::TEXT, NULL::TEXT;
        RETURN;
    END IF;
    
    -- Vérifier le statut
    IF v_redemption.status = 'used' THEN
        RETURN QUERY SELECT false, 'Code déjà utilisé', NULL::TEXT, NULL::TEXT;
        RETURN;
    END IF;
    
    IF v_redemption.status = 'cancelled' THEN
        RETURN QUERY SELECT false, 'Code annulé', NULL::TEXT, NULL::TEXT;
        RETURN;
    END IF;
    
    IF v_redemption.status = 'expired' OR 
       (v_redemption.expires_at IS NOT NULL AND v_redemption.expires_at < NOW()) THEN
        -- Marquer comme expiré si ce n'est pas déjà fait
        UPDATE offer_redemptions
        SET status = 'expired'
        WHERE id = v_redemption.id;
        
        RETURN QUERY SELECT false, 'Code expiré', NULL::TEXT, NULL::TEXT;
        RETURN;
    END IF;
    
    -- Récupérer les infos
    SELECT * INTO v_offer FROM offers WHERE id = v_redemption.offer_id;
    SELECT * INTO v_customer FROM customers WHERE id = v_redemption.customer_id;
    
    -- Marquer comme utilisé
    UPDATE offer_redemptions
    SET status = 'used',
        used_at = NOW()
    WHERE id = v_redemption.id;
    
    RETURN QUERY SELECT 
        true, 
        'Code validé avec succès',
        v_offer.name,
        v_customer.first_name || ' ' || v_customer.last_name;
END;
$$ LANGUAGE plpgsql;

-- Vue pour les statistiques des offres
CREATE OR REPLACE VIEW offer_statistics AS
SELECT 
    o.id,
    o.company_id,
    o.name,
    o.type,
    o.points_cost,
    o.total_uses,
    COUNT(DISTINCT r.customer_id) as unique_customers,
    SUM(r.points_spent) as total_points_spent,
    COUNT(CASE WHEN r.status = 'pending' THEN 1 END) as pending_redemptions,
    COUNT(CASE WHEN r.status = 'used' THEN 1 END) as used_redemptions,
    COUNT(CASE WHEN r.status = 'expired' THEN 1 END) as expired_redemptions
FROM offers o
LEFT JOIN offer_redemptions r ON o.id = r.offer_id
GROUP BY o.id, o.company_id, o.name, o.type, o.points_cost, o.total_uses;

-- Politique de sécurité RLS
ALTER TABLE offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE offer_redemptions ENABLE ROW LEVEL SECURITY;

-- Les entreprises peuvent gérer leurs propres offres
CREATE POLICY "Companies can manage own offers" ON offers
    FOR ALL
    USING (company_id = auth.uid());

CREATE POLICY "Companies can view own redemptions" ON offer_redemptions
    FOR SELECT
    USING (company_id = auth.uid());

-- Grant permissions
GRANT ALL ON offers TO authenticated;
GRANT ALL ON offer_redemptions TO authenticated;
GRANT ALL ON offer_statistics TO authenticated;