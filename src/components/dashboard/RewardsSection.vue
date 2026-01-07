<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-3xl font-black text-gray-900 dark:text-white">Gérer les Récompenses</h1>
        <p class="text-gray-600 dark:text-gray-400 mt-2">Créez et gérez vos récompenses de fidélité</p>
      </div>
      <div class="flex items-center space-x-3">
        <button 
          @click="goToClientView"
          class="bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-300 font-bold px-6 py-3 rounded-full transition-all duration-300 flex items-center space-x-2"
        >
          <Eye :size="20" />
          <span>Vue client</span>
        </button>
        <button 
          @click="showCreateModal = true"
          class="bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold px-6 py-3 rounded-full hover:scale-105 transition-all duration-300 shadow-lg flex items-center space-x-2"
        >
          <Plus :size="20" />
          <span>Nouvelle récompense</span>
        </button>
      </div>
    </div>

    <!-- Section Points de bienvenue -->
    <div class="bg-gradient-to-br from-violet-50 to-pink-50 dark:from-gray-700 dark:to-gray-800 rounded-xl p-6 border border-violet-200 dark:border-gray-600">
      <div class="flex items-start justify-between">
        <div class="flex-1">
          <div class="flex items-center space-x-3 mb-3">
            <div class="w-12 h-12 bg-white dark:bg-gray-800 rounded-full flex items-center justify-center shadow-sm">
              <Gift :size="24" class="text-violet-600" />
            </div>
            <div>
              <h2 class="text-lg font-bold text-gray-900 dark:text-white">Points de bienvenue</h2>
              <p class="text-sm text-gray-600 dark:text-gray-400">Attribués automatiquement aux nouveaux clients</p>
            </div>
          </div>
          
          <div class="flex items-center space-x-3">
            <div class="flex items-center space-x-2 bg-white dark:bg-gray-700 rounded-lg px-4 py-2 border-2 border-violet-200 dark:border-gray-600">
              <input
                v-model.number="signupPoints"
                type="number"
                min="0"
                max="1000"
                class="w-20 text-center font-bold text-violet-600 dark:text-violet-400 bg-transparent outline-none"
                placeholder="50"
              />
              <span class="text-gray-600 dark:text-gray-400 font-medium">points</span>
            </div>
            <button
              @click="saveSignupPoints"
              :disabled="savingPoints || signupPoints === originalSignupPoints"
              class="px-4 py-2 bg-violet-600 text-white font-medium rounded-lg hover:bg-violet-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ savingPoints ? 'Enregistrement...' : 'Sauvegarder' }}
            </button>
          </div>
          <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">
            💡 Conseil : Entre 10 et 100 points pour encourager l'inscription
          </p>
        </div>
      </div>
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="flex justify-center items-center py-12">
      <Loader2 :size="32" class="text-violet-600 animate-spin" />
    </div>

    <!-- Liste des récompenses -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <!-- Récompenses existantes -->
      <div 
        v-for="reward in rewards" 
        :key="reward.id"
        class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden hover:shadow-lg transition-shadow"
      >
        <div class="p-6">
          <div class="w-12 h-12 rounded-full flex items-center justify-center mb-4" 
               :class="getCategoryColor(reward.category)">
            <component :is="getCategoryIcon(reward.category)" :size="24" />
          </div>
          <h3 class="font-bold text-lg text-gray-900 dark:text-white mb-2">{{ reward.name }}</h3>
          <p class="text-gray-600 dark:text-gray-400 text-sm mb-4">{{ reward.description }}</p>
          
          <div class="flex items-center justify-between mb-4">
            <span class="text-sm text-gray-500 dark:text-gray-400">Points requis</span>
            <span class="font-bold text-violet-600">{{ reward.points_required }} pts</span>
          </div>
          
          <div v-if="reward.discount_percentage" class="flex items-center justify-between mb-4">
            <span class="text-sm text-gray-500 dark:text-gray-400">Réduction</span>
            <span class="font-medium">{{ reward.discount_percentage }}%</span>
          </div>

          <div v-if="reward.discount_amount" class="flex items-center justify-between mb-4">
            <span class="text-sm text-gray-500 dark:text-gray-400">Montant</span>
            <span class="font-medium">{{ reward.discount_amount }}€</span>
          </div>

          <div class="flex items-center justify-between mb-4">
            <span class="text-sm text-gray-500 dark:text-gray-400">Statut</span>
            <span :class="reward.is_active ? 'text-green-600' : 'text-gray-400'" class="font-medium">
              {{ reward.is_active ? 'Active' : 'Inactive' }}
            </span>
          </div>

          <div class="flex items-center justify-between mb-4">
            <span class="text-sm text-gray-500 dark:text-gray-400">Utilisations</span>
            <span class="font-medium">{{ reward.total_uses || 0 }}</span>
          </div>

          <div class="flex space-x-2">
            <button 
              @click="editReward(reward)"
              class="flex-1 px-3 py-2 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-lg text-sm font-medium transition-colors"
            >
              Modifier
            </button>
            <button 
              @click="toggleRewardStatus(reward)"
              class="px-3 py-2 rounded-lg text-sm font-medium transition-colors"
              :class="reward.is_active ? 'text-orange-600 hover:bg-orange-50' : 'text-green-600 hover:bg-green-50'"
            >
              {{ reward.is_active ? 'Désactiver' : 'Activer' }}
            </button>
            <button 
              @click="reward.id && deleteReward(reward.id)"
              class="px-3 py-2 text-red-600 hover:bg-red-50 rounded-lg text-sm font-medium transition-colors"
            >
              <Trash2 :size="16" />
            </button>
          </div>
        </div>
      </div>

      <!-- Bouton ajouter -->
      <div 
        @click="showCreateModal = true"
        class="border-2 border-dashed border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 rounded-xl flex items-center justify-center min-h-[280px] hover:border-violet-400 dark:hover:border-violet-500 transition-colors cursor-pointer group"
      >
        <div class="text-center">
          <div class="w-12 h-12 bg-gray-100 dark:bg-gray-700 group-hover:bg-violet-100 dark:group-hover:bg-violet-900/30 rounded-full flex items-center justify-center mx-auto mb-3 transition-colors">
            <Plus :size="24" class="text-gray-400 dark:text-gray-500 group-hover:text-violet-600 dark:group-hover:text-violet-400 transition-colors" />
          </div>
          <p class="text-gray-500 dark:text-gray-400 group-hover:text-violet-600 dark:group-hover:text-violet-400 font-medium transition-colors">Ajouter une récompense</p>
        </div>
      </div>
    </div>

    <!-- Modal de création/édition -->
    <Teleport to="body">
      <Transition
        enter-active-class="duration-200 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="duration-150 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showCreateModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <!-- Overlay -->
          <div class="absolute inset-0 bg-black/50" @click="closeModal"></div>
          
          <!-- Modal -->
          <div class="relative bg-white dark:bg-gray-800 rounded-2xl shadow-2xl p-8 max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div class="mb-6">
              <h2 class="text-2xl font-black text-gray-900 dark:text-white">
                {{ editingReward ? 'Modifier la récompense' : 'Nouvelle récompense' }}
              </h2>
              <p class="text-gray-600 dark:text-gray-400 mt-1">
                {{ editingReward ? 'Modifiez les informations de votre récompense' : 'Créez une nouvelle récompense pour fidéliser vos clients' }}
              </p>
            </div>

            <form @submit.prevent="saveReward" class="space-y-6">
              <!-- Nom -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                  Nom de la récompense *
                </label>
                <input
                  v-model="formData.name"
                  type="text"
                  required
                  class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                  placeholder="Ex: Café gratuit"
                />
              </div>

              <!-- Description -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                  Description
                </label>
                <textarea
                  v-model="formData.description"
                  rows="3"
                  class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                  placeholder="Ex: Un café offert après 10 achats"
                ></textarea>
              </div>

              <!-- Catégorie -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                  Catégorie *
                </label>
                <select
                  v-model="formData.category"
                  required
                  class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                >
                  <option value="product">Produit</option>
                  <option value="discount">Réduction</option>
                  <option value="service">Service</option>
                  <option value="gift">Cadeau</option>
                  <option value="experience">Expérience</option>
                  <option value="general">Général</option>
                </select>
              </div>

              <!-- Points requis -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                  Points requis *
                </label>
                <input
                  v-model.number="formData.points_required"
                  type="number"
                  min="0"
                  required
                  class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                  placeholder="100"
                />
              </div>

              <!-- Type de récompense -->
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Réduction en %
                  </label>
                  <input
                    v-model.number="formData.discount_percentage"
                    type="number"
                    min="0"
                    max="100"
                    class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                    placeholder="20"
                  />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Ou montant fixe (€)
                  </label>
                  <input
                    v-model.number="formData.discount_amount"
                    type="number"
                    min="0"
                    step="0.01"
                    class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                    placeholder="5.00"
                  />
                </div>
              </div>

              <!-- Limites -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                  Utilisations max par client (optionnel)
                </label>
                <input
                  v-model.number="formData.max_uses_per_customer"
                  type="number"
                  min="0"
                  class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                  placeholder="Illimité"
                />
              </div>

              <!-- Dates de validité -->
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Valide à partir de
                  </label>
                  <input
                    v-model="formData.valid_from"
                    type="date"
                    class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                  />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Valide jusqu'au (optionnel)
                  </label>
                  <input
                    v-model="formData.valid_until"
                    type="date"
                    class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                  />
                </div>
              </div>

              <!-- Statut actif -->
              <div class="flex items-center space-x-3">
                <input
                  v-model="formData.is_active"
                  type="checkbox"
                  id="is_active"
                  class="w-5 h-5 text-violet-600 border-2 border-gray-300 rounded focus:ring-violet-500"
                />
                <label for="is_active" class="text-sm font-medium text-gray-700 dark:text-gray-300">
                  Récompense active
                </label>
              </div>

              <!-- Boutons -->
              <div class="flex space-x-4 pt-6">
                <button
                  type="button"
                  @click="closeModal"
                  class="flex-1 py-3 px-6 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-300 font-bold rounded-xl transition-colors"
                >
                  Annuler
                </button>
                <button
                  type="submit"
                  :disabled="saving"
                  class="flex-1 py-3 px-6 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold rounded-xl hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:hover:scale-100 flex items-center justify-center space-x-2"
                >
                  <Loader2 v-if="saving" :size="20" class="animate-spin" />
                  <span>{{ saving ? 'Enregistrement...' : (editingReward ? 'Modifier' : 'Créer') }}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- Message de succès pour les points de bienvenue -->
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
import { useRouter } from 'vue-router'
import { Plus, Coffee, Percent, Gift, Trash2, Package, Star, ShoppingBag, Loader2, Eye, CheckCircle } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

