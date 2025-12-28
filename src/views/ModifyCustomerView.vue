<template>
  <div class="min-h-screen bg-gradient-to-br from-violet-50 via-white to-pink-50 py-12 px-4">
    <div class="max-w-md mx-auto">
      <!-- Logo -->
      <div class="text-center mb-8">
        <img src="/Logo_Trans_unique.png" alt="FidApp" class="h-16 mx-auto mb-4" />
        <h1 class="text-2xl font-bold text-gray-900">Modification de vos informations</h1>
      </div>

      <!-- Contenu principal -->
      <div class="bg-white rounded-2xl shadow-xl p-8">
        <!-- Chargement -->
        <div v-if="loading" class="flex flex-col items-center py-12">
          <div class="w-12 h-12 border-4 border-violet-600 border-t-transparent rounded-full animate-spin mb-4"></div>
          <p class="text-gray-600">Vérification du lien...</p>
        </div>

        <!-- Erreur -->
        <div v-else-if="error" class="text-center py-8">
          <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <X :size="32" class="text-red-600" />
          </div>
          <h2 class="text-xl font-bold text-gray-900 mb-2">Lien invalide ou expiré</h2>
          <p class="text-gray-600 mb-6">{{ errorMessage }}</p>
          <button
            @click="router.push('/')"
            class="px-6 py-2 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-medium rounded-lg hover:scale-105 transition-transform"
          >
            Retour à l'accueil
          </button>
        </div>

        <!-- Formulaire de modification -->
        <div v-else-if="tokenData" class="space-y-6">
          <div class="text-center mb-6">
            <div class="w-16 h-16 bg-violet-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Shield :size="32" class="text-violet-600" />
            </div>
            <h2 class="text-xl font-bold text-gray-900">Confirmer la modification</h2>
            <p class="text-sm text-gray-600 mt-2">
              Vous êtes sur le point de modifier votre {{ getFieldLabel(tokenData.field_to_modify) }}
            </p>
          </div>

          <!-- Ancienne valeur -->
          <div class="bg-gray-50 rounded-lg p-4">
            <p class="text-sm text-gray-600 mb-1">Valeur actuelle</p>
            <p class="font-medium text-gray-900">{{ tokenData.old_value || 'Non renseigné' }}</p>
          </div>

          <!-- Nouvelle valeur -->
          <div class="bg-violet-50 rounded-lg p-4 border-2 border-violet-200">
            <p class="text-sm text-violet-600 mb-1">Nouvelle valeur</p>
            <p class="font-bold text-violet-900">{{ tokenData.new_value }}</p>
          </div>

          <!-- Message d'avertissement -->
          <div class="bg-orange-50 border border-orange-200 rounded-lg p-4">
            <p class="text-xs text-orange-700">
              ⚠️ Cette modification est définitive. Assurez-vous que la nouvelle valeur est correcte.
            </p>
          </div>

          <!-- Boutons -->
          <div class="flex space-x-3">
            <button
              @click="router.push('/')"
              class="flex-1 py-3 px-4 bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium rounded-lg transition-colors"
            >
              Annuler
            </button>
            <button
              @click="confirmModification"
              :disabled="confirming"
              class="flex-1 py-3 px-4 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-medium rounded-lg hover:scale-105 transition-transform disabled:opacity-50 disabled:hover:scale-100"
            >
              {{ confirming ? 'Modification...' : 'Confirmer la modification' }}
            </button>
          </div>
        </div>

        <!-- Succès -->
        <div v-else-if="success" class="text-center py-8">
          <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <Check :size="32" class="text-green-600" />
          </div>
          <h2 class="text-xl font-bold text-gray-900 mb-2">Modification réussie !</h2>
          <p class="text-gray-600 mb-6">
            Votre {{ getFieldLabel(modifiedField) }} a été modifié avec succès.
          </p>
          <button
            @click="router.push('/')"
            class="px-6 py-2 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-medium rounded-lg hover:scale-105 transition-transform"
          >
            Retour à l'accueil
          </button>
        </div>
      </div>

      <!-- Footer -->
      <div class="text-center mt-8 text-sm text-gray-500">
        <p>© 2024 FidApp - Tous droits réservés</p>
        <p class="mt-2">
          Besoin d'aide ? Contactez votre commerçant
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Shield, X, Check } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

const router = useRouter()
const route = useRoute()

const loading = ref(true)
const error = ref(false)
const errorMessage = ref('')
const success = ref(false)
const confirming = ref(false)

const tokenData = ref<any>(null)
const modifiedField = ref('')

// Obtenir le label du champ
const getFieldLabel = (field: string) => {
  const labels: Record<string, string> = {
    email: 'adresse email',
    phone: 'numéro de téléphone',
    first_name: 'prénom',
    last_name: 'nom',
    address: 'adresse'
  }
  return labels[field] || field
}

// Vérifier le token au chargement
const checkToken = async () => {
  loading.value = true
  
  try {
    const token = route.query.token as string
    
    if (!token) {
      error.value = true
      errorMessage.value = 'Aucun token fourni dans le lien.'
      return
    }
    
    // Vérifier le token dans la base
    const { data, error: dbError } = await supabase
      .from('modification_tokens')
      .select('*')
      .eq('token', token)
      .eq('status', 'pending')
      .single()
    
    if (dbError || !data) {
      error.value = true
      errorMessage.value = 'Ce lien est invalide, a déjà été utilisé ou a expiré.'
      return
    }
    
    // Vérifier l'expiration
    const expiresAt = new Date(data.expires_at)
    if (expiresAt < new Date()) {
      error.value = true
      errorMessage.value = 'Ce lien a expiré. Veuillez demander un nouveau lien.'
      
      // Marquer comme expiré
      await supabase
        .from('modification_tokens')
        .update({ status: 'expired' })
        .eq('id', data.id)
      
      return
    }
    
    tokenData.value = data
  } catch (err) {
    console.error('Erreur lors de la vérification du token:', err)
    error.value = true
    errorMessage.value = 'Une erreur est survenue lors de la vérification du lien.'
  } finally {
    loading.value = false
  }
}

// Confirmer la modification
const confirmModification = async () => {
  if (!tokenData.value) return
  
  confirming.value = true
  
  try {
    const token = route.query.token as string
    
    // Utiliser la fonction SQL pour valider et appliquer la modification
    const { data, error: dbError } = await supabase.rpc('use_modification_token', {
      p_token: token,
      p_ip_address: null,
      p_user_agent: navigator.userAgent
    })
    
    if (dbError) {
      throw dbError
    }
    
    if (data && data.length > 0 && data[0].success) {
      modifiedField.value = tokenData.value.field_to_modify
      success.value = true
      tokenData.value = null
    } else {
      error.value = true
      errorMessage.value = data?.[0]?.message || 'Erreur lors de la modification'
    }
  } catch (err) {
    console.error('Erreur lors de la modification:', err)
    error.value = true
    errorMessage.value = 'Une erreur est survenue lors de la modification.'
  } finally {
    confirming.value = false
  }
}

onMounted(() => {
  checkToken()
})
</script>