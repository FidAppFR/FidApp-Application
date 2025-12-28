<template>
  <Teleport to="body">
    <Transition
      enter-active-class="transition-all duration-300"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition-all duration-300"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="isVisible"
        class="fixed inset-0 bg-white z-[99999] flex items-center justify-center"
        style="position: fixed !important; top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important;"
      >
        <div class="flex flex-col items-center space-y-6">
          <!-- Logo ou icône principale -->
          <div class="relative">
            <div class="absolute inset-0 bg-gradient-to-r from-violet-600 to-pink-600 rounded-full blur-2xl opacity-30 animate-pulse"></div>
            <div class="relative bg-white rounded-3xl p-8 shadow-2xl">
              <Loader2 :size="60" class="text-violet-600 animate-spin" />
            </div>
          </div>
          
          <!-- Texte de chargement -->
          <div class="text-center space-y-2">
            <p class="text-2xl font-black bg-gradient-to-r from-violet-600 to-pink-600 bg-clip-text text-transparent">
              Déconnexion en cours
            </p>
            <p class="text-gray-600 text-sm">
              Veuillez patienter...
            </p>
          </div>
          
          <!-- Barre de progression -->
          <div class="w-64 h-2 bg-gray-200 rounded-full overflow-hidden">
            <div class="h-full bg-gradient-to-r from-violet-600 to-pink-600 rounded-full animate-[loading_1s_ease-in-out_infinite]"></div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Loader2 } from 'lucide-vue-next'

const isVisible = ref(false)

const show = () => {
  isVisible.value = true
}

const hide = () => {
  isVisible.value = false
}

// Exposer les méthodes pour pouvoir les utiliser depuis l'extérieur
defineExpose({
  show,
  hide
})
</script>