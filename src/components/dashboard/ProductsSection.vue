<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-black text-gray-900">Nos Produits</h1>
        <p class="text-gray-600 mt-2">Gérez les produits disponibles pour vos fidèles</p>
      </div>
      <button
        @click="showAddProduct = true"
        class="bg-gradient-to-r from-violet-600 to-pink-600 text-white px-4 py-2 rounded-lg hover:shadow-lg transition-all duration-200 flex items-center gap-2"
      >
        <Plus :size="20" />
        Ajouter un produit
      </button>
    </div>

    <!-- Statistiques -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <div class="bg-white rounded-xl shadow-sm p-4 border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Total produits</p>
            <p class="text-2xl font-bold text-gray-900 mt-1">{{ products.length }}</p>
          </div>
          <Package :size="24" class="text-violet-600" />
        </div>
      </div>
      
      <div class="bg-white rounded-xl shadow-sm p-4 border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Produits actifs</p>
            <p class="text-2xl font-bold text-gray-900 mt-1">{{ activeProducts }}</p>
          </div>
          <CheckCircle :size="24" class="text-green-600" />
        </div>
      </div>
      
      <div class="bg-white rounded-xl shadow-sm p-4 border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Points moyens</p>
            <p class="text-2xl font-bold text-gray-900 mt-1">{{ averagePoints }}</p>
          </div>
          <Star :size="24" class="text-amber-600" />
        </div>
      </div>
      
      <div class="bg-white rounded-xl shadow-sm p-4 border border-gray-200">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">Achats ce mois</p>
            <p class="text-2xl font-bold text-gray-900 mt-1">{{ monthlyPurchases }}</p>
          </div>
          <ShoppingCart :size="24" class="text-pink-600" />
        </div>
      </div>
    </div>

    <!-- Liste des produits -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-200">
      <div class="p-6 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <h2 class="text-lg font-bold text-gray-900">Produits disponibles</h2>
          <div class="flex gap-2">
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Rechercher un produit..."
              class="px-3 py-1.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-violet-600"
            />
            <select
              v-model="filterCategory"
              class="px-3 py-1.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-violet-600"
            >
              <option value="">Toutes catégories</option>
              <option value="food">Nourriture</option>
              <option value="drink">Boisson</option>
              <option value="service">Service</option>
              <option value="discount">Réduction</option>
              <option value="other">Autre</option>
            </select>
          </div>
        </div>
      </div>

      <div v-if="loading" class="p-8 text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-violet-600 mx-auto"></div>
      </div>

      <div v-else-if="filteredProducts.length === 0" class="p-8 text-center text-gray-500">
        <Package :size="48" class="mx-auto mb-4 text-gray-300" />
        <p>Aucun produit trouvé</p>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 p-6">
        <div
          v-for="product in filteredProducts"
          :key="product.id"
          class="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
        >
          <div class="flex items-start justify-between mb-3">
            <div class="flex-1">
              <h3 class="font-semibold text-gray-900">{{ product.name }}</h3>
              <p class="text-sm text-gray-600 mt-1">{{ product.description }}</p>
            </div>
            <div class="flex items-center gap-1">
              <button
                @click="editProduct(product)"
                class="p-1 hover:bg-gray-100 rounded transition-colors"
              >
                <Edit2 :size="16" class="text-gray-600" />
              </button>
              <button
                @click="toggleProductStatus(product)"
                class="p-1 hover:bg-gray-100 rounded transition-colors"
              >
                <component 
                  :is="product.is_active ? 'ToggleRight' : 'ToggleLeft'"
                  :size="20" 
                  :class="product.is_active ? 'text-green-600' : 'text-gray-400'"
                />
              </button>
              <button
                @click="deleteProduct(product)"
                class="p-1 hover:bg-red-50 rounded transition-colors"
              >
                <Trash2 :size="16" class="text-red-600" />
              </button>
            </div>
          </div>

          <div class="flex items-center justify-between">
            <div class="flex items-center gap-2">
              <Star :size="16" class="text-amber-500" />
              <span class="font-bold text-violet-600">{{ product.points }} points</span>
            </div>
            <div v-if="product.price" class="text-sm text-gray-500">
              {{ product.price }}€
            </div>
          </div>

          <div class="mt-3 flex items-center justify-between text-sm">
            <span :class="[
              'px-2 py-1 rounded-full text-xs font-medium',
              getCategoryClass(product.category)
            ]">
              {{ getCategoryLabel(product.category) }}
            </span>
            <span v-if="!product.unlimited_stock" class="text-gray-500">
              Stock: {{ product.stock }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Ajouter/Modifier produit -->
    <div v-if="showAddProduct || editingProduct" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-xl p-6 w-full max-w-md">
        <h3 class="text-xl font-bold text-gray-900 mb-4">
          {{ editingProduct ? 'Modifier le produit' : 'Ajouter un produit' }}
        </h3>

        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nom du produit</label>
            <input
              v-model="productForm.name"
              type="text"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
              placeholder="Ex: Café gratuit"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea
              v-model="productForm.description"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
              rows="2"
              placeholder="Description du produit"
            ></textarea>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Points requis</label>
              <input
                v-model.number="productForm.points"
                type="number"
                min="1"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
                placeholder="100"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Prix (€)</label>
              <input
                v-model.number="productForm.price"
                type="number"
                step="0.01"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
                placeholder="5.50"
              />
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Catégorie</label>
            <select
              v-model="productForm.category"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
            >
              <option value="food">Nourriture</option>
              <option value="drink">Boisson</option>
              <option value="service">Service</option>
              <option value="discount">Réduction</option>
              <option value="other">Autre</option>
            </select>
          </div>

          <div>
            <label class="flex items-center space-x-2">
              <input
                v-model="productForm.unlimited_stock"
                type="checkbox"
                class="rounded text-violet-600 focus:ring-violet-600"
              />
              <span class="text-sm text-gray-700">Stock illimité</span>
            </label>
          </div>

          <div v-if="!productForm.unlimited_stock">
            <label class="block text-sm font-medium text-gray-700 mb-1">Stock disponible</label>
            <input
              v-model.number="productForm.stock"
              type="number"
              min="0"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-600"
              placeholder="50"
            />
          </div>
        </div>

        <div class="flex gap-3 mt-6">
          <button
            @click="saveProduct"
            :disabled="saving"
            class="flex-1 bg-gradient-to-r from-violet-600 to-pink-600 text-white py-2 rounded-lg hover:shadow-lg transition-all duration-200 disabled:opacity-50"
          >
            {{ saving ? 'Enregistrement...' : 'Enregistrer' }}
          </button>
          <button
            @click="closeProductModal"
            class="flex-1 bg-gray-100 text-gray-700 py-2 rounded-lg hover:bg-gray-200 transition-colors"
          >
            Annuler
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { 
  Package, Plus, Edit2, Trash2, Star, CheckCircle, 
  ShoppingCart, ToggleRight, ToggleLeft 
} from 'lucide-vue-next'
import { supabase } from '@/services/supabase'

interface Product {
  id: string
  name: string
  description: string
  points: number
  price?: number
  category: string
  stock?: number
  unlimited_stock: boolean
  is_active: boolean
  display_order: number
}

const products = ref<Product[]>([])
const loading = ref(false)
const saving = ref(false)
const showAddProduct = ref(false)
const editingProduct = ref<Product | null>(null)
const searchQuery = ref('')
const filterCategory = ref('')
const monthlyPurchases = ref(0)

const productForm = ref({
  name: '',
  description: '',
  points: 100,
  price: null as number | null,
  category: 'other',
  stock: null as number | null,
  unlimited_stock: true
})

const filteredProducts = computed(() => {
  let filtered = products.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(p => 
      p.name.toLowerCase().includes(query) ||
      p.description?.toLowerCase().includes(query)
    )
  }

  if (filterCategory.value) {
    filtered = filtered.filter(p => p.category === filterCategory.value)
  }

  return filtered.sort((a, b) => a.display_order - b.display_order)
})

