<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-3xl font-black text-gray-900 dark:text-white">Vos Fidèles</h1>
        <p class="text-gray-600 dark:text-gray-400 mt-2">Gérez vos clients fidèles et leurs points</p>
      </div>
      <div class="flex space-x-3">
        <button class="px-4 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors flex items-center space-x-2">
          <Download :size="18" />
          <span>Exporter</span>
        </button>
        <button class="bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold px-6 py-3 rounded-full hover:scale-105 transition-all duration-300 shadow-lg flex items-center space-x-2">
          <UserPlus :size="20" />
          <span>Ajouter un client</span>
        </button>
      </div>
    </div>

    <!-- Barre de recherche et filtres -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
      <div class="flex flex-col md:flex-row md:items-center space-y-4 md:space-y-0 md:space-x-4">
        <div class="flex-1 relative">
          <Search :size="20" class="absolute left-3 top-3 text-gray-400" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Rechercher un client..."
            class="w-full pl-10 pr-4 py-3 border border-gray-200 dark:border-gray-700 rounded-lg focus:outline-none focus:border-violet-500 transition-colors"
          />
        </div>
        <select 
          v-model="filter"
          class="px-4 py-3 border border-gray-200 dark:border-gray-700 rounded-lg focus:outline-none focus:border-violet-500 transition-colors"
        >
          <option value="all">Tous les clients</option>
          <option value="active">Clients actifs</option>
          <option value="inactive">Clients inactifs</option>
          <option value="vip">VIP (500+ pts)</option>
        </select>
        <button class="px-4 py-3 bg-violet-100 text-violet-600 rounded-lg font-medium hover:bg-violet-200 transition-colors flex items-center space-x-2">
          <Filter :size="18" />
          <span>Filtres</span>
        </button>
      </div>
    </div>

    <!-- Statistiques -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <div class="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
        <p class="text-sm text-gray-600 dark:text-gray-400">Total clients</p>
        <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stats.totalCustomers }}</p>
        <p class="text-xs text-green-600 mt-1" v-if="stats.monthlyGrowth > 0">+{{ stats.monthlyGrowth }}% ce mois</p>
        <p class="text-xs text-red-600 mt-1" v-else-if="stats.monthlyGrowth < 0">{{ stats.monthlyGrowth }}% ce mois</p>
        <p class="text-xs text-gray-500 dark:text-gray-400 mt-1" v-else>Aucune évolution ce mois</p>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
        <p class="text-sm text-gray-600 dark:text-gray-400">Clients actifs</p>
        <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stats.activeCustomers }}</p>
        <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">{{ stats.totalCustomers > 0 ? Math.round((stats.activeCustomers / stats.totalCustomers) * 100) : 0 }}% du total</p>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
        <p class="text-sm text-gray-600 dark:text-gray-400">Points totaux</p>
        <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stats.totalPoints.toLocaleString() }}</p>
        <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">Moyenne: {{ stats.totalCustomers > 0 ? Math.round(stats.totalPoints / stats.totalCustomers) : 0 }} pts</p>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-700">
        <p class="text-sm text-gray-600 dark:text-gray-400">Taux de rétention</p>
        <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stats.retentionRate }}%</p>
        <p class="text-xs text-green-600 mt-1">+3% ce mois</p>
      </div>
    </div>

    <!-- Table des clients -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700">
      <div class="overflow-x-auto overflow-y-visible">
        <table class="w-full">
          <thead class="bg-gray-50 dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700">
            <tr>
              <th class="text-left px-6 py-4 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Client
              </th>
              <th class="text-left px-6 py-4 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Points
              </th>
              <th class="text-left px-6 py-4 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Statut
              </th>
              <th class="text-left px-6 py-4 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Dernière visite
              </th>
              <th class="text-left px-6 py-4 text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <!-- Loading state -->
            <tr v-if="loading">
              <td colspan="5" class="px-6 py-12 text-center">
                <div class="flex justify-center items-center space-x-2">
                  <div class="w-8 h-8 border-4 border-violet-600 border-t-transparent rounded-full animate-spin"></div>
                  <span class="text-gray-500 dark:text-gray-400">Chargement des clients...</span>
                </div>
              </td>
            </tr>
            
            <!-- No customers -->
            <tr v-else-if="paginatedCustomers.length === 0">
              <td colspan="5" class="px-6 py-12 text-center">
                <p class="text-gray-500 dark:text-gray-400">Aucun client trouvé</p>
                <button class="mt-4 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold px-6 py-3 rounded-full hover:scale-105 transition-all duration-300 shadow-lg">
                  <UserPlus :size="20" class="inline mr-2" />
                  Ajouter votre premier client
                </button>
              </td>
            </tr>
            
            <!-- Customer rows -->
            <tr v-else v-for="(customer, index) in paginatedCustomers" :key="customer.id" class="hover:bg-gray-50 transition-colors">
              <td class="px-6 py-4">
                <div class="flex items-center space-x-3">
                  <div :class="[getInitialsColor(index), 'w-10 h-10 rounded-full flex items-center justify-center']">
                    <span :class="[getInitialsTextColor(index), 'font-bold']">{{ getInitials(customer) }}</span>
                  </div>
                  <div>
                    <p class="font-medium text-gray-900 dark:text-white">{{ customer.first_name }} {{ customer.last_name }}</p>
                    <p class="text-sm text-gray-500 dark:text-gray-400">{{ customer.email }}</p>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4">
                <div class="flex items-center space-x-2">
                  <Star :size="16" class="text-yellow-500 fill-current" />
                  <span class="font-semibold">{{ customer.points }}</span>
                </div>
              </td>
              <td class="px-6 py-4">
                <span :class="['px-2 py-1 text-xs font-medium rounded-full', getCustomerStatus(customer).class]">
                  {{ getCustomerStatus(customer).label }}
                </span>
              </td>
              <td class="px-6 py-4 text-sm text-gray-600 dark:text-gray-400">
                {{ formatLastVisit(customer.last_visit) }}
              </td>
              <td class="px-6 py-4">
                <div class="flex space-x-2">
                  <button 
                    @click="viewCustomer(customer)"
                    class="text-violet-600 hover:text-violet-700 p-1 hover:bg-violet-50 rounded transition-colors"
                    title="Voir le profil"
                  >
                    <Eye :size="18" />
                  </button>
                  <button 
                    @click="sendEmail(customer)"
                    class="text-gray-600 dark:text-gray-400 hover:text-gray-700 dark:text-gray-300 p-1 hover:bg-gray-50 rounded transition-colors"
                    title="Envoyer un email"
                  >
                    <Mail :size="18" />
                  </button>
                  <div class="relative">
                    <button 
                      :ref="el => setButtonRef(customer.id, el as HTMLElement)"
                      @click="toggleDropdown(customer.id)"
                      class="text-gray-600 dark:text-gray-400 hover:text-gray-700 dark:text-gray-300 p-1 hover:bg-gray-50 rounded transition-colors"
                      title="Plus d'options"
                    >
                      <MoreVertical :size="18" />
                    </button>
                  </div>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div class="px-6 py-4 border-t border-gray-200 dark:border-gray-700 flex items-center justify-between">
        <p class="text-sm text-gray-600 dark:text-gray-400">
          <span v-if="filteredCustomers.length > 0">
            Affichage de {{ (currentPage - 1) * itemsPerPage + 1 }} à 
            {{ Math.min(currentPage * itemsPerPage, filteredCustomers.length) }} sur 
            {{ filteredCustomers.length }} client{{ filteredCustomers.length > 1 ? 's' : '' }}
          </span>
          <span v-else>Aucun client</span>
        </p>
        <div class="flex space-x-2" v-if="totalPages > 1">
          <button 
            @click="currentPage = Math.max(1, currentPage - 1)"
            :disabled="currentPage === 1"
            class="px-3 py-1 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors disabled:opacity-50 disabled:hover:bg-white dark:bg-gray-800"
          >
            Précédent
          </button>
          <template v-for="page in totalPages" :key="page">
            <button 
              v-if="page <= 3 || page > totalPages - 3 || Math.abs(page - currentPage) <= 1"
              @click="currentPage = page"
              :class="[
                'px-3 py-1 rounded-lg transition-colors',
                page === currentPage 
                  ? 'bg-violet-600 text-white' 
                  : 'border border-gray-300 hover:bg-gray-50'
              ]"
            >
              {{ page }}
            </button>
            <span 
              v-else-if="(page === 4 && currentPage > 5) || (page === totalPages - 3 && currentPage < totalPages - 4)"
              class="px-2"
            >
              ...
            </span>
          </template>
          <button 
            @click="currentPage = Math.min(totalPages, currentPage + 1)"
            :disabled="currentPage === totalPages"
            class="px-3 py-1 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors disabled:opacity-50 disabled:hover:bg-white dark:bg-gray-800"
          >
            Suivant
          </button>
        </div>
      </div>
    </div>

    <!-- Modal de gestion des points -->
    <Teleport to="body">
      <div 
        v-if="showPointsModal"
        class="fixed inset-0 z-50 flex items-center justify-center p-4"
      >
        <!-- Overlay -->
        <div 
          class="absolute inset-0 bg-black/50"
          @click="closePointsModal"
        ></div>
        
        <!-- Modal -->
        <div class="relative bg-white dark:bg-gray-800 rounded-2xl shadow-2xl p-6 max-w-md w-full">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white mb-4">Gérer les points</h2>
          
          <div v-if="selectedCustomer" class="space-y-4">
            <!-- Info client -->
            <div class="bg-gray-50 rounded-lg p-4">
              <p class="font-medium text-gray-900 dark:text-white">
                {{ selectedCustomer.first_name }} {{ selectedCustomer.last_name }}
              </p>
              <p class="text-sm text-gray-600 dark:text-gray-400">{{ selectedCustomer.email }}</p>
              <div class="mt-2 flex items-center space-x-2">
                <Star :size="20" class="text-yellow-500 fill-current" />
                <span class="font-bold text-lg">{{ selectedCustomer.points }} points</span>
              </div>
            </div>

            <!-- Type d'opération -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Type d'opération
              </label>
              <div class="grid grid-cols-3 gap-2">
                <button
                  @click="selectOperationType('product')"
                  :class="[
                    'py-2 px-3 rounded-lg font-medium transition-colors text-sm',
                    operationType === 'product'
                      ? 'bg-violet-100 text-violet-700 border-2 border-violet-300'
                      : 'bg-gray-50 text-gray-700 dark:text-gray-300 border-2 border-gray-200 dark:border-gray-700'
                  ]"
                >
                  <ShoppingCart :size="16" class="inline mr-1" />
                  Achat Produit
                </button>
                <button
                  @click="selectOperationType('admin')"
                  :class="[
                    'py-2 px-3 rounded-lg font-medium transition-colors text-sm',
                    operationType === 'admin'
                      ? 'bg-blue-100 text-blue-700 border-2 border-blue-300'
                      : 'bg-gray-50 text-gray-700 dark:text-gray-300 border-2 border-gray-200 dark:border-gray-700'
                  ]"
                >
                  <Settings :size="16" class="inline mr-1" />
                  Modif Admin
                </button>
                <button
                  @click="selectOperationType('bonus')"
                  :class="[
                    'py-2 px-3 rounded-lg font-medium transition-colors text-sm',
                    operationType === 'bonus'
                      ? 'bg-green-100 text-green-700 border-2 border-green-300'
                      : 'bg-gray-50 text-gray-700 dark:text-gray-300 border-2 border-gray-200 dark:border-gray-700'
                  ]"
                >
                  <Gift :size="16" class="inline mr-1" />
                  Bonus
                </button>
              </div>
            </div>

            <!-- Section Achat Produit -->
            <div v-if="operationType === 'product'" class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Sélectionner un produit
                </label>
                <div v-if="loadingProducts" class="text-center py-4">
                  <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-violet-600 mx-auto"></div>
                </div>
                <div v-else-if="availableProducts.length === 0" class="text-center py-4 text-gray-500 dark:text-gray-400">
                  Aucun produit disponible
                </div>
                <div v-else class="max-h-48 overflow-y-auto border border-gray-200 dark:border-gray-700 rounded-lg">
                  <button
                    v-for="product in availableProducts"
                    :key="product.id"
                    @click="selectProduct(product)"
                    :class="[
                      'w-full text-left px-3 py-2 hover:bg-violet-50 transition-colors border-b last:border-b-0',
                      selectedProduct?.id === product.id ? 'bg-violet-50' : ''
                    ]"
                  >
                    <div class="flex justify-between items-center">
                      <div>
                        <p class="font-medium text-gray-900 dark:text-white">{{ product.name }}</p>
                        <p class="text-xs text-gray-500 dark:text-gray-400">{{ product.description }}</p>
                      </div>
                      <div class="text-right">
                        <p class="font-bold text-violet-600">{{ product.points }} pts</p>
                        <p v-if="product.price" class="text-xs text-gray-500 dark:text-gray-400">{{ product.price }}€</p>
                      </div>
                    </div>
                  </button>
                </div>
              </div>
              
              <div v-if="selectedProduct">
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Quantité
                </label>
                <input
                  v-model.number="productQuantity"
                  type="number"
                  min="1"
                  class="w-full px-4 py-2 border-2 border-gray-200 dark:border-gray-700 rounded-lg focus:outline-none focus:border-violet-500"
                />
                <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
                  Total: {{ (selectedProduct.points * productQuantity) }} points
                </p>
              </div>
            </div>

            <!-- Section Modif Admin -->
            <div v-if="operationType === 'admin'" class="space-y-4">
              <div class="grid grid-cols-2 gap-2">
                <button
                  @click="pointsOperation = 'add'"
                  :class="[
                    'py-2 px-4 rounded-lg font-medium transition-colors',
                    pointsOperation === 'add'
                      ? 'bg-green-100 text-green-700 border-2 border-green-300'
                      : 'bg-gray-50 text-gray-700 dark:text-gray-300 border-2 border-gray-200 dark:border-gray-700'
                  ]"
                >
                  <Plus :size="18" class="inline mr-1" />
                  Ajouter
                </button>
                <button
                  @click="pointsOperation = 'remove'"
                  :class="[
                    'py-2 px-4 rounded-lg font-medium transition-colors',
                    pointsOperation === 'remove'
                      ? 'bg-red-100 text-red-700 border-2 border-red-300'
                      : 'bg-gray-50 text-gray-700 dark:text-gray-300 border-2 border-gray-200 dark:border-gray-700'
                  ]"
                >
                  <Minus :size="18" class="inline mr-1" />
                  Retirer
                </button>
              </div>
              
              <!-- Nombre de points pour admin -->
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Nombre de points
                </label>
                <input
                  v-model.number="pointsAmount"
                  type="number"
                  min="0"
                  :max="pointsOperation === 'remove' ? selectedCustomer.points : undefined"
                  class="w-full px-4 py-2 border-2 border-gray-200 dark:border-gray-700 rounded-lg focus:outline-none focus:border-violet-500"
                  placeholder="0"
                />
                <p v-if="pointsOperation === 'remove'" class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                  Maximum: {{ selectedCustomer.points }} points
                </p>
              </div>
            </div>

            <!-- Section Bonus -->
            <div v-if="operationType === 'bonus'" class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Type de bonus
                </label>
                <select
                  v-model="bonusType"
                  class="w-full px-4 py-2 border-2 border-gray-200 dark:border-gray-700 rounded-lg focus:outline-none focus:border-violet-500"
                >
                  <option value="welcome">Bonus de bienvenue (50 pts)</option>
                  <option value="birthday">Bonus anniversaire (100 pts)</option>
                  <option value="referral">Parrainage (75 pts)</option>
                  <option value="special">Événement spécial (25 pts)</option>
                </select>
              </div>
            </div>

            <!-- Raison (optionnel) -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Raison (optionnel)
              </label>
              <textarea
                v-model="pointsReason"
                rows="2"
                class="w-full px-4 py-2 border-2 border-gray-200 dark:border-gray-700 rounded-lg focus:outline-none focus:border-violet-500"
                placeholder="Ex: Bonus anniversaire, Ajustement manuel..."
              ></textarea>
            </div>

            <!-- Aperçu -->
            <div class="bg-violet-50 rounded-lg p-4">
              <p class="text-sm text-violet-700">
                <span class="font-medium">Nouveau solde:</span>
                <span class="font-bold ml-2">
                  {{ calculateNewBalance() }} points
                </span>
              </p>
            </div>

            <!-- Boutons -->
            <div class="flex space-x-3">
              <button
                @click="closePointsModal"
                class="flex-1 py-2 px-4 bg-gray-100 hover:bg-gray-200 text-gray-700 dark:text-gray-300 font-medium rounded-lg transition-colors"
              >
                Annuler
              </button>
              <button
                @click="updatePoints"
                :disabled="!pointsAmount || pointsAmount <= 0 || updatingPoints"
                class="flex-1 py-2 px-4 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-medium rounded-lg hover:scale-105 transition-all duration-300 shadow-lg disabled:opacity-50 disabled:hover:scale-100"
              >
                {{ updatingPoints ? 'Mise à jour...' : 'Confirmer' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Modal de confirmation de suppression -->
    <Teleport to="body">
      <div 
        v-if="showDeleteModal"
        class="fixed inset-0 z-50 flex items-center justify-center p-4"
      >
        <!-- Overlay -->
        <div 
          class="absolute inset-0 bg-black/50"
          @click="showDeleteModal = false"
        ></div>
        
        <!-- Modal -->
        <div class="relative bg-white dark:bg-gray-800 rounded-2xl shadow-2xl p-6 max-w-md w-full">
          <h2 class="text-xl font-bold text-gray-900 dark:text-white mb-4">Confirmer la suppression</h2>
          
          <div v-if="selectedCustomer" class="space-y-4">
            <p class="text-gray-600 dark:text-gray-400">
              Êtes-vous sûr de vouloir supprimer ce client ?
            </p>
            
            <div class="bg-red-50 rounded-lg p-4 border border-red-200">
              <p class="font-medium text-gray-900 dark:text-white">
                {{ selectedCustomer.first_name }} {{ selectedCustomer.last_name }}
              </p>
              <p class="text-sm text-gray-600 dark:text-gray-400">{{ selectedCustomer.email }}</p>
              <p class="text-sm text-red-600 mt-2">
                ⚠️ Cette action est irréversible
              </p>
            </div>

            <!-- Boutons -->
            <div class="flex space-x-3">
              <button
                @click="showDeleteModal = false"
                class="flex-1 py-2 px-4 bg-gray-100 hover:bg-gray-200 text-gray-700 dark:text-gray-300 font-medium rounded-lg transition-colors"
              >
                Annuler
              </button>
              <button
                @click="deleteCustomer"
                :disabled="deleting"
                class="flex-1 py-2 px-4 bg-red-600 hover:bg-red-700 text-white font-medium rounded-lg transition-colors disabled:opacity-50"
              >
                {{ deleting ? 'Suppression...' : 'Supprimer' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Modal de détail du client -->
    <Teleport to="body">
      <div 
        v-if="showDetailModal"
        class="fixed inset-0 z-50 flex items-center justify-center p-4"
      >
        <!-- Overlay -->
        <div 
          class="absolute inset-0 bg-black/50"
          @click="closeDetailModal"
        ></div>
        
        <!-- Modal -->
        <div class="relative bg-white dark:bg-gray-800 rounded-2xl shadow-2xl p-6 max-w-4xl w-full max-h-[90vh] overflow-y-auto">
          <!-- Header -->
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Détails du client</h2>
            <button
              @click="closeDetailModal"
              class="text-gray-400 hover:text-gray-600 dark:text-gray-400 transition-colors"
            >
              <X :size="24" />
            </button>
          </div>
          
          <div v-if="loadingDetails" class="flex justify-center py-12">
            <div class="w-12 h-12 border-4 border-violet-600 border-t-transparent rounded-full animate-spin"></div>
          </div>
          
          <div v-else-if="customerDetails" class="space-y-6">
            <!-- En-tête du profil -->
            <div class="flex items-start justify-between bg-gradient-to-r from-violet-50 to-pink-50 rounded-xl p-6">
              <div class="flex items-center space-x-4">
                <div class="w-20 h-20 bg-gradient-to-r from-violet-600 to-pink-600 rounded-full flex items-center justify-center text-white text-2xl font-bold">
                  {{ getInitials(customerDetails) }}
                </div>
                <div>
                  <h3 class="text-2xl font-bold text-gray-900 dark:text-white">
                    {{ customerDetails.first_name }} {{ customerDetails.last_name }}
                  </h3>
                  <p class="text-gray-600 dark:text-gray-400">Client depuis {{ formatDate(customerDetails.created_at) }}</p>
                  <div class="flex items-center space-x-2 mt-2">
                    <Star :size="20" class="text-yellow-500 fill-current" />
                    <span class="font-bold text-xl">{{ customerDetails.points }} points</span>
                    <span :class="['px-2 py-1 text-xs font-medium rounded-full ml-2', getCustomerStatus(customerDetails).class]">
                      {{ getCustomerStatus(customerDetails).label }}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Informations personnelles -->
            <div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl p-6">
              <h4 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center space-x-2">
                <User :size="20" class="text-violet-600" />
                <span>Informations personnelles</span>
              </h4>
              
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <!-- Prénom -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Prénom</label>
                  <div class="flex items-center space-x-2">
                    <div v-if="editingField !== 'first_name'" class="flex items-center space-x-2 flex-1">
                      <p class="text-gray-900 dark:text-white">{{ customerDetails.first_name }}</p>
                      <button
                        @click="startEditing('first_name')"
                        class="text-violet-600 hover:text-violet-700"
                      >
                        <Edit2 :size="16" />
                      </button>
                    </div>
                    <div v-else class="flex items-center space-x-2 flex-1">
                      <input
                        v-model="editValue"
                        type="text"
                        class="flex-1 px-3 py-1 border border-gray-200 dark:border-gray-700 rounded-lg focus:outline-none focus:border-violet-500"
                      />
                      <button
                        @click="saveDirectEdit('first_name')"
                        class="text-green-600 hover:text-green-700"
                      >
                        <Check :size="16" />
                      </button>
                      <button
                        @click="cancelEditing"
                        class="text-red-600 hover:text-red-700"
                      >
                        <X :size="16" />
                      </button>
                    </div>
                  </div>
                </div>

                <!-- Nom -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Nom</label>
                  <div class="flex items-center space-x-2">
                    <div v-if="editingField !== 'last_name'" class="flex items-center space-x-2 flex-1">
                      <p class="text-gray-900 dark:text-white">{{ customerDetails.last_name }}</p>
                      <button
                        @click="startEditing('last_name')"
                        class="text-violet-600 hover:text-violet-700"
                      >
                        <Edit2 :size="16" />
                      </button>
                    </div>
                    <div v-else class="flex items-center space-x-2 flex-1">
                      <input
                        v-model="editValue"
                        type="text"
                        class="flex-1 px-3 py-1 border border-gray-200 dark:border-gray-700 rounded-lg focus:outline-none focus:border-violet-500"
                      />
                      <button
                        @click="saveDirectEdit('last_name')"
                        class="text-green-600 hover:text-green-700"
                      >
                        <Check :size="16" />
                      </button>
                      <button
                        @click="cancelEditing"
                        class="text-red-600 hover:text-red-700"
                      >
                        <X :size="16" />
                      </button>
                    </div>
                  </div>
                </div>

                <!-- Email (sécurisé) -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1 flex items-center space-x-1">
                    <span>Email</span>
                    <Shield :size="14" class="text-orange-500" title="Modification sécurisée" />
                  </label>
                  <div class="flex items-center space-x-2">
                    <div v-if="editingField !== 'email'" class="flex items-center space-x-2 flex-1">
                      <p class="text-gray-900 dark:text-white">{{ customerDetails.email }}</p>
                      <button
                        @click="startEditing('email')"
                        class="text-violet-600 hover:text-violet-700"
                      >
                        <Edit2 :size="16" />
                      </button>
                    </div>
                    <div v-else class="space-y-2 flex-1">
                      <input
                        v-model="editValue"
                        type="email"
                        class="w-full px-3 py-1 border border-gray-200 dark:border-gray-700 rounded-lg focus:outline-none focus:border-violet-500"
                        placeholder="Nouveau email"
                      />
                      <div class="flex items-center space-x-2">
                        <button
                          @click="generateSecureLink('email')"
                          :disabled="generatingLink"
                          class="px-3 py-1 bg-orange-500 text-white rounded-lg hover:bg-orange-600 text-sm disabled:opacity-50"
                        >
                          {{ generatingLink ? 'Génération...' : 'Générer lien sécurisé' }}
                        </button>
                        <button
                          @click="cancelEditing"
                          class="text-red-600 hover:text-red-700"
                        >
                          <X :size="16" />
                        </button>
                      </div>
                      <div v-if="generatedLink" class="bg-orange-50 border border-orange-200 rounded-lg p-3 mt-2">
                        <p class="text-xs text-orange-700 mb-2">Lien de modification (usage unique) :</p>
                        <div class="flex items-center space-x-2">
                          <input
                            :value="generatedLink"
                            readonly
                            class="flex-1 px-2 py-1 bg-white dark:bg-gray-800 border border-orange-200 rounded text-xs"
                          />
                          <button
                            @click="copyLink"
                            class="px-2 py-1 bg-orange-500 text-white rounded hover:bg-orange-600 text-xs"
                          >
                            {{ linkCopied ? '✓ Copié' : 'Copier' }}
                          </button>
                        </div>
                        <p class="text-xs text-orange-600 mt-2">
                          ⚠️ Ce lien expire dans 24h et ne peut être utilisé qu'une fois
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Téléphone -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Téléphone</label>
                  <div class="flex items-center space-x-2">
                    <div v-if="editingField !== 'phone'" class="flex items-center space-x-2 flex-1">
                      <p class="text-gray-900 dark:text-white">{{ customerDetails.phone || 'Non renseigné' }}</p>
                      <button
                        @click="startEditing('phone')"
                        class="text-violet-600 hover:text-violet-700"
                      >
                        <Edit2 :size="16" />
                      </button>
                    </div>
                    <div v-else class="flex items-center space-x-2 flex-1">
                      <input
                        v-model="editValue"
                        type="tel"
                        class="flex-1 px-3 py-1 border border-gray-200 dark:border-gray-700 rounded-lg focus:outline-none focus:border-violet-500"
                      />
                      <button
                        @click="saveDirectEdit('phone')"
                        class="text-green-600 hover:text-green-700"
                      >
                        <Check :size="16" />
                      </button>
                      <button
                        @click="cancelEditing"
                        class="text-red-600 hover:text-red-700"
                      >
                        <X :size="16" />
                      </button>
                    </div>
                  </div>
                </div>

                <!-- Date de naissance -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Date de naissance</label>
                  <p class="text-gray-900 dark:text-white">{{ formatDate(customerDetails.date_of_birth) }}</p>
                </div>

                <!-- Adresse -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Adresse</label>
                  <p class="text-gray-900 dark:text-white">{{ customerDetails.address || 'Non renseignée' }}</p>
                </div>
              </div>
            </div>

            <!-- Statistiques -->
            <div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl p-6">
              <h4 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center space-x-2">
                <TrendingUp :size="20" class="text-violet-600" />
                <span>Statistiques</span>
              </h4>
              
              <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div class="bg-gray-50 rounded-lg p-4">
                  <p class="text-sm text-gray-600 dark:text-gray-400">Points actuels</p>
                  <p class="text-2xl font-bold text-violet-600">{{ customerDetails.points }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-4">
                  <p class="text-sm text-gray-600 dark:text-gray-400">Total gagné</p>
                  <p class="text-2xl font-bold text-green-600">{{ customerDetails.total_points_earned || 0 }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-4">
                  <p class="text-sm text-gray-600 dark:text-gray-400">Total dépensé</p>
                  <p class="text-2xl font-bold text-red-600">{{ customerDetails.total_points_spent || 0 }}</p>
                </div>
                <div class="bg-gray-50 rounded-lg p-4">
                  <p class="text-sm text-gray-600 dark:text-gray-400">Dernière visite</p>
                  <p class="text-sm font-medium text-gray-900 dark:text-white">{{ formatLastVisit(customerDetails.last_visit) }}</p>
                </div>
              </div>
            </div>

            <!-- Préférences -->
            <div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl p-6">
              <h4 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center space-x-2">
                <Settings :size="20" class="text-violet-600" />
                <span>Préférences de communication</span>
              </h4>
              
              <div class="space-y-3">
                <div class="flex items-center justify-between">
                  <span class="text-gray-700 dark:text-gray-300">Accepte les conditions</span>
                  <span :class="customerDetails.accept_terms ? 'text-green-600' : 'text-gray-400'">
                    {{ customerDetails.accept_terms ? '✓ Oui' : 'Non' }}
                  </span>
                </div>
                <div class="flex items-center justify-between">
                  <span class="text-gray-700 dark:text-gray-300">Recevoir les offres marketing</span>
                  <span :class="customerDetails.accept_marketing ? 'text-green-600' : 'text-gray-400'">
                    {{ customerDetails.accept_marketing ? '✓ Oui' : 'Non' }}
                  </span>
                </div>
                <div class="flex items-center justify-between">
                  <span class="text-gray-700 dark:text-gray-300">Recevoir les offres partenaires</span>
                  <span :class="customerDetails.accept_partners ? 'text-green-600' : 'text-gray-400'">
                    {{ customerDetails.accept_partners ? '✓ Oui' : 'Non' }}
                  </span>
                </div>
              </div>
            </div>

            <!-- Actions -->
            <div class="flex justify-end space-x-3">
              <button
                @click="closeDetailModal"
                class="px-6 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 dark:text-gray-300 font-medium rounded-lg transition-colors"
              >
                Fermer
              </button>
            </div>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Dropdown menu teleporté -->
    <Teleport to="body">
      <div 
        v-if="activeDropdown && dropdownPosition"
        class="fixed w-48 bg-white dark:bg-gray-800 rounded-lg shadow-xl border border-gray-200 dark:border-gray-700 z-[9999]"
        :style="{
          top: `${dropdownPosition.top}px`,
          left: `${dropdownPosition.left}px`
        }"
      >
        <button
          @click="openPointsModal(getCustomerById(activeDropdown))"
          class="w-full text-left px-4 py-2 hover:bg-gray-50 flex items-center space-x-2 text-sm rounded-t-lg"
        >
          <Settings :size="16" class="text-gray-500 dark:text-gray-400" />
          <span>Gérer les points</span>
        </button>
        <button
          @click="confirmDelete(getCustomerById(activeDropdown))"
          class="w-full text-left px-4 py-2 hover:bg-red-50 flex items-center space-x-2 text-sm text-red-600 rounded-b-lg"
        >
          <Trash2 :size="16" />
          <span>Supprimer le fidèle</span>
        </button>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { Search, Filter, Download, UserPlus, Star, Eye, Mail, MoreVertical, Settings, Trash2, Plus, Minus, Edit2, Copy, Check, Calendar, Phone, MapPin, Shield, X, User, TrendingUp, ShoppingCart, Gift } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'
import { getActiveProducts, purchaseProduct, adjustCustomerPoints } from '@/api/productsEndpoint'
import { recordScan } from '@/api/scanEndpoint'

interface Customer {
  id: string
  first_name: string
  last_name: string
  email: string
  phone?: string
  points: number
  created_at: string
  last_visit?: string
}

const searchQuery = ref('')
const customers = ref<Customer[]>([])
const loading = ref(true)
const currentPage = ref(1)
const itemsPerPage = 10
const filter = ref('all')

// Variables pour le dropdown et les modals
const activeDropdown = ref<string | null>(null)
const selectedCustomer = ref<Customer | null>(null)
const showPointsModal = ref(false)
const showDeleteModal = ref(false)
const showDetailModal = ref(false)
const dropdownPosition = ref<{ top: number; left: number } | null>(null)
const buttonRefs = ref<Record<string, HTMLElement>>({})

// Variables pour la gestion des points
const operationType = ref<'product' | 'admin' | 'bonus'>('admin')
const pointsOperation = ref<'add' | 'remove'>('add')
const pointsAmount = ref(0)
const pointsReason = ref('')
const updatingPoints = ref(false)

// Variables pour les produits
const availableProducts = ref<any[]>([])
const selectedProduct = ref<any>(null)
const productQuantity = ref(1)
const loadingProducts = ref(false)

// Variables pour les bonus
const bonusType = ref('welcome')

// Variable pour la suppression
const deleting = ref(false)

// Variables pour la modal détaillée
const editingField = ref<string | null>(null)
const editValue = ref('')
const generatingLink = ref(false)
const generatedLink = ref('')
const linkCopied = ref(false)
const customerDetails = ref<any>(null)
const loadingDetails = ref(false)

// Statistiques
const stats = ref({
  totalCustomers: 0,
  activeCustomers: 0,
  totalPoints: 0,
  retentionRate: 84,
  newThisMonth: 0,
  monthlyGrowth: 0
})

// Charger les données de l'entreprise et ses clients
const loadCustomers = async () => {
  try {
    loading.value = true
    
    // Récupérer l'utilisateur connecté
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return
    
    // Récupérer les données de l'entreprise
    const { data: userData } = await supabase
      .from('users')
      .select('id')
      .eq('auth_id', user.id)
      .single()
    
    if (!userData) return
    
    // Récupérer tous les clients de l'entreprise
    const { data: customersData, count } = await supabase
      .from('customers')
      .select('*', { count: 'exact' })
      .eq('company_id', userData.id)
      .order('created_at', { ascending: false })
    
    if (customersData) {
      customers.value = customersData
      stats.value.totalCustomers = count || 0
      
      // Calculer les statistiques
      calculateStats(customersData)
    }
  } catch (error) {
    console.error('Erreur lors du chargement des clients:', error)
  } finally {
    loading.value = false
  }
}

// Calculer les statistiques
const calculateStats = async (customersData: Customer[]) => {
  // Total des points
  stats.value.totalPoints = customersData.reduce((sum, c) => sum + (c.points || 0), 0)
  
  // Clients actifs (dernière visite < 30 jours)
  const thirtyDaysAgo = new Date()
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
  stats.value.activeCustomers = customersData.filter(c => {
    if (!c.last_visit) return false
    return new Date(c.last_visit) > thirtyDaysAgo
  }).length
  
  // Calculer les dates pour ce mois et le mois précédent
  const now = new Date()
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1)
  const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1)
  const endOfLastMonth = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59, 999)
  
  // Nouveaux ce mois
  stats.value.newThisMonth = customersData.filter(c => 
    new Date(c.created_at) >= startOfMonth
  ).length
  
  // Clients du mois précédent
  const lastMonthCustomers = customersData.filter(c => {
    const createdAt = new Date(c.created_at)
    return createdAt <= endOfLastMonth
  }).length
  
  // Calculer la croissance mensuelle
  if (lastMonthCustomers === 0) {
    // Si aucun client le mois dernier, croissance basée sur les nouveaux clients
    stats.value.monthlyGrowth = stats.value.newThisMonth > 0 ? 100 : 0
  } else {
    // Calcul normal : ((clients actuels - clients mois dernier) / clients mois dernier) * 100
    const growth = ((stats.value.totalCustomers - lastMonthCustomers) / lastMonthCustomers) * 100
    stats.value.monthlyGrowth = Math.round(growth)
  }
}

// Filtrer les clients
const filteredCustomers = computed(() => {
  let result = customers.value
  
  // Filtre par recherche
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(c => 
      `${c.first_name} ${c.last_name}`.toLowerCase().includes(query) ||
      c.email.toLowerCase().includes(query)
    )
  }
  
  // Filtre par statut
  if (filter.value === 'active') {
    const thirtyDaysAgo = new Date()
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
    result = result.filter(c => c.last_visit && new Date(c.last_visit) > thirtyDaysAgo)
  } else if (filter.value === 'inactive') {
    const thirtyDaysAgo = new Date()
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
    result = result.filter(c => !c.last_visit || new Date(c.last_visit) <= thirtyDaysAgo)
  } else if (filter.value === 'vip') {
    result = result.filter(c => c.points >= 500)
  }
  
  return result
})

// Pagination
const paginatedCustomers = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredCustomers.value.slice(start, end)
})

