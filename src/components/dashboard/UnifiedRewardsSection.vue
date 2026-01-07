<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-black text-gray-900 dark:text-white">Récompenses & Offres</h1>
        <p class="text-gray-600 dark:text-gray-400 mt-2">Gérez toutes vos récompenses et offres en un seul endroit</p>
      </div>
      <div class="flex gap-2">
        <button
          @click="migrateOldRewards"
          v-if="hasOldRewards"
          class="px-4 py-2 bg-amber-500 text-white rounded-lg hover:bg-amber-600 transition-colors flex items-center gap-2"
        >
          <RefreshCw :size="20" />
          Convertir anciennes récompenses
        </button>
        <button
          @click="showAddModal = true"
          class="px-4 py-2 bg-gradient-to-r from-violet-600 to-purple-600 text-white rounded-lg hover:shadow-lg transition-all duration-200 flex items-center gap-2"
        >
          <Plus :size="20" />
          Créer une offre
        </button>
      </div>
    </div>

    <!-- Statistiques -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Total actif</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ activeCount }}</p>
          </div>
          <Gift :size="24" class="text-violet-600" />
        </div>
      </div>
      
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Anciennes récompenses</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ oldRewardsCount }}</p>
          </div>
          <Archive :size="24" class="text-amber-600" />
        </div>
      </div>
      
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Nouvelles offres</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ newOffersCount }}</p>
          </div>
          <Star :size="24" class="text-green-600" />
        </div>
      </div>
      
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Utilisations totales</p>
            <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ totalUses }}</p>
          </div>
          <TrendingUp :size="24" class="text-blue-600" />
        </div>
      </div>
    </div>

    <!-- Filtres -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
      <div class="flex flex-col md:flex-row gap-4">
        <div class="flex-1">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Rechercher..."
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
          />
        </div>
        <select
          v-model="filterSource"
          class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
        >
          <option value="all">Toutes les sources</option>
          <option value="reward">Anciennes récompenses</option>
          <option value="offer">Nouvelles offres</option>
        </select>
        <select
          v-model="filterStatus"
          class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
        >
          <option value="all">Tous les statuts</option>
          <option value="active">Actives</option>
          <option value="inactive">Inactives</option>
        </select>
      </div>
    </div>

    <!-- Liste unifiée -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="item in filteredItems"
        :key="item.id"
        class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden hover:shadow-lg transition-shadow"
      >
        <!-- En-tête avec badge de source -->
        <div class="relative h-32 bg-gradient-to-br from-violet-500 to-purple-600 p-4">
          <div class="absolute top-3 right-3 flex gap-2">
            <span
              :class="[
                'px-2 py-1 rounded text-xs font-medium',
                item.source_type === 'reward' 
                  ? 'bg-amber-100 text-amber-700' 
                  : 'bg-green-100 text-green-700'
              ]"
            >
              {{ item.source_type === 'reward' ? 'Ancienne' : 'Nouvelle' }}
            </span>
            <button
              @click="toggleItem(item)"
              :class="[
                'px-2 py-1 rounded text-xs font-medium',
                item.is_active 
                  ? 'bg-green-100 text-green-700' 
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300'
              ]"
            >
              {{ item.is_active ? 'Active' : 'Inactive' }}
            </button>
          </div>
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 bg-white dark:bg-gray-800/20 backdrop-blur rounded-xl flex items-center justify-center overflow-hidden">
              <img 
                v-if="item.image_url" 
                :src="item.image_url" 
                alt="Icon" 
                class="w-full h-full object-cover"
              />
              <component v-else :is="getItemIcon(item.type)" :size="24" class="text-white" />
            </div>
            <div>
              <span class="text-white/80 text-xs uppercase tracking-wider">{{ getTypeLabel(item.type) }}</span>
              <h3 class="text-white font-bold text-lg">{{ item.name }}</h3>
            </div>
          </div>
        </div>

        <!-- Corps -->
        <div class="p-4 space-y-3">
          <p class="text-gray-600 dark:text-gray-400 text-sm line-clamp-2">{{ item.description || 'Pas de description' }}</p>
          
          <!-- Points requis -->
          <div class="flex items-center justify-between">
            <span class="text-sm text-gray-500 dark:text-gray-400">Coût en points</span>
            <div class="flex items-center gap-1">
              <Star :size="16" class="text-violet-500" />
              <span class="font-bold text-violet-600">{{ item.points_cost }}</span>
            </div>
          </div>

          <!-- Valeur -->
          <div v-if="item.value" class="flex items-center justify-between">
            <span class="text-sm text-gray-500 dark:text-gray-400">Valeur</span>
            <span class="font-bold">
              {{ item.type === 'discount' ? `-${item.value}%` : item.value_text || `${item.value}€` }}
            </span>
          </div>

          <!-- Utilisations -->
          <div class="flex items-center justify-between">
            <span class="text-sm text-gray-500 dark:text-gray-400">Utilisations</span>
            <span class="text-sm font-medium">{{ item.total_uses || 0 }}</span>
          </div>

          <!-- Actions -->
          <div class="pt-3 flex gap-2 border-t border-gray-100">
            <button
              v-if="item.source_type === 'reward'"
              @click="convertToOffer(item)"
              class="flex-1 px-3 py-2 bg-amber-50 text-amber-600 rounded-lg text-sm hover:bg-amber-100 transition-colors"
            >
              Convertir en offre
            </button>
            <button
              @click="editItem(item)"
              class="flex-1 px-3 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg text-sm hover:bg-gray-200 transition-colors"
            >
              Modifier
            </button>
            <button
              @click="deleteItem(item)"
              class="px-3 py-2 bg-red-50 text-red-600 rounded-lg text-sm hover:bg-red-100 transition-colors"
            >
              <Trash2 :size="16" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Message si vide -->
    <div v-if="filteredItems.length === 0" class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-12 text-center">
      <Gift :size="48" class="mx-auto mb-4 text-gray-300" />
      <p class="text-gray-500 dark:text-gray-400">Aucune récompense ou offre trouvée</p>
      <button
        @click="showAddModal = true"
        class="mt-4 px-4 py-2 bg-violet-600 text-white rounded-lg hover:bg-violet-700 transition-colors"
      >
        Créer votre première offre
      </button>
    </div>

    <!-- Modal d'édition (réutilise OffersSection) -->
    <OffersSection 
      v-if="showAddModal || editingItem"
      :editingOffer="editingItem"
      @close="closeModal"
      @saved="loadItems"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Gift, Plus, Trash2, Star, Archive, TrendingUp, RefreshCw, Percent, Tag, ArrowUp } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'
