<template>
  <div class="min-h-screen bg-gradient-to-br from-violet-50 via-white to-pink-50">
    <!-- Header simplifié -->
    <header class="bg-white/80 backdrop-blur-md border-b border-gray-100 sticky top-0 z-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center space-x-3">
            <!-- Logo de l'entreprise -->
            <div v-if="companyData.logo_url" class="w-10 h-10 rounded-lg overflow-hidden">
              <img :src="companyData.logo_url" alt="Logo" class="w-full h-full object-cover" />
            </div>
            <div v-else class="w-10 h-10 bg-gradient-to-r from-violet-600 to-pink-600 rounded-lg flex items-center justify-center">
              <Building2 :size="20" class="text-white" />
            </div>
            <div>
              <h1 class="text-xl font-bold text-gray-900">{{ companyData.name || 'FidApp' }}</h1>
              <p class="text-xs text-gray-500">Programme de fidélité</p>
            </div>
          </div>
          
          <!-- Boutons selon le type d'utilisateur -->
          <div class="flex items-center space-x-4">
            <!-- Bouton Mon profil pour les clients -->
            <button 
              v-if="!isOwner && isLoggedIn"
              @click="showProfileModal = true"
              class="text-sm text-violet-600 hover:text-violet-700 font-medium flex items-center space-x-1"
            >
              <User :size="16" />
              <span>Mon profil</span>
            </button>
            
            <!-- Bouton déconnexion pour les clients -->
            <button 
              v-if="!isOwner && isLoggedIn"
              @click="handleLogout"
              class="text-sm text-gray-500 hover:text-gray-700 font-medium flex items-center space-x-1"
            >
              <LogOut :size="16" />
              <span>Déconnexion</span>
            </button>
            
            <!-- Bouton retour dashboard pour les propriétaires -->
            <router-link 
              v-if="isOwner"
              to="/dashboard"
              class="text-sm text-violet-600 hover:text-violet-700 font-medium flex items-center space-x-1"
            >
              <ArrowLeft :size="16" />
              <span>Retour au dashboard</span>
            </router-link>
          </div>
        </div>
      </div>
    </header>

    <div class="max-w-4xl mx-auto px-4 py-8">
      <!-- Carte de fidélité -->
      <div class="mb-8">
        <div 
          class="relative h-64 rounded-2xl shadow-2xl overflow-hidden"
          :class="companyData.card_theme !== 'custom' ? cardGradient : ''"
        >
          <!-- Fond personnalisé si type custom -->
          <div v-if="companyData.card_theme === 'custom' && companyData.card_background_url" 
               class="absolute inset-0">
            <img 
              :src="companyData.card_background_url" 
              alt="" 
              class="w-full h-full object-cover"
            />
          </div>
          <!-- Fond dégradé si type gradient -->
          <div v-else class="absolute inset-0" :class="cardGradient"></div>
          
          <div class="absolute inset-0 bg-black/10"></div>
          <div class="relative h-full p-6 flex flex-col justify-between text-white">
            <!-- En-tête de la carte -->
            <div class="flex items-start justify-between">
              <div>
                <h2 class="text-2xl font-black">{{ companyData.name || 'Votre Entreprise' }}</h2>
                <p class="text-white/80 text-sm mt-1">Carte de fidélité</p>
              </div>
              <!-- Logo sur la carte -->
              <div v-if="companyData.logo_url" 
                   class="w-12 h-12 bg-white rounded-lg overflow-hidden shadow-lg">
                <img 
                  :src="companyData.logo_url" 
                  alt="Logo"
                  class="w-full h-full object-cover"
                />
              </div>
            </div>
            
            <!-- Points du client -->
            <div class="flex-1">
              <div v-if="showPoints && isLoggedIn && !isOwner" class="space-y-2">
                <div class="flex items-center space-x-2">
                  <Star :size="20" class="text-yellow-400 fill-current" />
                  <span class="text-2xl font-bold">{{ customerPoints }} pts</span>
                </div>
                <p class="text-white/80 text-sm">{{ customerName }}</p>
              </div>
              <div v-else-if="!isOwner && !isLoggedIn">
                <p class="text-white/80 text-sm">Connectez-vous pour voir vos points</p>
              </div>
            </div>
            
            <!-- Info membre et code de fidélité -->
            <div class="space-y-2">
              <div v-if="isLoggedIn && !isOwner && customerLoyaltyCode" class="bg-white/20 backdrop-blur-md rounded-lg px-3 py-2 border border-white/30">
                <p class="text-xs text-white/90 font-medium mb-1">Code de fidélité</p>
                <p class="text-sm font-mono font-bold text-white tracking-wider">{{ formattedLoyaltyCode }}</p>
              </div>
              <div>
                <p class="text-xs text-white/60">{{ isLoggedIn && !isOwner ? 'Membre depuis' : 'Programme de fidélité' }}</p>
                <p class="text-sm font-medium text-white">{{ isLoggedIn && !isOwner ? memberSince : 'Rejoignez-nous !' }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Section QR Code de fidélité - Visible uniquement si l'option est activée -->
      <div v-if="isLoggedIn && !isOwner && customerLoyaltyCode && customerId && showQRInCard" class="mb-8">
        <CustomerQRCode
          :loyalty-code="customerLoyaltyCode"
          :customer-id="customerId"
          :company-id="companyId || ''"
          :customer-name="customerName"
          :company-name="companyData.name"
        />
      </div>

      <!-- Section Apple Wallet -->
      <div v-if="isLoggedIn && !isOwner" class="bg-white rounded-2xl shadow-lg p-6 mb-8">
        <h3 class="text-xl font-bold text-gray-900 mb-4 flex items-center space-x-2">
          <Smartphone :size="24" class="text-violet-600" />
          <span>Ajouter à Apple Wallet</span>
        </h3>
        <p class="text-gray-600 mb-4">
          Ajoutez votre carte de fidélité à Apple Wallet pour un accès rapide et recevoir des notifications de mise à jour de vos points.
        </p>
        <AppleWalletButton
          v-if="customerId && companyId"
          :customer-id="customerId"
          :company-id="companyId"
          :qr-code-value="qrCodeValue"
          :show-instructions="true"
          @added="handleWalletAdded"
          @error="handleWalletError"
        />
      </div>

      <!-- Section Offres et Récompenses disponibles - Design amélioré -->
      <div class="mb-8">
        <!-- En-tête de section avec gradient -->
        <div class="bg-gradient-to-r from-violet-600 to-pink-600 rounded-t-2xl p-6 text-white">
          <h3 class="text-2xl font-black flex items-center gap-3">
            <div class="p-2 bg-white/20 backdrop-blur rounded-lg">
              <Gift :size="28" />
            </div>
            Catalogue des récompenses
          </h3>
          <p class="mt-2 text-white/90">Échangez vos points contre des avantages exclusifs</p>
        </div>
        
        <!-- Contenu avec fond blanc -->
        <div class="bg-white rounded-b-2xl shadow-xl p-6">
          <div v-if="loading" class="flex justify-center py-12">
            <Loader2 :size="40" class="text-violet-600 animate-spin" />
          </div>
          
          <div v-else-if="rewards.length === 0 && offers.length === 0" class="text-center py-12">
            <div class="w-24 h-24 bg-gradient-to-br from-violet-100 to-pink-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Gift :size="40" class="text-violet-400" />
            </div>
            <p class="text-gray-500 text-lg">Aucune offre disponible pour le moment</p>
            <p class="text-gray-400 text-sm mt-2">Revenez bientôt pour découvrir nos nouvelles récompenses !</p>
          </div>
          
          <div v-else>
            <!-- Offres spéciales en cartes visuelles -->
            <div v-if="offers.length > 0" class="mb-8">
              <div class="flex items-center gap-2 mb-4">
                <div class="w-2 h-8 bg-gradient-to-b from-violet-600 to-pink-600 rounded-full"></div>
                <h4 class="text-xl font-bold text-gray-800">Offres exclusives</h4>
                <span class="ml-2 px-3 py-1 bg-gradient-to-r from-violet-100 to-pink-100 text-violet-700 text-xs font-bold rounded-full animate-pulse">
                  LIMITÉES
                </span>
              </div>
              
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <div 
                  v-for="offer in offers" 
                  :key="offer.id"
                  class="group relative bg-white rounded-2xl shadow-md hover:shadow-2xl transition-all duration-300 overflow-hidden"
                  :class="{ 'grayscale opacity-75': customerPoints < offer.points_cost }"
                >
                  <!-- Image ou gradient d'en-tête -->
                  <div class="relative h-32 overflow-hidden">
                    <div 
                      v-if="offer.image_url"
                      class="absolute inset-0"
                    >
                      <img 
                        :src="offer.image_url" 
                        alt="" 
                        class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                      />
                      <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
                    </div>
                    <div 
                      v-else
                      :class="getOfferGradient(offer.type)"
                      class="absolute inset-0 bg-gradient-to-br"
                    >
                      <div class="absolute inset-0 bg-black/20"></div>
                    </div>
                    
                    <!-- Badge type d'offre -->
                    <div class="absolute top-3 left-3">
                      <span :class="getOfferBadgeClass(offer.type)" class="px-3 py-1 text-xs font-bold rounded-full backdrop-blur shadow-lg">
                        {{ getOfferTypeLabel(offer.type).toUpperCase() }}
                      </span>
                    </div>
                    
                    <!-- Valeur de l'offre en grand -->
                    <div class="absolute bottom-3 right-3">
                      <div v-if="offer.type === 'discount' && offer.value" class="text-3xl font-black text-white drop-shadow-lg">
                        -{{ offer.value }}%
                      </div>
                      <div v-else-if="offer.type === 'points' && offer.value" class="flex items-center gap-1">
                        <Star class="w-6 h-6 text-yellow-400 fill-current drop-shadow" />
                        <span class="text-2xl font-black text-white drop-shadow-lg">+{{ offer.value }}</span>
                      </div>
                    </div>
                  </div>
                  
                  <!-- Contenu de la carte -->
                  <div class="p-5">
                    <h4 class="font-black text-lg text-gray-900 mb-2 line-clamp-1">{{ offer.name }}</h4>
                    <p class="text-sm text-gray-600 mb-4 line-clamp-2 min-h-[40px]">{{ offer.description || 'Offre spéciale à durée limitée' }}</p>
                    
                    <!-- Points requis avec indicateur visuel -->
                    <div class="mb-4">
                      <div class="flex items-center justify-between mb-2">
                        <span class="text-xs text-gray-500 font-medium">Points requis</span>
                        <div class="flex items-center gap-1">
                          <Star :size="14" class="text-violet-500 fill-current" />
                          <span class="font-black text-violet-600">{{ offer.points_cost }}</span>
                        </div>
                      </div>
                      <!-- Barre de progression -->
                      <div class="w-full h-2 bg-gray-100 rounded-full overflow-hidden">
                        <div 
                          class="h-full bg-gradient-to-r from-violet-500 to-pink-500 rounded-full transition-all duration-500"
                          :style="`width: ${Math.min((customerPoints / offer.points_cost) * 100, 100)}%`"
                        ></div>
                      </div>
                      <div v-if="customerPoints < offer.points_cost" class="text-xs text-gray-500 mt-1">
                        Il vous manque {{ offer.points_cost - customerPoints }} points
                      </div>
                    </div>
                    
                    <!-- Bouton d'échange -->
                    <button 
                      v-if="customerPoints >= offer.points_cost"
                      @click="redeemOffer(offer)"
                      class="w-full py-3 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold rounded-xl hover:shadow-lg transform hover:scale-[1.02] transition-all duration-200 flex items-center justify-center gap-2"
                    >
                      <span>Échanger maintenant</span>
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
                      </svg>
                    </button>
                    <button 
                      v-else
                      disabled
                      class="w-full py-3 bg-gray-100 text-gray-400 font-bold rounded-xl cursor-not-allowed flex items-center justify-center gap-2"
                    >
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                      </svg>
                      <span>Points insuffisants</span>
                    </button>
                    
                    <!-- Conditions si présentes -->
                    <div v-if="offer.conditions" class="mt-3 pt-3 border-t border-gray-100">
                      <p class="text-xs text-gray-500 italic">{{ offer.conditions }}</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- Récompenses classiques avec nouveau design -->
            <div v-if="filteredRewards.length > 0">
              <div class="flex items-center gap-2 mb-4">
                <div class="w-2 h-8 bg-gradient-to-b from-yellow-500 to-orange-500 rounded-full"></div>
                <h4 class="text-xl font-bold text-gray-800">Récompenses fidélité</h4>
              </div>
              
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div 
                  v-for="reward in filteredRewards" 
                  :key="reward.id"
                  class="group bg-white border-2 border-gray-100 rounded-xl p-5 hover:border-violet-200 hover:shadow-lg transition-all duration-300"
                  :class="{ 'opacity-60 grayscale': customerPoints < reward.points_required }"
                >
                  <div class="flex items-start gap-4">
                    <!-- Icône de récompense -->
                    <div class="flex-shrink-0">
                      <div class="w-14 h-14 bg-gradient-to-br from-yellow-100 to-orange-100 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform">
                        <Award :size="24" class="text-orange-500" />
                      </div>
                    </div>
                    
                    <!-- Contenu -->
                    <div class="flex-1">
                      <h5 class="font-bold text-gray-900 mb-1">{{ reward.name }}</h5>
                      <p class="text-sm text-gray-600 mb-3">{{ reward.description }}</p>
                      
                      <!-- Points et valeur -->
                      <div class="flex items-center gap-3 mb-3">
                        <div class="flex items-center gap-1">
                          <Star :size="14" class="text-yellow-500 fill-current" />
                          <span class="font-bold text-sm text-gray-700">{{ reward.points_required }} pts</span>
                        </div>
                        
                        <div v-if="reward.discount_percentage" class="px-2 py-0.5 bg-green-100 text-green-700 text-xs font-bold rounded">
                          -{{ reward.discount_percentage }}%
                        </div>
                        
                        <div v-if="reward.discount_amount" class="px-2 py-0.5 bg-green-100 text-green-700 text-xs font-bold rounded">
                          -{{ reward.discount_amount }}€
                        </div>
                      </div>
                      
                      <!-- Bouton d'action -->
                      <button 
                        v-if="customerPoints >= reward.points_required"
                        @click="redeemReward(reward)"
                        class="px-4 py-2 bg-gradient-to-r from-yellow-500 to-orange-500 text-white text-sm font-bold rounded-lg hover:shadow-md transform hover:scale-105 transition-all"
                      >
                        Obtenir
                      </button>
                      <div 
                        v-else 
                        class="inline-flex items-center gap-1 text-xs text-gray-500"
                      >
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                        </svg>
                        <span>{{ reward.points_required - customerPoints }} pts manquants</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Section Historique -->
      <div class="bg-white rounded-2xl shadow-lg p-6">
        <h3 class="text-xl font-bold text-gray-900 mb-4 flex items-center space-x-2">
          <Clock :size="24" class="text-violet-600" />
          <span>Historique des points</span>
        </h3>
        
        <div v-if="loadingHistory" class="flex justify-center py-8">
          <Loader2 :size="32" class="text-violet-600 animate-spin" />
        </div>
        
        <div v-else-if="pointsHistory.length === 0" class="text-center py-8">
          <Clock :size="48" class="mx-auto text-gray-300 mb-3" />
          <p class="text-gray-500">Aucun historique disponible</p>
        </div>
        
        <div v-else class="space-y-3">
          <div 
            v-for="transaction in pointsHistory" 
            :key="transaction.id"
            class="flex items-center justify-between py-3 border-b border-gray-100 last:border-b-0"
          >
            <div class="flex items-center space-x-3">
              <div 
                class="w-10 h-10 rounded-full flex items-center justify-center"
                :class="getTransactionColor(transaction.transaction_type)"
              >
                <component :is="getTransactionIcon(transaction.transaction_type)" :size="20" />
              </div>
              <div>
                <p class="font-medium text-gray-900">{{ getTransactionLabel(transaction.transaction_type) }}</p>
                <p class="text-sm text-gray-500">{{ formatTransactionDate(transaction.created_at) }}</p>
                <p v-if="transaction.description" class="text-xs text-gray-400 mt-1">{{ transaction.description }}</p>
              </div>
            </div>
            <div class="text-right">
              <span 
                class="font-bold"
                :class="transaction.points_amount > 0 ? 'text-green-600' : 'text-red-600'"
              >
                {{ transaction.points_amount > 0 ? '+' : '' }}{{ transaction.points_amount }} pts
              </span>
              <p class="text-xs text-gray-400 mt-1">Solde: {{ transaction.points_after }} pts</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de confirmation d'échange -->
    <Teleport to="body">
      <Transition
        enter-active-class="duration-200 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="duration-150 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showRedeemModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div class="absolute inset-0 bg-black/50" @click="showRedeemModal = false"></div>
          
          <div class="relative bg-white rounded-2xl shadow-2xl p-8 max-w-md w-full">
            <div class="text-center">
              <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle :size="32" class="text-green-600" />
              </div>
              <h3 class="text-2xl font-bold text-gray-900 mb-2">Récompense échangée !</h3>
              <p class="text-gray-600 mb-6">
                Votre récompense "{{ selectedReward?.name }}" a été ajoutée à votre compte.
              </p>
              <button 
                @click="showRedeemModal = false"
                class="bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold px-8 py-3 rounded-full hover:scale-105 transition-all duration-300"
              >
                Fermer
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
    
    <!-- Modal Profil Client -->
    <Teleport to="body">
      <Transition
        enter-active-class="duration-200 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="duration-150 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showProfileModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div class="absolute inset-0 bg-black/50" @click="showProfileModal = false"></div>
          
          <div class="relative bg-white rounded-2xl shadow-2xl p-8 max-w-md w-full max-h-[90vh] overflow-y-auto">
            <!-- Header du modal -->
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-2xl font-bold text-gray-900">Mon profil</h3>
              <button 
                @click="showProfileModal = false"
                class="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <X :size="24" />
              </button>
            </div>
            
            <!-- Message de succès/erreur -->
            <div v-if="profileMessage" 
                 :class="profileMessageType === 'success' ? 'bg-green-50 text-green-700 border-green-200' : 'bg-red-50 text-red-700 border-red-200'"
                 class="p-3 rounded-lg border mb-4 text-sm">
              {{ profileMessage }}
            </div>
            
            <!-- Formulaire de profil -->
            <form @submit.prevent="updateProfile" class="space-y-4">
              <!-- Prénom -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Prénom</label>
                <input
                  v-model="profileData.first_name"
                  type="text"
                  class="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-violet-500"
                  required
                />
              </div>
              
              <!-- Nom -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Nom</label>
                <input
                  v-model="profileData.last_name"
                  type="text"
                  class="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-violet-500"
                  required
                />
              </div>
              
              <!-- Email -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Email</label>
                <input
                  v-model="profileData.email"
                  type="email"
                  class="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-violet-500"
                  required
                />
              </div>
              
              <!-- Téléphone -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Téléphone</label>
                <input
                  v-model="profileData.phone"
                  type="tel"
                  class="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-violet-500"
                  placeholder="06 12 34 56 78"
                />
              </div>
              
              <!-- Date de naissance -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-1">Date de naissance</label>
                <input
                  v-model="profileData.date_of_birth"
                  type="date"
                  class="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-violet-500"
                />
              </div>
              
              <!-- Préférences de communication -->
              <div class="pt-4 border-t border-gray-200">
                <h4 class="font-semibold text-gray-700 mb-3">Préférences de communication</h4>
                <div class="space-y-3">
                  <label class="flex items-start space-x-3 cursor-pointer">
                    <input
                      v-model="profileData.accept_marketing"
                      type="checkbox"
                      class="w-5 h-5 mt-0.5 text-violet-600 border-2 border-gray-300 rounded focus:ring-violet-500 focus:ring-2"
                    />
                    <div>
                      <span class="text-sm font-medium text-gray-700">
                        Recevoir les offres et actualités
                      </span>
                      <p class="text-xs text-gray-500 mt-1">
                        Restez informé des nouvelles récompenses et promotions exclusives
                      </p>
                    </div>
                  </label>
                  
                  <label class="flex items-start space-x-3 cursor-pointer">
                    <input
                      v-model="profileData.accept_partners"
                      type="checkbox"
                      class="w-5 h-5 mt-0.5 text-violet-600 border-2 border-gray-300 rounded focus:ring-violet-500 focus:ring-2"
                    />
                    <div>
                      <span class="text-sm font-medium text-gray-700">
                        Offres partenaires
                      </span>
                      <p class="text-xs text-gray-500 mt-1">
                        Recevoir des offres sélectionnées de nos partenaires
                      </p>
                    </div>
                  </label>
                </div>
              </div>
              
              <!-- Informations de fidélité (lecture seule) -->
              <div class="pt-4 border-t border-gray-200">
                <h4 class="font-semibold text-gray-700 mb-3">Informations de fidélité</h4>
                <div class="space-y-2 text-sm">
                  <div class="flex justify-between">
                    <span class="text-gray-600">Points actuels</span>
                    <span class="font-bold text-violet-600">{{ customerPoints }} pts</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-600">Total gagné</span>
                    <span class="font-medium">{{ profileData.total_points_earned || 0 }} pts</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-600">Total dépensé</span>
                    <span class="font-medium">{{ profileData.total_points_spent || 0 }} pts</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-600">Membre depuis</span>
                    <span class="font-medium">{{ memberSince }}</span>
                  </div>
                </div>
              </div>
              
              <!-- Boutons -->
              <div class="flex space-x-3 pt-4">
                <button
                  type="button"
                  @click="showProfileModal = false"
                  class="flex-1 py-2 px-4 bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold rounded-lg transition-colors"
                >
                  Annuler
                </button>
                <button
                  type="submit"
                  :disabled="savingProfile"
                  class="flex-1 py-2 px-4 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-semibold rounded-lg hover:scale-105 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
                >
                  <Save :size="18" />
                  <span>{{ savingProfile ? 'Enregistrement...' : 'Enregistrer' }}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Building2, Star, Gift, Clock, Plus, Minus, TrendingUp, UserPlus, Settings, ArrowLeft, Loader2, CheckCircle, User, LogOut, X, Save, Smartphone, Tag, Award } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'
