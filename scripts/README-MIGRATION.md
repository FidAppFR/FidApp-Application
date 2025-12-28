# 🚀 Migration Supabase FidApp

Ce dossier contient tous les scripts nécessaires pour exécuter la migration complète de votre base de données Supabase.

## 📋 Objectif de la Migration

Ajouter à votre base de données:
- ✅ Colonne `birth_date` (DATE) dans la table `users`
- ✅ Types enum `account_type` et `user_role`
- ✅ Colonnes `account_type` et `role` dans `users`
- ✅ Tables `features`, `account_permissions`, `account_limits`
- ✅ Système de permissions complet
- ✅ Configuration du compte `ravinesiva@gmail.com` en admin

## 📁 Fichiers Disponibles

### Scripts Automatiques
- `run-full-migration.mjs` - Tentative de migration automatique (toutes méthodes)
- `supabase-api-migration.mjs` - Migration via API Supabase
- `direct-migration.mjs` - Migration via connexion PostgreSQL directe

### Fichier SQL Manuel
- `migration-complete.sql` - **SCRIPT PRINCIPAL** à exécuter manuellement

### Scripts de Vérification
- `verify-status.mjs` - Vérifier l'état AVANT migration
- `post-migration-check.mjs` - Vérifier l'état APRÈS migration

### Migrations Existantes
- `../supabase/migrations/` - Migrations SQL existantes

## 🚀 PROCÉDURE RECOMMANDÉE

### Étape 1: Vérification Pré-Migration
```bash
node scripts/verify-status.mjs
```
Cela vous montre l'état actuel et confirme ce qui doit être migré.

### Étape 2: Tentative de Migration Automatique
```bash
node scripts/run-full-migration.mjs
```
Si cela fonctionne, passez à l'étape 4. Sinon, continuez à l'étape 3.

### Étape 3: Migration Manuelle (RECOMMANDÉE)
1. **Ouvrez votre tableau de bord Supabase:**
   ```
   https://supabase.com/dashboard/project/sdbtjaxyhkicnucktkuj/sql
   ```

2. **Copiez le contenu du fichier:**
   ```
   scripts/migration-complete.sql
   ```

3. **Collez dans l'éditeur SQL Supabase et cliquez sur "RUN"**

4. **Vérifiez que toutes les requêtes s'exécutent sans erreur**

### Étape 4: Vérification Post-Migration
```bash
node scripts/post-migration-check.mjs
```
Ce script vérifie que tout a été correctement migré.

## 🔧 Configuration

### Informations de Connexion
- **URL Supabase:** `https://sdbtjaxyhkicnucktkuj.supabase.co`
- **Service Key:** Incluse dans les scripts
- **Email Admin:** `ravinesiva@gmail.com`

### Types de Comptes Configurés
- `free` - Accès basique (10 produits, 7 jours d'analytics)
- `starter` - Accès étendu (50 produits, 30 jours d'analytics)
- `premium` - Accès presque complet (500 produits, 365 jours d'analytics, API)
- `admin` - Accès complet sans limites

### Rôles Utilisateurs
- `employee` - Employé avec accès basique
- `manager` - Manager avec permissions étendues
- `admin` - Administrateur de l'entreprise
- `owner` - Propriétaire de l'entreprise
- `super_admin` - Super administrateur système

## 🎯 Résultats Attendus

Après la migration réussie:

### Nouvelles Colonnes dans `users`
- `birth_date` (DATE)
- `account_type` (account_type enum) - Défaut: 'free'
- `role` (user_role enum) - Défaut: 'employee'
- `subscription_start_date` (TIMESTAMP)
- `subscription_end_date` (TIMESTAMP)
- `max_users` (INTEGER) - Défaut: 1
- `current_users` (INTEGER) - Défaut: 1

### Nouvelles Tables
- `features` - Liste des fonctionnalités de l'application
- `account_permissions` - Permissions par type de compte
- `account_limits` - Limites par type de compte
- `subscription_logs` - Historique des changements d'abonnement

### Vues et Fonctions
- Vue `user_permissions` - Permissions utilisateur simplifiées
- Fonction `check_user_permission(user_id, feature_name)` - Vérifier une permission
- Fonction `get_user_limits(user_id)` - Obtenir les limites d'un utilisateur

### Compte Administrateur
Votre compte `ravinesiva@gmail.com` sera configuré avec:
- `account_type` = 'admin'
- `role` = 'super_admin'
- Toutes les permissions activées

## 🚨 Résolution de Problèmes

### Erreur: "Column already exists"
C'est normal, les scripts utilisent `IF NOT EXISTS` pour éviter les doublons.

### Erreur: "Type already exists"
C'est normal, les types enum ne seront créés que s'ils n'existent pas.

### Erreur: "Permission denied"
Vérifiez que vous utilisez la Service Key dans les scripts.

### Connexion PostgreSQL échoue
Utilisez la migration manuelle via le dashboard Supabase.

## 🔍 Vérifications Manuelles

Après migration, vous pouvez exécuter ces requêtes dans Supabase:

```sql
-- Vérifier votre compte
SELECT email, account_type, role, birth_date 
FROM users 
WHERE email = 'ravinesiva@gmail.com';

-- Vérifier les nouvelles tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('features', 'account_permissions', 'account_limits');

-- Vérifier les permissions admin
SELECT f.name, ap.is_enabled 
FROM account_permissions ap
JOIN features f ON f.id = ap.feature_id
WHERE ap.account_type = 'admin';
```

## 📞 Support

Si vous rencontrez des problèmes:
1. Exécutez `verify-status.mjs` pour voir l'état actuel
2. Essayez la migration manuelle via le dashboard
3. Exécutez `post-migration-check.mjs` pour vérifier les résultats
4. Consultez les logs d'erreur dans Supabase

## 🎉 Migration Réussie!

Une fois la migration terminée avec succès:
- Votre base de données dispose d'un système de permissions complet
- Votre compte est configuré en administrateur
- Vous pouvez commencer à utiliser les nouvelles fonctionnalités dans votre application