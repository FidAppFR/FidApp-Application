-- Migration pour créer un système de notifications complet

-- 1. Table des notifications
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Type et contenu
    type TEXT NOT NULL CHECK (type IN (
        'new_customer',        -- Nouveau client fidèle
        'points_used',         -- Utilisation de points
        'points_earned',       -- Points gagnés
        'reward_redeemed',     -- Récompense échangée
        'milestone_reached',   -- Objectif atteint
        'daily_summary',       -- Résumé quotidien
        'weekly_summary',      -- Résumé hebdomadaire
        'low_stock',          -- Stock faible
        'birthday_alert',      -- Anniversaire client
        'referral_success'     -- Parrainage réussi
    )),
    
    -- Données de la notification
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    data JSONB, -- Données supplémentaires (customer_id, amount, etc.)
    
    -- État
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Priorité et catégorie
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    category TEXT DEFAULT 'general' CHECK (category IN ('general', 'customer', 'points', 'milestone', 'alert')),
    
    -- URL d'action (optionnel)
    action_url TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() + INTERVAL '30 days'
);

-- 2. Table des objectifs/milestones
CREATE TABLE IF NOT EXISTS company_milestones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Détails de l'objectif
    name TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN (
        'customer_count',      -- Nombre de clients
        'points_distributed',  -- Points distribués
        'rewards_redeemed',    -- Récompenses échangées
        'monthly_revenue',     -- Revenu mensuel
        'daily_scans',        -- Scans quotidiens
        'weekly_active',      -- Clients actifs par semaine
        'custom'              -- Objectif personnalisé
    )),
    
    -- Valeurs cibles
    target_value NUMERIC NOT NULL,
    current_value NUMERIC DEFAULT 0,
    
    -- État
    is_active BOOLEAN DEFAULT true,
    is_achieved BOOLEAN DEFAULT false,
    achieved_at TIMESTAMP WITH TIME ZONE,
    
    -- Période
    start_date DATE DEFAULT CURRENT_DATE,
    end_date DATE,
    
    -- Récompense (optionnel)
    reward_description TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Table des préférences de notifications
CREATE TABLE IF NOT EXISTS notification_preferences (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Préférences par type
    new_customer BOOLEAN DEFAULT true,
    points_used BOOLEAN DEFAULT true,
    points_earned BOOLEAN DEFAULT false,
    reward_redeemed BOOLEAN DEFAULT true,
    milestone_reached BOOLEAN DEFAULT true,
    daily_summary BOOLEAN DEFAULT false,
    weekly_summary BOOLEAN DEFAULT true,
    low_stock BOOLEAN DEFAULT true,
    birthday_alert BOOLEAN DEFAULT true,
    referral_success BOOLEAN DEFAULT true,
    
    -- Préférences de livraison
    email_enabled BOOLEAN DEFAULT false,
    push_enabled BOOLEAN DEFAULT true,
    in_app_enabled BOOLEAN DEFAULT true,
    
    -- Heures de silence
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(company_id)
);

