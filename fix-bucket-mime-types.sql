-- Script pour corriger les types MIME acceptés dans le bucket card-backgrounds

-- Mettre à jour le bucket pour accepter PNG et autres formats d'image
UPDATE storage.buckets 
SET allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml']
WHERE id = 'card-backgrounds';

-- Vérifier la mise à jour
SELECT id, name, public, file_size_limit, allowed_mime_types 
FROM storage.buckets 
WHERE id = 'card-backgrounds';