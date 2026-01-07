<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-3xl font-black text-gray-900 dark:text-white">Points de Bienvenue</h1>
      <p class="text-gray-600 dark:text-gray-400 mt-2">Configurez les points offerts aux nouveaux clients</p>
    </div>

    <!-- Carte de configuration -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
      <div class="flex items-start justify-between mb-6">
        <div class="flex items-center gap-3">
          <div class="w-12 h-12 bg-gradient-to-br from-violet-500 to-purple-600 rounded-xl flex items-center justify-center">
            <Gift :size="24" class="text-white" />
          </div>
          <div>
            <h2 class="text-xl font-bold text-gray-900 dark:text-white">Configuration des Points de Bienvenue</h2>
            <p class="text-sm text-gray-600 dark:text-gray-400">Offrez automatiquement des points aux nouveaux inscrits</p>
          </div>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600 dark:text-gray-400">Activé</span>
          <button
            @click="toggleWelcomeBonus"
            :class="[
              'relative inline-flex h-6 w-11 items-center rounded-full transition-colors',
              settings.welcome_enabled ? 'bg-violet-600' : 'bg-gray-300'
            ]"
          >
            <span
              :class="[
                'inline-block h-4 w-4 transform rounded-full bg-white dark:bg-gray-800 transition-transform',
                settings.welcome_enabled ? 'translate-x-6' : 'translate-x-1'
              ]"
            />
          </button>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Nombre de points -->
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Nombre de points offerts
          </label>
          <div class="flex items-center gap-2">
            <input
              v-model.number="settings.welcome_points"
              type="number"
              min="0"
              class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
              :disabled="!settings.welcome_enabled"
            />
            <div class="flex items-center gap-1 px-3 py-2 bg-amber-50 rounded-lg">
              <Star :size="20" class="text-amber-500" />
              <span class="font-semibold text-amber-700">pts</span>
            </div>
          </div>
        </div>

        <!-- Message de bienvenue -->
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Message de bienvenue
          </label>
          <input
            v-model="settings.welcome_message"
            type="text"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
            :disabled="!settings.welcome_enabled"
            placeholder="Ex: Bienvenue dans notre programme !"
          />
        </div>
      </div>

      <!-- Conditions -->
      <div class="mt-6">
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Conditions d'attribution (optionnel)
        </label>
        <textarea
          v-model="settings.welcome_conditions"
          rows="3"
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
          :disabled="!settings.welcome_enabled"
          placeholder="Ex: Valide après première visite, nécessite vérification email..."
        ></textarea>
      </div>

      <!-- Bouton de sauvegarde -->
      <div class="mt-6 flex justify-end">
        <button
          @click="saveSettings"
          :disabled="saving"
          class="px-6 py-2 bg-gradient-to-r from-violet-600 to-purple-600 text-white rounded-lg hover:shadow-lg transition-all duration-200 disabled:opacity-50"
        >
          {{ saving ? 'Enregistrement...' : 'Enregistrer les modifications' }}
        </button>
      </div>
    </div>

    <!-- Statistiques -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Bonus distribués</p>
            <p class="text-3xl font-bold text-gray-900 dark:text-white mt-2">{{ stats.totalApplied }}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">Depuis le début</p>
          </div>
          <UserPlus :size="24" class="text-violet-600" />
        </div>
      </div>

      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Points totaux</p>
            <p class="text-3xl font-bold text-gray-900 dark:text-white mt-2">{{ stats.totalPoints.toLocaleString() }}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">Points offerts</p>
          </div>
          <Star :size="24" class="text-amber-500" />
        </div>
      </div>

      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Ce mois</p>
            <p class="text-3xl font-bold text-gray-900 dark:text-white mt-2">{{ stats.thisMonth }}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">Nouveaux inscrits</p>
          </div>
          <Calendar :size="24" class="text-green-600" />
        </div>
      </div>
    </div>

    <!-- Liste des derniers bonus appliqués -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700">
      <div class="p-6 border-b border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white">Derniers bonus de bienvenue appliqués</h3>
      </div>
      
      <div v-if="recentBonuses.length === 0" class="p-8 text-center text-gray-500 dark:text-gray-400">
        <Gift :size="48" class="mx-auto mb-4 text-gray-300" />
        <p>Aucun bonus de bienvenue appliqué récemment</p>
      </div>
      
      <div v-else class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 dark:bg-gray-900">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Client</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Points offerts</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Date</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-400 uppercase">Appliqué par</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="bonus in recentBonuses" :key="bonus.id" class="hover:bg-gray-50 dark:bg-gray-900">
              <td class="px-6 py-4">
                <div class="flex items-center gap-2">
                  <div class="w-8 h-8 bg-gradient-to-br from-violet-400 to-purple-500 rounded-full flex items-center justify-center text-white text-xs font-bold">
                    {{ getInitials(bonus.customer_name) }}
                  </div>
                  <div>
                    <p class="text-sm font-medium text-gray-900 dark:text-white">{{ bonus.customer_name }}</p>
                    <p class="text-xs text-gray-500 dark:text-gray-400">{{ bonus.customer_email }}</p>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4">
                <div class="flex items-center gap-1">
                  <Star :size="16" class="text-amber-500" />
                  <span class="font-semibold text-gray-900 dark:text-white">{{ bonus.points_awarded }}</span>
                </div>
              </td>
              <td class="px-6 py-4 text-sm text-gray-600 dark:text-gray-400">
                {{ formatDate(bonus.applied_at) }}
              </td>
              <td class="px-6 py-4 text-sm text-gray-600 dark:text-gray-400">
                {{ bonus.applied_by_name || 'Système' }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Gift, Star, UserPlus, Calendar } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

