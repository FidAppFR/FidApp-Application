<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-3xl font-black text-gray-900">Bonus & Événements</h1>
      <p class="text-gray-600 mt-2">Gérez les bonus anniversaire, parrainage et événements spéciaux</p>
    </div>

    <!-- Tabs pour les différents types de bonus -->
    <div class="border-b border-gray-200">
      <nav class="-mb-px flex space-x-8">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          @click="activeTab = tab.id"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm transition-colors',
            activeTab === tab.id
              ? 'border-violet-600 text-violet-600'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          {{ tab.label }}
        </button>
      </nav>
    </div>

    <!-- Contenu selon l'onglet actif -->
    
    <!-- Onglet Anniversaire -->
    <div v-if="activeTab === 'birthday'" class="space-y-6">
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex items-start justify-between mb-6">
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 bg-gradient-to-br from-pink-500 to-rose-600 rounded-xl flex items-center justify-center">
              <Cake :size="24" class="text-white" />
            </div>
            <div>
              <h2 class="text-xl font-bold text-gray-900">Bonus Anniversaire</h2>
              <p class="text-sm text-gray-600">Offrez des points le jour de l'anniversaire de vos clients</p>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-sm text-gray-600">Activé</span>
            <button
              @click="toggleBonus('birthday')"
              :class="[
                'relative inline-flex h-6 w-11 items-center rounded-full transition-colors',
                bonusSettings.birthday_enabled ? 'bg-violet-600' : 'bg-gray-300'
              ]"
            >
              <span
                :class="[
                  'inline-block h-4 w-4 transform rounded-full bg-white transition-transform',
                  bonusSettings.birthday_enabled ? 'translate-x-6' : 'translate-x-1'
                ]"
              />
            </button>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Points offerts
            </label>
            <input
              v-model.number="bonusSettings.birthday_points"
              type="number"
              min="0"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
              :disabled="!bonusSettings.birthday_enabled"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Application automatique
            </label>
            <select
              v-model="bonusSettings.birthday_auto_apply"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
              :disabled="!bonusSettings.birthday_enabled"
            >
              <option :value="true">Automatique le jour J</option>
              <option :value="false">Manuel uniquement</option>
            </select>
          </div>
        </div>

        <div class="mt-6">
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Message d'anniversaire
          </label>
          <textarea
            v-model="bonusSettings.birthday_message"
            rows="2"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
            :disabled="!bonusSettings.birthday_enabled"
          ></textarea>
        </div>
      </div>
    </div>

    <!-- Onglet Parrainage -->
    <div v-if="activeTab === 'referral'" class="space-y-6">
      <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
        <div class="flex items-start justify-between mb-6">
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 bg-gradient-to-br from-green-500 to-emerald-600 rounded-xl flex items-center justify-center">
              <Users :size="24" class="text-white" />
            </div>
            <div>
              <h2 class="text-xl font-bold text-gray-900">Programme de Parrainage</h2>
              <p class="text-sm text-gray-600">Récompensez les clients qui recommandent votre entreprise</p>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-sm text-gray-600">Activé</span>
            <button
              @click="toggleBonus('referral')"
              :class="[
                'relative inline-flex h-6 w-11 items-center rounded-full transition-colors',
                bonusSettings.referral_enabled ? 'bg-violet-600' : 'bg-gray-300'
              ]"
            >
              <span
                :class="[
                  'inline-block h-4 w-4 transform rounded-full bg-white transition-transform',
                  bonusSettings.referral_enabled ? 'translate-x-6' : 'translate-x-1'
                ]"
              />
            </button>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Points pour le parrain
            </label>
            <input
              v-model.number="bonusSettings.referral_points_referrer"
              type="number"
              min="0"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
              :disabled="!bonusSettings.referral_enabled"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Points pour le filleul
            </label>
            <input
              v-model.number="bonusSettings.referral_points_referee"
              type="number"
              min="0"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
              :disabled="!bonusSettings.referral_enabled"
            />
          </div>
        </div>

        <div class="mt-6">
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Conditions de parrainage
          </label>
          <textarea
            v-model="bonusSettings.referral_conditions"
            rows="3"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
            :disabled="!bonusSettings.referral_enabled"
            placeholder="Ex: Le filleul doit effectuer un premier achat..."
          ></textarea>
        </div>
      </div>
    </div>

    <!-- Onglet Événements Spéciaux -->
    <div v-if="activeTab === 'special'" class="space-y-6">
      <div class="flex justify-end mb-4">
        <button
          @click="showAddEvent = true"
          class="px-4 py-2 bg-gradient-to-r from-violet-600 to-purple-600 text-white rounded-lg hover:shadow-lg transition-all duration-200 flex items-center gap-2"
        >
          <Plus :size="20" />
          Créer un événement
        </button>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="event in specialEvents"
          :key="event.id"
          class="bg-white rounded-xl shadow-sm border border-gray-200 p-6"
        >
          <div class="flex items-start justify-between mb-4">
            <h3 class="font-bold text-gray-900">{{ event.name }}</h3>
            <button
              @click="toggleEvent(event)"
              :class="[
                'px-2 py-1 rounded text-xs font-medium',
                event.is_active 
                  ? 'bg-green-100 text-green-700' 
                  : 'bg-gray-100 text-gray-700'
              ]"
            >
              {{ event.is_active ? 'Actif' : 'Inactif' }}
            </button>
          </div>
          
          <p class="text-sm text-gray-600 mb-4">{{ event.description }}</p>
          
          <div class="space-y-2">
            <div class="flex items-center justify-between">
              <span class="text-sm text-gray-500">Points</span>
              <div class="flex items-center gap-1">
                <Star :size="16" class="text-amber-500" />
                <span class="font-bold">{{ event.points }}</span>
              </div>
            </div>
            
            <div v-if="event.start_date || event.end_date" class="flex items-center justify-between">
              <span class="text-sm text-gray-500">Période</span>
              <span class="text-sm font-medium">
                {{ formatDateRange(event.start_date, event.end_date) }}
              </span>
            </div>
            
            <div class="flex items-center justify-between">
              <span class="text-sm text-gray-500">Utilisations</span>
              <span class="text-sm font-medium">{{ event.total_uses }}</span>
            </div>
          </div>
          
          <div class="mt-4 flex gap-2">
            <button
              @click="editEvent(event)"
              class="flex-1 px-3 py-1 bg-gray-100 text-gray-700 rounded text-sm hover:bg-gray-200 transition-colors"
            >
              Modifier
            </button>
            <button
              @click="deleteEvent(event)"
              class="flex-1 px-3 py-1 bg-red-50 text-red-600 rounded text-sm hover:bg-red-100 transition-colors"
            >
              Supprimer
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Bouton de sauvegarde global -->
    <div v-if="activeTab !== 'special'" class="flex justify-end">
      <button
        @click="saveSettings"
        :disabled="saving"
        class="px-6 py-2 bg-gradient-to-r from-violet-600 to-purple-600 text-white rounded-lg hover:shadow-lg transition-all duration-200 disabled:opacity-50"
      >
        {{ saving ? 'Enregistrement...' : 'Enregistrer les modifications' }}
      </button>
    </div>

    <!-- Modal pour créer/éditer un événement -->
    <div v-if="showAddEvent || editingEvent" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-xl p-6 w-full max-w-md">
        <h3 class="text-xl font-bold text-gray-900 mb-4">
          {{ editingEvent ? 'Modifier l\'événement' : 'Créer un événement' }}
        </h3>

        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nom de l'événement</label>
            <input
              v-model="eventForm.name"
              type="text"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
              placeholder="Ex: Black Friday"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea
              v-model="eventForm.description"
              rows="2"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Points offerts</label>
            <input
              v-model.number="eventForm.points"
              type="number"
              min="1"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
            />
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Date début</label>
              <input
                v-model="eventForm.start_date"
                type="date"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Date fin</label>
              <input
                v-model="eventForm.end_date"
                type="date"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
              />
            </div>
          </div>

          <div>
            <label class="flex items-center space-x-2">
              <input
                v-model="eventForm.is_active"
                type="checkbox"
                class="rounded text-violet-600 focus:ring-violet-600"
              />
              <span class="text-sm text-gray-700">Activer immédiatement</span>
            </label>
          </div>
        </div>

        <div class="flex gap-3 mt-6">
          <button
            @click="saveEvent"
            :disabled="savingEvent"
            class="flex-1 bg-gradient-to-r from-violet-600 to-purple-600 text-white py-2 rounded-lg hover:shadow-lg transition-all duration-200 disabled:opacity-50"
          >
            {{ savingEvent ? 'Enregistrement...' : 'Enregistrer' }}
          </button>
          <button
            @click="closeEventModal"
            class="flex-1 bg-gray-100 text-gray-700 py-2 rounded-lg hover:bg-gray-200 transition-colors"
          >
            Annuler
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Cake, Users, Plus, Star } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

