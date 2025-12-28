import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import { createPinia } from 'pinia'
import './styles/main.css'

import App from './App.vue'
// import App from './App-simple.vue'
// import App from './App-debug.vue'
import HomeView from './views/HomeView.vue'
import LoginView from './views/LoginView.vue'
import PricingView from './views/PricingView.vue'
import RegisterView from './views/RegisterView.vue'
import ProfileView from './views/ProfileView.vue'
import DashboardView from './views/DashboardView.vue'
import ClientView from './views/ClientView.vue'
import ClientAuthView from './views/ClientAuthView.vue'
import ModifyCustomerView from './views/ModifyCustomerView.vue'
// import { authGuard, permissionGuard } from './router/guards'

const routes = [
  { path: '/', name: 'Home', component: HomeView },
  { path: '/login', name: 'Login', component: LoginView },
  { path: '/pricing', name: 'Pricing', component: PricingView },
  { path: '/register', name: 'Register', component: RegisterView },
  { 
    path: '/profile', 
    name: 'Profile', 
    component: ProfileView
    // beforeEnter: [authGuard, permissionGuard]
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: DashboardView
  },
  {
    path: '/client-view',
    name: 'ClientView',
    component: ClientView
  },
  {
    path: '/client-auth',
    name: 'ClientAuth',
    component: ClientAuthView
  },
  {
    path: '/modify-customer',
    name: 'ModifyCustomer',
    component: ModifyCustomerView
  },
  {
    path: '/c/:qrCodeId',
    name: 'QRRedirect',
    component: () => import('@/views/HomeView.vue'), // Composant temporaire requis
    beforeEnter: async (to: any, from: any, next: any) => {
      // Récupérer l'ID de l'entreprise depuis le qr_code_id
      const qrCodeId = to.params.qrCodeId
      
      // Importer Supabase
      const { supabase } = await import('@/services/supabase')
      
      // Chercher l'entreprise avec ce QR code
      const { data } = await supabase
        .from('users')
        .select('id')
        .eq('qr_code_id', qrCodeId)
        .single()
      
      if (data) {
        // Rediriger vers la page d'authentification avec l'ID de l'entreprise
        next(`/client-auth?company=${data.id}`)
      } else {
        // Si QR code invalide, rediriger vers l'accueil
        next('/')
      }
    }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    // Toujours retourner en haut de la page lors de la navigation
    return { top: 0 }
  }
})

// Guard global pour vérifier l'authentification sur toutes les routes
// Temporairement désactivé pour diagnostiquer
// router.beforeEach(authGuard)

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.mount('#app')