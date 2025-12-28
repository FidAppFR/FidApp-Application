<template>
  <nav class="bg-white border-b border-gray-100 sticky top-0 z-50 backdrop-blur-md bg-white/95 shadow-sm">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-16 lg:h-20">
        
        <!-- Logo et Navigation principale -->
        <div class="flex items-center space-x-10">
          <!-- Logo -->
          <router-link to="/" class="flex items-center flex-shrink-0">
            <img 
              src="/Logo_Trans_unique.png" 
              alt="FidApp" 
              class="h-8 md:h-10 cursor-pointer hover:opacity-90 transition-opacity"
            />
          </router-link>

          <!-- Menu Desktop -->
          <div class="hidden lg:flex items-center space-x-1">
            <a href="#features" class="text-gray-600 hover:text-violet-600 font-medium px-4 py-2 rounded-lg hover:bg-violet-50 transition-all duration-200">
              Fonctionnalités
            </a>
            <router-link to="/pricing" class="text-gray-600 hover:text-violet-600 font-medium px-4 py-2 rounded-lg hover:bg-violet-50 transition-all duration-200">
              Tarifs
            </router-link>
            <a href="#testimonials" class="text-gray-600 hover:text-violet-600 font-medium px-4 py-2 rounded-lg hover:bg-violet-50 transition-all duration-200">
              Témoignages
            </a>
            <a href="#support" class="text-gray-600 hover:text-violet-600 font-medium px-4 py-2 rounded-lg hover:bg-violet-50 transition-all duration-200">
              Support
            </a>
          </div>
        </div>

        <!-- Boutons CTA Desktop -->
        <div class="hidden lg:flex items-center space-x-3">
          <!-- Bouton retour (affiché seulement si pas sur accueil ou tarifs) -->
          <button 
            v-if="showBackButton"
            @click="goBack"
            class="text-gray-600 hover:text-violet-600 font-medium flex items-center space-x-2 px-4 py-2 rounded-lg hover:bg-violet-50 transition-all duration-200"
          >
            <ArrowLeft :size="20" />
            <span>Retour</span>
          </button>
          
          <div v-if="showBackButton" class="h-6 w-px bg-gray-200"></div>
          
          <!-- Icône de notification (seulement sur dashboard) -->
          <div v-if="showNotificationBell" class="relative">
            <button 
              @click="toggleNotifications"
              class="relative p-2 text-gray-600 hover:text-violet-600 rounded-lg hover:bg-violet-50 transition-all duration-200"
            >
              <Bell :size="22" />
              <!-- Badge de notification -->
              <span 
                v-if="notificationCount > 0"
                class="absolute -top-0.5 -right-0.5 bg-red-500 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center animate-pulse"
              >
                {{ notificationCount > 9 ? '9+' : notificationCount }}
              </span>
            </button>
            
            <!-- Dropdown notifications -->
            <div 
              v-if="showNotifications"
              class="absolute right-0 mt-2 w-80 bg-white rounded-lg shadow-xl border border-gray-100 py-2 z-50"
            >
              <div class="px-4 py-3 border-b border-gray-100">
                <h3 class="font-semibold text-gray-900">Notifications</h3>
              </div>
              <div class="max-h-96 overflow-y-auto">
                <!-- Notifications existantes -->
                <div v-if="notifications.length > 0">
                  <button 
                    v-for="(notification, index) in notifications"
                    :key="index"
                    @click="markAsRead(index)"
                    class="w-full text-left px-4 py-3 hover:bg-gray-50 transition-colors border-b border-gray-100 last:border-b-0"
                  >
                    <p class="text-sm font-medium text-gray-900">{{ notification.title }}</p>
                    <p class="text-xs text-gray-600 mt-1">{{ notification.message }}</p>
                    <p class="text-xs text-gray-400 mt-1">{{ notification.time }}</p>
                  </button>
                </div>
                <!-- Pas de notifications -->
                <div v-else class="px-4 py-8 text-center">
                  <Bell :size="32" class="mx-auto text-gray-300 mb-3" />
                  <p class="text-sm text-gray-500">Aucune nouvelle notification</p>
                </div>
              </div>
              <div class="px-4 py-3 border-t border-gray-100">
                <button 
                  @click="clearAllNotifications"
                  class="text-sm text-violet-600 hover:text-violet-700 font-medium"
                >
                  Marquer tout comme lu
                </button>
              </div>
            </div>
          </div>
          
          <div v-if="showNotificationBell" class="h-6 w-px bg-gray-200"></div>
          
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
          
          <div class="h-6 w-px bg-gray-200"></div>
          
          <!-- Menu utilisateur -->
          <UserMenu />
        </div>

        <!-- Menu Mobile Button -->
        <div class="lg:hidden flex items-center space-x-2">
          <!-- Icône de notification mobile (seulement sur dashboard) -->
          <div v-if="showNotificationBell" class="relative">
            <button 
              @click="toggleNotifications"
              class="relative p-2 text-gray-600 hover:text-violet-600 rounded-lg hover:bg-violet-50 transition-all duration-200"
            >
              <Bell :size="20" />
              <!-- Badge de notification -->
              <span 
                v-if="notificationCount > 0"
                class="absolute -top-0.5 -right-0.5 bg-red-500 text-white text-xs font-bold rounded-full h-4 w-4 flex items-center justify-center animate-pulse"
              >
                {{ notificationCount > 9 ? '9+' : notificationCount }}
              </span>
            </button>
          </div>
          
          <button 
            @click="toggleMobileMenu"
            class="text-gray-600 hover:text-violet-600 p-2 rounded-lg hover:bg-violet-50 transition-all duration-200"
          >
            <Menu v-if="!showMobileMenu" :size="24" />
            <X v-else :size="24" />
          </button>
        </div>

      </div>
    </div>

    <!-- Menu Mobile -->
    <div 
      v-if="showMobileMenu" 
      class="lg:hidden bg-white border-t border-gray-100"
    >
      <div class="px-6 py-4 space-y-4">
        <a href="#features" class="block text-karma-gray-dark hover:text-karma-violet font-semibold py-2 transition-colors">
          Fonctionnalités
        </a>
        <router-link to="/pricing" class="block text-karma-gray-dark hover:text-karma-violet font-semibold py-2 transition-colors">
          Tarifs
        </router-link>
        <a href="#testimonials" class="block text-karma-gray-dark hover:text-karma-violet font-semibold py-2 transition-colors">
          Témoignages
        </a>
        <a href="#support" class="block text-karma-gray-dark hover:text-karma-violet font-semibold py-2 transition-colors">
          Support
        </a>
        
        <div class="pt-4 border-t border-gray-100 space-y-3">
          <!-- Bouton retour mobile (affiché seulement si pas sur accueil ou tarifs) -->
          <button 
            v-if="showBackButton"
            @click="goBack"
            class="w-full text-left py-2 px-4 rounded-lg hover:bg-violet-50 transition-all duration-200 flex items-center space-x-2 text-gray-600 hover:text-violet-600 font-medium"
          >
            <ArrowLeft :size="18" />
            <span>Retour</span>
          </button>
          
          <!-- Sélecteur de langue mobile -->
          <div class="flex items-center justify-between py-2 px-4 rounded-lg hover:bg-violet-50 transition-all duration-200">
            <span class="text-gray-600 font-medium flex items-center space-x-2">
              <Globe :size="18" />
              <span>Langue</span>
            </span>
            <div class="flex space-x-2">
              <button 
                @click="selectLanguage('FR')"
                class="px-3 py-1 rounded text-sm font-medium transition-colors"
                :class="currentLanguage === 'FR' ? 'bg-violet-100 text-violet-600' : 'text-gray-600 hover:text-violet-600'"
              >
                🇫🇷 FR
              </button>
              <button 
                @click="selectLanguage('EN')"
                class="px-3 py-1 rounded text-sm font-medium transition-colors"
                :class="currentLanguage === 'EN' ? 'bg-violet-100 text-violet-600' : 'text-gray-600 hover:text-violet-600'"
              >
                🇬🇧 EN
              </button>
            </div>
          </div>
          
          <router-link 
            to="/login" 
            class="block w-full text-left text-gray-700 hover:text-violet-600 font-medium py-2 px-4 rounded-lg hover:bg-violet-50 transition-all duration-200"
            @click="showMobileMenu = false"
          >
            Connexion
          </router-link>
          <router-link 
            to="/pricing"
            class="relative group bg-gradient-to-r from-violet-600 to-pink-600 text-white font-black py-4 px-10 rounded-full transition-all duration-300 hover:scale-110 shadow-2xl shadow-purple-500/25 hover:shadow-purple-500/40 text-base inline-flex items-center justify-center w-full"
            @click="showMobileMenu = false"
          >
            <span class="relative z-10">Essai Gratuit 🚀</span>
            <div class="absolute inset-0 bg-gradient-to-r from-violet-700 to-pink-700 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          </router-link>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Menu, X, Globe, ArrowLeft, Bell } from 'lucide-vue-next'
