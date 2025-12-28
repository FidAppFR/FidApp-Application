import { createApp } from 'vue'

const app = createApp({
  template: `
    <div style="padding: 20px; background: #f0f0f0; min-height: 100vh;">
      <h1 style="color: #333;">Test Vue App</h1>
      <p style="color: #666;">Si vous voyez ce message, Vue fonctionne correctement!</p>
      <p style="color: #999;">Timestamp: {{ timestamp }}</p>
      <button @click="count++" style="padding: 10px 20px; background: blue; color: white; border: none; border-radius: 5px; cursor: pointer;">
        Count: {{ count }}
      </button>
    </div>
  `,
  data() {
    return {
      timestamp: new Date().toISOString(),
      count: 0
    }
  },
  mounted() {
    console.log('Vue app mounted successfully!')
  }
})

app.mount('#app')

console.log('main-test.ts loaded')