const activeProducts = computed(() => 
  products.value.filter(p => p.is_active).length
)

const averagePoints = computed(() => {
  if (products.value.length === 0) return 0
  const total = products.value.reduce((sum, p) => sum + p.points, 0)
  return Math.round(total / products.value.length)
})

function getCategoryLabel(category: string): string {
  const labels: Record<string, string> = {
    food: 'Nourriture',
    drink: 'Boisson',
    service: 'Service',
    discount: 'Réduction',
    other: 'Autre'
  }
  return labels[category] || category
}

function getCategoryClass(category: string): string {
  const classes: Record<string, string> = {
    food: 'bg-orange-100 text-orange-700',
    drink: 'bg-blue-100 text-blue-700',
    service: 'bg-purple-100 text-purple-700',
    discount: 'bg-green-100 text-green-700',
    other: 'bg-gray-100 text-gray-700'
  }
  return classes[category] || 'bg-gray-100 text-gray-700'
}

async function loadProducts() {
  loading.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data, error } = await supabase
      .from('products')
      .select('*')
      .eq('company_id', user.id)
      .order('display_order', { ascending: true })

    if (!error && data) {
      products.value = data
    }

    // Charger le nombre d'achats ce mois
    const startOfMonth = new Date()
    startOfMonth.setDate(1)
    startOfMonth.setHours(0, 0, 0, 0)

    const { data: purchases } = await supabase
      .from('product_purchases')
      .select('id')
      .eq('company_id', user.id)
      .gte('purchased_at', startOfMonth.toISOString())

    if (purchases) {
      monthlyPurchases.value = purchases.length
    }
  } catch (error) {
    console.error('Erreur chargement produits:', error)
  } finally {
    loading.value = false
  }
}

