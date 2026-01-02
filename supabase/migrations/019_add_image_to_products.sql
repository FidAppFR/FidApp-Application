-- Migration pour ajouter un champ image aux produits
-- Permet d'associer une image/icône représentative à chaque produit

-- Ajouter la colonne image_url à la table products si elle n'existe pas déjà
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Créer un bucket Supabase pour stocker les images des produits
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'product-images', 
    'product-images', 
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
CREATE POLICY "Public can view product images" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'product-images');

-- Permettre aux utilisateurs authentifiés d'uploader des images
CREATE POLICY "Authenticated users can upload product images" ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'product-images');

-- Permettre aux utilisateurs de supprimer leurs propres images
CREATE POLICY "Users can delete own product images" ON storage.objects
    FOR DELETE
    TO authenticated
    USING (bucket_id = 'product-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Permettre aux utilisateurs de mettre à jour leurs propres images
CREATE POLICY "Users can update own product images" ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (bucket_id = 'product-images' AND auth.uid()::text = (storage.foldername(name))[1]);