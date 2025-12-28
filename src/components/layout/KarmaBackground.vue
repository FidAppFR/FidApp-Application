<template>
  <div class="relative min-h-screen overflow-hidden">
    <!-- Fond principal avec dégradé hero -->
    <div class="absolute inset-0 bg-gradient-to-br from-purple-50 to-pink-50"></div>
    
    <!-- Orbes lumineux -->
    <div v-if="showOrbs" class="absolute inset-0 pointer-events-none">
      <!-- Orbe Violet -->
      <div class="w-[500px] h-[500px] bg-gradient-to-br from-purple-400/30 to-violet-400/30 rounded-full absolute -top-32 -left-32 animate-pulse-slow blur-[100px]"></div>
      
      <!-- Orbe Rose -->
      <div class="w-[600px] h-[600px] bg-gradient-to-br from-pink-400/25 to-rose-400/25 rounded-full absolute top-1/2 -right-48 animate-pulse-slow blur-[100px]" style="animation-delay: 1s;"></div>
      
      <!-- Orbe Purple -->
      <div class="w-[450px] h-[450px] bg-gradient-to-br from-purple-500/20 to-pink-500/20 rounded-full absolute -bottom-24 left-1/3 animate-pulse-slow blur-[100px]" style="animation-delay: 2s;"></div>
    </div>
    
    <!-- Pattern de fond -->
    <div v-if="pattern" :class="patternClasses" class="absolute inset-0 pointer-events-none"></div>
    
    <!-- Contenu -->
    <div class="relative z-10">
      <slot></slot>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  showOrbs?: boolean
  pattern?: 'dots' | 'lines' | 'grid' | null
}

const props = withDefaults(defineProps<Props>(), {
  showOrbs: true,
  pattern: null
})

const patternClasses = computed(() => {
  if (!props.pattern) return ''
  
  const patterns = {
    dots: 'pattern-dots',
    lines: 'pattern-lines', 
    grid: 'pattern-grid'
  }
  
  return patterns[props.pattern] || ''
})
</script>