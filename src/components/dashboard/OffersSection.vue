<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-3xl font-black text-gray-900 dark:text-white">Offres & Récompenses</h1>
      <p class="text-gray-600 dark:text-gray-400 mt-2">Créez des offres spéciales et gérez vos récompenses</p>
    </div>

    <!-- Bouton d'ajout -->
    <div class="flex justify-end">
      <button
        @click="showAddOffer = true"
        class="px-4 py-2 bg-gradient-to-r from-violet-600 to-purple-600 text-white rounded-lg hover:shadow-lg transition-all duration-200 flex items-center gap-2"
      >
        <Plus :size="20" />
        Créer une offre
      </button>
    </div>

    <!-- Filtres et tri -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
      <div class="flex flex-col md:flex-row gap-4">
        <div class="flex-1">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Rechercher une offre..."
            class="w-full px-4 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
          />
        </div>
        <select
          v-model="filterStatus"
          class="px-4 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
        >
          <option value="all">Toutes les offres</option>
          <option value="active">Actives</option>
          <option value="draft">Brouillons</option>
          <option value="expired">Expirées</option>
        </select>
        <select
          v-model="filterType"
          class="px-4 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
        >
          <option value="all">Tous types</option>
          <option value="discount">Réduction</option>
          <option value="gift">Cadeau</option>
          <option value="points">Points bonus</option>
          <option value="upgrade">Surclassement</option>
        </select>
      </div>
    </div>

    <!-- Liste des offres -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="offer in filteredOffers"
        :key="offer.id"
        class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden hover:shadow-lg transition-shadow"
      >
        <!-- En-tête de l'offre -->
        <div class="relative h-32 bg-gradient-to-br from-violet-500 to-purple-600 p-4">
          <div class="absolute top-3 right-3">
            <button
              @click="toggleOffer(offer)"
              :class="[
                'px-2 py-1 rounded text-xs font-medium',
                offer.is_active 
                  ? 'bg-green-100 text-green-700' 
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300'
              ]"
            >
              {{ offer.is_active ? 'Active' : 'Inactive' }}
            </button>
          </div>
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 bg-white dark:bg-gray-800/20 backdrop-blur rounded-xl flex items-center justify-center overflow-hidden">
              <img 
                v-if="offer.image_url" 
                :src="offer.image_url" 
                alt="Icon" 
                class="w-full h-full object-cover"
              />
              <component v-else :is="getOfferIcon(offer.type)" :size="24" class="text-white" />
            </div>
            <div>
              <span class="text-white/80 text-xs uppercase tracking-wider">{{ getOfferTypeLabel(offer.type) }}</span>
              <h3 class="text-white font-bold text-lg">{{ offer.name }}</h3>
            </div>
          </div>
        </div>

        <!-- Corps de l'offre -->
        <div class="p-4 space-y-3">
          <p class="text-gray-600 dark:text-gray-400 text-sm line-clamp-2">{{ offer.description }}</p>
          
          <!-- Valeur de l'offre -->
          <div class="flex items-center justify-between">
            <span class="text-sm text-gray-500 dark:text-gray-400">Valeur</span>
            <div class="flex items-center gap-1">
              <template v-if="offer.type === 'points'">
                <Star :size="16" class="text-amber-500" />
                <span class="font-bold">{{ offer.value }} pts</span>
              </template>
              <template v-else-if="offer.type === 'discount'">
                <span class="font-bold text-green-600">-{{ offer.value }}%</span>
              </template>
              <template v-else>
                <span class="font-bold">{{ offer.value_text }}</span>
              </template>
            </div>
          </div>

          <!-- Points requis -->
          <div class="flex items-center justify-between">
            <span class="text-sm text-gray-500 dark:text-gray-400">Coût en points</span>
            <div class="flex items-center gap-1">
              <Star :size="16" class="text-violet-500" />
              <span class="font-bold text-violet-600">{{ offer.points_cost }}</span>
            </div>
          </div>

          <!-- Validité -->
          <div v-if="offer.start_date || offer.end_date" class="flex items-center justify-between">
            <span class="text-sm text-gray-500 dark:text-gray-400">Validité</span>
            <span class="text-sm font-medium">
              {{ formatDateRange(offer.start_date, offer.end_date) }}
            </span>
          </div>

          <!-- Utilisation -->
          <div class="flex items-center justify-between">
            <span class="text-sm text-gray-500 dark:text-gray-400">Utilisations</span>
            <span class="text-sm font-medium">
              {{ offer.total_uses }} / {{ offer.max_uses || '∞' }}
            </span>
          </div>

          <!-- Actions -->
          <div class="pt-3 flex gap-2 border-t border-gray-100">
            <button
              @click="editOffer(offer)"
              class="flex-1 px-3 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg text-sm hover:bg-gray-200 transition-colors"
            >
              Modifier
            </button>
            <button
              @click="duplicateOffer(offer)"
              class="flex-1 px-3 py-2 bg-violet-50 text-violet-600 rounded-lg text-sm hover:bg-violet-100 transition-colors"
            >
              Dupliquer
            </button>
            <button
              @click="deleteOffer(offer)"
              class="px-3 py-2 bg-red-50 text-red-600 rounded-lg text-sm hover:bg-red-100 transition-colors"
            >
              <Trash2 :size="16" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Message si aucune offre -->
    <div v-if="filteredOffers.length === 0" class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-12 text-center">
      <Gift :size="48" class="mx-auto mb-4 text-gray-300" />
      <p class="text-gray-500 dark:text-gray-400">Aucune offre trouvée</p>
      <button
        @click="showAddOffer = true"
        class="mt-4 px-4 py-2 bg-violet-600 text-white rounded-lg hover:bg-violet-700 transition-colors"
      >
        Créer votre première offre
      </button>
    </div>

    <!-- Modal pour créer/éditer une offre -->
    <Modal 
      :model-value="showAddOffer || !!editingOffer" 
      @update:model-value="closeOfferModal"
      size="lg"
    >
        <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-6">
          {{ editingOffer ? 'Modifier l\'offre' : 'Créer une nouvelle offre' }}
        </h3>

        <div class="space-y-4">
          <!-- Type d'offre -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Type d'offre</label>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-2">
              <button
                v-for="type in offerTypes"
                :key="type.value"
                @click="offerForm.type = type.value"
                :class="[
                  'p-3 rounded-lg border-2 transition-all',
                  offerForm.type === type.value
                    ? 'border-violet-600 bg-violet-50'
                    : 'border-gray-200 dark:border-gray-700 hover:border-gray-300'
                ]"
              >
                <component :is="type.icon" :size="24" class="mx-auto mb-1" :class="offerForm.type === type.value ? 'text-violet-600' : 'text-gray-400'" />
                <span class="text-xs" :class="offerForm.type === type.value ? 'text-violet-600 font-medium' : 'text-gray-600 dark:text-gray-400'">
                  {{ type.label }}
                </span>
              </button>
            </div>
          </div>

          <!-- Nom de l'offre -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Nom de l'offre</label>
            <input
              v-model="offerForm.name"
              type="text"
              class="w-full px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
              placeholder="Ex: Café offert, -20% sur votre commande..."
            />
          </div>

          <!-- Description -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Description</label>
            <textarea
              v-model="offerForm.description"
              rows="3"
              class="w-full px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
              placeholder="Décrivez votre offre en détail..."
            ></textarea>
          </div>

          <!-- Image de l'offre -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Image de l'offre (optionnel)</label>
            <div class="flex items-center gap-4">
              <!-- Preview de l'image -->
              <div class="w-24 h-24 border-2 border-dashed border-gray-300 rounded-lg flex items-center justify-center overflow-hidden bg-gray-50">
                <img 
                  v-if="imagePreview || offerForm.image_url" 
                  :src="imagePreview || offerForm.image_url" 
                  alt="Aperçu" 
                  class="w-full h-full object-cover"
                />
                <Image v-else :size="32" class="text-gray-400" />
              </div>
              
              <!-- Boutons d'upload et suppression -->
              <div class="flex-1">
                <input
                  ref="imageInput"
                  type="file"
                  accept="image/jpeg,image/jpg,image/png,image/webp,image/svg+xml"
                  @change="handleImageSelect"
                  class="hidden"
                />
                <button
                  type="button"
                  @click="$refs.imageInput.click()"
                  class="px-4 py-2 bg-violet-100 text-violet-600 rounded-lg hover:bg-violet-200 transition-colors text-sm"
                >
                  <Upload :size="16" class="inline mr-2" />
                  Choisir une image
                </button>
                <button
                  v-if="imagePreview || offerForm.image_url"
                  type="button"
                  @click="removeImage"
                  class="ml-2 px-4 py-2 bg-red-100 text-red-600 rounded-lg hover:bg-red-200 transition-colors text-sm"
                >
                  <X :size="16" class="inline mr-2" />
                  Supprimer
                </button>
                <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">JPG, PNG, WebP ou SVG. Max 5MB.</p>
              </div>
            </div>
          </div>

          <!-- Valeur selon le type -->
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                {{ getValueLabel(offerForm.type) }}
              </label>
              <input
                v-if="offerForm.type === 'discount' || offerForm.type === 'points'"
                v-model.number="offerForm.value"
                type="number"
                min="0"
                class="w-full px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
              />
              <input
                v-else
                v-model="offerForm.value_text"
                type="text"
                class="w-full px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
                placeholder="Ex: 1 produit offert"
              />
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Coût en points</label>
              <input
                v-model.number="offerForm.points_cost"
                type="number"
                min="0"
                class="w-full px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
              />
            </div>
          </div>

          <!-- Conditions -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Conditions d'utilisation</label>
            <textarea
              v-model="offerForm.conditions"
              rows="2"
              class="w-full px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
              placeholder="Ex: Valable sur présentation en caisse, non cumulable..."
            ></textarea>
          </div>

          <!-- Période de validité -->
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date de début</label>
              <input
                v-model="offerForm.start_date"
                type="date"
                class="w-full px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date de fin</label>
              <input
                v-model="offerForm.end_date"
                type="date"
                class="w-full px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
              />
            </div>
          </div>

          <!-- Limites -->
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Nombre d'utilisations max</label>
              <input
                v-model.number="offerForm.max_uses"
                type="number"
                min="0"
                class="w-full px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
                placeholder="Laisser vide pour illimité"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Max par client</label>
              <input
                v-model.number="offerForm.max_uses_per_customer"
                type="number"
                min="0"
                class="w-full px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-600"
                placeholder="Laisser vide pour illimité"
              />
            </div>
          </div>

          <!-- Activation -->
          <div>
            <label class="flex items-center space-x-2">
              <input
                v-model="offerForm.is_active"
                type="checkbox"
                class="rounded text-violet-600 focus:ring-violet-600"
              />
              <span class="text-sm text-gray-700 dark:text-gray-300">Activer immédiatement</span>
            </label>
          </div>
        </div>

        <!-- Boutons -->
        <div class="flex gap-3 mt-6">
          <button
            @click="saveOffer"
            :disabled="savingOffer"
            class="flex-1 bg-gradient-to-r from-violet-600 to-purple-600 text-white py-2 rounded-lg hover:shadow-lg transition-all duration-200 disabled:opacity-50"
          >
            {{ savingOffer ? 'Enregistrement...' : 'Enregistrer' }}
          </button>
          <button
            @click="closeOfferModal"
            class="flex-1 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 py-2 rounded-lg hover:bg-gray-200 transition-colors"
          >
            Annuler
          </button>
        </div>
    </Modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Plus, Gift, Percent, Star, ArrowUp, Trash2, Tag, Image, Upload, X } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'
