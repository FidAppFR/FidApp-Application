<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50">
    <!-- Navbar -->
    <nav class="bg-white border-b border-gray-100 sticky top-0 z-50 backdrop-blur-md bg-white/95 shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16 lg:h-20">
          <!-- Logo -->
          <router-link to="/" class="flex items-center">
            <img 
              src="/Logo_Trans_unique.png" 
              alt="FidApp" 
              class="h-8 md:h-10"
            />
          </router-link>
          
          <!-- Actions -->
          <div class="flex items-center space-x-3">
            <!-- Sélecteur de langue -->
            <div class="relative">
              <button 
                @click="toggleLanguageMenu"
                class="flex items-center space-x-1.5 text-gray-600 hover:text-violet-600 font-medium px-3 py-2 rounded-lg hover:bg-violet-50 transition-all duration-200"
              >
                <Globe :size="18" />
                <span class="text-sm font-medium">{{ currentLanguage }}</span>
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                </svg>
              </button>
              
              <!-- Dropdown langue -->
              <div 
                v-if="showLanguageMenu"
                class="absolute right-0 mt-2 w-32 bg-white rounded-lg shadow-lg border border-gray-100 py-1 z-50"
              >
                <button 
                  @click="selectLanguage('FR')"
                  class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-violet-50 hover:text-violet-600 transition-colors flex items-center space-x-2"
                  :class="{ 'bg-violet-50 text-violet-600': currentLanguage === 'FR' }"
                >
                  <span>🇫🇷</span>
                  <span>Français</span>
                </button>
                <button 
                  @click="selectLanguage('EN')"
                  class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-violet-50 hover:text-violet-600 transition-colors flex items-center space-x-2"
                  :class="{ 'bg-violet-50 text-violet-600': currentLanguage === 'EN' }"
                >
                  <span>🇬🇧</span>
                  <span>English</span>
                </button>
              </div>
            </div>
            
            <!-- Bouton retour -->
            <button 
              @click="goBack"
              class="text-gray-600 hover:text-violet-600 font-medium flex items-center space-x-2 px-4 py-2 rounded-lg hover:bg-violet-50 transition-all duration-200"
            >
              <ArrowLeft :size="20" />
              <span>Retour</span>
            </button>
          </div>
        </div>
      </div>
    </nav>

    <!-- Contenu principal -->
    <div class="flex min-h-[calc(100vh-64px)] items-center justify-center px-4 py-12">
      <div class="w-full max-w-md">
        <!-- Card d'inscription -->
        <div class="bg-white rounded-2xl shadow-xl p-8">
          <!-- Header -->
          <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-violet-600 to-pink-600 rounded-2xl mb-4">
              <UserPlus :size="32" color="white" />
            </div>
            <h2 class="text-3xl font-black text-gray-900 mb-2">
              Créez votre compte
            </h2>
            <p class="text-gray-600">
              Inscrivez-vous pour vous lancer !
            </p>
            
            <!-- Affichage du plan sélectionné -->
            <div class="mt-4 p-3 bg-gradient-to-r from-violet-50 to-pink-50 rounded-xl border border-violet-200">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-xs text-gray-600">Plan sélectionné</p>
                  <p class="font-bold text-violet-600">{{ selectedPlanInfo.name }}</p>
                </div>
                <div class="text-right">
                  <p class="text-2xl font-black text-violet-600">{{ selectedPlanInfo.price }}</p>
                  <p class="text-xs text-gray-600">{{ selectedPlanInfo.duration }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Formulaire -->
          <form @submit.prevent="handleRegister" class="space-y-5">
            <!-- Nom de société -->
            <div>
              <label for="company" class="block text-sm font-semibold text-gray-700 mb-2">
                Nom de société <span class="text-red-500">*</span>
              </label>
              <div class="relative">
                <input
                  id="company"
                  v-model="formData.company"
                  type="text"
                  required
                  class="w-full px-4 py-3 pl-11 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                  placeholder="Votre entreprise"
                  @blur="validateCompany"
                />
                <Building2 :size="20" class="absolute left-3.5 top-3.5 text-gray-400" />
              </div>
              <span v-if="errors.company" class="text-red-500 text-xs mt-1 block">{{ errors.company }}</span>
            </div>

            <!-- Prénom et Nom sur la même ligne -->
            <div class="grid grid-cols-2 gap-4">
              <!-- Prénom -->
              <div>
                <label for="firstName" class="block text-sm font-semibold text-gray-700 mb-2">
                  Prénom <span class="text-red-500">*</span>
                </label>
                <input
                  id="firstName"
                  v-model="formData.firstName"
                  type="text"
                  required
                  class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                  placeholder="Jean"
                  @blur="validateFirstName"
                />
                <span v-if="errors.firstName" class="text-red-500 text-xs mt-1 block">{{ errors.firstName }}</span>
              </div>

              <!-- Nom -->
              <div>
                <label for="lastName" class="block text-sm font-semibold text-gray-700 mb-2">
                  Nom <span class="text-red-500">*</span>
                </label>
                <input
                  id="lastName"
                  v-model="formData.lastName"
                  type="text"
                  required
                  class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                  placeholder="Dupont"
                  @blur="validateLastName"
                />
                <span v-if="errors.lastName" class="text-red-500 text-xs mt-1 block">{{ errors.lastName }}</span>
              </div>
            </div>

            <!-- Email -->
            <div>
              <label for="email" class="block text-sm font-semibold text-gray-700 mb-2">
                Adresse email <span class="text-red-500">*</span>
              </label>
              <div class="relative">
                <input
                  id="email"
                  v-model="formData.email"
                  type="email"
                  required
                  class="w-full px-4 py-3 pl-11 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                  placeholder="vous@exemple.com"
                  @blur="validateEmail"
                />
                <Mail :size="20" class="absolute left-3.5 top-3.5 text-gray-400" />
              </div>
              <span v-if="errors.email" class="text-red-500 text-xs mt-1 block">{{ errors.email }}</span>
            </div>

            <!-- Mot de passe -->
            <div>
              <label for="password" class="block text-sm font-semibold text-gray-700 mb-2">
                Mot de passe <span class="text-red-500">*</span>
              </label>
              <div class="relative">
                <input
                  id="password"
                  v-model="formData.password"
                  :type="showPassword ? 'text' : 'password'"
                  required
                  class="w-full px-4 py-3 pl-11 pr-12 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                  placeholder="••••••••"
                  @blur="validatePassword"
                  @input="validatePassword"
                />
                <Lock :size="20" class="absolute left-3.5 top-3.5 text-gray-400" />
                <button
                  type="button"
                  @click="showPassword = !showPassword"
                  class="absolute right-3 top-3 text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <Eye v-if="!showPassword" :size="20" />
                  <EyeOff v-else :size="20" />
                </button>
              </div>
              
              <!-- Indicateurs de force du mot de passe -->
              <Transition
                enter-active-class="transition-all duration-300 ease-out"
                enter-from-class="opacity-0 -translate-y-2"
                enter-to-class="opacity-100 translate-y-0"
                leave-active-class="transition-all duration-200 ease-in"
                leave-from-class="opacity-100 translate-y-0"
                leave-to-class="opacity-0 -translate-y-2"
              >
                <div v-if="formData.password" class="mt-2 space-y-1">
                  <TransitionGroup
                    enter-active-class="transition-all duration-300 ease-out"
                    enter-from-class="opacity-0 -translate-x-4"
                    enter-to-class="opacity-100 translate-x-0"
                    leave-active-class="transition-all duration-200 ease-in"
                    leave-from-class="opacity-100 translate-x-0"
                    leave-to-class="opacity-0 -translate-x-4"
                  >
                    <div key="length" class="flex items-center gap-2" :style="{ transitionDelay: '0ms' }">
                      <div :class="passwordStrength.hasLength ? 'text-green-500' : 'text-gray-400'" class="transition-colors duration-300">
                        <Check v-if="passwordStrength.hasLength" :size="14" />
                        <X v-else :size="14" />
                      </div>
                      <span :class="passwordStrength.hasLength ? 'text-green-600 text-xs' : 'text-gray-500 text-xs'" class="transition-colors duration-300">
                        Au moins 8 caractères
                      </span>
                    </div>
                    <div key="uppercase" class="flex items-center gap-2" :style="{ transitionDelay: '50ms' }">
                      <div :class="passwordStrength.hasUpperCase ? 'text-green-500' : 'text-gray-400'" class="transition-colors duration-300">
                        <Check v-if="passwordStrength.hasUpperCase" :size="14" />
                        <X v-else :size="14" />
                      </div>
                      <span :class="passwordStrength.hasUpperCase ? 'text-green-600 text-xs' : 'text-gray-500 text-xs'" class="transition-colors duration-300">
                        Au moins une majuscule
                      </span>
                    </div>
                    <div key="lowercase" class="flex items-center gap-2" :style="{ transitionDelay: '100ms' }">
                      <div :class="passwordStrength.hasLowerCase ? 'text-green-500' : 'text-gray-400'" class="transition-colors duration-300">
                        <Check v-if="passwordStrength.hasLowerCase" :size="14" />
                        <X v-else :size="14" />
                      </div>
                      <span :class="passwordStrength.hasLowerCase ? 'text-green-600 text-xs' : 'text-gray-500 text-xs'" class="transition-colors duration-300">
                        Au moins une minuscule
                      </span>
                    </div>
                    <div key="number" class="flex items-center gap-2" :style="{ transitionDelay: '150ms' }">
                      <div :class="passwordStrength.hasNumber ? 'text-green-500' : 'text-gray-400'" class="transition-colors duration-300">
                        <Check v-if="passwordStrength.hasNumber" :size="14" />
                        <X v-else :size="14" />
                      </div>
                      <span :class="passwordStrength.hasNumber ? 'text-green-600 text-xs' : 'text-gray-500 text-xs'" class="transition-colors duration-300">
                        Au moins un chiffre
                      </span>
                    </div>
                    <div key="special" class="flex items-center gap-2" :style="{ transitionDelay: '200ms' }">
                      <div :class="passwordStrength.hasSpecial ? 'text-green-500' : 'text-gray-400'" class="transition-colors duration-300">
                        <Check v-if="passwordStrength.hasSpecial" :size="14" />
                        <X v-else :size="14" />
                      </div>
                      <span :class="passwordStrength.hasSpecial ? 'text-green-600 text-xs' : 'text-gray-500 text-xs'" class="transition-colors duration-300">
                        Au moins un caractère spécial (!@#$%^&*)
                      </span>
                    </div>
                  </TransitionGroup>
                </div>
              </Transition>
              <span v-if="errors.password" class="text-red-500 text-xs mt-1 block">{{ errors.password }}</span>
            </div>

            <!-- Confirmation du mot de passe -->
            <Transition
              enter-active-class="transition-all duration-300 ease-out"
              enter-from-class="opacity-0 -translate-y-2"
              enter-to-class="opacity-100 translate-y-0"
              leave-active-class="transition-all duration-200 ease-in"
              leave-from-class="opacity-100 translate-y-0"
              leave-to-class="opacity-0 -translate-y-2"
            >
              <div v-if="formData.password">
                <label for="confirmPassword" class="block text-sm font-semibold text-gray-700 mb-2">
                  Confirmer le mot de passe <span class="text-red-500">*</span>
                </label>
                <div class="relative">
                  <input
                    id="confirmPassword"
                    v-model="formData.confirmPassword"
                    :type="showConfirmPassword ? 'text' : 'password'"
                    required
                    class="w-full px-4 py-3 pl-11 pr-12 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                    placeholder="••••••••"
                    @blur="validateConfirmPassword"
                    @input="validateConfirmPassword"
                  />
                  <Lock :size="20" class="absolute left-3.5 top-3.5 text-gray-400" />
                  <button
                    type="button"
                    @click="showConfirmPassword = !showConfirmPassword"
                    class="absolute right-3 top-3 text-gray-400 hover:text-gray-600 transition-colors"
                  >
                    <Eye v-if="!showConfirmPassword" :size="20" />
                    <EyeOff v-else :size="20" />
                  </button>
                </div>
                
                <!-- Indicateur de correspondance -->
                <div v-if="formData.confirmPassword" class="mt-2">
                  <div class="flex items-center gap-2">
                    <div :class="passwordsMatch ? 'text-green-500' : 'text-red-500'">
                      <Check v-if="passwordsMatch" :size="14" />
                      <X v-else :size="14" />
                    </div>
                    <span :class="passwordsMatch ? 'text-green-600 text-xs' : 'text-red-600 text-xs'">
                      {{ passwordsMatch ? 'Les mots de passe correspondent' : 'Les mots de passe ne correspondent pas' }}
                    </span>
                  </div>
                </div>
              </div>
            </Transition>

            <!-- Consentements -->
            <div class="space-y-3 p-4 bg-gray-50 rounded-xl">
              <label class="flex items-start space-x-2 cursor-pointer">
                <input
                  v-model="formData.acceptTerms"
                  type="checkbox"
                  class="w-4 h-4 mt-0.5 text-violet-600 border-2 border-gray-300 rounded focus:ring-violet-500 focus:ring-2"
                  required
                />
                <span class="text-xs text-gray-600">
                  J'accepte les <a href="#" class="text-violet-600 hover:underline">conditions d'utilisation</a> 
                  et la <a href="#" class="text-violet-600 hover:underline">politique de confidentialité</a> <span class="text-red-500">*</span>
                </span>
              </label>
              
              <label class="flex items-start space-x-2 cursor-pointer">
                <input
                  v-model="formData.acceptNewsletter"
                  type="checkbox"
                  class="w-4 h-4 mt-0.5 text-violet-600 border-2 border-gray-300 rounded focus:ring-violet-500 focus:ring-2"
                />
                <span class="text-xs text-gray-600">
                  J'accepte de recevoir des communications marketing et des offres promotionnelles
                </span>
              </label>
            </div>

            <!-- Bouton d'inscription -->
            <button
              type="submit"
              :disabled="!isFormValid"
              class="relative group w-full bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold py-4 px-6 rounded-full transition-all duration-300 hover:scale-105 shadow-lg hover:shadow-xl disabled:opacity-50 disabled:hover:scale-100 disabled:cursor-not-allowed"
            >
              <span class="relative z-10 flex items-center justify-center space-x-2">
                <span>Créer mon compte</span>
                <ArrowRight :size="20" />
              </span>
              <div class="absolute inset-0 bg-gradient-to-r from-violet-700 to-pink-700 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            </button>
          </form>

          <!-- Connexion -->
          <p class="text-center mt-8 text-sm text-gray-600">
            Déjà un compte ?
            <router-link to="/login" class="text-violet-600 hover:text-violet-700 font-semibold">
              Se connecter
            </router-link>
          </p>
        </div>
        
        <!-- Liens discrets -->
        <div class="mt-3">
          <div class="flex justify-center items-center space-x-6 text-xs">
            <a href="#help" class="text-gray-500 hover:text-violet-600 transition-colors">
              Aide
            </a>
            <span class="text-gray-300">•</span>
            <a href="#privacy" class="text-gray-500 hover:text-violet-600 transition-colors">
              Confidentialité
            </a>
            <span class="text-gray-300">•</span>
            <a href="#terms" class="text-gray-500 hover:text-violet-600 transition-colors">
              Conditions
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { UserPlus, Building2, Mail, Lock, Eye, EyeOff, ArrowRight, ArrowLeft, Globe, Check, X } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

const router = useRouter()
const route = useRoute()

const formData = ref({
  company: '',
  firstName: '',
  lastName: '',
  email: '',
  password: '',
  confirmPassword: '',
  acceptTerms: false,
  acceptNewsletter: false,
  selectedPlan: 'free' // Plan par défaut
})

const errors = ref({
  company: '',
  firstName: '',
  lastName: '',
  email: '',
  password: '',
  confirmPassword: ''
})

const showPassword = ref(false)
const showConfirmPassword = ref(false)
const showLanguageMenu = ref(false)
const currentLanguage = ref('FR')

// Plans disponibles
const plans = {
  free: { name: 'Essai Gratuit', price: '0€', duration: '14 jours' },
  starter: { name: 'Plan Starter', price: '19,99€', duration: '/mois' },
  premium: { name: 'Plan Premium', price: '39,99€', duration: '/mois' }
}

const selectedPlanInfo = computed(() => {
  return plans[formData.value.selectedPlan as keyof typeof plans] || plans.free
})

// Validation du mot de passe selon CNIL
const passwordStrength = computed(() => {
  const password = formData.value.password
  return {
    hasLength: password.length >= 8,
    hasUpperCase: /[A-Z]/.test(password),
    hasLowerCase: /[a-z]/.test(password),
    hasNumber: /\d/.test(password),
    hasSpecial: /[!@#$%^&*(),.?":{}|<>]/.test(password)
  }
})

const isPasswordValid = computed(() => {
  return passwordStrength.value.hasLength &&
         passwordStrength.value.hasUpperCase &&
         passwordStrength.value.hasLowerCase &&
         passwordStrength.value.hasNumber &&
         passwordStrength.value.hasSpecial
})

const passwordsMatch = computed(() => {
  return formData.value.password === formData.value.confirmPassword && formData.value.confirmPassword !== ''
})

const isFormValid = computed(() => {
  return formData.value.company && 
         formData.value.firstName &&
         formData.value.lastName &&
         formData.value.email && 
         formData.value.password && 
         formData.value.confirmPassword &&
         formData.value.acceptTerms &&
         !errors.value.company &&
         !errors.value.firstName &&
         !errors.value.lastName &&
         !errors.value.email &&
         !errors.value.password &&
         !errors.value.confirmPassword &&
         isPasswordValid.value &&
         passwordsMatch.value
})

const toggleLanguageMenu = () => {
  showLanguageMenu.value = !showLanguageMenu.value
}

const selectLanguage = (lang: string) => {
  currentLanguage.value = lang
  showLanguageMenu.value = false
  console.log('Language changed to:', lang)
}

const goBack = () => {
  if (window.history.length > 1) {
    router.back()
  } else {
    router.push('/')
  }
}

const validateCompany = () => {
  if (formData.value.company.length < 2) {
    errors.value.company = 'Le nom de société doit contenir au moins 2 caractères'
  } else {
    errors.value.company = ''
  }
}

const validateFirstName = () => {
  if (formData.value.firstName.length < 2) {
    errors.value.firstName = 'Le prénom doit contenir au moins 2 caractères'
  } else {
    errors.value.firstName = ''
  }
}

const validateLastName = () => {
  if (formData.value.lastName.length < 2) {
    errors.value.lastName = 'Le nom doit contenir au moins 2 caractères'
  } else {
    errors.value.lastName = ''
  }
}

const validateEmail = () => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(formData.value.email)) {
    errors.value.email = 'Veuillez entrer une adresse email valide'
  } else {
    errors.value.email = ''
  }
}

const validatePassword = () => {
  if (!isPasswordValid.value) {
    errors.value.password = 'Le mot de passe ne respecte pas tous les critères'
  } else {
    errors.value.password = ''
  }
}

const validateConfirmPassword = () => {
  // On ne met plus de message d'erreur ici car on affiche déjà l'indicateur visuel
  errors.value.confirmPassword = ''
}

const handleRegister = async () => {
  validateCompany()
  validateFirstName()
  validateLastName()
  validateEmail()
  validatePassword()
  validateConfirmPassword()
  
  if (isFormValid.value) {
    try {
      // Créer l'utilisateur dans Supabase Auth
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: formData.value.email,
        password: formData.value.password,
        options: {
          data: {
            company: formData.value.company,
            first_name: formData.value.firstName,
            last_name: formData.value.lastName,
            accept_terms: formData.value.acceptTerms,
            accept_newsletter: formData.value.acceptNewsletter,
            selected_plan: formData.value.selectedPlan
          }
        }
      })

      if (authError) {
        console.error('Erreur d\'inscription:', authError)
        errors.value.email = authError.message
        return
      }

      if (authData.user) {
        console.log('✅ Inscription réussie!', authData.user)
        
        // Afficher un message de succès
        alert('Inscription réussie! Vérifiez votre email pour confirmer votre compte.')
        
        // Redirection vers la page de connexion
        router.push('/login')
      }
    } catch (error) {
      console.error('Erreur lors de l\'inscription:', error)
      errors.value.email = 'Une erreur est survenue lors de l\'inscription'
    }
  }
}

// Récupérer le plan depuis l'URL au montage
onMounted(() => {
  const plan = route.query.plan as string
  if (plan && (plan === 'free' || plan === 'starter' || plan === 'premium')) {
    formData.value.selectedPlan = plan
  }
})

// Fermer le menu langue quand on clique ailleurs
if (typeof window !== 'undefined') {
  window.addEventListener('click', (e) => {
    const target = e.target as HTMLElement
    if (!target.closest('.relative')) {
      showLanguageMenu.value = false
    }
  })
}
</script>