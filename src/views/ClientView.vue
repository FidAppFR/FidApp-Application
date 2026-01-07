<template>
  <div class="min-h-screen bg-gradient-to-br from-violet-50 via-white to-pink-50">
    <!-- Header simplifié -->
    <header class="bg-white/80 backdrop-blur-md border-b border-gray-100 sticky top-0 z-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center space-x-3">
            <!-- Logo de l'entreprise -->
            <div v-if="companyData.logo_url" class="w-10 h-10 rounded-lg overflow-hidden">
              <img :src="companyData.logo_url" alt="Logo" class="w-full h-full object-cover" />
            </div>
            <div v-else class="w-10 h-10 bg-gradient-to-r from-violet-600 to-pink-600 rounded-lg flex items-center justify-center">
              <Building2 :size="20" class="text-white" />
            </div>
            <div>
              <h1 class="text-xl font-bold text-gray-900">{{ companyData.name || 'FidApp' }}</h1>
              <p class="text-xs text-gray-500">Programme de fidélité</p>
            </div>
          </div>
          
          <!-- Boutons selon le type d'utilisateur -->
          <div class="flex items-center space-x-4">
            <!-- Bouton Mon profil pour les clients -->
            <button 
              v-if="!isOwner && isLoggedIn"
              @click="showProfileModal = true"
              class="text-sm text-violet-600 hover:text-violet-700 font-medium flex items-center space-x-1"
            >
              <User :size="16" />
              <span>Mon profil</span>
            </button>
            
            <!-- Bouton déconnexion pour les clients -->
            <button 
              v-if="!isOwner && isLoggedIn"
              @click="handleLogout"
              class="text-sm text-gray-500 hover:text-gray-700 font-medium flex items-center space-x-1"
            >
              <LogOut :size="16" />
              <span>Déconnexion</span>
            </button>
            
            <!-- Bouton retour dashboard pour les propriétaires -->
            <router-link 
              v-if="isOwner"
              to="/dashboard"
              class="text-sm text-violet-600 hover:text-violet-700 font-medium flex items-center space-x-1"
            >
              <ArrowLeft :size="16" />
              <span>Retour au dashboard</span>
            </router-link>
          </div>
        </div>
      </div>
    </header>

    <div class="max-w-4xl mx-auto px-4 py-8">
      <!-- Carte de fidélité -->
      <div class="mb-8">
        <div 
          class="relative h-64 rounded-2xl shadow-2xl overflow-hidden"
          :class="companyData.card_theme !== 'custom' ? cardGradient : ''"
        >
          <!-- Fond personnalisé si type custom -->
          <div v-if="companyData.card_theme === 'custom' && companyData.card_background_url" 
               class="absolute inset-0">
            <img 
              :src="companyData.card_background_url" 
              alt="" 
              class="w-full h-full object-cover"
            />
          </div>
          <!-- Fond dégradé si type gradient -->
          <div v-else class="absolute inset-0" :class="cardGradient"></div>
          
          <div class="absolute inset-0 bg-black/10"></div>
          <div class="relative h-full p-6 flex flex-col justify-between text-white">
            <!-- En-tête de la carte -->
            <div class="flex items-start justify-between">
              <div>
                <h2 class="text-2xl font-black">{{ companyData.name || 'Votre Entreprise' }}</h2>
                <p class="text-white/80 text-sm mt-1">Carte de fidélité</p>
              </div>
              <!-- Logo sur la carte -->
              <div v-if="companyData.logo_url" 
                   class="w-12 h-12 bg-white rounded-lg overflow-hidden shadow-lg">
                <img 
                  :src="companyData.logo_url" 
                  alt="Logo"
                  class="w-full h-full object-cover"
                />
              </div>
            </div>
            
            <!-- Points du client -->
            <div class="flex-1">
              <div v-if="showPoints && isLoggedIn && !isOwner" class="space-y-2">
                <div class="flex items-center space-x-2">
                  <Star :size="20" class="text-yellow-400 fill-current" />
                  <span class="text-2xl font-bold">{{ customerPoints }} pts</span>
                </div>
                <p class="text-white/80 text-sm">{{ customerName }}</p>
              </div>
              <div v-else-if="!isOwner && !isLoggedIn">
                <p class="text-white/80 text-sm">Connectez-vous pour voir vos points</p>
              </div>
            </div>
            
            <!-- Info membre et code de fidélité -->
            <div class="space-y-2">
              <div v-if="isLoggedIn && !isOwner && customerLoyaltyCode" class="bg-white/20 backdrop-blur-md rounded-lg px-3 py-2 border border-white/30">
                <p class="text-xs text-white/90 font-medium mb-1">Code de fidélité</p>
                <p class="text-sm font-mono font-bold text-white tracking-wider">{{ formattedLoyaltyCode }}</p>
              </div>
              <div>
                <p class="text-xs text-white/60">{{ isLoggedIn && !isOwner ? 'Membre depuis' : 'Programme de fidélité' }}</p>
                <p class="text-sm font-medium text-white">{{ isLoggedIn && !isOwner ? memberSince : 'Rejoignez-nous !' }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>


      <!-- Section Points et Récompenses style McDonald's -->
      <div class="mb-8">
        <!-- Carte principale des points -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-200 p-6 mb-4">
          <!-- En-tête avec nom de l'entreprise et points -->
          <div class="mb-6">
            <div class="flex items-center gap-2 mb-3">
              <Star class="w-5 h-5 text-yellow-500 fill-yellow-500" />
              <h3 class="text-lg font-bold text-gray-900">{{ companyData.name || 'PROGRAMME FIDÉLITÉ' }}</h3>
            </div>
            
            <div class="flex items-baseline gap-3">
              <span class="text-5xl font-black text-violet-600">{{ customerPoints }}</span>
              <span class="text-2xl font-medium text-gray-600">points</span>
            </div>
            
            <p v-if="customerPoints > 0" class="text-sm text-gray-500 mt-2">
              dont <span class="font-semibold">{{ customerPoints }}</span> points expirant le {{ getExpirationDate() }}
            </p>
          </div>
          
          <!-- Barre de progression vers la prochaine récompense -->
          <div class="mb-8">
            <div class="relative">
              <!-- Barre de fond -->
              <div class="h-6 bg-gray-100 rounded-full relative">
                <!-- Barre de progression -->
                <div 
                  class="h-full bg-gradient-to-r from-violet-500 to-purple-600 rounded-full transition-all duration-1000 overflow-hidden"
                  :style="`width: ${Math.min((customerPoints / getNextRewardThreshold()) * 100, 100)}%`"
                >
                </div>
                
                <!-- Points blancs pour chaque seuil -->
                <div v-for="threshold in getProgressThresholds()" 
                     :key="threshold"
                     class="absolute top-1/2 -translate-y-1/2 w-3 h-3 bg-white rounded-full z-5"
                     :style="`left: ${(threshold / getNextRewardThreshold()) * 100}%; transform: translateX(-50%) translateY(-50%);`"
                ></div>
                
                <!-- Indicateur actuel - placé en dehors de la barre -->
                <div 
                  class="absolute top-1/2 -translate-y-1/2 w-8 h-8 bg-white border-4 border-violet-600 rounded-full shadow-lg z-10 transition-all duration-1000"
                  :style="`left: ${Math.min((customerPoints / getNextRewardThreshold()) * 100, 100)}%; transform: translateX(-50%) translateY(-50%);`"
                ></div>
              </div>
              
              <!-- Marqueurs de progression avec nombres -->
              <div class="absolute inset-0 flex items-center">
                <div class="flex justify-between w-full">
                  <!-- Points de référence -->
                  <span v-for="threshold in getProgressThresholds()" 
                        :key="threshold"
                        :style="`left: ${(threshold / getNextRewardThreshold()) * 100}%`"
                        class="absolute text-xs font-semibold text-gray-600 -bottom-6">
                    {{ threshold }}
                  </span>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Boutons d'action -->
          <div class="grid grid-cols-2 gap-3">
            <button 
              @click="openProfileModal"
              class="px-4 py-3 bg-gray-50 text-gray-700 rounded-xl hover:bg-gray-100 transition-colors flex items-center justify-center gap-2 font-medium"
            >
              <User :size="18" />
              Mon identifiant
            </button>
            <button 
              @click="handleAddToWallet"
              class="px-4 py-3 bg-violet-50 text-violet-600 rounded-xl hover:bg-violet-100 transition-colors flex items-center justify-center gap-2 font-medium"
            >
              <Smartphone :size="18" />
              Ajouter ma carte à mon Wallet
            </button>
          </div>
        </div>
        
        <!-- Section "Mes avantages" -->
        <div class="mb-8">
          <!-- Onglets -->
          <div class="flex gap-4 mb-6">
            <button 
              @click="rewardsTab = 'available'"
              :class="[
                'text-lg font-bold pb-2 border-b-2 transition-colors',
                rewardsTab === 'available' 
                  ? 'text-violet-600 border-violet-600' 
                  : 'text-gray-400 border-transparent hover:text-gray-600'
              ]"
            >
              Mes avantages
            </button>
            <button 
              @click="rewardsTab = 'history'"
              :class="[
                'text-lg font-bold pb-2 border-b-2 transition-colors',
                rewardsTab === 'history' 
                  ? 'text-violet-600 border-violet-600' 
                  : 'text-gray-400 border-transparent hover:text-gray-600'
              ]"
            >
              Mon historique
            </button>
          </div>
          
          <!-- Contenu des onglets -->
          <div v-if="rewardsTab === 'available'">
            <!-- Grille des récompenses disponibles -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <!-- Carte récompense -->
              <div v-for="offer in availableOffers" :key="offer.id" 
                   class="bg-white rounded-2xl border border-gray-200 overflow-hidden hover:shadow-lg transition-all cursor-pointer"
                   @click="selectedReward = offer">
                <div class="flex">
                  <!-- Image de la récompense -->
                  <div class="w-32 h-32 bg-gradient-to-br from-violet-100 to-purple-100 flex items-center justify-center p-4">
                    <div v-if="offer.image_url" class="w-full h-full">
                      <img :src="offer.image_url" alt="" class="w-full h-full object-contain" />
                    </div>
                    <div v-else class="w-20 h-20 rounded-full border-4 border-dashed border-violet-300 flex items-center justify-center">
                      <component :is="getOfferIcon(offer.type)" class="w-10 h-10 text-violet-400" />
                    </div>
                  </div>
                  
                  <!-- Contenu de la récompense -->
                  <div class="flex-1 p-4">
                    <h4 class="font-bold text-gray-900 mb-1">{{ offer.name }}</h4>
                    <p class="text-sm text-gray-500 mb-2">{{ offer.points_cost }} points</p>
                    
                    <!-- Bouton d'ajout -->
                    <button 
                      v-if="customerPoints >= offer.points_cost"
                      @click.stop="redeemOffer(offer)"
                      class="w-8 h-8 bg-violet-600 text-white rounded-full flex items-center justify-center hover:bg-violet-700 transition-colors"
                    >
                      <Plus :size="20" />
                    </button>
                    <div v-else class="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center">
                      <Lock :size="16" class="text-gray-400" />
                    </div>
                  </div>
                </div>
              </div>
              
              <!-- Message si aucune récompense -->
              <div v-if="availableOffers.length === 0" class="col-span-2 text-center py-12">
                <Gift :size="48" class="mx-auto mb-4 text-gray-300" />
                <p class="text-gray-500">Aucune récompense disponible pour le moment</p>
              </div>
            </div>
          </div>
          
          <!-- Historique -->
          <div v-else-if="rewardsTab === 'history'" class="bg-white rounded-xl p-6">
            <p class="text-gray-500 text-center py-8">Votre historique apparaîtra ici</p>
          </div>
        </div>
      </div>
        
      <!-- État de chargement -->
      <div v-if="loading" class="flex justify-center py-12">
        <Loader2 :size="40" class="text-violet-600 animate-spin" />
      </div>
      
      <!-- Message si aucune récompense -->
      <div v-else-if="rewards.length === 0 && offers.length === 0" class="text-center py-16">
        <div class="w-32 h-32 bg-gradient-to-br from-violet-100 to-pink-100 rounded-3xl flex items-center justify-center mx-auto mb-6 rotate-3">
          <Gift :size="48" class="text-violet-400" />
        </div>
        <p class="text-gray-600 text-xl font-medium">Le catalogue est en préparation</p>
        <p class="text-gray-400 mt-2">De nouvelles surprises arrivent bientôt !</p>
      </div>
      
    </div>

    <!-- Modal de confirmation d'échange -->
    <Teleport to="body">
      <Transition
        enter-active-class="duration-200 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="duration-150 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showRedeemModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div class="absolute inset-0 bg-black/50" @click="showRedeemModal = false"></div>
          
          <div class="relative bg-white rounded-2xl shadow-2xl p-8 max-w-md w-full">
            <div class="text-center">
              <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle :size="32" class="text-green-600" />
              </div>
              <h3 class="text-2xl font-bold text-gray-900 mb-2">Récompense échangée !</h3>
              <p class="text-gray-600 mb-6">
                Votre récompense "{{ selectedReward?.name }}" a été ajoutée à votre compte.
              </p>
              <button 
                @click="showRedeemModal = false"
                class="bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold px-8 py-3 rounded-full hover:scale-105 transition-all duration-300"
              >
                Fermer
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
    
    <!-- Modal Profil Client -->
    <Teleport to="body">
      <Transition
        enter-active-class="duration-200 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="duration-150 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showProfileModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div class="absolute inset-0 bg-black/50" @click="showProfileModal = false"></div>
          
          <div class="relative bg-white rounded-2xl shadow-2xl p-6 max-w-sm w-full">
            <!-- Header du modal -->
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-xl font-bold text-gray-900">Mon identifiant</h3>
              <button 
                @click="showProfileModal = false"
                class="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <X :size="24" />
              </button>
            </div>
            
            <!-- QR Code centré -->
            <div class="flex flex-col items-center space-y-4">
              <div class="bg-white p-4 rounded-xl shadow-inner border border-gray-200">
                <canvas ref="qrCanvasProfile" id="qr-canvas-profile"></canvas>
              </div>
              
              <!-- Code de fidélité -->
              <div class="w-full bg-gradient-to-br from-violet-50 to-purple-50 rounded-xl p-4">
                <p class="text-xs text-gray-600 font-medium mb-2 text-center">Code de fidélité</p>
                <p class="text-xl font-mono font-bold text-violet-900 text-center">{{ formattedLoyaltyCode }}</p>
              </div>
              
              <p class="text-sm text-gray-500 text-center">
                Présentez ce code au commerçant
              </p>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Building2, Star, Gift, Clock, Plus, Minus, TrendingUp, UserPlus, Settings, ArrowLeft, Loader2, CheckCircle, User, LogOut, X, Save, Smartphone, Tag, Award, Percent, ArrowUp, Lock, QrCode } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'