import Modal from '@/components/ui/Modal.vue'

interface Offer {
  id?: string
  name: string
  description: string
  type: 'discount' | 'gift' | 'points' | 'upgrade'
  value?: number
  value_text?: string
  points_cost: number
  conditions?: string
  start_date?: string
  end_date?: string
  max_uses?: number
  max_uses_per_customer?: number
  is_active: boolean
  total_uses: number
  image_url?: string
}

const offers = ref<Offer[]>([])
const showAddOffer = ref(false)
const editingOffer = ref<Offer | null>(null)
const savingOffer = ref(false)
const imageFile = ref<File | null>(null)
const imagePreview = ref<string>('')
const uploadingImage = ref(false)

const searchQuery = ref('')
const filterStatus = ref('all')
const filterType = ref('all')

const offerTypes = [
  { value: 'discount', label: 'Réduction', icon: Percent },
  { value: 'gift', label: 'Cadeau', icon: Gift },
  { value: 'points', label: 'Points', icon: Star },
  { value: 'upgrade', label: 'Upgrade', icon: ArrowUp }
]

const offerForm = ref<Offer>({
  name: '',
  description: '',
  type: 'discount',
  value: undefined,
  value_text: '',
  points_cost: 100,
  conditions: '',
  start_date: '',
  end_date: '',
  max_uses: undefined,
  max_uses_per_customer: undefined,
  is_active: true,
  total_uses: 0,
  image_url: ''
})

