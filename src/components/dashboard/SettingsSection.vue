<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-3xl font-black text-gray-900 dark:text-white">Paramètres</h1>
      <p class="text-gray-600 dark:text-gray-400 mt-2">Configurez votre compte et vos préférences</p>
    </div>

    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700">
      <!-- Tabs -->
      <div class="border-b border-gray-200 dark:border-gray-700">
        <nav class="flex space-x-8 px-6" aria-label="Tabs">
          <button
            v-for="tab in tabs"
            :key="tab.id"
            @click="activeTab = tab.id"
            :class="[
              'py-4 px-1 border-b-2 font-medium text-sm transition-colors',
              activeTab === tab.id
                ? 'border-violet-600 text-violet-600'
                : 'border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:text-gray-300 hover:border-gray-300'
            ]"
          >
            {{ tab.name }}
          </button>
        </nav>
      </div>

      <!-- Tab content -->
      <div class="p-6">
        <!-- Programme de fidélité -->
        <div v-if="activeTab === 'loyalty'" class="space-y-6">
          <div>
            <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Configuration du programme de fidélité</h3>
            
            <!-- Points de bienvenue -->
            <div class="p-6 bg-gradient-to-br from-violet-50 to-pink-50 dark:from-gray-700 dark:to-gray-800 rounded-xl mb-6">
              <div class="flex items-start space-x-4">
                <div class="w-12 h-12 bg-white dark:bg-gray-800 rounded-full flex items-center justify-center shadow-sm">
                  <Gift :size="24" class="text-violet-600" />
                </div>
                <div class="flex-1">
                  <h4 class="font-bold text-gray-900 dark:text-white mb-2">Points de bienvenue</h4>
                  <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
                    Points attribués automatiquement lors de l'inscription d'un nouveau client via QR code
                  </p>
                  <div class="flex items-center space-x-3">
                    <input
                      v-model.number="signupPoints"
                      type="number"
                      min="0"
                      max="1000"
                      class="w-32 px-4 py-2 border-2 border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                      placeholder="50"
                    />
                    <span class="text-gray-600 dark:text-gray-400 font-medium">points</span>
                    <button
                      @click="saveSignupPoints"
                      :disabled="savingPoints || signupPoints === originalSignupPoints"
                      class="px-4 py-2 bg-violet-600 text-white font-medium rounded-lg hover:bg-violet-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {{ savingPoints ? 'Enregistrement...' : 'Enregistrer' }}
                    </button>
                  </div>
                  <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">
                    Recommandé : entre 10 et 100 points pour encourager l'inscription
                  </p>
                </div>
              </div>
            </div>
            
            <!-- Autres paramètres -->
            <div class="space-y-4">
              <div class="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg">
                <div class="flex items-center justify-between">
                  <div>
                    <p class="font-medium text-gray-900 dark:text-white">Multiplicateur de points</p>
                    <p class="text-sm text-gray-500 dark:text-gray-400">Doublez les points lors d'événements spéciaux</p>
                  </div>
                  <span class="text-sm text-gray-400">Bientôt disponible</span>
                </div>
              </div>
              <div class="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg">
                <div class="flex items-center justify-between">
                  <div>
                    <p class="font-medium text-gray-900 dark:text-white">Expiration des points</p>
                    <p class="text-sm text-gray-500 dark:text-gray-400">Définissez une durée de validité pour les points</p>
                  </div>
                  <span class="text-sm text-gray-400">Bientôt disponible</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Général -->
        <div v-if="activeTab === 'general'" class="space-y-6">
          <div>
            <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Préférences générales</h3>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Langue</label>
                <select class="w-full md:w-64 px-4 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400">
                  <option>Français</option>
                  <option>English</option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Fuseau horaire</label>
                <select class="w-full md:w-64 px-4 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400">
                  <option>Paris (GMT+1)</option>
                  <option>Londres (GMT)</option>
                </select>
              </div>
            </div>
          </div>
        </div>

        <!-- Notifications -->
        <div v-if="activeTab === 'notifications'" class="space-y-6">
          <div>
            <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Préférences de notification</h3>
            <div class="space-y-4">
              <label class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-900 rounded-lg">
                <div>
                  <p class="font-medium text-gray-900 dark:text-white">Nouveaux clients</p>
                  <p class="text-sm text-gray-500 dark:text-gray-400">Recevez une notification quand un nouveau client s'inscrit</p>
                </div>
                <input type="checkbox" checked class="w-5 h-5 text-violet-600 rounded" />
              </label>
              <label class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-900 rounded-lg">
                <div>
                  <p class="font-medium text-gray-900 dark:text-white">Récompenses échangées</p>
                  <p class="text-sm text-gray-500 dark:text-gray-400">Notification quand un client échange une récompense</p>
                </div>
                <input type="checkbox" checked class="w-5 h-5 text-violet-600 rounded" />
              </label>
              <label class="flex items-center justify-between p-4 bg-gray-50 dark:bg-gray-900 rounded-lg">
                <div>
                  <p class="font-medium text-gray-900 dark:text-white">Rapports hebdomadaires</p>
                  <p class="text-sm text-gray-500 dark:text-gray-400">Recevez un résumé de vos performances chaque semaine</p>
                </div>
                <input type="checkbox" class="w-5 h-5 text-violet-600 rounded" />
              </label>
            </div>
          </div>
        </div>

        <!-- Facturation -->
        <div v-if="activeTab === 'billing'" class="space-y-6">
          <div>
            <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Historique de facturation</h3>
            
            <!-- Statistiques de facturation -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
              <div class="bg-gradient-to-br from-violet-50 to-purple-50 dark:from-gray-700 dark:to-gray-800 rounded-xl p-4">
                <div class="flex items-center justify-between">
                  <div>
                    <p class="text-xs text-gray-600 dark:text-gray-400 mb-1">Total dépensé</p>
                    <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ totalSpent }}€</p>
                  </div>
                  <Euro :size="24" class="text-violet-600" />
                </div>
              </div>
              <div class="bg-gradient-to-br from-pink-50 to-rose-50 dark:from-gray-700 dark:to-gray-800 rounded-xl p-4">
                <div class="flex items-center justify-between">
                  <div>
                    <p class="text-xs text-gray-600 dark:text-gray-400 mb-1">Mois payés</p>
                    <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ billingHistory.length }}</p>
                  </div>
                  <Calendar :size="24" class="text-pink-600" />
                </div>
              </div>
              <div class="bg-gradient-to-br from-green-50 to-emerald-50 dark:from-gray-700 dark:to-gray-800 rounded-xl p-4">
                <div class="flex items-center justify-between">
                  <div>
                    <p class="text-xs text-gray-600 dark:text-gray-400 mb-1">Plan actuel</p>
                    <p class="text-lg font-bold text-gray-900 dark:text-white">{{ currentUserPlan }}</p>
                  </div>
                  <CreditCard :size="24" class="text-green-600" />
                </div>
              </div>
            </div>

            <!-- Liste des factures -->
            <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700">
              <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
                <h4 class="font-semibold text-gray-900 dark:text-white">Historique des factures</h4>
              </div>
              <div class="divide-y divide-gray-100 dark:divide-gray-700">
                <!-- Si pas de factures -->
                <div v-if="billingHistory.length === 0" class="p-8 text-center">
                  <FileText :size="48" class="mx-auto text-gray-300 dark:text-gray-600 mb-3" />
                  <p class="text-gray-500 dark:text-gray-400">Aucune facture disponible</p>
                  <p class="text-sm text-gray-400 dark:text-gray-500 mt-1">Vos factures apparaîtront ici après votre premier paiement</p>
                </div>
                
                <!-- Liste des factures -->
                <div v-else v-for="invoice in billingHistory" :key="invoice.id" 
                     class="px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                  <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-4">
                      <div class="w-10 h-10 bg-violet-100 dark:bg-violet-900/30 rounded-full flex items-center justify-center">
                        <FileText :size="20" class="text-violet-600 dark:text-violet-400" />
                      </div>
                      <div>
                        <p class="font-medium text-gray-900 dark:text-white">
                          Facture #{{ invoice.number }}
                        </p>
                        <p class="text-sm text-gray-500 dark:text-gray-400">
                          {{ formatDate(invoice.date) }} • Plan {{ invoice.plan }}
                        </p>
                      </div>
                    </div>
                    <div class="flex items-center space-x-3">
                      <span class="font-bold text-gray-900 dark:text-white">{{ invoice.amount }}€</span>
                      <span :class="[
                        'px-2 py-1 text-xs rounded-full font-medium',
                        invoice.status === 'paid' 
                          ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400' 
                          : 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400'
                      ]">
                        {{ invoice.status === 'paid' ? 'Payée' : 'En attente' }}
                      </span>
                      <button
                        @click="downloadInvoice(invoice)"
                        class="px-3 py-1.5 bg-violet-600 hover:bg-violet-700 text-white text-sm rounded-lg font-medium transition-colors flex items-center space-x-1"
                      >
                        <Download :size="14" />
                        <span>PDF</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Information de facturation -->
            <div class="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-700 rounded-lg">
              <div class="flex items-start space-x-3">
                <svg class="w-5 h-5 text-blue-600 dark:text-blue-400 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
                </svg>
                <div class="flex-1">
                  <p class="text-sm text-blue-800 dark:text-blue-300 font-medium">Information importante</p>
                  <p class="text-sm text-blue-700 dark:text-blue-400 mt-1">
                    Les factures sont générées automatiquement chaque mois et envoyées à votre adresse email. 
                    Vous pouvez télécharger vos factures au format PDF pour votre comptabilité.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Sécurité -->
        <div v-if="activeTab === 'security'" class="space-y-6">
          <div>
            <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Sécurité du compte</h3>
            <div class="space-y-4">
              <button class="px-4 py-2 bg-violet-100 text-violet-600 rounded-lg font-medium hover:bg-violet-200 transition-colors">
                Changer le mot de passe
              </button>
              <div class="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg">
                <p class="text-sm text-gray-600 dark:text-gray-400">Authentification à deux facteurs</p>
                <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">Protégez votre compte avec une couche de sécurité supplémentaire</p>
                <button class="mt-3 text-sm text-violet-600 font-medium">Activer 2FA →</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Intégrations -->
        <div v-if="activeTab === 'integrations'" class="space-y-6">
          <div>
            <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Intégrations disponibles</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="p-4 border border-gray-200 dark:border-gray-700 rounded-lg">
                <div class="flex items-center justify-between mb-2">
                  <h4 class="font-medium">Google Analytics</h4>
                  <span class="px-2 py-1 bg-green-100 text-green-700 text-xs rounded-full">Connecté</span>
                </div>
                <p class="text-sm text-gray-500 dark:text-gray-400">Suivez vos performances de fidélité</p>
              </div>
              <div class="p-4 border border-gray-200 dark:border-gray-700 rounded-lg">
                <div class="flex items-center justify-between mb-2">
                  <h4 class="font-medium">Mailchimp</h4>
                  <button class="text-sm text-violet-600 font-medium">Connecter</button>
                </div>
                <p class="text-sm text-gray-500 dark:text-gray-400">Synchronisez vos contacts</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Message de succès -->
    <Teleport to="body">
      <Transition
        enter-active-class="duration-200 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="duration-150 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showSuccess" class="fixed bottom-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg flex items-center space-x-2 z-50">
          <CheckCircle :size="20" />
          <span>{{ successMessage }}</span>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { Gift, Loader2, CheckCircle, FileText, Download, CreditCard, Calendar, Euro } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'
