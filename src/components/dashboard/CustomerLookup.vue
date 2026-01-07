<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-3xl font-black text-gray-900 dark:text-white">Recherche Client</h1>
      <p class="text-gray-600 dark:text-gray-400 mt-2">Recherchez un client par son code de fidélité ou scannez son QR code</p>
    </div>

    <!-- Formulaire de recherche -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700">
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-semibold text-gray-700 mb-2">
            Code de fidélité du client
          </label>
          <div class="flex gap-3">
            <div class="flex-1 relative">
              <input
                v-model="searchCode"
                type="text"
                class="w-full px-4 py-3 pl-12 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors uppercase font-mono tracking-wider"
                placeholder="Entrez le code à 16 caractères"
                @keyup.enter="searchCustomer"
                maxlength="16"
              />
              <div class="absolute left-4 top-1/2 -translate-y-1/2">
                <CreditCard :size="20" class="text-gray-400" />
              </div>
            </div>
            <button
              @click="searchCustomer"
              :disabled="searching || !searchCode.trim()"
              class="px-6 py-3 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold rounded-xl hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:hover:scale-100"
            >
              <Search :size="20" v-if="!searching" />
              <Loader2 :size="20" v-else class="animate-spin" />
              <span class="ml-2">{{ searching ? 'Recherche...' : 'Rechercher' }}</span>
            </button>
          </div>
        </div>

        <!-- Instructions -->
        <div class="bg-violet-50 rounded-lg p-4 border border-violet-200">
          <p class="text-sm text-violet-700">
            💡 Demandez au client son code de fidélité ou scannez le QR code depuis son téléphone
          </p>
        </div>
      </div>
    </div>

    <!-- Message d'erreur -->
    <div v-if="errorMessage" class="bg-red-50 border border-red-200 rounded-xl p-4">
      <div class="flex items-start space-x-2">
        <AlertCircle :size="20" class="text-red-500 flex-shrink-0 mt-0.5" />
        <div>
          <p class="text-sm font-medium text-red-700">{{ errorMessage }}</p>
        </div>
      </div>
    </div>

    <!-- Résultat de la recherche -->
    <div v-if="customerFound" class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
      <!-- Header avec infos client -->
      <div class="bg-gradient-to-r from-violet-600 to-pink-600 p-6 text-white">
        <div class="flex items-center justify-between">
          <div>
            <h3 class="text-2xl font-bold">{{ customerFound.first_name }} {{ customerFound.last_name }}</h3>
            <p class="text-white/80 mt-1">Client fidèle depuis {{ formatDate(customerFound.created_at) }}</p>
          </div>
          <div class="text-right">
            <p class="text-sm text-white/80">Code de fidélité</p>
            <p class="text-lg font-mono font-bold tracking-wide">{{ formattedLoyaltyCode }}</p>
          </div>
        </div>
      </div>

      <!-- Statistiques -->
      <div class="p-6">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <!-- Points actuels -->
          <div class="bg-violet-50 rounded-lg p-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm text-gray-600">Points actuels</p>
                <p class="text-2xl font-bold text-violet-600">{{ customerFound.points }}</p>
              </div>
              <Star :size="24" class="text-violet-600" />
            </div>
          </div>

          <!-- Total gagné -->
          <div class="bg-green-50 rounded-lg p-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm text-gray-600">Total gagné</p>
                <p class="text-2xl font-bold text-green-600">{{ customerFound.total_points_earned || 0 }}</p>
              </div>
              <TrendingUp :size="24" class="text-green-600" />
            </div>
          </div>

          <!-- Total dépensé -->
          <div class="bg-blue-50 rounded-lg p-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm text-gray-600">Total utilisé</p>
                <p class="text-2xl font-bold text-blue-600">{{ customerFound.total_points_spent || 0 }}</p>
              </div>
              <Gift :size="24" class="text-blue-600" />
            </div>
          </div>

          <!-- Statut -->
          <div class="bg-gray-50 rounded-lg p-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm text-gray-600">Statut</p>
                <p class="text-lg font-bold" :class="customerFound.is_verified ? 'text-green-600' : 'text-orange-600'">
                  {{ customerFound.is_verified ? 'Vérifié' : 'Non vérifié' }}
                </p>
              </div>
              <CheckCircle :size="24" :class="customerFound.is_verified ? 'text-green-600' : 'text-gray-400'" />
            </div>
          </div>
        </div>

        <!-- Informations de contact -->
        <div class="border-t pt-4">
          <h4 class="font-semibold text-gray-900 mb-3">Informations de contact</h4>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="flex items-center space-x-2">
              <Mail :size="16" class="text-gray-400" />
              <span class="text-sm text-gray-600">Email :</span>
              <span class="text-sm font-medium">{{ customerFound.email }}</span>
            </div>
            <div class="flex items-center space-x-2">
              <Phone :size="16" class="text-gray-400" />
              <span class="text-sm text-gray-600">Téléphone :</span>
              <span class="text-sm font-medium">{{ customerFound.phone || 'Non renseigné' }}</span>
            </div>
          </div>
        </div>

        <!-- Actions rapides -->
        <div class="border-t mt-6 pt-6">
          <h4 class="font-semibold text-gray-900 mb-4">Actions rapides</h4>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <!-- Ajouter des points -->
            <div class="border border-gray-200 rounded-lg p-4">
              <h5 class="font-medium text-gray-900 mb-3 flex items-center gap-2">
                <Plus :size="16" />
                Ajouter des points
              </h5>
              <div class="flex gap-2">
                <input
                  v-model.number="pointsToAdd"
                  type="number"
                  min="1"
                  class="flex-1 px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-violet-500"
                  placeholder="Points"
                />
                <button
                  @click="addPoints"
                  :disabled="!pointsToAdd || pointsToAdd <= 0"
                  class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50"
                >
                  Ajouter
                </button>
              </div>
            </div>

            <!-- Retirer des points -->
            <div class="border border-gray-200 rounded-lg p-4">
              <h5 class="font-medium text-gray-900 mb-3 flex items-center gap-2">
                <Minus :size="16" />
                Retirer des points
              </h5>
              <div class="flex gap-2">
                <input
                  v-model.number="pointsToRemove"
                  type="number"
                  min="1"
                  :max="customerFound.points"
                  class="flex-1 px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-violet-500"
                  placeholder="Points"
                />
                <button
                  @click="removePoints"
                  :disabled="!pointsToRemove || pointsToRemove <= 0 || pointsToRemove > customerFound.points"
                  class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors disabled:opacity-50"
                >
                  Retirer
                </button>
              </div>
            </div>

            <!-- Voir l'historique -->
            <div class="border border-gray-200 rounded-lg p-4">
              <h5 class="font-medium text-gray-900 mb-3 flex items-center gap-2">
                <History :size="16" />
                Historique
              </h5>
              <button
                @click="viewHistory"
                class="w-full px-4 py-2 bg-violet-600 text-white rounded-lg hover:bg-violet-700 transition-colors"
              >
                Voir l'historique
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Message si pas de résultat -->
    <div v-else-if="searched && !customerFound" class="bg-gray-50 rounded-xl p-8 text-center">
      <UserX :size="48" class="mx-auto text-gray-300 mb-4" />
      <p class="text-gray-600">Aucun client trouvé avec ce code de fidélité</p>
      <p class="text-sm text-gray-500 mt-2">Vérifiez le code ou demandez au client de vérifier</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { 
  CreditCard, Search, Loader2, AlertCircle, Star, TrendingUp, Gift, 
  CheckCircle, Mail, Phone, Plus, Minus, History, UserX 
} from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