const filteredOffers = computed(() => {
  return offers.value.filter(offer => {
    // Filtre par recherche
    if (searchQuery.value && !offer.name.toLowerCase().includes(searchQuery.value.toLowerCase())) {
      return false
    }
    
    // Filtre par statut
    if (filterStatus.value !== 'all') {
      const now = new Date()
      const startDate = offer.start_date ? new Date(offer.start_date) : null
      const endDate = offer.end_date ? new Date(offer.end_date) : null
      
      if (filterStatus.value === 'active' && !offer.is_active) return false
      if (filterStatus.value === 'draft' && offer.is_active) return false
      if (filterStatus.value === 'expired' && (!endDate || endDate > now)) return false
    }
    
    // Filtre par type
    if (filterType.value !== 'all' && offer.type !== filterType.value) {
      return false
    }
    
    return true
  })
})

const getOfferIcon = (type: string) => {
  switch (type) {
    case 'discount': return Percent
    case 'gift': return Gift
    case 'points': return Star
    case 'upgrade': return ArrowUp
    default: return Tag
  }
}

const getOfferTypeLabel = (type: string) => {
  switch (type) {
    case 'discount': return 'Réduction'
    case 'gift': return 'Cadeau'
    case 'points': return 'Points bonus'
    case 'upgrade': return 'Surclassement'
    default: return 'Offre'
  }
}

