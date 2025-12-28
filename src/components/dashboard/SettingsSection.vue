<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-3xl font-black text-gray-900">Paramètres</h1>
      <p class="text-gray-600 mt-2">Configurez votre compte et vos préférences</p>
    </div>

    <div class="bg-white rounded-xl shadow-sm border border-gray-200">
      <!-- Tabs -->
      <div class="border-b border-gray-200">
        <nav class="flex space-x-8 px-6" aria-label="Tabs">
          <button
            v-for="tab in tabs"
            :key="tab.id"
            @click="activeTab = tab.id"
            :class="[
              'py-4 px-1 border-b-2 font-medium text-sm transition-colors',
              activeTab === tab.id
                ? 'border-violet-600 text-violet-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
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
            <h3 class="text-lg font-medium text-gray-900 mb-4">Configuration du programme de fidélité</h3>
            
            <!-- Points de bienvenue -->
            <div class="p-6 bg-gradient-to-br from-violet-50 to-pink-50 rounded-xl mb-6">
              <div class="flex items-start space-x-4">
                <div class="w-12 h-12 bg-white rounded-full flex items-center justify-center shadow-sm">
                  <Gift :size="24" class="text-violet-600" />
                </div>
                <div class="flex-1">
                  <h4 class="font-bold text-gray-900 mb-2">Points de bienvenue</h4>
                  <p class="text-sm text-gray-600 mb-4">
                    Points attribués automatiquement lors de l'inscription d'un nouveau client via QR code
                  </p>
                  <div class="flex items-center space-x-3">
                    <input
                      v-model.number="signupPoints"
                      type="number"
                      min="0"
                      max="1000"
                      class="w-32 px-4 py-2 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-violet-500 transition-colors"
                      placeholder="50"
                    />
                    <span class="text-gray-600 font-medium">points</span>
                    <button
                      @click="saveSignupPoints"
                      :disabled="savingPoints || signupPoints === originalSignupPoints"
                      class="px-4 py-2 bg-violet-600 text-white font-medium rounded-lg hover:bg-violet-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {{ savingPoints ? 'Enregistrement...' : 'Enregistrer' }}
                    </button>
                  </div>
                  <p class="text-xs text-gray-500 mt-2">
                    Recommandé : entre 10 et 100 points pour encourager l'inscription
                  </p>
                </div>
              </div>
            </div>
            
            <!-- Autres paramètres -->
            <div class="space-y-4">
              <div class="p-4 bg-gray-50 rounded-lg">
                <div class="flex items-center justify-between">
                  <div>
                    <p class="font-medium text-gray-900">Multiplicateur de points</p>
                    <p class="text-sm text-gray-500">Doublez les points lors d'événements spéciaux</p>
                  </div>
                  <span class="text-sm text-gray-400">Bientôt disponible</span>
                </div>
              </div>
              <div class="p-4 bg-gray-50 rounded-lg">
                <div class="flex items-center justify-between">
                  <div>
                    <p class="font-medium text-gray-900">Expiration des points</p>
                    <p class="text-sm text-gray-500">Définissez une durée de validité pour les points</p>
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
            <h3 class="text-lg font-medium text-gray-900 mb-4">Préférences générales</h3>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Langue</label>
                <select class="w-full md:w-64 px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-violet-500">
                  <option>Français</option>
                  <option>English</option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Fuseau horaire</label>
                <select class="w-full md:w-64 px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:border-violet-500">
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
            <h3 class="text-lg font-medium text-gray-900 mb-4">Préférences de notification</h3>
            <div class="space-y-4">
              <label class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                <div>
                  <p class="font-medium text-gray-900">Nouveaux clients</p>
                  <p class="text-sm text-gray-500">Recevez une notification quand un nouveau client s'inscrit</p>
                </div>
                <input type="checkbox" checked class="w-5 h-5 text-violet-600 rounded" />
              </label>
              <label class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                <div>
                  <p class="font-medium text-gray-900">Récompenses échangées</p>
                  <p class="text-sm text-gray-500">Notification quand un client échange une récompense</p>
                </div>
                <input type="checkbox" checked class="w-5 h-5 text-violet-600 rounded" />
              </label>
              <label class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                <div>
                  <p class="font-medium text-gray-900">Rapports hebdomadaires</p>
                  <p class="text-sm text-gray-500">Recevez un résumé de vos performances chaque semaine</p>
                </div>
                <input type="checkbox" class="w-5 h-5 text-violet-600 rounded" />
              </label>
            </div>
          </div>
        </div>

        <!-- Sécurité -->
        <div v-if="activeTab === 'security'" class="space-y-6">
          <div>
            <h3 class="text-lg font-medium text-gray-900 mb-4">Sécurité du compte</h3>
            <div class="space-y-4">
              <button class="px-4 py-2 bg-violet-100 text-violet-600 rounded-lg font-medium hover:bg-violet-200 transition-colors">
                Changer le mot de passe
              </button>
              <div class="p-4 bg-gray-50 rounded-lg">
                <p class="text-sm text-gray-600">Authentification à deux facteurs</p>
                <p class="text-xs text-gray-500 mt-1">Protégez votre compte avec une couche de sécurité supplémentaire</p>
                <button class="mt-3 text-sm text-violet-600 font-medium">Activer 2FA →</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Intégrations -->
        <div v-if="activeTab === 'integrations'" class="space-y-6">
          <div>
            <h3 class="text-lg font-medium text-gray-900 mb-4">Intégrations disponibles</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="p-4 border border-gray-200 rounded-lg">
                <div class="flex items-center justify-between mb-2">
                  <h4 class="font-medium">Google Analytics</h4>
                  <span class="px-2 py-1 bg-green-100 text-green-700 text-xs rounded-full">Connecté</span>
                </div>
                <p class="text-sm text-gray-500">Suivez vos performances de fidélité</p>
              </div>
              <div class="p-4 border border-gray-200 rounded-lg">
                <div class="flex items-center justify-between mb-2">
                  <h4 class="font-medium">Mailchimp</h4>
                  <button class="text-sm text-violet-600 font-medium">Connecter</button>
                </div>
                <p class="text-sm text-gray-500">Synchronisez vos contacts</p>
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
import { ref, onMounted } from 'vue'
import { Gift, Loader2, CheckCircle } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

const activeTab = ref('loyalty')
const signupPoints = ref(50)
const originalSignupPoints = ref(50)
const savingPoints = ref(false)
const showSuccess = ref(false)
const successMessage = ref('')

const tabs = [
  { id: 'loyalty', name: 'Programme de fidélité' },
  { id: 'general', name: 'Général' },
  { id: 'notifications', name: 'Notifications' },
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
      .select('signup_points')
      .eq('auth_id', user.id)
      .single()

    if (data) {
      signupPoints.value = data.signup_points || 50
      originalSignupPoints.value = data.signup_points || 50
    }
  } catch (error) {
    console.error('Erreur lors du chargement des paramètres:', error)
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
})
</script>