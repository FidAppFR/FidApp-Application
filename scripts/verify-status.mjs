import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

console.log(`
🔍 VÉRIFICATION STATUT MIGRATION SUPABASE
=========================================

URL: ${SUPABASE_URL}
Vérification pour: ravinesiva@gmail.com

`);

async function checkCurrentStatus() {
  try {
    console.log('📊 Vérification de l\'accès à la base...');
    
    // Test simple de connexion
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('*')
      .eq('email', 'ravinesiva@gmail.com')
      .limit(1);
    
    if (usersError) {
      console.log('❌ Erreur connexion users:', usersError.message);
      return;
    }
    
    if (!users || users.length === 0) {
      console.log('❌ Compte ravinesiva@gmail.com non trouvé');
      return;
    }
    
    const user = users[0];
    console.log('✅ Compte trouvé!\n');
    
    // Afficher les informations du compte
    console.log('📋 INFORMATIONS DU COMPTE:');
    console.log('═══════════════════════════');
    console.log('📧 Email:', user.email);
    console.log('👤 Nom:', `${user.first_name} ${user.last_name}`);
    console.log('🏢 Entreprise:', user.company);
    console.log('📅 Créé le:', user.created_at);
    
    // Vérifier les nouvelles colonnes
    console.log('\n🔍 NOUVELLES COLONNES:');
    console.log('══════════════════════');
    
    const newColumns = [
      'birth_date',
      'account_type', 
      'role',
      'subscription_start_date',
      'subscription_end_date',
      'max_users',
      'current_users'
    ];
    
    let hasAllColumns = true;
    newColumns.forEach(col => {
      if (col in user) {
        const value = user[col];
        if (value !== null && value !== undefined) {
          console.log(`✅ ${col}: ${value}`);
        } else {
          console.log(`⚠️ ${col}: null/undefined`);
        }
      } else {
        console.log(`❌ ${col}: MANQUANT`);
        hasAllColumns = false;
      }
    });
    
    // Vérifier les nouvelles tables
    console.log('\n🗂️ NOUVELLES TABLES:');
    console.log('══════════════════════');
    
    const tablesToCheck = ['features', 'account_permissions', 'account_limits'];
    
    for (const tableName of tablesToCheck) {
      try {
        const { data, error } = await supabase
          .from(tableName)
          .select('*')
          .limit(1);
        
        if (error) {
          console.log(`❌ Table ${tableName}: ${error.message}`);
        } else {
          console.log(`✅ Table ${tableName}: OK`);
        }
      } catch (err) {
        console.log(`❌ Table ${tableName}: ${err.message}`);
      }
    }
    
    // Statut de la migration
    console.log('\n📈 STATUT DE LA MIGRATION:');
    console.log('═══════════════════════════');
    
    const hasBirthDate = 'birth_date' in user;
    const hasAccountType = 'account_type' in user && user.account_type;
    const hasRole = 'role' in user && user.role;
    const isAdmin = user.account_type === 'admin' && user.role === 'super_admin';
    
    if (hasBirthDate && hasAccountType && hasRole) {
      console.log('🎉 MIGRATION RÉUSSIE!');
      console.log('✅ Toutes les colonnes principales sont présentes');
      
      if (isAdmin) {
        console.log('✅ Compte configuré en ADMIN');
      } else {
        console.log('⚠️ Compte PAS en admin - Exécutez la migration');
      }
    } else {
      console.log('⚠️ MIGRATION INCOMPLÈTE');
      console.log('❌ Il manque des colonnes importantes');
      console.log('\n🔧 ACTION REQUISE:');
      console.log('1. Exécutez le script migration-complete.sql');
      console.log('2. Ou suivez les instructions du script run-full-migration.mjs');
    }
    
    // Instructions pour finaliser
    if (!hasAllColumns || !isAdmin) {
      console.log('\n' + '='.repeat(60));
      console.log('📋 POUR TERMINER LA MIGRATION:');
      console.log('='.repeat(60));
      console.log('1. 🔗 Allez sur: https://supabase.com/dashboard/project/sdbtjaxyhkicnucktkuj/sql');
      console.log('2. 📋 Copiez le contenu du fichier: scripts/migration-complete.sql');
      console.log('3. 📝 Collez dans l\'éditeur SQL Supabase');
      console.log('4. 🚀 Cliquez sur "RUN"');
      console.log('5. ✅ Vérifiez les résultats');
      console.log('='.repeat(60));
    }
    
  } catch (error) {
    console.log('❌ Erreur générale:', error.message);
  }
}

// Exécuter la vérification
await checkCurrentStatus();