const totalPages = computed(() => 
  Math.ceil(filteredCustomers.value.length / itemsPerPage)
)

// Obtenir le statut du client
const getCustomerStatus = (customer: Customer) => {
  if (customer.points >= 500) return { label: 'VIP', class: 'bg-green-100 text-green-700' }
  if (customer.points >= 200) return { label: 'Régulier', class: 'bg-blue-100 text-blue-700' }
  return { label: 'Nouveau', class: 'bg-gray-100 text-gray-700 dark:text-gray-300' }
}

// Obtenir les initiales du client
const getInitials = (customer: Customer) => {
  const first = customer.first_name?.charAt(0) || ''
  const last = customer.last_name?.charAt(0) || ''
  return (first + last).toUpperCase() || '??'
}

// Formater la date de dernière visite
const formatLastVisit = (date: string | undefined) => {
  if (!date) return 'Jamais'
  
  const visitDate = new Date(date)
  const now = new Date()
  const diffTime = Math.abs(now.getTime() - visitDate.getTime())
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))
  
  if (diffDays === 0) return "Aujourd'hui"
  if (diffDays === 1) return 'Hier'
  if (diffDays < 7) return `Il y a ${diffDays} jours`
  if (diffDays < 30) return `Il y a ${Math.floor(diffDays / 7)} semaine(s)`
  return `Il y a ${Math.floor(diffDays / 30)} mois`
}

