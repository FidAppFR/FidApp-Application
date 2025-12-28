<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50">
    <!-- Écran de chargement -->
    <Teleport to="body">
      <Transition
        enter-active-class="duration-0"
        enter-from-class=""
        enter-to-class=""
        leave-active-class="transition-opacity duration-300"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div
          v-if="isLoading"
          class="fixed inset-0 bg-white z-[999999] flex items-center justify-center"
          style="position: fixed !important; top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important; width: 100vw !important; height: 100vh !important;"
        >
          <div class="flex flex-col items-center space-y-4">
            <div class="relative">
              <div class="absolute inset-0 bg-gradient-to-r from-violet-600 to-pink-600 rounded-full blur-xl opacity-30 animate-pulse"></div>
              <div class="relative bg-white rounded-2xl p-6 shadow-xl">
                <Loader2 :size="48" class="text-violet-600 animate-spin" />
              </div>
            </div>
            <p class="text-lg font-semibold text-gray-700">Connexion en cours...</p>
            <div class="w-48 h-1 bg-gray-200 rounded-full overflow-hidden">
              <div class="h-full bg-gradient-to-r from-violet-600 to-pink-600 rounded-full animate-[loading_0.8s_ease-in-out_infinite]"></div>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
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
        <!-- Card de connexion -->
        <div class="bg-white rounded-2xl shadow-xl p-8">
          <!-- Header -->
          <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-violet-600 to-pink-600 rounded-2xl mb-4">
              <User :size="32" color="white" />
            </div>
            <h2 class="text-3xl font-black text-gray-900 mb-2">
              Bon retour !
            </h2>
            <p class="text-gray-600">
              Connectez-vous pour accéder à votre espace
            </p>
          </div>

          <!-- Formulaire -->
          <form @submit.prevent="handleLogin" class="space-y-5">
            <!-- Email -->
            <div>
              <label for="email" class="block text-sm font-semibold text-gray-700 mb-2">
                Adresse email
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
              <Transition
                enter-active-class="transition-all duration-200"
                enter-from-class="opacity-0 -translate-y-1"
                enter-to-class="opacity-100 translate-y-0"
                leave-active-class="transition-all duration-200"
                leave-from-class="opacity-100 translate-y-0"
                leave-to-class="opacity-0 -translate-y-1"
              >
                <span v-if="errors.email" class="block text-red-500 text-xs mt-1">{{ errors.email }}</span>
              </Transition>
            </div>

            <!-- Mot de passe -->
            <div>
              <label for="password" class="block text-sm font-semibold text-gray-700 mb-2">
                Mot de passe
              </label>
              <div class="relative">
                <input
                  id="password"
                  v-model="formData.password"
                  :type="showPassword ? 'text' : 'password'"
                  required
                  class="w-full px-4 py-3 pl-11 pr-12 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                  placeholder="••••••••"
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
            </div>

            <!-- Options -->
            <div class="flex items-center justify-between">
              <label class="flex items-center space-x-2 cursor-pointer">
                <input
                  v-model="formData.rememberMe"
                  type="checkbox"
                  class="w-4 h-4 text-violet-600 border-2 border-gray-300 rounded focus:ring-violet-500 focus:ring-2"
                />
                <span class="text-sm text-gray-600">Se souvenir de moi</span>
              </label>
              
              <a href="#" class="text-sm text-violet-600 hover:text-violet-700 font-medium">
                Mot de passe oublié ?
              </a>
            </div>

            <!-- Bouton de connexion -->
            <button
              type="submit"
              :disabled="!isFormValid || isSubmitting"
              class="relative group w-full bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold py-4 px-6 rounded-full transition-all duration-300 hover:scale-105 shadow-lg hover:shadow-xl disabled:opacity-50 disabled:hover:scale-100 disabled:cursor-not-allowed"
            >
              <span class="relative z-10 flex items-center justify-center space-x-2">
                <Loader2 v-if="isSubmitting" :size="20" class="animate-spin" />
                <span>{{ isSubmitting ? 'Connexion...' : 'Se connecter' }}</span>
                <ArrowRight v-if="!isSubmitting" :size="20" />
              </span>
              <div class="absolute inset-0 bg-gradient-to-r from-violet-700 to-pink-700 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            </button>
          </form>

          <!-- Inscription -->
          <p class="text-center mt-8 text-sm text-gray-600">
            Pas encore de compte ?
            <router-link to="/register" class="text-violet-600 hover:text-violet-700 font-semibold">
              Créer un compte
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
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { User, Mail, Lock, Eye, EyeOff, ArrowRight, ArrowLeft, Globe, Loader2 } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

const router = useRouter()

const formData = ref({
  email: '',
  password: '',
  rememberMe: false
})

const errors = ref({
  email: ''
})

const showPassword = ref(false)
const showLanguageMenu = ref(false)
const currentLanguage = ref('FR')
const isLoading = ref(false)
const isSubmitting = ref(false)

const toggleLanguageMenu = () => {
  showLanguageMenu.value = !showLanguageMenu.value
}

const selectLanguage = (lang: string) => {
  currentLanguage.value = lang
  showLanguageMenu.value = false
  // Ici vous pouvez ajouter la logique de changement de langue
  console.log('Language changed to:', lang)
}

const goBack = () => {
  if (window.history.length > 1) {
    router.back()
  } else {
    router.push('/')
  }
}

// Fermer le menu langue quand on clique ailleurs
if (typeof window !== 'undefined') {
  window.addEventListener('click', (e) => {
    const target = e.target as HTMLElement
    if (!target.closest('.relative')) {
      showLanguageMenu.value = false
    }
  })
}

const isFormValid = computed(() => {
  return formData.value.email && 
         formData.value.password &&
         !errors.value.email
})

const validateEmail = () => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(formData.value.email)) {
    errors.value.email = 'Veuillez entrer une adresse email valide'
  } else {
    errors.value.email = ''
  }
}


const handleLogin = async () => {
  validateEmail()
  
  if (isFormValid.value && !isSubmitting.value) {
    isSubmitting.value = true
    errors.value.email = ''
    
    try {
      // Se connecter via Supabase Auth
      const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email: formData.value.email,
        password: formData.value.password
      })

      if (authError) {
        console.error('Erreur de connexion:', authError)
        errors.value.email = 'Email ou mot de passe incorrect'
        isSubmitting.value = false
        return
      }

      if (authData.user) {
        console.log('✅ Connexion réussie!', authData.user)
        
        // Afficher l'écran de chargement
        isLoading.value = true
        
        // Récupérer les informations complètes de l'utilisateur
        const { data: userData, error: userError } = await supabase
          .from('users')
          .select('*')
          .eq('auth_id', authData.user.id)
          .single()
        
        if (userData) {
          console.log('Informations utilisateur:', userData)
          
          // Logger l'activité de connexion
          await supabase.from('activity_logs').insert({
            user_id: userData.id,
            action: 'LOGIN',
            description: 'Connexion réussie'
          })
          
          // Mettre à jour last_login
          await supabase
            .from('users')
            .update({ last_login: new Date().toISOString() })
            .eq('id', userData.id)
        }
        
        // Attendre un peu pour montrer le chargement
        await new Promise(resolve => setTimeout(resolve, 800))
        
        // Redirection vers le dashboard
        router.push('/dashboard')
      }
    } catch (error) {
      console.error('Erreur lors de la connexion:', error)
      errors.value.email = 'Une erreur est survenue lors de la connexion'
      isSubmitting.value = false
      isLoading.value = false
    }
  }
}
</script>