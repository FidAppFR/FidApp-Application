<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header avec logo et notifications -->
    <header class="bg-white border-b border-gray-200 fixed top-0 left-0 right-0 z-40 h-16">
      <div class="h-full px-6 flex items-center justify-between">
        <router-link to="/" class="flex items-center">
          <img 
            src="/Logo_Trans_unique.png" 
            alt="FidApp" 
            class="h-8 md:h-10"
          />
        </router-link>
        
        <!-- Centre de notifications -->
        <NotificationCenter />
      </div>
    </header>

    <!-- Layout avec sidebar -->
    <div class="flex pt-16">
      <!-- Sidebar -->
      <aside class="fixed left-0 top-16 bottom-0 w-64 bg-white border-r border-gray-200 overflow-y-auto">
        <nav class="p-3 space-y-1">
          <!-- Menu Dashboard -->
          <button
            @click="navigateToSection('dashboard')"
            :class="[
              'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm',
              activeSection === 'dashboard' 
                ? 'bg-gradient-to-r from-violet-600 to-pink-600 text-white shadow-lg' 
                : 'hover:bg-gray-100 text-gray-700'
            ]"
          >
            <LayoutDashboard :size="16" />
            <span class="text-sm">Tableau de bord</span>
          </button>

          <!-- Menu Nos Produits -->
          <button
            @click="navigateToSection('products')"
            :class="[
              'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm',
              activeSection === 'products' 
                ? 'bg-gradient-to-r from-violet-600 to-pink-600 text-white shadow-lg' 
                : 'hover:bg-gray-100 text-gray-700'
            ]"
          >
            <Package :size="16" />
            <span class="text-sm">Nos Produits</span>
          </button>

          <!-- Menu Récompenses avec dropdown -->
          <div class="relative">
            <button
              @click="toggleRewardsDropdown"
              :class="[
                'w-full flex items-center justify-between px-3 py-2 rounded-lg transition-all duration-200 text-sm',
                ['rewards', 'welcome-points', 'offers', 'bonus'].includes(activeSection)
                  ? 'bg-gradient-to-r from-violet-600 to-pink-600 text-white shadow-lg' 
                  : 'hover:bg-gray-100 text-gray-700'
              ]"
            >
              <div class="flex items-center space-x-2">
                <Gift :size="16" />
                <span class="text-sm">Récompenses</span>
              </div>
              <ChevronDown 
                :size="14" 
                :class="[
                  'transition-transform duration-200',
                  showRewardsDropdown ? 'rotate-180' : ''
                ]"
              />
            </button>
            
            <!-- Dropdown menu avec animation -->
            <transition
              name="slide-fade"
              @enter="onDropdownEnter"
              @leave="onDropdownLeave"
            >
              <div 
                v-if="showRewardsDropdown"
                class="mt-1 space-y-1 pl-6 overflow-hidden"
              >
              <button
                @click="setActiveSection('welcome-points')"
                :class="[
                  'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm transform',
                  activeSection === 'welcome-points' 
                    ? 'bg-violet-100 text-violet-700 font-medium' 
                    : 'hover:bg-gray-100 text-gray-600 hover:translate-x-1'
                ]"
                :style="{ '--item-index': 0 }"
              >
                <UserPlus :size="14" />
                <span class="text-xs">Points de bienvenue</span>
              </button>
              
              <button
                @click="setActiveSection('offers')"
                :class="[
                  'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm transform',
                  activeSection === 'offers' 
                    ? 'bg-violet-100 text-violet-700 font-medium' 
                    : 'hover:bg-gray-100 text-gray-600 hover:translate-x-1'
                ]"
                :style="{ '--item-index': 1 }"
              >
                <Tag :size="14" />
                <span class="text-xs">Offres</span>
              </button>
              
              <button
                @click="setActiveSection('bonus')"
                :class="[
                  'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm transform',
                  activeSection === 'bonus' 
                    ? 'bg-violet-100 text-violet-700 font-medium' 
                    : 'hover:bg-gray-100 text-gray-600 hover:translate-x-1'
                ]"
                :style="{ '--item-index': 2 }"
              >
                <Sparkles :size="14" />
                <span class="text-xs">Bonus</span>
              </button>
              </div>
            </transition>
          </div>

          <!-- Menu Profil Société -->
          <button
            @click="navigateToSection('company')"
            :class="[
              'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm',
              activeSection === 'company' 
                ? 'bg-gradient-to-r from-violet-600 to-pink-600 text-white shadow-lg' 
                : 'hover:bg-gray-100 text-gray-700'
            ]"
          >
            <Building2 :size="16" />
            <span class="text-sm">Profil société</span>
          </button>

          <!-- Menu Votre Carte -->
          <button
            @click="navigateToSection('card')"
            :class="[
              'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm',
              activeSection === 'card' 
                ? 'bg-gradient-to-r from-violet-600 to-pink-600 text-white shadow-lg' 
                : 'hover:bg-gray-100 text-gray-700'
            ]"
          >
            <CreditCard :size="16" />
            <span class="text-sm">Votre Carte</span>
          </button>

          <!-- Menu Gestion Clients avec sous-menu -->
          <div>
            <button
              @click="toggleCustomersDropdown"
              :class="[
                'w-full flex items-center justify-between px-3 py-2 rounded-lg transition-all duration-200 text-sm',
                ['customers', 'customer-lookup'].includes(activeSection)
                  ? 'bg-gradient-to-r from-violet-600 to-pink-600 text-white shadow-lg' 
                  : 'hover:bg-gray-100 text-gray-700'
              ]"
            >
              <div class="flex items-center space-x-2">
                <Users :size="16" />
                <span class="text-sm">Gestion Clients</span>
              </div>
              <ChevronDown :size="16" :class="showCustomersDropdown ? 'rotate-180' : ''" class="transition-transform duration-200" />
            </button>
            
            <!-- Sous-menu Gestion Clients -->
            <Transition
              name="slide-fade"
              @enter="onDropdownEnter"
              @leave="onDropdownLeave"
            >
              <div v-if="showCustomersDropdown" class="ml-4 mt-1 space-y-1">
                <!-- Liste des fidèles -->
                <button
                  @click="setActiveSection('customers')"
                  :class="[
                    'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 transform',
                    activeSection === 'customers'
                      ? 'bg-violet-100 text-violet-700 translate-x-1' 
                      : 'hover:bg-gray-100 text-gray-600 hover:translate-x-1'
                  ]"
                  :style="{ '--item-index': 0 }"
                >
                  <Users :size="14" />
                  <span class="text-xs">Liste des fidèles</span>
                </button>
                
                <!-- Recherche client -->
                <button
                  @click="setActiveSection('customer-lookup')"
                  :class="[
                    'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 transform',
                    activeSection === 'customer-lookup'
                      ? 'bg-violet-100 text-violet-700 translate-x-1' 
                      : 'hover:bg-gray-100 text-gray-600 hover:translate-x-1'
                  ]"
                  :style="{ '--item-index': 1 }"
                >
                  <Search :size="14" />
                  <span class="text-xs">Recherche par code</span>
                </button>
              </div>
            </Transition>
          </div>

          <!-- Menu Objectifs -->
          <button
            @click="navigateToSection('milestones')"
            :class="[
              'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm',
              activeSection === 'milestones' 
                ? 'bg-gradient-to-r from-violet-600 to-pink-600 text-white shadow-lg' 
                : 'hover:bg-gray-100 text-gray-700'
            ]"
          >
            <Trophy :size="16" />
            <span class="text-sm">Objectifs</span>
          </button>

          <!-- Menu QR Code -->
          <button
            @click="navigateToSection('qrcode')"
            :class="[
              'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm',
              activeSection === 'qrcode' 
                ? 'bg-gradient-to-r from-violet-600 to-pink-600 text-white shadow-lg' 
                : 'hover:bg-gray-100 text-gray-700'
            ]"
          >
            <QrCode :size="16" />
            <span class="text-sm">QR Code</span>
          </button>

          <!-- Menu Votre Plan -->
          <button
            @click="navigateToSection('plan')"
            :class="[
              'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm',
              activeSection === 'plan' 
                ? 'bg-gradient-to-r from-violet-600 to-pink-600 text-white shadow-lg' 
                : 'hover:bg-gray-100 text-gray-700'
            ]"
          >
            <Crown :size="16" />
            <span class="text-sm">Votre Plan</span>
          </button>

          <!-- Séparateur -->
          <div class="pt-4 pb-2">
            <div class="border-t border-gray-200"></div>
          </div>

          <!-- Menu Paramètres -->
          <button
            @click="navigateToSection('settings')"
            :class="[
              'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm',
              activeSection === 'settings' 
                ? 'bg-gradient-to-r from-violet-600 to-pink-600 text-white shadow-lg' 
                : 'hover:bg-gray-100 text-gray-700'
            ]"
          >
            <Settings :size="16" />
            <span class="text-sm">Paramètres</span>
          </button>

          <!-- Menu Support -->
          <button
            @click="navigateToSection('support')"
            :class="[
              'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm',
              activeSection === 'support' 
                ? 'bg-gradient-to-r from-violet-600 to-pink-600 text-white shadow-lg' 
                : 'hover:bg-gray-100 text-gray-700'
            ]"
          >
            <HelpCircle :size="16" />
            <span class="text-sm">Support</span>
          </button>

          <!-- Menu temporaire: Anciennes récompenses -->
          <button
            @click="navigateToSection('old-rewards')"
            :class="[
              'w-full flex items-center space-x-2 px-3 py-2 rounded-lg transition-all duration-200 text-sm',
              activeSection === 'old-rewards' 
                ? 'bg-gradient-to-r from-amber-600 to-orange-600 text-white shadow-lg' 
                : 'hover:bg-gray-100 text-gray-700'
            ]"
          >
            <Archive :size="16" />
            <span class="text-sm">Anciennes Récompenses</span>
          </button>

          <!-- Menu Déconnexion -->
          <button
            @click="handleLogout"
            class="w-full flex items-center space-x-3 px-4 py-3 rounded-xl transition-all duration-200 hover:bg-red-50 text-red-600"
          >
            <LogOut :size="16" />
            <span class="text-sm">Déconnexion</span>
          </button>
        </nav>

        <!-- Info compte en bas -->
        <div class="absolute bottom-0 left-0 right-0 p-3 border-t border-gray-200 bg-gray-50">
          <div class="flex items-center space-x-2">
            <div class="w-8 h-8 rounded-full bg-gradient-to-r from-violet-600 to-pink-600 flex items-center justify-center text-white text-xs font-bold">
              {{ userInitials }}
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-xs font-semibold text-gray-900 truncate">
                {{ userData.company }}
              </p>
              <p class="text-xs text-gray-500 truncate">
                {{ userData.email }}
              </p>
              <p class="text-xs font-medium text-violet-600">
                {{ userData.selected_plan || userData.account_type || 'free' }}
              </p>
            </div>
          </div>
        </div>
      </aside>

      <!-- Contenu principal -->
      <main class="flex-1 ml-64 p-6">
        <!-- Section Dashboard -->
        <div v-if="activeSection === 'dashboard'" class="space-y-6">
          <div>
            <h1 class="text-3xl font-black text-gray-900">Tableau de bord</h1>
            <p class="text-gray-600 mt-2">Bienvenue sur votre espace de gestion FidApp</p>
          </div>

          <!-- Scan Stats Cards -->
          <ScanStatsCard />

          <!-- Stats cards -->
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-gray-600">Clients fidèles</p>
                  <p class="text-2xl font-bold text-gray-900 mt-2">{{ dashboardStats.totalCustomers }}</p>
                  <p class="text-xs text-green-600 mt-2" v-if="dashboardStats.monthlyGrowth > 0">+{{ dashboardStats.monthlyGrowth }}% ce mois</p>
                  <p class="text-xs text-gray-500 mt-2" v-else>{{ dashboardStats.monthlyGrowth }}% ce mois</p>
                </div>
                <div class="w-12 h-12 bg-violet-100 rounded-full flex items-center justify-center">
                  <Users :size="24" class="text-violet-600" />
                </div>
              </div>
            </div>

            <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-gray-600">Points distribués</p>
                  <p class="text-2xl font-bold text-gray-900 mt-2">{{ dashboardStats.totalPointsDistributed.toLocaleString() }}</p>
                  <p v-if="dashboardStats.pointsGrowth > 0" class="text-xs text-green-600 mt-2">+{{ dashboardStats.pointsGrowth }}% ce mois</p>
                  <p v-else-if="dashboardStats.pointsGrowth < 0" class="text-xs text-red-600 mt-2">{{ dashboardStats.pointsGrowth }}% ce mois</p>
                  <p v-else class="text-xs text-gray-500 mt-2">{{ dashboardStats.pointsGrowth }}% ce mois</p>
                </div>
                <div class="w-12 h-12 bg-pink-100 rounded-full flex items-center justify-center">
                  <Star :size="24" class="text-pink-600" />
                </div>
              </div>
            </div>

            <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-gray-600">Récompenses actives</p>
                  <p class="text-2xl font-bold text-gray-900 mt-2">{{ dashboardStats.activeRewards }}</p>
                  <p class="text-xs text-gray-500 mt-2">Dans votre programme</p>
                </div>
                <div class="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                  <Gift :size="24" class="text-green-600" />
                </div>
              </div>
            </div>

            <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-gray-600">Taux d'engagement</p>
                  <p class="text-2xl font-bold text-gray-900 mt-2">{{ dashboardStats.engagementRate }}%</p>
                  <p class="text-xs text-gray-500 mt-2">Clients actifs</p>
                </div>
                <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                  <TrendingUp :size="24" class="text-blue-600" />
                </div>
              </div>
            </div>
          </div>

          <!-- Section Objectifs en cours -->
          <div class="bg-gradient-to-br from-violet-50 to-purple-50 rounded-xl p-6 border border-violet-200">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-bold text-gray-900 flex items-center gap-2">
                <Trophy :size="20" class="text-violet-600" />
                Objectifs en cours
              </h3>
              <button 
                @click="navigateToSection('milestones')"
                class="text-sm text-violet-600 hover:text-violet-700 font-medium"
              >
                Voir tous →
              </button>
            </div>
            
            <div v-if="loadingMilestones" class="text-center py-4">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-violet-600 mx-auto"></div>
            </div>
            
            <div v-else-if="activeMilestones.length === 0" class="text-center py-8">
              <Target :size="32" class="mx-auto text-gray-300 mb-3" />
              <p class="text-sm text-gray-500">Aucun objectif défini</p>
              <button 
                @click="navigateToSection('milestones')"
                class="mt-3 px-4 py-2 bg-violet-600 text-white text-sm rounded-lg hover:bg-violet-700 transition-colors"
              >
                Créer un objectif
              </button>
            </div>
            
            <div v-else class="space-y-3">
              <div 
                v-for="milestone in activeMilestones.slice(0, 3)" 
                :key="milestone.id"
                class="bg-white rounded-lg p-4 border border-gray-200"
              >
                <div class="flex items-center justify-between mb-2">
                  <h4 class="font-semibold text-gray-900">{{ milestone.name }}</h4>
                  <span :class="[
                    'px-2 py-0.5 rounded-full text-xs font-medium',
                    getMilestoneTypeColor(milestone.type)
                  ]">
                    {{ getMilestoneTypeLabel(milestone.type) }}
                  </span>
                </div>
                
                <div class="space-y-2">
                  <div class="flex items-center justify-between text-sm">
                    <span class="text-gray-600">Progression</span>
                    <span class="font-bold text-gray-900">
                      {{ milestone.current_value }} / {{ milestone.target_value }}
                    </span>
                  </div>
                  
                  <div class="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
                    <div 
                      :class="[
                        'h-full transition-all duration-500',
                        getMilestoneProgressColor(milestone.current_value / milestone.target_value * 100)
                      ]"
                      :style="{ width: Math.min(100, (milestone.current_value / milestone.target_value * 100)) + '%' }"
                    ></div>
                  </div>
                  
                  <div class="flex items-center justify-between">
                    <span class="text-xs text-gray-500">
                      {{ Math.round((milestone.current_value / milestone.target_value) * 100) }}% complété
                    </span>
                    <span v-if="milestone.reward_description" class="text-xs text-violet-600 font-medium">
                      {{ milestone.reward_description }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Graphiques -->
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- Graphique des scans -->
            <ScanChart />
            <!-- Remplacer l'ancien graphique placeholder -->

            <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
              <h3 class="text-lg font-bold text-gray-900 mb-4">Récompenses populaires</h3>
              <div class="space-y-4">
                <div v-if="popularRewards.length === 0" class="text-center py-4 text-gray-500">
                  Aucune récompense disponible
                </div>
                <div v-else v-for="(reward, index) in popularRewards" :key="reward.id || index" class="flex items-center justify-between">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 rounded-full flex items-center justify-center" :class="getCategoryColor(reward.category)">
                      <component :is="getCategoryIcon(reward.category)" :size="16" />
                    </div>
                    <span class="font-medium">{{ reward.name }}</span>
                  </div>
                  <span class="text-sm text-gray-500">
                    {{ reward.redemption_count }} {{ reward.redemption_count === 1 ? 'échange' : 'échanges' }}
                  </span>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Historique des scans récents -->
          <ScanHistory :limit="10" />
        </div>

        <!-- Section Nos Produits -->
        <div v-if="activeSection === 'products'" class="space-y-6">
          <ProductsSection />
        </div>

        <!-- Section Récompenses -->
        <div v-if="activeSection === 'rewards'" class="space-y-6">
          <RewardsSection />
        </div>

        <!-- Section Points de bienvenue -->
        <div v-if="activeSection === 'welcome-points'" class="space-y-6">
          <WelcomePointsSection />
        </div>

        <!-- Section Offres -->
        <div v-if="activeSection === 'offers'" class="space-y-6">
          <OffersSection />
        </div>

        <!-- Section Bonus -->
        <div v-if="activeSection === 'bonus'" class="space-y-6">
          <BonusSection />
        </div>

        <!-- Section Profil Société -->
        <div v-if="activeSection === 'company'" class="space-y-6">
          <CompanyProfileSection />
        </div>

        <!-- Section Votre Carte -->
        <div v-if="activeSection === 'card'" class="space-y-6">
          <LoyaltyCardSection />
        </div>

        <!-- Section Vos Fidèles -->
        <div v-if="activeSection === 'customers'" class="space-y-6">
          <CustomersSection />
        </div>

        <!-- Section Recherche Client -->
        <div v-if="activeSection === 'customer-lookup'" class="space-y-6">
          <CustomerLookup />
        </div>

        <!-- Section Votre Plan -->
        <div v-if="activeSection === 'plan'" class="space-y-6">
          <PlanSection 
            :currentPlan="userData.selected_plan || userData.account_type || 'free'" 
            :selectedPlan="selectedPlan"
            @planUpdated="handlePlanUpdate" 
          />
        </div>

        <!-- Section Paramètres -->
        <div v-if="activeSection === 'settings'" class="space-y-6">
          <SettingsSection />
        </div>

        <!-- Section Support -->
        <div v-if="activeSection === 'support'" class="space-y-6">
          <SupportSection />
        </div>

        <!-- Section Objectifs/Milestones -->
        <div v-if="activeSection === 'milestones'" class="space-y-6">
          <MilestonesSection />
        </div>

        <!-- Section QR Code -->
        <div v-if="activeSection === 'qrcode'" class="space-y-6">
          <QRCodeSection />
        </div>

        <!-- Section temporaire: Gestionnaire d'anciennes récompenses -->
        <div v-if="activeSection === 'old-rewards'" class="space-y-6">
          <OldRewardsManager />
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { 
  LayoutDashboard, Gift, Building2, CreditCard, Users, Crown,
  Settings, HelpCircle, LogOut, Star, TrendingUp, Coffee, Percent, Bell, QrCode, Package, ShoppingBag,
  ChevronDown, UserPlus, Tag, Sparkles, Archive, Trophy, Target, Search
} from 'lucide-vue-next'
import { supabase } from '@/services/supabase'
import { logoutOverlay } from '@/services/logoutOverlay'
import ProductsSection from '@/components/dashboard/ProductsSection.vue'
import RewardsSection from '@/components/dashboard/RewardsSection.vue'
import CompanyProfileSection from '@/components/dashboard/CompanyProfileSection.vue'
import LoyaltyCardSection from '@/components/dashboard/LoyaltyCardSection.vue'
import CustomersSection from '@/components/dashboard/CustomersSection.vue'
import ScanStatsCard from '@/components/ScanStatsCard.vue'
import ScanChart from '@/components/ScanChart.vue'
import ScanHistory from '@/components/ScanHistory.vue'
import PlanSection from '@/components/dashboard/PlanSection.vue'
import SettingsSection from '@/components/dashboard/SettingsSection.vue'
import SupportSection from '@/components/dashboard/SupportSection.vue'
import QRCodeSection from '@/components/dashboard/QRCodeSection.vue'
import WelcomePointsSection from '@/components/dashboard/WelcomePointsSection.vue'
import OffersSection from '@/components/dashboard/OffersSection.vue'
import BonusSection from '@/components/dashboard/BonusSection.vue'
import OldRewardsManager from '@/components/dashboard/OldRewardsManager.vue'
import NotificationCenter from '@/components/NotificationCenter.vue'
import MilestonesSection from '@/components/dashboard/MilestonesSection.vue'
import CustomerLookup from '@/components/dashboard/CustomerLookup.vue'

const router = useRouter()
const route = useRoute()
const activeSection = ref('dashboard')
const selectedPlan = ref('')
const showRewardsDropdown = ref(false)
const showCustomersDropdown = ref(false)

// Interface pour les récompenses populaires
interface PopularReward {
  id: string
  name: string
  category: string
  redemption_count: number
}

const userData = ref<{
  email: string
  company: string
  account_type: string
  selected_plan: string
  first_name: string
  last_name: string
  id?: string
  auth_id?: string
}>({
  email: '',
  company: '',
  account_type: 'free',
  selected_plan: 'free',
  first_name: '',
  last_name: ''
})

// Récompenses populaires
const popularRewards = ref<PopularReward[]>([])

// Milestones actifs
interface Milestone {
  id: string
  name: string
  type: string
  target_value: number
  current_value: number
  reward_description: string | null
}

const activeMilestones = ref<Milestone[]>([])
const loadingMilestones = ref(false)

// Intervalle de rafraîchissement
let refreshInterval: number | null = null

// Statistiques du dashboard
const dashboardStats = ref({
  totalCustomers: 0,
  monthlyGrowth: 0,
  totalPointsDistributed: 0,
  pointsGrowth: 0,
  activeRewards: 0,
  engagementRate: 0
})

const userInitials = computed(() => {
  const first = userData.value.first_name?.charAt(0) || ''
  const last = userData.value.last_name?.charAt(0) || ''
  return (first + last).toUpperCase() || 'U'
})

const toggleRewardsDropdown = () => {
  showRewardsDropdown.value = !showRewardsDropdown.value
}

const toggleCustomersDropdown = () => {
  showCustomersDropdown.value = !showCustomersDropdown.value
}

const setActiveSection = (section: string) => {
  activeSection.value = section
  // Keep dropdown open when selecting a rewards subcategory
  if (!['welcome-points', 'offers', 'bonus'].includes(section)) {
    showRewardsDropdown.value = false
  }
  // Keep dropdown open when selecting a customers subcategory
  if (!['customers', 'customer-lookup'].includes(section)) {
    showCustomersDropdown.value = false
  }
  // Scroll vers le haut de la page
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// Fonction pour changer de section avec scroll automatique
const navigateToSection = (section: string) => {
  activeSection.value = section
  showRewardsDropdown.value = false
  showCustomersDropdown.value = false
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const onDropdownEnter = (el: any) => {
  el.style.height = '0'
  el.style.opacity = '0'
  setTimeout(() => {
    el.style.transition = 'height 0.3s ease, opacity 0.3s ease'
    el.style.height = el.scrollHeight + 'px'
    el.style.opacity = '1'
  })
}

const onDropdownLeave = (el: any) => {
  el.style.transition = 'height 0.3s ease, opacity 0.3s ease'
  el.style.height = '0'
  el.style.opacity = '0'
}

const handleLogout = async () => {
  logoutOverlay.show()
  await supabase.auth.signOut()
  setTimeout(() => {
    logoutOverlay.hide()
    router.push('/')
  }, 1500)
}

const handlePlanUpdate = async (newPlan: string) => {
  // Mettre à jour l'état local immédiatement
  userData.value.selected_plan = newPlan
  // Optionnel: recharger les données depuis la base
  await loadUserData()
}

const loadUserData = async () => {
  const { data: { user } } = await supabase.auth.getUser()
  
  if (!user) {
    router.push('/login')
    return
  }

  const { data } = await supabase
    .from('users')
    .select('*')
    .eq('auth_id', user.id)
    .single()

  if (data) {
    userData.value = data
    
    // Charger le nombre de clients fidèles, les récompenses populaires et les objectifs
    await loadCustomerStats(data.id)
    await loadPopularRewards(data.id)
    await loadActiveMilestones(data.id)
  }
}

const loadCustomerStats = async (companyId: string) => {
  try {
    // Récupérer le nombre total de clients
    const { count: totalCount } = await supabase
      .from('customers')
      .select('*', { count: 'exact', head: true })
      .eq('company_id', companyId)
    
    dashboardStats.value.totalCustomers = totalCount || 0
    
    // Calculer les dates pour ce mois et le mois précédent
    const now = new Date()
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1)
    const endOfLastMonth = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59, 999)
    const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1)
    
    // Récupérer le nombre de clients à la fin du mois précédent (total historique)
    const { count: customersAtEndOfLastMonth } = await supabase
      .from('customers')
      .select('*', { count: 'exact', head: true })
      .eq('company_id', companyId)
      .lte('created_at', endOfLastMonth.toISOString())
    
    // Calculer la croissance mensuelle des clients
    if (customersAtEndOfLastMonth === 0 || customersAtEndOfLastMonth === null) {
      if (totalCount && totalCount > 0) {
        dashboardStats.value.monthlyGrowth = 100
      } else {
        dashboardStats.value.monthlyGrowth = 0
      }
    } else {
      const growth = (((totalCount || 0) - customersAtEndOfLastMonth) / customersAtEndOfLastMonth) * 100
      dashboardStats.value.monthlyGrowth = Math.round(growth)
    }
    
    // Récupérer le total des points distribués
    const { data: customers } = await supabase
      .from('customers')
      .select('points')
      .eq('company_id', companyId)
    
    const totalPoints = customers?.reduce((sum, customer) => sum + (customer.points || 0), 0) || 0
    dashboardStats.value.totalPointsDistributed = totalPoints
    
    // Calculer les points distribués le mois dernier
    const { data: customersLastMonth } = await supabase
      .from('customers')
      .select('points, created_at')
      .eq('company_id', companyId)
      .lte('created_at', endOfLastMonth.toISOString())
    
    const pointsLastMonth = customersLastMonth?.reduce((sum, customer) => sum + (customer.points || 0), 0) || 0
    
    // Calculer la croissance des points
    if (pointsLastMonth === 0) {
      if (totalPoints > 0) {
        dashboardStats.value.pointsGrowth = 100
      } else {
        dashboardStats.value.pointsGrowth = 0
      }
    } else {
      const pointsGrowth = ((totalPoints - pointsLastMonth) / pointsLastMonth) * 100
      dashboardStats.value.pointsGrowth = Math.round(pointsGrowth)
    }
    
    // Récupérer le nombre de récompenses actives
    const { count: activeRewardsCount } = await supabase
      .from('rewards')
      .select('*', { count: 'exact', head: true })
      .eq('company_id', companyId)
      .eq('is_active', true)
    
    dashboardStats.value.activeRewards = activeRewardsCount || 0
    
    // Calculer le taux d'engagement (clients avec plus de 0 points / total clients)
    const { count: activeCustomers } = await supabase
      .from('customers')
      .select('*', { count: 'exact', head: true })
      .eq('company_id', companyId)
      .gt('points', 0)
    
    if (totalCount && totalCount > 0) {
      dashboardStats.value.engagementRate = Math.round(((activeCustomers || 0) / totalCount) * 100)
    } else {
      dashboardStats.value.engagementRate = 0
    }
    
  } catch (error) {
    console.error('Erreur lors du chargement des statistiques:', error)
  }
}

