<template>
  <div class="relative">
    <!-- Bouton de notification avec badge -->
    <button 
      @click="toggleNotifications"
      class="relative p-2 text-gray-600 hover:text-violet-600 rounded-lg hover:bg-violet-50 transition-all duration-200"
    >
      <Bell :size="22" />
      <!-- Badge de notification -->
      <span 
        v-if="unreadCount > 0"
        class="absolute -top-0.5 -right-0.5 bg-red-500 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center animate-pulse"
      >
        {{ unreadCount > 9 ? '9+' : unreadCount }}
      </span>
    </button>
    
    <!-- Dropdown notifications -->
    <div 
      v-if="showNotifications"
      class="absolute right-0 mt-2 w-96 bg-white rounded-lg shadow-xl border border-gray-100 z-50 overflow-hidden"
    >
      <!-- En-tête -->
      <div class="px-4 py-3 border-b border-gray-100 bg-gradient-to-r from-violet-600 to-purple-600 text-white">
        <div class="flex items-center justify-between">
          <h3 class="font-semibold">Notifications</h3>
          <span v-if="unreadCount > 0" class="text-xs bg-white/20 px-2 py-1 rounded">
            {{ unreadCount }} non lue{{ unreadCount > 1 ? 's' : '' }}
          </span>
        </div>
      </div>
      
      <!-- Filtres rapides -->
      <div class="px-4 py-2 border-b border-gray-100 bg-gray-50 flex gap-2">
        <button
          @click="activeFilter = 'all'"
          :class="[
            'px-2 py-1 rounded text-xs font-medium transition-colors',
            activeFilter === 'all' 
              ? 'bg-violet-600 text-white' 
              : 'bg-white text-gray-600 hover:bg-gray-100'
          ]"
        >
          Toutes
        </button>
        <button
          @click="activeFilter = 'unread'"
          :class="[
            'px-2 py-1 rounded text-xs font-medium transition-colors',
            activeFilter === 'unread' 
              ? 'bg-violet-600 text-white' 
              : 'bg-white text-gray-600 hover:bg-gray-100'
          ]"
        >
          Non lues
        </button>
        <button
          @click="activeFilter = 'important'"
          :class="[
            'px-2 py-1 rounded text-xs font-medium transition-colors',
            activeFilter === 'important' 
              ? 'bg-violet-600 text-white' 
              : 'bg-white text-gray-600 hover:bg-gray-100'
          ]"
        >
          Importantes
        </button>
      </div>
      
      <!-- Liste des notifications -->
      <div class="max-h-96 overflow-y-auto">
        <!-- Chargement -->
        <div v-if="loading" class="p-8 text-center">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-violet-600 mx-auto"></div>
        </div>
        
        <!-- Notifications existantes -->
        <div v-else-if="filteredNotifications.length > 0">
          <button 
            v-for="notification in filteredNotifications"
            :key="notification.id"
            @click="handleNotificationClick(notification)"
            class="w-full text-left px-4 py-3 hover:bg-gray-50 transition-colors border-b border-gray-100 last:border-b-0 relative"
            :class="{ 'bg-blue-50': !notification.is_read }"
          >
            <!-- Indicateur non lu -->
            <div v-if="!notification.is_read" class="absolute left-0 top-0 bottom-0 w-1 bg-violet-600"></div>
            
            <div class="flex items-start gap-3">
              <!-- Icône selon le type -->
              <div :class="[
                'w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0',
                getNotificationColor(notification.type)
              ]">
                <component :is="getNotificationIcon(notification.type)" :size="20" />
              </div>
              
              <!-- Contenu -->
              <div class="flex-1 min-w-0">
                <div class="flex items-start justify-between">
                  <p class="text-sm font-medium text-gray-900">{{ notification.title }}</p>
                  <span class="text-xs text-gray-400 whitespace-nowrap ml-2">
                    {{ formatTime(notification.created_at) }}
                  </span>
                </div>
                <p class="text-sm text-gray-600 mt-1">{{ notification.message }}</p>
                
                <!-- Données supplémentaires -->
                <div v-if="notification.data" class="mt-2">
                  <div v-if="notification.type === 'new_customer'" class="flex items-center gap-2 text-xs text-gray-500">
                    <User :size="12" />
                    <span>{{ notification.data.customer_name }}</span>
                  </div>
                  <div v-else-if="notification.type === 'points_used'" class="flex items-center gap-2 text-xs text-gray-500">
                    <Coins :size="12" />
                    <span>{{ notification.data.points_spent }} points échangés</span>
                  </div>
                  <div v-else-if="notification.type === 'milestone_reached'" class="flex items-center gap-2 text-xs text-gray-500">
                    <Trophy :size="12" />
                    <span>{{ notification.data.current_value }}/{{ notification.data.target_value }}</span>
                  </div>
                </div>
                
                <!-- Badge de priorité -->
                <div v-if="notification.priority !== 'normal'" class="mt-2">
                  <span :class="[
                    'px-2 py-0.5 text-xs font-medium rounded',
                    getPriorityClass(notification.priority)
                  ]">
                    {{ getPriorityLabel(notification.priority) }}
                  </span>
                </div>
              </div>
            </div>
          </button>
        </div>
        
        <!-- Pas de notifications -->
        <div v-else class="px-4 py-8 text-center">
          <Bell :size="32" class="mx-auto text-gray-300 mb-3" />
          <p class="text-sm text-gray-500">Aucune notification</p>
        </div>
      </div>
      
      <!-- Pied de page -->
      <div class="px-4 py-3 border-t border-gray-100 bg-gray-50 flex items-center justify-between">
        <button 
          @click="markAllAsRead"
          v-if="unreadCount > 0"
          class="text-sm text-violet-600 hover:text-violet-700 font-medium"
        >
          Tout marquer comme lu
        </button>
        <router-link
          to="/dashboard?section=notifications"
          class="text-sm text-gray-600 hover:text-gray-800"
        >
          Voir tout →
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { Bell, User, Coins, Trophy, Gift, AlertCircle, Target, TrendingUp, Users } from 'lucide-vue-next'
import { supabase } from '@/services/supabase'
import { formatDistanceToNow } from 'date-fns'
import { fr } from 'date-fns/locale'

