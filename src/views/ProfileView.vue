<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50">
    <!-- Écran de chargement -->
    <Transition
      enter-active-class="duration-0"
      enter-from-class=""
      enter-to-class=""
      leave-active-class="transition-opacity duration-300"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div v-if="isLoading" class="fixed inset-0 bg-white z-[999999] flex items-center justify-center" style="position: fixed !important; top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important; width: 100vw !important; height: 100vh !important;">
        <div class="flex flex-col items-center space-y-4">
          <div class="relative">
            <div class="absolute inset-0 bg-gradient-to-r from-violet-600 to-pink-600 rounded-full blur-xl opacity-30 animate-pulse"></div>
            <div class="relative bg-white rounded-2xl p-6 shadow-xl">
              <Loader2 :size="48" class="text-violet-600 animate-spin" />
            </div>
          </div>
          <p class="text-lg font-semibold text-gray-700">Chargement du profil...</p>
          <div class="w-48 h-1 bg-gray-200 rounded-full overflow-hidden">
            <div class="h-full bg-gradient-to-r from-violet-600 to-pink-600 rounded-full animate-[loading_0.8s_ease-in-out_infinite]"></div>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Navbar -->
    <KarmaNavbar />

    <!-- Contenu principal -->
    <div class="container mx-auto px-4 py-8 max-w-4xl">
      <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
        <!-- Header du profil -->
        <div class="bg-gradient-to-r from-violet-600 to-pink-600 p-8 text-white">
          <div class="flex items-center space-x-6">
            <div class="w-24 h-24 bg-white/20 backdrop-blur rounded-full flex items-center justify-center">
              <User :size="48" class="text-white" />
            </div>
            <div>
              <h1 class="text-3xl font-black mb-2">Mon Profil</h1>
              <p class="text-white/80">Gérez vos informations personnelles</p>
            </div>
          </div>
        </div>

        <!-- Corps du profil -->
        <div class="p-8">
          <!-- Messages de succès/erreur -->
          <Transition
            enter-active-class="transition-all duration-300"
            enter-from-class="opacity-0 -translate-y-2"
            enter-to-class="opacity-100 translate-y-0"
            leave-active-class="transition-all duration-200"
            leave-from-class="opacity-100"
            leave-to-class="opacity-0"
          >
            <div v-if="successMessage" class="mb-6 p-4 bg-green-50 border border-green-200 rounded-xl">
              <div class="flex items-center space-x-2 text-green-700">
                <CheckCircle :size="20" />
                <span class="font-medium">{{ successMessage }}</span>
              </div>
            </div>
          </Transition>

          <Transition
            enter-active-class="transition-all duration-300"
            enter-from-class="opacity-0 -translate-y-2"
            enter-to-class="opacity-100 translate-y-0"
            leave-active-class="transition-all duration-200"
            leave-from-class="opacity-100"
            leave-to-class="opacity-0"
          >
            <div v-if="errorMessage" class="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl">
              <div class="flex items-center space-x-2 text-red-700">
                <AlertCircle :size="20" />
                <span class="font-medium">{{ errorMessage }}</span>
              </div>
            </div>
          </Transition>

          <!-- Sections du profil -->
          <div class="space-y-8">
            <!-- Informations personnelles -->
            <section>
              <h2 class="text-xl font-bold text-gray-900 mb-4 flex items-center space-x-2">
                <UserCheck :size="24" class="text-violet-600" />
                <span>Informations personnelles</span>
              </h2>
              
              <div class="grid md:grid-cols-2 gap-6">
                <!-- Prénom -->
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">
                    Prénom
                  </label>
                  <input
                    v-model="profileData.firstName"
                    type="text"
                    class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                    placeholder="Votre prénom"
                  />
                </div>

                <!-- Nom -->
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">
                    Nom
                  </label>
                  <input
                    v-model="profileData.lastName"
                    type="text"
                    class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                    placeholder="Votre nom"
                  />
                </div>

                <!-- Email (non modifiable) -->
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">
                    Email
                  </label>
                  <div class="relative">
                    <input
                      :value="profileData.email"
                      type="email"
                      disabled
                      class="w-full px-4 py-3 pl-11 border-2 border-gray-200 rounded-xl bg-gray-50 text-gray-600 cursor-not-allowed"
                    />
                    <Mail :size="20" class="absolute left-3.5 top-3.5 text-gray-400" />
                    <Lock :size="16" class="absolute right-3.5 top-4 text-gray-400" />
                  </div>
                  <p class="text-xs text-gray-500 mt-1">L'email ne peut pas être modifié</p>
                </div>

                <!-- Entreprise (non modifiable) -->
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">
                    Entreprise
                  </label>
                  <div class="relative">
                    <input
                      :value="profileData.company"
                      type="text"
                      disabled
                      class="w-full px-4 py-3 pl-11 border-2 border-gray-200 rounded-xl bg-gray-50 text-gray-600 cursor-not-allowed"
                    />
                    <Building2 :size="20" class="absolute left-3.5 top-3.5 text-gray-400" />
                    <Lock :size="16" class="absolute right-3.5 top-4 text-gray-400" />
                  </div>
                  <p class="text-xs text-gray-500 mt-1">Le nom de l'entreprise ne peut pas être modifié</p>
                </div>

                <!-- Téléphone -->
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">
                    Téléphone
                  </label>
                  <div class="relative">
                    <input
                      v-model="profileData.phone"
                      type="tel"
                      class="w-full px-4 py-3 pl-11 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                      placeholder="+33 6 12 34 56 78"
                    />
                    <Phone :size="20" class="absolute left-3.5 top-3.5 text-gray-400" />
                  </div>
                </div>

                <!-- Date de naissance -->
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">
                    Date de naissance
                  </label>
                  <div class="relative">
                    <input
                      v-model="profileData.birthDate"
                      type="date"
                      class="w-full px-4 py-3 pl-11 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                    />
                    <Calendar :size="20" class="absolute left-3.5 top-3.5 text-gray-400" />
                  </div>
                </div>
              </div>
            </section>

            <!-- Préférences -->
            <section>
              <h2 class="text-xl font-bold text-gray-900 mb-4 flex items-center space-x-2">
                <Settings :size="24" class="text-violet-600" />
                <span>Préférences</span>
              </h2>
              
              <div class="space-y-4">
                <!-- Consentement marketing -->
                <div class="p-4 bg-gray-50 rounded-xl">
                  <label class="flex items-start space-x-3 cursor-pointer">
                    <input
                      v-model="profileData.acceptNewsletter"
                      type="checkbox"
                      class="w-5 h-5 mt-0.5 text-violet-600 border-2 border-gray-300 rounded focus:ring-violet-500 focus:ring-2"
                    />
                    <div>
                      <span class="text-sm font-semibold text-gray-700">
                        Recevoir les communications marketing
                      </span>
                      <p class="text-xs text-gray-500 mt-1">
                        J'accepte de recevoir des emails promotionnels, des nouveautés et des offres spéciales
                      </p>
                    </div>
                  </label>
                </div>

                <!-- Langue -->
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">
                    Langue préférée
                  </label>
                  <div class="relative">
                    <select
                      v-model="profileData.language"
                      class="w-full px-4 py-3 pl-11 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors appearance-none"
                    >
                      <option value="FR">🇫🇷 Français</option>
                      <option value="EN">🇬🇧 English</option>
                    </select>
                    <Globe :size="20" class="absolute left-3.5 top-3.5 text-gray-400" />
                    <ChevronDown :size="20" class="absolute right-3.5 top-3.5 text-gray-400 pointer-events-none" />
                  </div>
                </div>
              </div>
            </section>

            <!-- Sécurité -->
            <section>
              <h2 class="text-xl font-bold text-gray-900 mb-4 flex items-center space-x-2">
                <Shield :size="24" class="text-violet-600" />
                <span>Sécurité</span>
              </h2>
              
              <div class="space-y-4">
                <!-- Changement de mot de passe -->
                <div v-if="!showPasswordChange">
                  <button
                    @click="showPasswordChange = true"
                    class="w-full md:w-auto px-6 py-3 bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold rounded-xl transition-colors flex items-center justify-center space-x-2"
                  >
                    <Key :size="20" />
                    <span>Changer le mot de passe</span>
                  </button>
                </div>

                <!-- Formulaire de changement de mot de passe -->
                <Transition
                  enter-active-class="transition-all duration-300"
                  enter-from-class="opacity-0 -translate-y-2"
                  enter-to-class="opacity-100 translate-y-0"
                  leave-active-class="transition-all duration-200"
                  leave-from-class="opacity-100"
                  leave-to-class="opacity-0 -translate-y-2"
                >
                  <div v-if="showPasswordChange" class="p-6 bg-violet-50 rounded-xl space-y-4">
                    <h3 class="font-semibold text-gray-900 mb-4">Changer votre mot de passe</h3>
                    
                    <!-- Mot de passe actuel -->
                    <div>
                      <label class="block text-sm font-semibold text-gray-700 mb-2">
                        Mot de passe actuel
                      </label>
                      <div class="relative">
                        <input
                          v-model="passwordData.currentPassword"
                          :type="showCurrentPassword ? 'text' : 'password'"
                          class="w-full px-4 py-3 pl-11 pr-12 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                          placeholder="••••••••"
                        />
                        <Lock :size="20" class="absolute left-3.5 top-3.5 text-gray-400" />
                        <button
                          type="button"
                          @click="showCurrentPassword = !showCurrentPassword"
                          class="absolute right-3 top-3 text-gray-400 hover:text-gray-600 transition-colors"
                        >
                          <Eye v-if="!showCurrentPassword" :size="20" />
                          <EyeOff v-else :size="20" />
                        </button>
                      </div>
                    </div>

                    <!-- Nouveau mot de passe -->
                    <div>
                      <label class="block text-sm font-semibold text-gray-700 mb-2">
                        Nouveau mot de passe
                      </label>
                      <div class="relative">
                        <input
                          v-model="passwordData.newPassword"
                          :type="showNewPassword ? 'text' : 'password'"
                          class="w-full px-4 py-3 pl-11 pr-12 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                          placeholder="••••••••"
                        />
                        <Lock :size="20" class="absolute left-3.5 top-3.5 text-gray-400" />
                        <button
                          type="button"
                          @click="showNewPassword = !showNewPassword"
                          class="absolute right-3 top-3 text-gray-400 hover:text-gray-600 transition-colors"
                        >
                          <Eye v-if="!showNewPassword" :size="20" />
                          <EyeOff v-else :size="20" />
                        </button>
                      </div>
                    </div>

                    <!-- Confirmer nouveau mot de passe -->
                    <div>
                      <label class="block text-sm font-semibold text-gray-700 mb-2">
                        Confirmer le nouveau mot de passe
                      </label>
                      <div class="relative">
                        <input
                          v-model="passwordData.confirmPassword"
                          :type="showConfirmPassword ? 'text' : 'password'"
                          class="w-full px-4 py-3 pl-11 pr-12 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-violet-500 transition-colors"
                          placeholder="••••••••"
                        />
                        <Lock :size="20" class="absolute left-3.5 top-3.5 text-gray-400" />
                        <button
                          type="button"
                          @click="showConfirmPassword = !showConfirmPassword"
                          class="absolute right-3 top-3 text-gray-400 hover:text-gray-600 transition-colors"
                        >
                          <Eye v-if="!showConfirmPassword" :size="20" />
                          <EyeOff v-else :size="20" />
                        </button>
                      </div>
                    </div>

                    <!-- Boutons d'action -->
                    <div class="flex space-x-3">
                      <button
                        @click="updatePassword"
                        :disabled="isUpdatingPassword"
                        class="px-6 py-3 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-semibold rounded-xl hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        <span v-if="!isUpdatingPassword">Mettre à jour</span>
                        <span v-else class="flex items-center space-x-2">
                          <Loader2 :size="18" class="animate-spin" />
                          <span>Mise à jour...</span>
                        </span>
                      </button>
                      <button
                        @click="cancelPasswordChange"
                        class="px-6 py-3 bg-gray-200 hover:bg-gray-300 text-gray-700 font-semibold rounded-xl transition-colors"
                      >
                        Annuler
                      </button>
                    </div>
                  </div>
                </Transition>
              </div>
            </section>

            <!-- Boutons d'action principaux -->
            <div class="flex justify-between items-center pt-6 border-t border-gray-200">
              <div class="text-sm text-gray-500">
                Membre depuis {{ formatDate(profileData.createdAt) }}
              </div>
              
              <div class="flex space-x-3">
                <button
                  @click="saveProfile"
                  :disabled="isSaving"
                  class="px-8 py-3 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold rounded-full hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:cursor-not-allowed flex items-center space-x-2"
                >
                  <Save v-if="!isSaving" :size="20" />
                  <Loader2 v-else :size="20" class="animate-spin" />
                  <span>{{ isSaving ? 'Enregistrement...' : 'Enregistrer les modifications' }}</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { 
  User, UserCheck, Mail, Phone, Building2, Calendar, Lock, Key, Shield, 
  Settings, Globe, ChevronDown, Eye, EyeOff, Save, CheckCircle, 
  AlertCircle, Loader2
} from 'lucide-vue-next'
import KarmaNavbar from '@/components/layout/KarmaNavbar.vue'
import { supabase } from '@/services/supabase'

