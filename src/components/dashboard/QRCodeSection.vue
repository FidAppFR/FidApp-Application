<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-3xl font-black text-gray-900 dark:text-white">QR Code de Fidélité</h1>
      <p class="text-gray-600 dark:text-gray-400 mt-2">Générez et téléchargez le QR code pour vos clients</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Aperçu du QR Code -->
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
        <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Aperçu du QR Code</h3>
        
        <div id="qr-container" class="bg-gradient-to-br from-violet-50 to-pink-50 rounded-2xl p-8">
          <!-- Logo et nom de l'entreprise -->
          <div class="text-center mb-6">
            <div v-if="companyData.logo_url" class="w-20 h-20 mx-auto mb-3 rounded-xl overflow-hidden shadow-lg">
              <img :src="companyData.logo_url" alt="Logo" class="w-full h-full object-cover" />
            </div>
            <div v-else class="w-20 h-20 mx-auto mb-3 bg-gradient-to-r from-violet-600 to-pink-600 rounded-xl flex items-center justify-center shadow-lg">
              <Building2 :size="40" class="text-white" />
            </div>
            <h2 class="text-2xl font-black text-gray-900 dark:text-white">{{ companyData.name || 'Votre Entreprise' }}</h2>
            <p class="text-gray-600 dark:text-gray-400 mt-1">Programme de fidélité</p>
          </div>
          
          <!-- QR Code -->
          <div class="bg-white dark:bg-gray-800 rounded-xl p-4 shadow-inner flex items-center justify-center">
            <canvas ref="qrCanvas"></canvas>
          </div>
          
          <!-- Instructions -->
          <div class="mt-6 text-center">
            <p class="text-sm text-gray-700 dark:text-gray-300 font-medium">📱 Scannez pour accéder</p>
            <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">à votre espace fidélité</p>
          </div>
        </div>

        <!-- Statistiques -->
        <div class="mt-6 grid grid-cols-3 gap-4">
          <div class="bg-gray-50 dark:bg-gray-900 rounded-lg p-3">
            <p class="text-xs text-gray-500 dark:text-gray-400 mb-1">Total scans</p>
            <p class="text-xl font-bold text-orange-600">{{ scanStats.totalScans }}</p>
          </div>
          <div class="bg-gray-50 dark:bg-gray-900 rounded-lg p-3">
            <p class="text-xs text-gray-500 dark:text-gray-400 mb-1">Clients uniques</p>
            <p class="text-xl font-bold text-violet-600">{{ scanStats.totalUniqueClients }}</p>
          </div>
          <div class="bg-gray-50 dark:bg-gray-900 rounded-lg p-3">
            <p class="text-xs text-gray-500 dark:text-gray-400 mb-1">Scans aujourd'hui</p>
            <p class="text-xl font-bold text-pink-600">{{ scanStats.scansToday }}</p>
          </div>
        </div>
      </div>

      <!-- Options et actions -->
      <div class="space-y-6">
        <!-- Informations du QR Code -->
        <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Informations du QR Code</h3>
          
          <div class="space-y-4">
            <div>
              <label class="text-sm font-semibold text-gray-700 dark:text-gray-300">URL de destination</label>
              <div class="mt-1 flex items-center space-x-2">
                <input 
                  :value="qrUrl" 
                  readonly
                  class="flex-1 px-3 py-2 bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-lg text-sm text-gray-600 dark:text-gray-400"
                />
                <button 
                  @click="copyUrl"
                  class="p-2 text-violet-600 hover:bg-violet-50 rounded-lg transition-colors"
                >
                  <Copy :size="18" />
                </button>
              </div>
            </div>

            <div>
              <label class="text-sm font-semibold text-gray-700 dark:text-gray-300">Identifiant unique</label>
              <div class="mt-1 flex items-center space-x-2">
                <span class="font-mono text-lg text-violet-600 font-bold">{{ qrCodeId || 'Génération...' }}</span>
                <span class="text-xs text-gray-500 dark:text-gray-400">(Permanent)</span>
              </div>
            </div>

            <div>
              <label class="text-sm font-semibold text-gray-700 dark:text-gray-300">Type de QR Code</label>
              <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">Redirection vers la page d'authentification client</p>
            </div>

            <div>
              <label class="text-sm font-semibold text-gray-700 dark:text-gray-300">Validité</label>
              <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">Permanent - Aucune expiration</p>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
          <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Actions</h3>
          
          <div class="space-y-3">
            <button 
              @click="downloadAsPDF"
              :disabled="generatingPDF"
              class="w-full bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold py-3 px-6 rounded-xl hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:hover:scale-100 flex items-center justify-center space-x-2"
            >
              <Download :size="20" />
              <span>{{ generatingPDF ? 'Génération...' : 'Télécharger en PDF' }}</span>
            </button>

            <button 
              @click="downloadAsImage"
              class="w-full bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 text-gray-700 dark:text-gray-300 font-bold py-3 px-6 rounded-xl transition-colors flex items-center justify-center space-x-2"
            >
              <Image :size="20" />
              <span>Télécharger en image</span>
            </button>

            <button 
              @click="printQR"
              class="w-full border-2 border-gray-300 text-gray-700 dark:text-gray-300 font-bold py-3 px-6 rounded-xl hover:bg-gray-50 dark:bg-gray-900 transition-colors flex items-center justify-center space-x-2"
            >
              <Printer :size="20" />
              <span>Imprimer</span>
            </button>
          </div>
        </div>

        <!-- Conseils d'utilisation -->
        <div class="bg-violet-50 rounded-xl p-6">
          <h4 class="font-bold text-violet-900 mb-2 flex items-center space-x-2">
            <Lightbulb :size="20" />
            <span>Conseils d'utilisation</span>
          </h4>
          <ul class="space-y-2 text-sm text-violet-700">
            <li>• Imprimez et affichez le QR code à votre caisse</li>
            <li>• Ajoutez-le à vos supports marketing</li>
            <li>• Partagez-le sur vos réseaux sociaux</li>
            <li>• Intégrez-le à votre site web</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Message de succès -->
    <Teleport to="body">
      <Transition
        enter-active-class="duration-200 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="duration-150 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showSuccess" class="fixed bottom-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg flex items-center space-x-2 z-50">
          <CheckCircle :size="20" />
          <span>{{ successMessage }}</span>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Building2, Download, Image, Printer, Copy, Lightbulb, CheckCircle } from 'lucide-vue-next'
