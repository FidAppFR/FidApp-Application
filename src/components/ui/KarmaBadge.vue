<template>
  <span :class="badgeClasses">
    <component 
      v-if="icon" 
      :is="icon" 
      :size="iconSize" 
      class="mr-2" 
    />
    <slot></slot>
    {{ text }}
  </span>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  variant?: 'label' | 'success' | 'floating' | 'vip'
  text?: string
  icon?: any
  iconSize?: number
  animated?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'label',
  iconSize: 16,
  animated: false
})

const badgeClasses = computed(() => {
  const baseClasses = 'inline-flex items-center justify-center font-bold'
  
  const variantClasses = {
    label: 'bg-gradient-to-r from-purple-100 to-pink-100 border-2 border-purple-300 rounded-full py-2 px-5 text-purple-800',
    success: 'bg-karma-card-success rounded-2xl p-6 text-white shadow-karma-success',
    floating: 'bg-karma-card-success rounded-2xl p-6 text-white shadow-karma-success animate-bounce-slow',
    vip: 'bg-karma-gradient rounded-full py-3 px-6 text-white shadow-karma-purple text-sm'
  }
  
  const animationClasses = props.animated ? 'animate-bounce-slow' : ''
  
  return `${baseClasses} ${variantClasses[props.variant]} ${animationClasses}`
})
</script>