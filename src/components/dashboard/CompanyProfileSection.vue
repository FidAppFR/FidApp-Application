<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-3xl font-black text-gray-900 dark:text-white">Profil de Société</h1>
      <p class="text-gray-600 dark:text-gray-400 mt-2">Gérez les informations de votre entreprise</p>
    </div>

    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
      <form @submit.prevent="saveCompanyProfile" class="space-y-6">
        <!-- Logo et infos de base -->
        <div class="flex items-start space-x-6">
          <div class="flex-shrink-0">
            <!-- Logo actuel ou placeholder -->
            <div class="relative group w-24 h-24">
              <div v-if="logoPreview || companyData.logo_url" 
                   class="w-24 h-24 rounded-2xl overflow-hidden border-2 border-gray-200">
                <img 
                  :src="(logoPreview || companyData.logo_url) ?? ''" 
                  alt="Logo entreprise"
                  class="w-full h-full object-cover"
                />
              </div>
              <div v-else 
                   class="w-24 h-24 bg-gradient-to-r from-violet-600 to-pink-600 rounded-2xl flex items-center justify-center text-white">
                <Building2 :size="40" />
              </div>
              
              <!-- Overlay au survol -->
              <div class="absolute inset-0 w-24 h-24 bg-black bg-opacity-50 rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-200 flex items-center justify-center pointer-events-none">
                <Camera :size="24" class="text-white" />
              </div>
            </div>
            
            <!-- Input file caché -->
            <input 
              ref="fileInput"
              type="file"
              accept="image/png, image/jpeg, image/jpg, image/webp"
              @change="handleFileUpload"
              class="hidden"
            />
            
            <!-- Bouton pour changer le logo -->
            <button 
              type="button" 
              @click="($refs.fileInput as HTMLInputElement)?.click()"
              class="mt-3 text-sm text-violet-600 hover:text-violet-700 font-medium flex items-center space-x-1"
            >
              <Upload :size="16" />
              <span>Changer le logo</span>
            </button>
            
            <!-- Bouton supprimer si logo existe -->
            <button 
              v-if="logoPreview || companyData.logo_url"
              type="button" 
              @click="removeLogo"
              class="mt-2 text-sm text-red-600 hover:text-red-700 font-medium flex items-center space-x-1"
            >
              <Trash2 :size="16" />
              <span>Supprimer</span>
            </button>
          </div>
          
          <div class="flex-1 grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Nom de l'entreprise
              </label>
              <input
                v-model="companyData.name"
                type="text"
                class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                placeholder="Nom de votre entreprise"
              />
            </div>
            
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Secteur d'activité
              </label>
              <select
                v-model="companyData.sector"
                class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
              >
                <option value="">Sélectionner un secteur</option>
                <option value="retail">Commerce de détail</option>
                <option value="restaurant">Restaurant / Café</option>
                <option value="services">Services</option>
                <option value="beauty">Beauté / Bien-être</option>
                <option value="fitness">Sport / Fitness</option>
                <option value="health">Santé</option>
                <option value="education">Éducation</option>
                <option value="other">Autre</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Message d'info sur le logo -->
        <div v-if="uploadingLogo" class="bg-violet-50 border border-violet-200 rounded-lg p-4 flex items-center space-x-3">
          <Loader2 :size="20" class="text-violet-600 animate-spin" />
          <span class="text-sm text-violet-700">Upload du logo en cours...</span>
        </div>

        <div v-if="uploadError" class="bg-red-50 border border-red-200 rounded-lg p-4 flex items-center space-x-3">
          <AlertCircle :size="20" class="text-red-600" />
          <span class="text-sm text-red-700">{{ uploadError }}</span>
        </div>

        <!-- Coordonnées -->
        <div>
          <h3 class="text-lg font-bold text-gray-900 mb-4">Coordonnées</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Adresse
              </label>
              <input
                v-model="companyData.address"
                type="text"
                class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                placeholder="123 rue Example"
              />
            </div>
            
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Ville
              </label>
              <input
                v-model="companyData.city"
                type="text"
                class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                placeholder="Paris"
              />
            </div>
            
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Code postal
              </label>
              <input
                v-model="companyData.postal_code"
                type="text"
                class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                placeholder="75001"
              />
            </div>
            
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Téléphone
              </label>
              <input
                v-model="companyData.phone"
                type="tel"
                class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                placeholder="+33 1 23 45 67 89"
              />
            </div>

            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Email professionnel
              </label>
              <input
                v-model="companyData.email"
                type="email"
                class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                placeholder="contact@entreprise.com"
              />
            </div>

            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Site web
              </label>
              <input
                v-model="companyData.website"
                type="url"
                class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
                placeholder="https://www.entreprise.com"
              />
            </div>
          </div>
        </div>

        <!-- Horaires -->
        <div>
          <h3 class="text-lg font-bold text-gray-900 mb-4">Horaires d'ouverture</h3>
          <div class="space-y-3">
            <div v-for="day in daysOrder" :key="day" class="flex items-center space-x-4">
              <span class="w-24 text-sm font-medium capitalize">{{ day }}</span>
              <input
                v-model="companyData.opening_hours[day].open"
                type="time"
                :disabled="companyData.opening_hours[day].closed"
                class="px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white disabled:bg-gray-50 dark:disabled:bg-gray-600 disabled:text-gray-400 dark:disabled:text-gray-500"
              />
              <span class="text-gray-500">à</span>
              <input
                v-model="companyData.opening_hours[day].close"
                type="time"
                :disabled="companyData.opening_hours[day].closed"
                class="px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white disabled:bg-gray-50 dark:disabled:bg-gray-600 disabled:text-gray-400 dark:disabled:text-gray-500"
              />
              <label class="flex items-center space-x-2 text-sm">
                <input 
                  v-model="companyData.opening_hours[day].closed" 
                  type="checkbox" 
                  class="rounded text-violet-600" 
                />
                <span>Fermé</span>
              </label>
            </div>
          </div>
        </div>

        <!-- Description -->
        <div>
          <label class="block text-sm font-semibold text-gray-700 mb-2">
            Description de l'entreprise
          </label>
          <textarea
            v-model="companyData.description"
            rows="4"
            class="w-full px-4 py-3 border-2 border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:border-violet-500 dark:focus:border-violet-400 transition-colors"
            placeholder="Décrivez votre entreprise et vos services..."
          ></textarea>
        </div>

        <!-- Bouton de sauvegarde -->
        <div class="flex justify-end space-x-4">
          <button
            type="button"
            @click="resetForm"
            class="px-6 py-3 bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold rounded-full transition-colors"
          >
            Annuler
          </button>
          <button
            type="submit"
            :disabled="saving"
            class="bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold px-8 py-3 rounded-full hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:hover:scale-100 flex items-center space-x-2"
          >
            <Loader2 v-if="saving" :size="20" class="animate-spin" />
            <span>{{ saving ? 'Enregistrement...' : 'Enregistrer les modifications' }}</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Building2, Upload, Camera, Trash2, Loader2, AlertCircle } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

