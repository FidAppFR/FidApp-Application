import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import { createPinia } from 'pinia'
import App from './App.vue'
import './styles/main.css'

// Import des vues avec lazy loading pour optimiser
const HomeView = () => import('./views/HomeView.vue')
const LoginView = () => import('./views/LoginView.vue')
const PricingView = () => import('./views/PricingView.vue')
const RegisterView = () => import('./views/RegisterView.vue')
const ProfileView = () => import('./views/ProfileView.vue')
const DashboardView = () => import('./views/DashboardView.vue')
const ClientView = () => import('./views/ClientView.vue')
const ClientAuthView = () => import('./views/ClientAuthView.vue')
const ModifyCustomerView = () => import('./views/ModifyCustomerView.vue')
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
    component: HomeView, // Utilise le composant déjà importé
    beforeEnter: async (to: any, from: any, next: any) => {
      try {
        // Récupérer l'ID de l'entreprise depuis le qr_code_id
        const qrCodeId = to.params.qrCodeId
        
        // Importer Supabase
        const { supabase } = await import('./services/supabase')
        
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
      } catch (error) {
        console.error('Error in QR redirect:', error)
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

// Gestion d'erreur globale
app.config.errorHandler = (err, instance, info) => {
  console.error('Vue error:', err)
  console.error('Component:', instance)
  console.error('Error info:', info)
}

// Mount avec try-catch
try {
  app.mount('#app')
  console.log('FidApp mounted successfully')
} catch (error) {
  console.error('Failed to mount app:', error)
  // Afficher au moins un message d'erreur
  const appElement = document.getElementById('app')
  if (appElement) {
    appElement.innerHTML = `
      <div style="padding: 40px; text-align: center; font-family: sans-serif;">
        <h1 style="color: #ef4444;">Erreur de chargement</h1>
        <p>L'application n'a pas pu se charger correctement.</p>
        <p style="color: #666;">Veuillez rafraîchir la page ou contacter le support.</p>
        <button onclick="location.reload()" style="margin-top: 20px; padding: 10px 20px; background: #8b5cf6; color: white; border: none; border-radius: 5px; cursor: pointer;">
          Rafraîchir
        </button>
      </div>
    `
  }
}