import { recordScan } from '@/api/scanEndpoint'
import QRCode from 'qrcode'

const router = useRouter()

interface Reward {
  id: string
  name: string
  description: string
  points_required: number
  discount_percentage?: number
  discount_amount?: number
  is_active: boolean
  category: string
}

interface CompanyData {
  name: string
  logo_url: string | null
  card_settings?: any
  qr_code_id?: string
  card_theme?: 'gradient' | 'custom'
  card_background_url?: string | null
  card_gradient?: string
}

interface PointsHistory {
  id: string
  points_amount: number
  points_before: number
  points_after: number
  transaction_type: 'welcome' | 'admin_add' | 'admin_remove' | 'earned' | 'spent'
  description: string | null
  created_at: string
}

const rewards = ref<Reward[]>([])
const offers = ref<any[]>([])
const filterCategory = ref<'all' | 'offers' | 'rewards'>('all')
const sortBy = ref<'points_asc' | 'points_desc' | 'available'>('available')
const rewardsTab = ref<'available' | 'history'>('available')
const companyData = ref<CompanyData>({
  name: '',
  logo_url: null,
  card_settings: null,
  qr_code_id: '',
  card_theme: 'gradient',
  card_background_url: null,
  card_gradient: 'from-violet-600 to-pink-600'
})
const pointsHistory = ref<PointsHistory[]>([])
const loading = ref(true)
const loadingHistory = ref(false)
const isOwner = ref(false)
const isAuthenticated = ref(false)
const isLoggedIn = ref(false)
const showRedeemModal = ref(false)
const selectedReward = ref<Reward | null>(null)
const showProfileModal = ref(false)
const savingProfile = ref(false)
const profileMessage = ref('')
const profileMessageType = ref<'success' | 'error'>('success')
const qrCanvasProfile = ref<HTMLCanvasElement | null>(null)