const router = useRouter()

// État du profil
const profileData = ref({
  id: '',
  email: '',
  company: '',
  firstName: '',
  lastName: '',
  phone: '',
  birthDate: '',
  acceptNewsletter: false,
  language: 'FR',
  createdAt: ''
})

// État du changement de mot de passe
const passwordData = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// État de l'interface
const isLoading = ref(true)
const showPasswordChange = ref(false)
const showCurrentPassword = ref(false)
const showNewPassword = ref(false)
const showConfirmPassword = ref(false)
const isSaving = ref(false)
const isUpdatingPassword = ref(false)
const successMessage = ref('')
const errorMessage = ref('')

// Charger les données du profil
const loadProfile = async () => {
  isLoading.value = true
  
  try {
    // Petit délai pour montrer le chargement
    await new Promise(resolve => setTimeout(resolve, 600))
    
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      console.log('Pas d\'utilisateur connecté')
      router.push('/login')
      return
    }

    console.log('Utilisateur Auth connecté:', user.id, user.email)

    // Essayer de récupérer directement depuis la table users
    console.log('Récupération du profil pour:', user.id)
    
    let { data: userData, error } = await supabase
      .from('users')
      .select('*')
      .eq('auth_id', user.id)
      .single()

    if (error && error.code === 'PGRST116') {
      // L'enregistrement n'existe pas, le créer
      console.log('Profil non trouvé, création...')
      console.log('Metadata utilisateur:', user.user_metadata)
      
      // Générer un QR code unique
      const generateQRCode = () => {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
        let result = 'QR'
        for (let i = 0; i < 8; i++) {
          result += chars.charAt(Math.floor(Math.random() * chars.length))
        }
        return result
      }
      
      const newUserData = {
        auth_id: user.id,
        email: user.email,
        company: user.user_metadata?.company || 'Mon Entreprise',
        first_name: user.user_metadata?.first_name || '',
        last_name: user.user_metadata?.last_name || '',
        accept_newsletter: user.user_metadata?.accept_newsletter || false,
        accept_terms: user.user_metadata?.accept_terms !== false, // Default true
        qr_code_id: generateQRCode(),
        language: 'FR',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
      
      // Ajouter selected_plan seulement si la métadonnée existe
      if (user.user_metadata?.selected_plan) {
        (newUserData as any).selected_plan = user.user_metadata.selected_plan
      }
      
      console.log('Données à insérer:', newUserData)
      
      const { data: newUser, error: insertError } = await supabase
        .from('users')
        .insert(newUserData)
        .select()
        .single()
      
      if (insertError) {
        console.error('Erreur lors de la création du profil:', insertError)
        
        // Si c'est une erreur de contrainte unique sur auth_id, essayer de récupérer
        if (insertError.code === '23505' && insertError.message.includes('auth_id')) {
          console.log('Le profil existe déjà, tentative de récupération...')
          const { data: existingUser, error: fetchError } = await supabase
            .from('users')
            .select('*')
            .eq('auth_id', user.id)
            .single()
          
          if (existingUser) {
            userData = existingUser
            console.log('Profil existant récupéré:', existingUser)
          } else {
            console.error('Impossible de récupérer le profil existant:', fetchError)
            errorMessage.value = 'Erreur lors du chargement du profil. Veuillez rafraîchir la page.'
          }
        } else {
          errorMessage.value = `Erreur: ${insertError.message}`
        }
      } else if (newUser) {
        userData = newUser
        console.log('Nouveau profil créé:', newUser)
        successMessage.value = 'Profil créé avec succès!'
        setTimeout(() => { successMessage.value = '' }, 3000)
      }
    } else if (error) {
      console.error('Erreur lors de la récupération du profil:', error)
      errorMessage.value = 'Erreur lors du chargement du profil'
    }
    
    if (userData) {
      console.log('Données utilisateur récupérées:', userData)
      profileData.value = {
        id: userData.id,
        email: userData.email,
        company: userData.company,
        firstName: userData.first_name || '',
        lastName: userData.last_name || '',
        phone: userData.phone || '',
        birthDate: userData.birth_date || '',
        acceptNewsletter: userData.accept_newsletter || false,
        language: userData.language || 'FR',
        createdAt: userData.created_at
      }
      
      // Vérifier si on a récupéré une date de naissance
      if (userData.birth_date) {
        console.log('Date de naissance trouvée:', userData.birth_date);
      }
    }
  } catch (error) {
    console.error('Erreur lors du chargement du profil:', error)
    errorMessage.value = 'Impossible de charger votre profil'
  } finally {
    isLoading.value = false
  }
}

