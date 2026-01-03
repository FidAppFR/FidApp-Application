<template>
  <div class="min-h-screen bg-gradient-to-br from-violet-50 via-white to-pink-50 py-8 px-4">
    <div class="max-w-md w-full mx-auto">
      <!-- Logo et titre -->
      <div class="text-center mb-8">
        <div class="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-r from-violet-600 to-pink-600 rounded-2xl mb-4">
          <CreditCard :size="40" class="text-white" />
        </div>
        <h1 class="text-3xl font-black text-gray-900">Espace Client Fidélité</h1>
        <p class="text-gray-600 mt-2">{{ companyName }}</p>
      </div>

      <!-- Connexion -->
      <div v-if="!showRegisterForm && !showOtpForm" class="bg-white rounded-2xl shadow-xl p-8">
        <h2 class="text-xl font-bold text-gray-900 mb-6">Connexion</h2>
        
        <form @submit.prevent="handleLogin" class="space-y-4">
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">
              Connexion avec email ou téléphone
            </label>
            <div class="relative">
              <input
                v-model="loginIdentifier"
                type="text"
                class="w-full px-4 py-3 pl-12 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                placeholder="email@exemple.com ou 0612345678"
                required
              />
              <div class="absolute left-4 top-1/2 -translate-y-1/2">
                <Mail v-if="isEmail(loginIdentifier)" :size="20" class="text-gray-400" />
                <Phone v-else :size="20" class="text-gray-400" />
              </div>
            </div>
            <p class="text-xs text-gray-500 mt-2">
              Utilisez l'email ou le téléphone avec lequel vous vous êtes inscrit
            </p>
          </div>

          <!-- Message d'erreur -->
          <div v-if="errorMessage" class="bg-red-50 border-l-4 border-red-500 rounded-lg p-4 animate-shake">
            <div class="flex items-start space-x-2">
              <AlertCircle :size="20" class="text-red-500 flex-shrink-0 mt-0.5" />
              <p class="text-sm text-red-700 font-medium">{{ errorMessage }}</p>
            </div>
          </div>

          <button
            type="submit"
            :disabled="loading || !loginIdentifier.trim()"
            class="w-full bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold py-3 rounded-xl hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:hover:scale-100 disabled:cursor-not-allowed"
          >
            {{ loading ? 'Envoi...' : 'Recevoir le code' }}
          </button>
        </form>

        <div class="mt-6 pt-6 border-t border-gray-200">
          <p class="text-center text-gray-600 mb-3">Pas encore de compte ?</p>
          <button
            @click="showRegisterForm = true"
            class="w-full py-3 border-2 border-violet-600 text-violet-600 font-bold rounded-xl hover:bg-violet-50 transition-colors"
          >
            Créer un compte client
          </button>
        </div>
      </div>

      <!-- Formulaire d'inscription -->
      <div v-else-if="showRegisterForm && !showOtpForm" class="bg-white rounded-2xl shadow-xl overflow-hidden mb-2">
        <!-- Header -->
        <div class="bg-gradient-to-r from-violet-600 to-pink-600 p-6 text-white">
          <h2 class="text-2xl font-bold">Créer votre compte client</h2>
          <p class="text-white/80 text-sm mt-1">Rejoignez le programme de fidélité</p>
        </div>
        
        <!-- Formulaire -->
        <div class="p-8">
          <form @submit.prevent="handleRegister" class="space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Prénom *
              </label>
              <input
                v-model="registerData.first_name"
                type="text"
                class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Nom *
              </label>
              <input
                v-model="registerData.last_name"
                type="text"
                class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                required
              />
            </div>
          </div>

          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">
              Date de naissance
            </label>
            <input
              v-model="registerData.date_of_birth"
              type="date"
              class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
            />
          </div>

          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">
              Email *
            </label>
            <input
              v-model="registerData.email"
              type="email"
              class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
              placeholder="email@exemple.com"
              required
            />
          </div>

          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">
              Téléphone (optionnel)
            </label>
            <input
              v-model="registerData.phone"
              type="tel"
              class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
              placeholder="0612345678"
            />
            <p class="text-xs text-gray-500 mt-1">
              Optionnel : pour recevoir des SMS de notifications
            </p>
          </div>

            <!-- Consentements et mentions -->
            <div class="space-y-3 p-4 bg-gray-50 rounded-xl">
              <!-- Conditions d'utilisation -->
              <label class="flex items-start space-x-2 cursor-pointer">
                <input
                  v-model="acceptTerms"
                  type="checkbox"
                  class="w-4 h-4 mt-0.5 text-violet-600 border-2 border-gray-300 rounded focus:ring-violet-500 focus:ring-2"
                  required
                />
                <span class="text-xs text-gray-600">
                  J'accepte les <a href="#" class="text-violet-600 hover:underline">conditions d'utilisation</a> 
                  et la <a href="#" class="text-violet-600 hover:underline">politique de confidentialité</a> <span class="text-red-500">*</span>
                </span>
              </label>
              
              <!-- Newsletter -->
              <label class="flex items-start space-x-2 cursor-pointer">
                <input
                  v-model="acceptMarketing"
                  type="checkbox"
                  class="w-4 h-4 mt-0.5 text-violet-600 border-2 border-gray-300 rounded focus:ring-violet-500 focus:ring-2"
                />
                <span class="text-xs text-gray-600">
                  J'accepte de recevoir des offres promotionnelles et des actualités du programme de fidélité
                </span>
              </label>
              
              <!-- Offres partenaires -->
              <label class="flex items-start space-x-2 cursor-pointer">
                <input
                  v-model="acceptPartners"
                  type="checkbox"
                  class="w-4 h-4 mt-0.5 text-violet-600 border-2 border-gray-300 rounded focus:ring-violet-500 focus:ring-2"
                />
                <span class="text-xs text-gray-600">
                  J'accepte de recevoir des offres de nos partenaires sélectionnés
                </span>
              </label>
            </div>

            <!-- Message d'erreur -->
            <div v-if="errorMessage" class="bg-red-50 border-l-4 border-red-500 rounded-lg p-4 animate-shake">
              <div class="flex items-start space-x-2">
                <AlertCircle :size="20" class="text-red-500 flex-shrink-0 mt-0.5" />
                <p class="text-sm text-red-700 font-medium">{{ errorMessage }}</p>
              </div>
            </div>

            <!-- Boutons -->
            <div class="space-y-3 pt-4">
              <button
                type="submit"
                :disabled="loading || !acceptTerms || !registerData.first_name.trim() || !registerData.last_name.trim() || !registerData.email.trim()"
                class="w-full bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold py-3 rounded-xl hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:hover:scale-100 disabled:cursor-not-allowed"
              >
                {{ loading ? 'Création en cours...' : 'Créer mon compte' }}
              </button>

              <button
                type="button"
                @click="showRegisterForm = false"
                class="w-full py-3 text-gray-600 font-medium hover:text-gray-800 transition-colors"
              >
                Déjà un compte ? <span class="text-violet-600 hover:text-violet-700">Se connecter</span>
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Vérification OTP -->
      <div v-else-if="showOtpForm" class="bg-white rounded-2xl shadow-xl p-8">
        <div class="text-center mb-6">
          <div class="w-16 h-16 bg-violet-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <Shield :size="32" class="text-violet-600" />
          </div>
          <h2 class="text-xl font-bold text-gray-900">Vérification</h2>
          <p class="text-gray-600 mt-2">
            Un code a été envoyé {{ otpSentTo.includes('@') ? 'par email' : 'par SMS' }} à<br>
            <span class="font-medium">{{ otpSentTo }}</span>
          </p>
        </div>

        <form @submit.prevent="verifyOtp" class="space-y-4">
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">
              Code de vérification
            </label>
            <input
              v-model="otpCode"
              type="text"
              maxlength="6"
              class="w-full px-4 py-3 text-center text-2xl font-mono border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors tracking-widest"
              placeholder="000000"
              required
            />
          </div>

          <!-- Message d'erreur -->
          <div v-if="errorMessage" class="bg-red-50 border border-red-200 rounded-lg p-3">
            <p class="text-sm text-red-700">{{ errorMessage }}</p>
          </div>

          <button
            type="submit"
            :disabled="loading || otpCode.length !== 6"
            class="w-full bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold py-3 rounded-xl hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:hover:scale-100"
          >
            {{ loading ? 'Vérification...' : 'Vérifier le code' }}
          </button>

          <div class="flex items-center justify-between pt-4">
            <button
              type="button"
              @click="resendOtp"
              :disabled="resendCooldown > 0"
              class="text-violet-600 hover:text-violet-700 font-medium text-sm disabled:text-gray-400"
            >
              {{ resendCooldown > 0 ? `Renvoyer (${resendCooldown}s)` : 'Renvoyer le code' }}
            </button>
            <button
              type="button"
              @click="cancelOtp"
              class="text-gray-600 hover:text-gray-800 font-medium text-sm"
            >
              Annuler
            </button>
          </div>
        </form>
      </div>

      <!-- Footer avec liens -->
      <div class="mt-2 text-center">
        <div class="flex items-center justify-center space-x-4 text-sm text-gray-600">
          <button class="hover:text-violet-600 transition-colors">Aide</button>
          <span>•</span>
          <button class="hover:text-violet-600 transition-colors">Confidentialité</button>
          <span>•</span>
          <button class="hover:text-violet-600 transition-colors">Conditions</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style>
