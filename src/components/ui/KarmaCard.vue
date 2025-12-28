<template>
  <div :class="cardClasses">
    <div v-if="showIcon" class="mb-4">
      <div :class="iconContainerClasses">
        <component 
          :is="icon" 
          :size="iconSize" 
          :color="iconColor" 
        />
      </div>
    </div>
    
    <div class="flex-1">
      <h3 v-if="title" :class="titleClasses">
        {{ title }}
      </h3>
      
      <div v-if="value" :class="valueClasses">
        {{ value }}
      </div>
      
      <p v-if="description" :class="descriptionClasses">
        {{ description }}
      </p>
      
      <div v-if="badge" class="mt-4">
        <span :class="badgeClasses">
          {{ badge }}
        </span>
      </div>
      
      <slot></slot>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  variant?: 'stat-rose' | 'stat-purple' | 'stat-success' | 'activity-rose' | 'activity-purple' | 'activity-pink' | 'default'
  title?: string
  value?: string | number
  description?: string
  badge?: string
  icon?: any
  iconSize?: number
  iconColor?: string
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'default',
  iconSize: 20,
  iconColor: 'white'
})

const showIcon = computed(() => props.icon)

const cardClasses = computed(() => {
  const baseClasses = 'rounded-xl transition-transform duration-300 hover:scale-105'
  
  const variantClasses = {
    'stat-rose': 'bg-white p-6 border-2 border-pink-200 shadow-sm',
    'stat-purple': 'bg-white p-6 border-2 border-purple-200 shadow-sm',
    'stat-success': 'bg-white p-6 border-2 border-green-200 shadow-sm',
    'activity-rose': 'bg-gradient-to-r from-pink-100 to-red-50 border-2 border-pink-300 p-5',
    'activity-purple': 'bg-gradient-to-r from-purple-100 to-purple-50 border-2 border-purple-300 p-5',
    'activity-pink': 'bg-gradient-to-r from-pink-100 to-pink-50 border-2 border-pink-300 p-5',
    'default': 'bg-white border border-karma-gray-light p-6 shadow-karma-soft'
  }
  
  return `${baseClasses} ${variantClasses[props.variant]}`
})

const iconContainerClasses = computed(() => {
  const isStatCard = props.variant.startsWith('stat-')
  if (isStatCard) {
    const iconBg = {
      'stat-rose': 'bg-gradient-to-r from-pink-500 to-rose-500',
      'stat-purple': 'bg-gradient-to-r from-violet-500 to-purple-500',
      'stat-success': 'bg-gradient-to-r from-green-500 to-emerald-500'
    }
    return `w-12 h-12 rounded-xl flex items-center justify-center ${iconBg[props.variant] || 'bg-gray-200'} shadow-sm`
  }
  return `w-16 h-16 rounded-2xl flex items-center justify-center bg-gradient-to-r from-violet-600 to-pink-600 shadow-karma-soft`
})

const titleClasses = computed(() => {
  const isStatCard = props.variant.startsWith('stat-')
  return `${isStatCard ? 'text-base font-semibold text-gray-600' : 'text-2xl font-black text-karma-black'}`
})

const valueClasses = computed(() => {
  const isStatCard = props.variant.startsWith('stat-')
  if (isStatCard) {
    const valueColor = {
      'stat-rose': 'text-pink-600',
      'stat-purple': 'text-purple-600',
      'stat-success': 'text-green-600'
    }
    return `text-3xl font-black ${valueColor[props.variant] || 'text-gray-900'} mb-1`
  }
  return `text-5xl font-black text-karma-black mb-2`
})

const descriptionClasses = computed(() => {
  const isStatCard = props.variant.startsWith('stat-')
  return `${isStatCard ? 'text-sm text-gray-500' : 'text-lg font-medium text-karma-gray-dark'}`
})

const badgeClasses = computed(() => {
  return 'badge-karma-label text-sm'
})
</script>