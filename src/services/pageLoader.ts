import { ref } from 'vue'

const isPageLoading = ref(false)

export const pageLoader = {
  show() {
    isPageLoading.value = true
  },
  
  hide() {
    // Petit délai pour éviter le flash
    setTimeout(() => {
      isPageLoading.value = false
    }, 300)
  },
  
  isVisible: isPageLoading
}