@keyframes shake {
  0%, 100% { transform: translateX(0); }
  10%, 30%, 50%, 70%, 90% { transform: translateX(-2px); }
  20%, 40%, 60%, 80% { transform: translateX(2px); }
}

.animate-shake {
  animation: shake 0.5s;
}
</style>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { CreditCard, Mail, Phone, Shield, AlertCircle } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

const router = useRouter()
const route = useRoute()

// États
const showRegisterForm = ref(false)
const showOtpForm = ref(false)
const loading = ref(false)
const errorMessage = ref('')
const companyName = ref('FidApp')
const companyId = ref<string | null>(null)

// Données de connexion
const loginIdentifier = ref('')
const otpCode = ref('')
const otpSentTo = ref('')
const customerId = ref<string | null>(null)

// Données d'inscription
const registerData = ref({
  first_name: '',
  last_name: '',
  date_of_birth: '',
  email: '',
  phone: ''
})

// Consentements
const acceptTerms = ref(false)
const acceptMarketing = ref(false)
const acceptPartners = ref(false)

// Cooldown pour renvoyer l'OTP
const resendCooldown = ref(0)
let cooldownInterval: number | null = null

// Vérifier si c'est un email
const isEmail = (value: string) => {
  return value.includes('@')
}

// Générer un code OTP
const generateOtp = () => {
  return Math.floor(100000 + Math.random() * 900000).toString()
}

