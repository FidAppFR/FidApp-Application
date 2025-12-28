// Version de production simplifiée pour Vercel
import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import { createPinia } from 'pinia'
import './styles/main.css'

// Import simple des vues essentielles
const HomeView = () => import('./views/HomeView.vue')
const LoginView = () => import('./views/LoginView.vue')
const RegisterView = () => import('./views/RegisterView.vue')
const DashboardView = () => import('./views/DashboardView.vue')
const ClientView = () => import('./views/ClientView.vue')

// App component simple sans Teleport ni services complexes
const App = {
  template: `
    <div id="app">
      <router-view />
    </div>
  `
}

// Routes simplifiées
const routes = [
  { path: '/', name: 'Home', component: HomeView },
  { path: '/login', name: 'Login', component: LoginView },
  { path: '/register', name: 'Register', component: RegisterView },
  { path: '/dashboard', name: 'Dashboard', component: DashboardView },
  { path: '/client', name: 'Client', component: ClientView },
  // Route catch-all pour éviter les erreurs
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

// Gestion d'erreur globale
app.config.errorHandler = (err, vm, info) => {
  console.error('Vue error:', err, info)
}

// Mount avec gestion d'erreur
try {
  app.mount('#app')
  console.log('App mounted successfully')
} catch (error) {
  console.error('Failed to mount app:', error)
  // Fallback: afficher au moins quelque chose
  document.getElementById('app').innerHTML = `
    <div style="padding: 40px; text-align: center;">
      <h1>FidApp</h1>
      <p>Une erreur s'est produite lors du chargement.</p>
      <p>Veuillez rafraîchir la page.</p>
    </div>
  `
}