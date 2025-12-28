console.log('main-minimal.ts loading...');

import { createApp } from 'vue'

console.log('Vue imported');

const app = createApp({
  template: `<div style="padding: 40px; background: linear-gradient(to right, #8b5cf6, #ec4899); min-height: 100vh; color: white;">
    <h1 style="font-size: 48px; margin-bottom: 20px;">FidApp Fonctionne! 🎉</h1>
    <p style="font-size: 24px;">Si vous voyez ce message, Vue est opérationnel.</p>
    <p>Heure: {{ time }}</p>
  </div>`,
  data() {
    return {
      time: new Date().toLocaleTimeString()
    }
  },
  mounted() {
    console.log('App mounted successfully!');
    setInterval(() => {
      this.time = new Date().toLocaleTimeString();
    }, 1000);
  }
});

console.log('App created, mounting...');

try {
  app.mount('#app');
  console.log('App mounted to #app');
} catch (error) {
  console.error('Error mounting app:', error);
}