const getValueLabel = (type: string) => {
  switch (type) {
    case 'discount': return 'Pourcentage de réduction'
    case 'points': return 'Points bonus offerts'
    default: return 'Valeur de l\'offre'
  }
}

const loadOffers = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data } = await supabase
      .from('offers')
      .select('*')
      .eq('company_id', user.id)
      .order('created_at', { ascending: false })

    if (data) {
      offers.value = data
    }
  } catch (error) {
    console.error('Erreur chargement offres:', error)
  }
}

const handleImageSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (!file) return
  
  // Vérifier la taille du fichier (5MB max)
  if (file.size > 5 * 1024 * 1024) {
    alert('L\'image ne doit pas dépasser 5MB')
    return
  }
  
  imageFile.value = file
  
  // Créer un aperçu de l'image
  const reader = new FileReader()
  reader.onload = (e) => {
    imagePreview.value = e.target?.result as string
  }
  reader.readAsDataURL(file)
}

const removeImage = () => {
  imageFile.value = null
  imagePreview.value = ''
  offerForm.value.image_url = ''
}

const uploadImage = async (): Promise<string | null> => {
  if (!imageFile.value) return null
  
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return null
    
    const fileName = `${user.id}/${Date.now()}_${imageFile.value.name}`
    
    const { data, error } = await supabase.storage
      .from('offer-images')
      .upload(fileName, imageFile.value, {
        cacheControl: '3600',
        upsert: false
      })
    
    if (error) {
      console.error('Erreur upload image:', error)
      return null
    }
    
    // Obtenir l'URL publique
    const { data: { publicUrl } } = supabase.storage
      .from('offer-images')
      .getPublicUrl(fileName)
    
    return publicUrl
  } catch (error) {
    console.error('Erreur upload:', error)
    return null
  }
}

