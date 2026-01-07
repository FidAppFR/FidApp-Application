<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-3xl font-black text-gray-900 dark:text-white">Objectifs & Milestones</h1>
        <p class="text-gray-600 dark:text-gray-400 mt-2">Définissez et suivez vos objectifs de croissance</p>
      </div>
      <button 
        @click="showCreateModal = true"
        class="bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold px-6 py-3 rounded-full hover:scale-105 transition-all duration-300 shadow-lg flex items-center space-x-2"
      >
        <Plus :size="20" />
        <span>Nouvel objectif</span>
      </button>
    </div>

    <!-- Statistiques rapides -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Objectifs actifs</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ activeCount }}</p>
          </div>
          <Target :size="24" class="text-violet-600" />
        </div>
      </div>
      
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Complétés</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ achievedCount }}</p>
          </div>
          <Trophy :size="24" class="text-green-600" />
        </div>
      </div>
      
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">En cours</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ inProgressCount }}</p>
          </div>
          <TrendingUp :size="24" class="text-blue-600" />
        </div>
      </div>
      
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Taux réussite</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ successRate }}%</p>
          </div>
          <Award :size="24" class="text-amber-600" />
        </div>
      </div>
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="flex justify-center items-center py-12">
      <Loader2 :size="32" class="text-violet-600 animate-spin" />
    </div>

    <!-- Liste des milestones -->
    <div v-else class="space-y-4">
      <!-- Milestones actifs -->
      <div v-if="activeMilestones.length > 0">
        <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-3">Objectifs en cours</h2>
        <div class="grid gap-4">
          <div 
            v-for="milestone in activeMilestones" 
            :key="milestone.id"
            class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6 hover:shadow-lg transition-shadow"
          >
            <div class="flex items-start justify-between mb-4">
              <div class="flex-1">
                <h3 class="font-bold text-lg text-gray-900 dark:text-white">{{ milestone.name }}</h3>
                <p class="text-gray-600 dark:text-gray-400 text-sm mt-1">{{ milestone.description }}</p>
                
                <div class="flex items-center gap-4 mt-3 text-sm">
                  <span class="flex items-center gap-1">
                    <Calendar :size="14" class="text-gray-400" />
                    <span class="text-gray-500 dark:text-gray-400">
                      Du {{ formatDate(milestone.start_date) }}
                      <template v-if="milestone.end_date">
                        au {{ formatDate(milestone.end_date) }}
                      </template>
                    </span>
                  </span>
                  
                  <span :class="[
                    'px-2 py-0.5 rounded-full text-xs font-medium',
                    getTypeColor(milestone.type)
                  ]">
                    {{ getTypeLabel(milestone.type) }}
                  </span>
                </div>
              </div>
              
              <div class="flex gap-2">
                <button 
                  @click="editMilestone(milestone)"
                  class="p-2 text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors"
                >
                  <Edit :size="16" />
                </button>
                <button 
                  @click="deleteMilestone(milestone.id)"
                  class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                >
                  <Trash2 :size="16" />
                </button>
              </div>
            </div>

            <!-- Barre de progression -->
            <div class="space-y-2">
              <div class="flex items-center justify-between text-sm">
                <span class="text-gray-600 dark:text-gray-400">Progression</span>
                <span class="font-bold text-gray-900 dark:text-white">
                  {{ milestone.current_value }} / {{ milestone.target_value }}
                </span>
              </div>
              
              <div class="w-full bg-gray-200 rounded-full h-3 overflow-hidden">
                <div 
                  :class="[
                    'h-full transition-all duration-500',
                    getProgressColor(milestone.current_value / milestone.target_value * 100)
                  ]"
                  :style="{ width: Math.min(100, (milestone.current_value / milestone.target_value * 100)) + '%' }"
                ></div>
              </div>
              
              <div class="flex items-center justify-between">
                <span class="text-xs text-gray-500 dark:text-gray-400">
                  {{ Math.round((milestone.current_value / milestone.target_value) * 100) }}% complété
                </span>
                <span v-if="milestone.reward_description" class="text-xs text-violet-600 font-medium">
                  Récompense : {{ milestone.reward_description }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Milestones complétés -->
      <div v-if="achievedMilestones.length > 0">
        <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-3 flex items-center gap-2">
          Objectifs atteints
          <Trophy :size="20" class="text-green-600" />
        </h2>
        <div class="grid gap-4">
          <div 
            v-for="milestone in achievedMilestones" 
            :key="milestone.id"
            class="bg-green-50 rounded-xl border border-green-200 p-6"
          >
            <div class="flex items-center justify-between">
              <div>
                <h3 class="font-bold text-gray-900 dark:text-white flex items-center gap-2">
                  <CheckCircle :size="20" class="text-green-600" />
                  {{ milestone.name }}
                </h3>
                <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                  Atteint le {{ formatDate(milestone.achieved_at) }}
                </p>
              </div>
              <span class="font-bold text-green-600">
                {{ milestone.target_value }} {{ getTypeUnit(milestone.type) }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Aucun milestone -->
      <div v-if="milestones.length === 0" class="text-center py-12 bg-white dark:bg-gray-800 rounded-xl border-2 border-dashed border-gray-300">
        <Target :size="48" class="mx-auto text-gray-300 mb-4" />
        <p class="text-gray-500 dark:text-gray-400">Aucun objectif défini</p>
        <button 
          @click="showCreateModal = true"
          class="mt-4 px-4 py-2 bg-violet-600 text-white rounded-lg hover:bg-violet-700 transition-colors"
        >
          Créer votre premier objectif
        </button>
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
                {{ editingMilestone ? 'Modifier l\'objectif' : 'Nouvel objectif' }}
              </h2>
              <p class="text-gray-600 dark:text-gray-400 mt-1">
                Définissez un objectif mesurable pour votre entreprise
              </p>
            </div>

            <form @submit.prevent="saveMilestone" class="space-y-6">
              <!-- Nom -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                  Nom de l'objectif *
                </label>
                <input
                  v-model="formData.name"
                  type="text"
                  required
                  class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-700 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                  placeholder="Ex: Atteindre 100 clients"
                />
              </div>

              <!-- Description -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                  Description
                </label>
                <textarea
                  v-model="formData.description"
                  rows="2"
                  class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-700 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                  placeholder="Décrivez votre objectif..."
                ></textarea>
              </div>

              <!-- Type -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                  Type d'objectif *
                </label>
                <select
                  v-model="formData.type"
                  required
                  class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-700 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                >
                  <option value="customer_count">Nombre de clients</option>
                  <option value="points_distributed">Points distribués</option>
                  <option value="rewards_redeemed">Récompenses échangées</option>
                  <option value="monthly_revenue">Revenu mensuel</option>
                  <option value="daily_scans">Scans quotidiens</option>
                  <option value="weekly_active">Clients actifs/semaine</option>
                  <option value="custom">Personnalisé</option>
                </select>
              </div>

              <!-- Valeurs -->
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Valeur cible *
                  </label>
                  <input
                    v-model.number="formData.target_value"
                    type="number"
                    min="1"
                    required
                    class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-700 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                    placeholder="100"
                  />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Valeur actuelle
                  </label>
                  <input
                    v-model.number="formData.current_value"
                    type="number"
                    min="0"
                    class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-700 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                    placeholder="0"
                    :disabled="!editingMilestone"
                  />
                </div>
              </div>

              <!-- Dates -->
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Date de début
                  </label>
                  <input
                    v-model="formData.start_date"
                    type="date"
                    class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-700 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                  />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                    Date de fin (optionnel)
                  </label>
                  <input
                    v-model="formData.end_date"
                    type="date"
                    class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-700 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                  />
                </div>
              </div>

              <!-- Récompense -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                  Récompense à l'atteinte (optionnel)
                </label>
                <input
                  v-model="formData.reward_description"
                  type="text"
                  class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-700 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                  placeholder="Ex: Bonus de 500€"
                />
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
                  class="flex-1 py-3 px-6 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold rounded-xl hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:hover:scale-100"
                >
                  {{ saving ? 'Enregistrement...' : (editingMilestone ? 'Modifier' : 'Créer') }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { 
  Plus, Target, Trophy, TrendingUp, Award, Calendar, Edit, Trash2, 
  Loader2, CheckCircle, Users, Coins, Gift, DollarSign, Activity
} from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

interface Milestone {
  id: string
  company_id: string
  name: string
  description: string | null
  type: string
  target_value: number
  current_value: number
  is_active: boolean
  is_achieved: boolean
  achieved_at: string | null
  start_date: string
  end_date: string | null
  reward_description: string | null
  created_at: string
  updated_at: string
}

const milestones = ref<Milestone[]>([])
const loading = ref(false)
const saving = ref(false)
const showCreateModal = ref(false)
const editingMilestone = ref<Milestone | null>(null)

const formData = ref({
  name: '',
  description: '',
  type: 'customer_count',
  target_value: 100,
  current_value: 0,
  start_date: new Date().toISOString().split('T')[0],
  end_date: '',
  reward_description: ''
})

// Computed
const activeMilestones = computed(() => 
  milestones.value.filter(m => m.is_active && !m.is_achieved)
)

const achievedMilestones = computed(() => 
  milestones.value.filter(m => m.is_achieved)
)

const activeCount = computed(() => 
  milestones.value.filter(m => m.is_active).length
)

const achievedCount = computed(() => 
  achievedMilestones.value.length
)

const inProgressCount = computed(() => 
  activeMilestones.value.length
)

const successRate = computed(() => {
  const total = milestones.value.length
  if (total === 0) return 0
  return Math.round((achievedCount.value / total) * 100)
})

// Méthodes
const loadMilestones = async () => {
  loading.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data, error } = await supabase
      .from('company_milestones')
      .select('*')
      .eq('company_id', user.id)
      .order('created_at', { ascending: false })

    if (!error && data) {
      milestones.value = data
    }
  } catch (error) {
    console.error('Erreur chargement milestones:', error)
  } finally {
    loading.value = false
  }
}

const saveMilestone = async () => {
  saving.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const milestoneData = {
      company_id: user.id,
      name: formData.value.name,
      description: formData.value.description || null,
      type: formData.value.type,
      target_value: formData.value.target_value,
      current_value: formData.value.current_value || 0,
      start_date: formData.value.start_date,
      end_date: formData.value.end_date || null,
      reward_description: formData.value.reward_description || null,
      is_active: true
    }

    if (editingMilestone.value) {
      const { error } = await supabase
        .from('company_milestones')
        .update(milestoneData)
        .eq('id', editingMilestone.value.id)

      if (!error) {
        await loadMilestones()
        closeModal()
      }
    } else {
      const { error } = await supabase
        .from('company_milestones')
        .insert(milestoneData)

      if (!error) {
        await loadMilestones()
        closeModal()
      }
    }
  } catch (error) {
    console.error('Erreur sauvegarde milestone:', error)
  } finally {
    saving.value = false
  }
}

