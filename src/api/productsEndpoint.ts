// API pour gérer les produits et les achats
import { supabase } from '../services/supabase'

export interface Product {
  id: string
  name: string
  description: string
  points: number
  price?: number
  category: string
  stock?: number
  unlimited_stock: boolean
  is_active: boolean
  display_order: number
}

export interface ProductPurchase {
  product_id: string
  customer_id: string
  quantity: number
  processed_by?: string
  processed_by_name?: string
}

// Récupérer tous les produits d'une entreprise
export async function getCompanyProducts(): Promise<Product[]> {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return []

    const { data, error } = await supabase
      .from('products')
      .select('*')
      .eq('company_id', user.id)
      .order('display_order', { ascending: true })

    if (error) {
      console.error('Erreur récupération produits:', error)
      return []
    }

    return data || []
  } catch (error) {
    console.error('Erreur getCompanyProducts:', error)
    return []
  }
}

// Récupérer uniquement les produits actifs
export async function getActiveProducts(): Promise<Product[]> {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return []

    const { data, error } = await supabase
      .from('products')
      .select('*')
      .eq('company_id', user.id)
      .eq('is_active', true)
      .order('display_order', { ascending: true })

    if (error) {
      console.error('Erreur récupération produits actifs:', error)
      return []
    }

    return data || []
  } catch (error) {
    console.error('Erreur getActiveProducts:', error)
    return []
  }
}

// Effectuer un achat de produit
export async function purchaseProduct(
  purchase: ProductPurchase
): Promise<{ success: boolean; message: string; remainingPoints?: number }> {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return { success: false, message: 'Non authentifié' }
    }

    // Appeler la fonction SQL qui gère l'achat
    const { data, error } = await supabase
      .rpc('purchase_product', {
        p_customer_id: purchase.customer_id,
        p_product_id: purchase.product_id,
        p_quantity: purchase.quantity,
        p_processed_by: user.id,
        p_processed_by_name: user.email
      })
      .single()

    if (error) {
      console.error('Erreur achat produit:', error)
      return { 
        success: false, 
        message: error.message || 'Erreur lors de l\'achat' 
      }
    }

    return {
      success: data.success,
      message: data.message,
      remainingPoints: data.remaining_points
    }
  } catch (error) {
    console.error('Erreur purchaseProduct:', error)
    return { 
      success: false, 
      message: 'Erreur système lors de l\'achat' 
    }
  }
}

// Ajouter ou retirer des points manuellement
export async function adjustCustomerPoints(
  customerId: string,
  points: number,
  reason: string
): Promise<{ success: boolean; message: string; newPoints?: number }> {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return { success: false, message: 'Non authentifié' }
    }

    // Récupérer le client actuel
    const { data: customer, error: fetchError } = await supabase
      .from('customers')
      .select('points, company_id')
      .eq('id', customerId)
      .single()

    if (fetchError || !customer) {
      return { success: false, message: 'Client non trouvé' }
    }

    // Calculer les nouveaux points
    const newPoints = customer.points + points
    
    // Vérifier que les points ne deviennent pas négatifs
    if (newPoints < 0) {
      return { 
        success: false, 
        message: 'Points insuffisants',
        newPoints: customer.points 
      }
    }

    // Mettre à jour les points
    const { error: updateError } = await supabase
      .from('customers')
      .update({ 
        points: newPoints,
        updated_at: new Date().toISOString()
      })
      .eq('id', customerId)

    if (updateError) {
      return { success: false, message: 'Erreur lors de la mise à jour' }
    }

    // Enregistrer dans l'historique des scans
    const scanType = points > 0 ? 'points_add' : 'points_add'
    const { error: scanError } = await supabase
      .from('qr_scan_history')
      .insert({
        customer_id: customerId,
        company_id: customer.company_id,
        scanned_by: user.id,
        scanned_by_name: user.email,
        scan_type: scanType,
        points_added: Math.abs(points),
        location: `Admin: ${reason}`
      })

    if (scanError) {
      console.error('Erreur enregistrement historique:', scanError)
    }

    return {
      success: true,
      message: points > 0 
        ? `${points} points ajoutés avec succès`
        : `${Math.abs(points)} points retirés avec succès`,
      newPoints
    }
  } catch (error) {
    console.error('Erreur adjustCustomerPoints:', error)
    return { 
      success: false, 
      message: 'Erreur système' 
    }
  }
}

// Récupérer l'historique des achats d'un client
export async function getCustomerPurchaseHistory(customerId: string): Promise<any[]> {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return []

    const { data, error } = await supabase
      .from('product_purchases')
      .select(`
        *,
        products (
          name,
          description,
          category
        )
      `)
      .eq('customer_id', customerId)
      .eq('company_id', user.id)
      .order('purchased_at', { ascending: false })
      .limit(50)

    if (error) {
      console.error('Erreur récupération historique achats:', error)
      return []
    }

    return data || []
  } catch (error) {
    console.error('Erreur getCustomerPurchaseHistory:', error)
    return []
  }
}