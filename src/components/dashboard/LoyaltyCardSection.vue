<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-3xl font-black text-gray-900">Personnaliser Votre Carte</h1>
      <p class="text-gray-600 mt-2">Créez une carte de fidélité unique pour vos clients</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Aperçu de la carte -->
      <div>
        <h3 class="text-lg font-bold text-gray-900 mb-4">Aperçu en temps réel</h3>
        <div class="bg-gray-100 rounded-xl p-6 flex items-center justify-center min-h-[400px]">
          <div 
            :style="cardStyles"
            class="w-full max-w-sm transform hover:scale-105 transition-transform duration-300"
          >
            <!-- Recto de la carte -->
            <div class="relative h-56 rounded-2xl shadow-2xl overflow-hidden">
              <div class="absolute inset-0 bg-gradient-to-br" :class="cardData.gradient"></div>
              <div class="absolute inset-0 bg-black/10"></div>
              <div class="relative h-full p-6 flex flex-col justify-between text-white">
                <!-- Logo et nom -->
                <div class="flex items-start justify-between">
                  <div>
                    <h4 class="text-2xl font-black">{{ cardData.companyName || 'Votre Entreprise' }}</h4>
                    <p class="text-white/80 text-sm mt-1">Carte de fidélité</p>
                  </div>
                  <!-- Logo sur la carte -->
                  <div v-if="logoPreview || cardData.logoUrl" 
                       class="w-12 h-12 bg-white rounded-lg overflow-hidden shadow-lg">
                    <img 
                      :src="(logoPreview || cardData.logoUrl) ?? ''" 
                      alt="Logo"
                      class="w-full h-full object-cover"
                    />
                  </div>
                  <div v-else 
                       class="w-12 h-12 bg-white/20 backdrop-blur rounded-lg flex items-center justify-center">
                    <Building2 :size="24" class="text-white/60" />
                  </div>
                </div>
                
                <!-- Points (affichage conditionnel) -->
                <div v-if="cardData.showPoints" class="space-y-2">
                  <div class="flex items-center space-x-2">
                    <Star :size="20" class="text-yellow-400 fill-current" />
                    <span class="text-2xl font-bold">250 pts</span>
                  </div>
                  <p class="text-white/80 text-sm">Membre depuis 2024</p>
                </div>
                
                <!-- Numéro de carte -->
                <div>
                  <p class="text-xs text-white/60">N° de carte</p>
                  <p class="font-mono text-sm">**** **** **** 1234</p>
                </div>
              </div>
            </div>
            
            <!-- Verso avec QR code (affichage conditionnel) -->
            <div v-if="cardData.showQR || cardData.showExpiry" class="mt-4 bg-white rounded-2xl shadow-lg p-6">
              <div class="flex items-center justify-between">
                <div v-if="cardData.showQR" class="flex-1">
                  <p class="text-xs text-gray-500 uppercase tracking-wider">Scannez pour gagner des points</p>
                  <div class="mt-3 w-24 h-24 bg-gray-200 rounded-lg flex items-center justify-center">
                    <QrCode :size="48" class="text-gray-400" />
                  </div>
                </div>
                <div v-if="cardData.showExpiry" class="text-right">
                  <p class="text-xs text-gray-500">Valable jusqu'au</p>
                  <p class="font-bold">12/2025</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Options de personnalisation -->
      <div class="space-y-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h3 class="text-lg font-bold text-gray-900 mb-4">Options de personnalisation</h3>
          
          <div class="space-y-4">
            <!-- Nom de l'entreprise -->
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Nom sur la carte
              </label>
              <input
                v-model="cardData.companyName"
                type="text"
                class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                placeholder="Nom de votre entreprise"
              />
            </div>

            <!-- Couleur de la carte -->
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Thème de couleur
              </label>
              <div class="grid grid-cols-3 gap-3">
                <button
                  @click="cardData.gradient = 'from-violet-600 to-pink-600'"
                  :class="[
                    'h-20 rounded-xl bg-gradient-to-br from-violet-600 to-pink-600 transition-all',
                    cardData.gradient === 'from-violet-600 to-pink-600' ? 'ring-4 ring-violet-600 ring-offset-2' : ''
                  ]"
                ></button>
                <button
                  @click="cardData.gradient = 'from-blue-600 to-cyan-600'"
                  :class="[
                    'h-20 rounded-xl bg-gradient-to-br from-blue-600 to-cyan-600 transition-all',
                    cardData.gradient === 'from-blue-600 to-cyan-600' ? 'ring-4 ring-blue-600 ring-offset-2' : ''
                  ]"
                ></button>
                <button
                  @click="cardData.gradient = 'from-green-600 to-emerald-600'"
                  :class="[
                    'h-20 rounded-xl bg-gradient-to-br from-green-600 to-emerald-600 transition-all',
                    cardData.gradient === 'from-green-600 to-emerald-600' ? 'ring-4 ring-green-600 ring-offset-2' : ''
                  ]"
                ></button>
                <button
                  @click="cardData.gradient = 'from-orange-600 to-red-600'"
                  :class="[
                    'h-20 rounded-xl bg-gradient-to-br from-orange-600 to-red-600 transition-all',
                    cardData.gradient === 'from-orange-600 to-red-600' ? 'ring-4 ring-orange-600 ring-offset-2' : ''
                  ]"
                ></button>
                <button
                  @click="cardData.gradient = 'from-purple-600 to-indigo-600'"
                  :class="[
                    'h-20 rounded-xl bg-gradient-to-br from-purple-600 to-indigo-600 transition-all',
                    cardData.gradient === 'from-purple-600 to-indigo-600' ? 'ring-4 ring-purple-600 ring-offset-2' : ''
                  ]"
                ></button>
                <button
                  @click="cardData.gradient = 'from-gray-800 to-gray-900'"
                  :class="[
                    'h-20 rounded-xl bg-gradient-to-br from-gray-800 to-gray-900 transition-all',
                    cardData.gradient === 'from-gray-800 to-gray-900' ? 'ring-4 ring-gray-800 ring-offset-2' : ''
                  ]"
                ></button>
              </div>
            </div>

            <!-- Logo -->
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Logo de l'entreprise
              </label>
              <div class="flex items-center space-x-4">
                <!-- Aperçu du logo -->
                <div v-if="logoPreview || cardData.logoUrl" 
                     class="relative group w-20 h-20">
                  <div class="w-20 h-20 rounded-xl overflow-hidden border-2 border-gray-200">
                    <img 
                      :src="(logoPreview || cardData.logoUrl) ?? ''" 
                      alt="Logo"
                      class="w-full h-full object-cover"
                    />
                  </div>
                  <!-- Bouton supprimer -->
                  <button
                    type="button"
                    @click="removeLogo"
                    class="absolute -top-2 -right-2 bg-red-500 hover:bg-red-600 text-white rounded-full p-1 shadow-lg transition-colors"
                  >
                    <Trash2 :size="14" />
                  </button>
                </div>
                <div v-else 
                     class="w-20 h-20 bg-gray-100 rounded-xl flex items-center justify-center">
                  <Upload :size="24" class="text-gray-400" />
                </div>
                
                <!-- Input file caché -->
                <input 
                  ref="fileInput"
                  type="file"
                  accept="image/png, image/jpeg, image/jpg, image/webp"
                  @change="handleFileUpload"
                  class="hidden"
                />
                
                <!-- Bouton upload -->
                <button 
                  type="button"
                  @click="($refs.fileInput as HTMLInputElement)?.click()"
                  :disabled="uploadingLogo"
                  class="px-4 py-2 bg-violet-100 text-violet-600 rounded-lg font-medium hover:bg-violet-200 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {{ uploadingLogo ? 'Chargement...' : (logoPreview ? 'Changer le logo' : 'Télécharger un logo') }}
                </button>
              </div>
              
              <!-- Message d'erreur -->
              <div v-if="uploadError" class="mt-2 bg-red-50 border border-red-200 rounded-lg p-3 flex items-center space-x-2">
                <AlertCircle :size="16" class="text-red-600" />
                <span class="text-sm text-red-700">{{ uploadError }}</span>
              </div>
            </div>

            <!-- Message personnalisé -->
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Message de bienvenue
              </label>
              <textarea
                v-model="cardData.welcomeMessage"
                rows="3"
                class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                placeholder="Merci de votre fidélité !"
              ></textarea>
            </div>

            <!-- Options avancées -->
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-3">
                Options avancées
              </label>
              <div class="space-y-3">
                <label class="flex items-center space-x-3">
                  <input type="checkbox" class="w-4 h-4 text-violet-600 rounded" v-model="cardData.showPoints" />
                  <span class="text-sm">Afficher le solde de points</span>
                </label>
                <label class="flex items-center space-x-3">
                  <input type="checkbox" class="w-4 h-4 text-violet-600 rounded" v-model="cardData.showQR" />
                  <span class="text-sm">Afficher le QR code</span>
                </label>
                <label class="flex items-center space-x-3">
                  <input type="checkbox" class="w-4 h-4 text-violet-600 rounded" v-model="cardData.showExpiry" />
                  <span class="text-sm">Afficher la date d'expiration</span>
                </label>
              </div>
            </div>
          </div>
        </div>

        <!-- Bouton d'action -->
        <div>
          <button 
            @click="saveCardSettings"
            :disabled="saving"
            class="w-full bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold px-6 py-3 rounded-full hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:hover:scale-100"
          >
            {{ saving ? 'Enregistrement...' : 'Enregistrer les modifications' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Star, QrCode, Upload, Building2, Trash2, AlertCircle } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

const cardData = ref({
  companyName: 'FidApp',
  gradient: 'from-violet-600 to-pink-600',
  welcomeMessage: 'Merci de votre fidélité !',
  showPoints: true,
  showQR: true,
  showExpiry: true,
  logoUrl: null as string | null
})

const fileInput = ref<HTMLInputElement>()
const logoPreview = ref<string | null>(null)
const uploadingLogo = ref(false)
const uploadError = ref<string | null>(null)
const selectedFile = ref<File | null>(null)
const saving = ref(false)
const loading = ref(true)

const cardStyles = computed(() => ({
  // Styles dynamiques si nécessaire
}))

// Charger les données existantes
const loadCardData = async () => {
  loading.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data, error } = await supabase
      .from('users')
      .select('company, logo_url, card_settings')
      .eq('auth_id', user.id)
      .single()

    if (!error && data) {
      cardData.value.companyName = data.company || 'FidApp'
      cardData.value.logoUrl = data.logo_url || null
      logoPreview.value = data.logo_url || null
      
      // Charger les paramètres de carte si disponibles
      if (data.card_settings) {
        // S'assurer que les valeurs booléennes sont bien récupérées
        cardData.value.gradient = data.card_settings.gradient || cardData.value.gradient
        cardData.value.welcomeMessage = data.card_settings.welcomeMessage || cardData.value.welcomeMessage
        cardData.value.showPoints = data.card_settings.showPoints !== undefined ? data.card_settings.showPoints : true
        cardData.value.showQR = data.card_settings.showQR !== undefined ? data.card_settings.showQR : true
        cardData.value.showExpiry = data.card_settings.showExpiry !== undefined ? data.card_settings.showExpiry : true
      }
    }
  } catch (error) {
    console.error('Erreur lors du chargement des données:', error)
  } finally {
    loading.value = false
  }
}

