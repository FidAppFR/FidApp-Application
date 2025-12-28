<template>
  <div class="bg-white rounded-2xl border border-gray-200 overflow-hidden shadow-sm">
    <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
      <h3 class="text-lg font-bold text-gray-900 flex items-center gap-2">
        <QrCode class="w-5 h-5 text-orange-500" />
        Historique des scans
      </h3>
      <button 
        @click="loadHistory"
        class="text-sm text-purple-600 hover:text-purple-700 flex items-center gap-1"
      >
        <RefreshCw :class="['w-4 h-4', loading && 'animate-spin']" />
        Actualiser
      </button>
    </div>

    <div v-if="loading && scanHistory.length === 0" class="p-8 text-center">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-500 mx-auto"></div>
    </div>

    <div v-else-if="scanHistory.length === 0" class="p-8 text-center text-gray-500">
      <QrCode class="w-12 h-12 mx-auto mb-3 text-gray-300" />
      <p>Aucun scan enregistré pour le moment</p>
    </div>

    <div v-else class="overflow-x-auto">
      <table class="w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">
              Date & Heure
            </th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">
              Client
            </th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">
              Type
            </th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">
              Points
            </th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">
              Montant
            </th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase">
              Lieu
            </th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr 
            v-for="scan in scanHistory" 
            :key="scan.id"
            class="hover:bg-gray-50 transition-colors"
          >
            <td class="px-6 py-4 text-sm text-gray-900">
              {{ formatDate(scan.scannedAt) }}
            </td>
            <td class="px-6 py-4">
              <div class="flex items-center gap-2">
                <div class="w-8 h-8 bg-gradient-to-br from-orange-400 to-rose-500 rounded-full flex items-center justify-center text-white text-xs font-bold">
                  {{ getInitials(scan.customerName) }}
                </div>
                <span class="text-sm font-medium text-gray-900">
                  {{ scan.customerName }}
                </span>
              </div>
            </td>
            <td class="px-6 py-4">
              <span :class="getScanTypeBadgeClass(scan.scanType)">
                {{ getScanTypeLabel(scan.scanType) }}
              </span>
            </td>
            <td class="px-6 py-4 text-sm font-semibold text-green-600">
              {{ scan.pointsAdded ? `+${scan.pointsAdded}` : '-' }}
            </td>
            <td class="px-6 py-4 text-sm text-gray-900">
              {{ scan.euroAmount ? `${scan.euroAmount}€` : '-' }}
            </td>
            <td class="px-6 py-4 text-sm text-gray-600">
              {{ scan.location || '-' }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { QrCode, RefreshCw } from 'lucide-vue-next'
import { getScanHistory, type ScanHistoryItem } from '../api/scanEndpoint'

interface Props {
  customerId?: string
  limit?: number
}

const props = withDefaults(defineProps<Props>(), {
  limit: 20
})

const scanHistory = ref<ScanHistoryItem[]>([])
const loading = ref(false)

function formatDate(dateStr: string): string {
  const date = new Date(dateStr)
  const options: Intl.DateTimeFormatOptions = {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }
  return date.toLocaleDateString('fr-FR', options)
}

function getInitials(name: string): string {
  const parts = name.split(' ')
  return parts.map(p => p[0]).join('').toUpperCase().substring(0, 2)
}

function getScanTypeLabel(type: string): string {
  const labels: Record<string, string> = {
    'points_add': '➕ Ajout points',
    'reward_claim': '🎁 Récompense',
    'check_balance': '👀 Consultation',
    'attendance': '📍 Présence',
    'registration': '✨ Inscription'
  }
  return labels[type] || type
}

function getScanTypeBadgeClass(type: string): string {
  const classes: Record<string, string> = {
    'points_add': 'inline-flex px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700',
    'reward_claim': 'inline-flex px-3 py-1 rounded-full text-xs font-semibold bg-purple-100 text-purple-700',
    'check_balance': 'inline-flex px-3 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-700',
    'attendance': 'inline-flex px-3 py-1 rounded-full text-xs font-semibold bg-yellow-100 text-yellow-700',
    'registration': 'inline-flex px-3 py-1 rounded-full text-xs font-semibold bg-pink-100 text-pink-700'
  }
  return classes[type] || 'inline-flex px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-700'
}

async function loadHistory() {
  loading.value = true
  try {
    const data = await getScanHistory(props.customerId, props.limit)
    scanHistory.value = data
  } catch (error) {
    console.error('Erreur chargement historique:', error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadHistory()
})
</script>