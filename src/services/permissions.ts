import { ref, computed } from 'vue'
import { supabase } from './supabase'

// Types
export type AccountType = 'free' | 'starter' | 'premium' | 'admin'
export type UserRole = 'owner' | 'admin' | 'manager' | 'employee' | 'super_admin'

export interface UserPermissions {
  accountType: AccountType
  role: UserRole
  features: Record<string, boolean>
  limits: Record<string, any>
}

// État global des permissions
const currentUserPermissions = ref<UserPermissions | null>(null)

// Charger les permissions de l'utilisateur
export async function loadUserPermissions() {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      currentUserPermissions.value = null
      return null
    }

    // Récupérer les informations utilisateur avec les permissions
    const { data: userData } = await supabase
      .from('users')
      .select(`
        id,
        email,
        account_type,
        role,
        subscription_start_date,
        subscription_end_date
      `)
      .eq('auth_id', user.id)
      .single()

    if (!userData) {
      currentUserPermissions.value = null
      return null
    }

    // Récupérer les permissions pour ce type de compte
    const { data: permissions } = await supabase
      .from('user_permissions')
      .select('*')
      .eq('user_id', userData.id)

    // Récupérer les limites
    const { data: limits } = await supabase
      .from('account_limits')
      .select('*')
      .eq('account_type', userData.account_type)
      .single()

    // Construire l'objet permissions
    const features: Record<string, boolean> = {}
    const featureLimits: Record<string, any> = {}

    permissions?.forEach(perm => {
      features[perm.feature_name] = perm.is_enabled
      if (perm.limits) {
        featureLimits[perm.feature_name] = perm.limits
      }
    })

    currentUserPermissions.value = {
      accountType: userData.account_type as AccountType,
      role: userData.role as UserRole,
      features,
      limits: {
        ...limits,
        ...featureLimits
      }
    }

    return currentUserPermissions.value
  } catch (error) {
    console.error('Erreur lors du chargement des permissions:', error)
    currentUserPermissions.value = null
    return null
  }
}

// Vérifier si l'utilisateur a une permission spécifique
export function hasPermission(featureName: string): boolean {
  if (!currentUserPermissions.value) return false
  
  // Les admins ont toujours toutes les permissions
  if (currentUserPermissions.value.accountType === 'admin') return true
  
  return currentUserPermissions.value.features[featureName] === true
}

// Vérifier si l'utilisateur a accès à une route
export function canAccessRoute(routeName: string): boolean {
  const routePermissions: Record<string, string[]> = {
    '/dashboard': ['dashboard_view'],
    '/profile': ['profile_edit'],
    '/products': ['product_management'],
    '/campaigns': ['campaign_management'],
    '/customers': ['customer_management'],
    '/analytics': ['analytics_basic', 'analytics_advanced'],
    '/admin': ['admin_panel'],
    '/settings': ['system_settings'],
    '/team': ['team_management'],
    '/billing': ['billing_management']
  }

  const requiredPermissions = routePermissions[routeName]
  if (!requiredPermissions) return true // Route publique

  // Vérifier si l'utilisateur a au moins une des permissions requises
  return requiredPermissions.some(perm => hasPermission(perm))
}

// Obtenir les limites pour une fonctionnalité
export function getLimit(limitName: string): any {
  if (!currentUserPermissions.value) return null
  return currentUserPermissions.value.limits[limitName]
}

// Vérifier si l'utilisateur est dans la limite
export function isWithinLimit(limitName: string, currentValue: number): boolean {
  const limit = getLimit(limitName)
  if (!limit || typeof limit !== 'number') return true
  return currentValue < limit
}

// Computed pour vérifier les types de comptes
export const isFreeTier = computed(() => 
  currentUserPermissions.value?.accountType === 'free'
)

export const isStarterTier = computed(() => 
  currentUserPermissions.value?.accountType === 'starter'
)

export const isPremiumTier = computed(() => 
  currentUserPermissions.value?.accountType === 'premium'
)

export const isAdmin = computed(() => 
  currentUserPermissions.value?.accountType === 'admin'
)

export const isSuperAdmin = computed(() => 
  currentUserPermissions.value?.role === 'super_admin'
)

// Messages d'upgrade
export function getUpgradeMessage(feature: string): string {
  const messages: Record<string, Record<AccountType, string>> = {
    'product_management': {
      'free': 'Passez à Starter pour gérer jusqu\'à 50 produits',
      'starter': 'Passez à Premium pour gérer jusqu\'à 500 produits',
      'premium': '',
      'admin': ''
    },
    'campaign_management': {
      'free': 'Passez à Starter pour créer des campagnes marketing',
      'starter': 'Passez à Premium pour des campagnes illimitées',
      'premium': '',
      'admin': ''
    },
    'analytics_advanced': {
      'free': 'Passez à Premium pour accéder aux analytics avancées',
      'starter': 'Passez à Premium pour accéder aux analytics avancées',
      'premium': '',
      'admin': ''
    },
    'api_access': {
      'free': 'Passez à Premium pour accéder à l\'API',
      'starter': 'Passez à Premium pour accéder à l\'API',
      'premium': '',
      'admin': ''
    }
  }

  const accountType = currentUserPermissions.value?.accountType
  if (!accountType || !messages[feature]) return ''
  
  return messages[feature][accountType] || ''
}

// Export de l'état global
export { currentUserPermissions }

// Initialiser les permissions au démarrage
// Désactivé temporairement pour éviter le blocage
// if (typeof window !== 'undefined') {
//   loadUserPermissions()
// }