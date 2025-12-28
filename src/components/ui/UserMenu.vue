<template>
  <div class="relative">
    <!-- Utilisateur connecté -->
    <div v-if="user" class="flex items-center space-x-3">
      <button
        @click="toggleMenu"
        class="flex items-center space-x-2 px-3 py-2 rounded-lg hover:bg-violet-50 transition-all duration-200"
      >
        <div class="flex items-center justify-center w-8 h-8 bg-gradient-to-r from-violet-600 to-pink-600 rounded-full">
          <User :size="16" color="white" />
        </div>
        <span class="text-sm font-medium text-gray-700">{{ displayName }}</span>
        <ChevronDown :size="16" class="text-gray-400" />
      </button>

      <!-- Menu dropdown -->
      <div
        v-if="showMenu"
        class="absolute right-0 mt-2 top-full w-56 bg-white rounded-lg shadow-lg border border-gray-100 py-2 z-50"
      >
        <div class="px-4 py-2 border-b border-gray-100">
          <p class="text-xs text-gray-500">Connecté en tant que</p>
          <p class="text-sm font-medium text-gray-900">{{ user.email }}</p>
        </div>

        <router-link
          to="/profile"
          class="block px-4 py-2 text-sm text-gray-700 hover:bg-violet-50 hover:text-violet-600 transition-colors"
        >
          <div class="flex items-center space-x-2">
            <Settings :size="16" />
            <span>Mon profil</span>
          </div>
        </router-link>

        <router-link
          to="/dashboard"
          class="block px-4 py-2 text-sm text-gray-700 hover:bg-violet-50 hover:text-violet-600 transition-colors"
        >
          <div class="flex items-center space-x-2">
            <LayoutDashboard :size="16" />
            <span>Dashboard</span>
          </div>
        </router-link>

        <div class="border-t border-gray-100 mt-2 pt-2">
          <button
            @click="handleLogout"
            class="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors"
          >
            <div class="flex items-center space-x-2">
              <LogOut :size="16" />
              <span>Se déconnecter</span>
            </div>
          </button>
        </div>
      </div>
    </div>

    <!-- Utilisateur non connecté -->
    <div v-else class="flex items-center space-x-3">
      <router-link
        to="/login"
        class="text-gray-700 hover:text-violet-600 font-medium px-5 py-2.5 rounded-lg hover:bg-violet-50 transition-all duration-200"
      >
        Connexion
      </router-link>
      <div class="h-6 w-px bg-gray-200"></div>
      <router-link
        to="/pricing"
        class="relative group bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold py-2.5 px-6 rounded-full transition-all duration-300 hover:scale-105 shadow-lg hover:shadow-xl text-sm inline-flex items-center justify-center"
      >
        <span class="relative z-10">Essai Gratuit 🚀</span>
        <div class="absolute inset-0 bg-gradient-to-r from-violet-700 to-pink-700 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
      </router-link>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { User, ChevronDown, Settings, LayoutDashboard, LogOut, Loader2 } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'
import { logoutOverlay } from '@/services/logoutOverlay'

const router = useRouter()
const user = ref<any>(null)
const showMenu = ref(false)

const displayName = computed(() => {
  if (!user.value) return ''
  
  // Utiliser le prénom si disponible, sinon l'email
  const metadata = user.value.user_metadata
  if (metadata?.first_name) {
    return metadata.first_name
  }
  
  // Extraire la partie avant @ de l'email
  return user.value.email?.split('@')[0] || 'Utilisateur'
})

const toggleMenu = () => {
  showMenu.value = !showMenu.value
}

const handleLogout = async () => {
  showMenu.value = false
  logoutOverlay.show()
  
  try {
    // Petit délai pour montrer le chargement
    await new Promise(resolve => setTimeout(resolve, 800))
    
    const { error } = await supabase.auth.signOut()
    
    if (!error) {
      user.value = null
      
      // Redirection vers la page d'accueil
      await router.push('/')
      
      // Message de succès optionnel
      console.log('✅ Déconnexion réussie')
    } else {
      console.error('Erreur lors de la déconnexion:', error)
    }
  } catch (error) {
    console.error('Erreur lors de la déconnexion:', error)
  } finally {
    logoutOverlay.hide()
  }
}

// Vérifier l'état de connexion au montage
onMounted(async () => {
  // Récupérer l'utilisateur actuel
  const { data: { user: currentUser } } = await supabase.auth.getUser()
  user.value = currentUser

  // Écouter les changements d'authentification
  const { data: authListener } = supabase.auth.onAuthStateChange((event, session) => {
    user.value = session?.user || null
  })

  // Fermer le menu quand on clique ailleurs
  const handleClickOutside = (e: MouseEvent) => {
    const target = e.target as HTMLElement
    if (!target.closest('.relative')) {
      showMenu.value = false
    }
  }

  window.addEventListener('click', handleClickOutside)

  // Nettoyer les listeners au démontage
  onUnmounted(() => {
    authListener?.subscription.unsubscribe()
    window.removeEventListener('click', handleClickOutside)
  })
})
</script>