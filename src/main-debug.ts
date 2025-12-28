// Version de débogage pour identifier le problème de page blanche
console.log('1. main-debug.ts loaded')

import { createApp } from 'vue'
console.log('2. Vue imported')

// Composant App ultra simple
const App = {
  template: `
    <div style="padding: 20px; font-family: sans-serif;">
      <h1 style="color: #8b5cf6;">FidApp Debug</h1>
      <p>Si vous voyez ce message, l'application fonctionne!</p>
      <p>Time: ${new Date().toISOString()}</p>
      <div style="margin-top: 20px;">
        <a href="/login" style="margin-right: 10px;">Login</a>
        <a href="/register">Register</a>
      </div>
    </div>
  `,
  mounted() {
    console.log('4. App mounted')
  }
}

console.log('3. Creating app...')

try {
  const app = createApp(App)
  app.mount('#app')
  console.log('5. App successfully mounted to #app')
} catch (error) {
  console.error('ERROR mounting app:', error)
  document.body.innerHTML = `
    <div style="padding: 20px; color: red;">
      <h1>Erreur de montage</h1>
      <pre>${error}</pre>
    </div>
  `
}