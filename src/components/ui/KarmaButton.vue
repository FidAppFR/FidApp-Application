<template>
  <button 
    :class="buttonClasses"
    @click="$emit('click', $event)"
  >
    <component 
      v-if="icon" 
      :is="icon" 
      :size="iconSize" 
      class="mr-2" 
    />
    <slot></slot>
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  variant?: 'primary' | 'secondary'
  size?: 'sm' | 'md' | 'lg'
  icon?: any
  iconSize?: number
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  iconSize: 24
})

defineEmits<{
  click: [event: MouseEvent]
}>()

const buttonClasses = computed(() => {
  const baseClasses = 'font-black rounded-full transition-transform duration-200 hover:scale-105 inline-flex items-center justify-center'
  
  const variantClasses = {
    primary: 'bg-karma-gradient text-white shadow-karma-purple',
    secondary: 'bg-white text-karma-black border-4 border-karma-black'
  }
  
  const sizeClasses = {
    sm: 'py-2 px-6 text-sm',
    md: 'py-5 px-12 text-base',
    lg: 'py-6 px-16 text-lg'
  }
  
  return `${baseClasses} ${variantClasses[props.variant]} ${sizeClasses[props.size]}`
})
</script>