// Données du client
const customerData = ref<any>(null)
const customerPoints = ref(0)
const customerName = ref('')
const memberSince = ref('')
const customerLoyaltyCode = ref('')

// Données du profil client pour le modal
const profileData = ref({
  first_name: '',
  last_name: '',
  email: '',
  phone: '',
  date_of_birth: '',
  total_points_earned: 0,
  total_points_spent: 0,
  accept_marketing: false,
  accept_partners: false
})

// Variables pour Apple Wallet
const customerId = ref('')
const companyId = ref('')
const qrCodeValue = computed(() => {
  if (companyData.value.qr_code_id && customerId.value) {
    return `${window.location.origin}/c/${companyData.value.qr_code_id}?cid=${customerId.value}`
  }
  return ''
})

// Paramètres de la carte
const showPoints = computed(() => 
  companyData.value.card_settings?.showPoints !== false
)

const showQRInCard = computed(() =>
  companyData.value.card_settings?.showQRInCard !== false  // Par défaut à true
)

const cardGradient = computed(() => {
  // Utiliser card_gradient depuis la base de données
  const gradient = companyData.value.card_gradient || companyData.value.card_settings?.gradient || 'from-violet-600 to-pink-600'
  return `bg-gradient-to-br ${gradient}`
})

// Formater le code de fidélité en XXXX-XXXX-XXXX-XXXX
const formattedLoyaltyCode = computed(() => {
  if (!customerLoyaltyCode.value) return ''
  // Diviser en groupes de 4 caractères
  return customerLoyaltyCode.value.match(/.{1,4}/g)?.join(' - ') || customerLoyaltyCode.value
})

