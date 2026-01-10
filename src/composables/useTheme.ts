import { ref, watch, onMounted } from 'vue'
import { supabase } from '@/services/supabase'

const isDark = ref(false)
const themePreference = ref<'light' | 'dark'>('light')

export function useTheme() {
  // Charger la préférence depuis la base de données
  const loadThemeFromDB = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) return null

      const { data } = await supabase
        .from('users')
        .select('theme_preference')
        .eq('auth_id', user.id)
        .single()

      return data?.theme_preference || null
    } catch (error) {
      console.error('Erreur chargement thème depuis DB:', error)
      return null
    }
  }

  // Sauvegarder la préférence dans la base de données
  const saveThemeToDB = async (theme: 'light' | 'dark') => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) return

      await supabase
        .from('users')
        .update({
          theme_preference: theme,
          updated_at: new Date().toISOString()
        })
        .eq('auth_id', user.id)
    } catch (error) {
      console.error('Erreur sauvegarde thème dans DB:', error)
    }
  }

  // Initialiser le thème depuis la DB ou localStorage (défaut: light)
  const initTheme = async () => {
    // 1. Essayer de charger depuis la DB
    const dbTheme = await loadThemeFromDB()

    if (dbTheme && (dbTheme === 'light' || dbTheme === 'dark')) {
      themePreference.value = dbTheme
      isDark.value = dbTheme === 'dark'
    } else {
      // 2. Sinon, essayer le localStorage
      const savedTheme = localStorage.getItem('theme')
      if (savedTheme && (savedTheme === 'light' || savedTheme === 'dark')) {
        themePreference.value = savedTheme as 'light' | 'dark'
        isDark.value = savedTheme === 'dark'
      } else {
        // 3. Par défaut: thème clair
        themePreference.value = 'light'
        isDark.value = false
      }
    }

    updateTheme()
  }

  // Mettre à jour les classes sur le document
  const updateTheme = () => {
    if (isDark.value) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }

  // Basculer le thème
  const toggleTheme = async () => {
    isDark.value = !isDark.value
    const newTheme = isDark.value ? 'dark' : 'light'
    themePreference.value = newTheme
    
    // Sauvegarder dans localStorage (pour un accès immédiat)
    localStorage.setItem('theme', newTheme)
    
    // Sauvegarder dans la DB (pour la persistance entre sessions/appareils)
    await saveThemeToDB(newTheme)
    
    updateTheme()
  }

  // Observer les changements
  watch(isDark, () => {
    updateTheme()
  })

  // Initialiser au montage
  onMounted(() => {
    initTheme()
  })

  return {
    isDark,
    themePreference,
    toggleTheme,
    initTheme
  }
}