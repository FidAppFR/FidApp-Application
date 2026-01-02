-- Migration pour créer les paramètres de bonus personnalisables
-- Permet aux entreprises de personnaliser les points de chaque type de bonus

-- Table pour les paramètres de bonus par entreprise
CREATE TABLE IF NOT EXISTS bonus_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Points de bienvenue
    welcome_enabled BOOLEAN DEFAULT true,
    welcome_points INTEGER DEFAULT 50 CHECK (welcome_points >= 0),
    welcome_message TEXT DEFAULT 'Bienvenue dans notre programme de fidélité !',
    welcome_conditions TEXT,
    
    -- Bonus anniversaire
    birthday_enabled BOOLEAN DEFAULT true,
    birthday_points INTEGER DEFAULT 100 CHECK (birthday_points >= 0),
    birthday_message TEXT DEFAULT 'Joyeux anniversaire ! Voici votre cadeau.',
    birthday_auto_apply TEXT DEFAULT 'same_day' CHECK (birthday_auto_apply IN ('same_day', 'same_month', 'week_before', 'manual')),
    
    -- Bonus parrainage
    referral_enabled BOOLEAN DEFAULT true,
    referral_points_referrer INTEGER DEFAULT 75 CHECK (referral_points_referrer >= 0), -- Points pour le parrain
    referral_points_referee INTEGER DEFAULT 50 CHECK (referral_points_referee >= 0),  -- Points pour le filleul
    referral_message TEXT DEFAULT 'Merci de nous recommander !',
    referral_conditions TEXT,
    
    -- Événements spéciaux
    special_events_enabled BOOLEAN DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Une seule config par entreprise
    CONSTRAINT unique_bonus_settings_per_company UNIQUE (company_id)
);

-- Table pour les événements spéciaux personnalisés
CREATE TABLE IF NOT EXISTS special_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Détails de l'événement
    name TEXT NOT NULL,
    description TEXT,
    points INTEGER NOT NULL CHECK (points > 0),
    
    -- Période de validité
    start_date DATE,
    end_date DATE,
    
    -- Conditions
    is_active BOOLEAN DEFAULT true,
    auto_apply BOOLEAN DEFAULT false,
    conditions TEXT,
    max_uses_per_customer INTEGER, -- NULL = illimité
    
    -- Stats
    total_uses INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table pour tracker les bonus appliqués
CREATE TABLE IF NOT EXISTS applied_bonuses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Type de bonus
    bonus_type TEXT NOT NULL CHECK (bonus_type IN ('welcome', 'birthday', 'referral', 'special_event')),
    special_event_id UUID REFERENCES special_events(id) ON DELETE SET NULL,
    
    -- Détails
    points_awarded INTEGER NOT NULL,
    applied_by UUID REFERENCES users(id),
    applied_by_name TEXT,
    
    -- Pour le parrainage
    referrer_id UUID REFERENCES customers(id), -- Le parrain
    referee_id UUID REFERENCES customers(id),  -- Le filleul
    
    -- Timestamps
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Éviter les doublons
    CONSTRAINT unique_welcome_per_customer UNIQUE (customer_id, company_id, bonus_type)
        DEFERRABLE INITIALLY DEFERRED
);

-- Créer l'index pour les requêtes fréquentes
CREATE INDEX idx_bonus_settings_company ON bonus_settings(company_id);
CREATE INDEX idx_special_events_company ON special_events(company_id);
CREATE INDEX idx_special_events_active ON special_events(is_active);
CREATE INDEX idx_special_events_dates ON special_events(start_date, end_date);
CREATE INDEX idx_applied_bonuses_customer ON applied_bonuses(customer_id);
CREATE INDEX idx_applied_bonuses_company ON applied_bonuses(company_id);
CREATE INDEX idx_applied_bonuses_type ON applied_bonuses(bonus_type);