// Filtrer les récompenses actives
const filteredRewards = computed(() => 
  rewards.value.filter(r => r.is_active).sort((a, b) => a.points_required - b.points_required)
)

// Compter les offres disponibles
const availableOffersCount = computed(() => {
  const offersAvailable = offers.value.filter(o => o.is_active && customerPoints.value >= o.points_cost).length
  const rewardsAvailable = rewards.value.filter(r => r.is_active && customerPoints.value >= r.points_required).length
  return offersAvailable + rewardsAvailable
})

// Compter le total des offres
const totalOffersCount = computed(() => {
  const activeOffers = offers.value.filter(o => o.is_active).length
  const activeRewards = rewards.value.filter(r => r.is_active).length
  return activeOffers + activeRewards
})

// Trier les offres
const sortedOffers = computed(() => {
  let sorted = [...offers.value.filter(o => o.is_active)]
  
  switch(sortBy.value) {
    case 'points_asc':
      sorted.sort((a, b) => a.points_cost - b.points_cost)
      break
    case 'points_desc':
      sorted.sort((a, b) => b.points_cost - a.points_cost)
      break
    case 'available':
      sorted.sort((a, b) => {
        const aAvailable = customerPoints.value >= a.points_cost ? 0 : 1
        const bAvailable = customerPoints.value >= b.points_cost ? 0 : 1
        return aAvailable - bAvailable || a.points_cost - b.points_cost
      })
      break
  }
  
  return sorted
})

// Trier les récompenses
const sortedRewards = computed(() => {
  let sorted = [...rewards.value.filter(r => r.is_active)]
  
  switch(sortBy.value) {
    case 'points_asc':
      sorted.sort((a, b) => a.points_required - b.points_required)
      break
    case 'points_desc':
      sorted.sort((a, b) => b.points_required - a.points_required)
      break
    case 'available':
      sorted.sort((a, b) => {
        const aAvailable = customerPoints.value >= a.points_required ? 0 : 1
        const bAvailable = customerPoints.value >= b.points_required ? 0 : 1
        return aAvailable - bAvailable || a.points_required - b.points_required
      })
      break
  }
  
  return sorted
})

