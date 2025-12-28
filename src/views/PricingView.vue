<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50">
    <!-- Navbar -->
    <KarmaNavbar />

    <!-- Contenu principal -->
    <div class="px-4 py-16">
      <div class="max-w-5xl mx-auto">
        <!-- Header -->
        <div class="text-center mb-12">
          <h1 class="text-3xl md:text-4xl font-black text-gray-900 mb-4">
            Choisissez votre plan
          </h1>
          <p class="text-lg text-gray-600 max-w-xl mx-auto">
            Commencez gratuitement et évoluez selon vos besoins
          </p>
        </div>

        <!-- Offre Essai Gratuit -->
        <div class="mb-8">
          <div class="bg-white rounded-2xl shadow-lg p-6 border-2 border-green-200 relative overflow-hidden">
            <div class="flex items-center justify-between flex-wrap gap-4">
              <div class="flex-1">
                <h3 class="text-xl font-black text-gray-900 mb-2 flex items-center gap-2">
                  <Sparkles class="text-green-500" :size="24" />
                  Essai Gratuit
                </h3>
                <p class="text-gray-600 mb-4">
                  14 jours d'accès complet pour tester toutes les fonctionnalités
                </p>
                <div class="flex flex-wrap gap-4 text-sm">
                  <div class="flex items-center gap-2 text-gray-700">
                    <Check class="text-green-500" :size="16" />
                    <span>100 clients max</span>
                  </div>
                  <div class="flex items-center gap-2 text-gray-700">
                    <Check class="text-green-500" :size="16" />
                    <span>Toutes les fonctionnalités</span>
                  </div>
                  <div class="flex items-center gap-2 text-gray-700">
                    <Check class="text-green-500" :size="16" />
                    <span>Sans engagement</span>
                  </div>
                  <div class="flex items-center gap-2 text-gray-700">
                    <Check class="text-green-500" :size="16" />
                    <span>Support par email</span>
                  </div>
                  <div class="flex items-center gap-2 text-gray-700">
                    <X class="text-red-500" :size="16" />
                    <span>Après 14 jours : passage automatique en plan payant</span>
                  </div>
                  <div class="flex items-center gap-2 text-gray-700">
                    <X class="text-red-500" :size="16" />
                    <span>Statistiques et exports</span>
                  </div>
                </div>
              </div>
              <div class="text-center">
                <div class="text-3xl font-black text-gray-900 mb-1">0€</div>
                <div class="text-sm text-gray-600 mb-4">pendant 14 jours</div>
                <button 
                  @click="selectPlan('free')"
                  class="relative group bg-gradient-to-r from-green-500 to-emerald-500 text-white font-bold py-3 px-8 rounded-full transition-all duration-300 hover:scale-105 shadow-lg hover:shadow-xl inline-flex items-center justify-center"
                >
                  <span class="relative z-10">Commencer l'essai</span>
                  <ArrowRight class="ml-2" :size="18" />
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Offres payantes -->
        <div class="grid md:grid-cols-2 gap-8">
          <!-- Plan Starter -->
          <div class="bg-white rounded-2xl shadow-xl p-6 border-2 border-gray-100 hover:border-violet-200 transition-all duration-300 relative flex flex-col">
            <div class="mb-6">
              <h3 class="text-2xl font-black text-gray-900 mb-2">
                Plan Starter
              </h3>
              <div class="flex items-baseline gap-2 mb-4">
                <span class="text-4xl font-black text-violet-600">19,99€</span>
                <span class="text-gray-600">/mois</span>
              </div>
              <p class="text-gray-600 text-sm">
                Engagement minimum 6 mois • Facturation annuelle
              </p>
            </div>

            <div class="space-y-4 mb-8">
              <h4 class="font-bold text-gray-900">Fonctionnalités incluses :</h4>
              <div class="space-y-3">
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-violet-100 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check class="text-violet-600" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">Programme de fidélisation</p>
                    <p class="text-sm text-gray-600">Points, récompenses et niveaux VIP</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-violet-100 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check class="text-violet-600" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">500 comptes clients</p>
                    <p class="text-sm text-gray-600">Gérez jusqu'à 500 clients</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-violet-100 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check class="text-violet-600" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">Notifications automatiques</p>
                    <p class="text-sm text-gray-600">Email et SMS programmés</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-violet-100 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check class="text-violet-600" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">Support prioritaire par email</p>
                    <p class="text-sm text-gray-600">Assistance dédiée par email</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-violet-100 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check class="text-violet-600" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">Dashboard Analytics</p>
                    <p class="text-sm text-gray-600">Tableau de bord avec statistiques</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-gray-100 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <X class="text-gray-400" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-400">API et intégrations avancées</p>
                    <p class="text-sm text-gray-400">Non inclus</p>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-auto">
            <button 
              @click="selectPlan('starter')"
              class="w-full relative group bg-gradient-to-r from-violet-600 to-purple-600 text-white font-bold py-4 px-6 rounded-full transition-all duration-300 hover:scale-105 shadow-lg hover:shadow-xl"
            >
              <span class="relative z-10">Choisir ce plan</span>
              <div class="absolute inset-0 bg-gradient-to-r from-violet-700 to-purple-700 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            </button>

            <p class="text-xs text-gray-500 text-center mt-4">
              239,88€ facturé annuellement
            </p>
            </div>
          </div>

          <!-- Plan Premium -->
          <div class="bg-gradient-to-br from-violet-50 to-purple-50 rounded-2xl shadow-xl p-6 border-2 border-violet-300 relative flex flex-col">
            <div class="absolute -top-4 left-1/2 transform -translate-x-1/2">
              <span class="bg-gradient-to-r from-violet-600 to-pink-600 text-white text-sm font-bold px-4 py-2 rounded-full inline-flex items-center gap-2">
                <Crown :size="16" />
                POPULAIRE
              </span>
            </div>

            <div class="mb-6 mt-4">
              <h3 class="text-2xl font-black text-gray-900 mb-2">
                Plan Premium
              </h3>
              <div class="flex items-baseline gap-2 mb-4">
                <span class="text-4xl font-black bg-gradient-to-r from-violet-600 to-pink-600 bg-clip-text text-transparent">39,99€</span>
                <span class="text-gray-600">/mois</span>
              </div>
              <p class="text-gray-600 text-sm">
                Engagement minimum 6 mois • Facturation annuelle
              </p>
            </div>

            <div class="space-y-4 mb-8">
              <h4 class="font-bold text-gray-900">Fonctionnalités incluses :</h4>
              <div class="space-y-3">
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-gradient-to-r from-violet-600 to-pink-600 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check class="text-white" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">Tout du plan Starter</p>
                    <p class="text-sm text-gray-600">Toutes les fonctionnalités Starter incluses</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-gradient-to-r from-violet-600 to-pink-600 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check class="text-white" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">Dashboard avancé avec analytics temps réel</p>
                    <p class="text-sm text-gray-600">KPIs détaillés en temps réel</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-gradient-to-r from-violet-600 to-pink-600 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check class="text-white" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">Statistiques complètes et exports</p>
                    <p class="text-sm text-gray-600">Rapports détaillés avec exports</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-gradient-to-r from-violet-600 to-pink-600 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check class="text-white" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">Segmentation avancée des clients</p>
                    <p class="text-sm text-gray-600">Ciblage personnalisé</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-gradient-to-r from-violet-600 to-pink-600 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check class="text-white" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">API complète et intégrations</p>
                    <p class="text-sm text-gray-600">Intégrations illimitées</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-gradient-to-r from-violet-600 to-pink-600 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check class="text-white" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">Comptes clients illimités</p>
                    <p class="text-sm text-gray-600">Sans limite de clients</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <div class="w-5 h-5 rounded-full bg-gradient-to-r from-violet-600 to-pink-600 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check class="text-white" :size="12" strokeWidth={3} />
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">Formation personnalisée et support Prioritaire</p>
                    <p class="text-sm text-gray-600">Onboarding dédié et support VIP</p>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-auto">
            <button 
              @click="selectPlan('premium')"
              class="w-full relative group bg-gradient-to-r from-violet-600 to-pink-600 text-white font-bold py-4 px-6 rounded-full transition-all duration-300 hover:scale-105 shadow-xl hover:shadow-2xl"
            >
              <span class="relative z-10 flex items-center justify-center gap-2">
                <span>Choisir ce plan</span>
                <Zap :size="18" />
              </span>
              <div class="absolute inset-0 bg-gradient-to-r from-violet-700 to-pink-700 rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            </button>

            <p class="text-xs text-gray-600 text-center mt-4">
              479,88€ facturé annuellement • Économisez 20%
            </p>
            </div>
          </div>
        </div>

        <!-- Garanties -->
        <div class="mt-12 text-center">
          <div class="inline-flex flex-wrap justify-center gap-6 text-sm text-gray-600">
            <div class="flex items-center gap-2">
              <Shield class="text-green-500" :size="20" />
              <span>Paiement sécurisé</span>
            </div>
            <div class="flex items-center gap-2">
              <RefreshCw class="text-green-500" :size="20" />
              <span>Mise en place en 24h</span>
            </div>
            <div class="flex items-center gap-2">
              <Headphones class="text-green-500" :size="20" />
              <span>Support 7j/7</span>
            </div>
          </div>
        </div>

        <!-- FAQ moderne et attractive -->
        <div class="mt-20 max-w-3xl mx-auto">
          <div class="text-center mb-12">
            <span class="inline-block bg-gradient-to-r from-violet-100 to-pink-100 text-violet-700 text-sm font-bold px-4 py-2 rounded-full mb-4">
              FAQ
            </span>
            <h2 class="text-3xl font-black text-gray-900 mb-3">
              On répond à vos questions
            </h2>
            <p class="text-gray-600">
              Simple, transparent, sans surprise 
            </p>
          </div>
          
          <div class="space-y-3">
            <!-- Question 1 -->
            <div class="group bg-white border-2 border-gray-100 rounded-2xl p-6 hover:border-violet-200 transition-all duration-300 cursor-pointer">
              <div class="flex items-start gap-4">
                <div class="flex-shrink-0">
                  <div class="w-10 h-10 bg-gradient-to-r from-violet-500 to-purple-500 rounded-xl flex items-center justify-center">
                    <span class="text-white font-bold text-lg">?</span>
                  </div>
                </div>
                <div class="flex-1">
                  <h3 class="font-bold text-gray-900 mb-2 group-hover:text-violet-600 transition-colors">
                    C'est vraiment sans engagement ?
                  </h3>
                  <p class="text-gray-600 text-sm leading-relaxed">
                    <span class="font-semibold text-green-600">Oui !</span> L'essai gratuit de 14 jours est sans carte bancaire. 
                    Testez tout, sans risque.
                  </p>
                </div>
              </div>
            </div>

            <!-- Question 2 -->
            <div class="group bg-white border-2 border-gray-100 rounded-2xl p-6 hover:border-violet-200 transition-all duration-300 cursor-pointer">
              <div class="flex items-start gap-4">
                <div class="flex-shrink-0">
                  <div class="w-10 h-10 bg-gradient-to-r from-pink-500 to-rose-500 rounded-xl flex items-center justify-center">
                    <span class="text-white font-bold text-lg">€</span>
                  </div>
                </div>
                <div class="flex-1">
                  <h3 class="font-bold text-gray-900 mb-2 group-hover:text-violet-600 transition-colors">
                    Des frais cachés ?
                  </h3>
                  <p class="text-gray-600 text-sm leading-relaxed">
                    <span class="font-semibold text-green-600">Jamais !</span> Le prix affiché est le prix final. 
                    Pas de mauvaise surprise.
                  </p>
                </div>
              </div>
            </div>

            <!-- Question 3 -->
            <div class="group bg-white border-2 border-gray-100 rounded-2xl p-6 hover:border-violet-200 transition-all duration-300 cursor-pointer">
              <div class="flex items-start gap-4">
                <div class="flex-shrink-0">
                  <div class="w-10 h-10 bg-gradient-to-r from-violet-500 to-pink-500 rounded-xl flex items-center justify-center">
                    <RefreshCw class="text-white" :size="20" />
                  </div>
                </div>
                <div class="flex-1">
                  <h3 class="font-bold text-gray-900 mb-2 group-hover:text-violet-600 transition-colors">
                    Je peux changer de plan ?
                  </h3>
                  <p class="text-gray-600 text-sm leading-relaxed">
                    <span class="font-semibold text-green-600">Bien sûr !</span> Évoluez à votre rythme. 
                    Upgrade instantané, downgrade en fin de période.
                  </p>
                </div>
              </div>
            </div>

            <!-- Question 4 -->
            <div class="group bg-white border-2 border-gray-100 rounded-2xl p-6 hover:border-violet-200 transition-all duration-300 cursor-pointer">
              <div class="flex items-start gap-4">
                <div class="flex-shrink-0">
                  <div class="w-10 h-10 bg-gradient-to-r from-green-500 to-emerald-500 rounded-xl flex items-center justify-center">
                    <Rocket class="text-white" :size="20" />
                  </div>
                </div>
                <div class="flex-1">
                  <h3 class="font-bold text-gray-900 mb-2 group-hover:text-violet-600 transition-colors">
                    C'est rapide à installer ?
                  </h3>
                  <p class="text-gray-600 text-sm leading-relaxed">
                    <span class="font-semibold text-green-600">3 minutes !</span> Notre équipe vous accompagne. 
                    Opérationnel en 24h maximum.
                  </p>
                </div>
              </div>
            </div>
          </div>

          <!-- CTA FAQ -->
          <div class="mt-8 text-center">
            <p class="text-gray-600 mb-4">
              D'autres questions ?
            </p>
            <a href="#contact" class="inline-flex items-center gap-2 text-violet-600 hover:text-violet-700 font-semibold group">
              <MessageCircle :size="20" />
              <span>Chattez avec nous</span>
              <ArrowRight :size="16" class="group-hover:translate-x-1 transition-transform" />
            </a>
          </div>
        </div>
      </div>
    </div>

    <!-- Footer simple -->
    <footer class="bg-gradient-to-br from-purple-100 to-pink-100 mt-16">
      <div class="max-w-7xl mx-auto px-6">
        <div class="border-t-2 border-white/30 pt-8 pb-8 flex flex-col md:flex-row justify-between items-center">
          <div class="text-karma-gray-dark font-bold mb-4 md:mb-0">
            © 2025 FidApp. Tous droits réservés 🔥
          </div>
          <div class="flex space-x-6 text-sm">
            <a href="#privacy" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Confidentialité</a>
            <a href="#terms" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Conditions</a>
            <a href="#cookies" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Cookies</a>
            <a href="#legal" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Mentions légales</a>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import { ref, onMounted } from 'vue'
import { 
  ArrowRight, 
  Check, 
  X,
  Sparkles, 
  Crown, 
  Zap, 
  Shield, 
  RefreshCw, 
  Headphones,
  MessageCircle,
  Rocket
} from 'lucide-vue-next'
import KarmaNavbar from '@/components/layout/KarmaNavbar.vue'
import { supabase } from '@/services/supabase'

const router = useRouter()
const isAuthenticated = ref(false)

// Vérifier si l'utilisateur est connecté
onMounted(async () => {
  const { data: { user } } = await supabase.auth.getUser()
  isAuthenticated.value = !!user
})

const selectPlan = async (plan: string) => {
  console.log('Plan selected:', plan)
  
  // Vérifier si l'utilisateur est connecté
  const { data: { user } } = await supabase.auth.getUser()
  
  if (user) {
    // Si connecté, rediriger vers le dashboard avec l'onglet plans actif
    router.push(`/dashboard?section=plan&selectedPlan=${plan}`)
  } else {
    // Si non connecté, rediriger vers la page d'inscription
    router.push(`/register?plan=${plan}`)
  }
}
</script>