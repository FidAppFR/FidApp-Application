-- Migration pour convertir les anciennes récompenses en offres
-- et créer une vue unifiée pour gérer les deux

-- 1. Ajouter l'image_url à la table rewards si elle n'existe pas
ALTER TABLE rewards 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- 2. Créer une vue unifiée qui combine rewards et offers
CREATE OR REPLACE VIEW unified_rewards AS
SELECT 
    -- Champs communs
    id,
    company_id,
    name,
    description,
    is_active,
    created_at,
    updated_at,
    
    -- Type d'origine
    'reward' as source_type,
    
    -- Mapping des champs rewards vers offers
    points_required as points_cost,
    category as type,
    CASE 
        WHEN discount_percentage IS NOT NULL THEN discount_percentage
        WHEN discount_amount IS NOT NULL THEN discount_amount
        ELSE NULL
    END as value,
    NULL as value_text,
    NULL as conditions,
    valid_from as start_date,
    valid_until as end_date,
    max_uses_per_customer,
    total_uses,
    NULL as image_url,
    0 as display_order
FROM rewards

UNION ALL

SELECT 
    -- Champs communs
    id,
    company_id,
    name,
    description,
    is_active,
    created_at,
    updated_at,
    
    -- Type d'origine
    'offer' as source_type,
    
    -- Champs offers directs
    points_cost,
    type,
    value,
    value_text,
    conditions,
    start_date::timestamptz,
    end_date::timestamptz,
    max_uses_per_customer,
    total_uses,
    image_url,
    display_order
FROM offers;

-- 3. Fonction pour migrer une récompense vers une offre
CREATE OR REPLACE FUNCTION migrate_reward_to_offer(p_reward_id UUID)
RETURNS UUID AS $$
DECLARE
    v_reward rewards%ROWTYPE;
    v_new_offer_id UUID;
BEGIN
    -- Récupérer la récompense
    SELECT * INTO v_reward FROM rewards WHERE id = p_reward_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Récompense non trouvée';
    END IF;
    
    -- Créer l'offre correspondante
    INSERT INTO offers (
        company_id,
        name,
        description,
        type,
        value,
        value_text,
        points_cost,
        conditions,
        start_date,
        end_date,
        max_uses_per_customer,
        is_active,
        total_uses,
        image_url
    ) VALUES (
        v_reward.company_id,
        v_reward.name,
        v_reward.description,
        CASE v_reward.category
            WHEN 'product' THEN 'gift'
            WHEN 'service' THEN 'upgrade'
            WHEN 'discount' THEN 'discount'
            ELSE 'gift'
        END,
        COALESCE(v_reward.discount_percentage, v_reward.discount_amount),
        NULL,
        v_reward.points_required,
        NULL,
        v_reward.valid_from::date,
        v_reward.valid_until::date,
        v_reward.max_uses_per_customer,
        v_reward.is_active,
        v_reward.total_uses,
        v_reward.image_url
    ) RETURNING id INTO v_new_offer_id;
    
    -- Désactiver l'ancienne récompense
    UPDATE rewards 
    SET is_active = false,
        updated_at = NOW()
    WHERE id = p_reward_id;
    
    RETURN v_new_offer_id;
END;
$$ LANGUAGE plpgsql;

-- 4. Fonction pour migrer toutes les récompenses d'une entreprise
CREATE OR REPLACE FUNCTION migrate_all_company_rewards(p_company_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER := 0;
    v_reward rewards%ROWTYPE;
BEGIN
    FOR v_reward IN 
        SELECT * FROM rewards 
        WHERE company_id = p_company_id 
        AND is_active = true
    LOOP
        PERFORM migrate_reward_to_offer(v_reward.id);
        v_count := v_count + 1;
    END LOOP;
    
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- 5. Trigger pour synchroniser les modifications
CREATE OR REPLACE FUNCTION sync_reward_to_offer()
RETURNS TRIGGER AS $$
DECLARE
    v_offer_exists BOOLEAN;
BEGIN
    -- Vérifier si une offre correspondante existe déjà
    SELECT EXISTS(
        SELECT 1 FROM offers 
        WHERE name = NEW.name 
        AND company_id = NEW.company_id
        AND created_at >= NEW.created_at - INTERVAL '1 minute'
    ) INTO v_offer_exists;
    
    -- Si l'offre n'existe pas, la créer
    IF NOT v_offer_exists AND NEW.is_active THEN
        INSERT INTO offers (
            company_id,
            name,
            description,
            type,
            value,
            points_cost,
            is_active
        ) VALUES (
            NEW.company_id,
            NEW.name,
            NEW.description,
            'gift',
            COALESCE(NEW.discount_percentage, NEW.discount_amount),
            NEW.points_required,
            NEW.is_active
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger seulement s'il n'existe pas
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'sync_reward_to_offer_trigger'
    ) THEN
        CREATE TRIGGER sync_reward_to_offer_trigger
        AFTER INSERT OR UPDATE ON rewards
        FOR EACH ROW
        EXECUTE FUNCTION sync_reward_to_offer();
    END IF;
END $$;

-- Permissions
GRANT SELECT ON unified_rewards TO authenticated;