# 🔍 Guide de diagnostic - Page blanche FidApp

## Tests à effectuer dans l'ordre :

### 1. Test minimal (Vue seul)
Dans `index.html`, remplacez ligne 11 :
```html
<script type="module" src="/src/main-minimal.ts"></script>
```

**Résultat attendu** : Message "FidApp Fonctionne! 🎉" avec fond violet

### 2. Test Router
```html
<script type="module" src="/src/main-router.ts"></script>
```

**Résultat attendu** : Navigation simple avec 2 liens

### 3. Test sans Tailwind
```html
<script type="module" src="/src/main-notailwind.ts"></script>
```

**Résultat attendu** : App sans styles Tailwind

### 4. Test normal
```html
<script type="module" src="/src/main.ts"></script>
```

## 🔧 Actions selon le résultat :

### Si Test 1 échoue (page blanche)
- Vérifiez la console pour les erreurs
- Le problème est dans Vue ou Vite
- Essayez : `rm -rf node_modules && npm install`

### Si Test 1 réussit mais Test 2 échoue
- Problème avec Vue Router
- Vérifiez les imports des composants

### Si Test 2 réussit mais Test 3 échoue
- Problème avec les styles Tailwind
- Vérifiez le fichier `src/styles/main.css`

### Si Test 3 réussit mais Test 4 échoue
- Problème dans App.vue ou les composants
- Utilisez App-debug.vue ou App-simple.vue

## 📋 Commandes utiles :

```bash
# Redémarrer le serveur
npm run dev

# Vérifier les erreurs de build
npm run build

# Nettoyer et réinstaller
rm -rf node_modules .vite
npm install
npm run dev
```

## 🔍 Vérifier dans la console du navigateur :

1. Ouvrez les DevTools (F12)
2. Onglet Console : cherchez les erreurs rouges
3. Onglet Network : vérifiez que tous les fichiers se chargent (status 200)
4. Onglet Sources : vérifiez que main.ts est bien chargé

## 💡 Solutions communes :

### Erreur "Cannot find module"
```bash
npm install
```

### Erreur Supabase
Vérifiez le fichier `.env` :
```
VITE_SUPABASE_URL=votre_url
VITE_SUPABASE_ANON_KEY=votre_clé
```

### Cache navigateur
- Ctrl+Shift+R (Windows/Linux)
- Cmd+Shift+R (Mac)
- Ou ouvrir en navigation privée