import QRCode from 'qrcode'
import jsPDF from 'jspdf'
import html2canvas from 'html2canvas'
import { supabase } from '@/services/supabase'
import { getScanStats } from '@/api/scanEndpoint'

interface CompanyData {
  id: string
  name: string
  logo_url: string | null
  qr_code_id: string | null
}

const qrCanvas = ref<HTMLCanvasElement>()
const companyData = ref<CompanyData>({
  id: '',
  name: '',
  logo_url: null,
  qr_code_id: null
})
const qrUrl = ref('')
const qrCodeId = ref('')
const generatingPDF = ref(false)
const showSuccess = ref(false)
const successMessage = ref('')

const scanStats = ref({
  totalScans: 0,
  totalUniqueClients: 0,
  scansToday: 0,
  scansThisWeek: 0,
  scansThisMonth: 0,
  averageScansPerDay: 0
})

// Charger les données de l'entreprise
const loadCompanyData = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    let { data } = await supabase
      .from('users')
      .select('id, company, logo_url, qr_code_id')
      .eq('auth_id', user.id)
      .single()

    if (data) {
      // Si pas de qr_code_id, en générer un et le sauvegarder
      if (!data.qr_code_id) {
        const newQrCodeId = generateUniqueId()
        
        const { data: updatedData, error } = await supabase
          .from('users')
          .update({ qr_code_id: newQrCodeId })
          .eq('auth_id', user.id)
          .select()
          .single()
        
        if (!error && updatedData) {
          data = updatedData
        }
      }
      
      if (data) {
        companyData.value = {
          id: data.id,
          name: data.company || 'FidApp',
          logo_url: data.logo_url,
          qr_code_id: data.qr_code_id
        }

        // Utiliser le qr_code_id pour l'URL (plus court et permanent)
        const baseUrl = window.location.origin
        qrCodeId.value = data.qr_code_id
        qrUrl.value = `${baseUrl}/c/${data.qr_code_id}`
      }
      
      // Générer le QR code
      generateQRCode()
    }

    // Charger les statistiques
    const { count: customerCount } = await supabase
      .from('customers')
      .select('*', { count: 'exact', head: true })
      .eq('company_id', data?.id)

    stats.value.totalCustomers = customerCount || 0
    stats.value.monthlyScans = Math.floor(Math.random() * 50) + 10 // Simulé
  } catch (error) {
    console.error('Erreur lors du chargement:', error)
  }
}