// Obtenir la couleur de fond pour les initiales
const getInitialsColor = (index: number) => {
  const colors = ['bg-violet-100', 'bg-pink-100', 'bg-green-100', 'bg-blue-100', 'bg-yellow-100']
  return colors[index % colors.length]
}

// Obtenir la couleur de texte pour les initiales
const getInitialsTextColor = (index: number) => {
  const colors = ['text-violet-600', 'text-pink-600', 'text-green-600', 'text-blue-600', 'text-yellow-600']
  return colors[index % colors.length]
}

// Set button ref
const setButtonRef = (customerId: string, el: HTMLElement | null) => {
  if (el) {
    buttonRefs.value[customerId] = el
  }
}

// Get customer by ID
const getCustomerById = (customerId: string | null) => {
  if (!customerId) return null
  return customers.value.find(c => c.id === customerId) || null
}

// Toggle dropdown menu
const toggleDropdown = (customerId: string) => {
  if (activeDropdown.value === customerId) {
    activeDropdown.value = null
    dropdownPosition.value = null
  } else {
    activeDropdown.value = customerId
    // Calculer la position du dropdown
    const button = buttonRefs.value[customerId]
    if (button) {
      const rect = button.getBoundingClientRect()
      dropdownPosition.value = {
        top: rect.top - 100, // Positionner au-dessus du bouton
        left: rect.left - 150 // Décaler à gauche pour aligner à droite
      }
    }
  }
}

