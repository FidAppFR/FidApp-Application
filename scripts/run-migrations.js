import { createClient } from '@supabase/supabase-js';
import pkg from 'pg';
const { Client } = pkg;

const SUPABASE_URL = 'https://sdbtjaxyhkicnucktkuj.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM';

async function executeMigrationsDirectly() {
  console.log('\n🔧 Connexion directe à PostgreSQL...\n');
  
  // Connection directe sans pooler
  const connectionString = 'postgresql://postgres.sdbtjaxyhkicnucktkuj:QuoJPgmP3jQQy5Xr@aws-0-eu-central-1.pooler.supabase.com:5432/postgres';
  
  const client = new Client({
    connectionString: connectionString
  });
  
  try {
    await client.connect();
    console.log('✅ Connecté à PostgreSQL !');
    
    // Migration 1: birth_date
    console.log('\n📝 Exécution: Ajout de birth_date...');
    try {
      await client.query(`
        ALTER TABLE public.users 
        ADD COLUMN IF NOT EXISTS birth_date DATE;
      `);
      console.log('✅ Colonne birth_date ajoutée !');
    } catch (error) {
      if (error.message.includes('already exists')) {
        console.log('ℹ️ Colonne birth_date existe déjà');
      } else {
        console.log('⚠️ Erreur birth_date:', error.message);
      }
    }
    
    // Migration 2: Types enum
    console.log('\n📝 Création des types enum...');
    try {
      // Créer le type account_type
      await client.query(`
        DO $$ 
        BEGIN
          IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'account_type') THEN
            CREATE TYPE account_type AS ENUM ('free', 'starter', 'premium', 'admin');
          END IF;
        END $$;
      `);
      console.log('✅ Type account_type créé');
      
      // Créer le type user_role
      await client.query(`
        DO $$ 
        BEGIN
          IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
            CREATE TYPE user_role AS ENUM ('owner', 'admin', 'manager', 'employee', 'super_admin');
          END IF;
        END $$;
      `);
      console.log('✅ Type user_role créé');
      
    } catch (error) {
      console.log('⚠️ Erreur types:', error.message);
    }
    
    // Migration 3: Ajouter les colonnes
    console.log('\n📝 Ajout des colonnes de permissions...');
    try {
      await client.query(`
        ALTER TABLE public.users 
        ADD COLUMN IF NOT EXISTS account_type account_type DEFAULT 'free',
        ADD COLUMN IF NOT EXISTS role user_role DEFAULT 'employee',
        ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP,
        ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP,
        ADD COLUMN IF NOT EXISTS max_users INTEGER DEFAULT 1,
        ADD COLUMN IF NOT EXISTS current_users INTEGER DEFAULT 1;
      `);
      console.log('✅ Colonnes de permissions ajoutées');
    } catch (error) {
      console.log('⚠️ Erreur colonnes:', error.message);
    }
    
    // Migration 4: Créer les tables features
    console.log('\n📝 Création de la table features...');
    try {
      await client.query(`
        CREATE TABLE IF NOT EXISTS features (
          id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
          name VARCHAR(100) NOT NULL UNIQUE,
          description TEXT,
          category VARCHAR(50),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `);
      console.log('✅ Table features créée');
      
      // Insérer les features
      await client.query(`
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
      `);
      console.log('✅ Features insérées');
    } catch (error) {
      console.log('⚠️ Erreur features:', error.message);
    }
    
    // Migration 5: Créer la table account_permissions
    console.log('\n📝 Création de la table account_permissions...');
    try {
      await client.query(`
        CREATE TABLE IF NOT EXISTS account_permissions (
          id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
          account_type account_type NOT NULL,
          feature_id UUID REFERENCES features(id) ON DELETE CASCADE,
          is_enabled BOOLEAN DEFAULT false,
          limits JSONB,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(account_type, feature_id)
        );
      `);
      console.log('✅ Table account_permissions créée');
    } catch (error) {
      console.log('⚠️ Erreur account_permissions:', error.message);
    }
    
    // Migration 6: Créer la table account_limits
    console.log('\n📝 Création de la table account_limits...');
    try {
      await client.query(`
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
      `);
      console.log('✅ Table account_limits créée');
      
      // Insérer les limites
      await client.query(`
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
      `);
      console.log('✅ Limites insérées');
    } catch (error) {
      console.log('⚠️ Erreur account_limits:', error.message);
    }
    
    // Migration 7: Créer la vue user_permissions
    console.log('\n📝 Création de la vue user_permissions...');
    try {
      await client.query(`
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
      `);
      console.log('✅ Vue user_permissions créée');
    } catch (error) {
      console.log('⚠️ Erreur vue:', error.message);
    }
    
    // Migration 8: Mettre à jour votre compte en admin
    console.log('\n📝 Configuration de votre compte en admin...');
    try {
      await client.query(`
        UPDATE users 
        SET account_type = 'admin', role = 'super_admin'
        WHERE email = 'ravinesiva@gmail.com';
      `);
      console.log('✅ Votre compte est maintenant admin !');
    } catch (error) {
      console.log('⚠️ Erreur mise à jour admin:', error.message);
    }
    
    // Migration 9: Configurer les permissions
    console.log('\n📝 Configuration des permissions...');
    try {
      // Permissions FREE
      await client.query(`
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
      `);
      
      // Permissions ADMIN (tout activé)
      await client.query(`
        INSERT INTO account_permissions (account_type, feature_id, is_enabled, limits)
        SELECT 'admin', id, true, NULL
        FROM features
        ON CONFLICT (account_type, feature_id) DO NOTHING;
      `);
      console.log('✅ Permissions configurées');
    } catch (error) {
      console.log('⚠️ Erreur permissions:', error.message);
    }
    
    // Vérification finale
    console.log('\n🔍 Vérification finale...');
    const result = await client.query(`
      SELECT email, account_type, role, birth_date
      FROM users
      WHERE email = 'ravinesiva@gmail.com'
    `);
    
    if (result.rows.length > 0) {
      console.log('✅ Votre compte:');
      console.log('   Email:', result.rows[0].email);
      console.log('   Type:', result.rows[0].account_type);
      console.log('   Rôle:', result.rows[0].role);
      console.log('   Date de naissance:', result.rows[0].birth_date || 'non définie');
    }
    
    // Afficher les colonnes de la table users
    const columnsResult = await client.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_schema = 'public' 
      AND table_name = 'users'
      ORDER BY ordinal_position;
    `);
    
    console.log('\n📊 Colonnes de la table users:');
    columnsResult.rows.forEach(col => {
      const check = ['birth_date', 'account_type', 'role'].includes(col.column_name) ? '✅' : '  ';
      console.log(`${check} ${col.column_name} (${col.data_type})`);
    });
    
  } catch (error) {
    console.error('❌ Erreur de connexion:', error.message);
  } finally {
    await client.end();
    console.log('\n✅ Connexion fermée');
  }
}

// Exécuter
(async () => {
  await executeMigrationsDirectly();
  console.log('\n🎉 Migration terminée !');
  console.log('Vous pouvez maintenant tester votre application.');
})();