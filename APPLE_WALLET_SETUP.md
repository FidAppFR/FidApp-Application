# 🎫 Guide d'intégration Apple Wallet pour FidApp

## 📋 Vue d'ensemble

Cette intégration permet à vos clients d'ajouter leur carte de fidélité directement dans Apple Wallet, avec :
- ✅ Mise à jour automatique des points
- ✅ QR Code intégré pour les scans en magasin
- ✅ Notifications push lors des changements de points
- ✅ Design personnalisé avec votre logo et couleurs

## 💰 Coûts

- **Apple Developer Account** : 99€/an (obligatoire)
- **Hébergement HTTPS** : Déjà inclus si vous utilisez Vercel, Netlify ou similaire
- **Pas de coûts par transaction ou par carte générée**

## 🚀 Étapes de configuration

### Étape 1 : Créer un compte Apple Developer

1. Allez sur [developer.apple.com](https://developer.apple.com)
2. Créez un compte ou connectez-vous
3. Souscrivez au programme Apple Developer (99€/an)
4. Attendez l'activation (généralement 24-48h)

### Étape 2 : Créer un Pass Type ID

1. Connectez-vous à [developer.apple.com/account](https://developer.apple.com/account)
2. Allez dans "Certificates, Identifiers & Profiles"
3. Cliquez sur "Identifiers" puis "+"
4. Sélectionnez "Pass Type IDs"
5. Entrez :
   - Description : "FidApp Loyalty Card"
   - Identifier : `pass.com.fidapp.loyalty` (remplacez par votre domaine)
6. Cliquez sur "Continue" puis "Register"

### Étape 3 : Créer le certificat Pass Type

1. Dans "Certificates", cliquez sur "+"
2. Sélectionnez "Pass Type ID Certificate"
3. Choisissez votre Pass Type ID créé précédemment
4. Suivez les instructions pour créer une Certificate Signing Request (CSR) :
   ```bash
   # Sur Mac, ouvrez Keychain Access
   # Menu > Certificate Assistant > Request a Certificate from a Certificate Authority
   # Entrez votre email et nom
   # Sauvegardez sur le disque
   ```
5. Uploadez le CSR
6. Téléchargez le certificat généré

### Étape 4 : Télécharger le certificat WWDR

1. Téléchargez le certificat WWDR (Apple Worldwide Developer Relations) :
   ```bash
   curl -O https://www.apple.com/certificateauthority/AppleWWDRCAG4.cer
   ```

### Étape 5 : Exporter les certificats

```bash
# Convertir le certificat WWDR en PEM
openssl x509 -inform DER -in AppleWWDRCAG4.cer -out wwdr.pem

# Importer votre certificat Pass Type dans Keychain (double-cliquez dessus)
# Puis exportez-le en P12 depuis Keychain Access

# Convertir le P12 en PEM
openssl pkcs12 -in pass-certificate.p12 -out pass-certificate.pem -nodes

# Séparer le certificat et la clé
openssl pkcs12 -in pass-certificate.p12 -clcerts -nokeys -out signer-cert.pem
openssl pkcs12 -in pass-certificate.p12 -nocerts -out signer-key.pem

# Encoder en Base64 pour les variables d'environnement
base64 -i wwdr.pem -o wwdr-base64.txt
base64 -i signer-cert.pem -o signer-cert-base64.txt
base64 -i signer-key.pem -o signer-key-base64.txt
```

### Étape 6 : Configurer les variables d'environnement

Créez un fichier `.env` dans le dossier FidApp-Dev :

```env
# Supabase (déjà configuré)
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key

# Apple Wallet
VITE_APPLE_TEAM_ID=YOUR_TEAM_ID  # Trouvé dans votre compte Apple Developer
VITE_APPLE_PASS_TYPE_ID=pass.com.fidapp.loyalty  # Créé à l'étape 2
VITE_APPLE_KEY_PASSPHRASE=your_passphrase  # Si vous avez mis un mot de passe

# Copiez le contenu des fichiers base64 ici
VITE_APPLE_WWDR_CERT=<contenu de wwdr-base64.txt>
VITE_APPLE_SIGNER_CERT=<contenu de signer-cert-base64.txt>
VITE_APPLE_SIGNER_KEY=<contenu de signer-key-base64.txt>
```

### Étape 7 : Exécuter les migrations de base de données

```bash
cd FidApp-Dev

# Exécuter la migration pour créer les tables Apple Wallet
npx supabase db push supabase/migrations/012_create_apple_wallet_tables.sql
```

### Étape 8 : Déployer l'application

```bash
# Builder l'application
npm run build

# Déployer sur votre hébergeur (Vercel, Netlify, etc.)
# Assurez-vous que toutes les variables d'environnement sont configurées
```

### Étape 9 : Configurer le endpoint Web Service (optionnel mais recommandé)

Pour les mises à jour push automatiques, créez un endpoint API :

```javascript
// api/wallet/[...path].js (pour Vercel)
import { handleWebServiceRequest } from '@/api/walletEndpoint'

export default async function handler(req, res) {
  const { path } = req.query
  const result = await handleWebServiceRequest(
    req.method,
    path.join('/'),
    req.body,
    req.headers
  )
  
  res.status(result.status).json(result.body || {})
}
```

## 🧪 Test de l'intégration

1. **Sur iPhone/iPad** :
   - Connectez-vous en tant que client
   - Cliquez sur "Ajouter à Apple Wallet"
   - Le fichier .pkpass sera téléchargé
   - Ouvrez-le pour l'ajouter à Wallet

2. **Sur Mac** :
   - Le bouton apparaîtra aussi sur Mac avec macOS Big Sur ou plus récent
   - La carte sera ajoutée à Wallet sur Mac

3. **Autres appareils** :
   - Un QR code de secours sera proposé

## 🔍 Vérification

Pour vérifier que tout fonctionne :

1. La carte apparaît dans Apple Wallet ✓
2. Le QR code est scannable ✓
3. Les points sont affichés correctement ✓
4. Le design correspond à vos couleurs ✓

## 🚨 Dépannage

### Erreur "Certificate not found"
- Vérifiez que les certificats sont correctement encodés en Base64
- Assurez-vous qu'il n'y a pas d'espaces ou retours à la ligne supplémentaires

### Erreur "Invalid pass"
- Vérifiez que le Pass Type ID correspond exactement
- Assurez-vous que le Team ID est correct

### La carte ne s'ouvre pas
- Vérifiez que vous êtes sur un appareil Apple compatible
- Assurez-vous que le fichier est bien téléchargé avec l'extension .pkpass

## 📱 Fonctionnalités futures

Une fois configuré, vous pourrez :
- Envoyer des notifications push quand les points changent
- Mettre à jour la carte automatiquement
- Ajouter des géolocalisations pour afficher la carte près de vos magasins
- Personnaliser complètement le design

## 🆘 Support

Pour toute question :
- Documentation Apple : [developer.apple.com/wallet](https://developer.apple.com/wallet)
- Support FidApp : contact@fidapp.fr

## ✅ Checklist de déploiement

- [ ] Compte Apple Developer actif
- [ ] Pass Type ID créé
- [ ] Certificats générés et exportés
- [ ] Variables d'environnement configurées
- [ ] Migration de base de données exécutée
- [ ] Application déployée avec HTTPS
- [ ] Test sur un vrai appareil Apple
- [ ] QR code de secours fonctionnel