import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

console.log(`
⚠️  IMPORTANT - EXÉCUTEZ CE SQL MAINTENANT
==========================================

Pour que la date de naissance fonctionne, vous DEVEZ exécuter ce SQL :

1. Cliquez sur ce lien pour ouvrir l'éditeur SQL Supabase :
   👉 https://supabase.com/dashboard/project/sdbtjaxyhkicnucktkuj/sql/new

2. Copiez et collez EXACTEMENT ce code SQL :

============================================================
-- Ajouter la colonne birth_date à la table users
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS birth_date DATE;

-- Vérifier que la colonne a été ajoutée
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'users'
AND column_name = 'birth_date';
============================================================

3. Cliquez sur "RUN" ou "Exécuter"

4. Vous devriez voir un message de succès

5. Testez ensuite votre profil

`);

// Tester si on peut créer un utilisateur avec birth_date
async function testBirthDate() {
  console.log('🧪 Test de la fonctionnalité birth_date...\n');
  
  try {
    // Créer un utilisateur test
    const testEmail = `birth_test_${Date.now()}@gmail.com`;
    const testBirthDate = '1990-05-15';
    
    console.log('1️⃣ Création d\'un utilisateur test...');
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: testEmail,
      password: 'TestPassword123!@',
      options: {
        data: {
          company: 'Test Birth Company',
          first_name: 'Birth',
          last_name: 'Test',
          accept_newsletter: false
        }
      }
    });
    
    if (authError) {
      console.error('❌ Erreur création:', authError.message);
      return;
    }
    
    if (authData.user) {
      console.log('✅ Utilisateur créé:', authData.user.id);
      
      // Attendre le trigger
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // Récupérer l'utilisateur dans la table
      const { data: userData, error: fetchError } = await supabase
        .from('users')
        .select('*')
        .eq('auth_id', authData.user.id)
        .single();
      
      if (userData) {
        console.log('✅ Utilisateur trouvé dans la table users');
        console.log('   ID:', userData.id);
        
        // Tester la mise à jour avec birth_date
        console.log('\n2️⃣ Test de mise à jour avec birth_date...');
        const { error: updateError } = await supabase
          .from('users')
          .update({ 
            birth_date: testBirthDate,
            phone: '+33 6 12 34 56 78'
          })
          .eq('id', userData.id);
        
        if (updateError) {
          console.error('❌ ERREUR lors de la mise à jour:', updateError.message);
          console.log('\n⚠️ LA COLONNE birth_date N\'EXISTE PAS ENCORE !');
          console.log('👆 EXÉCUTEZ LE SQL CI-DESSUS DANS SUPABASE');
        } else {
          console.log('✅ Mise à jour réussie avec birth_date !');
          
          // Vérifier que la date est bien enregistrée
          const { data: verifyData, error: verifyError } = await supabase
            .from('users')
            .select('birth_date, phone')
            .eq('id', userData.id)
            .single();
          
          if (verifyData) {
            console.log('✅ Vérification des données:');
            console.log('   Date de naissance:', verifyData.birth_date || 'NON ENREGISTRÉE');
            console.log('   Téléphone:', verifyData.phone || 'NON ENREGISTRÉ');
            
            if (verifyData.birth_date === testBirthDate) {
              console.log('\n🎉 LA DATE DE NAISSANCE FONCTIONNE CORRECTEMENT !');
            } else {
              console.log('\n⚠️ La date n\'a pas été enregistrée');
              console.log('👆 EXÉCUTEZ LE SQL CI-DESSUS');
            }
          }
        }
      }
      
      // Nettoyer
      await supabase.auth.admin.deleteUser(authData.user.id);
      console.log('\n🧹 Utilisateur test supprimé');
    }
    
  } catch (error) {
    console.error('❌ Erreur générale:', error);
  }
}

// Vérifier les colonnes existantes
async function checkColumns() {
  console.log('\n📊 Vérification des colonnes de la table users...\n');
  
  try {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .limit(1);
    
    if (data && data.length > 0) {
      const columns = Object.keys(data[0]);
      console.log('Colonnes existantes:');
      columns.forEach(col => {
        const icon = col === 'birth_date' ? '✅' : '  ';
        console.log(`${icon} ${col}`);
      });
      
      if (!columns.includes('birth_date')) {
        console.log('\n❌ LA COLONNE birth_date N\'EXISTE PAS !');
        console.log('👆 EXÉCUTEZ LE SQL CI-DESSUS POUR L\'AJOUTER');
      } else {
        console.log('\n✅ La colonne birth_date existe déjà !');
      }
    }
  } catch (error) {
    console.error('Erreur:', error);
  }
}

// Exécuter les tests
(async () => {
  await checkColumns();
  await testBirthDate();
})();