import jsPDF from 'jspdf'
import { getFidAppLogoBase64 } from '@/utils/pdfLogo'

const activeTab = ref('loyalty')
const signupPoints = ref(50)
const originalSignupPoints = ref(50)
const savingPoints = ref(false)
const showSuccess = ref(false)
const successMessage = ref('')
const currentUserPlan = ref('Free')
const billingHistory = ref<any[]>([])
const loadingInvoices = ref(false)

// Calculer le total dépensé
const totalSpent = computed(() => {
  return billingHistory.value.reduce((sum, invoice) => {
    return sum + (invoice.status === 'paid' ? invoice.amount : 0)
  }, 0)
})

const tabs = [
  { id: 'loyalty', name: 'Programme de fidélité' },
  { id: 'general', name: 'Général' },
  { id: 'notifications', name: 'Notifications' },
  { id: 'billing', name: 'Facturation' },
  { id: 'security', name: 'Sécurité' },
  { id: 'integrations', name: 'Intégrations' }
]

// Charger les paramètres actuels
const loadSettings = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data } = await supabase
      .from('users')
      .select('signup_points, selected_plan')
      .eq('auth_id', user.id)
      .single()

    if (data) {
      signupPoints.value = data.signup_points || 50
      originalSignupPoints.value = data.signup_points || 50
      currentUserPlan.value = data.selected_plan || 'Free'
    }
  } catch (error) {
    console.error('Erreur lors du chargement des paramètres:', error)
  }
}

