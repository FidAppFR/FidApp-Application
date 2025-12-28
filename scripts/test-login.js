import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function testLogin() {
  console.log('🔐 Test de connexion...\n');
  
  // Email et mot de passe de test
  const testEmail = 'test@example.com';
  const testPassword = 'TestPassword123!@';
  
  try {
    // 1. Créer un utilisateur de test
    console.log('1️⃣ Création d\'un utilisateur de test...');
    const { data: signUpData, error: signUpError } = await supabase.auth.signUp({
      email: testEmail,
      password: testPassword,
      options: {
        data: {
          company: 'Test Company',
          first_name: 'Test',
          last_name: 'User'
        }
      }
    });
    
    if (signUpError && signUpError.message !== 'User already registered') {
      console.error('❌ Erreur inscription:', signUpError);
    } else {
      console.log('✅ Utilisateur créé ou existe déjà');
    }
    
    // 2. Tester la connexion
    console.log('\n2️⃣ Test de connexion...');
    const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({
      email: testEmail,
      password: testPassword
    });
    
    if (loginError) {
      console.error('❌ Erreur de connexion:', loginError.message);
      console.error('   Détails:', loginError);
      
      // Suggestions
      console.log('\n💡 Vérifiez :');
      console.log('   - L\'email est correct');
      console.log('   - Le mot de passe est correct');
      console.log('   - Le compte existe dans Supabase');
      console.log('   - L\'email a été confirmé si nécessaire');
    } else {
      console.log('✅ Connexion réussie!');
      console.log('   User ID:', loginData.user?.id);
      console.log('   Email:', loginData.user?.email);
      
      // 3. Vérifier la table users
      const { data: userData, error: userError } = await supabase
        .from('users')
        .select('*')
        .eq('auth_id', loginData.user?.id)
        .single();
        
      if (userData) {
        console.log('✅ Données utilisateur trouvées dans la table users');
        console.log('   ID:', userData.id);
        console.log('   Company:', userData.company);
      } else {
        console.log('⚠️ Pas de données dans la table users');
      }
      
      // 4. Déconnexion
      await supabase.auth.signOut();
      console.log('\n✅ Test terminé avec succès!');
    }
    
  } catch (error) {
    console.error('❌ Erreur générale:', error);
  }
  
  // 5. Lister les utilisateurs existants (pour debug)
  console.log('\n📋 Utilisateurs dans la base:');
  const { data: users, error: usersError } = await supabase
    .from('users')
    .select('id, email, company, created_at')
    .limit(5);
    
  if (users && users.length > 0) {
    users.forEach(user => {
      console.log(`   - ${user.email} (${user.company})`);
    });
  } else {
    console.log('   Aucun utilisateur trouvé');
  }
}

testLogin().catch(console.error);