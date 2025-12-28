-- Ajouter une colonne pour stocker l'identifiant unique du QR code de chaque entreprise
-- Cet identifiant restera permanent pour chaque entreprise

-- 1. Ajouter la colonne si elle n'existe pas
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS qr_code_id VARCHAR(20) UNIQUE;

-- 2. Fonction pour générer un ID unique de 10 caractères
CREATE OR REPLACE FUNCTION generate_qr_code_id()
RETURNS TEXT AS $$
DECLARE
    characters TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result TEXT := '';
    i INTEGER := 0;
BEGIN
    -- Générer un ID de 10 caractères
    FOR i IN 1..10 LOOP
        result := result || substr(characters, floor(random() * length(characters) + 1)::int, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 3. Fonction trigger pour générer automatiquement un QR code ID lors de la création
CREATE OR REPLACE FUNCTION set_qr_code_id()
RETURNS TRIGGER AS $$
DECLARE
    new_id TEXT;
    done BOOLEAN := FALSE;
BEGIN
    -- Si qr_code_id est null, en générer un nouveau
    IF NEW.qr_code_id IS NULL THEN
        WHILE NOT done LOOP
            new_id := generate_qr_code_id();
            -- Vérifier l'unicité
            IF NOT EXISTS (SELECT 1 FROM users WHERE qr_code_id = new_id) THEN
                NEW.qr_code_id := new_id;
                done := TRUE;
            END IF;
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Créer le trigger (le DROP IF EXISTS est sûr)
DROP TRIGGER IF EXISTS set_qr_code_id_trigger ON users;
CREATE TRIGGER set_qr_code_id_trigger
BEFORE INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION set_qr_code_id();

-- 5. Générer des QR codes pour les enregistrements existants
-- Cette partie génère un ID unique pour chaque ligne existante
DO $$
DECLARE
    row_record RECORD;
    new_id TEXT;
    done BOOLEAN;
BEGIN
    FOR row_record IN SELECT id FROM users WHERE qr_code_id IS NULL LOOP
        done := FALSE;
        WHILE NOT done LOOP
            new_id := generate_qr_code_id();
            -- Vérifier que l'ID est unique
            IF NOT EXISTS (SELECT 1 FROM users WHERE qr_code_id = new_id) THEN
                UPDATE users SET qr_code_id = new_id WHERE id = row_record.id;
                done := TRUE;
            END IF;
        END LOOP;
    END LOOP;
END $$;

-- Message de confirmation
SELECT 'Colonne qr_code_id ajoutée avec succès!' as message;