import { recordScan } from '@/api/scanEndpoint'
import AppleWalletButton from '@/components/ui/AppleWalletButton.vue'
import CustomerQRCode from '@/components/CustomerQRCode.vue'

const router = useRouter()

interface Reward {
  id: string
  name: string
  description: string
  points_required: number
  discount_percentage?: number
  discount_amount?: number
  is_active: boolean
  category: string
}

interface CompanyData {
  name: string
  logo_url: string | null
  card_settings?: any
  qr_code_id?: string
  card_theme?: 'gradient' | 'custom'
  card_background_url?: string | null
  card_gradient?: string
}

interface PointsHistory {
  id: string
  points_amount: number
  points_before: number
  points_after: number
  transaction_type: 'welcome' | 'admin_add' | 'admin_remove' | 'earned' | 'spent'
  description: string | null
  created_at: string
}

const rewards = ref<Reward[]>([])
const offers = ref<any[]>([])
const companyData = ref<CompanyData>({
  name: '',
  logo_url: null,
  card_settings: null,
  qr_code_id: '',
  card_theme: 'gradient',
  card_background_url: null,
  card_gradient: 'from-violet-600 to-pink-600'
})
const pointsHistory = ref<PointsHistory[]>([])
const loading = ref(true)
const loadingHistory = ref(false)
const isOwner = ref(false)
const isAuthenticated = ref(false)
const isLoggedIn = ref(false)
const showRedeemModal = ref(false)
const selectedReward = ref<Reward | null>(null)
const showProfileModal = ref(false)
const savingProfile = ref(false)
const profileMessage = ref('')
const profileMessageType = ref<'success' | 'error'>('success')