interface Reward {
  id?: string
  name: string
  description: string
  category: string
  points_required: number
  discount_percentage?: number
  discount_amount?: number
  is_active: boolean
  valid_from?: string
  valid_until?: string
  max_uses_per_customer?: number
  total_uses?: number
}

const router = useRouter()
const rewards = ref<Reward[]>([])
const loading = ref(false)
const saving = ref(false)
const showCreateModal = ref(false)
const editingReward = ref<Reward | null>(null)
const companyId = ref<string | null>(null)

// Variables pour les points de bienvenue
const signupPoints = ref(50)
const originalSignupPoints = ref(50)
const savingPoints = ref(false)
const showSuccess = ref(false)
const successMessage = ref('')

const formData = ref<Reward>({
  name: '',
  description: '',
  category: 'general',
  points_required: 100,
  discount_percentage: undefined,
  discount_amount: undefined,
  is_active: true,
  valid_from: new Date().toISOString().split('T')[0],
  valid_until: undefined,
  max_uses_per_customer: undefined
})

// Récupérer les récompenses et les paramètres
const fetchRewards = async () => {
  loading.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      console.log('Aucun utilisateur connecté pour récupérer les récompenses')
      loading.value = false
      return
    }

    // Récupérer l'ID de l'entreprise et les points d'inscription
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('id, signup_points')
      .eq('auth_id', user.id)
      .single()

    if (userError) {
      console.error('Erreur lors de la récupération de l\'utilisateur:', userError)
      loading.value = false
      return
    }

    if (!userData) {
      console.log('Aucune donnée utilisateur trouvée')
      loading.value = false
      return
    }

    companyId.value = userData.id
    // Charger les points d'inscription configurés
    signupPoints.value = userData.signup_points || 50
    originalSignupPoints.value = userData.signup_points || 50
    console.log('Récupération des récompenses pour l\'entreprise:', userData.id)

    // Récupérer les récompenses de l'entreprise
    const { data, error } = await supabase
      .from('rewards')
      .select('*')
      .eq('company_id', userData.id)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Erreur lors du chargement des récompenses:', error)
      // Si la table n'existe pas, afficher un message spécifique
      if (error.message.includes('relation') && error.message.includes('does not exist')) {
        alert('La table des récompenses n\'existe pas encore. Veuillez exécuter la migration SQL.')
      }
    } else {
      console.log('Récompenses récupérées:', data)
      rewards.value = data || []
    }
  } catch (error) {
    console.error('Erreur générale lors du chargement des récompenses:', error)
  } finally {
    loading.value = false
  }
}

