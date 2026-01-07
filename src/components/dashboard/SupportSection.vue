<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-3xl font-black text-gray-900 dark:text-white">Centre d'aide</h1>
      <p class="text-gray-600 dark:text-gray-400 dark:text-gray-500 mt-2">Trouvez des réponses à vos questions</p>
    </div>

    <!-- Recherche -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
      <div class="relative">
        <Search :size="20" class="absolute left-4 top-4 text-gray-400 dark:text-gray-500" />
        <input
          type="text"
          placeholder="Comment pouvons-nous vous aider ?"
          class="w-full pl-12 pr-4 py-4 border border-gray-200 dark:border-gray-700 rounded-xl text-lg focus:outline-none focus:border-violet-500 transition-colors"
        />
      </div>
    </div>

    <!-- Catégories d'aide -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6 hover:shadow-lg transition-shadow cursor-pointer">
        <div class="w-12 h-12 bg-violet-100 rounded-full flex items-center justify-center mb-4">
          <BookOpen :size="24" class="text-violet-600" />
        </div>
        <h3 class="font-bold text-lg text-gray-900 dark:text-white mb-2">Guide de démarrage</h3>
        <p class="text-gray-600 dark:text-gray-400 dark:text-gray-500 text-sm">Apprenez les bases de FidApp</p>
      </div>

      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6 hover:shadow-lg transition-shadow cursor-pointer">
        <div class="w-12 h-12 bg-pink-100 rounded-full flex items-center justify-center mb-4">
          <HelpCircle :size="24" class="text-pink-600" />
        </div>
        <h3 class="font-bold text-lg text-gray-900 dark:text-white mb-2">FAQ</h3>
        <p class="text-gray-600 dark:text-gray-400 dark:text-gray-500 text-sm">Questions fréquemment posées</p>
      </div>

      <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6 hover:shadow-lg transition-shadow cursor-pointer">
        <div class="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center mb-4">
          <MessageCircle :size="24" class="text-green-600" />
        </div>
        <h3 class="font-bold text-lg text-gray-900 dark:text-white mb-2">Contacter le support</h3>
        <p class="text-gray-600 dark:text-gray-400 dark:text-gray-500 text-sm">Obtenez de l'aide personnalisée</p>
      </div>
    </div>

    <!-- Articles populaires -->
    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
      <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-4">Articles populaires</h3>
      <div class="space-y-3">
        <a href="#" class="flex items-center justify-between p-3 hover:bg-gray-50 dark:hover:bg-gray-700 rounded-lg transition-colors">
          <span class="text-gray-700 dark:text-gray-300">Comment créer ma première récompense ?</span>
          <ChevronRight :size="18" class="text-gray-400 dark:text-gray-500" />
        </a>
        <a href="#" class="flex items-center justify-between p-3 hover:bg-gray-50 dark:hover:bg-gray-700 rounded-lg transition-colors">
          <span class="text-gray-700 dark:text-gray-300">Gérer les points de fidélité</span>
          <ChevronRight :size="18" class="text-gray-400 dark:text-gray-500" />
        </a>
        <a href="#" class="flex items-center justify-between p-3 hover:bg-gray-50 dark:hover:bg-gray-700 rounded-lg transition-colors">
          <span class="text-gray-700 dark:text-gray-300">Personnaliser ma carte de fidélité</span>
          <ChevronRight :size="18" class="text-gray-400 dark:text-gray-500" />
        </a>
        <a href="#" class="flex items-center justify-between p-3 hover:bg-gray-50 dark:hover:bg-gray-700 rounded-lg transition-colors">
          <span class="text-gray-700 dark:text-gray-300">Analyser mes statistiques</span>
          <ChevronRight :size="18" class="text-gray-400 dark:text-gray-500" />
        </a>
      </div>
    </div>

    <!-- Contact direct -->
    <div class="bg-gradient-to-r from-violet-600 to-pink-600 rounded-2xl p-8 text-white">
      <h3 class="text-2xl font-bold mb-4">Besoin d'aide supplémentaire ?</h3>
      <p class="text-white/80 mb-6">Notre équipe est là pour vous aider</p>
      <div class="flex flex-col md:flex-row gap-4">
        <button class="px-6 py-3 bg-white dark:bg-gray-800 text-violet-600 rounded-xl font-bold hover:scale-105 transition-all duration-300 flex items-center justify-center space-x-2">
          <Mail :size="20" />
          <span>support@fidapp.com</span>
        </button>
        <button class="px-6 py-3 bg-white dark:bg-gray-800/20 hover:bg-white dark:bg-gray-800/30 backdrop-blur text-white rounded-xl font-bold transition-colors flex items-center justify-center space-x-2">
          <Phone :size="20" />
          <span>+33 1 23 45 67 89</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Search, BookOpen, HelpCircle, MessageCircle, ChevronRight, Mail, Phone } from 'lucide-vue-next'
</script>