const saveOffer = async () => {
  savingOffer.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    // Upload l'image si nécessaire
    let imageUrl = offerForm.value.image_url
    if (imageFile.value) {
      uploadingImage.value = true
      const uploadedUrl = await uploadImage()
      if (uploadedUrl) {
        imageUrl = uploadedUrl
      }
      uploadingImage.value = false
    }

    const offerData = {
      company_id: user.id,
      ...offerForm.value,
      image_url: imageUrl
    }

    if (editingOffer.value) {
      const { error } = await supabase
        .from('offers')
        .update(offerData)
        .eq('id', editingOffer.value.id)

      if (!error) {
        await loadOffers()
        closeOfferModal()
      }
    } else {
      const { error } = await supabase
        .from('offers')
        .insert(offerData)

      if (!error) {
        await loadOffers()
        closeOfferModal()
      }
    }
  } catch (error) {
    console.error('Erreur sauvegarde offre:', error)
  } finally {
    savingOffer.value = false
  }
}

const editOffer = (offer: Offer) => {
  editingOffer.value = offer
  offerForm.value = { ...offer }
  imagePreview.value = offer.image_url || ''
  imageFile.value = null
}

const duplicateOffer = async (offer: Offer) => {
  const newOffer = { ...offer }
  delete newOffer.id
  newOffer.name = `${offer.name} (copie)`
  newOffer.total_uses = 0
  offerForm.value = newOffer
  showAddOffer.value = true
}

const toggleOffer = async (offer: Offer) => {
  try {
    const { error } = await supabase
      .from('offers')
      .update({ is_active: !offer.is_active })
      .eq('id', offer.id)

    if (!error) {
      offer.is_active = !offer.is_active
    }
  } catch (error) {
    console.error('Erreur changement statut:', error)
  }
}

const deleteOffer = async (offer: Offer) => {
  if (!confirm(`Supprimer l'offre "${offer.name}" ?`)) return

  try {
    const { error } = await supabase
      .from('offers')
      .delete()
      .eq('id', offer.id)

    if (!error) {
      offers.value = offers.value.filter(o => o.id !== offer.id)
    }
  } catch (error) {
    console.error('Erreur suppression:', error)
  }
}

const closeOfferModal = () => {
  showAddOffer.value = false
  editingOffer.value = null
  imageFile.value = null
  imagePreview.value = ''
  offerForm.value = {
    name: '',
    description: '',
    type: 'discount',
    value: undefined,
    value_text: '',
    points_cost: 100,
    conditions: '',
    start_date: '',
    end_date: '',
    max_uses: undefined,
    max_uses_per_customer: undefined,
    is_active: true,
    total_uses: 0,
    image_url: ''
  }
}

const formatDateRange = (start: string, end: string) => {
  if (!start && !end) return 'Permanent'
  const formatDate = (date: string) => new Date(date).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short' })
  if (start && end) return `${formatDate(start)} - ${formatDate(end)}`
  if (start) return `Dès le ${formatDate(start)}`
  if (end) return `Jusqu'au ${formatDate(end)}`
}

onMounted(() => {
  loadOffers()
})
</script>