const tabs = [
  { id: 'birthday', label: 'Anniversaire' },
  { id: 'referral', label: 'Parrainage' },
  { id: 'special', label: 'Événements spéciaux' }
]

const activeTab = ref('birthday')
const saving = ref(false)
const savingEvent = ref(false)
const showAddEvent = ref(false)
const editingEvent = ref<any>(null)

const bonusSettings = ref({
  birthday_enabled: true,
  birthday_points: 100,
  birthday_message: 'Joyeux anniversaire ! Voici votre cadeau.',
  birthday_auto_apply: true,
  referral_enabled: true,
  referral_points_referrer: 75,
  referral_points_referee: 50,
  referral_message: 'Merci de nous recommander !',
  referral_conditions: ''
})

const specialEvents = ref<any[]>([])

const eventForm = ref({
  name: '',
  description: '',
  points: 25,
  start_date: '',
  end_date: '',
  is_active: true
})

const toggleBonus = (type: string) => {
  if (type === 'birthday') {
    bonusSettings.value.birthday_enabled = !bonusSettings.value.birthday_enabled
  } else if (type === 'referral') {
    bonusSettings.value.referral_enabled = !bonusSettings.value.referral_enabled
  }
}

const loadSettings = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data } = await supabase
      .from('bonus_settings')
      .select('*')
      .eq('company_id', user.id)
      .single()

    if (data) {
      Object.assign(bonusSettings.value, data)
    }
  } catch (error) {
    console.error('Erreur chargement paramètres:', error)
  }
}