// Charger les objectifs actifs
const loadActiveMilestones = async (companyId: string) => {
  loadingMilestones.value = true
  try {
    const { data, error } = await supabase
      .from('company_milestones')
      .select('id, name, type, target_value, current_value, reward_description')
      .eq('company_id', companyId)
      .eq('is_active', true)
      .eq('is_achieved', false)
      .order('created_at', { ascending: false })
      .limit(3)

    if (!error && data) {
      activeMilestones.value = data
    }
  } catch (error) {
    console.error('Erreur chargement milestones:', error)
    activeMilestones.value = []
  } finally {
    loadingMilestones.value = false
  }
}

// Méthodes pour les milestones
const getMilestoneTypeLabel = (type: string) => {
  const labels: Record<string, string> = {
    customer_count: 'Clients',
    points_distributed: 'Points',
    rewards_redeemed: 'Récompenses',
    monthly_revenue: 'Revenu',
    daily_scans: 'Scans/jour',
    weekly_active: 'Actifs/sem',
    custom: 'Personnalisé'
  }
  return labels[type] || type
}

const getMilestoneTypeColor = (type: string) => {
  const colors: Record<string, string> = {
    customer_count: 'bg-green-100 text-green-700',
    points_distributed: 'bg-blue-100 text-blue-700',
    rewards_redeemed: 'bg-pink-100 text-pink-700',
    monthly_revenue: 'bg-amber-100 text-amber-700',
    daily_scans: 'bg-purple-100 text-purple-700',
    weekly_active: 'bg-indigo-100 text-indigo-700',
    custom: 'bg-gray-100 text-gray-700'
  }
  return colors[type] || 'bg-gray-100 text-gray-700'
}