-- Fonction pour initialiser les paramètres de bonus pour une entreprise
CREATE OR REPLACE FUNCTION init_bonus_settings_for_company()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO bonus_settings (company_id)
    VALUES (NEW.id)
    ON CONFLICT (company_id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour créer automatiquement les paramètres lors de la création d'une entreprise
DROP TRIGGER IF EXISTS trigger_init_bonus_settings ON users;
CREATE TRIGGER trigger_init_bonus_settings
    AFTER INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION init_bonus_settings_for_company();

-- Fonction pour appliquer un bonus
CREATE OR REPLACE FUNCTION apply_bonus(
    p_customer_id UUID,
    p_bonus_type TEXT,
    p_special_event_id UUID DEFAULT NULL,
    p_referrer_id UUID DEFAULT NULL,
    p_applied_by UUID DEFAULT NULL,
    p_applied_by_name TEXT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    points_awarded INTEGER
) AS $$
DECLARE
    v_company_id UUID;
    v_bonus_settings bonus_settings%ROWTYPE;
    v_special_event special_events%ROWTYPE;
    v_points_to_award INTEGER;
    v_existing_bonus INTEGER;
BEGIN
    -- Récupérer l'entreprise du client
    SELECT company_id INTO v_company_id
    FROM customers
    WHERE id = p_customer_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Client non trouvé', 0;
        RETURN;
    END IF;
    
    -- Vérifier si le bonus a déjà été appliqué
    SELECT COUNT(*) INTO v_existing_bonus
    FROM applied_bonuses
    WHERE customer_id = p_customer_id
      AND company_id = v_company_id
      AND bonus_type = p_bonus_type
      AND (p_bonus_type != 'special_event' OR special_event_id = p_special_event_id);
    
    IF v_existing_bonus > 0 AND p_bonus_type IN ('welcome') THEN
        RETURN QUERY SELECT false, 'Ce bonus a déjà été appliqué', 0;
        RETURN;
    END IF;
    
    -- Récupérer les paramètres de bonus
    SELECT * INTO v_bonus_settings
    FROM bonus_settings
    WHERE company_id = v_company_id;
    
    -- Déterminer les points à attribuer
    CASE p_bonus_type
        WHEN 'welcome' THEN
            IF NOT v_bonus_settings.welcome_enabled THEN
                RETURN QUERY SELECT false, 'Le bonus de bienvenue est désactivé', 0;
                RETURN;
            END IF;
            v_points_to_award := v_bonus_settings.welcome_points;
            
        WHEN 'birthday' THEN
            IF NOT v_bonus_settings.birthday_enabled THEN
                RETURN QUERY SELECT false, 'Le bonus anniversaire est désactivé', 0;
                RETURN;
            END IF;
            v_points_to_award := v_bonus_settings.birthday_points;
            
        WHEN 'referral' THEN
            IF NOT v_bonus_settings.referral_enabled THEN
                RETURN QUERY SELECT false, 'Le bonus de parrainage est désactivé', 0;
                RETURN;
            END IF;
            v_points_to_award := v_bonus_settings.referral_points_referrer;
            
        WHEN 'special_event' THEN
            IF p_special_event_id IS NULL THEN
                RETURN QUERY SELECT false, 'Événement spécial non spécifié', 0;
                RETURN;
            END IF;
            
            SELECT * INTO v_special_event
            FROM special_events
            WHERE id = p_special_event_id
              AND company_id = v_company_id
              AND is_active = true;
            
            IF NOT FOUND THEN
                RETURN QUERY SELECT false, 'Événement non trouvé ou inactif', 0;
                RETURN;
            END IF;
            
            v_points_to_award := v_special_event.points;
            
        ELSE
            RETURN QUERY SELECT false, 'Type de bonus invalide', 0;
            RETURN;
    END CASE;
    
    -- Ajouter les points au client
    UPDATE customers
    SET points = points + v_points_to_award,
        updated_at = NOW()
    WHERE id = p_customer_id;
    
    -- Enregistrer l'application du bonus
    INSERT INTO applied_bonuses (
        customer_id,
        company_id,
        bonus_type,
        special_event_id,
        points_awarded,
        applied_by,
        applied_by_name,
        referrer_id
    ) VALUES (
        p_customer_id,
        v_company_id,
        p_bonus_type,
        p_special_event_id,
        v_points_to_award,
        p_applied_by,
        p_applied_by_name,
        p_referrer_id
    );
    
    -- Mettre à jour les stats pour les événements spéciaux
    IF p_bonus_type = 'special_event' THEN
        UPDATE special_events
        SET total_uses = total_uses + 1
        WHERE id = p_special_event_id;
    END IF;
    
    RETURN QUERY SELECT true, 'Bonus appliqué avec succès', v_points_to_award;
END;
$$ LANGUAGE plpgsql;

-- Vue pour les statistiques de bonus
CREATE OR REPLACE VIEW bonus_statistics AS
SELECT 
    ab.company_id,
    ab.bonus_type,
    COUNT(*) as total_applied,
    SUM(ab.points_awarded) as total_points_awarded,
    AVG(ab.points_awarded) as avg_points_per_bonus,
    MAX(ab.applied_at) as last_applied,
    MIN(ab.applied_at) as first_applied
FROM applied_bonuses ab
GROUP BY ab.company_id, ab.bonus_type;

-- Politique de sécurité RLS
ALTER TABLE bonus_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE special_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE applied_bonuses ENABLE ROW LEVEL SECURITY;

-- Les entreprises peuvent gérer leurs propres paramètres
CREATE POLICY "Companies can manage own bonus settings" ON bonus_settings
    FOR ALL
    USING (company_id = auth.uid());

CREATE POLICY "Companies can manage own special events" ON special_events
    FOR ALL
    USING (company_id = auth.uid());

CREATE POLICY "Companies can view own applied bonuses" ON applied_bonuses
    FOR SELECT
    USING (company_id = auth.uid());

-- Grant permissions
GRANT ALL ON bonus_settings TO authenticated;
GRANT ALL ON special_events TO authenticated;
GRANT ALL ON applied_bonuses TO authenticated;
GRANT ALL ON bonus_statistics TO authenticated;

-- Initialiser les paramètres pour les entreprises existantes
INSERT INTO bonus_settings (company_id)
SELECT id FROM users
ON CONFLICT (company_id) DO NOTHING;