// Charger les infos de l'entreprise
const loadCompanyInfo = async () => {
  try {
    // Récupérer l'ID de l'entreprise depuis l'URL ou autre source
    const companyParam = route.query.company as string
    
    if (!companyParam) {
      console.error('Pas de paramètre company dans l\'URL')
      errorMessage.value = 'Lien invalide. Veuillez utiliser le lien fourni par votre commerçant.'
      return
    }
    
    console.log('Chargement des infos pour company_id:', companyParam)
    
    const { data, error } = await supabase
      .from('users')
      .select('id, company')
      .eq('id', companyParam)
      .single()
    
    if (error) {
      console.error('Erreur lors de la récupération de l\'entreprise:', error)
      errorMessage.value = 'Entreprise non trouvée. Veuillez vérifier le lien.'
      return
    }
    
    if (data) {
      companyId.value = data.id
      companyName.value = data.company || 'FidApp'
      console.log('Entreprise trouvée:', companyName.value, 'ID:', companyId.value)
    }
  } catch (error) {
    console.error('Erreur lors du chargement des infos entreprise:', error)
    errorMessage.value = 'Erreur lors du chargement. Veuillez rafraîchir la page.'
  }
}

// Gérer la connexion
const handleLogin = async () => {
  loading.value = true
  errorMessage.value = ''
  
  // Vérifier qu'on a bien un company_id
  if (!companyId.value) {
    errorMessage.value = 'Erreur: Entreprise non identifiée. Veuillez utiliser le lien fourni par votre commerçant.'
    loading.value = false
    return
  }
  
  try {
    const identifier = loginIdentifier.value.trim()
    
    // Vérifier que l'identifiant n'est pas vide
    if (!identifier) {
      errorMessage.value = 'Veuillez entrer votre email ou numéro de téléphone'
      loading.value = false
      return
    }
    
    const isEmailLogin = isEmail(identifier)
    
    // Vérifier si le client existe avec email OU téléphone
    let customer = null
    let searchType = ''
    
    if (isEmailLogin) {
      // Rechercher par email
      const { data: emailCustomer } = await supabase
        .from('customers')
        .select('id, first_name, last_name, is_verified, email, phone')
        .eq('company_id', companyId.value)
        .eq('email', identifier)
        .single()
      
      customer = emailCustomer
      searchType = 'email'
    } else {
      // Rechercher par téléphone d'abord
      const { data: phoneCustomer } = await supabase
        .from('customers')
        .select('id, first_name, last_name, is_verified, email, phone')
        .eq('company_id', companyId.value)
        .eq('phone', identifier)
        .single()
      
      if (phoneCustomer) {
        customer = phoneCustomer
        searchType = 'phone'
      } else {
        // Si pas trouvé par téléphone et que ça ressemble à un email incomplet, 
        // suggérer d'utiliser l'email
        errorMessage.value = `Aucun compte trouvé avec le numéro "${identifier}". Si vous avez créé votre compte avec un email, veuillez utiliser votre adresse email complète pour vous connecter.`
        loading.value = false
        return
      }
    }
    
    if (!customer) {
      // Message d'erreur spécifique selon le type d'identifiant
      if (isEmailLogin) {
        errorMessage.value = `Aucun compte trouvé avec l'email "${identifier}". Veuillez vérifier l'adresse email ou créer un nouveau compte.`
      } else {
        errorMessage.value = `Aucun compte trouvé avec le numéro "${identifier}". Veuillez vérifier le numéro ou créer un nouveau compte.`
      }
      loading.value = false
      return
    }
    
    // Générer et "envoyer" l'OTP (simulé)
    const otp = generateOtp()
    console.log('OTP généré:', otp) // En production, envoyer par email/SMS
    
    // Mettre à jour l'OTP dans la base
    await supabase
      .from('customers')
      .update({
        last_otp_code: otp,
        last_otp_sent_at: new Date().toISOString(),
        otp_attempts: 0
      })
      .eq('id', customer.id)
    
    customerId.value = customer.id
    
    // Déterminer où envoyer l'OTP basé sur ce qui est disponible
    if (searchType === 'email' || !customer.phone) {
      // Envoyer par email si recherché par email ou si pas de téléphone
      otpSentTo.value = customer.email
      alert(`Code de vérification: ${otp}\n(En production, envoyé par email à ${customer.email})`)
    } else {
      // Envoyer par SMS si trouvé par téléphone et qu'il existe
      otpSentTo.value = customer.phone
      alert(`Code de vérification: ${otp}\n(En production, envoyé par SMS au ${customer.phone})`)
    }
    
    showOtpForm.value = true
    startResendCooldown()
    
  } catch (error) {
    console.error('Erreur lors de la connexion:', error)
    errorMessage.value = 'Une erreur est survenue'
  } finally {
    loading.value = false
  }
}