const getMilestoneProgressColor = (percentage: number) => {
  if (percentage >= 100) return 'bg-green-500'
  if (percentage >= 75) return 'bg-blue-500'
  if (percentage >= 50) return 'bg-yellow-500'
  if (percentage >= 25) return 'bg-orange-500'
  return 'bg-red-500'
}

// Charger les récompenses populaires
const loadPopularRewards = async (companyId: string) => {
  try {
    // D'abord, essayer avec la vue reward_statistics si elle existe
    const { data: rewardStats, error: statsError } = await supabase
      .from('reward_statistics')
      .select('id, name, category, total_redemptions')
      .eq('company_id', companyId)
      .eq('is_active', true)
      .order('total_redemptions', { ascending: false })
      .limit(3)
    
    if (!statsError && rewardStats) {
      popularRewards.value = rewardStats.map(r => ({
        id: r.id,
        name: r.name,
        category: r.category,
        redemption_count: r.total_redemptions || 0
      }))
    } else {
      // Sinon, utiliser la table rewards directement
      const { data: rewards } = await supabase
        .from('rewards')
        .select('id, name, category')
        .eq('company_id', companyId)
        .eq('is_active', true)
        .limit(3)
      
      if (rewards) {
        // Pour chaque récompense, compter les échanges
        const rewardsWithCount = await Promise.all(
          rewards.map(async (reward) => {
            const { count } = await supabase
              .from('reward_redemptions')
              .select('*', { count: 'exact', head: true })
              .eq('reward_id', reward.id)
              .eq('status', 'completed')
            
            return {
              id: reward.id,
              name: reward.name,
              category: reward.category,
              redemption_count: count || 0
            }
          })
        )
        
        // Trier par nombre d'échanges et prendre les 3 premiers
        popularRewards.value = rewardsWithCount
          .sort((a, b) => b.redemption_count - a.redemption_count)
          .slice(0, 3)
      }
    }
    
    // Si pas assez de récompenses, remplir avec des valeurs par défaut
    while (popularRewards.value.length < 3) {
      popularRewards.value.push({
        id: '',
        name: 'Aucune récompense',
        category: 'general',
        redemption_count: 0
      })
    }
  } catch (error) {
    console.error('Erreur lors du chargement des récompenses populaires:', error)
    // Valeurs par défaut en cas d'erreur
    popularRewards.value = [
      { id: '1', name: 'Aucune donnée', category: 'general', redemption_count: 0 },
      { id: '2', name: 'Aucune donnée', category: 'general', redemption_count: 0 },
      { id: '3', name: 'Aucune donnée', category: 'general', redemption_count: 0 }
    ]
  }
}