// Données du client
const customerData = ref<any>(null)
const customerPoints = ref(0)
const customerName = ref('')
const memberSince = ref('')
const customerLoyaltyCode = ref('')

// Données du profil client pour le modal
const profileData = ref({
  first_name: '',
  last_name: '',
  email: '',
  phone: '',
  date_of_birth: '',
  total_points_earned: 0,
  total_points_spent: 0,
  accept_marketing: false,
  accept_partners: false
})

// Variables pour Apple Wallet
const customerId = ref('')
const companyId = ref('')
const qrCodeValue = computed(() => {
  if (companyData.value.qr_code_id && customerId.value) {
    return `${window.location.origin}/c/${companyData.value.qr_code_id}?cid=${customerId.value}`
  }
  return ''
})

// Paramètres de la carte
const showPoints = computed(() => 
  companyData.value.card_settings?.showPoints !== false
)

const showQRInCard = computed(() =>
  companyData.value.card_settings?.showQRInCard !== false  // Par défaut à true
)

const cardGradient = computed(() => {
  // Utiliser card_gradient depuis la base de données
  const gradient = companyData.value.card_gradient || companyData.value.card_settings?.gradient || 'from-violet-600 to-pink-600'
  return `bg-gradient-to-br ${gradient}`
})

// Formater le code de fidélité en XXXX-XXXX-XXXX-XXXX
const formattedLoyaltyCode = computed(() => {
  if (!customerLoyaltyCode.value) return ''
  // Diviser en groupes de 4 caractères
  return customerLoyaltyCode.value.match(/.{1,4}/g)?.join(' - ') || customerLoyaltyCode.value
})

