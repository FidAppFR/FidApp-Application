-- Script pour ajouter la colonne selected_plan si elle n'existe pas
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS selected_plan VARCHAR(50) DEFAULT 'free';

-- Mettre à jour les enregistrements existants qui ont null
UPDATE users 
SET selected_plan = COALESCE(selected_plan, 'free')
WHERE selected_plan IS NULL;

-- Vérifier que la colonne existe
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'users' 
AND column_name = 'selected_plan';

-- Afficher quelques enregistrements pour vérification
SELECT id, email, company, selected_plan
FROM users
LIMIT 5;