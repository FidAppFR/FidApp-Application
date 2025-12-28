<template>
  <footer class="relative bg-gradient-to-br from-purple-100 to-pink-100">
    <!-- Pattern de fond -->
    <div class="absolute inset-0 pattern-dots pointer-events-none"></div>
    
    <div class="relative max-w-7xl mx-auto px-6 py-16">
      <!-- Section principale -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-8 mb-12">
        <!-- Logo et description -->
        <div class="md:col-span-1">
          <div class="mb-4">
            <img 
              src="/Logo_Trans_unique.png" 
              alt="FidApp" 
              class="h-10"
            />
          </div>
          <p class="text-karma-gray-dark text-sm font-medium">
            La plateforme de fidélité qui transforme vos clients en ambassadeurs passionnés 🔥
          </p>
          <!-- Badge -->
          <div class="mt-4">
            <span class="inline-flex items-center gap-2 bg-white/80 backdrop-blur text-karma-purple font-bold px-4 py-2 rounded-full text-sm border-2 border-purple-300">
              <Flame :size="16" />
              N°1 en France
            </span>
          </div>
        </div>

        <!-- Produit -->
        <div>
          <h3 class="font-black mb-4 text-karma-gradient text-lg">Produit</h3>
          <ul class="space-y-3">
            <li><a href="#features" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Fonctionnalités</a></li>
            <li><a href="#pricing" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Tarifs</a></li>
            <li><a href="#integrations" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Intégrations</a></li>
            <li><a href="#api" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">API</a></li>
          </ul>
        </div>

        <!-- Entreprise -->
        <div>
          <h3 class="font-black mb-4 text-karma-gradient text-lg">Entreprise</h3>
          <ul class="space-y-3">
            <li><a href="#about" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">À propos</a></li>
            <li><a href="#blog" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Blog</a></li>
            <li><a href="#careers" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Carrières</a></li>
            <li><a href="#contact" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Contact</a></li>
          </ul>
        </div>

        <!-- Support -->
        <div>
          <h3 class="font-black mb-4 text-karma-gradient text-lg">Support</h3>
          <ul class="space-y-3">
            <li><a href="#help" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Centre d'aide</a></li>
            <li><a href="#docs" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Documentation</a></li>
            <li><a href="#status" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Statut</a></li>
            <li><a href="#security" class="text-karma-gray-dark hover:text-karma-violet font-semibold transition-colors">Sécurité</a></li>
          </ul>
        </div>
      </div>

      <!-- Réseaux sociaux -->
      <div class="flex justify-center space-x-6 mb-12 pt-8 border-t-2 border-white/30">
        <a href="#" class="w-12 h-12 bg-white rounded-full flex items-center justify-center shadow-lg hover:shadow-xl hover:scale-110 transition-all group">
          <Twitter :size="20" class="text-karma-violet group-hover:text-karma-purple transition-colors" />
        </a>
        <a href="#" class="w-12 h-12 bg-white rounded-full flex items-center justify-center shadow-lg hover:shadow-xl hover:scale-110 transition-all group">
          <Facebook :size="20" class="text-karma-violet group-hover:text-karma-purple transition-colors" />
        </a>
        <a href="#" class="w-12 h-12 bg-white rounded-full flex items-center justify-center shadow-lg hover:shadow-xl hover:scale-110 transition-all group">
          <Instagram :size="20" class="text-karma-violet group-hover:text-karma-purple transition-colors" />
        </a>
        <a href="#" class="w-12 h-12 bg-white rounded-full flex items-center justify-center shadow-lg hover:shadow-xl hover:scale-110 transition-all group">
          <Linkedin :size="20" class="text-karma-violet group-hover:text-karma-purple transition-colors" />
        </a>
        <a href="#" class="w-12 h-12 bg-white rounded-full flex items-center justify-center shadow-lg hover:shadow-xl hover:scale-110 transition-all group">
          <Youtube :size="20" class="text-karma-violet group-hover:text-karma-purple transition-colors" />
        </a>
      </div>

      <!-- Copyright et liens légaux -->
      <div class="border-t-2 border-white/30 pt-8 flex flex-col md:flex-row justify-between items-center">
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
</template>

<script setup lang="ts">
import { Twitter, Facebook, Instagram, Linkedin, Youtube, Flame } from 'lucide-vue-next'
</script>