async function saveProduct() {
  saving.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const productData = {
      company_id: user.id,
      name: productForm.value.name,
      description: productForm.value.description,
      points: productForm.value.points,
      price: productForm.value.price,
      category: productForm.value.category,
      stock: productForm.value.unlimited_stock ? null : productForm.value.stock,
      unlimited_stock: productForm.value.unlimited_stock,
      is_active: true
    }

    if (editingProduct.value) {
      const { error } = await supabase
        .from('products')
        .update(productData)
        .eq('id', editingProduct.value.id)

      if (!error) {
        await loadProducts()
        closeProductModal()
      }
    } else {
      const { error } = await supabase
        .from('products')
        .insert(productData)

      if (!error) {
        await loadProducts()
        closeProductModal()
      }
    }
  } catch (error) {
    console.error('Erreur sauvegarde produit:', error)
  } finally {
    saving.value = false
  }
}

function editProduct(product: Product) {
  editingProduct.value = product
  productForm.value = {
    name: product.name,
    description: product.description,
    points: product.points,
    price: product.price || null,
    category: product.category,
    stock: product.stock || null,
    unlimited_stock: product.unlimited_stock
  }
}

async function toggleProductStatus(product: Product) {
  try {
    const { error } = await supabase
      .from('products')
      .update({ is_active: !product.is_active })
      .eq('id', product.id)

    if (!error) {
      product.is_active = !product.is_active
    }
  } catch (error) {
    console.error('Erreur changement statut:', error)
  }
}

async function deleteProduct(product: Product) {
  if (!confirm(`Êtes-vous sûr de vouloir supprimer "${product.name}" ?`)) return

  try {
    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', product.id)

    if (!error) {
      products.value = products.value.filter(p => p.id !== product.id)
    }
  } catch (error) {
    console.error('Erreur suppression produit:', error)
  }
}

function closeProductModal() {
  showAddProduct.value = false
  editingProduct.value = null
  productForm.value = {
    name: '',
    description: '',
    points: 100,
    price: null,
    category: 'other',
    stock: null,
    unlimited_stock: true
  }
}

onMounted(() => {
  loadProducts()
})
</script>