const loadSpecialEvents = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data } = await supabase
      .from('special_events')
      .select('*')
      .eq('company_id', user.id)
      .order('created_at', { ascending: false })

    if (data) {
      specialEvents.value = data
    }
  } catch (error) {
    console.error('Erreur chargement événements:', error)
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
        ...bonusSettings.value
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

const saveEvent = async () => {
  savingEvent.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const eventData = {
      company_id: user.id,
      ...eventForm.value
    }

    if (editingEvent.value) {
      const { error } = await supabase
        .from('special_events')
        .update(eventData)
        .eq('id', editingEvent.value.id)

      if (!error) {
        await loadSpecialEvents()
        closeEventModal()
      }
    } else {
      const { error } = await supabase
        .from('special_events')
        .insert(eventData)

      if (!error) {
        await loadSpecialEvents()
        closeEventModal()
      }
    }
  } catch (error) {
    console.error('Erreur sauvegarde événement:', error)
  } finally {
    savingEvent.value = false
  }
}

const editEvent = (event: any) => {
  editingEvent.value = event
  eventForm.value = { ...event }
}

const toggleEvent = async (event: any) => {
  try {
    const { error } = await supabase
      .from('special_events')
      .update({ is_active: !event.is_active })
      .eq('id', event.id)

    if (!error) {
      event.is_active = !event.is_active
    }
  } catch (error) {
    console.error('Erreur changement statut:', error)
  }
}

const deleteEvent = async (event: any) => {
  if (!confirm(`Supprimer l'événement "${event.name}" ?`)) return

  try {
    const { error } = await supabase
      .from('special_events')
      .delete()
      .eq('id', event.id)

    if (!error) {
      specialEvents.value = specialEvents.value.filter(e => e.id !== event.id)
    }
  } catch (error) {
    console.error('Erreur suppression:', error)
  }
}

const closeEventModal = () => {
  showAddEvent.value = false
  editingEvent.value = null
  eventForm.value = {
    name: '',
    description: '',
    points: 25,
    start_date: '',
    end_date: '',
    is_active: true
  }
}

const formatDateRange = (start: string, end: string) => {
  if (!start && !end) return 'Permanent'
  const formatDate = (date: string) => new Date(date).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short' })
  if (start && end) return `${formatDate(start)} - ${formatDate(end)}`
  if (start) return `À partir du ${formatDate(start)}`
  if (end) return `Jusqu'au ${formatDate(end)}`
}

onMounted(() => {
  loadSettings()
  loadSpecialEvents()
})
</script>