// Charger les données de l'entreprise et les récompenses
const loadData = async () => {
  loading.value = true
  try {
    // Récupérer l'ID de l'entreprise depuis l'URL
    const companyParam = router.currentRoute.value.query.company as string
    let localCompanyId = companyParam
    
    // Vérifier si c'est un propriétaire d'entreprise
    const { data: { user } } = await supabase.auth.getUser()
    if (user) {
      const { data: userData } = await supabase
        .from('users')
        .select('id')
        .eq('auth_id', user.id)
        .single()
      
      if (userData) {
        isOwner.value = true
        localCompanyId = userData.id
        companyId.value = userData.id
      }
    }
    
    // Vérifier la session client
    const customerSession = localStorage.getItem('customer_session')
    if (customerSession && !isOwner.value) {
      const session = JSON.parse(customerSession)
      customerData.value = session
      isAuthenticated.value = true
      isLoggedIn.value = true  // Marquer comme connecté
      customerPoints.value = session.points || 0
      customerName.value = session.name || ''
      customerId.value = session.id
      companyId.value = localCompanyId
      
      // Rafraîchir les points depuis la base
      const { data: freshCustomer } = await supabase
        .from('customers')
        .select('points, created_at, loyalty_code')
        .eq('id', session.id)
        .single()
      
      if (freshCustomer) {
        customerPoints.value = freshCustomer.points
        customerLoyaltyCode.value = freshCustomer.loyalty_code || ''
        // Stocker created_at dans customerData pour le calcul de l'expiration
        customerData.value.created_at = freshCustomer.created_at
        const createdDate = new Date(freshCustomer.created_at)
        memberSince.value = createdDate.toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' })
      }
    } else if (!isOwner.value) {
      // Rediriger vers l'authentification client
      router.push(`/client-auth?company=${localCompanyId}`)
      return
    }
    
    // Charger les données de l'entreprise
    if (localCompanyId) {
      const { data: companyInfo } = await supabase
        .from('users')
        .select('company, logo_url, card_settings, qr_code_id, card_theme, card_background_url, card_gradient')
        .eq('id', localCompanyId)
        .single()
      
      if (companyInfo) {
        companyData.value = {
          name: companyInfo.company || 'FidApp',
          logo_url: companyInfo.logo_url,
          card_settings: companyInfo.card_settings,
          qr_code_id: companyInfo.qr_code_id,
          card_theme: companyInfo.card_theme || 'gradient',
          card_background_url: companyInfo.card_background_url,
          card_gradient: companyInfo.card_gradient || 'from-violet-600 to-pink-600'
        }
      }
      
      // Charger les récompenses
      const { data: rewardsData } = await supabase
        .from('rewards')
        .select('*')
        .eq('company_id', localCompanyId)
        .eq('is_active', true)
      
      if (rewardsData) {
        rewards.value = rewardsData
      }
      
      // Charger les offres
      const { data: offersData } = await supabase
        .from('offers')
        .select('*')
        .eq('company_id', localCompanyId)
        .eq('is_active', true)
        .order('points_cost', { ascending: true })
      
      if (offersData) {
        offers.value = offersData
      }
    }
  } catch (error) {
    console.error('Erreur lors du chargement:', error)
  } finally {
    loading.value = false
  }
}

// Obtenir le nombre de points maximum nécessaire
const getMaxRewardPoints = () => {
  const allPoints = [
    ...offers.value.map(o => o.points_cost),
    ...rewards.value.map(r => r.points_required)
  ]
  return Math.max(...allPoints, 100) // Au minimum 100 points
}

// Obtenir le prochain seuil de récompense
const getNextRewardThreshold = () => {
  const allPoints = [
    ...offers.value.map(o => o.points_cost),
    ...rewards.value.map(r => r.points_required)
  ].filter(p => p > customerPoints.value).sort((a, b) => a - b)
  
  return allPoints[0] || getMaxRewardPoints()
}

// Obtenir la date d'expiration des points (1 an après l'inscription)
const getExpirationDate = () => {
  if (!customerData.value || !customerData.value.created_at) {
    // Si pas de date d'inscription, retourner une date par défaut
    const date = new Date()
    date.setFullYear(date.getFullYear() + 1)
    return date.toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })
  }
  
  // Calculer 1 an après la date d'inscription
  const inscriptionDate = new Date(customerData.value.created_at)
  inscriptionDate.setFullYear(inscriptionDate.getFullYear() + 1)
  return inscriptionDate.toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })
}

// Obtenir les seuils de progression pour la barre
const getProgressThresholds = () => {
  const max = getNextRewardThreshold()
  const step = Math.round(max / 4)
  return [step, step * 2, step * 3]
}

// Obtenir les offres disponibles en fonction des points
const availableOffers = computed(() => {
  return offers.value.filter(offer => offer.is_active)
})

// Obtenir l'icône selon le type d'offre
const getOfferIcon = (type: string) => {
  switch (type) {
    case 'discount': return Percent
    case 'gift': return Gift
    case 'points': return Star
    case 'upgrade': return ArrowUp
    default: return Tag
  }
}
// Obtenir le label du type d'offre
const getOfferTypeLabel = (type: string) => {
  switch (type) {
    case 'discount': return 'Réduction'
    case 'gift': return 'Cadeau'
    case 'points': return 'Points bonus'
    case 'upgrade': return 'Surclassement'
    default: return 'Offre'
  }
}


// Obtenir le gradient pour le type d'offre
const getOfferGradient = (type: string) => {
  switch (type) {
    case 'discount': 
      return 'from-emerald-400 to-green-600'
    case 'gift': 
      return 'from-pink-400 to-rose-600'
    case 'points': 
      return 'from-amber-400 to-yellow-600'
    case 'upgrade': 
      return 'from-purple-400 to-indigo-600'
    default: 
      return 'from-violet-400 to-purple-600'
  }
}

