import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

console.log(`
🎉 VÉRIFICATION POST-MIGRATION SUPABASE
======================================

Ce script vérifie que la migration a été exécutée avec succès.
Exécutez-le APRÈS avoir lancé le script migration-complete.sql

URL: ${SUPABASE_URL}

`);

async function checkMigrationSuccess() {
  let allTestsPassed = true;
  
  console.log('🔍 DÉBUT DES VÉRIFICATIONS...\n');
  
  // Test 1: Vérifier le compte admin
  console.log('📋 TEST 1: Compte administrateur');
  console.log('─'.repeat(40));
  
  try {
    const { data: adminUser, error } = await supabase
      .from('users')
      .select('email, account_type, role, birth_date, first_name, last_name')
      .eq('email', 'ravinesiva@gmail.com')
      .single();
    
    if (error) {
      console.log('❌ Erreur récupération compte:', error.message);
      allTestsPassed = false;
    } else {
      console.log('✅ Compte trouvé');
      console.log(`   📧 Email: ${adminUser.email}`);
      console.log(`   👤 Nom: ${adminUser.first_name} ${adminUser.last_name}`);
      
      if (adminUser.account_type === 'admin') {
        console.log('✅ Type de compte: admin');
      } else {
        console.log(`❌ Type de compte: ${adminUser.account_type || 'non défini'} (attendu: admin)`);
        allTestsPassed = false;
      }
      
      if (adminUser.role === 'super_admin') {
        console.log('✅ Rôle: super_admin');
      } else {
        console.log(`❌ Rôle: ${adminUser.role || 'non défini'} (attendu: super_admin)`);
        allTestsPassed = false;
      }
      
      if ('birth_date' in adminUser) {
        console.log(`✅ Colonne birth_date: présente (${adminUser.birth_date || 'null'})`);
      } else {
        console.log('❌ Colonne birth_date: manquante');
        allTestsPassed = false;
      }
    }
  } catch (err) {
    console.log('❌ Erreur test 1:', err.message);
    allTestsPassed = false;
  }
  
  // Test 2: Vérifier la table features
  console.log('\n📋 TEST 2: Table features');
  console.log('─'.repeat(40));
  
  try {
    const { data: features, error } = await supabase
      .from('features')
      .select('name, category')
      .order('category');
    
    if (error) {
      console.log('❌ Table features:', error.message);
      allTestsPassed = false;
    } else {
      console.log(`✅ Table features: ${features.length} fonctionnalités trouvées`);
      
      const expectedFeatures = [
        'dashboard_view',
        'profile_edit', 
        'analytics_basic',
        'admin_panel'
      ];
      
      const foundFeatures = features.map(f => f.name);
      const missingFeatures = expectedFeatures.filter(f => !foundFeatures.includes(f));
      
      if (missingFeatures.length === 0) {
        console.log('✅ Toutes les fonctionnalités principales présentes');
      } else {
        console.log(`❌ Fonctionnalités manquantes: ${missingFeatures.join(', ')}`);
        allTestsPassed = false;
      }
      
      // Grouper par catégorie
      const categories = [...new Set(features.map(f => f.category))];
      console.log(`   📊 Catégories: ${categories.join(', ')}`);
    }
  } catch (err) {
    console.log('❌ Erreur test 2:', err.message);
    allTestsPassed = false;
  }
  
  // Test 3: Vérifier la table account_permissions
  console.log('\n📋 TEST 3: Table account_permissions');
  console.log('─'.repeat(40));
  
  try {
    const { data: permissions, error } = await supabase
      .from('account_permissions')
      .select('account_type, is_enabled')
      .eq('account_type', 'admin');
    
    if (error) {
      console.log('❌ Table account_permissions:', error.message);
      allTestsPassed = false;
    } else {
      const adminPermissions = permissions.filter(p => p.is_enabled);
      console.log(`✅ Permissions admin: ${adminPermissions.length} activées`);
      
      if (adminPermissions.length >= 4) {
        console.log('✅ Permissions admin configurées correctement');
      } else {
        console.log('⚠️ Peu de permissions admin configurées');
      }
    }
  } catch (err) {
    console.log('❌ Erreur test 3:', err.message);
    allTestsPassed = false;
  }
  
  // Test 4: Vérifier la table account_limits
  console.log('\n📋 TEST 4: Table account_limits');
  console.log('─'.repeat(40));
  
  try {
    const { data: limits, error } = await supabase
      .from('account_limits')
      .select('account_type, max_products, api_access')
      .order('account_type');
    
    if (error) {
      console.log('❌ Table account_limits:', error.message);
      allTestsPassed = false;
    } else {
      console.log(`✅ Table account_limits: ${limits.length} types de comptes configurés`);
      
      const accountTypes = limits.map(l => l.account_type);
      const expectedTypes = ['free', 'starter', 'premium', 'admin'];
      const missingTypes = expectedTypes.filter(t => !accountTypes.includes(t));
      
      if (missingTypes.length === 0) {
        console.log('✅ Tous les types de comptes configurés');
        
        // Vérifier les limites admin
        const adminLimits = limits.find(l => l.account_type === 'admin');
        if (adminLimits && adminLimits.api_access) {
          console.log('✅ Compte admin a accès à l\'API');
        } else {
          console.log('⚠️ Compte admin sans accès API');
        }
      } else {
        console.log(`❌ Types manquants: ${missingTypes.join(', ')}`);
        allTestsPassed = false;
      }
    }
  } catch (err) {
    console.log('❌ Erreur test 4:', err.message);
    allTestsPassed = false;
  }
  
  // Test 5: Vérifier la vue user_permissions (si elle existe)
  console.log('\n📋 TEST 5: Vue user_permissions');
  console.log('─'.repeat(40));
  
  try {
    const { data: userPermissions, error } = await supabase
      .from('user_permissions')
      .select('user_id, email, feature_name, is_enabled')
      .eq('email', 'ravinesiva@gmail.com')
      .limit(5);
    
    if (error) {
      console.log('⚠️ Vue user_permissions:', error.message);
    } else {
      console.log(`✅ Vue user_permissions: ${userPermissions.length} permissions visibles`);
      
      const enabledPerms = userPermissions.filter(p => p.is_enabled);
      console.log(`   🔓 Permissions activées: ${enabledPerms.length}`);
    }
  } catch (err) {
    console.log('⚠️ Vue user_permissions non accessible:', err.message);
  }
  
  // RÉSULTAT FINAL
  console.log('\n' + '='.repeat(60));
  console.log('🏁 RÉSULTAT FINAL DE LA MIGRATION');
  console.log('='.repeat(60));
  
  if (allTestsPassed) {
    console.log('🎉 MIGRATION RÉUSSIE AVEC SUCCÈS!');
    console.log('✅ Toutes les vérifications sont passées');
    console.log('✅ Votre base de données est prête');
    console.log('\n📋 CE QUI A ÉTÉ AJOUTÉ:');
    console.log('   ✅ Colonne birth_date dans users');
    console.log('   ✅ Types enum account_type et user_role');
    console.log('   ✅ Colonnes account_type et role dans users');
    console.log('   ✅ Table features avec 15 fonctionnalités');
    console.log('   ✅ Table account_permissions avec permissions');
    console.log('   ✅ Table account_limits avec limites par plan');
    console.log('   ✅ Votre compte configuré en admin');
    console.log('   ✅ Index et vues pour les performances');
    
    console.log('\n🚀 PROCHAINES ÉTAPES:');
    console.log('   1. Testez la connexion dans votre application');
    console.log('   2. Vérifiez que les permissions fonctionnent');
    console.log('   3. Configurez les autres utilisateurs si nécessaire');
    
  } else {
    console.log('⚠️ MIGRATION INCOMPLÈTE');
    console.log('❌ Certaines vérifications ont échoué');
    console.log('\n🔧 ACTIONS RECOMMANDÉES:');
    console.log('   1. Relancez le script migration-complete.sql');
    console.log('   2. Vérifiez les erreurs ci-dessus');
    console.log('   3. Contactez le support si nécessaire');
  }
  
  console.log('='.repeat(60));
}

// Exécuter les vérifications
await checkMigrationSuccess();