import UserMenu from '@/components/ui/UserMenu.vue'

interface Notification {
  title: string
  message: string
  time: string
  read?: boolean
}

defineEmits<{
  'cta-click': []
}>()

const router = useRouter()
const route = useRoute()

const showMobileMenu = ref(false)
const showLanguageMenu = ref(false)
const showNotifications = ref(false)
const currentLanguage = ref('FR')

// Notifications - exemples de notifications
const notifications = ref<Notification[]>([
  {
    title: 'Nouveau client fidèle',
    message: 'Jean Dupont vient de s\'inscrire à votre programme',
    time: 'Il y a 5 min'
  },
  {
    title: 'Récompense échangée',
    message: 'Marie Martin a échangé 200 points contre un café gratuit',
    time: 'Il y a 1 heure'
  },
  {
    title: 'Objectif atteint !',
    message: 'Vous avez dépassé 100 clients fidèles ce mois-ci',
    time: 'Il y a 2 heures'
  }
])

const notificationCount = computed(() => notifications.value.length)

const showBackButton = computed(() => {
  // Afficher le bouton retour sauf sur la page d'accueil, tarifs et profil
  return route.path !== '/' && route.path !== '/pricing' && route.path !== '/profile'
})

// Afficher les notifications uniquement sur le dashboard
const showNotificationBell = computed(() => {
  return route.path === '/dashboard' || route.path.startsWith('/dashboard/')
})

const toggleMobileMenu = () => {
  showMobileMenu.value = !showMobileMenu.value
  showLanguageMenu.value = false
}

const toggleLanguageMenu = () => {
  showLanguageMenu.value = !showLanguageMenu.value
}

const selectLanguage = (lang: string) => {
  currentLanguage.value = lang
  showLanguageMenu.value = false
  // Ici vous pouvez ajouter la logique de changement de langue
  console.log('Language changed to:', lang)
}

const toggleNotifications = () => {
  showNotifications.value = !showNotifications.value
  showLanguageMenu.value = false
}

const markAsRead = (index: number) => {
  notifications.value.splice(index, 1)
  if (notifications.value.length === 0) {
    showNotifications.value = false
  }
}

const clearAllNotifications = () => {
  notifications.value = []
  showNotifications.value = false
}

const goBack = () => {
  if (window.history.length > 1) {
    router.back()
  } else {
    router.push('/')
  }
}

// Fermer les menus quand on clique ailleurs
if (typeof window !== 'undefined') {
  window.addEventListener('click', (e) => {
    const target = e.target as HTMLElement
    if (!target.closest('.relative')) {
      showLanguageMenu.value = false
      showNotifications.value = false
    }
  })
}
</script>