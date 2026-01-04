<template>
  <div>
    <!-- Pass Mobile cliquable -->
    <div 
      @click="showModal = true"
      class="bg-gradient-to-br from-violet-50 via-purple-50 to-pink-50 rounded-2xl shadow-md p-6 cursor-pointer hover:shadow-lg transition-all hover:scale-[1.02]"
    >
      <div class="text-center">
        <h3 class="text-lg font-bold bg-gradient-to-r from-violet-600 to-purple-600 bg-clip-text text-transparent mb-4">
          Pass Mobile
        </h3>
        
        <!-- QR Code épuré centré -->
        <div class="inline-block bg-white p-4 rounded-xl shadow-sm mb-4">
          <canvas ref="qrCanvas" id="qr-canvas"></canvas>
        </div>
        
        <!-- Code de fidélité intégré -->
        <div class="bg-white/80 backdrop-blur rounded-lg px-4 py-2 inline-block">
          <p class="text-xs text-gray-600 mb-1">Code fidélité</p>
          <p class="text-sm font-mono font-bold text-gray-900 tracking-wide">{{ formattedCode }}</p>
        </div>
        
        <p class="text-xs text-gray-600 mt-3 font-medium">
          Scannable en caisse • Touchez pour agrandir
        </p>
      </div>
    </div>

    <!-- Modal QR Code agrandi -->
    <Teleport to="body">
      <Transition
        enter-active-class="duration-300 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="duration-200 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <!-- Backdrop -->
          <div class="absolute inset-0 bg-black/70" @click="showModal = false"></div>
          
          <!-- Modal content -->
          <div class="relative bg-white rounded-3xl shadow-2xl p-8 max-w-md w-full">
            <!-- Header -->
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-2xl font-bold bg-gradient-to-r from-violet-600 to-purple-600 bg-clip-text text-transparent">
                Pass Mobile
              </h3>
              <button 
                @click="showModal = false"
                class="p-2 hover:bg-gray-100 rounded-full transition-colors"
              >
                <X :size="24" class="text-gray-500" />
              </button>
            </div>
            
            <!-- Code de fidélité -->
            <div class="bg-gradient-to-r from-violet-100 to-purple-100 rounded-xl p-4 mb-6">
              <p class="text-sm text-gray-700 font-medium mb-2">Code de fidélité</p>
              <div class="flex items-center justify-between">
                <p class="text-xl font-mono font-bold text-violet-900">{{ formattedCode }}</p>
                <button 
                  @click="copyToClipboard"
                  class="p-2 text-violet-600 hover:bg-white/50 rounded-lg transition-colors"
                >
                  <Copy :size="20" />
                </button>
              </div>
            </div>
            
            <!-- QR Code grand format -->
            <div class="flex flex-col items-center space-y-4">
              <div class="bg-white p-6 rounded-xl border-2 border-gray-200 shadow-inner">
                <canvas ref="qrCanvasLarge" id="qr-canvas-large"></canvas>
              </div>
              
              <p class="text-center text-sm text-gray-600">
                Présentez ce code au commerçant
              </p>
              
              <!-- Boutons d'action -->
              <div class="flex space-x-3 w-full">
                <button 
                  @click="downloadQRCode"
                  class="flex-1 px-4 py-3 bg-gradient-to-r from-violet-600 to-purple-600 text-white font-medium rounded-xl hover:shadow-lg transition-all flex items-center justify-center space-x-2"
                >
                  <Download :size="18" />
                  <span>Télécharger</span>
                </button>
                <button 
                  @click="showModal = false"
                  class="flex-1 px-4 py-3 bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium rounded-xl transition-colors"
                >
                  Fermer
                </button>
              </div>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
    
    <!-- Message de succès pour la copie -->
    <Transition
      enter-active-class="duration-200 ease-out"
      enter-from-class="opacity-0 translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 translate-y-2"
    >
      <div v-if="showCopySuccess" class="fixed bottom-4 right-4 z-[60] bg-green-500 text-white px-4 py-2 rounded-lg shadow-lg flex items-center space-x-2">
        <CheckCircle :size="16" />
        <span class="text-sm">Code copié !</span>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import { QrCode, Download, Copy, CheckCircle, X } from 'lucide-vue-next'
import QRCode from 'qrcode'

interface Props {
  loyaltyCode: string
  customerId: string
  companyId: string
  customerName?: string
  companyName?: string
}

const props = defineProps<Props>()

// Formater le code en XXXX - XXXX - XXXX - XXXX
const formattedCode = computed(() => {
  if (!props.loyaltyCode) return ''
  return props.loyaltyCode.match(/.{1,4}/g)?.join(' - ') || props.loyaltyCode
})
const qrCanvas = ref<HTMLCanvasElement | null>(null)
const qrCanvasLarge = ref<HTMLCanvasElement | null>(null)
const showCopySuccess = ref(false)
const showModal = ref(false)

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
  try {
    // Générer le QR code miniature
    if (qrCanvas.value) {
      await QRCode.toCanvas(qrCanvas.value, qrData.value, {
        width: 180,
        margin: 2,
        color: {
          dark: '#5B21B6',  // Violet foncé
          light: '#FFFFFF'
        },
        errorCorrectionLevel: 'H'
      })
    }
    
    // Générer le QR code grand format si la modal est ouverte
    if (qrCanvasLarge.value) {
      await QRCode.toCanvas(qrCanvasLarge.value, qrData.value, {
        width: 300,
        margin: 2,
        color: {
          dark: '#5B21B6',  // Violet foncé
          light: '#FFFFFF'
        },
        errorCorrectionLevel: 'H'
      })
    }
  } catch (error) {
    console.error('Erreur génération QR code:', error)
  }
}

// Observer l'ouverture de la modal pour générer le grand QR code
watch(showModal, async (newVal) => {
  if (newVal) {
    // Attendre que le DOM soit mis à jour
    await new Promise(resolve => setTimeout(resolve, 100))
    generateQRCode()
  }
})

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