// Générer un ID unique pour le QR code
const generateUniqueId = () => {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  let result = ''
  for (let i = 0; i < 10; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length))
  }
  return result
}

// Générer le QR code
const generateQRCode = async () => {
  if (!qrCanvas.value) return

  try {
    await QRCode.toCanvas(qrCanvas.value, qrUrl.value, {
      width: 256,
      margin: 2,
      color: {
        dark: '#1e293b',
        light: '#ffffff'
      },
      errorCorrectionLevel: 'H'
    })
  } catch (error) {
    console.error('Erreur lors de la génération du QR code:', error)
  }
}

// Copier l'URL
const copyUrl = () => {
  navigator.clipboard.writeText(qrUrl.value)
  showSuccessMessage('URL copiée!')
}

// Télécharger en PDF
const downloadAsPDF = async () => {
  generatingPDF.value = true
  
  try {
    const element = document.getElementById('qr-container')
    if (!element) return

    // Capturer le conteneur en image
    const canvas = await html2canvas(element, {
      scale: 2,
      backgroundColor: '#ffffff'
    })

    // Créer le PDF
    const pdf = new jsPDF({
      orientation: 'portrait',
      unit: 'mm',
      format: 'a4'
    })

    // Calculer les dimensions
    const imgWidth = 170
    const imgHeight = (canvas.height * imgWidth) / canvas.width
    const xPosition = (pdf.internal.pageSize.width - imgWidth) / 2
    const yPosition = 20

    // Ajouter l'image au PDF
    pdf.addImage(
      canvas.toDataURL('image/png'),
      'PNG',
      xPosition,
      yPosition,
      imgWidth,
      imgHeight
    )

    // Ajouter du texte
    pdf.setFontSize(12)
    pdf.setTextColor(100)
    const textY = yPosition + imgHeight + 10
    pdf.text('Scannez ce QR code pour accéder au programme de fidélité', pdf.internal.pageSize.width / 2, textY, {
      align: 'center'
    })

    // Télécharger
    pdf.save(`QRCode-${companyData.value.name.replace(/\s+/g, '_')}.pdf`)
    showSuccessMessage('PDF téléchargé!')
  } catch (error) {
    console.error('Erreur lors de la génération du PDF:', error)
  } finally {
    generatingPDF.value = false
  }
}

// Télécharger en image
const downloadAsImage = async () => {
  try {
    const element = document.getElementById('qr-container')
    if (!element) return

    const canvas = await html2canvas(element, {
      scale: 2,
      backgroundColor: '#ffffff'
    })

    // Créer un lien de téléchargement
    const link = document.createElement('a')
    link.download = `QRCode-${companyData.value.name.replace(/\s+/g, '_')}.png`
    link.href = canvas.toDataURL()
    link.click()
    
    showSuccessMessage('Image téléchargée!')
  } catch (error) {
    console.error('Erreur lors du téléchargement de l\'image:', error)
  }
}

// Imprimer
const printQR = () => {
  window.print()
  showSuccessMessage('Prêt à imprimer!')
}

// Afficher un message de succès
const showSuccessMessage = (message: string) => {
  successMessage.value = message
  showSuccess.value = true
  setTimeout(() => {
    showSuccess.value = false
  }, 3000)
}

// Charger les statistiques de scans
const loadScanStats = async () => {
  try {
    const stats = await getScanStats()
    if (stats) {
      scanStats.value = stats
    }
  } catch (error) {
    console.error('Erreur chargement stats scans:', error)
  }
}

onMounted(() => {
  loadCompanyData()
  loadScanStats()
})
</script>

<style scoped>
@media print {
  body * {
    visibility: hidden;
  }
  
  #qr-container, #qr-container * {
    visibility: visible;
  }
  
  #qr-container {
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
  }
}
</style>