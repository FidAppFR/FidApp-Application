-- Script pour corriger les politiques de sécurité du bucket card-backgrounds

-- Supprimer les anciennes politiques si elles existent
DROP POLICY IF EXISTS "Public can view card backgrounds" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload card backgrounds" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own card backgrounds" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own card backgrounds" ON storage.objects;

-- Créer des politiques plus permissives

-- 1. Permettre à tous de voir les images (bucket public)
CREATE POLICY "Anyone can view card backgrounds" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'card-backgrounds');

-- 2. Permettre aux utilisateurs authentifiés d'uploader
CREATE POLICY "Authenticated can upload card backgrounds" 
ON storage.objects FOR INSERT 
TO authenticated
WITH CHECK (bucket_id = 'card-backgrounds');

-- 3. Permettre aux utilisateurs de mettre à jour leurs propres images
CREATE POLICY "Users can update own card backgrounds" 
ON storage.objects FOR UPDATE 
TO authenticated
USING (bucket_id = 'card-backgrounds' AND auth.uid()::text = (storage.foldername(name))[1])
WITH CHECK (bucket_id = 'card-backgrounds');

-- 4. Permettre aux utilisateurs de supprimer leurs propres images
CREATE POLICY "Users can delete own card backgrounds" 
ON storage.objects FOR DELETE 
TO authenticated
USING (bucket_id = 'card-backgrounds' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Vérifier que le bucket est bien public
UPDATE storage.buckets 
SET public = true 
WHERE id = 'card-backgrounds';

-- Afficher les politiques actives
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'objects' 
AND policyname LIKE '%card backgrounds%';