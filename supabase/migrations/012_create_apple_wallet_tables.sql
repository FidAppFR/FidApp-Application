-- Table pour stocker les passes Apple Wallet générés
CREATE TABLE IF NOT EXISTS apple_wallet_passes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    serial_number VARCHAR(255) UNIQUE NOT NULL,
    pass_data JSONB NOT NULL,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    needs_update BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(customer_id, company_id)
);

-- Table pour gérer les appareils enregistrés
CREATE TABLE IF NOT EXISTS wallet_devices (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_id VARCHAR(255) NOT NULL,
    pass_type_id VARCHAR(255) NOT NULL,
    serial_number VARCHAR(255) NOT NULL REFERENCES apple_wallet_passes(serial_number) ON DELETE CASCADE,
    push_token TEXT,
    registered_at TIMESTAMPTZ DEFAULT NOW(),
    last_seen TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(device_id, serial_number)
);

-- Index pour améliorer les performances
CREATE INDEX idx_wallet_passes_customer ON apple_wallet_passes(customer_id);
CREATE INDEX idx_wallet_passes_company ON apple_wallet_passes(company_id);
CREATE INDEX idx_wallet_passes_serial ON apple_wallet_passes(serial_number);
CREATE INDEX idx_wallet_devices_serial ON wallet_devices(serial_number);
CREATE INDEX idx_wallet_devices_device ON wallet_devices(device_id);

-- Trigger pour mettre à jour automatiquement le pass quand les points changent
CREATE OR REPLACE FUNCTION update_wallet_pass_on_points_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Marquer le pass comme nécessitant une mise à jour
    UPDATE apple_wallet_passes
    SET needs_update = true,
        last_updated = NOW(),
        pass_data = jsonb_set(
            pass_data,
            '{points}',
            to_jsonb(NEW.points)
        )
    WHERE customer_id = NEW.id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_wallet_pass
AFTER UPDATE OF points ON customers
FOR EACH ROW
WHEN (OLD.points IS DISTINCT FROM NEW.points)
EXECUTE FUNCTION update_wallet_pass_on_points_change();

-- Fonction pour nettoyer les vieux appareils non actifs
CREATE OR REPLACE FUNCTION cleanup_inactive_devices()
RETURNS void AS $$
BEGIN
    DELETE FROM wallet_devices
    WHERE last_seen < NOW() - INTERVAL '6 months';
END;
$$ LANGUAGE plpgsql;

-- Permissions RLS
ALTER TABLE apple_wallet_passes ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_devices ENABLE ROW LEVEL SECURITY;

-- Politique pour que les clients puissent voir leurs propres passes
CREATE POLICY "Customers can view own passes" ON apple_wallet_passes
    FOR SELECT
    USING (customer_id IN (
        SELECT id FROM customers WHERE email = current_user
    ));

-- Politique pour que les entreprises puissent gérer les passes de leurs clients
CREATE POLICY "Companies can manage customer passes" ON apple_wallet_passes
    FOR ALL
    USING (company_id = auth.uid());

-- Politique pour les appareils
CREATE POLICY "Devices can register themselves" ON wallet_devices
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Devices can update themselves" ON wallet_devices
    FOR UPDATE
    USING (device_id = current_setting('app.device_id', true));

CREATE POLICY "Devices can unregister themselves" ON wallet_devices
    FOR DELETE
    USING (device_id = current_setting('app.device_id', true));