// Gérer l'upload du fichier
const handleFileUpload = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (!file) return
  
  // Vérifier la taille du fichier (max 5MB)
  if (file.size > 5 * 1024 * 1024) {
    uploadError.value = 'Le fichier ne doit pas dépasser 5MB'
    return
  }
  
  // Vérifier le type de fichier
  if (!file.type.startsWith('image/')) {
    uploadError.value = 'Veuillez sélectionner une image'
    return
  }
  
  uploadError.value = null
  selectedFile.value = file
  
  // Créer un aperçu
  const reader = new FileReader()
  reader.onload = (e) => {
    logoPreview.value = e.target?.result as string
  }
  reader.readAsDataURL(file)
}

// Uploader le logo vers Supabase Storage
const uploadLogo = async (): Promise<string | null> => {
  if (!selectedFile.value) return null
  
  uploadingLogo.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('Utilisateur non connecté')
    
    // Générer un nom de fichier unique
    const fileExt = selectedFile.value.name.split('.').pop()
    const fileName = `${user.id}/card-logo-${Date.now()}.${fileExt}`
    
    // Uploader le fichier
    const { data, error } = await supabase.storage
      .from('company-logos')
      .upload(fileName, selectedFile.value, {
        upsert: true,
        cacheControl: '3600'
      })
    
    if (error) {
      console.error('Erreur upload:', error)
      uploadError.value = 'Erreur lors de l\'upload du logo'
      return null
    }
    
    // Récupérer l'URL publique
    const { data: { publicUrl } } = supabase.storage
      .from('company-logos')
      .getPublicUrl(fileName)
    
    return publicUrl
  } catch (error) {
    console.error('Erreur lors de l\'upload:', error)
    uploadError.value = 'Erreur lors de l\'upload du logo'
    return null
  } finally {
    uploadingLogo.value = false
  }
}

