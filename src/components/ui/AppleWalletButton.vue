<template>
  <div class="space-y-3">
    <!-- Bouton principal Apple Wallet -->
    <button
      v-if="isAvailable && !isLoading && !isAdded"
      @click="handleAddToWallet"
      class="w-full bg-black text-white rounded-lg px-6 py-3 flex items-center justify-center space-x-3 hover:bg-gray-900 transition-colors shadow-lg"
    >
      <svg class="w-8 h-8" viewBox="0 0 24 24" fill="currentColor">
        <path d="M17.39 14.56c-.01.57-.35 1.07-.89 1.3-.19.08-.39.12-.59.12-.36 0-.71-.13-.98-.37l-7.88-7c-.29-.26-.46-.62-.48-1.01-.02-.39.12-.76.38-1.04.25-.27.6-.43.98-.45.38-.01.75.13 1.03.38l7.88 7c.54.48.57 1.31.09 1.85-.03.04-.07.07-.1.1l-.44.12zm-7.87-8.96c-.4 0-.78.15-1.07.42-.29.28-.45.65-.44 1.05.02.4.2.77.5 1.03l7.88 7c.28.25.64.38 1.01.38.21 0 .42-.04.61-.13.56-.24.92-.77.93-1.37.01-.6-.33-1.14-.87-1.41l-7.88-7c-.29-.26-.66-.4-1.04-.38-.38.02-.74.19-1 .47-.26.29-.4.67-.38 1.06.02.4.2.77.49 1.03l5.85 5.19c.11.09.24.14.38.14s.27-.05.38-.14c.21-.19.22-.51.03-.71l-5.85-5.19c-.08-.07-.13-.17-.14-.28-.01-.11.03-.22.1-.3.07-.08.17-.13.28-.14.11 0 .22.03.3.1l7.88 7c.37.33.41.9.08 1.28-.33.37-.9.41-1.28.08l-7.88-7c-.37-.33-.59-.8-.61-1.31-.02-.51.16-.99.49-1.35.33-.36.8-.57 1.31-.59.51-.02.99.16 1.35.49z"/>
      </svg>
      <span class="font-medium">Ajouter à Apple Wallet</span>
    </button>

    <!-- État de chargement -->
    <div v-if="isLoading" class="w-full bg-gray-100 rounded-lg px-6 py-3 flex items-center justify-center space-x-3">
      <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-gray-900"></div>
      <span class="text-gray-600">Génération en cours...</span>
    </div>

    <!-- Carte déjà ajoutée -->
    <div v-if="isAdded" class="w-full bg-green-50 border border-green-200 rounded-lg px-6 py-3 flex items-center justify-center space-x-3">
      <CheckCircle :size="20" class="text-green-600" />
      <span class="text-green-800 font-medium">Carte ajoutée à Apple Wallet</span>
    </div>

    <!-- Non disponible sur cet appareil -->
    <div v-if="!isAvailable && !isLoading" class="text-center space-y-2">
      <p class="text-sm text-gray-500">
        Apple Wallet n'est pas disponible sur cet appareil
      </p>
      <button
        @click="showQRCode = true"
        class="text-violet-600 hover:text-violet-700 font-medium text-sm underline"
      >
        Afficher le QR code à la place
      </button>
    </div>

    <!-- Message d'erreur -->
    <div v-if="errorMessage" class="w-full bg-red-50 border border-red-200 rounded-lg px-4 py-3">
      <p class="text-red-800 text-sm">{{ errorMessage }}</p>
    </div>

    <!-- Modal QR Code de secours -->
    <Teleport to="body">
      <div v-if="showQRCode" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
        <div class="bg-white rounded-xl shadow-2xl max-w-md w-full p-6">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-bold">QR Code de votre carte</h3>
            <button @click="showQRCode = false" class="text-gray-400 hover:text-gray-600">
              <X :size="20" />
            </button>
          </div>
          <div class="flex justify-center mb-4">
            <canvas ref="qrCanvas" class="border-2 border-gray-200 rounded-lg"></canvas>
          </div>
          <p class="text-sm text-gray-600 text-center">
            Présentez ce QR code lors de vos achats pour accumuler et utiliser vos points
          </p>
        </div>
      </div>
    </Teleport>

    <!-- Instructions pour l'ajout -->
    <div v-if="showInstructions" class="bg-blue-50 border border-blue-200 rounded-lg p-4 mt-4">
      <h4 class="font-semibold text-blue-900 mb-2">Comment ajouter à Apple Wallet :</h4>
      <ol class="list-decimal list-inside space-y-1 text-sm text-blue-800">
        <li>Cliquez sur le bouton "Ajouter à Apple Wallet"</li>
        <li>Le fichier de la carte sera téléchargé</li>
        <li>Ouvrez le fichier téléchargé</li>
        <li>Suivez les instructions pour ajouter la carte</li>
      </ol>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import { CheckCircle, X } from 'lucide-vue-next';
import QRCode from 'qrcode';
import { isWalletAvailable } from '@/services/appleWallet';
import { generateWalletPass } from '@/api/walletEndpoint';
import { useAuthStore } from '@/stores/auth';

const props = defineProps<{
  customerId: string;
  companyId: string;
  qrCodeValue: string;
  showInstructions?: boolean;
}>();

const emit = defineEmits<{
  added: [serialNumber: string];
  error: [error: Error];
}>();

const authStore = useAuthStore();
const isAvailable = ref(false);
const isLoading = ref(false);
const isAdded = ref(false);
const errorMessage = ref('');
const showQRCode = ref(false);
const qrCanvas = ref<HTMLCanvasElement>();

onMounted(() => {
  isAvailable.value = isWalletAvailable();
  checkIfAlreadyAdded();
});

watch(() => showQRCode.value, async (show) => {
  if (show && qrCanvas.value) {
    await generateQRCode();
  }
});

async function checkIfAlreadyAdded() {
  const addedPasses = localStorage.getItem('walletPasses') || '{}';
  const passes = JSON.parse(addedPasses);
  isAdded.value = !!passes[`${props.companyId}-${props.customerId}`];
}

async function handleAddToWallet() {
  // Fonctionnalité temporairement désactivée
  console.log('Apple Wallet temporairement désactivé');
  errorMessage.value = 'Cette fonctionnalité sera bientôt disponible';
  setTimeout(() => {
    errorMessage.value = '';
  }, 3000);
}

async function generateQRCode() {
  if (!qrCanvas.value) return;
  
  try {
    await QRCode.toCanvas(qrCanvas.value, props.qrCodeValue, {
      width: 256,
      margin: 2,
      color: {
        dark: '#000000',
        light: '#FFFFFF'
      }
    });
  } catch (error) {
    console.error('Erreur génération QR code:', error);
  }
}
</script>