// Sauvegarder le profil
const saveProfile = async () => {
  isSaving.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    // Préparer les données de base à mettre à jour
    const updateData: any = {
      first_name: profileData.value.firstName,
      last_name: profileData.value.lastName,
      phone: profileData.value.phone,
      accept_newsletter: profileData.value.acceptNewsletter,
      language: profileData.value.language,
      updated_at: new Date().toISOString()
    }

    // Essayer d'abord sans birth_date
    let { error } = await supabase
      .from('users')
      .update(updateData)
      .eq('id', profileData.value.id)

    // Si pas d'erreur et qu'on a une date de naissance, essayer de l'ajouter
    if (!error && profileData.value.birthDate) {
      const { error: birthDateError } = await supabase
        .from('users')
        .update({ birth_date: profileData.value.birthDate })
        .eq('id', profileData.value.id)
      
      // Ignorer l'erreur si c'est juste la colonne qui n'existe pas
      if (birthDateError && !birthDateError.message.includes('birth_date')) {
        error = birthDateError
      }
    }

    if (error) throw error

    successMessage.value = 'Vos informations ont été mises à jour avec succès'
    
    // Logger l'activité
    await supabase.from('activity_logs').insert({
      user_id: profileData.value.id,
      action: 'PROFILE_UPDATED',
      description: 'Profil mis à jour'
    })
    
    // Faire disparaître le message après 3 secondes
    setTimeout(() => {
      successMessage.value = ''
    }, 3000)
  } catch (error: any) {
    console.error('Erreur lors de la sauvegarde:', error)
    
    // Message d'erreur plus clair selon le type d'erreur
    if (error.message?.includes('birth_date')) {
      errorMessage.value = 'La date de naissance ne peut pas être enregistrée pour le moment. Les autres informations ont été sauvegardées.'
    } else {
      errorMessage.value = error.message || 'Une erreur est survenue lors de la sauvegarde'
    }
  } finally {
    isSaving.value = false
  }
}

