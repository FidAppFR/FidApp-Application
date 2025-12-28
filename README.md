# FidApp - Système de Fidélisation Digital

## 🎯 Description

FidApp est une application web moderne de gestion de cartes de fidélité digitales, permettant aux entreprises de créer et gérer leur programme de fidélisation facilement.

## ✨ Fonctionnalités

### Pour les Entreprises
- 🎨 Création de cartes de fidélité personnalisées
- 📊 Tableau de bord complet avec statistiques
- 🎁 Gestion des récompenses et promotions
- 👥 Gestion de la base clients
- 📱 QR Code unique pour chaque entreprise
- 💳 Support Apple Wallet (en développement)

### Pour les Clients
- 📱 Carte de fidélité digitale
- ⭐ Accumulation et suivi des points
- 🎁 Catalogue de récompenses
- 📜 Historique des transactions
- 🔐 Connexion sécurisée par OTP

## 🚀 Technologies

- **Frontend**: Vue 3 + TypeScript
- **Styling**: Tailwind CSS
- **Base de données**: Supabase (PostgreSQL)
- **Authentification**: Supabase Auth
- **Icons**: Lucide Vue
- **Build Tool**: Vite
- **QR Code**: qrcode library

## 📦 Installation

### Prérequis
- Node.js 18+ 
- npm ou yarn
- Compte Supabase

### Étapes

1. Cloner le repository
```bash
git clone https://github.com/yourusername/fidapp.git
cd fidapp/FidApp-Dev
```

2. Installer les dépendances
```bash
npm install
```

3. Configurer les variables d'environnement
```bash
cp .env.example .env
# Éditer .env avec vos clés Supabase
```

4. Configurer Supabase
```bash
# Exécuter les migrations dans l'ordre
supabase db push supabase/migrations/*.sql
```

5. Lancer en développement
```bash
npm run dev
```

## 🛠 Scripts disponibles

```bash
npm run dev        # Lancer le serveur de développement
npm run build      # Construire pour la production
npm run preview    # Prévisualiser la build
npm run lint       # Linter le code
npm run type-check # Vérifier les types TypeScript
```

## 📁 Structure du projet

```
FidApp-Dev/
├── src/
│   ├── components/     # Composants Vue réutilisables
│   │   ├── dashboard/  # Composants du tableau de bord
│   │   ├── ui/         # Composants UI de base
│   │   └── layout/     # Composants de mise en page
│   ├── views/          # Pages de l'application
│   ├── services/       # Services (Supabase, auth, etc.)
│   ├── stores/         # Stores Pinia
│   ├── router/         # Configuration Vue Router
│   └── api/           # Endpoints API
├── supabase/
│   └── migrations/     # Migrations SQL
├── public/            # Assets publics
└── scripts/           # Scripts utilitaires
```

## 🔒 Sécurité

- Authentification sécurisée avec Supabase Auth
- OTP pour la connexion des clients
- Row Level Security (RLS) sur toutes les tables
- Sessions sécurisées avec JWT
- Validation des données côté serveur

## 📱 Fonctionnalités à venir

- [ ] Application mobile native
- [ ] Intégration complète Apple Wallet
- [ ] Google Wallet support
- [ ] Notifications push
- [ ] Programme de parrainage
- [ ] Analytics avancées
- [ ] Multi-établissements
- [ ] Export de données
- [ ] API publique

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Contact

Pour toute question : contact@fidapp.fr

## 🙏 Remerciements

- Vue.js Team
- Supabase Team  
- Tailwind CSS
- Tous les contributeurs