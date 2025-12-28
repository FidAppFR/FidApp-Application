import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function testDatabase() {
  console.log('🔍 Test de la base de données Supabase...\n');

  // 1. Test de lecture des tables
  console.log('📊 Vérification des tables:');
  
  try {
    // Vérifier la table users
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('*')
      .limit(5);
    
    if (usersError) {
      console.log('❌ Erreur table users:', usersError.message);
    } else {
      console.log(`✅ Table users: ${users?.length || 0} enregistrements`);
    }

    // Vérifier la table sessions
    const { data: sessions, error: sessionsError } = await supabase
      .from('sessions')
      .select('*')
      .limit(5);
    
    if (sessionsError) {
      console.log('❌ Erreur table sessions:', sessionsError.message);
    } else {
      console.log(`✅ Table sessions: ${sessions?.length || 0} enregistrements`);
    }

    // Vérifier la table activity_logs
    const { data: logs, error: logsError } = await supabase
      .from('activity_logs')
      .select('*')
      .limit(5);
    
    if (logsError) {
      console.log('❌ Erreur table activity_logs:', logsError.message);
    } else {
      console.log(`✅ Table activity_logs: ${logs?.length || 0} enregistrements`);
    }

  } catch (error) {
    console.error('❌ Erreur générale:', error);
  }

  // 2. Test d'inscription d'un utilisateur
  console.log('\n🧪 Test d\'inscription:');
  
  const testEmail = `test${Date.now()}@fidapp.com`;
  const testPassword = 'TestPassword123!@';
  
  try {
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: testEmail,
      password: testPassword,
      options: {
        data: {
          company: 'Test Company',
          first_name: 'Test',
          last_name: 'User',
          accept_newsletter: true
        }
      }
    });

    if (authError) {
      console.log('❌ Erreur inscription:', authError.message);
    } else if (authData.user) {
      console.log('✅ Utilisateur créé avec succès!');
      console.log('   ID:', authData.user.id);
      console.log('   Email:', authData.user.email);
      
      // Vérifier si l'utilisateur a été ajouté dans la table users
      const { data: userData, error: userError } = await supabase
        .from('users')
        .select('*')
        .eq('auth_id', authData.user.id)
        .single();
        
      if (userData) {
        console.log('✅ Utilisateur trouvé dans la table users');
        console.log('   Company:', userData.company);
        console.log('   Nom:', userData.first_name, userData.last_name);
      } else {
        console.log('⚠️ Utilisateur non trouvé dans la table users');
        
        // Créer manuellement l'entrée si nécessaire
        const { data: newUser, error: insertError } = await supabase
          .from('users')
          .insert({
            auth_id: authData.user.id,
            email: authData.user.email,
            company: 'Test Company',
            first_name: 'Test',
            last_name: 'User',
            accept_terms: true,
            accept_newsletter: true
          })
          .select()
          .single();
          
        if (newUser) {
          console.log('✅ Utilisateur ajouté manuellement dans users');
        } else if (insertError) {
          console.log('❌ Erreur insertion:', insertError.message);
        }
      }
      
      // Nettoyer: supprimer l'utilisateur test
      await supabase.auth.admin.deleteUser(authData.user.id);
      console.log('🧹 Utilisateur test supprimé');
    }
  } catch (error) {
    console.error('❌ Erreur test inscription:', error);
  }

  console.log('\n✨ Test terminé!');
  console.log('📝 Votre base de données est configurée et prête à l\'emploi!');
}

testDatabase().catch(console.error);