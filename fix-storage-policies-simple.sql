-- Solution simple : désactiver temporairement RLS sur le bucket
-- ATTENTION : À utiliser uniquement pour tester, puis réactiver avec de bonnes politiques

-- Option 1 : Politique très permissive pour tous les utilisateurs authentifiés
DROP POLICY IF EXISTS "Authenticated users can upload card backgrounds" ON storage.objects;

CREATE POLICY "Authenticated users full access card backgrounds" 
ON storage.objects 
TO authenticated
USING (bucket_id = 'card-backgrounds')
WITH CHECK (bucket_id = 'card-backgrounds');

-- Option 2 : Si ça ne marche toujours pas, désactiver RLS temporairement
-- ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- Pour réactiver plus tard :
-- ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;