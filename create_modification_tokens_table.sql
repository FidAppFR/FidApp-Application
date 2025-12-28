-- ========================================================
-- MIGRATION : Créer une table pour les tokens de modification
-- À exécuter dans le SQL Editor de votre dashboard Supabase
-- ========================================================

-- 1. Supprimer la table si elle existe
DROP TABLE IF EXISTS public.modification_tokens CASCADE;

-- 2. Créer la table modification_tokens
CREATE TABLE public.modification_tokens (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL UNIQUE,
    field_to_modify VARCHAR(50) NOT NULL, -- email, phone, etc.
    new_value TEXT NOT NULL,
    old_value TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'used', 'expired', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '24 hours'),
    used_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES users(id),
    ip_address INET,
    user_agent TEXT
);

-- 3. Créer les index
CREATE INDEX idx_modification_tokens_token ON modification_tokens(token);
CREATE INDEX idx_modification_tokens_customer_id ON modification_tokens(customer_id);
CREATE INDEX idx_modification_tokens_status ON modification_tokens(status);
CREATE INDEX idx_modification_tokens_expires_at ON modification_tokens(expires_at);

-- 4. Activer RLS
ALTER TABLE modification_tokens ENABLE ROW LEVEL SECURITY;

-- 5. Créer les politiques de sécurité
-- Permettre aux entreprises de créer des tokens pour leurs clients
CREATE POLICY "Companies can create tokens" ON modification_tokens
    FOR INSERT
    WITH CHECK (true);

-- Permettre la lecture des tokens
CREATE POLICY "Enable read access" ON modification_tokens
    FOR SELECT
    USING (true);

-- Permettre la mise à jour des tokens
CREATE POLICY "Enable update" ON modification_tokens
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- 6. Fonction pour générer un token unique
CREATE OR REPLACE FUNCTION generate_modification_token()
RETURNS TEXT AS $$
DECLARE
    token TEXT;
    exists_count INT;
BEGIN
    LOOP
        -- Générer un token aléatoire
        token := encode(gen_random_bytes(32), 'hex');
        
        -- Vérifier l'unicité
        SELECT COUNT(*) INTO exists_count
        FROM modification_tokens
        WHERE modification_tokens.token = token;
        
        EXIT WHEN exists_count = 0;
    END LOOP;
    
    RETURN token;
END;
$$ LANGUAGE plpgsql;

-- 7. Fonction pour valider et utiliser un token
CREATE OR REPLACE FUNCTION use_modification_token(
    p_token VARCHAR(255),
    p_ip_address INET DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
) RETURNS TABLE (
    success BOOLEAN,
    customer_id UUID,
    field_to_modify VARCHAR(50),
    new_value TEXT,
    message TEXT
) AS $$
DECLARE
    v_token_record RECORD;
BEGIN
    -- Récupérer le token
    SELECT * INTO v_token_record
    FROM modification_tokens
    WHERE token = p_token
    AND status = 'pending'
    AND expires_at > NOW();
    
    -- Si le token n'existe pas ou n'est pas valide
    IF NOT FOUND THEN
        RETURN QUERY SELECT 
            FALSE::BOOLEAN,
            NULL::UUID,
            NULL::VARCHAR(50),
            NULL::TEXT,
            'Token invalide ou expiré'::TEXT;
        RETURN;
    END IF;
    
    -- Marquer le token comme utilisé
    UPDATE modification_tokens
    SET 
        status = 'used',
        used_at = NOW(),
        ip_address = p_ip_address,
        user_agent = p_user_agent
    WHERE id = v_token_record.id;
    
    -- Mettre à jour le champ du client
    IF v_token_record.field_to_modify = 'email' THEN
        UPDATE customers
        SET email = v_token_record.new_value
        WHERE id = v_token_record.customer_id;
    ELSIF v_token_record.field_to_modify = 'phone' THEN
        UPDATE customers
        SET phone = v_token_record.new_value
        WHERE id = v_token_record.customer_id;
    ELSIF v_token_record.field_to_modify = 'first_name' THEN
        UPDATE customers
        SET first_name = v_token_record.new_value
        WHERE id = v_token_record.customer_id;
    ELSIF v_token_record.field_to_modify = 'last_name' THEN
        UPDATE customers
        SET last_name = v_token_record.new_value
        WHERE id = v_token_record.customer_id;
    END IF;
    
    RETURN QUERY SELECT 
        TRUE::BOOLEAN,
        v_token_record.customer_id,
        v_token_record.field_to_modify,
        v_token_record.new_value,
        'Modification effectuée avec succès'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- 8. Fonction pour nettoyer les tokens expirés (à exécuter périodiquement)
CREATE OR REPLACE FUNCTION cleanup_expired_tokens()
RETURNS INT AS $$
DECLARE
    deleted_count INT;
BEGIN
    DELETE FROM modification_tokens
    WHERE status = 'pending'
    AND expires_at < NOW();
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- 9. Vérifier que tout est créé
SELECT 
    'Table modification_tokens créée avec succès' as message,
    COUNT(*) as nombre_colonnes
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'modification_tokens';