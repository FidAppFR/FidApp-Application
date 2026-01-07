<template>
  <teleport to="body">
    <transition name="modal">
      <div 
        v-if="modelValue" 
        class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[9999] p-4"
        @click="$emit('update:modelValue', false)"
      >
        <transition name="modal-content">
          <div 
            v-if="modelValue"
            :class="[
              'bg-white dark:bg-gray-800 rounded-xl p-6 w-full overflow-y-auto',
              sizeClass
            ]"
            @click.stop
          >
            <slot />
          </div>
        </transition>
      </div>
    </transition>
  </teleport>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  modelValue: boolean
  size?: 'sm' | 'md' | 'lg' | 'xl'
}>()

defineEmits<{
  'update:modelValue': [value: boolean]
}>()

const sizeClass = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'max-w-sm max-h-[80vh]'
    case 'lg':
      return 'max-w-2xl max-h-[90vh]'
    case 'xl':
      return 'max-w-4xl max-h-[90vh]'
    case 'md':
    default:
      return 'max-w-md max-h-[85vh]'
  }
})
</script>

<style scoped>
/* Animation pour le modal overlay */
.modal-enter-active, .modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from, .modal-leave-to {
  opacity: 0;
}

/* Animation pour le contenu du modal */
.modal-content-enter-active {
  transition: all 0.3s ease;
}

.modal-content-leave-active {
  transition: all 0.2s ease;
}

.modal-content-enter-from {
  transform: scale(0.9);
  opacity: 0;
}

.modal-content-leave-to {
  transform: scale(0.9);
  opacity: 0;
}
</style>