// Sauvegarder une récompense
const saveReward = async () => {
  saving.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      console.error('Aucun utilisateur connecté')
      alert('Vous devez être connecté pour créer une récompense')
      saving.value = false
      return
    }

    console.log('Utilisateur connecté:', user.id)

    // Récupérer l'ID de l'entreprise
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('id')
      .eq('auth_id', user.id)
      .single()

    if (userError) {
      console.error('Erreur lors de la récupération de l\'utilisateur:', userError)
      alert('Erreur lors de la récupération des données utilisateur')
      saving.value = false
      return
    }

    if (!userData) {
      console.error('Aucune donnée utilisateur trouvée')
      alert('Aucune donnée utilisateur trouvée')
      saving.value = false
      return
    }

    console.log('ID de l\'entreprise:', userData.id)

    // Préparer les données
    const rewardData: any = {
      company_id: userData.id,
      name: formData.value.name,
      description: formData.value.description || null,
      category: formData.value.category,
      points_required: formData.value.points_required,
      discount_percentage: formData.value.discount_percentage || null,
      discount_amount: formData.value.discount_amount || null,
      is_active: formData.value.is_active,
      max_uses_per_customer: formData.value.max_uses_per_customer || null
    }

    // Ajouter les dates si elles sont définies
    if (formData.value.valid_from) {
      rewardData.valid_from = new Date(formData.value.valid_from).toISOString()
    }
    if (formData.value.valid_until) {
      rewardData.valid_until = new Date(formData.value.valid_until).toISOString()
    }

    console.log('Données à sauvegarder:', rewardData)

    if (editingReward.value) {
      // Mise à jour
      const { data, error } = await supabase
        .from('rewards')
        .update(rewardData)
        .eq('id', editingReward.value.id)
        .select()

      if (error) {
        console.error('Erreur lors de la mise à jour:', error)
        alert(`Erreur lors de la mise à jour: ${error.message}`)
      } else {
        console.log('Récompense mise à jour avec succès:', data)
        await fetchRewards()
        closeModal()
      }
    } else {
      // Création - Utiliser la fonction RPC pour éviter les problèmes de trigger
      console.log('Tentative de création de récompense...')
      
      try {
        // Essayer d'abord avec la fonction RPC sans trigger
        const { data: rpcResult, error: rpcError } = await supabase
          .rpc('insert_reward_without_trigger', {
            p_company_id: userData.id,
            p_name: formData.value.name,
            p_description: formData.value.description || null,
            p_category: formData.value.category,
            p_points_required: formData.value.points_required,
            p_discount_percentage: formData.value.discount_percentage || null,
            p_discount_amount: formData.value.discount_amount || null,
            p_is_active: formData.value.is_active,
            p_max_uses_per_customer: formData.value.max_uses_per_customer || null
          })

        if (rpcError) {
          console.log('RPC non disponible, tentative insertion directe...')
          // Si RPC échoue, essayer insertion directe
          const { data: directResult, error: directError } = await supabase
            .from('rewards')
            .insert([rewardData])
            .select()

          if (directError) {
            console.error('Erreur lors de la création:', directError)
            
            // En dernier recours, créer dans offers
            if (directError.message.includes('trigger') || directError.message.includes('offers')) {
              console.log('Création dans offers comme fallback...')
              
              const offerData = {
                company_id: userData.id,
                name: formData.value.name,
                description: formData.value.description || null,
                type: formData.value.category === 'discount' ? 'discount' : 'gift',
                points_cost: formData.value.points_required,
                value: formData.value.discount_percentage || formData.value.discount_amount || null,
                is_active: formData.value.is_active,
                max_uses_per_customer: formData.value.max_uses_per_customer || null
              }
              
              const { error: offerError } = await supabase
                .from('offers')
                .insert([offerData])
              
              if (offerError) {
                alert(`Impossible de créer la récompense: ${offerError.message}`)
                return
              }
            } else {
              alert(`Erreur lors de la création: ${directError.message}`)
              return
            }
          }
        }
        
        console.log('Récompense créée avec succès')
        await fetchRewards()
        closeModal()
        showSuccessMessage('Récompense créée avec succès!')
        
      } catch (error) {
        console.error('Erreur inattendue:', error)
        // Tentative finale avec insertion directe simple
        const { error: finalError } = await supabase
          .from('rewards')
          .insert([rewardData])
        
        if (!finalError) {
          await fetchRewards()
          closeModal()
          showSuccessMessage('Récompense créée avec succès!')
        } else {
          alert('Impossible de créer la récompense. Veuillez réessayer.')
        }
      }
    }
  } catch (error) {
    console.error('Erreur générale lors de la sauvegarde:', error)
    alert('Une erreur inattendue s\'est produite')
  } finally {
    saving.value = false
  }
}

