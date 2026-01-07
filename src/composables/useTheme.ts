import { ref, watch, onMounted } from 'vue'

const isDark = ref(false)

export function useTheme() {
  // Initialiser le thème depuis le localStorage
  const initTheme = () => {
    const savedTheme = localStorage.getItem('theme')
    if (savedTheme) {
      isDark.value = savedTheme === 'dark'
    } else {
      // Détecter la préférence système
      isDark.value = window.matchMedia('(prefers-color-scheme: dark)').matches
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
  const toggleTheme = () => {
    isDark.value = !isDark.value
    localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
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
    toggleTheme,
    initTheme
  }
}