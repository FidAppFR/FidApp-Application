-- Fonction RPC pour créer une offre en contournant temporairement RLS
-- Utilisée comme solution de secours si les politiques RLS posent problème

CREATE OR REPLACE FUNCTION create_offer_bypass_rls(
    p_company_id UUID,
    p_name TEXT,
    p_description TEXT,
    p_type TEXT,
    p_value DECIMAL(10,2),
    p_value_text TEXT,
    p_points_cost INTEGER,
    p_conditions TEXT,
    p_is_active BOOLEAN DEFAULT true
)
RETURNS offers AS $$
DECLARE
    v_offer offers;
    v_user_id UUID;
BEGIN
    -- Vérifier que l'utilisateur est bien autorisé pour cette entreprise
    SELECT auth_id INTO v_user_id 
    FROM users 
    WHERE id = p_company_id;
    
    IF v_user_id IS NULL OR v_user_id != auth.uid() THEN
        RAISE EXCEPTION 'Non autorisé à créer une offre pour cette entreprise';
    END IF;
    
    -- Insérer l'offre
    INSERT INTO offers (
        company_id,
        name,
        description,
        type,
        value,
        value_text,
        points_cost,
        conditions,
        is_active,
        created_at,
        updated_at
    ) VALUES (
        p_company_id,
        p_name,
        p_description,
        p_type,
        p_value,
        p_value_text,
        p_points_cost,
        p_conditions,
        p_is_active,
        NOW(),
        NOW()
    ) RETURNING * INTO v_offer;
    
    RETURN v_offer;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Donner les permissions d'exécution
GRANT EXECUTE ON FUNCTION create_offer_bypass_rls TO authenticated;

-- Fonction similaire pour mettre à jour
CREATE OR REPLACE FUNCTION update_offer_bypass_rls(
    p_offer_id UUID,
    p_name TEXT,
    p_description TEXT,
    p_type TEXT,
    p_value DECIMAL(10,2),
    p_value_text TEXT,
    p_points_cost INTEGER,
    p_conditions TEXT,
    p_is_active BOOLEAN
)
RETURNS offers AS $$
DECLARE
    v_offer offers;
    v_company_id UUID;
    v_user_id UUID;
BEGIN
    -- Récupérer le company_id de l'offre
    SELECT company_id INTO v_company_id
    FROM offers
    WHERE id = p_offer_id;
    
    -- Vérifier que l'utilisateur est autorisé
    SELECT auth_id INTO v_user_id 
    FROM users 
    WHERE id = v_company_id;
    
    IF v_user_id IS NULL OR v_user_id != auth.uid() THEN
        RAISE EXCEPTION 'Non autorisé à modifier cette offre';
    END IF;
    
    -- Mettre à jour l'offre
    UPDATE offers SET
        name = p_name,
        description = p_description,
        type = p_type,
        value = p_value,
        value_text = p_value_text,
        points_cost = p_points_cost,
        conditions = p_conditions,
        is_active = p_is_active,
        updated_at = NOW()
    WHERE id = p_offer_id
    RETURNING * INTO v_offer;
    
    RETURN v_offer;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Donner les permissions d'exécution
GRANT EXECUTE ON FUNCTION update_offer_bypass_rls TO authenticated;