// Supprimer le logo
const removeLogo = () => {
  logoPreview.value = null
  selectedFile.value = null
  cardData.value.logoUrl = null
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

// Sauvegarder les modifications
const saveCardSettings = async () => {
  saving.value = true
  uploadError.value = null
  
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      uploadError.value = 'Vous devez être connecté'
      return
    }
    
    let logoUrl = cardData.value.logoUrl
    
    // Uploader le nouveau logo si nécessaire
    if (selectedFile.value) {
      const uploadedUrl = await uploadLogo()
      if (uploadedUrl) {
        logoUrl = uploadedUrl
      }
    }
    
    // Préparer les données de la carte
    const card_settings = {
      gradient: cardData.value.gradient,
      welcomeMessage: cardData.value.welcomeMessage,
      showPoints: cardData.value.showPoints,
      showQR: cardData.value.showQR,
      showExpiry: cardData.value.showExpiry
    }
    
    // Mettre à jour les données
    const { error } = await supabase
      .from('users')
      .update({
        company: cardData.value.companyName,
        logo_url: logoUrl,
        card_settings,
        updated_at: new Date().toISOString()
      })
      .eq('auth_id', user.id)
    
    if (error) {
      console.error('Erreur lors de la sauvegarde:', error)
      uploadError.value = 'Erreur lors de la sauvegarde'
    } else {
      // Recharger les données
      cardData.value.logoUrl = logoUrl
      selectedFile.value = null
      alert('Carte de fidélité mise à jour avec succès!')
    }
  } catch (error) {
    console.error('Erreur:', error)
    uploadError.value = 'Une erreur inattendue s\'est produite'
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  loadCardData()
})
</script>