interface Customer {
  id: string
  company_id: string
  first_name: string
  last_name: string
  email: string
  phone: string | null
  loyalty_code: string
  points: number
  total_points_earned: number
  total_points_spent: number
  created_at: string
  is_verified: boolean
}

const searchCode = ref('')
const searching = ref(false)
const searched = ref(false)
const customerFound = ref<Customer | null>(null)
const errorMessage = ref('')

const pointsToAdd = ref<number | null>(null)
const pointsToRemove = ref<number | null>(null)

// Formater le code de fidélité
const formattedLoyaltyCode = computed(() => {
  if (!customerFound.value?.loyalty_code) return ''
  return customerFound.value.loyalty_code.match(/.{1,4}/g)?.join(' - ') || customerFound.value.loyalty_code
})

// Formater la date
const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('fr-FR', {
    month: 'long',
    year: 'numeric'
  })
}

// Rechercher un client
const searchCustomer = async () => {
  if (!searchCode.value.trim()) return
  
  searching.value = true
  searched.value = false
  errorMessage.value = ''
  customerFound.value = null
  
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      errorMessage.value = 'Vous devez être connecté'
      return
    }

    // Récupérer l'ID de l'entreprise
    const { data: userData } = await supabase
      .from('users')
      .select('id')
      .eq('auth_id', user.id)
      .single()

    if (!userData) {
      errorMessage.value = 'Entreprise non trouvée'
      return
    }

    // Rechercher le client par code de fidélité
    const { data: customer, error } = await supabase
      .from('customers')
      .select('*')
      .eq('company_id', userData.id)
      .eq('loyalty_code', searchCode.value.toUpperCase())
      .single()

    if (error || !customer) {
      searched.value = true
      return
    }

    customerFound.value = customer
    searched.value = true
  } catch (error) {
    console.error('Erreur recherche:', error)
    errorMessage.value = 'Une erreur est survenue lors de la recherche'
  } finally {
    searching.value = false
  }
}