// Charger l'historique de facturation
const loadBillingHistory = async () => {
  loadingInvoices.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    // Pour l'instant, on simule des données de facturation
    // Dans un cas réel, on chargerait depuis une table 'invoices'
    billingHistory.value = [
      {
        id: 1,
        number: 'INV-2024-001',
        date: new Date('2024-01-15'),
        plan: 'Starter',
        amount: 49,
        status: 'paid'
      },
      {
        id: 2,
        number: 'INV-2024-002',
        date: new Date('2024-02-15'),
        plan: 'Starter',
        amount: 49,
        status: 'paid'
      },
      {
        id: 3,
        number: 'INV-2024-003',
        date: new Date('2024-03-15'),
        plan: 'Premium',
        amount: 99,
        status: 'paid'
      }
    ]
  } catch (error) {
    console.error('Erreur lors du chargement de l\'historique:', error)
  } finally {
    loadingInvoices.value = false
  }
}

// Formater la date
const formatDate = (date: Date) => {
  return new Intl.DateTimeFormat('fr-FR', {
    day: '2-digit',
    month: 'long',
    year: 'numeric'
  }).format(date)
}

// Télécharger une facture en PDF
const downloadInvoice = async (invoice: any) => {
  try {
    // Récupérer les infos de l'utilisateur
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data: userData } = await supabase
      .from('users')
      .select('company, email, first_name, last_name, address, city, postal_code, country, phone, siret, logo_url')
      .eq('auth_id', user.id)
      .single()

    // Créer un nouveau document PDF
    const doc = new jsPDF()
    
    // Couleurs
    const primaryColor = '#7C3AED'
    const grayColor = '#666666'
    
    // Logo de l'entreprise (FidApp)
    let logoAdded = false
    
    try {
      // Essayer de charger le logo avec l'utilitaire
      const logoBase64 = await getFidAppLogoBase64()
      
      // Ajouter le logo au PDF avec ratio préservé
      const logoWidth = 40  // largeur en mm
      const logoHeight = 16  // hauteur proportionnelle (ratio ~2.5:1)
      
      // Ajouter le logo
      doc.addImage(logoBase64, 'PNG', 20, 15, logoWidth, logoHeight)
      logoAdded = true
      console.log('Logo FidApp ajouté avec succès')
      
    } catch (error) {
      console.error('Impossible de charger le logo, utilisation du texte:', error)
    }
    
    // Si le logo n'a pas pu être ajouté, utiliser le texte
    if (!logoAdded) {
      doc.setFontSize(22)
      doc.setTextColor(primaryColor)
      doc.setFont('helvetica', 'bold')
      doc.text('FidApp', 20, 25)
    }
    
    // Informations de FidApp (émetteur de la facture)
    doc.setFontSize(10)
    doc.setTextColor(grayColor)
    doc.setFont('helvetica', 'normal')
    doc.text('FidApp SAS', 20, 40)
    doc.text('123 Avenue des Champs-Élysées', 20, 45)
    doc.text('75008 Paris, France', 20, 50)
    doc.text('SIRET: 123 456 789 00012', 20, 55)
    doc.text('TVA: FR 12 123456789', 20, 60)
    doc.text('Email: facturation@fidapp.fr', 20, 65)
    doc.text('Tél: +33 1 23 45 67 89', 20, 70)
    
    // Titre FACTURE
    doc.setFontSize(28)
    doc.setTextColor('#000000')
    doc.setFont('helvetica', 'bold')
    doc.text('FACTURE', 140, 30)
    
    // Numéro et date de facture
    doc.setFontSize(10)
    doc.setFont('helvetica', 'normal')
    doc.text(`N° ${invoice.number}`, 140, 40)
    doc.text(`Date: ${formatDate(invoice.date)}`, 140, 45)
    doc.text(`Échéance: ${formatDate(new Date(invoice.date.getTime() + 30 * 24 * 60 * 60 * 1000))}`, 140, 50)
    
    // Rectangle pour les infos client
    doc.setDrawColor(200, 200, 200)
    doc.setFillColor(245, 245, 245)
    doc.rect(20, 85, 170, 45, 'F')
    
    // Informations du client
    doc.setFontSize(12)
    doc.setTextColor('#000000')
    doc.setFont('helvetica', 'bold')
    doc.text('FACTURÉ À:', 25, 95)
    
    doc.setFontSize(10)
    doc.setFont('helvetica', 'normal')
    
    // Colonne gauche - Informations professionnelles
    // Nom de la société ou nom du client
    const clientName = userData?.company || `${userData?.first_name || ''} ${userData?.last_name || ''}`.trim() || 'Client'
    doc.setFont('helvetica', 'bold')
    doc.text(`Société: ${clientName}`, 25, 103)
    
    doc.setFont('helvetica', 'normal')
    // SIRET
    const siretText = userData?.siret || 'Non défini'
    doc.text(`SIRET: ${siretText}`, 25, 109)
    
    // TVA
    const tvaText = userData?.tva_number || 'Non défini'
    doc.text(`TVA: ${tvaText}`, 25, 115)
    
    // Colonne droite - Adresse et contact
    // Adresse complète formatée
    let currentY = 103
    if (userData?.address) {
      // Essayer de séparer le numéro et la rue
      const addressParts = userData.address.match(/^(\d+[a-zA-Z]?\s*(?:bis|ter)?)\s+(.+)$/)
      if (addressParts) {
        // Format: numéro rue (avec espace)
        doc.text(`${addressParts[1]} ${addressParts[2]}`, 115, currentY)
      } else {
        // Si pas de numéro détecté, afficher tel quel
        doc.text(userData.address, 115, currentY)
      }
      currentY += 5
    }
    
    // Ligne 2: code postal ville, pays
    if (userData?.postal_code || userData?.city || userData?.country) {
      let line2 = ''
      
      // Code postal complet
      if (userData?.postal_code) {
        line2 = userData.postal_code
      }
      
      // Ajouter la ville
      if (userData?.city) {
        line2 += line2 ? ' ' : ''
        line2 += userData.city
      }
      
      // Ajouter le pays
      const country = userData?.country || 'France'
      line2 += ', ' + country
      
      doc.text(line2, 115, currentY)
      currentY += 5
    }
    
    // Email sous l'adresse
    const emailText = userData?.email || 'Non défini'
    if (emailText.length > 30) {
      doc.setFontSize(9)
      doc.text(`Email: ${emailText}`, 115, currentY)
      doc.setFontSize(10)
    } else {
      doc.text(`Email: ${emailText}`, 115, currentY)
    }
    currentY += 5
    
    // Téléphone sous l'email
    const phoneText = userData?.phone || 'Non défini'
    doc.text(`Tél: ${phoneText}`, 115, currentY)
    
    // Tableau des services
    const startY = 145
    
    // En-tête du tableau
    doc.setFillColor(primaryColor)
    doc.setTextColor('#FFFFFF')
    doc.rect(20, startY, 170, 10, 'F')
    doc.setFont('helvetica', 'bold')
    doc.text('Description', 25, startY + 7)
    doc.text('Quantité', 100, startY + 7)
    doc.text('Prix unitaire', 130, startY + 7)
    doc.text('Total HT', 165, startY + 7)
    
    // Ligne de service
    doc.setTextColor('#000000')
    doc.setFont('helvetica', 'normal')
    const lineY = startY + 15
    doc.text(`Abonnement FidApp - Plan ${invoice.plan}`, 25, lineY)
    doc.text('1', 105, lineY)
    const priceHT = (invoice.amount / 1.20).toFixed(2)
    doc.text(`${priceHT}€`, 135, lineY)
    doc.text(`${priceHT}€`, 168, lineY)
    
    // Ligne de séparation
    doc.setDrawColor(200, 200, 200)
    doc.line(20, lineY + 5, 190, lineY + 5)
    
    // Totaux
    const totalsY = lineY + 20
    doc.setFont('helvetica', 'normal')
    doc.text('Sous-total HT:', 130, totalsY)
    doc.text(`${priceHT}€`, 168, totalsY)
    
    doc.text('TVA (20%):', 130, totalsY + 7)
    const tva = (invoice.amount - parseFloat(priceHT)).toFixed(2)
    doc.text(`${tva}€`, 168, totalsY + 7)
    
    // Total TTC
    doc.setFillColor(primaryColor)
    doc.setTextColor('#FFFFFF')
    doc.rect(125, totalsY + 12, 65, 10, 'F')
    doc.setFont('helvetica', 'bold')
    doc.text('TOTAL TTC:', 130, totalsY + 19)
    doc.text(`${invoice.amount}€`, 168, totalsY + 19)
    
    // Statut de paiement
    const statusY = totalsY + 35
    if (invoice.status === 'paid') {
      doc.setTextColor('#10B981')
      doc.setFont('helvetica', 'bold')
      doc.text('✓ FACTURE ACQUITTÉE', 20, statusY)
      doc.setFont('helvetica', 'normal')
      doc.text(`Payée le ${formatDate(invoice.date)}`, 20, statusY + 5)
    } else {
      doc.setTextColor('#F59E0B')
      doc.setFont('helvetica', 'bold')
      doc.text('EN ATTENTE DE PAIEMENT', 20, statusY)
    }
    
    // Conditions de paiement
    doc.setTextColor(grayColor)
    doc.setFontSize(9)
    doc.setFont('helvetica', 'normal')
    doc.text('Conditions de paiement:', 20, statusY + 20)
    doc.text('• Paiement à 30 jours date de facture', 20, statusY + 25)
    doc.text('• Pas d\'escompte pour paiement anticipé', 20, statusY + 30)
    doc.text('• Pénalité de retard: 3x le taux d\'intérêt légal', 20, statusY + 35)
    doc.text('• Indemnité forfaitaire pour frais de recouvrement: 40€', 20, statusY + 40)
    
    // Pied de page
    doc.setDrawColor(200, 200, 200)
    doc.line(20, 270, 190, 270)
    doc.setTextColor(grayColor)
    doc.setFontSize(8)
    doc.text('FidApp SAS - Capital social: 10 000€ - RCS Paris B 123 456 789', 105, 280, { align: 'center' })
    doc.text('www.fidapp.fr - contact@fidapp.fr - +33 1 23 45 67 89', 105, 285, { align: 'center' })
    
    // Ouvrir le PDF dans un nouvel onglet
    const pdfBlob = doc.output('blob')
    const pdfUrl = URL.createObjectURL(pdfBlob)
    window.open(pdfUrl, '_blank')
    
    showSuccessMessage(`Facture ${invoice.number} générée`)
  } catch (error) {
    console.error('Erreur génération PDF:', error)
    showSuccessMessage('Erreur lors de la génération de la facture')
  }
}

// Sauvegarder les points d'inscription
const saveSignupPoints = async () => {
  savingPoints.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { error } = await supabase
      .from('users')
      .update({ signup_points: signupPoints.value })
      .eq('auth_id', user.id)

    if (!error) {
      originalSignupPoints.value = signupPoints.value
      showSuccessMessage('Points de bienvenue mis à jour!')
    }
  } catch (error) {
    console.error('Erreur lors de la sauvegarde:', error)
  } finally {
    savingPoints.value = false
  }
}

// Afficher un message de succès
const showSuccessMessage = (message: string) => {
  successMessage.value = message
  showSuccess.value = true
  setTimeout(() => {
    showSuccess.value = false
  }, 3000)
}

onMounted(() => {
  loadSettings()
  loadBillingHistory()
})
</script>