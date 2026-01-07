-- Fonction pour insérer une récompense sans déclencher de trigger
CREATE OR REPLACE FUNCTION insert_reward_without_trigger(
    p_company_id UUID,
    p_name VARCHAR(255),
    p_description TEXT,
    p_category VARCHAR(50),
    p_points_required INTEGER,
    p_discount_percentage DECIMAL(5,2),
    p_discount_amount DECIMAL(10,2),
    p_is_active BOOLEAN,
    p_max_uses_per_customer INTEGER
)
RETURNS rewards AS $$
DECLARE
    v_reward rewards;
BEGIN
    -- Insérer la récompense directement
    INSERT INTO rewards (
        company_id,
        name,
        description,
        category,
        points_required,
        discount_percentage,
        discount_amount,
        is_active,
        max_uses_per_customer,
        created_at,
        updated_at
    ) VALUES (
        p_company_id,
        p_name,
        p_description,
        p_category,
        p_points_required,
        p_discount_percentage,
        p_discount_amount,
        p_is_active,
        p_max_uses_per_customer,
        NOW(),
        NOW()
    ) RETURNING * INTO v_reward;
    
    RETURN v_reward;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Donner les permissions
GRANT EXECUTE ON FUNCTION insert_reward_without_trigger TO authenticated;