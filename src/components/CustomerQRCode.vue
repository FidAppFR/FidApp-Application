<template>
  <div class="bg-white rounded-2xl shadow-lg p-6">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-xl font-bold text-gray-900 flex items-center space-x-2">
        <QrCode :size="24" class="text-violet-600" />
        <span>Ma Carte de Fidélité</span>
      </h3>
      <button 
        @click="downloadQRCode"
        class="text-sm text-violet-600 hover:text-violet-700 font-medium flex items-center space-x-1"
      >
        <Download :size="16" />
        <span>Télécharger</span>
      </button>
    </div>

    <!-- Code de fidélité -->
    <div class="bg-gradient-to-r from-violet-50 to-purple-50 rounded-xl p-4 mb-4 border border-violet-200">
      <p class="text-sm text-gray-600 mb-1">Code de fidélité</p>
      <div class="flex items-center justify-between">
        <p class="text-2xl font-mono font-bold text-violet-900">{{ loyaltyCode }}</p>
        <button 
          @click="copyToClipboard"
          class="p-2 text-violet-600 hover:bg-violet-100 rounded-lg transition-colors"
        >
          <Copy :size="20" />
        </button>
      </div>
    </div>

    <!-- QR Code -->
    <div class="flex flex-col items-center space-y-4">
      <div class="bg-white p-4 rounded-xl border-2 border-gray-200">
        <canvas ref="qrCanvas" id="qr-canvas"></canvas>
      </div>
      
      <div class="text-center">
        <p class="text-sm text-gray-600 mb-2">
          Présentez ce QR code en caisse pour cumuler vos points
        </p>
        <p class="text-xs text-gray-500">
          Ce code est unique et personnel, ne le partagez pas
        </p>
      </div>
    </div>

    <!-- Message de succès pour la copie -->
    <Transition
      enter-active-class="duration-200 ease-out"
      enter-from-class="opacity-0 translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 translate-y-2"
    >
      <div v-if="showCopySuccess" class="absolute top-4 right-4 bg-green-500 text-white px-4 py-2 rounded-lg shadow-lg flex items-center space-x-2">
        <CheckCircle :size="16" />
        <span class="text-sm">Code copié !</span>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import { QrCode, Download, Copy, CheckCircle } from 'lucide-vue-next'
import QRCode from 'qrcode'

interface Props {
  loyaltyCode: string
  customerId: string
  companyId: string
  customerName?: string
  companyName?: string
}

const props = defineProps<Props>()
const qrCanvas = ref<HTMLCanvasElement | null>(null)
const showCopySuccess = ref(false)

// Données à encoder dans le QR code
const qrData = computed(() => {
  // Format: FIDAPP://customer/companyId/loyaltyCode
  // Cela permettra à l'app de scanner et identifier rapidement le client
  return JSON.stringify({
    type: 'fidapp_customer',
    company_id: props.companyId,
    customer_id: props.customerId,
    loyalty_code: props.loyaltyCode,
    timestamp: Date.now()
  })
})

// Générer le QR code
const generateQRCode = async () => {
  if (!qrCanvas.value) return
  
  try {
    await QRCode.toCanvas(qrCanvas.value, qrData.value, {
      width: 250,
      margin: 2,
      color: {
        dark: '#5B21B6',  // Violet foncé
        light: '#FFFFFF'
      },
      errorCorrectionLevel: 'H'
    })
  } catch (error) {
    console.error('Erreur génération QR code:', error)
  }
}

// Télécharger le QR code
const downloadQRCode = () => {
  if (!qrCanvas.value) return
  
  // Créer un canvas temporaire avec plus d'infos
  const tempCanvas = document.createElement('canvas')
  const ctx = tempCanvas.getContext('2d')
  if (!ctx) return
  
  // Dimensions du canvas final
  tempCanvas.width = 350
  tempCanvas.height = 450
  
  // Fond blanc
  ctx.fillStyle = '#FFFFFF'
  ctx.fillRect(0, 0, tempCanvas.width, tempCanvas.height)
  
  // Titre
  ctx.fillStyle = '#1F2937'
  ctx.font = 'bold 20px system-ui'
  ctx.textAlign = 'center'
  ctx.fillText(props.companyName || 'Carte de Fidélité', tempCanvas.width / 2, 40)
  
  // QR Code
  ctx.drawImage(qrCanvas.value, 50, 70, 250, 250)
  
  // Code de fidélité
  ctx.fillStyle = '#5B21B6'
  ctx.font = 'bold 24px monospace'
  ctx.textAlign = 'center'
  ctx.fillText(props.loyaltyCode, tempCanvas.width / 2, 360)
  
  // Nom du client
  if (props.customerName) {
    ctx.fillStyle = '#6B7280'
    ctx.font = '16px system-ui'
    ctx.fillText(props.customerName, tempCanvas.width / 2, 390)
  }
  
  // Footer
  ctx.fillStyle = '#9CA3AF'
  ctx.font = '12px system-ui'
  ctx.fillText('FidApp - Programme de Fidélité', tempCanvas.width / 2, 420)
  
  // Télécharger
  const link = document.createElement('a')
  link.download = `carte-fidelite-${props.loyaltyCode}.png`
  link.href = tempCanvas.toDataURL('image/png')
  link.click()
}

// Copier le code dans le presse-papier
const copyToClipboard = async () => {
  try {
    await navigator.clipboard.writeText(props.loyaltyCode)
    showCopySuccess.value = true
    setTimeout(() => {
      showCopySuccess.value = false
    }, 2000)
  } catch (error) {
    console.error('Erreur copie:', error)
  }
}

// Regenerer le QR code si les données changent
watch(() => props.loyaltyCode, () => {
  generateQRCode()
})

onMounted(() => {
  generateQRCode()
})
</script>