// Mettre à jour le mot de passe
const updatePassword = async () => {
  errorMessage.value = ''
  successMessage.value = ''

  // Validation
  if (!passwordData.value.currentPassword || !passwordData.value.newPassword) {
    errorMessage.value = 'Veuillez remplir tous les champs'
    return
  }

  if (passwordData.value.newPassword !== passwordData.value.confirmPassword) {
    errorMessage.value = 'Les nouveaux mots de passe ne correspondent pas'
    return
  }

  if (passwordData.value.newPassword.length < 8) {
    errorMessage.value = 'Le nouveau mot de passe doit contenir au moins 8 caractères'
    return
  }

  isUpdatingPassword.value = true

  try {
    const { error } = await supabase.auth.updateUser({
      password: passwordData.value.newPassword
    })

    if (error) throw error

    successMessage.value = 'Votre mot de passe a été mis à jour avec succès'
    showPasswordChange.value = false
    
    // Réinitialiser le formulaire
    passwordData.value = {
      currentPassword: '',
      newPassword: '',
      confirmPassword: ''
    }
    
    // Faire disparaître le message après 3 secondes
    setTimeout(() => {
      successMessage.value = ''
    }, 3000)
  } catch (error: any) {
    console.error('Erreur lors de la mise à jour du mot de passe:', error)
    errorMessage.value = error.message || 'Une erreur est survenue lors de la mise à jour du mot de passe'
  } finally {
    isUpdatingPassword.value = false
  }
}

// Annuler le changement de mot de passe
const cancelPasswordChange = () => {
  showPasswordChange.value = false
  passwordData.value = {
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  }
}

// Formater la date
const formatDate = (dateString: string) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('fr-FR', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  })
}

// Charger le profil au montage
onMounted(() => {
  loadProfile()
})
</script>