import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authService, type User } from '@/services/supabase'
import { useRouter } from 'vue-router'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)
  const router = useRouter()

  const isAuthenticated = computed(() => !!user.value)

  async function login(email: string, password: string) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: loginError } = await authService.login(email, password)
      
      if (loginError) {
        error.value = loginError.message
        return false
      }

      if (data.user) {
        user.value = {
          id: data.user.id,
          email: data.user.email!,
          company: data.user.user_metadata?.company || '',
          first_name: data.user.user_metadata?.first_name || '',
          last_name: data.user.user_metadata?.last_name || '',
          accept_newsletter: data.user.user_metadata?.accept_newsletter || false
        }
        
        // Redirection après connexion
        router.push('/dashboard')
        return true
      }
      
      return false
    } catch (err) {
      error.value = 'Une erreur est survenue lors de la connexion'
      return false
    } finally {
      loading.value = false
    }
  }

  async function register(userData: User & { password: string }) {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: registerError } = await authService.register(userData)
      
      if (registerError) {
        error.value = registerError.message
        return false
      }

      if (data.user) {
        // Email de confirmation envoyé
        return true
      }
      
      return false
    } catch (err) {
      error.value = 'Une erreur est survenue lors de l\'inscription'
      return false
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    loading.value = true
    
    try {
      const { error: logoutError } = await authService.logout()
      
      if (!logoutError) {
        user.value = null
        router.push('/login')
      }
    } catch (err) {
      console.error('Erreur lors de la déconnexion:', err)
    } finally {
      loading.value = false
    }
  }

  async function checkAuth() {
    const currentUser = await authService.getCurrentUser()
    
    if (currentUser) {
      user.value = {
        id: currentUser.id,
        email: currentUser.email!,
        company: currentUser.user_metadata?.company || '',
        first_name: currentUser.user_metadata?.first_name || '',
        last_name: currentUser.user_metadata?.last_name || '',
        accept_newsletter: currentUser.user_metadata?.accept_newsletter || false
      }
    }
  }

  // Écouter les changements d'authentification
  authService.onAuthStateChange((event, session) => {
    if (session?.user) {
      user.value = {
        id: session.user.id,
        email: session.user.email!,
        company: session.user.user_metadata?.company || '',
        first_name: session.user.user_metadata?.first_name || '',
        last_name: session.user.user_metadata?.last_name || '',
        accept_newsletter: session.user.user_metadata?.accept_newsletter || false
      }
    } else {
      user.value = null
    }
  })

  return {
    user,
    loading,
    error,
    isAuthenticated,
    login,
    register,
    logout,
    checkAuth
  }
})