<template>
  <div class="bg-white rounded-2xl border border-gray-200 shadow-sm p-6">
    <h3 class="text-xl font-bold text-gray-900 mb-6 flex items-center gap-2">
      <TrendingUp class="w-5 h-5 text-purple-500" />
      Évolution des scans (30 derniers jours)
    </h3>
    
    <div v-if="loading" class="flex items-center justify-center h-64">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-500"></div>
    </div>
    
    <canvas v-else ref="chartCanvas" class="w-full" style="height: 300px;"></canvas>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { TrendingUp } from 'lucide-vue-next'
import { getScanChartData } from '../api/scanEndpoint'

const chartCanvas = ref<HTMLCanvasElement | null>(null)
const loading = ref(true)
const chartData = ref<{ date: string; scans: number }[]>([])

async function loadChartData() {
  try {
    loading.value = true
    const data = await getScanChartData(30)
    chartData.value = data
    
    if (chartCanvas.value) {
      drawChart()
    }
  } catch (error) {
    console.error('Erreur chargement données graphique:', error)
  } finally {
    loading.value = false
  }
}

function drawChart() {
  if (!chartCanvas.value || chartData.value.length === 0) return
  
  const ctx = chartCanvas.value.getContext('2d')
  if (!ctx) return
  
  const canvas = chartCanvas.value
  const padding = 40
  const width = canvas.width = canvas.offsetWidth
  const height = canvas.height = 300
  
  // Clear canvas
  ctx.clearRect(0, 0, width, height)
  
  // Calculate dimensions
  const chartWidth = width - padding * 2
  const chartHeight = height - padding * 2
  
  // Find max value
  const maxScans = Math.max(...chartData.value.map(d => d.scans), 10)
  
  // Draw grid lines
  ctx.strokeStyle = '#f0f0f0'
  ctx.lineWidth = 1
  
  // Horizontal grid lines
  for (let i = 0; i <= 5; i++) {
    const y = padding + (chartHeight / 5) * i
    ctx.beginPath()
    ctx.moveTo(padding, y)
    ctx.lineTo(width - padding, y)
    ctx.stroke()
    
    // Y-axis labels
    ctx.fillStyle = '#6b7280'
    ctx.font = '11px sans-serif'
    ctx.textAlign = 'right'
    const value = Math.round((maxScans / 5) * (5 - i))
    ctx.fillText(value.toString(), padding - 10, y + 4)
  }
  
  // Draw line chart
  ctx.strokeStyle = 'url(#gradient)'
  const gradient = ctx.createLinearGradient(0, 0, width, 0)
  gradient.addColorStop(0, '#f43f5e')
  gradient.addColorStop(0.5, '#f97316')
  gradient.addColorStop(1, '#f59e0b')
  ctx.strokeStyle = gradient
  ctx.lineWidth = 3
  ctx.lineCap = 'round'
  ctx.lineJoin = 'round'
  
  ctx.beginPath()
  
  const xStep = chartWidth / (chartData.value.length - 1 || 1)
  
  // Draw the line
  chartData.value.forEach((point, index) => {
    const x = padding + xStep * index
    const y = padding + chartHeight - (point.scans / maxScans) * chartHeight
    
    if (index === 0) {
      ctx.moveTo(x, y)
    } else {
      ctx.lineTo(x, y)
    }
  })
  
  ctx.stroke()
  
  // Draw area under line
  const areaGradient = ctx.createLinearGradient(0, padding, 0, height - padding)
  areaGradient.addColorStop(0, 'rgba(249, 115, 22, 0.3)')
  areaGradient.addColorStop(1, 'rgba(249, 115, 22, 0.0)')
  ctx.fillStyle = areaGradient
  
  ctx.beginPath()
  chartData.value.forEach((point, index) => {
    const x = padding + xStep * index
    const y = padding + chartHeight - (point.scans / maxScans) * chartHeight
    
    if (index === 0) {
      ctx.moveTo(x, y)
    } else {
      ctx.lineTo(x, y)
    }
  })
  ctx.lineTo(width - padding, height - padding)
  ctx.lineTo(padding, height - padding)
  ctx.closePath()
  ctx.fill()
  
  // Draw dots
  ctx.fillStyle = '#f97316'
  chartData.value.forEach((point, index) => {
    const x = padding + xStep * index
    const y = padding + chartHeight - (point.scans / maxScans) * chartHeight
    
    ctx.beginPath()
    ctx.arc(x, y, 4, 0, Math.PI * 2)
    ctx.fill()
  })
  
  // X-axis labels (show every 5th label to avoid crowding)
  ctx.fillStyle = '#6b7280'
  ctx.font = '10px sans-serif'
  ctx.textAlign = 'center'
  
  chartData.value.forEach((point, index) => {
    if (index % 5 === 0 || index === chartData.value.length - 1) {
      const x = padding + xStep * index
      ctx.fillText(point.date, x, height - padding + 20)
    }
  })
}

// Redraw chart on window resize
function handleResize() {
  if (!loading.value && chartCanvas.value) {
    drawChart()
  }
}

onMounted(() => {
  loadChartData()
  window.addEventListener('resize', handleResize)
})

// Clean up
onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
})
</script>