// Filtrer les récompenses actives
const filteredRewards = computed(() => 
  rewards.value.filter(r => r.is_active).sort((a, b) => a.points_required - b.points_required)
)

// Charger les données de l'entreprise et les récompenses
const loadData = async () => {
  loading.value = true
  try {
    // Récupérer l'ID de l'entreprise depuis l'URL
    const companyParam = router.currentRoute.value.query.company as string
    let localCompanyId = companyParam
    
    // Vérifier si c'est un propriétaire d'entreprise
    const { data: { user } } = await supabase.auth.getUser()
    if (user) {
      const { data: userData } = await supabase
        .from('users')
        .select('id')
        .eq('auth_id', user.id)
        .single()
      
      if (userData) {
        isOwner.value = true
        localCompanyId = userData.id
        companyId.value = userData.id
      }
    }
    
    // Vérifier la session client
    const customerSession = localStorage.getItem('customer_session')
    if (customerSession && !isOwner.value) {
      const session = JSON.parse(customerSession)
      customerData.value = session
      isAuthenticated.value = true
      isLoggedIn.value = true  // Marquer comme connecté
      customerPoints.value = session.points || 0
      customerName.value = session.name || ''
      customerId.value = session.id
      companyId.value = localCompanyId
      
      // Rafraîchir les points depuis la base
      const { data: freshCustomer } = await supabase
        .from('customers')
        .select('points, created_at, loyalty_code')
        .eq('id', session.id)
        .single()
      
      if (freshCustomer) {
        customerPoints.value = freshCustomer.points
        customerLoyaltyCode.value = freshCustomer.loyalty_code || ''
        const createdDate = new Date(freshCustomer.created_at)
        memberSince.value = createdDate.toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' })
      }
    } else if (!isOwner.value) {
      // Rediriger vers l'authentification client
      router.push(`/client-auth?company=${localCompanyId}`)
      return
    }
    
    // Charger les données de l'entreprise
    if (localCompanyId) {
      const { data: companyInfo } = await supabase
        .from('users')
        .select('company, logo_url, card_settings, qr_code_id, card_theme, card_background_url, card_gradient')
        .eq('id', localCompanyId)
        .single()
      
      if (companyInfo) {
        companyData.value = {
          name: companyInfo.company || 'FidApp',
          logo_url: companyInfo.logo_url,
          card_settings: companyInfo.card_settings,
          qr_code_id: companyInfo.qr_code_id,
          card_theme: companyInfo.card_theme || 'gradient',
          card_background_url: companyInfo.card_background_url,
          card_gradient: companyInfo.card_gradient || 'from-violet-600 to-pink-600'
        }
      }
      
      // Charger les récompenses
      const { data: rewardsData } = await supabase
        .from('rewards')
        .select('*')
        .eq('company_id', localCompanyId)
        .eq('is_active', true)
      
      if (rewardsData) {
        rewards.value = rewardsData
      }
      
      // Charger les offres
      const { data: offersData } = await supabase
        .from('offers')
        .select('*')
        .eq('company_id', localCompanyId)
        .eq('is_active', true)
        .order('points_cost', { ascending: true })
      
      if (offersData) {
        offers.value = offersData
      }
    }
  } catch (error) {
    console.error('Erreur lors du chargement:', error)
  } finally {
    loading.value = false
  }
}

