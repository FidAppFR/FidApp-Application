<template>
  <div id="app">
    <router-view />
    <ScrollToTop />
    
    <!-- Overlay de déconnexion global -->
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
          v-if="isLogoutVisible"
          class="fixed inset-0 bg-white z-[99999]"
          style="position: fixed !important; top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important; width: 100vw !important; height: 100vh !important;"
        >
          <div class="w-full h-full flex items-center justify-center">
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
        </div>
      </Transition>
    </Teleport>
    
    <!-- Loader de transition de page (optionnel) -->
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
          v-if="isPageLoaderVisible"
          class="fixed inset-0 bg-white z-[999999]"
          style="position: fixed !important; top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important; width: 100vw !important; height: 100vh !important;"
        >
          <div class="w-full h-full flex items-center justify-center">
            <div class="flex flex-col items-center space-y-3">
              <div class="relative">
                <div class="absolute inset-0 bg-gradient-to-r from-violet-600 to-pink-600 rounded-full blur-lg opacity-20 animate-pulse"></div>
                <Loader2 :size="36" class="text-violet-600 animate-spin relative" />
              </div>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { watch, computed } from 'vue'
import { useRoute } from 'vue-router'
import ScrollToTop from '@/components/ui/ScrollToTop.vue'
import { Loader2 } from 'lucide-vue-next'
import { logoutOverlay } from '@/services/logoutOverlay'
import { pageLoader } from '@/services/pageLoader'

const route = useRoute()

// Utiliser des computed pour la réactivité
const isLogoutVisible = computed(() => logoutOverlay.isVisible.value)
const isPageLoaderVisible = computed(() => pageLoader.isVisible.value)

// Déclencher le loader lors des changements de route
watch(() => route.path, (newPath, oldPath) => {
  // Afficher le loader uniquement lors de la sortie de la page profil
  if (oldPath === '/profile' && newPath !== oldPath) {
    pageLoader.show()
    setTimeout(() => pageLoader.hide(), 400)
  }
})
</script>

<style>
/* Les styles globaux sont importés dans main.ts */
</style>