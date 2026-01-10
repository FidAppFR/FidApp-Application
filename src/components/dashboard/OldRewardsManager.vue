<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-3xl font-black text-gray-900 dark:text-white">Gestionnaire d'anciennes récompenses</h1>
      <p class="text-gray-600 dark:text-gray-400 mt-2">Visualisez et supprimez vos anciennes récompenses créées</p>
    </div>

    <!-- Bouton de rechargement -->
    <div class="flex justify-end">
      <button
        @click="loadRewards"
        :disabled="loading"
        class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2"
      >
        <RefreshCw :size="20" :class="loading ? 'animate-spin' : ''" />
        Rafraîchir
      </button>
    </div>

    <!-- Statistiques -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Total récompenses</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ rewards.length }}</p>
          </div>
          <Archive :size="24" class="text-violet-600" />
        </div>
      </div>
      
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Actives</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ activeCount }}</p>
          </div>
          <CheckCircle :size="24" class="text-green-600" />
        </div>
      </div>
      
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Inactives</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ inactiveCount }}</p>
          </div>
          <XCircle :size="24" class="text-red-600" />
        </div>
      </div>
    </div>

    <!-- Liste des récompenses -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-200">
      <div class="p-6 border-b border-gray-200">
        <h2 class="text-lg font-bold text-gray-900">Liste complète des anciennes récompenses</h2>
      </div>
      
      <div v-if="loading" class="p-8 text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-violet-600 mx-auto"></div>
      </div>
      
      <div v-else-if="rewards.length === 0" class="p-8 text-center text-gray-500">
        <Archive :size="48" class="mx-auto mb-4 text-gray-300" />
        <p>Aucune ancienne récompense trouvée</p>
      </div>
      
      <div v-else class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Nom
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Description
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Points requis
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Catégorie
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Statut
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Créée le
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="reward in rewards" :key="reward.id" class="hover:bg-gray-50 dark:hover:bg-gray-700">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="text-sm font-medium text-gray-900">{{ reward.name }}</div>
              </td>
              <td class="px-6 py-4">
                <div class="text-sm text-gray-500">{{ reward.description || '-' }}</div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center gap-1">
                  <Star :size="14" class="text-violet-500" />
                  <span class="text-sm font-medium">{{ reward.points_required }}</span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">
                  {{ reward.category }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span :class="[
                  'px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full',
                  reward.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                ]">
                  {{ reward.is_active ? 'Active' : 'Inactive' }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(reward.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div class="flex gap-2">
                  <button
                    @click="toggleStatus(reward)"
                    :class="[
                      'px-3 py-1 rounded text-xs font-medium transition-colors',
                      reward.is_active 
                        ? 'bg-amber-100 text-amber-700 hover:bg-amber-200' 
                        : 'bg-green-100 text-green-700 hover:bg-green-200'
                    ]"
                  >
                    {{ reward.is_active ? 'Désactiver' : 'Activer' }}
                  </button>
                  <button
                    @click="deleteReward(reward)"
                    class="px-3 py-1 bg-red-100 text-red-600 rounded hover:bg-red-200 transition-colors text-xs font-medium"
                  >
                    Supprimer
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Actions globales -->
    <div class="bg-amber-50 border border-amber-200 rounded-xl p-6">
      <h3 class="font-bold text-amber-900 mb-2">Actions de masse</h3>
      <div class="flex gap-3">
        <button
          @click="deactivateAll"
          :disabled="activeCount === 0"
          class="px-4 py-2 bg-amber-600 text-white rounded-lg hover:bg-amber-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Désactiver toutes les actives
        </button>
        <button
          @click="deleteInactive"
          :disabled="inactiveCount === 0"
          class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Supprimer toutes les inactives
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Archive, CheckCircle, XCircle, RefreshCw, Star, Trash2 } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

interface Reward {
  id: string
  name: string
  description: string | null
  points_required: number
  category: string
  is_active: boolean
  created_at: string
  total_uses: number
}

const rewards = ref<Reward[]>([])
const loading = ref(false)

const activeCount = computed(() => 
  rewards.value.filter(r => r.is_active).length
)

const inactiveCount = computed(() => 
  rewards.value.filter(r => !r.is_active).length
)

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

async function loadRewards() {
  loading.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      alert('Vous devez être connecté')
      return
    }

    // Récupérer l'ID de l'entreprise
    const { data: userData } = await supabase
      .from('users')
      .select('id')
      .eq('auth_id', user.id)
      .single()

    if (!userData) {
      alert('Impossible de récupérer vos données')
      return
    }

    // Charger les récompenses
    const { data, error } = await supabase
      .from('rewards')
      .select('*')
      .eq('company_id', userData.id)
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Erreur:', error)
      alert('Erreur lors du chargement des récompenses')
    } else {
      rewards.value = data || []
      console.log(`${rewards.value.length} récompenses trouvées`)
    }
  } catch (error) {
    console.error('Erreur:', error)
    alert('Erreur lors du chargement')
  } finally {
    loading.value = false
  }
}

async function toggleStatus(reward: Reward) {
  try {
    const { error } = await supabase
      .from('rewards')
      .update({ is_active: !reward.is_active })
      .eq('id', reward.id)

    if (error) {
      alert('Erreur lors de la modification')
    } else {
      reward.is_active = !reward.is_active
    }
  } catch (error) {
    console.error('Erreur:', error)
  }
}

async function deleteReward(reward: Reward) {
  if (!confirm(`Êtes-vous sûr de vouloir supprimer "${reward.name}" ? Cette action est irréversible.`)) {
    return
  }

  try {
    const { error } = await supabase
      .from('rewards')
      .delete()
      .eq('id', reward.id)

    if (error) {
      alert('Erreur lors de la suppression')
    } else {
      rewards.value = rewards.value.filter(r => r.id !== reward.id)
      alert('Récompense supprimée avec succès')
    }
  } catch (error) {
    console.error('Erreur:', error)
  }
}

async function deactivateAll() {
  if (!confirm('Désactiver toutes les récompenses actives ?')) return

  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data: userData } = await supabase
      .from('users')
      .select('id')
      .eq('auth_id', user.id)
      .single()

    if (!userData) return

    const { error } = await supabase
      .from('rewards')
      .update({ is_active: false })
      .eq('company_id', userData.id)
      .eq('is_active', true)

    if (!error) {
      await loadRewards()
      alert('Toutes les récompenses ont été désactivées')
    }
  } catch (error) {
    console.error('Erreur:', error)
  }
}

async function deleteInactive() {
  if (!confirm('Supprimer TOUTES les récompenses inactives ? Cette action est IRRÉVERSIBLE.')) return

  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data: userData } = await supabase
      .from('users')
      .select('id')
      .eq('auth_id', user.id)
      .single()

    if (!userData) return

    const { error } = await supabase
      .from('rewards')
      .delete()
      .eq('company_id', userData.id)
      .eq('is_active', false)

    if (!error) {
      await loadRewards()
      alert('Toutes les récompenses inactives ont été supprimées')
    }
  } catch (error) {
    console.error('Erreur:', error)
  }
}

onMounted(() => {
  loadRewards()
})
</script>