// Voir le profil du client
const viewCustomer = async (customer: Customer) => {
  selectedCustomer.value = customer
  showDetailModal.value = true
  loadingDetails.value = true
  
  try {
    // Charger les détails complets du client
    const { data } = await supabase
      .from('customers')
      .select('*')
      .eq('id', customer.id)
      .single()
    
    if (data) {
      customerDetails.value = data
      
      // Calculer les totaux depuis l'historique des points
      await calculatePointsTotals(customer.id, data.company_id)
    }
  } catch (error) {
    console.error('Erreur lors du chargement des détails:', error)
  } finally {
    loadingDetails.value = false
  }
}

// Calculer les totaux de points gagnés et dépensés
const calculatePointsTotals = async (customerId: string, companyId: string) => {
  try {
    // Récupérer tout l'historique des points
    const { data: history } = await supabase
      .from('points_history')
      .select('points_amount, transaction_type')
      .eq('customer_id', customerId)
      .eq('company_id', companyId)
    
    if (history && customerDetails.value) {
      let totalEarned = 0
      let totalSpent = 0
      
      history.forEach(transaction => {
        // Points gagnés (welcome, earned, admin_add)
        if (transaction.transaction_type === 'welcome' || 
            transaction.transaction_type === 'earned' || 
            transaction.transaction_type === 'admin_add') {
          totalEarned += Math.abs(transaction.points_amount)
        } 
        // Points dépensés (spent, admin_remove)
        else if (transaction.transaction_type === 'spent' || 
                 transaction.transaction_type === 'admin_remove') {
          totalSpent += Math.abs(transaction.points_amount)
        }
      })
      
      // Mettre à jour les totaux dans customerDetails
      customerDetails.value.total_points_earned = totalEarned
      customerDetails.value.total_points_spent = totalSpent
    }
  } catch (error) {
    console.error('Erreur lors du calcul des totaux:', error)
    // En cas d'erreur, utiliser les valeurs par défaut
    if (customerDetails.value) {
      customerDetails.value.total_points_earned = 0
      customerDetails.value.total_points_spent = 0
    }
  }
}