import OffersSection from './OffersSection.vue'

interface UnifiedItem {
  id: string
  company_id: string
  name: string
  description: string | null
  is_active: boolean
  source_type: 'reward' | 'offer'
  points_cost: number
  type: string
  value?: number
  value_text?: string
  image_url?: string
  total_uses: number
}

const items = ref<UnifiedItem[]>([])
const loading = ref(false)
const searchQuery = ref('')
const filterSource = ref('all')
const filterStatus = ref('all')
const showAddModal = ref(false)
const editingItem = ref<UnifiedItem | null>(null)

const filteredItems = computed(() => {
  return items.value.filter(item => {
    // Filtre par recherche
    if (searchQuery.value && !item.name.toLowerCase().includes(searchQuery.value.toLowerCase())) {
      return false
    }
    
    // Filtre par source
    if (filterSource.value !== 'all' && item.source_type !== filterSource.value) {
      return false
    }
    
    // Filtre par statut
    if (filterStatus.value === 'active' && !item.is_active) return false
    if (filterStatus.value === 'inactive' && item.is_active) return false
    
    return true
  })
})

const hasOldRewards = computed(() => 
  items.value.some(item => item.source_type === 'reward' && item.is_active)
)

const oldRewardsCount = computed(() => 
  items.value.filter(item => item.source_type === 'reward').length
)

