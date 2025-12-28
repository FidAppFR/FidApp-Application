console.log('Testing router...');

import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'

const TestComponent = {
  template: `<div style="padding: 20px; background: #f3f4f6;">
    <h2>Test Component</h2>
    <p>Route: {{ $route.path }}</p>
  </div>`
}

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: TestComponent },
    { path: '/test', component: TestComponent }
  ]
})

const app = createApp({
  template: `<div style="min-height: 100vh; background: white;">
    <h1 style="padding: 20px; background: linear-gradient(to right, #8b5cf6, #ec4899); color: white; margin: 0;">
      FidApp - Router Test
    </h1>
    <nav style="padding: 20px;">
      <router-link to="/" style="margin-right: 20px;">Home</router-link>
      <router-link to="/test">Test</router-link>
    </nav>
    <router-view></router-view>
  </div>`
})

app.use(router)

try {
  app.mount('#app')
  console.log('Router app mounted successfully')
} catch (error) {
  console.error('Error mounting router app:', error)
}