// Envoyer un email
const sendEmail = (customer: Customer) => {
  window.location.href = `mailto:${customer.email}`
}

// Ouvrir la modal de gestion des points
const openPointsModal = async (customer: Customer | null) => {
  if (!customer) return
  selectedCustomer.value = customer
  showPointsModal.value = true
  activeDropdown.value = null
  dropdownPosition.value = null
  operationType.value = 'admin'
  pointsOperation.value = 'add'
  pointsAmount.value = 0
  pointsReason.value = ''
  selectedProduct.value = null
  productQuantity.value = 1
  bonusType.value = 'welcome'
  
  // Charger les produits disponibles
  await loadProducts()
}

// Fermer la modal de gestion des points
const closePointsModal = () => {
  showPointsModal.value = false
  selectedCustomer.value = null
  operationType.value = 'admin'
  pointsOperation.value = 'add'
  pointsAmount.value = 0
  pointsReason.value = ''
  selectedProduct.value = null
  productQuantity.value = 1
  bonusType.value = 'welcome'
}

// Sélectionner le type d'opération
const selectOperationType = (type: 'product' | 'admin' | 'bonus') => {
  operationType.value = type
  selectedProduct.value = null
  pointsAmount.value = 0
}

// Charger les produits disponibles
const loadProducts = async () => {
  loadingProducts.value = true
  try {
    availableProducts.value = await getActiveProducts()
  } catch (error) {
    console.error('Erreur chargement produits:', error)
  } finally {
    loadingProducts.value = false
  }
}