const newOffersCount = computed(() => 
  items.value.filter(item => item.source_type === 'offer').length
)

const activeCount = computed(() => 
  items.value.filter(item => item.is_active).length
)

const totalUses = computed(() => 
  items.value.reduce((sum, item) => sum + (item.total_uses || 0), 0)
)

const getItemIcon = (type: string) => {
  const icons: Record<string, any> = {
    discount: Percent,
    gift: Gift,
    points: Star,
    upgrade: ArrowUp,
    product: Gift,
    service: ArrowUp
  }
  return icons[type] || Tag
}

const getTypeLabel = (type: string) => {
  const labels: Record<string, string> = {
    discount: 'Réduction',
    gift: 'Cadeau',
    points: 'Points bonus',
    upgrade: 'Surclassement',
    product: 'Produit',
    service: 'Service'
  }
  return labels[type] || 'Offre'
}

async function loadItems() {
  loading.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    // Charger depuis la vue unifiée
    const { data, error } = await supabase
      .from('unified_rewards')
      .select('*')
      .eq('company_id', user.id)
      .order('created_at', { ascending: false })

    if (!error && data) {
      items.value = data
    }
  } catch (error) {
    console.error('Erreur chargement:', error)
  } finally {
    loading.value = false
  }
}

async function convertToOffer(item: UnifiedItem) {
  if (!confirm(`Convertir "${item.name}" en nouvelle offre ?`)) return
  
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    // Appeler la fonction de migration
    const { data, error } = await supabase.rpc('migrate_reward_to_offer', {
      p_reward_id: item.id
    })

    if (!error) {
      alert('Récompense convertie avec succès!')
      await loadItems()
    }
  } catch (error) {
    console.error('Erreur conversion:', error)
    alert('Erreur lors de la conversion')
  }
}

async function migrateOldRewards() {
  if (!confirm('Convertir toutes les anciennes récompenses actives en nouvelles offres ?')) return
  
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data, error } = await supabase.rpc('migrate_all_company_rewards', {
      p_company_id: user.id
    })

    if (!error) {
      alert(`${data} récompense(s) convertie(s) avec succès!`)
      await loadItems()
    }
  } catch (error) {
    console.error('Erreur migration:', error)
    alert('Erreur lors de la migration')
  }
}

async function toggleItem(item: UnifiedItem) {
  try {
    const table = item.source_type === 'reward' ? 'rewards' : 'offers'
    const { error } = await supabase
      .from(table)
      .update({ is_active: !item.is_active })
      .eq('id', item.id)

    if (!error) {
      item.is_active = !item.is_active
    }
  } catch (error) {
    console.error('Erreur changement statut:', error)
  }
}

function editItem(item: UnifiedItem) {
  if (item.source_type === 'offer') {
    // Éditer directement comme offre
    editingItem.value = item
  } else {
    // Proposer de convertir d'abord
    if (confirm('Pour modifier cette ancienne récompense, elle doit d\'abord être convertie en offre. Continuer ?')) {
      convertToOffer(item)
    }
  }
}

async function deleteItem(item: UnifiedItem) {
  if (!confirm(`Supprimer "${item.name}" ?`)) return
  
  try {
    const table = item.source_type === 'reward' ? 'rewards' : 'offers'
    const { error } = await supabase
      .from(table)
      .delete()
      .eq('id', item.id)

    if (!error) {
      items.value = items.value.filter(i => i.id !== item.id)
    }
  } catch (error) {
    console.error('Erreur suppression:', error)
  }
}

function closeModal() {
  showAddModal.value = false
  editingItem.value = null
}

onMounted(() => {
  loadItems()
})
</script>