// Obtenir le label du type d'offre
const getOfferTypeLabel = (type: string) => {
  switch (type) {
    case 'discount': return 'Réduction'
    case 'gift': return 'Cadeau'
    case 'points': return 'Points bonus'
    case 'upgrade': return 'Surclassement'
    default: return 'Offre'
  }
}

// Obtenir le gradient pour le type d'offre
const getOfferGradient = (type: string) => {
  switch (type) {
    case 'discount': 
      return 'from-emerald-400 to-green-600'
    case 'gift': 
      return 'from-pink-400 to-rose-600'
    case 'points': 
      return 'from-amber-400 to-yellow-600'
    case 'upgrade': 
      return 'from-purple-400 to-indigo-600'
    default: 
      return 'from-violet-400 to-purple-600'
  }
}

// Obtenir la classe du badge pour le type d'offre
const getOfferBadgeClass = (type: string) => {
  switch (type) {
    case 'discount': 
      return 'bg-green-500/90 text-white'
    case 'gift': 
      return 'bg-rose-500/90 text-white'
    case 'points': 
      return 'bg-amber-500/90 text-white'
    case 'upgrade': 
      return 'bg-indigo-500/90 text-white'
    default: 
      return 'bg-violet-500/90 text-white'
  }
}

// Échanger une offre
const redeemOffer = async (offer: any) => {
  selectedReward.value = {
    id: offer.id,
    name: offer.name,
    description: offer.description,
    points_required: offer.points_cost,
    is_active: offer.is_active,
    category: offer.type
  }
  showRedeemModal.value = true
  
  try {
    // Récupérer l'ID de l'entreprise depuis l'URL
    const companyParam = router.currentRoute.value.query.company as string
    const companyId = companyParam || ''
    
    if (!customerData.value || !companyId) {
      console.error('Données client ou entreprise manquantes')
      return
    }
    
    const oldPoints = customerPoints.value
    const newPoints = oldPoints - offer.points_cost
    
    // Mettre à jour les points du client
    const { error: updateError } = await supabase
      .from('customers')
      .update({ points: newPoints })
      .eq('id', customerData.value.id)
    
    if (updateError) {
      console.error('Erreur lors de la mise à jour des points:', updateError)
      showRedeemModal.value = false
      return
    }
    
    // Créer l'enregistrement dans offer_redemptions (si la table existe)
    const { error: redemptionError } = await supabase
      .from('offer_redemptions')
      .insert({
        offer_id: offer.id,
        customer_id: customerData.value.id,
        company_id: companyId,
        points_used: offer.points_cost,
        status: 'completed'
      })
    
    if (redemptionError && !redemptionError.message.includes('offer_redemptions')) {
      console.error('Erreur lors de l\'enregistrement de l\'échange:', redemptionError)
    }
    
    // Créer l'enregistrement dans l'historique
    const { error: historyError } = await supabase
      .from('points_history')
      .insert({
        customer_id: customerData.value.id,
        company_id: companyId,
        points_amount: -offer.points_cost,
        points_before: oldPoints,
        points_after: newPoints,
        transaction_type: 'spent',
        description: `Offre échangée: ${offer.name}`,
        offer_id: offer.id
      })
    
    if (historyError) {
      console.error('Erreur lors de l\'enregistrement de l\'historique:', historyError)
    }
    
    // Mettre à jour l'affichage local
    customerPoints.value = newPoints
    
    // Rafraîchir l'historique
    if (customerData.value && companyId) {
      loadPointsHistory(customerData.value.id, companyId)
    }
    
  } catch (error) {
    console.error('Erreur lors de l\'échange:', error)
    showRedeemModal.value = false
  }
}

