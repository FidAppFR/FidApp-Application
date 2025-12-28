<template>
  <div class="flex items-center gap-3">
    <img 
      :src="iconSrc" 
      :alt="iconAlt" 
      :class="iconClasses"
    />
    <img 
      v-if="showText"
      :src="logoSrc" 
      :alt="logoAlt" 
      :class="logoClasses"
    />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  size?: 'sm' | 'md' | 'lg' | 'xl'
  showText?: boolean
  iconSrc?: string
  logoSrc?: string
  iconAlt?: string
  logoAlt?: string
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  showText: true,
  iconSrc: '/Icon_Trans.png',
  logoSrc: '/Logo_Trans.png',
  iconAlt: 'FidApp Icon',
  logoAlt: 'FidApp'
})

const iconClasses = computed(() => {
  const sizes = {
    sm: 'w-8 h-8',
    md: 'w-12 h-12',
    lg: 'w-16 h-16',
    xl: 'w-20 h-20'
  }
  return sizes[props.size]
})

const logoClasses = computed(() => {
  const sizes = {
    sm: 'h-6',
    md: 'h-8',
    lg: 'h-10',
    xl: 'h-12'
  }
  return sizes[props.size]
})
</script>