const editMilestone = (milestone: Milestone) => {
  editingMilestone.value = milestone
  formData.value = {
    name: milestone.name,
    description: milestone.description || '',
    type: milestone.type,
    target_value: milestone.target_value,
    current_value: milestone.current_value,
    start_date: milestone.start_date,
    end_date: milestone.end_date || '',
    reward_description: milestone.reward_description || ''
  }
  showCreateModal.value = true
}

const deleteMilestone = async (id: string) => {
  if (!confirm('Êtes-vous sûr de vouloir supprimer cet objectif ?')) return

  try {
    const { error } = await supabase
      .from('company_milestones')
      .delete()
      .eq('id', id)

    if (!error) {
      await loadMilestones()
    }
  } catch (error) {
    console.error('Erreur suppression milestone:', error)
  }
}

const closeModal = () => {
  showCreateModal.value = false
  editingMilestone.value = null
  formData.value = {
    name: '',
    description: '',
    type: 'customer_count',
    target_value: 100,
    current_value: 0,
    start_date: new Date().toISOString().split('T')[0],
    end_date: '',
    reward_description: ''
  }
}

const formatDate = (date: string | null) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('fr-FR')
}

const getTypeLabel = (type: string) => {
  const labels: Record<string, string> = {
    customer_count: 'Clients',
    points_distributed: 'Points',
    rewards_redeemed: 'Récompenses',
    monthly_revenue: 'Revenu',
    daily_scans: 'Scans/jour',
    weekly_active: 'Actifs/semaine',
    custom: 'Personnalisé'
  }
  return labels[type] || type
}

const getTypeUnit = (type: string) => {
  const units: Record<string, string> = {
    customer_count: 'clients',
    points_distributed: 'points',
    rewards_redeemed: 'échanges',
    monthly_revenue: '€',
    daily_scans: 'scans',
    weekly_active: 'actifs',
    custom: ''
  }
  return units[type] || ''
}

const getTypeColor = (type: string) => {
  const colors: Record<string, string> = {
    customer_count: 'bg-green-100 text-green-700',
    points_distributed: 'bg-blue-100 text-blue-700',
    rewards_redeemed: 'bg-pink-100 text-pink-700',
    monthly_revenue: 'bg-amber-100 text-amber-700',
    daily_scans: 'bg-purple-100 text-purple-700',
    weekly_active: 'bg-indigo-100 text-indigo-700',
    custom: 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300'
  }
  return colors[type] || 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300'
}

const getProgressColor = (percentage: number) => {
  if (percentage >= 100) return 'bg-green-500'
  if (percentage >= 75) return 'bg-blue-500'
  if (percentage >= 50) return 'bg-yellow-500'
  if (percentage >= 25) return 'bg-orange-500'
  return 'bg-red-500'
}

onMounted(() => {
  loadMilestones()
})
</script>