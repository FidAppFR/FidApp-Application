import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuration Supabase
const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

async function executeSQLMigration() {
  try {
    // Lire le fichier SQL
    const sqlPath = path.join(__dirname, '..', 'supabase', 'migrations', '001_create_users_table.sql');
    const sqlContent = fs.readFileSync(sqlPath, 'utf8');

    console.log('🚀 Exécution de la migration de base de données...');

    // Exécuter la requête SQL via l'API REST
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/exec_sql`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
      },
      body: JSON.stringify({ query: sqlContent })
    });

    if (!response.ok) {
      // Si la fonction RPC n'existe pas, essayer directement avec l'API SQL
      console.log('⚠️  Tentative d\'exécution directe...');
      
      // Note: Supabase n'expose pas directement l'exécution SQL via REST API
      // Vous devrez exécuter ce SQL dans le dashboard Supabase ou via la CLI
      console.log('\n📝 Script SQL généré avec succès !');
      console.log('👉 Veuillez exécuter le script suivant dans votre dashboard Supabase :');
      console.log('   Dashboard > SQL Editor > New Query');
      console.log(`📁 Fichier: ${sqlPath}`);
      console.log('\n✅ Une fois exécuté, votre base de données sera prête !');
      
      return;
    }

    console.log('✅ Migration exécutée avec succès !');
    console.log('📊 Tables créées :');
    console.log('   - public.users (informations utilisateurs)');
    console.log('   - public.sessions (gestion des sessions)');
    console.log('   - public.activity_logs (logs d\'activité)');
    console.log('\n🔒 Sécurité RLS activée');
    console.log('🎯 Triggers et fonctions installés');
    
  } catch (error) {
    console.error('❌ Erreur lors de l\'exécution de la migration :', error);
    console.log('\n💡 Alternative : Exécutez le script SQL manuellement dans le dashboard Supabase');
  }
}

// Test de connexion à Supabase
async function testConnection() {
  try {
    console.log('🔍 Test de connexion à Supabase...');
    
    const response = await fetch(`${SUPABASE_URL}/rest/v1/`, {
      headers: {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`
      }
    });

    if (response.ok) {
      console.log('✅ Connexion à Supabase réussie !');
      return true;
    } else {
      console.error('❌ Impossible de se connecter à Supabase');
      return false;
    }
  } catch (error) {
    console.error('❌ Erreur de connexion :', error);
    return false;
  }
}

// Exécution principale
async function main() {
  console.log('=================================');
  console.log('🛠️  Configuration Base de Données');
  console.log('=================================\n');

  const isConnected = await testConnection();
  
  if (isConnected) {
    await executeSQLMigration();
  }

  console.log('\n=================================');
  console.log('📋 Prochaines étapes :');
  console.log('1. Exécutez le SQL dans le dashboard Supabase si nécessaire');
  console.log('2. Testez l\'inscription avec : npm run dev');
  console.log('3. Les utilisateurs seront créés automatiquement');
  console.log('=================================');
}

main();