interface CompanyData {
  name: string
  sector: string
  address: string
  city: string
  postal_code: string
  phone: string
  email: string
  website: string
  description: string
  logo_url: string | null
  opening_hours: {
    [key: string]: {
      open: string
      close: string
      closed: boolean
    }
  }
}

const daysOrder = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche']

const companyData = ref<CompanyData>({
  name: '',
  sector: '',
  address: '',
  city: '',
  postal_code: '',
  phone: '',
  email: '',
  website: '',
  description: '',
  logo_url: null,
  opening_hours: {
    lundi: { open: '09:00', close: '19:00', closed: false },
    mardi: { open: '09:00', close: '19:00', closed: false },
    mercredi: { open: '09:00', close: '19:00', closed: false },
    jeudi: { open: '09:00', close: '19:00', closed: false },
    vendredi: { open: '09:00', close: '19:00', closed: false },
    samedi: { open: '09:00', close: '19:00', closed: false },
    dimanche: { open: '09:00', close: '19:00', closed: true }
  }
})

const fileInput = ref<HTMLInputElement>()
const logoPreview = ref<string | null>(null)
const uploadingLogo = ref(false)
const uploadError = ref<string | null>(null)
const saving = ref(false)
const selectedFile = ref<File | null>(null)

// Charger les données de l'entreprise
const loadCompanyData = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('auth_id', user.id)
      .single()

    if (!error && data) {
      // Fusionner les données existantes
      companyData.value = {
        ...companyData.value,
        name: data.company || '',
        address: data.address || '',
        city: data.city || '',
        postal_code: data.postal_code || '',
        phone: data.phone || '',
        email: data.email || '',
        website: data.website || '',
        description: data.description || '',
        logo_url: data.logo_url || null,
        sector: data.sector || '',
        opening_hours: data.opening_hours || companyData.value.opening_hours
      }
    }
  } catch (error) {
    console.error('Erreur lors du chargement des données:', error)
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
    const fileName = `${user.id}/logo-${Date.now()}.${fileExt}`
    
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
  companyData.value.logo_url = null
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

// Sauvegarder le profil
const saveCompanyProfile = async () => {
  saving.value = true
  uploadError.value = null
  
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      uploadError.value = 'Vous devez être connecté'
      return
    }
    
    let logoUrl = companyData.value.logo_url
    
    // Uploader le nouveau logo si nécessaire
    if (selectedFile.value) {
      const uploadedUrl = await uploadLogo()
      if (uploadedUrl) {
        logoUrl = uploadedUrl
      }
    }
    
    // Préparer les données de mise à jour (seulement les colonnes existantes)
    const updateData: any = {
        company: companyData.value.name,
        updated_at: new Date().toISOString()
    }
    
    // Ajouter les colonnes optionnelles si elles existent dans votre table
    // Commentez celles qui n'existent pas encore dans votre base
    if (companyData.value.address) updateData.address = companyData.value.address
    if (companyData.value.city) updateData.city = companyData.value.city
    if (companyData.value.postal_code) updateData.postal_code = companyData.value.postal_code
    if (companyData.value.phone) updateData.phone = companyData.value.phone
    if (companyData.value.sector) updateData.sector = companyData.value.sector
    if (companyData.value.website) updateData.website = companyData.value.website
    if (companyData.value.description) updateData.description = companyData.value.description
    if (logoUrl) updateData.logo_url = logoUrl
    if (companyData.value.opening_hours) updateData.opening_hours = companyData.value.opening_hours
    
    console.log('Données à mettre à jour:', updateData)
    
    // Mettre à jour les données
    const { data, error } = await supabase
      .from('users')
      .update(updateData)
      .eq('auth_id', user.id)
      .select()
    
    if (error) {
      console.error('Erreur détaillée lors de la sauvegarde:', error)
      console.error('Message:', error.message)
      console.error('Details:', error.details)
      console.error('Hint:', error.hint)
      uploadError.value = `Erreur: ${error.message || 'Erreur lors de la sauvegarde'}`
    } else {
      console.log('Mise à jour réussie:', data)
      // Recharger les données
      await loadCompanyData()
      selectedFile.value = null
      logoPreview.value = null
      alert('Profil de société mis à jour avec succès!')
    }
  } catch (error) {
    console.error('Erreur:', error)
    uploadError.value = 'Une erreur inattendue s\'est produite'
  } finally {
    saving.value = false
  }
}

// Réinitialiser le formulaire
const resetForm = () => {
  loadCompanyData()
  logoPreview.value = null
  selectedFile.value = null
  uploadError.value = null
}

onMounted(() => {
  loadCompanyData()
})
</script>