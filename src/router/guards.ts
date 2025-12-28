import { NavigationGuardNext, RouteLocationNormalized } from 'vue-router'
import { supabase } from '@/services/supabase'
import { loadUserPermissions, canAccessRoute, currentUserPermissions } from '@/services/permissions'

// Guard pour vérifier l'authentification
export async function authGuard(
  to: RouteLocationNormalized,
  from: RouteLocationNormalized,
  next: NavigationGuardNext
) {
  const { data: { user } } = await supabase.auth.getUser()
  
  // Routes publiques qui ne nécessitent pas d'authentification
  const publicRoutes = ['/', '/login', '/register', '/pricing', '/features', '/about', '/contact']
  
  if (publicRoutes.includes(to.path)) {
    next()
    return
  }
  
  // Si pas connecté, rediriger vers login
  if (!user) {
    next('/login')
    return
  }
  
  // Charger les permissions si pas déjà chargées
  if (!currentUserPermissions.value) {
    await loadUserPermissions()
  }
  
  next()
}

// Guard pour vérifier les permissions
export async function permissionGuard(
  to: RouteLocationNormalized,
  from: RouteLocationNormalized,
  next: NavigationGuardNext
) {
  // Attendre que les permissions soient chargées
  if (!currentUserPermissions.value) {
    const permissions = await loadUserPermissions()
    
    if (!permissions) {
      next('/login')
      return
    }
  }
  
  // Vérifier l'accès à la route
  if (!canAccessRoute(to.path)) {
    // Rediriger selon le type de compte
    const accountType = currentUserPermissions.value?.accountType
    
    switch (accountType) {
      case 'free':
        next('/dashboard-free')
        break
      case 'starter':
      case 'premium':
        next('/dashboard')
        break
      case 'admin':
        next('/admin')
        break
      default:
        next('/')
    }
    return
  }
  
  next()
}

// Guard spécifique pour l'admin
export function adminGuard(
  to: RouteLocationNormalized,
  from: RouteLocationNormalized,
  next: NavigationGuardNext
) {
  const isAdmin = currentUserPermissions.value?.accountType === 'admin'
  
  if (!isAdmin) {
    next('/dashboard')
    return
  }
  
  next()
}

// Guard pour les pages de type de compte
export function accountTypeGuard(requiredType: string | string[]) {
  return (
    to: RouteLocationNormalized,
    from: RouteLocationNormalized,
    next: NavigationGuardNext
  ) => {
    const accountType = currentUserPermissions.value?.accountType
    const types = Array.isArray(requiredType) ? requiredType : [requiredType]
    
    if (!accountType || !types.includes(accountType)) {
      next('/pricing') // Rediriger vers la page de tarification pour upgrade
      return
    }
    
    next()
  }
}