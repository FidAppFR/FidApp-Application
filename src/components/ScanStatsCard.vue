<template>
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    <!-- Total Scans -->
    <div class="bg-gradient-to-br from-rose-500 to-pink-600 p-6 rounded-2xl text-white shadow-xl">
      <div class="flex items-center justify-between mb-4">
        <QrCode class="w-8 h-8" />
        <span class="text-rose-100 text-sm font-semibold">Total</span>
      </div>
      <div class="text-4xl font-black mb-1">
        {{ stats.totalScans.toLocaleString('fr-FR') }}
      </div>
      <div class="text-rose-100 text-sm">Scans total</div>
    </div>

    <!-- Scans Today -->
    <div class="bg-gradient-to-br from-orange-500 to-amber-600 p-6 rounded-2xl text-white shadow-xl">
      <div class="flex items-center justify-between mb-4">
        <Calendar class="w-8 h-8" />
        <span class="text-orange-100 text-sm font-semibold">Aujourd'hui</span>
      </div>
      <div class="text-4xl font-black mb-1">
        {{ stats.scansToday.toLocaleString('fr-FR') }}
      </div>
      <div class="text-orange-100 text-sm">Scans aujourd'hui</div>
    </div>

    <!-- Unique Clients -->
    <div class="bg-gradient-to-br from-emerald-500 to-green-600 p-6 rounded-2xl text-white shadow-xl">
      <div class="flex items-center justify-between mb-4">
        <Users class="w-8 h-8" />
        <span class="text-emerald-100 text-sm font-semibold">Uniques</span>
      </div>
      <div class="text-4xl font-black mb-1">
        {{ stats.totalUniqueClients.toLocaleString('fr-FR') }}
      </div>
      <div class="text-emerald-100 text-sm">Clients scannés</div>
    </div>

    <!-- Average per day -->
    <div class="bg-gradient-to-br from-blue-500 to-indigo-600 p-6 rounded-2xl text-white shadow-xl">
      <div class="flex items-center justify-between mb-4">
        <TrendingUp class="w-8 h-8" />
        <span class="text-blue-100 text-sm font-semibold">Moyenne</span>
      </div>
      <div class="text-4xl font-black mb-1">
        {{ stats.averageScansPerDay.toFixed(1) }}
      </div>
      <div class="text-blue-100 text-sm">Scans / jour</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { QrCode, Calendar, Users, TrendingUp } from 'lucide-vue-next'
import { getScanStats } from '../api/scanEndpoint'

interface ScanStats {
  totalScans: number
  totalUniqueClients: number
  scansToday: number
  scansThisWeek: number
  scansThisMonth: number
  averageScansPerDay: number
}

const stats = ref<ScanStats>({
  totalScans: 0,
  totalUniqueClients: 0,
  scansToday: 0,
  scansThisWeek: 0,
  scansThisMonth: 0,
  averageScansPerDay: 0
})

const loading = ref(true)

async function loadStats() {
  try {
    const data = await getScanStats()
    if (data) {
      stats.value = data
    }
  } catch (error) {
    console.error('Erreur chargement stats:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadStats()
  // Rafraîchir les stats toutes les 30 secondes
  setInterval(loadStats, 30000)
})
</script>