interface BonusSettings {
  welcome_enabled: boolean
  welcome_points: number
  welcome_message: string
  welcome_conditions: string
}

const settings = ref<BonusSettings>({
  welcome_enabled: true,
  welcome_points: 50,
  welcome_message: 'Bienvenue dans notre programme de fidélité !',
  welcome_conditions: ''
})

const stats = ref({
  totalApplied: 0,
  totalPoints: 0,
  thisMonth: 0
})

const recentBonuses = ref<any[]>([])
const saving = ref(false)

const toggleWelcomeBonus = () => {
  settings.value.welcome_enabled = !settings.value.welcome_enabled
}

const loadSettings = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data, error } = await supabase
      .from('bonus_settings')
      .select('*')
      .eq('company_id', user.id)
      .single()

    if (data) {
      settings.value = {
        welcome_enabled: data.welcome_enabled,
        welcome_points: data.welcome_points,
        welcome_message: data.welcome_message,
        welcome_conditions: data.welcome_conditions || ''
      }
    }
  } catch (error) {
    console.error('Erreur chargement paramètres:', error)
  }
}

const loadStats = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    // Total des bonus appliqués
    const { data: bonusData } = await supabase
      .from('applied_bonuses')
      .select('points_awarded')
      .eq('company_id', user.id)
      .eq('bonus_type', 'welcome')

    if (bonusData) {
      stats.value.totalApplied = bonusData.length
      stats.value.totalPoints = bonusData.reduce((sum, b) => sum + b.points_awarded, 0)
    }

    // Bonus ce mois
    const startOfMonth = new Date()
    startOfMonth.setDate(1)
    startOfMonth.setHours(0, 0, 0, 0)

    const { data: monthData } = await supabase
      .from('applied_bonuses')
      .select('id')
      .eq('company_id', user.id)
      .eq('bonus_type', 'welcome')
      .gte('applied_at', startOfMonth.toISOString())

    if (monthData) {
      stats.value.thisMonth = monthData.length
    }
  } catch (error) {
    console.error('Erreur chargement stats:', error)
  }
}

const loadRecentBonuses = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data } = await supabase
      .from('applied_bonuses')
      .select(`
        *,
        customers (
          first_name,
          last_name,
          email
        )
      `)
      .eq('company_id', user.id)
      .eq('bonus_type', 'welcome')
      .order('applied_at', { ascending: false })
      .limit(10)

    if (data) {
      recentBonuses.value = data.map(bonus => ({
        ...bonus,
        customer_name: `${bonus.customers.first_name} ${bonus.customers.last_name}`,
        customer_email: bonus.customers.email
      }))
    }
  } catch (error) {
    console.error('Erreur chargement historique:', error)
  }
}

const saveSettings = async () => {
  saving.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { error } = await supabase
      .from('bonus_settings')
      .upsert({
        company_id: user.id,
        welcome_enabled: settings.value.welcome_enabled,
        welcome_points: settings.value.welcome_points,
        welcome_message: settings.value.welcome_message,
        welcome_conditions: settings.value.welcome_conditions
      })

    if (!error) {
      alert('Paramètres enregistrés avec succès')
    }
  } catch (error) {
    console.error('Erreur sauvegarde:', error)
    alert('Erreur lors de l\'enregistrement')
  } finally {
    saving.value = false
  }
}

const getInitials = (name: string) => {
  return name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2)
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(() => {
  loadSettings()
  loadStats()
  loadRecentBonuses()
})
</script>