// Gérer l'inscription
const handleRegister = async () => {
  loading.value = true
  errorMessage.value = ''
  
  // Vérifier qu'on a bien un company_id
  if (!companyId.value) {
    errorMessage.value = 'Erreur: Entreprise non identifiée. Veuillez utiliser le lien fourni par votre commerçant.'
    loading.value = false
    return
  }
  
  // Vérifier que les conditions sont acceptées
  if (!acceptTerms.value) {
    errorMessage.value = 'Vous devez accepter les conditions d\'utilisation pour créer un compte.'
    loading.value = false
    return
  }
  
  console.log('Création de compte pour company_id:', companyId.value)
  console.log('Données du formulaire:', registerData.value)
  console.log('Consentements:', { terms: acceptTerms.value, marketing: acceptMarketing.value, partners: acceptPartners.value })
  
  try {
    // Vérifier si le client existe déjà
    const { data: existing } = await supabase
      .from('customers')
      .select('id')
      .eq('company_id', companyId.value)
      .eq('email', registerData.value.email)
      .single()
    
    if (existing) {
      errorMessage.value = 'Un compte existe déjà avec cet email'
      loading.value = false
      return
    }
    
    // Récupérer les points d'inscription configurés pour cette entreprise
    const { data: companySettings } = await supabase
      .from('users')
      .select('signup_points')
      .eq('id', companyId.value)
      .single()
    
    const signupPoints = companySettings?.signup_points || 50 // Par défaut 50 si non configuré
    
    // Créer le compte client
    const otp = generateOtp()
    
    // Préparer les données avec les consentements
    const customerData = {
      company_id: companyId.value,
      ...registerData.value,
      last_otp_code: otp,
      last_otp_sent_at: new Date().toISOString(),
      points: signupPoints, // Points de bienvenue configurables
      accept_terms: acceptTerms.value,
      accept_marketing: acceptMarketing.value,
      accept_partners: acceptPartners.value,
      consent_updated_at: new Date().toISOString()
    }
    
    const { data: newCustomer, error } = await supabase
      .from('customers')
      .insert(customerData)
      .select()
      .single()
    
    if (error) {
      console.error('Erreur création compte:', error)
      // Afficher plus de détails sur l'erreur
      if (error.code === '23505') {
        errorMessage.value = 'Un compte existe déjà avec cet email pour cette entreprise'
      } else if (error.code === '23503') {
        errorMessage.value = 'Entreprise non trouvée. Veuillez vérifier le lien.'
      } else if (error.message?.includes('customers')) {
        errorMessage.value = `Erreur base de données: ${error.message}`
      } else {
        errorMessage.value = 'Erreur lors de la création du compte. Veuillez réessayer.'
      }
      loading.value = false
      return
    }
    
    // Créer l'enregistrement dans l'historique pour les points de bienvenue
    if (signupPoints > 0) {
      const { error: historyError } = await supabase
        .from('points_history')
        .insert({
          customer_id: newCustomer.id,
          company_id: companyId.value,
          points_amount: signupPoints,
          points_before: 0,
          points_after: signupPoints,
          transaction_type: 'welcome',
          description: 'Points de bienvenue'
        })
      
      if (historyError) {
        console.error('Erreur lors de l\'enregistrement de l\'historique:', historyError)
        // Ne pas bloquer l'inscription même si l'historique échoue
      }
    }
    
    customerId.value = newCustomer.id
    otpSentTo.value = registerData.value.email
    showOtpForm.value = true
    showRegisterForm.value = false
    startResendCooldown()
    
    // Simuler l'envoi
    alert(`Code de vérification: ${otp}\n(En production, envoyé par email)`)
    
  } catch (error) {
    console.error('Erreur lors de l\'inscription:', error)
    errorMessage.value = 'Une erreur est survenue'
  } finally {
    loading.value = false
  }
}