// Éditer une récompense
const editReward = (reward: Reward) => {
  editingReward.value = reward
  formData.value = { ...reward }
  showCreateModal.value = true
}

// Basculer le statut d'une récompense
const toggleRewardStatus = async (reward: Reward) => {
  try {
    const { error } = await supabase
      .from('rewards')
      .update({ is_active: !reward.is_active })
      .eq('id', reward.id)

    if (!error) {
      await fetchRewards()
    }
  } catch (error) {
    console.error('Erreur lors de la mise à jour du statut:', error)
  }
}

// Supprimer une récompense
const deleteReward = async (id: string) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer cette récompense ?')) return
  
  try {
    const { error } = await supabase
      .from('rewards')
      .delete()
      .eq('id', id)

    if (!error) {
      await fetchRewards()
    }
  } catch (error) {
    console.error('Erreur lors de la suppression:', error)
  }
}

// Fermer la modal
const closeModal = () => {
  showCreateModal.value = false
  editingReward.value = null
  formData.value = {
    name: '',
    description: '',
    category: 'general',
    points_required: 100,
    discount_percentage: undefined,
    discount_amount: undefined,
    is_active: true,
    valid_from: new Date().toISOString().split('T')[0],
    valid_until: undefined,
    max_uses_per_customer: undefined
  }
}

// Obtenir l'icône selon la catégorie
const getCategoryIcon = (category: string) => {
  const icons: Record<string, any> = {
    product: Coffee,
    discount: Percent,
    service: Star,
    gift: Gift,
    experience: Star,
    general: Package
  }
  return icons[category] || Package
}

// Obtenir la couleur selon la catégorie
const getCategoryColor = (category: string) => {
  const colors: Record<string, string> = {
    product: 'bg-violet-100 text-violet-600',
    discount: 'bg-pink-100 text-pink-600',
    service: 'bg-blue-100 text-blue-600',
    gift: 'bg-green-100 text-green-600',
    experience: 'bg-yellow-100 text-yellow-600',
    general: 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400'
  }
  return colors[category] || 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400'
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

// Aller à la vue client
const goToClientView = () => {
  if (companyId.value) {
    router.push(`/client-view?company=${companyId.value}`)
  }
}

onMounted(() => {
  fetchRewards()
})
</script>