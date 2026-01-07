<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-3xl font-black text-gray-900 dark:text-white">Votre Plan</h1>
      <p class="text-gray-600 dark:text-gray-400 mt-2">Gérez votre abonnement et découvrez nos offres</p>
    </div>

    <!-- Plan actuel -->
    <div class="bg-gradient-to-r from-violet-600 to-pink-600 rounded-2xl p-4 text-white">
      <div class="flex items-center justify-between gap-6">
        <!-- Titre du plan -->
        <div class="flex items-center space-x-3">
          <Crown :size="24" />
          <div>
            <h2 class="text-xl font-black">Plan {{ currentPlan.toUpperCase() }}</h2>
            <p class="text-white/70 text-xs">Votre plan actuel</p>
          </div>
        </div>
        
        <!-- Informations du plan -->
        <div class="flex items-center space-x-8 flex-grow">
          <div class="text-center">
            <p class="text-white/60 text-xs">Clients max</p>
            <p class="font-bold">{{ getPlanLimits(currentPlan).customers }}</p>
          </div>
          <div class="text-center">
            <p class="text-white/60 text-xs">Récompenses</p>
            <p class="font-bold">{{ getPlanLimits(currentPlan).rewards }}</p>
          </div>
          <div class="text-center">
            <p class="text-white/60 text-xs">Analytics</p>
            <p class="font-bold">{{ getPlanLimits(currentPlan).analytics }}</p>
          </div>
          <div class="text-center">
            <p class="text-white/60 text-xs">{{ currentPlan === 'free' ? 'Essai gratuit' : 'Engagement' }}</p>
            <p class="font-bold">{{ currentPlan === 'free' ? '14 jours' : '6 mois' }}</p>
          </div>
          <div class="text-center">
            <p class="text-white/60 text-xs">Prochaine facturation</p>
            <p class="font-bold text-sm">15 Jan 2025</p>
          </div>
        </div>
        
        <!-- Bouton action -->
        <div>
          <button class="px-4 py-2 bg-white dark:bg-gray-800/20 hover:bg-white dark:bg-gray-800/30 rounded-lg text-sm font-medium transition-colors whitespace-nowrap">
            Gérer la facturation
          </button>
        </div>
      </div>
    </div>

    <!-- Tous les plans -->
    <div class="w-full">
      <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">Choisir un plan</h3>
      <div class="grid grid-cols-3 gap-3">
        
        <!-- Plan Free -->
        <div :class="[
          'relative rounded-xl p-4 transition-all duration-300 flex flex-col',
          currentPlan === 'free' 
            ? 'bg-violet-50 border-2 border-violet-600 shadow-lg' 
            : 'bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 hover:shadow-lg'
        ]">
          <!-- Badge plan actuel -->
          <div v-if="currentPlan === 'free'" class="absolute -top-3 left-1/2 transform -translate-x-1/2">
            <span class="px-3 py-1 bg-violet-600 text-white text-xs font-bold rounded-full">
              PLAN ACTUEL
            </span>
          </div>

          <div class="text-center mb-3">
            <h4 class="text-lg font-bold text-gray-900 dark:text-white">Essai Gratuit</h4>
            <p class="text-gray-600 dark:text-gray-400 text-xs">14 jours d'essai</p>
            <div class="flex items-baseline justify-center mt-2">
              <span class="text-2xl font-black text-gray-900 dark:text-white">0€</span>
              <span class="text-gray-500 dark:text-gray-400 ml-1 text-xs">/14 jours</span>
            </div>
          </div>

          <ul class="space-y-1.5 mb-4 flex-grow">
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">100 clients max</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">Toutes fonctionnalités</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">Sans engagement</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">Support par email</span>
            </li>
            <li class="flex items-center space-x-2">
              <X :size="14" class="text-gray-300 flex-shrink-0" />
              <span class="text-xs text-gray-400">Statistiques</span>
            </li>
          </ul>

          <div class="mt-auto">
            <button 
              v-if="currentPlan !== 'free'"
              @click="selectPlan('free')"
              class="w-full py-2 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-300 font-bold rounded-xl transition-colors text-sm"
            >
              Passer à Free
            </button>
            <div v-else class="w-full py-2 text-center text-gray-500 dark:text-gray-400 font-medium text-sm">
              Plan actuel
            </div>
          </div>
        </div>

        <!-- Plan Starter -->
        <div :class="[
          'relative rounded-xl p-4 transition-all duration-300 flex flex-col',
          currentPlan === 'starter' 
            ? 'bg-violet-50 border-2 border-violet-600 shadow-lg' 
            : 'bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 hover:shadow-lg'
        ]">
          <!-- Badge plan actuel -->
          <div v-if="currentPlan === 'starter'" class="absolute -top-3 left-1/2 transform -translate-x-1/2">
            <span class="px-3 py-1 bg-violet-600 text-white text-xs font-bold rounded-full">
              PLAN ACTUEL
            </span>
          </div>

          <div class="text-center mb-3">
            <h4 class="text-lg font-bold text-gray-900 dark:text-white">Starter</h4>
            <p class="text-gray-600 dark:text-gray-400 text-xs">Petites entreprises</p>
            <div class="flex items-baseline justify-center mt-2">
              <span class="text-2xl font-black text-violet-600">19,99€</span>
              <span class="text-gray-500 dark:text-gray-400 ml-1 text-xs">/mois</span>
            </div>
            <p class="text-xs text-gray-500 dark:text-gray-400">6 mois • 239,88€/an</p>
          </div>

          <ul class="space-y-1.5 mb-4 flex-grow">
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">Programme fidélité</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">500 comptes clients</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">Notifications auto</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">Support prioritaire</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">Dashboard Analytics</span>
            </li>
            <li class="flex items-center space-x-2">
              <X :size="14" class="text-gray-300 flex-shrink-0" />
              <span class="text-xs text-gray-400">API avancée</span>
            </li>
          </ul>

          <div class="mt-auto">
            <button 
              v-if="currentPlan !== 'starter'"
              @click="selectPlan('starter')"
              class="w-full py-2 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold rounded-xl hover:scale-105 transition-all duration-300 shadow-lg text-sm"
            >
              {{ currentPlan === 'free' ? 'Upgrade' : 'Passer à' }} Starter
            </button>
            <div v-else class="w-full py-2 text-center text-gray-500 dark:text-gray-400 font-medium text-sm">
              Plan actuel
            </div>
          </div>
        </div>

        <!-- Plan Premium -->
        <div :class="[
          'relative rounded-xl p-4 transition-all duration-300 flex flex-col',
          currentPlan === 'premium' 
            ? 'bg-gradient-to-br from-violet-50 to-pink-50 border-2 border-violet-600 shadow-lg' 
            : 'bg-gradient-to-br from-violet-50 to-pink-50 border-2 border-violet-300 hover:shadow-lg'
        ]">
          <!-- Badge plan actuel ou populaire -->
          <div class="absolute -top-3 left-1/2 transform -translate-x-1/2">
            <span v-if="currentPlan === 'premium'" class="px-3 py-1 bg-violet-600 text-white text-xs font-bold rounded-full">
              PLAN ACTUEL
            </span>
            <span v-else class="px-3 py-1 bg-gradient-to-r from-violet-600 to-pink-600 text-white text-xs font-bold rounded-full inline-flex items-center space-x-1">
              <Crown :size="12" />
              <span>POPULAIRE</span>
            </span>
          </div>

          <div class="text-center mb-3 mt-2">
            <h4 class="text-lg font-bold text-gray-900 dark:text-white">Premium</h4>
            <p class="text-gray-600 dark:text-gray-400 text-xs">Entreprises en croissance</p>
            <div class="flex items-baseline justify-center mt-2">
              <span class="text-2xl font-black bg-gradient-to-r from-violet-600 to-pink-600 bg-clip-text text-transparent">39,99€</span>
              <span class="text-gray-500 dark:text-gray-400 ml-1 text-xs">/mois</span>
            </div>
            <p class="text-xs text-gray-600 dark:text-gray-400">6 mois • 479,88€/an</p>
          </div>

          <ul class="space-y-1.5 mb-4 flex-grow">
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300 font-semibold">Tout Starter +</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">Analytics temps réel</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">Stats & exports</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">Segmentation clients</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">API complète</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">Clients illimités</span>
            </li>
            <li class="flex items-center space-x-2">
              <Check :size="14" class="text-green-600 flex-shrink-0" />
              <span class="text-xs text-gray-700 dark:text-gray-300">Support VIP</span>
            </li>
          </ul>

          <div class="mt-auto">
            <button 
              v-if="currentPlan !== 'premium'"
              @click="selectPlan('premium')"
              class="w-full py-2 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold rounded-xl hover:scale-105 transition-all duration-300 shadow-lg text-sm"
            >
              {{ currentPlan === 'admin' ? 'Passer à' : 'Upgrade' }} Premium
            </button>
            <div v-else class="w-full py-2 text-center text-gray-500 dark:text-gray-400 font-medium text-sm">
              Plan actuel
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Comparaison des fonctionnalités -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
      <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-6">Comparaison détaillée</h3>
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead>
            <tr class="border-b border-gray-200 dark:border-gray-700">
              <th class="text-left py-3 px-4 font-medium text-gray-700 dark:text-gray-300">Fonctionnalité</th>
              <th class="text-center py-3 px-4 font-medium text-gray-700 dark:text-gray-300">Free</th>
              <th class="text-center py-3 px-4 font-medium text-gray-700 dark:text-gray-300">Starter</th>
              <th class="text-center py-3 px-4 font-medium text-gray-700 dark:text-gray-300">Premium</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr>
              <td class="py-3 px-4 text-sm text-gray-700 dark:text-gray-300">Nombre de clients</td>
              <td class="text-center py-3 px-4 text-gray-900 dark:text-white">100</td>
              <td class="text-center py-3 px-4 text-gray-900 dark:text-white">500</td>
              <td class="text-center py-3 px-4 text-gray-900 dark:text-white">Illimité</td>
            </tr>
            <tr>
              <td class="py-3 px-4 text-sm text-gray-700 dark:text-gray-300">Programme de fidélité</td>
              <td class="text-center py-3 px-4">
                <Check :size="16" class="text-green-600 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <Check :size="16" class="text-green-600 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <Check :size="16" class="text-green-600 mx-auto" />
              </td>
            </tr>
            <tr>
              <td class="py-3 px-4 text-sm text-gray-700 dark:text-gray-300">Notifications automatiques</td>
              <td class="text-center py-3 px-4">
                <X :size="16" class="text-red-500 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <Check :size="16" class="text-green-600 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <Check :size="16" class="text-green-600 mx-auto" />
              </td>
            </tr>
            <tr>
              <td class="py-3 px-4 text-sm text-gray-700 dark:text-gray-300">Support</td>
              <td class="text-center py-3 px-4 text-xs text-gray-700 dark:text-gray-300">Email</td>
              <td class="text-center py-3 px-4 text-xs text-gray-700 dark:text-gray-300">Email prioritaire</td>
              <td class="text-center py-3 px-4 text-xs text-gray-700 dark:text-gray-300">Prioritaire</td>
            </tr>
            <tr>
              <td class="py-3 px-4 text-sm text-gray-700 dark:text-gray-300">Dashboard Analytics</td>
              <td class="text-center py-3 px-4">
                <X :size="16" class="text-red-500 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <Check :size="16" class="text-green-600 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <Check :size="16" class="text-green-600 mx-auto" />
              </td>
            </tr>
            <tr>
              <td class="py-3 px-4 text-sm text-gray-700 dark:text-gray-300">Statistiques et exports</td>
              <td class="text-center py-3 px-4">
                <X :size="16" class="text-red-500 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <X :size="16" class="text-red-500 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <Check :size="16" class="text-green-600 mx-auto" />
              </td>
            </tr>
            <tr>
              <td class="py-3 px-4 text-sm text-gray-700 dark:text-gray-300">Analytics temps réel</td>
              <td class="text-center py-3 px-4">
                <X :size="16" class="text-red-500 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <X :size="16" class="text-red-500 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <Check :size="16" class="text-green-600 mx-auto" />
              </td>
            </tr>
            <tr>
              <td class="py-3 px-4 text-sm text-gray-700 dark:text-gray-300">Segmentation avancée</td>
              <td class="text-center py-3 px-4">
                <X :size="16" class="text-red-500 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <X :size="16" class="text-red-500 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <Check :size="16" class="text-green-600 mx-auto" />
              </td>
            </tr>
            <tr>
              <td class="py-3 px-4 text-sm text-gray-700 dark:text-gray-300">API et intégrations</td>
              <td class="text-center py-3 px-4">
                <X :size="16" class="text-red-500 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <X :size="16" class="text-red-500 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <Check :size="16" class="text-green-600 mx-auto" />
              </td>
            </tr>
            <tr>
              <td class="py-3 px-4 text-sm text-gray-700 dark:text-gray-300">Formation personnalisée</td>
              <td class="text-center py-3 px-4">
                <X :size="16" class="text-red-500 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <X :size="16" class="text-red-500 mx-auto" />
              </td>
              <td class="text-center py-3 px-4">
                <Check :size="16" class="text-green-600 mx-auto" />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    
    <!-- Modal de confirmation de changement de plan -->
    <Teleport to="body">
    <Transition
      enter-active-class="duration-200 ease-out"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="duration-150 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div v-if="showUpgradeModal" class="fixed inset-0 z-50 flex items-center justify-center">
        <!-- Overlay -->
        <div class="absolute inset-0 bg-black/50" @click="cancelUpgrade"></div>
        
        <!-- Modal -->
        <div class="relative bg-white dark:bg-gray-800 rounded-2xl shadow-2xl p-8 max-w-md w-full mx-4">
          <div class="text-center mb-6">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-violet-600 to-pink-600 rounded-2xl mb-4">
              <Crown :size="32" class="text-white" />
            </div>
            <h2 class="text-2xl font-black text-gray-900 dark:text-white mb-2">
              Confirmer le changement de plan
            </h2>
            <p class="text-gray-600 dark:text-gray-400">
              Vous allez passer au plan <span class="font-bold text-violet-600">{{ planToUpgrade.toUpperCase() }}</span>
            </p>
          </div>

          <!-- Message de succès -->
          <div v-if="successMessage" class="mb-4 p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-700 rounded-xl">
            <p class="text-green-700 dark:text-green-300 font-medium text-center">{{ successMessage }}</p>
          </div>
          
          <!-- Message d'erreur -->
          <div v-if="errorMessage" class="mb-4 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-700 rounded-xl">
            <p class="text-red-700 dark:text-red-300 font-medium text-center">{{ errorMessage }}</p>
          </div>

          <div class="bg-gray-50 dark:bg-gray-900 rounded-xl p-4 mb-6">
            <div class="space-y-3">
              <div class="flex items-center justify-between">
                <span class="text-sm text-gray-600 dark:text-gray-400">Plan actuel</span>
                <span class="font-bold text-gray-900 dark:text-white">{{ currentPlan.toUpperCase() }}</span>
              </div>
              <div class="border-t border-gray-200 dark:border-gray-700"></div>
              <div class="flex items-center justify-between">
                <span class="text-sm text-gray-600 dark:text-gray-400">Nouveau plan</span>
                <span class="font-bold text-violet-600">{{ planToUpgrade.toUpperCase() }}</span>
              </div>
              <div class="flex items-center justify-between">
                <span class="text-sm text-gray-600 dark:text-gray-400">Prix mensuel</span>
                <span class="font-bold text-gray-900 dark:text-white">
                  {{ planToUpgrade === 'free' ? '0€' : planToUpgrade === 'starter' ? '19,99€' : '39,99€' }}
                </span>
              </div>
              <div v-if="planToUpgrade !== 'free'" class="flex items-center justify-between">
                <span class="text-sm text-gray-600 dark:text-gray-400">Engagement</span>
                <span class="font-bold text-gray-900 dark:text-white">6 mois minimum</span>
              </div>
            </div>
          </div>

          <div class="flex space-x-4">
            <button
              @click="cancelUpgrade"
              class="flex-1 py-3 px-6 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-300 font-bold rounded-xl transition-colors"
            >
              Annuler
            </button>
            <button
              @click="confirmUpgrade"
              :disabled="isUpdating"
              class="flex-1 py-3 px-6 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold rounded-xl hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span v-if="!isUpdating">Confirmer</span>
              <span v-else>Mise à jour...</span>
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { Crown, Check, X } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

