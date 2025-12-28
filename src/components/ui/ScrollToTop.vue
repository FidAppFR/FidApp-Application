<template>
  <Transition name="fade">
    <button
      v-if="isVisible"
      @click="scrollToTop"
      class="fixed bottom-8 right-8 z-40 bg-gradient-to-r from-violet-600 to-pink-600 text-white p-4 rounded-full shadow-lg hover:shadow-xl hover:scale-110 transition-all duration-300 group"
      aria-label="Retour en haut"
    >
      <div class="relative">
        <ArrowUp :size="24" class="group-hover:-translate-y-1 transition-transform duration-300" />
        <div class="absolute inset-0 bg-gradient-to-r from-violet-700 to-pink-700 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300 -z-10 scale-150"></div>
      </div>
    </button>
  </Transition>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { ArrowUp } from 'lucide-vue-next'

const isVisible = ref(false)

const handleScroll = () => {
  // Afficher le bouton après avoir scrollé de 300px
  isVisible.value = window.scrollY > 300
}

const scrollToTop = () => {
  window.scrollTo({
    top: 0,
    behavior: 'smooth'
  })
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
  // Vérifier la position initiale
  handleScroll()
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(20px);
}
</style>