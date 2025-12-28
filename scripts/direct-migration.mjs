import pg from 'pg';
const { Client } = pg;

// Configuration de connexion directe
const config = {
  host: 'aws-0-eu-central-1.pooler.supabase.com',
  port: 5432,
  database: 'postgres',
  user: 'postgres.sdbtjaxyhkicnucktkuj',
  password: 'QuoJPgmP3jQQy5Xr',
  ssl: {
    rejectUnauthorized: false
  }
};

async function runMigration() {
  const client = new Client(config);
  
  console.log('🚀 Connexion à PostgreSQL...\n');
  
  try {
    await client.connect();
    console.log('✅ Connecté avec succès!\n');
    
    // Liste des migrations à exécuter
    const migrations = [
      {
        name: 'Ajout colonne birth_date',
        sql: `ALTER TABLE public.users ADD COLUMN IF NOT EXISTS birth_date DATE;`
      },
      {
        name: 'Création type account_type',
        sql: `
          DO $$ 
          BEGIN
            IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_type') THEN
              CREATE TYPE account_type AS ENUM ('free', 'starter', 'premium', 'admin');
            END IF;
          END $$;
        `
      },
      {
        name: 'Création type user_role',
        sql: `
          DO $$ 
          BEGIN
            IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
              CREATE TYPE user_role AS ENUM ('owner', 'admin', 'manager', 'employee', 'super_admin');
            END IF;
          END $$;
        `
      },
      {
        name: 'Ajout colonnes permissions',
        sql: `
          ALTER TABLE public.users 
          ADD COLUMN IF NOT EXISTS account_type account_type DEFAULT 'free',
          ADD COLUMN IF NOT EXISTS role user_role DEFAULT 'employee',
          ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP,
          ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP,
          ADD COLUMN IF NOT EXISTS max_users INTEGER DEFAULT 1,
          ADD COLUMN IF NOT EXISTS current_users INTEGER DEFAULT 1;
        `
      },
      {
        name: 'Création table features',
        sql: `
          CREATE TABLE IF NOT EXISTS features (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            name VARCHAR(100) NOT NULL UNIQUE,
            description TEXT,
            category VARCHAR(50),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          );
        `
      },
      {
        name: 'Insertion features',
        sql: `
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
        `
      },
      {
        name: 'Création table account_permissions',
        sql: `
          CREATE TABLE IF NOT EXISTS account_permissions (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            account_type account_type NOT NULL,
            feature_id UUID REFERENCES features(id) ON DELETE CASCADE,
            is_enabled BOOLEAN DEFAULT false,
            limits JSONB,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(account_type, feature_id)
          );
        `
      },
      {
        name: 'Création table account_limits',
        sql: `
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
        `
      },
      {
        name: 'Insertion limites',
        sql: `
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
        `
      },
      {
        name: 'Création vue user_permissions',
        sql: `
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
        `
      },
      {
        name: 'Mise à jour compte admin',
        sql: `
          UPDATE users 
          SET account_type = 'admin', role = 'super_admin'
          WHERE email = 'ravinesiva@gmail.com';
        `
      },
      {
        name: 'Configuration permissions admin',
        sql: `
          INSERT INTO account_permissions (account_type, feature_id, is_enabled)
          SELECT 'admin', id, true
          FROM features
          ON CONFLICT (account_type, feature_id) DO NOTHING;
        `
      },
      {
        name: 'Configuration permissions free',
        sql: `
          INSERT INTO account_permissions (account_type, feature_id, is_enabled, limits)
          SELECT 'free', id, 
            CASE name
              WHEN 'dashboard_view' THEN true
              WHEN 'profile_edit' THEN true
              WHEN 'analytics_basic' THEN true
              WHEN 'product_management' THEN true
              ELSE false
            END,
            CASE name
              WHEN 'product_management' THEN '{"max_items": 10}'::jsonb
              WHEN 'analytics_basic' THEN '{"days_history": 7}'::jsonb
              ELSE NULL
            END
          FROM features
          ON CONFLICT (account_type, feature_id) DO NOTHING;
        `
      }
    ];
    
    // Exécuter chaque migration
    for (const migration of migrations) {
      console.log(`📝 ${migration.name}...`);
      try {
        await client.query(migration.sql);
        console.log(`✅ ${migration.name} - Succès\n`);
      } catch (error) {
        if (error.message.includes('already exists') || 
            error.message.includes('duplicate')) {
          console.log(`ℹ️  ${migration.name} - Déjà existant\n`);
        } else {
          console.log(`⚠️  ${migration.name} - Erreur: ${error.message}\n`);
        }
      }
    }
    
    // Vérification finale
    console.log('🔍 Vérification finale...\n');
    
    // Vérifier les colonnes
    const columnsResult = await client.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_schema = 'public' 
      AND table_name = 'users'
      AND column_name IN ('birth_date', 'account_type', 'role');
    `);
    
    console.log('📊 Colonnes ajoutées:');
    columnsResult.rows.forEach(row => {
      console.log(`   ✅ ${row.column_name}`);
    });
    
    // Vérifier votre compte
    const accountResult = await client.query(`
      SELECT email, account_type, role, birth_date
      FROM users
      WHERE email = 'ravinesiva@gmail.com';
    `);
    
    if (accountResult.rows.length > 0) {
      console.log('\n👤 Votre compte:');
      console.log(`   Email: ${accountResult.rows[0].email}`);
      console.log(`   Type: ${accountResult.rows[0].account_type}`);
      console.log(`   Rôle: ${accountResult.rows[0].role}`);
    }
    
    console.log('\n🎉 Migration terminée avec succès!');
    
  } catch (error) {
    console.error('❌ Erreur de connexion:', error.message);
  } finally {
    await client.end();
    console.log('\n✅ Connexion fermée');
  }
}

// Exécuter la migration
runMigration();