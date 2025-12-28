/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        'inter': ['Inter', 'system-ui', 'sans-serif'],
      },
      colors: {
        // Palette Karma Hero (Violet-Rose-Orange)
        'karma-violet': '#A855F7',
        'karma-purple': '#8B5CF6',
        'karma-pink': '#EC4899',
        'karma-rose': '#F43F5E',
        
        // Couleurs Secondaires
        'karma-violet-light': '#F3E8FF',
        'karma-purple-light': '#E9D5FF',
        'karma-rose-light': '#FECDD3',
        'karma-success': '#10B981',
        'karma-success-dark': '#059669',
        
        // Couleurs Neutres
        'karma-black': '#111827',
        'karma-gray-dark': '#374151',
        'karma-gray': '#6B7280',
        'karma-gray-light': '#F3F4F6',
        'karma-white': '#FFFFFF',
        
        // Bordures Colorées
        'karma-border-rose': '#FDA4AF',
        'karma-border-success': '#6EE7B7',
      },
      backgroundImage: {
        // Dégradé Principal Violet-Rose
        'karma-gradient': 'linear-gradient(to right, #A855F7, #EC4899)',
        
        // Dégradé Fond Hero
        'karma-hero': 'linear-gradient(to bottom right, #F3E8FF, #FECDD3)',
        
        // Dégradés Cards
        'karma-card-violet': 'linear-gradient(135deg, #A855F7, #8B5CF6)',
        'karma-card-rose': 'linear-gradient(to bottom right, #EC4899, #F472B6)',
        'karma-card-purple': 'linear-gradient(to bottom right, #8B5CF6, #A855F7)',
        'karma-card-success': 'linear-gradient(to bottom right, #10B981, #059669)',
        
        // Patterns de fond
        'karma-pattern-dots': 'radial-gradient(circle at 2px 2px, rgb(236, 72, 153) 2px, transparent 0)',
        'karma-pattern-lines': 'repeating-linear-gradient(45deg, transparent, transparent 10px, rgb(168, 85, 247) 10px, rgb(168, 85, 247) 11px)',
        'karma-pattern-grid': 'linear-gradient(to right, rgb(168, 85, 247) 1px, transparent 1px), linear-gradient(to bottom, rgb(168, 85, 247) 1px, transparent 1px)',
        
        // Orbes Lumineux
        'karma-orb-rose': 'linear-gradient(to bottom right, #FB7185, #EC4899)',
        'karma-orb-purple': 'linear-gradient(to bottom right, #A855F7, #8B5CF6)',
        'karma-orb-pink': 'linear-gradient(to bottom right, #EC4899, #F472B6)',
      },
      backgroundSize: {
        'pattern-dots': '60px 60px',
        'pattern-grid': '80px 80px',
      },
      fontSize: {
        'hero': ['5rem', { lineHeight: '1' }],
        'hero-xl': ['6rem', { lineHeight: '1' }],
      },
      boxShadow: {
        'karma-soft': '0 10px 15px -3px rgba(0, 0, 0, 0.1)',
        'karma-medium': '0 20px 25px -5px rgba(0, 0, 0, 0.1)',
        'karma-strong': '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
        'karma-purple': '0 25px 50px -12px rgba(168, 85, 247, 0.5)',
        'karma-success': '0 25px 50px -12px rgba(16, 185, 129, 0.5)',
      },
      animation: {
        'bounce-slow': 'bounce 1s infinite',
        'pulse-slow': 'pulse 2s infinite',
      }
    },
  },
  plugins: [],
}