// Ajouter des points
const addPoints = async () => {
  if (!customerFound.value || !pointsToAdd.value || pointsToAdd.value <= 0) return
  
  try {
    const newPoints = customerFound.value.points + pointsToAdd.value
    
    const { error } = await supabase
      .from('customers')
      .update({ 
        points: newPoints,
        total_points_earned: (customerFound.value.total_points_earned || 0) + pointsToAdd.value
      })
      .eq('id', customerFound.value.id)

    if (!error) {
      customerFound.value.points = newPoints
      customerFound.value.total_points_earned = (customerFound.value.total_points_earned || 0) + pointsToAdd.value
      pointsToAdd.value = null
      
      // Créer une entrée dans l'historique
      await supabase
        .from('points_history')
        .insert({
          customer_id: customerFound.value.id,
          company_id: customerFound.value.company_id,
          points_amount: pointsToAdd.value,
          points_before: customerFound.value.points - pointsToAdd.value,
          points_after: newPoints,
          transaction_type: 'admin_add',
          description: 'Points ajoutés manuellement'
        })
    }
  } catch (error) {
    console.error('Erreur ajout points:', error)
  }
}

// Retirer des points
const removePoints = async () => {
  if (!customerFound.value || !pointsToRemove.value || pointsToRemove.value <= 0) return
  
  try {
    const newPoints = Math.max(0, customerFound.value.points - pointsToRemove.value)
    
    const { error } = await supabase
      .from('customers')
      .update({ 
        points: newPoints,
        total_points_spent: (customerFound.value.total_points_spent || 0) + pointsToRemove.value
      })
      .eq('id', customerFound.value.id)

    if (!error) {
      customerFound.value.points = newPoints
      customerFound.value.total_points_spent = (customerFound.value.total_points_spent || 0) + pointsToRemove.value
      pointsToRemove.value = null
      
      // Créer une entrée dans l'historique
      await supabase
        .from('points_history')
        .insert({
          customer_id: customerFound.value.id,
          company_id: customerFound.value.company_id,
          points_amount: -pointsToRemove.value,
          points_before: customerFound.value.points + pointsToRemove.value,
          points_after: newPoints,
          transaction_type: 'admin_remove',
          description: 'Points retirés manuellement'
        })
    }
  } catch (error) {
    console.error('Erreur retrait points:', error)
  }
}

// Voir l'historique (rediriger vers la page client)
const viewHistory = () => {
  if (customerFound.value) {
    // Ouvrir dans un nouvel onglet ou modal
    window.open(`/customers?id=${customerFound.value.id}`, '_blank')
  }
}
</script>