// Obtenir la classe du badge pour le type d'offre
const getOfferBadgeClass = (type: string) => {
  switch (type) {
    case 'discount': 
      return 'bg-green-500/90 text-white'
    case 'gift': 
      return 'bg-rose-500/90 text-white'
    case 'points': 
      return 'bg-amber-500/90 text-white'
    case 'upgrade': 
      return 'bg-indigo-500/90 text-white'
    default: 
      return 'bg-violet-500/90 text-white'
  }
}

// Échanger une offre
const redeemOffer = async (offer: any) => {
  selectedReward.value = {
    id: offer.id,
    name: offer.name,
    description: offer.description,
    points_required: offer.points_cost,
    is_active: offer.is_active,
    category: offer.type
  }
  showRedeemModal.value = true
  
  try {
    // Récupérer l'ID de l'entreprise depuis l'URL
    const companyParam = router.currentRoute.value.query.company as string
    const companyId = companyParam || ''
    
    if (!customerData.value || !companyId) {
      console.error('Données client ou entreprise manquantes')
      return
    }
    
    const oldPoints = customerPoints.value
    const newPoints = oldPoints - offer.points_cost
    
    // Mettre à jour les points du client
    const { error: updateError } = await supabase
      .from('customers')
      .update({ points: newPoints })
      .eq('id', customerData.value.id)
    
    if (updateError) {
      console.error('Erreur lors de la mise à jour des points:', updateError)
      showRedeemModal.value = false
      return
    }
    
    // Créer l'enregistrement dans offer_redemptions (si la table existe)
    const { error: redemptionError } = await supabase
      .from('offer_redemptions')
      .insert({
        offer_id: offer.id,
        customer_id: customerData.value.id,
        company_id: companyId,
        points_used: offer.points_cost,
        status: 'completed'
      })
    
    if (redemptionError && !redemptionError.message.includes('offer_redemptions')) {
      console.error('Erreur lors de l\'enregistrement de l\'échange:', redemptionError)
    }
    
    // Créer l'enregistrement dans l'historique
    const { error: historyError } = await supabase
      .from('points_history')
      .insert({
        customer_id: customerData.value.id,
        company_id: companyId,
        points_amount: -offer.points_cost,
        points_before: oldPoints,
        points_after: newPoints,
        transaction_type: 'spent',
        description: `Offre échangée: ${offer.name}`,
        offer_id: offer.id
      })
    
    if (historyError) {
      console.error('Erreur lors de l\'enregistrement de l\'historique:', historyError)
    }
    
    // Mettre à jour l'affichage local
    customerPoints.value = newPoints
    
    // Rafraîchir l'historique
    if (customerData.value && companyId) {
      loadPointsHistory(customerData.value.id, companyId)
    }
    
  } catch (error) {
    console.error('Erreur lors de l\'échange:', error)
    showRedeemModal.value = false
  }
}

// Échanger une récompense
const redeemReward = async (reward: Reward) => {
  selectedReward.value = reward
  showRedeemModal.value = true
  
  try {
    // Récupérer l'ID de l'entreprise depuis l'URL
    const companyParam = router.currentRoute.value.query.company as string
    const companyId = companyParam || ''
    
    if (!customerData.value || !companyId) {
      console.error('Données client ou entreprise manquantes')
      return
    }
    
    const oldPoints = customerPoints.value
    const newPoints = oldPoints - reward.points_required
    
    // Mettre à jour les points du client
    const { error: updateError } = await supabase
      .from('customers')
      .update({ points: newPoints })
      .eq('id', customerData.value.id)
    
    if (updateError) {
      console.error('Erreur lors de la mise à jour des points:', updateError)
      showRedeemModal.value = false
      return
    }
    
    // Créer l'enregistrement dans reward_redemptions
    const { error: redemptionError } = await supabase
      .from('reward_redemptions')
      .insert({
        reward_id: reward.id,
        customer_id: customerData.value.id,
        company_id: companyId,
        points_used: reward.points_required,
        status: 'completed'
      })
    
    if (redemptionError) {
      console.error('Erreur lors de l\'enregistrement de l\'échange:', redemptionError)
    }
    
    // Créer l'enregistrement dans l'historique
    const { error: historyError } = await supabase
      .from('points_history')
      .insert({
        customer_id: customerData.value.id,
        company_id: companyId,
        points_amount: -reward.points_required,
        points_before: oldPoints,
        points_after: newPoints,
        transaction_type: 'spent',
        description: `Échange: ${reward.name}`,
        reward_id: reward.id
      })
    
    if (historyError) {
      console.error('Erreur lors de l\'enregistrement de l\'historique:', historyError)
    }
    
    // Mettre à jour l'affichage local
    customerPoints.value = newPoints
    
    // Rafraîchir l'historique
    if (customerData.value && companyId) {
      loadPointsHistory(customerData.value.id, companyId)
    }
    
  } catch (error) {
    console.error('Erreur lors de l\'échange:', error)
    showRedeemModal.value = false
  }
}

// Gérer la déconnexion client
const handleLogout = () => {
  // Supprimer la session du localStorage
  localStorage.removeItem('customer_session')
  isLoggedIn.value = false
  customerData.value = null
  
  // Rediriger vers la page d'authentification
  const companyId = new URLSearchParams(window.location.search).get('company')
  if (companyId) {
    router.push(`/client-auth?company=${companyId}`)
  }
}

