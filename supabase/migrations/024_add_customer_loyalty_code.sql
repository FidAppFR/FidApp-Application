-- Ajout du code de fidélité unique pour chaque client

-- 1. Ajouter la colonne loyalty_code à la table customers
ALTER TABLE customers 
ADD COLUMN IF NOT EXISTS loyalty_code TEXT UNIQUE;

-- 2. Créer un index pour les recherches rapides
CREATE INDEX IF NOT EXISTS idx_customers_loyalty_code ON customers(loyalty_code);
CREATE INDEX IF NOT EXISTS idx_customers_company_loyalty ON customers(company_id, loyalty_code);

-- 3. Fonction pour générer un code de fidélité unique
CREATE OR REPLACE FUNCTION generate_loyalty_code()
RETURNS TEXT AS $$
DECLARE
    v_code TEXT;
    v_exists BOOLEAN;
BEGIN
    LOOP
        -- Générer un code au format: XXXX-XXXX-XXXX (12 caractères alphanumériques)
        v_code := UPPER(
            substring(md5(random()::text) from 1 for 4) || '-' ||
            substring(md5(random()::text) from 1 for 4) || '-' ||
            substring(md5(random()::text) from 1 for 4)
        );
        
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

-- 4. Trigger pour générer automatiquement un code lors de la création d'un client
CREATE OR REPLACE FUNCTION set_customer_loyalty_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.loyalty_code IS NULL THEN
        NEW.loyalty_code := generate_loyalty_code();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_loyalty_code
BEFORE INSERT ON customers
FOR EACH ROW
EXECUTE FUNCTION set_customer_loyalty_code();

-- 5. Générer les codes pour les clients existants qui n'en ont pas
DO $$
DECLARE
    v_customer RECORD;
BEGIN
    FOR v_customer IN 
        SELECT id FROM customers WHERE loyalty_code IS NULL
    LOOP
        UPDATE customers 
        SET loyalty_code = generate_loyalty_code()
        WHERE id = v_customer.id;
    END LOOP;
END $$;

-- 6. Fonction pour obtenir les infos client par code de fidélité
CREATE OR REPLACE FUNCTION get_customer_by_loyalty_code(
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

-- 7. Permissions
GRANT EXECUTE ON FUNCTION generate_loyalty_code() TO authenticated;
GRANT EXECUTE ON FUNCTION get_customer_by_loyalty_code(TEXT, UUID) TO authenticated;

-- 8. Politiques RLS pour permettre aux clients de voir leur propre code
-- (Les politiques existantes devraient déjà permettre cela, mais on s'assure)
CREATE POLICY "Customers can view own loyalty code" ON customers
    FOR SELECT
    USING (
        id IN (
            SELECT id FROM customers 
            WHERE email = current_setting('request.jwt.claims', true)::json->>'email'
        )
        OR company_id = auth.uid()
    );

COMMENT ON COLUMN customers.loyalty_code IS 'Code de fidélité unique du client au format XXXX-XXXX-XXXX';