const props = defineProps<{
  currentPlan: string
  selectedPlan?: string
}>()

const emit = defineEmits<{
  'planUpdated': [plan: string]
}>()

const showUpgradeModal = ref(false)
const planToUpgrade = ref('')
const isUpdating = ref(false)
const successMessage = ref('')
const errorMessage = ref('')

// Observer le plan sélectionné depuis l'URL
watch(() => props.selectedPlan, (newPlan) => {
  if (newPlan && newPlan !== props.currentPlan) {
    planToUpgrade.value = newPlan
    showUpgradeModal.value = true
  }
}, { immediate: true })

const confirmUpgrade = async () => {
  // Pour l'instant, on met à jour directement le plan sans paiement
  console.log('Changement vers le plan:', planToUpgrade.value)
  
  isUpdating.value = true
  successMessage.value = ''
  errorMessage.value = ''
  
  try {
    // Récupérer l'utilisateur actuel
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      errorMessage.value = 'Utilisateur non connecté'
      return
    }
    
    // Mettre à jour le plan dans la base de données
    const { error } = await supabase
      .from('users')
      .update({ 
        selected_plan: planToUpgrade.value,
        updated_at: new Date().toISOString()
      })
      .eq('auth_id', user.id)
    
    if (error) throw error
    
    // Message de succès
    successMessage.value = `Votre plan a été changé avec succès vers ${planToUpgrade.value.toUpperCase()} !`
    
    // Émettre l'événement de mise à jour
    emit('planUpdated', planToUpgrade.value)
    
    // Fermer le modal après un court délai
    setTimeout(() => {
      showUpgradeModal.value = false
      planToUpgrade.value = ''
      successMessage.value = ''
      // Recharger la page pour afficher le nouveau plan
      window.location.reload()
    }, 1500)
    
  } catch (error) {
    console.error('Erreur lors du changement de plan:', error)
    errorMessage.value = 'Erreur lors du changement de plan'
  } finally {
    isUpdating.value = false
  }
}

const cancelUpgrade = () => {
  showUpgradeModal.value = false
  planToUpgrade.value = ''
}

const selectPlan = (plan: string) => {
  if (plan !== props.currentPlan) {
    planToUpgrade.value = plan
    showUpgradeModal.value = true
  }
}

const getPlanLimits = (plan: string) => {
  const limits = {
    free: { customers: '100', rewards: 'Toutes', analytics: '14 jours' },
    starter: { customers: '500', rewards: 'Illimitées', analytics: '30 jours' },
    premium: { customers: 'Illimité', rewards: 'Illimitées', analytics: '365 jours' },
    admin: { customers: 'Illimité', rewards: 'Illimitées', analytics: 'Illimité' }
  }
  return limits[plan as keyof typeof limits] || limits.free
}
</script>