<template>
  <div id="app" class="p-8">
    <h1 class="text-2xl font-bold mb-4">App Debug Mode</h1>
    
    <div class="mb-4">
      <p class="font-semibold">Route actuelle: {{ currentRoute }}</p>
    </div>
    
    <div class="mb-4">
      <p class="font-semibold">Liens de test:</p>
      <div class="space-x-4">
        <router-link to="/" class="text-blue-500 underline">Home</router-link>
        <router-link to="/login" class="text-blue-500 underline">Login</router-link>
        <router-link to="/dashboard" class="text-blue-500 underline">Dashboard</router-link>
      </div>
    </div>
    
    <div class="border-2 border-gray-300 p-4 mt-4">
      <p class="text-sm text-gray-600 mb-2">Router View:</p>
      <router-view />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const currentRoute = computed(() => route.path)

console.log('App-debug mounted')
</script>