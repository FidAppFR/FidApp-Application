# 📦 Configuration GitHub pour FidApp

## ⚠️ Prérequis Important

Avant de pouvoir utiliser Git sur votre Mac, vous devez accepter la licence Xcode :

```bash
sudo xcodebuild -license
```

Suivez les instructions à l'écran pour accepter la licence.

## 🚀 Étapes pour mettre votre projet sur GitHub

### 1. Initialiser Git localement

```bash
# Se placer dans le dossier du projet
cd /Users/ravine/Documents/FidApp/Application/FidApp-Dev

# Initialiser Git
git init

# Configurer votre identité Git (remplacez par vos informations)
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"
```

### 2. Préparer le premier commit

```bash
# Ajouter tous les fichiers
git add .

# Créer le premier commit
git commit -m "Initial commit: FidApp - Système de fidélisation digital"
```

### 3. Créer un repository sur GitHub

1. Allez sur [github.com](https://github.com)
2. Connectez-vous à votre compte
3. Cliquez sur le bouton "+" en haut à droite
4. Sélectionnez "New repository"
5. Configurez :
   - Repository name: `fidapp`
   - Description: "Système de fidélisation digital avec cartes de fidélité numériques"
   - Visibilité: Public ou Private selon votre choix
   - ⚠️ NE PAS initialiser avec README, .gitignore ou License (déjà présents)
6. Cliquez sur "Create repository"

### 4. Connecter votre repository local à GitHub

GitHub vous donnera des commandes. Utilisez celles pour "push an existing repository" :

```bash
# Ajouter l'origine distante (remplacez USERNAME par votre nom d'utilisateur GitHub)
git remote add origin https://github.com/USERNAME/fidapp.git

# Renommer la branche principale en main
git branch -M main

# Pousser le code vers GitHub
git push -u origin main
```

### 5. Vérifier les fichiers sensibles

Avant de pousser, assurez-vous que :
- ✅ Le fichier `.env` n'est PAS inclus (vérifié dans .gitignore)
- ✅ Les certificats Apple Wallet ne sont PAS inclus
- ✅ Aucun mot de passe ou clé API n'est dans le code

Vérifiez avec :
```bash
git status
```

### 6. Pour les futurs commits

```bash
# Voir les changements
git status

# Ajouter des fichiers spécifiques
git add src/components/NewComponent.vue

# Ou ajouter tous les changements
git add .

# Créer un commit avec un message descriptif
git commit -m "feat: ajouter nouvelle fonctionnalité X"

# Pousser vers GitHub
git push
```

## 📝 Bonnes pratiques pour les commits

Utilisez des préfixes conventionnels :
- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Documentation
- `style:` Formatage, style (pas de changement de code)
- `refactor:` Refactoring du code
- `test:` Ajout de tests
- `chore:` Maintenance, configuration

Exemples :
```bash
git commit -m "feat: ajouter système de notifications"
git commit -m "fix: corriger calcul des points"
git commit -m "docs: mettre à jour README avec nouvelles instructions"
```

## 🔐 Sécurité

### Variables d'environnement

Ne JAMAIS commiter le fichier `.env`. Pour partager la configuration :

1. Le fichier `.env.example` est inclus avec des valeurs d'exemple
2. Documentez les variables nécessaires dans le README
3. Utilisez les GitHub Secrets pour les déploiements automatiques

### Protéger la branche main

Sur GitHub, allez dans Settings > Branches et configurez :
- Require pull request reviews
- Dismiss stale pull request approvals
- Require status checks to pass

## 🤝 Collaboration

### Inviter des collaborateurs

1. Sur GitHub, allez dans Settings > Manage access
2. Cliquez sur "Invite a collaborator"
3. Entrez le nom d'utilisateur ou email

### Workflow recommandé

1. Créer une branche pour chaque fonctionnalité
```bash
git checkout -b feature/nom-fonctionnalite
```

2. Faire les changements et commits

3. Pousser la branche
```bash
git push -u origin feature/nom-fonctionnalite
```

4. Créer une Pull Request sur GitHub

5. Review et merge

## 🚨 Dépannage

### Erreur "remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/USERNAME/fidapp.git
```

### Erreur d'authentification
GitHub demande maintenant un Personal Access Token au lieu du mot de passe :
1. Allez dans GitHub Settings > Developer settings > Personal access tokens
2. Générez un nouveau token avec les permissions "repo"
3. Utilisez ce token comme mot de passe

### Réinitialiser si nécessaire
```bash
# Supprimer le dossier .git (attention, perd l'historique)
rm -rf .git
# Recommencer depuis l'étape 1
```

## ✅ Checklist finale

- [ ] Licence Xcode acceptée
- [ ] Git initialisé
- [ ] .env exclu du repository
- [ ] Premier commit créé
- [ ] Repository GitHub créé
- [ ] Code poussé sur GitHub
- [ ] README visible sur GitHub
- [ ] Aucune information sensible exposée