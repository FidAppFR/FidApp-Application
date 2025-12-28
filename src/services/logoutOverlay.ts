import { ref } from 'vue'

const isLoggingOut = ref(false)

export const logoutOverlay = {
  show() {
    isLoggingOut.value = true
  },
  
  hide() {
    isLoggingOut.value = false
  },
  
  isVisible: isLoggingOut
}