import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://sdbtjaxyhkicnucktkuj.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkYnRqYXh5aGtpY251Y2t0a3VqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDA5OTA0NSwiZXhwIjoyMDc5Njc1MDQ1fQ.yPUPegFnSJEzBKdlKWhF4mfOYZpvImQ1Nm0A5DVz9yM'

const supabase = createClient(supabaseUrl, supabaseKey)

async function runMigration() {
  try {
    // Créer la table rewards
    const { error } = await supabase.rpc('exec_sql', {
      sql: `
        -- Création de la table des récompenses
        CREATE TABLE IF NOT EXISTS rewards (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            company_id UUID REFERENCES users(id) ON DELETE CASCADE,
            name VARCHAR(255) NOT NULL,
            description TEXT,
            points_required INTEGER NOT NULL DEFAULT 0,
            category VARCHAR(50) NOT NULL DEFAULT 'general',
            discount_percentage INTEGER,
            discount_amount DECIMAL(10,2),
            is_active BOOLEAN DEFAULT true,
            valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            valid_until TIMESTAMP WITH TIME ZONE,
            max_uses_per_customer INTEGER,
            total_uses INTEGER DEFAULT 0,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );

        -- Index pour améliorer les performances
        CREATE INDEX IF NOT EXISTS idx_rewards_company_id ON rewards(company_id);
        CREATE INDEX IF NOT EXISTS idx_rewards_is_active ON rewards(is_active);
        CREATE INDEX IF NOT EXISTS idx_rewards_category ON rewards(category);
      `
    })

    if (error) {
      console.error('Erreur lors de la création de la table:', error)
    } else {
      console.log('✅ Table rewards créée avec succès')
    }

    // Activer RLS
    const { error: rlsError } = await supabase.rpc('exec_sql', {
      sql: `
        -- RLS (Row Level Security)
        ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;

        -- Politique pour que chaque entreprise ne voie que ses récompenses
        CREATE POLICY "Companies can view their own rewards" ON rewards
            FOR SELECT USING (auth.uid()::text = (SELECT auth_id FROM users WHERE id = company_id));

        CREATE POLICY "Companies can insert their own rewards" ON rewards
            FOR INSERT WITH CHECK (auth.uid()::text = (SELECT auth_id FROM users WHERE id = company_id));

        CREATE POLICY "Companies can update their own rewards" ON rewards
            FOR UPDATE USING (auth.uid()::text = (SELECT auth_id FROM users WHERE id = company_id));

        CREATE POLICY "Companies can delete their own rewards" ON rewards
            FOR DELETE USING (auth.uid()::text = (SELECT auth_id FROM users WHERE id = company_id));
      `
    })

    if (rlsError) {
      console.error('Erreur lors de l\'activation RLS:', rlsError)
    } else {
      console.log('✅ RLS activé avec succès')
    }

  } catch (error) {
    console.error('Erreur générale:', error)
  }
}

// Exécuter la migration
runMigration()