interface Notification {
  id: string
  type: string
  title: string
  message: string
  data?: any
  is_read: boolean
  priority: string
  category: string
  created_at: string
}

const notifications = ref<Notification[]>([])
const showNotifications = ref(false)
const loading = ref(false)
const activeFilter = ref('all')
const subscription = ref<any>(null)

const unreadCount = computed(() => 
  notifications.value.filter(n => !n.is_read).length
)

const filteredNotifications = computed(() => {
  let filtered = notifications.value
  
  if (activeFilter.value === 'unread') {
    filtered = filtered.filter(n => !n.is_read)
  } else if (activeFilter.value === 'important') {
    filtered = filtered.filter(n => n.priority === 'high' || n.priority === 'urgent')
  }
  
  // Trier par date (plus récent en premier) et statut de lecture
  return filtered.sort((a, b) => {
    if (!a.is_read && b.is_read) return -1
    if (a.is_read && !b.is_read) return 1
    return new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
  })
})

const getNotificationIcon = (type: string) => {
  const icons: Record<string, any> = {
    new_customer: Users,
    points_used: Coins,
    points_earned: TrendingUp,
    reward_redeemed: Gift,
    milestone_reached: Trophy,
    alert: AlertCircle,
    default: Bell
  }
  return icons[type] || icons.default
}

const getNotificationColor = (type: string) => {
  const colors: Record<string, string> = {
    new_customer: 'bg-green-100 text-green-600',
    points_used: 'bg-blue-100 text-blue-600',
    points_earned: 'bg-purple-100 text-purple-600',
    reward_redeemed: 'bg-pink-100 text-pink-600',
    milestone_reached: 'bg-amber-100 text-amber-600',
    alert: 'bg-red-100 text-red-600',
    default: 'bg-gray-100 text-gray-600'
  }
  return colors[type] || colors.default
}

