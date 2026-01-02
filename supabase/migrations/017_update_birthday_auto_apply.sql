-- Migration pour mettre à jour le type de birthday_auto_apply
-- Passe d'un BOOLEAN à un TEXT avec des options spécifiques

-- Vérifier si la colonne existe et est de type BOOLEAN
DO $$
BEGIN
    -- Si la table existe et que la colonne est de type BOOLEAN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'bonus_settings' 
        AND column_name = 'birthday_auto_apply'
        AND data_type = 'boolean'
    ) THEN
        -- Ajouter une nouvelle colonne temporaire
        ALTER TABLE bonus_settings 
        ADD COLUMN birthday_auto_apply_new TEXT;
        
        -- Migrer les données existantes
        UPDATE bonus_settings 
        SET birthday_auto_apply_new = CASE 
            WHEN birthday_auto_apply = true THEN 'same_day'
            ELSE 'manual'
        END;
        
        -- Supprimer l'ancienne colonne
        ALTER TABLE bonus_settings 
        DROP COLUMN birthday_auto_apply;
        
        -- Renommer la nouvelle colonne
        ALTER TABLE bonus_settings 
        RENAME COLUMN birthday_auto_apply_new TO birthday_auto_apply;
        
        -- Ajouter la contrainte CHECK
        ALTER TABLE bonus_settings 
        ADD CONSTRAINT birthday_auto_apply_check 
        CHECK (birthday_auto_apply IN ('same_day', 'same_month', 'week_before', 'manual'));
        
        -- Définir la valeur par défaut
        ALTER TABLE bonus_settings 
        ALTER COLUMN birthday_auto_apply SET DEFAULT 'same_day';
    END IF;
END $$;