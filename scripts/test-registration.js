import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function testRegistration() {
  console.log('🧪 Test d\'inscription complet avec toutes les données\n');
  console.log('========================================\n');
  
  // Générer un email unique pour le test
  const timestamp = Date.now();
  const testData = {
    email: `test${timestamp}@gmail.com`,
    password: 'TestPassword123!@#',
    company: 'Ma Société Test',
    firstName: 'Jean',
    lastName: 'Dupont',
    acceptTerms: true,
    acceptNewsletter: true,
    selectedPlan: 'starter'
  };
  
  console.log('📝 Données d\'inscription:');
  console.log('   Email:', testData.email);
  console.log('   Entreprise:', testData.company);
  console.log('   Nom complet:', testData.firstName, testData.lastName);
  console.log('   Conditions acceptées:', testData.acceptTerms);
  console.log('   Newsletter:', testData.acceptNewsletter);
  console.log('   Plan:', testData.selectedPlan);
  console.log('');
  
  try {
    // 1. Créer le compte
    console.log('1️⃣ Création du compte...');
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: testData.email,
      password: testData.password,
      options: {
        data: {
          company: testData.company,
          first_name: testData.firstName,
          last_name: testData.lastName,
          accept_terms: testData.acceptTerms,
          accept_newsletter: testData.acceptNewsletter,
          selected_plan: testData.selectedPlan
        }
      }
    });
    
    if (authError) {
      console.error('❌ Erreur lors de l\'inscription:', authError.message);
      return;
    }
    
    console.log('✅ Compte créé avec succès!');
    console.log('   User ID:', authData.user?.id);
    console.log('');
    
    // 2. Vérifier les données dans la table users
    console.log('2️⃣ Vérification des données enregistrées...');
    
    // Attendre un peu pour que le trigger s'exécute
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('*')
      .eq('auth_id', authData.user?.id)
      .single();
    
    if (userError) {
      console.error('❌ Erreur lors de la récupération:', userError.message);
    } else if (userData) {
      console.log('✅ Données trouvées dans la table users:');
      console.log('   ✔️ ID unique:', userData.id);
      console.log('   ✔️ Email:', userData.email);
      console.log('   ✔️ Entreprise:', userData.company);
      console.log('   ✔️ Prénom:', userData.first_name);
      console.log('   ✔️ Nom:', userData.last_name);
      console.log('   ✔️ Conditions acceptées:', userData.accept_terms);
      console.log('   ✔️ Newsletter:', userData.accept_newsletter);
      console.log('   ✔️ Plan sélectionné:', userData.selected_plan || 'non défini');
      console.log('   ✔️ Date création:', userData.created_at);
      console.log('');
      
      // Vérifier que toutes les données sont correctes
      let allCorrect = true;
      
      if (userData.company !== testData.company) {
        console.error('❌ Entreprise incorrecte');
        allCorrect = false;
      }
      if (userData.first_name !== testData.firstName) {
        console.error('❌ Prénom incorrect');
        allCorrect = false;
      }
      if (userData.last_name !== testData.lastName) {
        console.error('❌ Nom incorrect');
        allCorrect = false;
      }
      if (userData.accept_terms !== testData.acceptTerms) {
        console.error('❌ Consentement conditions incorrect');
        allCorrect = false;
      }
      if (userData.accept_newsletter !== testData.acceptNewsletter) {
        console.error('❌ Consentement newsletter incorrect');
        allCorrect = false;
      }
      
      if (allCorrect) {
        console.log('🎉 Toutes les données sont correctement enregistrées!');
      } else {
        console.log('⚠️ Certaines données ne sont pas correctement enregistrées');
      }
    } else {
      console.error('❌ Aucune donnée trouvée dans la table users');
    }
    
    // 3. Vérifier les logs d'activité
    console.log('\n3️⃣ Vérification des logs d\'activité...');
    const { data: logs, error: logsError } = await supabase
      .from('activity_logs')
      .select('*')
      .eq('user_id', userData?.id)
      .order('created_at', { ascending: false })
      .limit(5);
    
    if (logs && logs.length > 0) {
      console.log('✅ Logs trouvés:');
      logs.forEach(log => {
        console.log(`   - ${log.action}: ${log.description}`);
      });
    }
    
    // 4. Nettoyer (optionnel)
    console.log('\n4️⃣ Nettoyage...');
    if (authData.user?.id) {
      // Supprimer l'utilisateur de test
      await supabase.auth.admin.deleteUser(authData.user.id);
      console.log('✅ Utilisateur de test supprimé');
    }
    
  } catch (error) {
    console.error('❌ Erreur générale:', error);
  }
  
  console.log('\n========================================');
  console.log('✨ Test terminé!');
}

testRegistration().catch(console.error);