// Mettre à jour le profil client
const updateProfile = async () => {
  savingProfile.value = true
  profileMessage.value = ''
  
  try {
    const session = localStorage.getItem('customer_session')
    if (!session) {
      profileMessage.value = 'Session expirée. Veuillez vous reconnecter.'
      profileMessageType.value = 'error'
      return
    }
    
    const customerSession = JSON.parse(session)
    
    // Mettre à jour les données dans la base
    const { error } = await supabase
      .from('customers')
      .update({
        first_name: profileData.value.first_name,
        last_name: profileData.value.last_name,
        email: profileData.value.email,
        phone: profileData.value.phone,
        date_of_birth: profileData.value.date_of_birth || null,
        accept_marketing: profileData.value.accept_marketing,
        accept_partners: profileData.value.accept_partners,
        consent_updated_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .eq('id', customerSession.id)
    
    if (error) throw error
    
    // Mettre à jour le nom affiché
    customerName.value = `${profileData.value.first_name} ${profileData.value.last_name}`
    
    // Mettre à jour la session
    customerSession.name = customerName.value
    customerSession.email = profileData.value.email
    localStorage.setItem('customer_session', JSON.stringify(customerSession))
    
    profileMessage.value = 'Profil mis à jour avec succès !'
    profileMessageType.value = 'success'
    
    // Fermer le modal après 2 secondes
    setTimeout(() => {
      showProfileModal.value = false
      profileMessage.value = ''
    }, 2000)
    
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil:', error)
    profileMessage.value = 'Erreur lors de la mise à jour'
    profileMessageType.value = 'error'
  } finally {
    savingProfile.value = false
  }
}

// Charger les données du client depuis la session
const loadCustomerFromSession = () => {
  const session = localStorage.getItem('customer_session')
  
  if (session) {
    try {
      const data = JSON.parse(session)
      
      isLoggedIn.value = true
      customerData.value = data
      customerPoints.value = data.points || 0
      customerName.value = data.name || 'Client'
      customerId.value = data.id
      
      // Récupérer le company_id depuis l'URL ou la session
      const companyParam = router.currentRoute.value.query.company as string
      if (companyParam) {
        companyId.value = companyParam
      }
      
      // Charger les détails complets du client
      loadCustomerDetails(data.id)
    } catch (error) {
      console.error('Erreur session client:', error)
    }
  }
}

// Charger les détails complets du client
const loadCustomerDetails = async (customerId: string) => {
  try {
    const { data, error } = await supabase
      .from('customers')
      .select('*')
      .eq('id', customerId)
      .single()
    
    if (data) {
      // Mettre à jour les données du profil
      profileData.value = {
        first_name: data.first_name,
        last_name: data.last_name,
        email: data.email,
        phone: data.phone || '',
        date_of_birth: data.date_of_birth || '',
        total_points_earned: data.total_points_earned || 0,
        total_points_spent: data.total_points_spent || 0,
        accept_marketing: data.accept_marketing || false,
        accept_partners: data.accept_partners || false
      }
      
      customerPoints.value = data.points || 0
      customerName.value = `${data.first_name} ${data.last_name}`
      customerLoyaltyCode.value = data.loyalty_code || ''
      
      // Stocker created_at pour le calcul de l'expiration
      if (customerData.value) {
        customerData.value.created_at = data.created_at
      }
      
      // S'assurer que companyId est défini
      if (!companyId.value && data.company_id) {
        companyId.value = data.company_id
      }
      
      // S'assurer que les valeurs obligatoires sont définies avec des valeurs par défaut si nécessaire
      if (!customerId.value) {
        customerId.value = data.id
      }
      if (!companyId.value) {
        companyId.value = data.company_id
      }
      
      // Formater la date de membre
      if (data.created_at) {
        const date = new Date(data.created_at)
        memberSince.value = date.toLocaleDateString('fr-FR', { 
          year: 'numeric', 
          month: 'long' 
        })
      }
      
      // Charger l'historique des points
      loadPointsHistory(customerId, data.company_id)
    }
  } catch (error) {
    console.error('Erreur lors du chargement des détails client:', error)
  }
}

// Charger l'historique des points
const loadPointsHistory = async (customerId: string, companyId: string) => {
  loadingHistory.value = true
  try {
    // Récupérer l'historique pour l'affichage
    const { data, error } = await supabase
      .from('points_history')
      .select('*')
      .eq('customer_id', customerId)
      .eq('company_id', companyId)
      .order('created_at', { ascending: false })
      .limit(20)
    
    if (data) {
      pointsHistory.value = data
    }
    
    // Récupérer TOUT l'historique pour calculer les totaux
    const { data: allHistory } = await supabase
      .from('points_history')
      .select('points_amount, transaction_type')
      .eq('customer_id', customerId)
      .eq('company_id', companyId)
    
    if (allHistory) {
      // Calculer les totaux
      let totalEarned = 0
      let totalSpent = 0
      
      allHistory.forEach(transaction => {
        if (transaction.transaction_type === 'welcome' || 
            transaction.transaction_type === 'earned' || 
            transaction.transaction_type === 'admin_add') {
          totalEarned += Math.abs(transaction.points_amount)
        } else if (transaction.transaction_type === 'spent' || 
                   transaction.transaction_type === 'admin_remove') {
          totalSpent += Math.abs(transaction.points_amount)
        }
      })
      
      // Mettre à jour les données du profil
      profileData.value.total_points_earned = totalEarned
      profileData.value.total_points_spent = totalSpent
    }
  } catch (error) {
    console.error('Erreur lors du chargement de l\'historique:', error)
  } finally {
    loadingHistory.value = false
  }
}

// Obtenir la couleur selon le type de transaction
const getTransactionColor = (type: string) => {
  const colors: Record<string, string> = {
    'welcome': 'bg-green-100 text-green-600',
    'earned': 'bg-green-100 text-green-600',
    'admin_add': 'bg-orange-100 text-orange-600',
    'admin_remove': 'bg-orange-100 text-orange-600',
    'spent': 'bg-red-100 text-red-600'
  }
  return colors[type] || 'bg-gray-100 text-gray-600'
}

// Obtenir l'icône selon le type de transaction
const getTransactionIcon = (type: string) => {
  const icons: Record<string, any> = {
    'welcome': UserPlus,
    'earned': TrendingUp,
    'admin_add': Plus,
    'admin_remove': Minus,
    'spent': Gift
  }
  return icons[type] || Clock
}

// Obtenir le label selon le type de transaction
const getTransactionLabel = (type: string) => {
  const labels: Record<string, string> = {
    'welcome': 'Points de bienvenue',
    'earned': 'Points gagnés',
    'admin_add': 'Points ajoutés (Admin)',
    'admin_remove': 'Points retirés (Admin)',
    'spent': 'Récompense échangée'
  }
  return labels[type] || 'Transaction'
}

// Formater la date de transaction
const formatTransactionDate = (dateString: string) => {
  const date = new Date(dateString)
  const now = new Date()
  const diffTime = Math.abs(now.getTime() - date.getTime())
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))
  
  if (diffDays === 0) {
    const diffHours = Math.floor(diffTime / (1000 * 60 * 60))
    if (diffHours === 0) {
      const diffMinutes = Math.floor(diffTime / (1000 * 60))
      if (diffMinutes === 0) return "À l'instant"
      return `Il y a ${diffMinutes} minute${diffMinutes > 1 ? 's' : ''}`
    }
    return `Il y a ${diffHours} heure${diffHours > 1 ? 's' : ''}`
  }
  if (diffDays === 1) return 'Hier'
  if (diffDays < 7) return `Il y a ${diffDays} jours`
  if (diffDays < 30) return `Il y a ${Math.floor(diffDays / 7)} semaine${Math.floor(diffDays / 7) > 1 ? 's' : ''}`
  
  return date.toLocaleDateString('fr-FR', { 
    day: 'numeric', 
    month: 'long', 
    year: 'numeric' 
  })
}

