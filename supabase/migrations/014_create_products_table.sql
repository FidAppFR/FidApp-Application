-- Migration pour créer la table des produits
-- Permet de définir des produits avec leurs points associés

-- Créer la table des produits
CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Informations du produit
    name TEXT NOT NULL,
    description TEXT,
    points INTEGER NOT NULL CHECK (points > 0),
    category TEXT,
    
    -- Prix et stock optionnels
    price DECIMAL(10, 2),
    stock INTEGER,
    unlimited_stock BOOLEAN DEFAULT true,
    
    -- Statut
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    
    -- Image du produit
    image_url TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Contraintes
    CONSTRAINT unique_product_name_per_company UNIQUE (company_id, name)
);

-- Index pour les performances
CREATE INDEX idx_products_company ON products(company_id);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_order ON products(display_order);

-- Créer la table d'historique des achats de produits
CREATE TABLE IF NOT EXISTS product_purchases (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE SET NULL,
    
    -- Détails de l'achat
    product_name TEXT NOT NULL, -- Stocké au cas où le produit est supprimé
    points_spent INTEGER NOT NULL,
    quantity INTEGER DEFAULT 1,
    
    -- Qui a traité l'achat
    processed_by UUID REFERENCES users(id),
    processed_by_name TEXT,
    
    -- Timestamps
    purchased_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour les performances
CREATE INDEX idx_purchases_customer ON product_purchases(customer_id);
CREATE INDEX idx_purchases_company ON product_purchases(company_id);
CREATE INDEX idx_purchases_product ON product_purchases(product_id);
CREATE INDEX idx_purchases_date ON product_purchases(purchased_at);

-- Vue pour les produits les plus vendus
CREATE OR REPLACE VIEW top_products AS
SELECT 
    p.company_id,
    p.id as product_id,
    p.name,
    p.points,
    p.category,
    COUNT(pp.id) as total_purchases,
    SUM(pp.quantity) as total_quantity,
    SUM(pp.points_spent) as total_points_spent
FROM products p
LEFT JOIN product_purchases pp ON p.id = pp.product_id
WHERE p.is_active = true
GROUP BY p.company_id, p.id, p.name, p.points, p.category
ORDER BY total_purchases DESC;

-- Fonction pour acheter un produit
CREATE OR REPLACE FUNCTION purchase_product(
    p_customer_id UUID,
    p_product_id UUID,
    p_quantity INTEGER DEFAULT 1,
    p_processed_by UUID DEFAULT NULL,
    p_processed_by_name TEXT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    remaining_points INTEGER
) AS $$
DECLARE
    v_product products%ROWTYPE;
    v_customer customers%ROWTYPE;
    v_total_points INTEGER;
BEGIN
    -- Récupérer le produit
    SELECT * INTO v_product FROM products 
    WHERE id = p_product_id AND is_active = true;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Produit introuvable ou inactif', 0;
        RETURN;
    END IF;
    
    -- Récupérer le client
    SELECT * INTO v_customer FROM customers 
    WHERE id = p_customer_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Client introuvable', 0;
        RETURN;
    END IF;
    
    -- Calculer le total de points
    v_total_points := v_product.points * p_quantity;
    
    -- Vérifier si le client a assez de points
    IF v_customer.points < v_total_points THEN
        RETURN QUERY SELECT false, 'Points insuffisants', v_customer.points;
        RETURN;
    END IF;
    
    -- Vérifier le stock si applicable
    IF NOT v_product.unlimited_stock AND v_product.stock < p_quantity THEN
        RETURN QUERY SELECT false, 'Stock insuffisant', v_customer.points;
        RETURN;
    END IF;
    
    -- Déduire les points du client
    UPDATE customers 
    SET points = points - v_total_points,
        updated_at = NOW()
    WHERE id = p_customer_id;
    
    -- Mettre à jour le stock si applicable
    IF NOT v_product.unlimited_stock THEN
        UPDATE products 
        SET stock = stock - p_quantity,
            updated_at = NOW()
        WHERE id = p_product_id;
    END IF;
    
    -- Enregistrer l'achat
    INSERT INTO product_purchases (
        customer_id,
        company_id,
        product_id,
        product_name,
        points_spent,
        quantity,
        processed_by,
        processed_by_name
    ) VALUES (
        p_customer_id,
        v_product.company_id,
        p_product_id,
        v_product.name,
        v_total_points,
        p_quantity,
        p_processed_by,
        p_processed_by_name
    );
    
    -- Enregistrer dans l'historique des scans (type achat)
    INSERT INTO qr_scan_history (
        customer_id,
        company_id,
        scanned_by,
        scanned_by_name,
        scan_type,
        points_added,
        euro_amount
    ) VALUES (
        p_customer_id,
        v_product.company_id,
        p_processed_by,
        p_processed_by_name,
        'points_add',
        -v_total_points, -- Négatif car ce sont des points dépensés
        v_product.price * p_quantity
    );
    
    -- Retourner le succès
    RETURN QUERY SELECT 
        true, 
        'Achat effectué avec succès', 
        v_customer.points - v_total_points;
END;
$$ LANGUAGE plpgsql;

-- Politique de sécurité RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_purchases ENABLE ROW LEVEL SECURITY;

-- Les entreprises peuvent voir et gérer leurs propres produits
CREATE POLICY "Companies can manage own products" ON products
    FOR ALL
    USING (company_id = auth.uid());

-- Les entreprises peuvent voir leurs propres achats
CREATE POLICY "Companies can view own purchases" ON product_purchases
    FOR SELECT
    USING (company_id = auth.uid());

-- Grant permissions
GRANT ALL ON products TO authenticated;
GRANT ALL ON product_purchases TO authenticated;
GRANT ALL ON top_products TO authenticated;