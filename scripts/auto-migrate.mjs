import fetch from 'node-fetch';

const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

async function executeSQLViaAPI(sql, description) {
  console.log(`\n📝 ${description}...`);
  
  try {
    // Utiliser l'API REST de Supabase pour exécuter du SQL brut
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SERVICE_KEY,
        'Authorization': `Bearer ${SERVICE_KEY}`,
        'Prefer': 'return=minimal'
      },
      body: JSON.stringify({
        query: sql
      })
    });
    
    if (response.ok) {
      console.log(`✅ ${description} - Succès`);
      return true;
    } else {
      console.log(`⚠️ ${description} - Échec (${response.status})`);
      return false;
    }
  } catch (error) {
    console.log(`❌ ${description} - Erreur:`, error.message);
    return false;
  }
}

// Utiliser Puppeteer pour automatiser l'interface web
async function executeViaWebInterface() {
  console.log('\n🤖 Automatisation de l\'interface Supabase...\n');
  
  try {
    const { default: puppeteer } = await import('puppeteer');
    
    const browser = await puppeteer.launch({
      headless: false, // Pour voir ce qui se passe
      defaultViewport: null
    });
    
    const page = await browser.newPage();
    
    console.log('1️⃣ Navigation vers Supabase SQL Editor...');
    await page.goto('https://supabase.com/dashboard/project/sdbtjaxyhkicnucktkuj/sql/new', {
      waitUntil: 'networkidle2'
    });
    
    // Attendre que la page se charge
    await page.waitForTimeout(3000);
    
    console.log('2️⃣ Détection de l\'éditeur SQL...');
    
    // Le SQL complet à exécuter
    const fullSQL = `
-- MIGRATION COMPLÈTE FIDAPP
-- ========================

-- 1. BIRTH DATE
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS birth_date DATE;

-- 2. TYPES ENUM
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_type') THEN
    CREATE TYPE account_type AS ENUM ('free', 'starter', 'premium', 'admin');
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('owner', 'admin', 'manager', 'employee', 'super_admin');
  END IF;
END $$;

-- 3. COLONNES PERMISSIONS
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS account_type account_type DEFAULT 'free',
ADD COLUMN IF NOT EXISTS role user_role DEFAULT 'employee',
ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP,
ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP,
ADD COLUMN IF NOT EXISTS max_users INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS current_users INTEGER DEFAULT 1;

-- 4. TABLE FEATURES
CREATE TABLE IF NOT EXISTS features (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  category VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO features (name, description, category) VALUES
('dashboard_view', 'Accès au tableau de bord', 'dashboard'),
('profile_edit', 'Modifier le profil', 'profile'),
('analytics_basic', 'Analytics de base', 'analytics'),
('analytics_advanced', 'Analytics avancées', 'analytics'),
('product_management', 'Gestion des produits', 'products'),
('campaign_management', 'Gestion des campagnes', 'campaigns'),
('customer_management', 'Gestion des clients', 'customers'),
('export_data', 'Export des données', 'data'),
('api_access', 'Accès API', 'api'),
('team_management', 'Gestion d''équipe', 'team'),
('custom_branding', 'Personnalisation de la marque', 'branding'),
('admin_panel', 'Panneau d''administration', 'admin'),
('user_management', 'Gestion des utilisateurs', 'admin'),
('system_settings', 'Paramètres système', 'admin'),
('billing_management', 'Gestion de la facturation', 'billing')
ON CONFLICT (name) DO NOTHING;

-- 5. PERMISSIONS
CREATE TABLE IF NOT EXISTS account_permissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  account_type account_type NOT NULL,
  feature_id UUID REFERENCES features(id) ON DELETE CASCADE,
  is_enabled BOOLEAN DEFAULT false,
  limits JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(account_type, feature_id)
);

-- 6. LIMITES
CREATE TABLE IF NOT EXISTS account_limits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  account_type account_type NOT NULL UNIQUE,
  max_products INTEGER,
  max_campaigns INTEGER,
  max_customers INTEGER,
  max_analytics_days INTEGER,
  max_exports_per_month INTEGER,
  max_api_calls_per_day INTEGER,
  custom_branding BOOLEAN DEFAULT false,
  priority_support BOOLEAN DEFAULT false,
  advanced_analytics BOOLEAN DEFAULT false,
  api_access BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO account_limits (
  account_type, max_products, max_campaigns, max_customers, 
  max_analytics_days, max_exports_per_month, max_api_calls_per_day,
  custom_branding, priority_support, advanced_analytics, api_access
) VALUES 
('free', 10, 1, 100, 7, 5, 0, false, false, false, false),
('starter', 50, 5, 500, 30, 20, 0, false, false, false, false),
('premium', 500, 50, 5000, 365, 100, 1000, true, true, true, true),
('admin', NULL, NULL, NULL, NULL, NULL, NULL, true, true, true, true)
ON CONFLICT (account_type) DO NOTHING;

-- 7. VUE PERMISSIONS
CREATE OR REPLACE VIEW user_permissions AS
SELECT 
  u.id as user_id,
  u.email,
  u.account_type,
  u.role,
  f.name as feature_name,
  f.category,
  ap.is_enabled,
  ap.limits
FROM users u
LEFT JOIN account_permissions ap ON ap.account_type = u.account_type
LEFT JOIN features f ON f.id = ap.feature_id;

-- 8. COMPTE ADMIN
UPDATE users 
SET account_type = 'admin', role = 'super_admin'
WHERE email = 'ravinesiva@gmail.com';

-- 9. CONFIG PERMISSIONS
INSERT INTO account_permissions (account_type, feature_id, is_enabled)
SELECT 'admin', id, true
FROM features
ON CONFLICT (account_type, feature_id) DO NOTHING;

-- VERIFICATION
SELECT 'Migration terminée!' as status;
    `;
    
    // Chercher l'éditeur CodeMirror ou Monaco
    try {
      // Essayer de trouver l'éditeur
      const editorFound = await page.evaluate(() => {
        // Chercher Monaco Editor
        if (window.monaco && window.monaco.editor) {
          const editors = window.monaco.editor.getModels();
          if (editors.length > 0) {
            editors[0].setValue('');
            return true;
          }
        }
        // Chercher CodeMirror
        if (window.CodeMirror) {
          const cm = document.querySelector('.CodeMirror');
          if (cm && cm.CodeMirror) {
            cm.CodeMirror.setValue('');
            return true;
          }
        }
        return false;
      });
      
      if (editorFound) {
        console.log('3️⃣ Éditeur trouvé! Injection du SQL...');
        
        // Injecter le SQL
        await page.evaluate((sql) => {
          if (window.monaco && window.monaco.editor) {
            const editors = window.monaco.editor.getModels();
            if (editors.length > 0) {
              editors[0].setValue(sql);
            }
          } else if (window.CodeMirror) {
            const cm = document.querySelector('.CodeMirror');
            if (cm && cm.CodeMirror) {
              cm.CodeMirror.setValue(sql);
            }
          }
        }, fullSQL);
        
        console.log('4️⃣ SQL injecté! Recherche du bouton RUN...');
        
        // Chercher et cliquer sur le bouton RUN
        const runButton = await page.$('button:has-text("Run"), button:has-text("RUN"), button:has-text("Execute")');
        if (runButton) {
          console.log('5️⃣ Bouton RUN trouvé! Exécution...');
          await runButton.click();
          
          // Attendre le résultat
          await page.waitForTimeout(5000);
          
          console.log('✅ Migration exécutée via l\'interface web!');
        } else {
          console.log('⚠️ Bouton RUN non trouvé - Vérifiez manuellement');
        }
      } else {
        console.log('⚠️ Éditeur non trouvé - La page a peut-être changé');
      }
    } catch (error) {
      console.log('⚠️ Erreur lors de l\'interaction avec l\'éditeur:', error.message);
    }
    
    console.log('\n⏸️ Gardez le navigateur ouvert pour vérifier le résultat');
    console.log('📋 Appuyez sur Ctrl+C quand vous avez terminé');
    
    // Garder le navigateur ouvert
    await new Promise(() => {});
    
  } catch (error) {
    console.log('❌ Erreur Puppeteer:', error.message);
    console.log('\nInstallation de Puppeteer requise:');
    console.log('npm install puppeteer');
  }
}