// Sélectionner un produit
const selectProduct = (product: any) => {
  selectedProduct.value = product
  productQuantity.value = 1
}

// Calculer le nouveau solde
const calculateNewBalance = () => {
  if (!selectedCustomer.value) return 0
  
  if (operationType.value === 'product' && selectedProduct.value) {
    return Math.max(0, selectedCustomer.value.points - (selectedProduct.value.points * productQuantity.value))
  }
  
  if (operationType.value === 'admin') {
    return pointsOperation.value === 'add'
      ? selectedCustomer.value.points + (pointsAmount.value || 0)
      : Math.max(0, selectedCustomer.value.points - (pointsAmount.value || 0))
  }
  
  if (operationType.value === 'bonus') {
    const bonusPoints = {
      welcome: 50,
      birthday: 100,
      referral: 75,
      special: 25
    }
    return selectedCustomer.value.points + (bonusPoints[bonusType.value as keyof typeof bonusPoints] || 0)
  }
  
  return selectedCustomer.value.points
}

// Mettre à jour les points
const updatePoints = async () => {
  if (!selectedCustomer.value) return
  
  // Vérifier selon le type d'opération
  if (operationType.value === 'product' && !selectedProduct.value) return
  if (operationType.value === 'admin' && !pointsAmount.value) return
  
  updatingPoints.value = true
  
  try {
    let result = { success: false, message: '', newPoints: 0 }
    
    // Traiter selon le type d'opération
    if (operationType.value === 'product') {
      // Achat de produit
      result = await purchaseProduct({
        customer_id: selectedCustomer.value.id,
        product_id: selectedProduct.value.id,
        quantity: productQuantity.value
      })
      
      // Enregistrer le scan
      await recordScan({
        customerId: selectedCustomer.value.id,
        scanType: 'points_add',
        pointsAdded: -(selectedProduct.value.points * productQuantity.value),
        euroAmount: selectedProduct.value.price * productQuantity.value,
        location: `Achat: ${selectedProduct.value.name}`
      })
      
    } else if (operationType.value === 'admin') {
      // Modification admin
      const points = pointsOperation.value === 'add' ? pointsAmount.value : -pointsAmount.value
      result = await adjustCustomerPoints(
        selectedCustomer.value.id,
        points,
        pointsReason.value || 'Ajustement administrateur'
      )
      
    } else if (operationType.value === 'bonus') {
      // Bonus
      const bonusPoints = {
        welcome: 50,
        birthday: 100,
        referral: 75,
        special: 25
      }
      const points = bonusPoints[bonusType.value as keyof typeof bonusPoints] || 0
      const bonusLabels = {
        welcome: 'Bonus de bienvenue',
        birthday: 'Bonus anniversaire',
        referral: 'Bonus parrainage',
        special: 'Événement spécial'
      }
      
      result = await adjustCustomerPoints(
        selectedCustomer.value.id,
        points,
        bonusLabels[bonusType.value as keyof typeof bonusLabels] || 'Bonus'
      )
    }
    
    if (result.success) {
      // Mettre à jour l'affichage
      selectedCustomer.value.points = result.newPoints || calculateNewBalance()
      
      // Mettre à jour dans la liste
      const index = customers.value.findIndex(c => c.id === selectedCustomer.value?.id)
      if (index !== -1) {
        customers.value[index].points = selectedCustomer.value.points
      }
      
      // Fermer la modal
      closePointsModal()
      
      // Message de succès
      alert(result.message || 'Points mis à jour avec succès')
    } else {
      alert(result.message || 'Erreur lors de la mise à jour')
    }
  } catch (error) {
    console.error('Erreur:', error)
    alert('Une erreur est survenue')
  } finally {
    updatingPoints.value = false
  }
}

