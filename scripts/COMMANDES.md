# 🚀 COMMANDES MIGRATION SUPABASE

## Commandes d'exécution rapide

```bash
# 1. Vérifier l'état actuel
node scripts/verify-status.mjs

# 2. Résumé complet de la migration
node scripts/migration-summary.mjs

# 3. Tentative de migration automatique (peut échouer)
node scripts/run-full-migration.mjs

# 4. Vérification après migration
node scripts/post-migration-check.mjs
```

## 🎯 MIGRATION MANUELLE (RECOMMANDÉE)

1. **Ouvrir le dashboard Supabase :**
   ```
   https://supabase.com/dashboard/project/sdbtjaxyhkicnucktkuj/sql
   ```

2. **Copier le contenu du fichier :**
   ```
   scripts/migration-complete.sql
   ```

3. **Coller dans l'éditeur SQL et cliquer "RUN"**

## 📁 Structure des fichiers créés

```
scripts/
├── migration-complete.sql ........... 📄 FICHIER SQL PRINCIPAL
├── README-MIGRATION.md .............. 📚 Documentation complète  
├── COMMANDES.md ..................... 📋 Ce fichier
├── verify-status.mjs ................ 🔍 Vérification pré-migration
├── post-migration-check.mjs ......... ✅ Vérification post-migration
├── migration-summary.mjs ............ 📊 Résumé complet
├── run-full-migration.mjs ........... 🤖 Tentative automatique
├── supabase-api-migration.mjs ....... 🔧 Via API Supabase
├── direct-migration.mjs ............. 🔌 Via PostgreSQL direct
└── execute-supabase-migration.mjs ... 📋 Instructions manuelles
```

## ⚡ Commande tout-en-un

```bash
# Vérifier + Résumé + Tentative auto + Vérification finale
node scripts/verify-status.mjs && echo -e "\n---\n" && node scripts/migration-summary.mjs && echo -e "\n---\n" && node scripts/run-full-migration.mjs && echo -e "\n---\n" && node scripts/post-migration-check.mjs
```