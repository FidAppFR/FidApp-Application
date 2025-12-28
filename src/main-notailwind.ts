// Test SANS Tailwind CSS
console.log('Testing without Tailwind...');

import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import { createPinia } from 'pinia'
// PAS d'import de styles
// import './styles/main.css'

import HomeView from './views/HomeView.vue'

const routes = [
  { path: '/', name: 'Home', component: HomeView }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

const app = createApp({
  template: `
    <div style="background: white; min-height: 100vh;">
      <h1 style="background: purple; color: white; padding: 20px; margin: 0;">
        FidApp - Test sans Tailwind
      </h1>
      <router-view />
    </div>
  `
})

const pinia = createPinia()

app.use(pinia)
app.use(router)

try {
  app.mount('#app')
  console.log('App without Tailwind mounted successfully')
} catch (error) {
  console.error('Error:', error)
}