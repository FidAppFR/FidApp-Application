-- Ajouter la colonne logo_url à la table users
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS logo_url TEXT;

-- Créer un bucket pour stocker les logos des entreprises
INSERT INTO storage.buckets (id, name, public)
VALUES ('company-logos', 'company-logos', true)
ON CONFLICT (id) DO NOTHING;

-- Politique pour permettre aux utilisateurs authentifiés d'uploader leur logo
CREATE POLICY "Users can upload their own logo" ON storage.objects
FOR INSERT 
WITH CHECK (
    bucket_id = 'company-logos' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Politique pour permettre aux utilisateurs de mettre à jour leur logo
CREATE POLICY "Users can update their own logo" ON storage.objects
FOR UPDATE 
USING (
    bucket_id = 'company-logos' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Politique pour permettre aux utilisateurs de supprimer leur logo
CREATE POLICY "Users can delete their own logo" ON storage.objects
FOR DELETE 
USING (
    bucket_id = 'company-logos' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Politique pour permettre à tous de voir les logos (bucket public)
CREATE POLICY "Logos are publicly accessible" ON storage.objects
FOR SELECT 
USING (bucket_id = 'company-logos');