<template>
  <div class="min-h-screen">
    <!-- Navbar -->
    <KarmaNavbar @cta-click="scrollToStats" />
    
    <!-- Main Content -->
    <KarmaBackground :show-orbs="true" pattern="dots">
      <div class="container mx-auto px-6 py-24">
      
      <!-- Hero Section -->
      <section class="text-center mb-32 pt-12 relative">
        <!-- Badge avec fond coloré -->
        <div class="mb-8">
          <span class="inline-flex items-center gap-2 bg-gradient-to-r from-violet-100 via-purple-100 to-pink-100 text-purple-700 font-bold px-6 py-3 rounded-full border-2 border-purple-200/50 shadow-lg shadow-purple-200/50">
            <Star :size="18" fill="currentColor" class="text-purple-600" />
            <span>Le programme fidélité qui fait revenir vos clients</span>
          </span>
        </div>
        
        <!-- Titre principal avec dégradé amélioré -->
        <h1 class="text-4xl md:text-5xl lg:text-6xl font-black mb-8 leading-tight">
          <span class="text-gray-900">Vos clients vous adorent.</span><br>
          <span class="bg-gradient-to-r from-violet-600 to-pink-600 bg-clip-text text-transparent">
            Récompensez-les !
          </span>
        </h1>
        
        <!-- Description avec meilleur contraste -->
        <p class="text-base md:text-lg text-gray-600 font-medium mb-12 max-w-2xl mx-auto leading-relaxed">
          Créez un programme de fidélité qui donne envie de revenir. Points, récompenses, avantages VIP... en quelques clics.
        </p>
        
        <!-- Bouton CTA amélioré -->
        <div class="flex justify-center mb-12">
          <router-link 
            to="/pricing"
            class="relative group bg-gradient-to-r from-violet-600 to-pink-600 text-white font-black py-5 px-14 rounded-full transition-all duration-300 hover:scale-110 shadow-2xl shadow-purple-500/25 hover:shadow-purple-500/40 text-lg inline-flex items-center justify-center"
          >
            <span class="relative z-10">Essai Gratuit 🚀</span>
            <div class="absolute inset-0 bg-gradient-to-r from-violet-700 to-pink-700 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
          </router-link>
        </div>

        <!-- Features rapides avec style amélioré -->
        <div class="flex flex-col sm:flex-row items-center justify-center gap-8">
          <div class="flex items-center gap-3 bg-white/80 backdrop-blur-sm px-4 py-2 rounded-full shadow-md">
            <div class="w-6 h-6 bg-gradient-to-br from-green-400 to-emerald-500 rounded-full flex items-center justify-center shadow-sm">
              <Check :size="16" color="white" strokeWidth={3} />
            </div>
            <span class="font-bold text-gray-800">Installation en 3 min</span>
          </div>
          <div class="flex items-center gap-3 bg-white/80 backdrop-blur-sm px-4 py-2 rounded-full shadow-md">
            <div class="w-6 h-6 bg-gradient-to-br from-green-400 to-emerald-500 rounded-full flex items-center justify-center shadow-sm">
              <Check :size="16" color="white" strokeWidth={3} />
            </div>
            <span class="font-bold text-gray-800">Pas besoin de coder</span>
          </div>
          <div class="flex items-center gap-3 bg-white/80 backdrop-blur-sm px-4 py-2 rounded-full shadow-md">
            <div class="w-6 h-6 bg-gradient-to-br from-green-400 to-emerald-500 rounded-full flex items-center justify-center shadow-sm">
              <Check :size="16" color="white" strokeWidth={3} />
            </div>
            <span class="font-bold text-gray-800">Gratuit pendant 14 jours</span>
          </div>
        </div>

      </section>

      <!-- Stats Section -->
      <section ref="statsSection" class="mb-32 pt-24 -mt-20">
        <div class="text-center mb-16">
          <h2 class="text-4xl font-black text-karma-black mb-4">
            Résultats prouvés
          </h2>
          <p class="text-lg text-karma-gray-dark max-w-xl mx-auto">
            Des métriques qui parlent d'elles-mêmes
          </p>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <KarmaCard 
            variant="stat-rose"
            value="+340%"
            description="Augmentation conversions"
            :icon="TrendingUp"
          />
          
          <KarmaCard 
            variant="stat-purple"
            value="89%"
            description="Taux de rétention"
            :icon="Users"
          />
          
          <KarmaCard 
            variant="stat-success"
            value="+250%"
            description="Croissance revenue"
            :icon="Target"
          />
        </div>
      </section>

      <!-- Features Section -->
      <section class="mb-32">
        <div class="text-center mb-16">
          <h2 class="text-5xl font-black text-karma-black mb-6">
            Fonctionnalités premium ✨
          </h2>
          <p class="text-xl text-karma-gray-dark max-w-2xl mx-auto">
            Tous les outils dont vous avez besoin pour créer un programme de fidélité irrésistible
          </p>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <KarmaCard 
            variant="activity-rose"
            title="Récompenses Intelligentes"
            description="Système de points avancé avec récompenses personnalisées"
            :icon="Gift"
            badge="🎁 Automatisé"
          />
          
          <KarmaCard 
            variant="activity-purple"
            title="Gamification"
            description="Défis, niveaux VIP et badges pour engager vos clients"
            :icon="Star"
            badge="🏆 Engagement"
          />
          
          <KarmaCard 
            variant="activity-pink"
            title="Analytics Avancés"
            description="Tableaux de bord complets pour optimiser vos performances"
            :icon="BarChart3"
            badge="📊 Insights"
          />
          
          <KarmaCard 
            variant="activity-rose"
            title="Intégrations"
            description="Compatible avec tous vos outils existants"
            :icon="Zap"
            badge="🔌 API"
          />
          
          <KarmaCard 
            variant="activity-purple"
            title="Support Client"
            description="Équipe dédiée pour votre succès 24/7"
            :icon="MessageCircle"
            badge="💬 Support"
          />
          
          <KarmaCard 
            variant="activity-pink"
            title="Mobile-First"
            description="Expérience optimale sur tous les appareils"
            :icon="Smartphone"
            badge="📱 Responsive"
          />
        </div>
      </section>

      <!-- Success Stories -->
      <section class="mb-32">
        <div class="text-center mb-16">
          <h2 class="text-5xl font-black text-karma-black mb-6">
            Ils nous font confiance 🎯
          </h2>
        </div>
        
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <KarmaCard variant="default">
            <div class="flex items-start gap-4">
              <div class="icon-karma-container bg-karma-card-rose">
                <Store :size="28" color="white" />
              </div>
              <div>
                <h3 class="text-2xl font-black text-karma-black mb-2">
                  Boutique Mode Sarah
                </h3>
                <p class="text-karma-gray-dark mb-4">
                  "En 3 mois, notre chiffre d'affaires a augmenté de 180% grâce au programme de fidélité FidApp. Nos clients reviennent sans cesse !"
                </p>
                <KarmaBadge variant="success" text="🚀 +180% CA" />
              </div>
            </div>
          </KarmaCard>
          
          <KarmaCard variant="default">
            <div class="flex items-start gap-4">
              <div class="icon-karma-container bg-karma-card-purple">
                <Coffee :size="28" color="white" />
              </div>
              <div>
                <h3 class="text-2xl font-black text-karma-black mb-2">
                  Café Central
                </h3>
                <p class="text-karma-gray-dark mb-4">
                  "Nos clients utilisent l'app tous les jours. Le système de points les motive vraiment à revenir. C'est magique !"
                </p>
                <KarmaBadge variant="success" text="💫 95% d'adoption" />
              </div>
            </div>
          </KarmaCard>
        </div>
      </section>

      <!-- CTA Final -->
      <section class="text-center bg-white rounded-3xl p-16 shadow-karma-strong">
        <KarmaBadge variant="floating" :icon="Flame" text="Offre Limitée" animated />
        
        <h2 class="text-5xl font-black text-karma-black mt-8 mb-6">
          Prêt à enflammer vos ventes ? 🔥
        </h2>
        
        <p class="text-xl text-karma-gray-dark mb-12 max-w-2xl mx-auto">
          Rejoignez des milliers d'entreprises qui transforment leurs clients en fans absolus
        </p>
        
        <div class="flex flex-col sm:flex-row gap-6 justify-center">
          <router-link to="/pricing">
            <KarmaButton 
              variant="primary" 
              size="lg" 
              :icon="Rocket"
            >
              Démarrer gratuitement
            </KarmaButton>
          </router-link>
          
          <KarmaButton 
            variant="secondary" 
            size="lg"
            :icon="Phone"
          >
            Demander une démo
          </KarmaButton>
        </div>
        
        <div class="flex justify-center gap-8 mt-12 text-karma-gray">
          <div class="flex items-center gap-2">
            <Check :size="20" class="text-karma-success" />
            <span>Essai gratuit 14 jours</span>
          </div>
          <div class="flex items-center gap-2">
            <Check :size="20" class="text-karma-success" />
            <span>Sans engagement</span>
          </div>
          <div class="flex items-center gap-2">
            <Check :size="20" class="text-karma-success" />
            <span>Support inclus</span>
          </div>
        </div>
      </section>
      
      </div>
    </KarmaBackground>
    
    <!-- Footer -->
    <KarmaFooter />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { 
  ArrowRight, TrendingUp, Users, Target, Gift, Star, BarChart3, 
  Zap, MessageCircle, Smartphone, Store, Coffee, Flame, 
  Phone, Check, Rocket
} from 'lucide-vue-next'

import KarmaNavbar from '@/components/layout/KarmaNavbar.vue'
import KarmaBackground from '@/components/layout/KarmaBackground.vue'
import KarmaFooter from '@/components/layout/KarmaFooter.vue'
import KarmaButton from '@/components/ui/KarmaButton.vue'
import KarmaCard from '@/components/ui/KarmaCard.vue'
import KarmaBadge from '@/components/ui/KarmaBadge.vue'

const statsSection = ref<HTMLElement>()

const scrollToStats = () => {
  statsSection.value?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}
</script>