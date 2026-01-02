-- Migration pour ajouter un champ image aux offres
-- Permet d'associer une image/icône représentative à chaque offre

-- Ajouter la colonne image_url à la table offers
ALTER TABLE offers 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Créer un bucket Supabase pour stocker les images des offres
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'offer-images', 
    'offer-images', 
    true, 
    5242880, -- 5MB max
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/svg+xml']
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/svg+xml'];

-- Politique de sécurité pour le bucket
-- Permettre à tous de lire les images (bucket public)
CREATE POLICY "Public can view offer images" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'offer-images');

-- Permettre aux utilisateurs authentifiés d'uploader des images
CREATE POLICY "Authenticated users can upload offer images" ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'offer-images');

-- Permettre aux utilisateurs de supprimer leurs propres images
CREATE POLICY "Users can delete own offer images" ON storage.objects
    FOR DELETE
    TO authenticated
    USING (bucket_id = 'offer-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Permettre aux utilisateurs de mettre à jour leurs propres images
CREATE POLICY "Users can update own offer images" ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (bucket_id = 'offer-images' AND auth.uid()::text = (storage.foldername(name))[1]);