// Échanger une récompense
const redeemReward = async (reward: Reward) => {
  selectedReward.value = reward
  showRedeemModal.value = true
  
  try {
    // Récupérer l'ID de l'entreprise depuis l'URL
    const companyParam = router.currentRoute.value.query.company as string
    const companyId = companyParam || ''
    
    if (!customerData.value || !companyId) {
      console.error('Données client ou entreprise manquantes')
      return
    }
    
    const oldPoints = customerPoints.value
    const newPoints = oldPoints - reward.points_required
    
    // Mettre à jour les points du client
    const { error: updateError } = await supabase
      .from('customers')
      .update({ points: newPoints })
      .eq('id', customerData.value.id)
    
    if (updateError) {
      console.error('Erreur lors de la mise à jour des points:', updateError)
      showRedeemModal.value = false
      return
    }
    
    // Créer l'enregistrement dans reward_redemptions
    const { error: redemptionError } = await supabase
      .from('reward_redemptions')
      .insert({
        reward_id: reward.id,
        customer_id: customerData.value.id,
        company_id: companyId,
        points_used: reward.points_required,
        status: 'completed'
      })
    
    if (redemptionError) {
      console.error('Erreur lors de l\'enregistrement de l\'échange:', redemptionError)
    }
    
    // Créer l'enregistrement dans l'historique
    const { error: historyError } = await supabase
      .from('points_history')
      .insert({
        customer_id: customerData.value.id,
        company_id: companyId,
        points_amount: -reward.points_required,
        points_before: oldPoints,
        points_after: newPoints,
        transaction_type: 'spent',
        description: `Échange: ${reward.name}`,
        reward_id: reward.id
      })
    
    if (historyError) {
      console.error('Erreur lors de l\'enregistrement de l\'historique:', historyError)
    }
    
    // Mettre à jour l'affichage local
    customerPoints.value = newPoints
    
    // Rafraîchir l'historique
    if (customerData.value && companyId) {
      loadPointsHistory(customerData.value.id, companyId)
    }
    
  } catch (error) {
    console.error('Erreur lors de l\'échange:', error)
    showRedeemModal.value = false
  }
}