// Méthode pour ajouter au wallet
const handleAddToWallet = () => {
  // Afficher une notification temporaire
  const notification = document.createElement('div')
  notification.className = 'fixed top-4 right-4 z-50 bg-violet-500 text-white px-6 py-3 rounded-lg shadow-lg flex items-center space-x-2'
  notification.innerHTML = `
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
    </svg>
    <span>Fonction Wallet temporairement indisponible</span>
  `
  document.body.appendChild(notification)
  
  setTimeout(() => {
    notification.remove()
  }, 3000)
}

// Générer le QR code pour le profil
const generateProfileQRCode = async () => {
  if (!qrCanvasProfile.value || !customerLoyaltyCode.value) return
  
  try {
    // Données à encoder dans le QR code
    const qrData = JSON.stringify({
      type: 'fidapp_customer',
      company_id: companyId.value,
      customer_id: customerId.value,
      loyalty_code: customerLoyaltyCode.value,
      timestamp: Date.now()
    })
    
    await QRCode.toCanvas(qrCanvasProfile.value, qrData, {
      width: 200,
      margin: 2,
      color: {
        dark: '#7C3AED',
        light: '#FFFFFF'
      },
      errorCorrectionLevel: 'M'
    })
  } catch (error) {
    console.error('Erreur génération QR code:', error)
  }
}

// Ouvrir le modal du profil
const openProfileModal = async () => {
  showProfileModal.value = true
  // Attendre que le DOM soit mis à jour
  await new Promise(resolve => setTimeout(resolve, 100))
  generateProfileQRCode()
}

onMounted(async () => {
  await loadData()
  loadCustomerFromSession()
})

// Rafraîchir les points et l'historique du client
const refreshCustomerPoints = async () => {
  if (!customerData.value) return
  
  try {
    // Récupérer les points actuels
    const { data: freshCustomer } = await supabase
      .from('customers')
      .select('points, company_id')
      .eq('id', customerData.value.id)
      .single()
    
    if (freshCustomer) {
      const oldPoints = customerPoints.value
      customerPoints.value = freshCustomer.points
      
      // Recharger l'historique et recalculer les statistiques
      await loadPointsHistory(customerData.value.id, freshCustomer.company_id)
      
      // Si les points ont changé, mettre aussi à jour la session
      if (oldPoints !== freshCustomer.points) {
        const session = localStorage.getItem('customer_session')
        if (session) {
          const sessionData = JSON.parse(session)
          sessionData.points = freshCustomer.points
          localStorage.setItem('customer_session', JSON.stringify(sessionData))
        }
      }
    }
  } catch (error) {
    console.error('Erreur lors du rafraîchissement:', error)
  }
}
</script>

<style scoped>
@keyframes shimmer {
  0% {
    transform: translateX(-100%);
  }
  100% {
    transform: translateX(100%);
  }
}

.animate-shimmer {
  animation: shimmer 2s infinite;
}
</style>