// Obtenir l'icône selon la catégorie
const getCategoryIcon = (category: string) => {
  const icons: Record<string, any> = {
    product: Coffee,
    discount: Percent,
    service: Star,
    gift: Gift,
    experience: Star,
    general: Package
  }
  return icons[category] || Package
}

// Obtenir la couleur selon la catégorie
const getCategoryColor = (category: string) => {
  const colors: Record<string, string> = {
    product: 'bg-violet-100 text-violet-600',
    discount: 'bg-pink-100 text-pink-600',
    service: 'bg-blue-100 text-blue-600',
    gift: 'bg-green-100 text-green-600',
    experience: 'bg-yellow-100 text-yellow-600',
    general: 'bg-gray-100 text-gray-600'
  }
  return colors[category] || 'bg-gray-100 text-gray-600'
}

onMounted(() => {
  loadUserData()
  
  // Vérifier si une section spécifique est demandée via l'URL
  if (route.query.section) {
    activeSection.value = route.query.section as string
  }
  
  // Vérifier si un plan spécifique est sélectionné
  if (route.query.selectedPlan) {
    selectedPlan.value = route.query.selectedPlan as string
  }
  
  // Rafraîchir les données toutes les 30 secondes
  refreshInterval = setInterval(() => {
    const userId = userData.value.id || userData.value.auth_id
    if (userId) {
      loadCustomerStats(userId)
      loadPopularRewards(userId)
      loadActiveMilestones(userId)
    }
  }, 30000) as unknown as number
})

onUnmounted(() => {
  // Nettoyer l'intervalle quand le composant est détruit
  if (refreshInterval) {
    clearInterval(refreshInterval)
  }
})
</script>

<style scoped>
/* Animation pour le dropdown */
.slide-fade-enter-active,
.slide-fade-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.slide-fade-enter-from {
  transform: translateY(-10px);
  opacity: 0;
}

.slide-fade-leave-to {
  transform: translateY(-10px);
  opacity: 0;
}

/* Animation douce pour les items du sous-menu */
.slide-fade-enter-active button {
  animation: slideIn 0.3s ease forwards;
  animation-delay: calc(var(--item-index) * 0.05s);
  opacity: 0;
}

@keyframes slideIn {
  from {
    transform: translateX(-10px);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}
</style>