-- 4. Index pour les performances
CREATE INDEX idx_notifications_company ON notifications(company_id);
CREATE INDEX idx_notifications_unread ON notifications(company_id, is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_milestones_company ON company_milestones(company_id);
CREATE INDEX idx_milestones_active ON company_milestones(is_active, is_achieved);

-- 5. Fonction pour créer une notification
CREATE OR REPLACE FUNCTION create_notification(
    p_company_id UUID,
    p_type TEXT,
    p_title TEXT,
    p_message TEXT,
    p_data JSONB DEFAULT NULL,
    p_priority TEXT DEFAULT 'normal',
    p_category TEXT DEFAULT 'general'
)
RETURNS UUID AS $$
DECLARE
    v_notification_id UUID;
    v_prefs notification_preferences%ROWTYPE;
BEGIN
    -- Vérifier les préférences
    SELECT * INTO v_prefs FROM notification_preferences WHERE company_id = p_company_id;
    
    -- Si pas de préférences, créer les valeurs par défaut
    IF NOT FOUND THEN
        INSERT INTO notification_preferences (company_id) VALUES (p_company_id);
        SELECT * INTO v_prefs FROM notification_preferences WHERE company_id = p_company_id;
    END IF;
    
    -- Vérifier si ce type de notification est activé
    CASE p_type
        WHEN 'new_customer' THEN
            IF NOT v_prefs.new_customer THEN RETURN NULL; END IF;
        WHEN 'points_used' THEN
            IF NOT v_prefs.points_used THEN RETURN NULL; END IF;
        WHEN 'reward_redeemed' THEN
            IF NOT v_prefs.reward_redeemed THEN RETURN NULL; END IF;
        WHEN 'milestone_reached' THEN
            IF NOT v_prefs.milestone_reached THEN RETURN NULL; END IF;
        ELSE
            -- Par défaut, créer la notification
    END CASE;
    
    -- Créer la notification
    INSERT INTO notifications (
        company_id,
        type,
        title,
        message,
        data,
        priority,
        category
    ) VALUES (
        p_company_id,
        p_type,
        p_title,
        p_message,
        p_data,
        p_priority,
        p_category
    ) RETURNING id INTO v_notification_id;
    
    RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql;

-- 6. Trigger pour nouveau client
CREATE OR REPLACE FUNCTION notify_new_customer()
RETURNS TRIGGER AS $$
DECLARE
    v_company_name TEXT;
BEGIN
    -- Récupérer le nom de l'entreprise
    SELECT company INTO v_company_name FROM users WHERE id = NEW.company_id;
    
    -- Créer la notification
    PERFORM create_notification(
        NEW.company_id,
        'new_customer',
        'Nouveau client fidèle !',
        NEW.first_name || ' ' || NEW.last_name || ' vient de rejoindre votre programme de fidélité.',
        jsonb_build_object(
            'customer_id', NEW.id,
            'customer_name', NEW.first_name || ' ' || NEW.last_name,
            'email', NEW.email
        ),
        'normal',
        'customer'
    );
    
    -- Vérifier les milestones de nombre de clients
    UPDATE company_milestones
    SET current_value = current_value + 1
    WHERE company_id = NEW.company_id
    AND type = 'customer_count'
    AND is_active = true
    AND is_achieved = false;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_new_customer_notification
AFTER INSERT ON customers
FOR EACH ROW
EXECUTE FUNCTION notify_new_customer();

-- 7. Trigger pour utilisation de points
CREATE OR REPLACE FUNCTION notify_points_used()
RETURNS TRIGGER AS $$
DECLARE
    v_customer customers%ROWTYPE;
    v_offer offers%ROWTYPE;
BEGIN
    -- Si c'est une nouvelle rédemption
    IF TG_OP = 'INSERT' THEN
        -- Récupérer les infos du client et de l'offre
        SELECT * INTO v_customer FROM customers WHERE id = NEW.customer_id;
        SELECT * INTO v_offer FROM offers WHERE id = NEW.offer_id;
        
        -- Créer la notification
        PERFORM create_notification(
            NEW.company_id,
            'points_used',
            'Points utilisés',
            v_customer.first_name || ' ' || v_customer.last_name || ' a échangé ' || 
            NEW.points_spent || ' points contre "' || v_offer.name || '"',
            jsonb_build_object(
                'customer_id', NEW.customer_id,
                'customer_name', v_customer.first_name || ' ' || v_customer.last_name,
                'points_spent', NEW.points_spent,
                'offer_name', v_offer.name,
                'redemption_code', NEW.redemption_code
            ),
            'normal',
            'points'
        );
        
        -- Mettre à jour les milestones de points distribués
        UPDATE company_milestones
        SET current_value = current_value + NEW.points_spent
        WHERE company_id = NEW.company_id
        AND type = 'points_distributed'
        AND is_active = true
        AND is_achieved = false;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_points_used_notification
AFTER INSERT ON offer_redemptions
FOR EACH ROW
EXECUTE FUNCTION notify_points_used();

-- 8. Fonction pour vérifier et notifier les milestones atteints
CREATE OR REPLACE FUNCTION check_milestone_achievement()
RETURNS TRIGGER AS $$
BEGIN
    -- Si l'objectif vient d'être atteint
    IF NEW.current_value >= NEW.target_value AND OLD.current_value < NEW.target_value THEN
        -- Marquer comme atteint
        NEW.is_achieved := true;
        NEW.achieved_at := NOW();
        
        -- Créer une notification
        PERFORM create_notification(
            NEW.company_id,
            'milestone_reached',
            'Objectif atteint ! 🎉',
            'Félicitations ! Vous avez atteint votre objectif : ' || NEW.name || 
            ' (' || NEW.current_value || '/' || NEW.target_value || ')',
            jsonb_build_object(
                'milestone_id', NEW.id,
                'milestone_name', NEW.name,
                'target_value', NEW.target_value,
                'current_value', NEW.current_value,
                'reward', NEW.reward_description
            ),
            'high',
            'milestone'
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_milestone_achievement
BEFORE UPDATE ON company_milestones
FOR EACH ROW
WHEN (NEW.current_value != OLD.current_value)
EXECUTE FUNCTION check_milestone_achievement();

-- 9. Fonction pour marquer les notifications comme lues
CREATE OR REPLACE FUNCTION mark_notifications_read(
    p_company_id UUID,
    p_notification_ids UUID[] DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    IF p_notification_ids IS NULL THEN
        -- Marquer toutes les notifications non lues
        UPDATE notifications
        SET is_read = true,
            read_at = NOW()
        WHERE company_id = p_company_id
        AND is_read = false;
    ELSE
        -- Marquer les notifications spécifiques
        UPDATE notifications
        SET is_read = true,
            read_at = NOW()
        WHERE company_id = p_company_id
        AND id = ANY(p_notification_ids)
        AND is_read = false;
    END IF;
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- 10. Vue pour les statistiques de notifications
CREATE OR REPLACE VIEW notification_stats AS
SELECT 
    company_id,
    COUNT(*) as total_notifications,
    COUNT(*) FILTER (WHERE is_read = false) as unread_count,
    COUNT(*) FILTER (WHERE type = 'new_customer') as new_customers_count,
    COUNT(*) FILTER (WHERE type = 'points_used') as points_used_count,
    COUNT(*) FILTER (WHERE type = 'milestone_reached') as milestones_count,
    MAX(created_at) as last_notification_at
FROM notifications
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY company_id;

-- 11. Fonction pour créer des milestones par défaut
CREATE OR REPLACE FUNCTION create_default_milestones(p_company_id UUID)
RETURNS void AS $$
BEGIN
    -- Milestone: 10 clients
    INSERT INTO company_milestones (company_id, name, type, target_value, description)
    VALUES (p_company_id, 'Premiers 10 clients', 'customer_count', 10, 'Atteindre 10 clients fidèles');
    
    -- Milestone: 50 clients
    INSERT INTO company_milestones (company_id, name, type, target_value, description)
    VALUES (p_company_id, '50 clients fidèles', 'customer_count', 50, 'Atteindre 50 clients fidèles');
    
    -- Milestone: 100 clients
    INSERT INTO company_milestones (company_id, name, type, target_value, description)
    VALUES (p_company_id, 'Club des 100', 'customer_count', 100, 'Atteindre 100 clients fidèles');
    
    -- Milestone: 1000 points distribués
    INSERT INTO company_milestones (company_id, name, type, target_value, description)
    VALUES (p_company_id, '1000 points distribués', 'points_distributed', 1000, 'Distribuer 1000 points de fidélité');
END;
$$ LANGUAGE plpgsql;

-- 12. Politiques de sécurité RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Companies can manage own notifications" ON notifications
    FOR ALL
    USING (company_id = auth.uid());

CREATE POLICY "Companies can manage own milestones" ON company_milestones
    FOR ALL
    USING (company_id = auth.uid());

CREATE POLICY "Companies can manage own preferences" ON notification_preferences
    FOR ALL
    USING (company_id = auth.uid());

-- Permissions
GRANT ALL ON notifications TO authenticated;
GRANT ALL ON company_milestones TO authenticated;
GRANT ALL ON notification_preferences TO authenticated;
GRANT ALL ON notification_stats TO authenticated;