import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Types pour les tables de base de données
export interface User {
  id?: string
  email: string
  password?: string
  company: string
  first_name: string
  last_name: string
  accept_newsletter?: boolean
  created_at?: string
  updated_at?: string
}

export interface Session {
  id?: string
  user_id: string
  token: string
  expires_at: string
  created_at?: string
}

// Service d'authentification
export const authService = {
  async login(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    return { data, error }
  },

  async register(user: User & { password: string }) {
    const { data, error } = await supabase.auth.signUp({
      email: user.email,
      password: user.password,
      options: {
        data: {
          company: user.company,
          first_name: user.first_name,
          last_name: user.last_name,
          accept_newsletter: user.accept_newsletter
        }
      }
    })
    return { data, error }
  },

  async logout() {
    const { error } = await supabase.auth.signOut()
    return { error }
  },

  async getCurrentUser() {
    const { data: { user } } = await supabase.auth.getUser()
    return user
  },

  onAuthStateChange(callback: (event: any, session: any) => void) {
    return supabase.auth.onAuthStateChange(callback)
  }
}

// Service pour les opérations CRUD
export const dataService = {
  async getUsers() {
    const { data, error } = await supabase
      .from('users')
      .select('*')
    return { data, error }
  },

  async getUserById(id: string) {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', id)
      .single()
    return { data, error }
  },

  async updateUser(id: string, updates: Partial<User>) {
    const { data, error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', id)
    return { data, error }
  },

  async deleteUser(id: string) {
    const { data, error } = await supabase
      .from('users')
      .delete()
      .eq('id', id)
    return { data, error }
  }
}