// Confirmer la suppression
const confirmDelete = (customer: Customer | null) => {
  if (!customer) return
  selectedCustomer.value = customer
  showDeleteModal.value = true
  activeDropdown.value = null
  dropdownPosition.value = null
}

// Supprimer le client
const deleteCustomer = async () => {
  if (!selectedCustomer.value) return
  
  deleting.value = true
  
  try {
    const { error } = await supabase
      .from('customers')
      .delete()
      .eq('id', selectedCustomer.value.id)
    
    if (error) {
      console.error('Erreur lors de la suppression:', error)
      alert('Erreur lors de la suppression du client')
    } else {
      // Retirer le client de la liste locale
      customers.value = customers.value.filter(c => c.id !== selectedCustomer.value!.id)
      
      // Recalculer les statistiques
      stats.value.totalCustomers = customers.value.length
      calculateStats(customers.value)
      
      // Fermer la modal
      showDeleteModal.value = false
      selectedCustomer.value = null
      
      console.log('Client supprimé avec succès')
    }
  } catch (error) {
    console.error('Erreur:', error)
    alert('Une erreur est survenue')
  } finally {
    deleting.value = false
  }
}

// Commencer l'édition d'un champ
const startEditing = (field: string) => {
  editingField.value = field
  editValue.value = customerDetails.value[field] || ''
}