// Gérer la déconnexion client
const handleLogout = () => {
  // Supprimer la session du localStorage
  localStorage.removeItem('customer_session')
  isLoggedIn.value = false
  customerData.value = null
  
  // Rediriger vers la page d'authentification
  const companyId = new URLSearchParams(window.location.search).get('company')
  if (companyId) {
    router.push(`/client-auth?company=${companyId}`)
  }
}

// Mettre à jour le profil client
const updateProfile = async () => {
  savingProfile.value = true
  profileMessage.value = ''
  
  try {
    const session = localStorage.getItem('customer_session')
    if (!session) {
      profileMessage.value = 'Session expirée. Veuillez vous reconnecter.'
      profileMessageType.value = 'error'
      return
    }
    
    const customerSession = JSON.parse(session)
    
    // Mettre à jour les données dans la base
    const { error } = await supabase
      .from('customers')
      .update({
        first_name: profileData.value.first_name,
        last_name: profileData.value.last_name,
        email: profileData.value.email,
        phone: profileData.value.phone,
        date_of_birth: profileData.value.date_of_birth || null,
        accept_marketing: profileData.value.accept_marketing,
        accept_partners: profileData.value.accept_partners,
        consent_updated_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .eq('id', customerSession.id)
    
    if (error) throw error
    
    // Mettre à jour le nom affiché
    customerName.value = `${profileData.value.first_name} ${profileData.value.last_name}`
    
    // Mettre à jour la session
    customerSession.name = customerName.value
    customerSession.email = profileData.value.email
    localStorage.setItem('customer_session', JSON.stringify(customerSession))
    
    profileMessage.value = 'Profil mis à jour avec succès !'
    profileMessageType.value = 'success'
    
    // Fermer le modal après 2 secondes
    setTimeout(() => {
      showProfileModal.value = false
      profileMessage.value = ''
    }, 2000)
    
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil:', error)
    profileMessage.value = 'Erreur lors de la mise à jour'
    profileMessageType.value = 'error'
  } finally {
    savingProfile.value = false
  }
}

// Charger les données du client depuis la session
const loadCustomerFromSession = () => {
  const session = localStorage.getItem('customer_session')
  
  if (session) {
    try {
      const data = JSON.parse(session)
      
      isLoggedIn.value = true
      customerData.value = data
      customerPoints.value = data.points || 0
      customerName.value = data.name || 'Client'
      customerId.value = data.id
      
      // Récupérer le company_id depuis l'URL ou la session
      const companyParam = router.currentRoute.value.query.company as string
      if (companyParam) {
        companyId.value = companyParam
      }
      
      // Charger les détails complets du client
      loadCustomerDetails(data.id)
    } catch (error) {
      console.error('Erreur session client:', error)
    }
  }
}

// Charger les détails complets du client
const loadCustomerDetails = async (customerId: string) => {
  try {
    const { data, error } = await supabase
      .from('customers')
      .select('*')
      .eq('id', customerId)
      .single()
    
    if (data) {
      // Mettre à jour les données du profil
      profileData.value = {
        first_name: data.first_name,
        last_name: data.last_name,
        email: data.email,
        phone: data.phone || '',
        date_of_birth: data.date_of_birth || '',
        total_points_earned: data.total_points_earned || 0,
        total_points_spent: data.total_points_spent || 0,
        accept_marketing: data.accept_marketing || false,
        accept_partners: data.accept_partners || false
      }
      
      customerPoints.value = data.points || 0
      customerName.value = `${data.first_name} ${data.last_name}`
      customerLoyaltyCode.value = data.loyalty_code || ''
      
      // S'assurer que companyId est défini
      if (!companyId.value && data.company_id) {
        companyId.value = data.company_id
      }
      
      // S'assurer que les valeurs obligatoires sont définies avec des valeurs par défaut si nécessaire
      if (!customerId.value) {
        customerId.value = data.id
      }
      if (!companyId.value) {
        companyId.value = data.company_id
      }
      
      // Formater la date de membre
      if (data.created_at) {
        const date = new Date(data.created_at)
        memberSince.value = date.toLocaleDateString('fr-FR', { 
          year: 'numeric', 
          month: 'long' 
        })
      }
      
      // Charger l'historique des points
      loadPointsHistory(customerId, data.company_id)
    }
  } catch (error) {
    console.error('Erreur lors du chargement des détails client:', error)
  }
}

// Charger l'historique des points
const loadPointsHistory = async (customerId: string, companyId: string) => {
  loadingHistory.value = true
  try {
    // Récupérer l'historique pour l'affichage
    const { data, error } = await supabase
      .from('points_history')
      .select('*')
      .eq('customer_id', customerId)
      .eq('company_id', companyId)
      .order('created_at', { ascending: false })
      .limit(20)
    
    if (data) {
      pointsHistory.value = data
    }
    
    // Récupérer TOUT l'historique pour calculer les totaux
    const { data: allHistory } = await supabase
      .from('points_history')
      .select('points_amount, transaction_type')
      .eq('customer_id', customerId)
      .eq('company_id', companyId)
    
    if (allHistory) {
      // Calculer les totaux
      let totalEarned = 0
      let totalSpent = 0
      
      allHistory.forEach(transaction => {
        if (transaction.transaction_type === 'welcome' || 
            transaction.transaction_type === 'earned' || 
            transaction.transaction_type === 'admin_add') {
          totalEarned += Math.abs(transaction.points_amount)
        } else if (transaction.transaction_type === 'spent' || 
                   transaction.transaction_type === 'admin_remove') {
          totalSpent += Math.abs(transaction.points_amount)
        }
      })
      
      // Mettre à jour les données du profil
      profileData.value.total_points_earned = totalEarned
      profileData.value.total_points_spent = totalSpent
    }
  } catch (error) {
    console.error('Erreur lors du chargement de l\'historique:', error)
  } finally {
    loadingHistory.value = false
  }
}

// Obtenir la couleur selon le type de transaction
const getTransactionColor = (type: string) => {
  const colors: Record<string, string> = {
    'welcome': 'bg-green-100 text-green-600',
    'earned': 'bg-green-100 text-green-600',
    'admin_add': 'bg-orange-100 text-orange-600',
    'admin_remove': 'bg-orange-100 text-orange-600',
    'spent': 'bg-red-100 text-red-600'
  }
  return colors[type] || 'bg-gray-100 text-gray-600'
}

// Obtenir l'icône selon le type de transaction
const getTransactionIcon = (type: string) => {
  const icons: Record<string, any> = {
    'welcome': UserPlus,
    'earned': TrendingUp,
    'admin_add': Plus,
    'admin_remove': Minus,
    'spent': Gift
  }
  return icons[type] || Clock
}

// Obtenir le label selon le type de transaction
const getTransactionLabel = (type: string) => {
  const labels: Record<string, string> = {
    'welcome': 'Points de bienvenue',
    'earned': 'Points gagnés',
    'admin_add': 'Points ajoutés (Admin)',
    'admin_remove': 'Points retirés (Admin)',
    'spent': 'Récompense échangée'
  }
  return labels[type] || 'Transaction'
}

// Formater la date de transaction
const formatTransactionDate = (dateString: string) => {
  const date = new Date(dateString)
  const now = new Date()
  const diffTime = Math.abs(now.getTime() - date.getTime())
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))
  
  if (diffDays === 0) {
    const diffHours = Math.floor(diffTime / (1000 * 60 * 60))
    if (diffHours === 0) {
      const diffMinutes = Math.floor(diffTime / (1000 * 60))
      if (diffMinutes === 0) return "À l'instant"
      return `Il y a ${diffMinutes} minute${diffMinutes > 1 ? 's' : ''}`
    }
    return `Il y a ${diffHours} heure${diffHours > 1 ? 's' : ''}`
  }
  if (diffDays === 1) return 'Hier'
  if (diffDays < 7) return `Il y a ${diffDays} jours`
  if (diffDays < 30) return `Il y a ${Math.floor(diffDays / 7)} semaine${Math.floor(diffDays / 7) > 1 ? 's' : ''}`
  
  return date.toLocaleDateString('fr-FR', { 
    day: 'numeric', 
    month: 'long', 
    year: 'numeric' 
  })
}

