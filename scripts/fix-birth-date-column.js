import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
  db: {
    schema: 'public'
  },
  auth: {
    persistSession: false
  }
});

async function fixBirthDateColumn() {
  console.log('🔧 Correction de la colonne birth_date...\n');
  
  try {
    // 1. Vérifier si la colonne existe déjà
    console.log('1️⃣ Vérification de la structure actuelle...');
    const { data: existingUser, error: checkError } = await supabase
      .from('users')
      .select('*')
      .limit(1);
    
    if (checkError) {
      console.log('Erreur lors de la vérification:', checkError);
    }
    
    // 2. Tester une mise à jour sans birth_date
    console.log('\n2️⃣ Test de mise à jour sans birth_date...');
    if (existingUser && existingUser[0]) {
      const { error: updateError } = await supabase
        .from('users')
        .update({
          updated_at: new Date().toISOString()
        })
        .eq('id', existingUser[0].id);
      
      if (!updateError) {
        console.log('✅ Mise à jour réussie sans birth_date');
      }
    }
    
    // 3. Créer un utilisateur test pour vérifier
    console.log('\n3️⃣ Test avec un nouvel utilisateur...');
    const testEmail = `test_profile_${Date.now()}@gmail.com`;
    
    const { data: newUser, error: createError } = await supabase.auth.signUp({
      email: testEmail,
      password: 'TestPassword123!@',
      options: {
        data: {
          company: 'Test Company',
          first_name: 'Test',
          last_name: 'User',
          accept_newsletter: false
        }
      }
    });
    
    if (newUser?.user) {
      console.log('✅ Utilisateur test créé');
      
      // Attendre que le trigger s'exécute
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Tester la mise à jour avec les champs du profil
      const { data: userData } = await supabase
        .from('users')
        .select('*')
        .eq('auth_id', newUser.user.id)
        .single();
      
      if (userData) {
        console.log('📝 Test de mise à jour du profil...');
        
        // Essayer sans birth_date d'abord
        const { error: profileError } = await supabase
          .from('users')
          .update({
            phone: '+33 6 12 34 56 78',
            language: 'FR',
            accept_newsletter: true
          })
          .eq('id', userData.id);
        
        if (!profileError) {
          console.log('✅ Profil mis à jour avec succès (sans birth_date)');
        } else {
          console.log('❌ Erreur:', profileError.message);
        }
      }
      
      // Nettoyer
      await supabase.auth.admin.deleteUser(newUser.user.id);
      console.log('🧹 Utilisateur test supprimé');
    }
    
  } catch (error) {
    console.error('❌ Erreur:', error);
  }
  
  console.log('\n' + '='.repeat(60));
  console.log('📌 SOLUTION POUR AJOUTER LA COLONNE birth_date :');
  console.log('='.repeat(60));
  console.log(`
Allez sur : https://supabase.com/dashboard/project/sdbtjaxyhkicnucktkuj/sql/new

Et exécutez ce SQL :

-- Ajouter la colonne birth_date si elle n'existe pas
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'users' 
        AND column_name = 'birth_date'
    ) THEN
        ALTER TABLE public.users ADD COLUMN birth_date DATE;
        RAISE NOTICE 'Colonne birth_date ajoutée avec succès';
    ELSE
        RAISE NOTICE 'La colonne birth_date existe déjà';
    END IF;
END $$;

-- Vérifier que la colonne a été ajoutée
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'users'
AND column_name IN ('birth_date', 'phone', 'language', 'accept_newsletter')
ORDER BY column_name;
`);
  console.log('='.repeat(60));
}

fixBirthDateColumn().catch(console.error);