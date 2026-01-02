-- Script final pour permettre l'upload avec la clé anon

-- Supprimer toutes les anciennes politiques
DROP POLICY IF EXISTS "Anyone can view card backgrounds" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can upload card backgrounds" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload card backgrounds" ON storage.objects;
DROP POLICY IF EXISTS "Auth users full access to card-backgrounds" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own card backgrounds" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own card backgrounds" ON storage.objects;

-- Créer une politique unique et simple pour les utilisateurs authentifiés
CREATE POLICY "Users can manage card backgrounds"
ON storage.objects
FOR ALL
TO authenticated
USING (bucket_id = 'card-backgrounds')
WITH CHECK (bucket_id = 'card-backgrounds');

-- S'assurer que le bucket est public pour la lecture
UPDATE storage.buckets 
SET public = true,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml']
WHERE id = 'card-backgrounds';

-- Vérifier
SELECT * FROM storage.buckets WHERE id = 'card-backgrounds';