// Méthodes pour Apple Wallet
const handleWalletAdded = (serialNumber: string) => {
  console.log('Carte ajoutée à Apple Wallet:', serialNumber)
  
  // Afficher une notification de succès
  const notification = document.createElement('div')
  notification.className = 'fixed top-4 right-4 z-50 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg flex items-center space-x-2'
  notification.innerHTML = `
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
    </svg>
    <span>Carte ajoutée à Apple Wallet avec succès!</span>
  `
  document.body.appendChild(notification)
  
  setTimeout(() => {
    notification.remove()
  }, 3000)
}

const handleWalletError = (error: Error) => {
  console.error('Erreur Apple Wallet:', error)
  
  // Afficher une notification d'erreur
  const notification = document.createElement('div')
  notification.className = 'fixed top-4 right-4 z-50 bg-red-500 text-white px-6 py-3 rounded-lg shadow-lg'
  notification.textContent = 'Erreur lors de l\'ajout à Apple Wallet'
  document.body.appendChild(notification)
  
  setTimeout(() => {
    notification.remove()
  }, 3000)
}

onMounted(async () => {
  await loadData()
  loadCustomerFromSession()
})

// Rafraîchir les points et l'historique du client
const refreshCustomerPoints = async () => {
  if (!customerData.value) return
  
  try {
    // Récupérer les points actuels
    const { data: freshCustomer } = await supabase
      .from('customers')
      .select('points, company_id')
      .eq('id', customerData.value.id)
      .single()
    
    if (freshCustomer) {
      const oldPoints = customerPoints.value
      customerPoints.value = freshCustomer.points
      
      // Recharger l'historique et recalculer les statistiques
      await loadPointsHistory(customerData.value.id, freshCustomer.company_id)
      
      // Si les points ont changé, mettre aussi à jour la session
      if (oldPoints !== freshCustomer.points) {
        const session = localStorage.getItem('customer_session')
        if (session) {
          const sessionData = JSON.parse(session)
          sessionData.points = freshCustomer.points
          localStorage.setItem('customer_session', JSON.stringify(sessionData))
        }
      }
    }
  } catch (error) {
    console.error('Erreur lors du rafraîchissement:', error)
  }
}
</script>