// Méthode alternative avec node-fetch
async function executeDirectSQL() {
  console.log('\n🔧 Tentative d\'exécution directe...\n');
  
  const migrations = [
    {
      sql: `ALTER TABLE public.users ADD COLUMN IF NOT EXISTS birth_date DATE`,
      description: 'Ajout colonne birth_date'
    },
    {
      sql: `UPDATE users SET account_type = 'admin', role = 'super_admin' WHERE email = 'ravinesiva@gmail.com'`,
      description: 'Configuration compte admin'
    }
  ];
  
  for (const migration of migrations) {
    await executeSQLViaAPI(migration.sql, migration.description);
  }
}

console.log('🚀 Démarrage des migrations automatiques...\n');
console.log('Méthodes disponibles:');
console.log('1. Direct SQL (limité)');
console.log('2. Interface Web (Puppeteer)\n');

// Essayer d'abord la méthode directe
await executeDirectSQL();

// Puis proposer l'automatisation web
console.log('\n📌 Pour une migration complète, utilisez Puppeteer:');
console.log('1. npm install puppeteer');
console.log('2. node scripts/auto-migrate.mjs\n');

// Si Puppeteer est installé, l'utiliser
try {
  await import('puppeteer');
  console.log('✅ Puppeteer détecté! Lancement de l\'automatisation...');
  await executeViaWebInterface();
} catch {
  console.log('⚠️ Puppeteer non installé');
  console.log('\n📋 COPIER LE SQL CI-DESSOUS ET L\'EXÉCUTER MANUELLEMENT:');
  console.log('👉 https://supabase.com/dashboard/project/sdbtjaxyhkicnucktkuj/sql/new\n');
}