// Vérifier l'OTP
const verifyOtp = async () => {
  loading.value = true
  errorMessage.value = ''
  
  try {
    // Vérifier l'OTP
    const { data: customer } = await supabase
      .from('customers')
      .select('*')
      .eq('id', customerId.value)
      .eq('last_otp_code', otpCode.value)
      .single()
    
    if (!customer) {
      errorMessage.value = 'Code incorrect'
      loading.value = false
      return
    }
    
    // Vérifier l'expiration (10 minutes)
    const otpAge = Date.now() - new Date(customer.last_otp_sent_at).getTime()
    if (otpAge > 10 * 60 * 1000) {
      errorMessage.value = 'Code expiré'
      loading.value = false
      return
    }
    
    // Marquer comme vérifié
    await supabase
      .from('customers')
      .update({ 
        is_verified: true,
        last_visit_at: new Date().toISOString()
      })
      .eq('id', customerId.value)
    
    // Stocker les infos client dans le localStorage
    localStorage.setItem('customer_session', JSON.stringify({
      id: customer.id,
      company_id: customer.company_id,
      email: customer.email,
      name: `${customer.first_name} ${customer.last_name}`,
      points: customer.points
    }))
    
    // Rediriger vers la vue client
    router.push(`/client-view?company=${companyId.value}`)
    
  } catch (error) {
    console.error('Erreur lors de la vérification:', error)
    errorMessage.value = 'Une erreur est survenue'
  } finally {
    loading.value = false
  }
}

// Renvoyer l'OTP
const resendOtp = async () => {
  if (resendCooldown.value > 0) return
  
  const otp = generateOtp()
  
  await supabase
    .from('customers')
    .update({
      last_otp_code: otp,
      last_otp_sent_at: new Date().toISOString(),
      otp_attempts: 0
    })
    .eq('id', customerId.value)
  
  alert(`Nouveau code: ${otp}\n(En production, envoyé par ${otpSentTo.value.includes('@') ? 'email' : 'SMS'})`)
  startResendCooldown()
}

// Annuler la vérification OTP
const cancelOtp = () => {
  showOtpForm.value = false
  otpCode.value = ''
  errorMessage.value = ''
  customerId.value = null
}

// Démarrer le cooldown
const startResendCooldown = () => {
  resendCooldown.value = 60
  cooldownInterval = setInterval(() => {
    resendCooldown.value--
    if (resendCooldown.value <= 0 && cooldownInterval) {
      clearInterval(cooldownInterval)
      cooldownInterval = null
    }
  }, 1000) as unknown as number
}

onMounted(() => {
  loadCompanyInfo()
})

onUnmounted(() => {
  if (cooldownInterval) {
    clearInterval(cooldownInterval)
  }
})
</script>