// Annuler l'édition
const cancelEditing = () => {
  editingField.value = null
  editValue.value = ''
  generatedLink.value = ''
  linkCopied.value = false
}

// Sauvegarder la modification directe (pour les champs non sensibles)
const saveDirectEdit = async (field: string) => {
  if (!customerDetails.value || !editValue.value) return
  
  try {
    const { error } = await supabase
      .from('customers')
      .update({ [field]: editValue.value })
      .eq('id', customerDetails.value.id)
    
    if (!error) {
      customerDetails.value[field] = editValue.value
      // Mettre à jour aussi dans la liste principale
      const customerIndex = customers.value.findIndex(c => c.id === customerDetails.value.id)
      if (customerIndex !== -1) {
        const customer = customers.value[customerIndex]
        if (customer && field in customer) {
          (customer as any)[field] = editValue.value
        }
      }
      cancelEditing()
      
      // Si on a modifié les points, recalculer les statistiques
      if (field === 'points') {
        await calculatePointsTotals(customerDetails.value.id, customerDetails.value.company_id)
      }
    }
  } catch (error) {
    console.error('Erreur lors de la modification:', error)
  }
}

// Générer un lien sécurisé pour modification sensible
const generateSecureLink = async (field: string) => {
  if (!customerDetails.value || !editValue.value) return
  
  generatingLink.value = true
  
  try {
    // Obtenir l'ID de l'entreprise
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('Utilisateur non connecté')
    
    const { data: userData } = await supabase
      .from('users')
      .select('id')
      .eq('auth_id', user.id)
      .single()
    
    if (!userData) throw new Error('Données entreprise non trouvées')
    
    // Générer un token unique
    const token = crypto.randomUUID() + Date.now().toString(36)
    
    // Créer l'enregistrement du token
    const { data: tokenData, error } = await supabase
      .from('modification_tokens')
      .insert({
        customer_id: customerDetails.value.id,
        company_id: userData.id,
        token: token,
        field_to_modify: field,
        new_value: editValue.value,
        old_value: customerDetails.value[field],
        created_by: userData.id
      })
      .select()
      .single()
    
    if (!error && tokenData) {
      // Générer le lien
      const baseUrl = window.location.origin
      generatedLink.value = `${baseUrl}/modify-customer?token=${token}`
      
      // Envoyer l'email au client (si c'est une modification d'email)
      if (field === 'email') {
        console.log('Email envoyé à:', customerDetails.value.email)
        console.log('Lien de modification:', generatedLink.value)
      }
    }
  } catch (error) {
    console.error('Erreur lors de la génération du lien:', error)
  } finally {
    generatingLink.value = false
  }
}

// Copier le lien dans le presse-papier
const copyLink = async () => {
  if (!generatedLink.value) return
  
  try {
    await navigator.clipboard.writeText(generatedLink.value)
    linkCopied.value = true
    setTimeout(() => {
      linkCopied.value = false
    }, 2000)
  } catch (error) {
    console.error('Erreur lors de la copie:', error)
  }
}

// Formater les dates
const formatDate = (dateString: string | null) => {
  if (!dateString) return 'Non renseigné'
  const date = new Date(dateString)
  return date.toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  })
}

// Fermer la modal de détail
const closeDetailModal = () => {
  showDetailModal.value = false
  selectedCustomer.value = null
  customerDetails.value = null
  cancelEditing()
}

// Fermer les dropdowns quand on clique ailleurs
onMounted(() => {
  loadCustomers()
  
  // Fermer le dropdown quand on clique ailleurs
  document.addEventListener('click', (e) => {
    const target = e.target as HTMLElement
    // Vérifier si le clic n'est pas sur un bouton de menu ou le dropdown lui-même
    if (!target.closest('[title="Plus d\'options"]') && !target.closest('.fixed.w-48')) {
      activeDropdown.value = null
      dropdownPosition.value = null
    }
  })
})
</script>