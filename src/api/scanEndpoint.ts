// API pour enregistrer et gérer les scans QR code
import { supabase } from '../services/supabase'

export interface ScanRequest {
  customerId: string
  scanType: 'points_add' | 'reward_claim' | 'check_balance' | 'attendance' | 'registration'
  pointsAdded?: number
  euroAmount?: number
  location?: string
}

export interface ScanStats {
  totalScans: number
  totalUniqueClients: number
  scansToday: number
  scansThisWeek: number
  scansThisMonth: number
  averageScansPerDay: number
}

export interface ScanHistoryItem {
  id: string
  customerId: string
  customerName: string
  scanType: string
  pointsAdded: number | null
  euroAmount: number | null
  scannedBy: string | null
  scannedByName: string | null
  location: string | null
  scannedAt: string
}

// Enregistrer un nouveau scan
export async function recordScan(request: ScanRequest): Promise<{ success: boolean; error?: string }> {
  try {
    // Obtenir l'utilisateur connecté
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      return { success: false, error: 'Non authentifié' }
    }

    // Obtenir les infos du client
    const { data: customer, error: customerError } = await supabase
      .from('customers')
      .select('id, company_id, first_name, last_name')
      .eq('id', request.customerId)
      .single()

    if (customerError || !customer) {
      return { success: false, error: 'Client non trouvé' }
    }

    // Enregistrer le scan
    const { error: insertError } = await supabase
      .from('qr_scan_history')
      .insert({
        customer_id: request.customerId,
        company_id: customer.company_id,
        scanned_by: user.id,
        scanned_by_name: user.email,
        scan_type: request.scanType,
        points_added: request.pointsAdded || null,
        euro_amount: request.euroAmount || null,
        location: request.location || null,
        device: navigator.userAgent,
        user_agent: navigator.userAgent
      })

    if (insertError) {
      console.error('Erreur lors de l\'enregistrement du scan:', insertError)
      return { success: false, error: 'Erreur lors de l\'enregistrement' }
    }

    return { success: true }
  } catch (error) {
    console.error('Erreur recordScan:', error)
    return { success: false, error: 'Erreur système' }
  }
}

// Obtenir les statistiques de scans
export async function getScanStats(): Promise<ScanStats | null> {
  try {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) return null

    // Appeler la fonction SQL qui calcule les stats
    const { data, error } = await supabase
      .rpc('get_scan_stats', { p_company_id: user.id })
      .single()

    if (error) {
      console.error('Erreur lors de la récupération des stats:', error)
      return null
    }

    return {
      totalScans: data.total_scans || 0,
      totalUniqueClients: data.total_unique_clients || 0,
      scansToday: data.scans_today || 0,
      scansThisWeek: data.scans_this_week || 0,
      scansThisMonth: data.scans_this_month || 0,
      averageScansPerDay: parseFloat(data.average_scans_per_day) || 0
    }
  } catch (error) {
    console.error('Erreur getScanStats:', error)
    return null
  }
}

// Obtenir l'historique des scans
export async function getScanHistory(customerId?: string, limit: number = 50): Promise<ScanHistoryItem[]> {
  try {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) return []

    let query = supabase
      .from('qr_scan_history')
      .select(`
        id,
        customer_id,
        scan_type,
        points_added,
        euro_amount,
        scanned_by,
        scanned_by_name,
        location,
        scanned_at,
        customers (
          first_name,
          last_name
        )
      `)
      .eq('company_id', user.id)
      .order('scanned_at', { ascending: false })
      .limit(limit)

    if (customerId) {
      query = query.eq('customer_id', customerId)
    }

    const { data, error } = await query

    if (error) {
      console.error('Erreur lors de la récupération de l\'historique:', error)
      return []
    }

    return data.map(scan => ({
      id: scan.id,
      customerId: scan.customer_id,
      customerName: `${scan.customers.first_name} ${scan.customers.last_name}`,
      scanType: scan.scan_type,
      pointsAdded: scan.points_added,
      euroAmount: scan.euro_amount,
      scannedBy: scan.scanned_by,
      scannedByName: scan.scanned_by_name,
      location: scan.location,
      scannedAt: scan.scanned_at
    }))
  } catch (error) {
    console.error('Erreur getScanHistory:', error)
    return []
  }
}

// Obtenir les données pour le graphique
export async function getScanChartData(days: number = 30): Promise<{ date: string; scans: number }[]> {
  try {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) return []

    const startDate = new Date()
    startDate.setDate(startDate.getDate() - days)

    const { data, error } = await supabase
      .from('scan_stats_daily')
      .select('scan_date, total_scans')
      .eq('company_id', user.id)
      .gte('scan_date', startDate.toISOString().split('T')[0])
      .order('scan_date', { ascending: true })

    if (error) {
      console.error('Erreur lors de la récupération des données du graphique:', error)
      return []
    }

    // Créer un tableau avec tous les jours, même ceux sans scans
    const chartData: { date: string; scans: number }[] = []
    const dataMap = new Map(data.map(d => [d.scan_date, d.total_scans]))

    for (let i = 0; i < days; i++) {
      const date = new Date()
      date.setDate(date.getDate() - (days - i - 1))
      const dateStr = date.toISOString().split('T')[0]
      
      chartData.push({
        date: new Date(dateStr).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short' }),
        scans: dataMap.get(dateStr) || 0
      })
    }

    return chartData
  } catch (error) {
    console.error('Erreur getScanChartData:', error)
    return []
  }
}

// Obtenir les top clients scannés
export async function getTopScannedCustomers(limit: number = 5): Promise<any[]> {
  try {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) return []

    const { data, error } = await supabase
      .from('top_scanned_customers')
      .select('*')
      .eq('company_id', user.id)
      .limit(limit)

    if (error) {
      console.error('Erreur lors de la récupération des top clients:', error)
      return []
    }

    return data
  } catch (error) {
    console.error('Erreur getTopScannedCustomers:', error)
    return []
  }
}