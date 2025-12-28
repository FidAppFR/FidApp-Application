-- VERSION SIMPLIFIÉE - Script sûr pour ajouter la colonne qr_code_id
-- Exécutez ce script dans Supabase SQL Editor

-- Étape 1 : Ajouter la colonne (ne fait rien si elle existe déjà)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS qr_code_id VARCHAR(20);

-- Étape 2 : Vérifier que la colonne a été ajoutée
SELECT COUNT(*) as nb_users_sans_qr_code
FROM users 
WHERE qr_code_id IS NULL;

-- Étape 3 : Générer un ID pour un utilisateur test (remplacez l'ID)
-- UPDATE users 
-- SET qr_code_id = 'TEST' || substr(md5(random()::text), 1, 8)
-- WHERE id = 'VOTRE-USER-ID-ICI' AND qr_code_id IS NULL;

-- Étape 4 : Voir les QR codes existants
SELECT id, company, qr_code_id 
FROM users 
LIMIT 10;