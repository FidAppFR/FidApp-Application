import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

console.log(`
⚠️  IMPORTANT: 
Pour corriger complètement l'enregistrement des données, 
vous devez exécuter ce SQL dans votre dashboard Supabase:

1. Allez sur: https://supabase.com/dashboard/project/sdbtjaxyhkicnucktkuj/sql/new
2. Copiez et exécutez ce SQL:

============================================================

-- Ajouter la colonne selected_plan si elle n'existe pas
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS selected_plan VARCHAR(50) DEFAULT 'free';

-- Mettre à jour la fonction pour capturer TOUTES les données
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Insérer ou mettre à jour l'utilisateur
    INSERT INTO public.users (
        auth_id, 
        email, 
        company, 
        first_name, 
        last_name, 
        accept_terms,
        accept_newsletter,
        selected_plan,
        language,
        created_at,
        is_active,
        email_verified
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'company', ''),
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        COALESCE((NEW.raw_user_meta_data->>'accept_terms')::boolean, false),
        COALESCE((NEW.raw_user_meta_data->>'accept_newsletter')::boolean, false),
        COALESCE(NEW.raw_user_meta_data->>'selected_plan', 'free'),
        COALESCE(NEW.raw_user_meta_data->>'language', 'FR'),
        NOW(),
        true,
        NEW.email_confirmed_at IS NOT NULL
    )
    ON CONFLICT (auth_id) 
    DO UPDATE SET
        company = COALESCE(NEW.raw_user_meta_data->>'company', EXCLUDED.company),
        first_name = COALESCE(NEW.raw_user_meta_data->>'first_name', EXCLUDED.first_name),
        last_name = COALESCE(NEW.raw_user_meta_data->>'last_name', EXCLUDED.last_name),
        accept_terms = COALESCE((NEW.raw_user_meta_data->>'accept_terms')::boolean, EXCLUDED.accept_terms),
        accept_newsletter = COALESCE((NEW.raw_user_meta_data->>'accept_newsletter')::boolean, EXCLUDED.accept_newsletter),
        selected_plan = COALESCE(NEW.raw_user_meta_data->>'selected_plan', EXCLUDED.selected_plan),
        updated_at = NOW(),
        email_verified = NEW.email_confirmed_at IS NOT NULL;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recréer le trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Créer aussi un trigger pour les mises à jour
CREATE OR REPLACE FUNCTION public.handle_user_update()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.users
    SET
        email = NEW.email,
        email_verified = NEW.email_confirmed_at IS NOT NULL,
        updated_at = NOW()
    WHERE auth_id = NEW.id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;
CREATE TRIGGER on_auth_user_updated
    AFTER UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_user_update();

============================================================

3. Une fois exécuté, testez à nouveau l'inscription
`);

// Tester la structure actuelle
console.log('\n📊 Vérification de la structure actuelle...\n');

try {
  // Vérifier les colonnes de la table users
  const { data: columns, error } = await supabase
    .from('users')
    .select('*')
    .limit(1);
  
  if (columns && columns.length > 0) {
    console.log('Colonnes disponibles dans la table users:');
    Object.keys(columns[0]).forEach(col => {
      console.log(`   - ${col}`);
    });
  }
  
  // Afficher les derniers utilisateurs créés
  const { data: users, error: usersError } = await supabase
    .from('users')
    .select('email, company, first_name, last_name, accept_terms, accept_newsletter, created_at')
    .order('created_at', { ascending: false })
    .limit(3);
  
  if (users && users.length > 0) {
    console.log('\nDerniers utilisateurs créés:');
    users.forEach(user => {
      console.log(`\n   Email: ${user.email}`);
      console.log(`   Entreprise: ${user.company}`);
      console.log(`   Nom: ${user.first_name} ${user.last_name}`);
      console.log(`   Conditions: ${user.accept_terms}`);
      console.log(`   Newsletter: ${user.accept_newsletter}`);
    });
  }
  
} catch (error) {
  console.error('Erreur:', error);
}