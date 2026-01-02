-- Migration pour ajouter la personnalisation du fond de carte de fidélité
-- Permet aux entreprises d'uploader une image de fond personnalisée pour leur carte

-- Ajouter la colonne card_background_url à la table users (entreprises)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS card_background_url TEXT,
ADD COLUMN IF NOT EXISTS card_theme TEXT DEFAULT 'gradient' CHECK (card_theme IN ('gradient', 'custom', 'solid'));

-- Créer un bucket Supabase pour stocker les fonds de carte
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'card-backgrounds', 
    'card-backgrounds', 
    true, 
    10485760, -- 10MB max pour des images haute qualité
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 10485760,
    allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];

-- Politique de sécurité pour le bucket
-- Permettre à tous de lire les images (bucket public)
CREATE POLICY "Public can view card backgrounds" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'card-backgrounds');

-- Permettre aux utilisateurs authentifiés d'uploader des images
CREATE POLICY "Authenticated users can upload card backgrounds" ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'card-backgrounds');

-- Permettre aux utilisateurs de supprimer leurs propres images
CREATE POLICY "Users can delete own card backgrounds" ON storage.objects
    FOR DELETE
    TO authenticated
    USING (bucket_id = 'card-backgrounds' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Permettre aux utilisateurs de mettre à jour leurs propres images
CREATE POLICY "Users can update own card backgrounds" ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (bucket_id = 'card-backgrounds' AND auth.uid()::text = (storage.foldername(name))[1]);