const getPriorityClass = (priority: string) => {
  const classes: Record<string, string> = {
    low: 'bg-gray-100 text-gray-700',
    normal: 'bg-blue-100 text-blue-700',
    high: 'bg-amber-100 text-amber-700',
    urgent: 'bg-red-100 text-red-700'
  }
  return classes[priority] || classes.normal
}

const getPriorityLabel = (priority: string) => {
  const labels: Record<string, string> = {
    low: 'Faible',
    normal: 'Normal',
    high: 'Important',
    urgent: 'Urgent'
  }
  return labels[priority] || priority
}

const formatTime = (date: string) => {
  try {
    return formatDistanceToNow(new Date(date), { 
      addSuffix: true,
      locale: fr 
    })
  } catch {
    return ''
  }
}

const toggleNotifications = () => {
  showNotifications.value = !showNotifications.value
  if (showNotifications.value) {
    loadNotifications()
  }
}

const loadNotifications = async () => {
  loading.value = true
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data, error } = await supabase
      .from('notifications')
      .select('*')
      .eq('company_id', user.id)
      .order('created_at', { ascending: false })
      .limit(20)

    if (!error && data) {
      notifications.value = data
    }
  } catch (error) {
    console.error('Erreur chargement notifications:', error)
  } finally {
    loading.value = false
  }
}

const handleNotificationClick = async (notification: Notification) => {
  // Marquer comme lu
  if (!notification.is_read) {
    await markAsRead(notification.id)
  }
  
  // Naviguer vers l'action si disponible
  if (notification.data?.customer_id) {
    // Navigation vers le client
    console.log('Navigate to customer:', notification.data.customer_id)
  }
  
  showNotifications.value = false
}

const markAsRead = async (notificationId: string) => {
  try {
    const { error } = await supabase
      .from('notifications')
      .update({ is_read: true, read_at: new Date().toISOString() })
      .eq('id', notificationId)

    if (!error) {
      const notification = notifications.value.find(n => n.id === notificationId)
      if (notification) {
        notification.is_read = true
      }
    }
  } catch (error) {
    console.error('Erreur marquage notification:', error)
  }
}

const markAllAsRead = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const unreadIds = notifications.value
      .filter(n => !n.is_read)
      .map(n => n.id)

    if (unreadIds.length === 0) return

    const { error } = await supabase
      .from('notifications')
      .update({ is_read: true, read_at: new Date().toISOString() })
      .in('id', unreadIds)

    if (!error) {
      notifications.value.forEach(n => {
        n.is_read = true
      })
    }
  } catch (error) {
    console.error('Erreur marquage notifications:', error)
  }
}

// Écouter les nouvelles notifications en temps réel
const subscribeToNotifications = async () => {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return

  subscription.value = supabase
    .channel('notifications')
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'notifications',
        filter: `company_id=eq.${user.id}`
      },
      (payload) => {
        // Ajouter la nouvelle notification en début de liste
        notifications.value.unshift(payload.new as Notification)
        
        // Afficher une notification système si autorisé
        if ('Notification' in window && Notification.permission === 'granted') {
          new Notification(payload.new.title, {
            body: payload.new.message,
            icon: '/logo.png'
          })
        }
      }
    )
    .subscribe()
}

// Demander la permission pour les notifications système
const requestNotificationPermission = async () => {
  if ('Notification' in window && Notification.permission === 'default') {
    await Notification.requestPermission()
  }
}

// Fermer le dropdown en cliquant ailleurs
const handleClickOutside = (e: MouseEvent) => {
  const target = e.target as HTMLElement
  if (!target.closest('.relative')) {
    showNotifications.value = false
  }
}

onMounted(() => {
  loadNotifications()
  subscribeToNotifications()
  requestNotificationPermission()
  window.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  if (subscription.value) {
    subscription.value.unsubscribe()
  }
  window.removeEventListener('click', handleClickOutside)
})
</script>