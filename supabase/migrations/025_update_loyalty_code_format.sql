-- Mise à jour de la fonction de génération de code de fidélité pour un format 16 caractères alphanumériques

-- 1. Supprimer l'ancienne fonction et trigger
DROP TRIGGER IF EXISTS trigger_set_loyalty_code ON customers;
DROP FUNCTION IF EXISTS set_customer_loyalty_code();
DROP FUNCTION IF EXISTS generate_loyalty_code();

-- 2. Créer une nouvelle fonction pour générer un code unique de 16 caractères
CREATE OR REPLACE FUNCTION generate_loyalty_code_v2()
RETURNS TEXT AS $$
DECLARE
    v_code TEXT;
    v_exists BOOLEAN;
    v_chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    v_length INTEGER := 16;
    i INTEGER;
BEGIN
    LOOP
        v_code := '';
        
        -- Générer un code de 16 caractères alphanumériques
        FOR i IN 1..v_length LOOP
            v_code := v_code || substr(v_chars, floor(random() * length(v_chars) + 1)::integer, 1);
        END LOOP;
        
        -- Vérifier si le code existe déjà
        SELECT EXISTS(SELECT 1 FROM customers WHERE loyalty_code = v_code) INTO v_exists;
        
        -- Si le code n'existe pas, on sort de la boucle
        IF NOT v_exists THEN
            EXIT;
        END IF;
    END LOOP;
    
    RETURN v_code;
END;
$$ LANGUAGE plpgsql;

-- 3. Créer le nouveau trigger
CREATE OR REPLACE FUNCTION set_customer_loyalty_code_v2()
RETURNS TRIGGER AS $$
BEGIN
    -- Toujours générer un nouveau code, même si un existe déjà
    IF NEW.loyalty_code IS NULL OR LENGTH(NEW.loyalty_code) < 16 THEN
        NEW.loyalty_code := generate_loyalty_code_v2();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_loyalty_code_v2
BEFORE INSERT ON customers
FOR EACH ROW
EXECUTE FUNCTION set_customer_loyalty_code_v2();

-- 4. Mettre à jour tous les codes existants avec le nouveau format
DO $$
DECLARE
    v_customer RECORD;
    v_new_code TEXT;
BEGIN
    -- Parcourir tous les clients
    FOR v_customer IN 
        SELECT id FROM customers
    LOOP
        -- Générer un nouveau code unique pour chaque client
        v_new_code := generate_loyalty_code_v2();
        
        -- Mettre à jour le client avec le nouveau code
        UPDATE customers 
        SET loyalty_code = v_new_code
        WHERE id = v_customer.id;
        
        RAISE NOTICE 'Client % mis à jour avec le code %', v_customer.id, v_new_code;
    END LOOP;
END $$;

-- 5. Créer une fonction pour obtenir les infos client par code de fidélité (mise à jour)
CREATE OR REPLACE FUNCTION get_customer_by_loyalty_code_v2(
    p_loyalty_code TEXT,
    p_company_id UUID DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    company_id UUID,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone TEXT,
    loyalty_code TEXT,
    points INTEGER,
    total_points_earned INTEGER,
    total_points_spent INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    is_verified BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.company_id,
        c.first_name,
        c.last_name,
        c.email,
        c.phone,
        c.loyalty_code,
        c.points,
        c.total_points_earned,
        c.total_points_spent,
        c.created_at,
        c.is_verified
    FROM customers c
    WHERE c.loyalty_code = p_loyalty_code
    AND (p_company_id IS NULL OR c.company_id = p_company_id)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Permissions
GRANT EXECUTE ON FUNCTION generate_loyalty_code_v2() TO authenticated;
GRANT EXECUTE ON FUNCTION get_customer_by_loyalty_code_v2(TEXT, UUID) TO authenticated;

-- 7. Ajouter un index pour les performances
DROP INDEX IF EXISTS idx_customers_loyalty_code;
CREATE UNIQUE INDEX idx_customers_loyalty_code_unique ON customers(loyalty_code);
CREATE INDEX idx_customers_company_loyalty_v2 ON customers(company_id, loyalty_code);

COMMENT ON COLUMN customers.loyalty_code IS 'Code de fidélité unique du client - 16 caractères alphanumériques';

-- Message de confirmation
SELECT 'Codes de fidélité mis à jour avec succès au format 16 caractères!' as message;