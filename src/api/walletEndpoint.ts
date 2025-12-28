import { createClient } from '@supabase/supabase-js';
import { AppleWalletService, type AppleWalletConfig } from '../services/appleWallet';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface WalletPassRequest {
  customerId: string;
  companyId: string;
}

export interface WalletPassResponse {
  passUrl: string;
  serialNumber: string;
  expiresAt: string;
}

const walletConfig: AppleWalletConfig = {
  teamIdentifier: import.meta.env.VITE_APPLE_TEAM_ID || '',
  passTypeIdentifier: import.meta.env.VITE_APPLE_PASS_TYPE_ID || '',
  organizationName: 'FidApp',
  description: 'Carte de fidélité',
  certificates: {
    wwdr: import.meta.env.VITE_APPLE_WWDR_CERT || '',
    signerCert: import.meta.env.VITE_APPLE_SIGNER_CERT || '',
    signerKey: import.meta.env.VITE_APPLE_SIGNER_KEY || '',
    signerKeyPassphrase: import.meta.env.VITE_APPLE_KEY_PASSPHRASE
  }
};

export async function generateWalletPass(request: WalletPassRequest): Promise<WalletPassResponse> {
  try {
    const { data: customer, error: customerError } = await supabase
      .from('customers')
      .select('*')
      .eq('id', request.customerId)
      .eq('company_id', request.companyId)
      .single();

    if (customerError || !customer) {
      throw new Error('Client non trouvé');
    }

    const { data: company, error: companyError } = await supabase
      .from('users')
      .select('company_name, logo_url, primary_color, qr_code_id, card_bg_color, card_text_color')
      .eq('id', request.companyId)
      .single();

    if (companyError || !company) {
      throw new Error('Entreprise non trouvée');
    }

    const walletService = new AppleWalletService(walletConfig);
    
    const passData = {
      companyName: company.company_name,
      companyLogo: company.logo_url,
      customerName: `${customer.first_name} ${customer.last_name}`,
      customerId: customer.id,
      points: customer.points || 0,
      qrCodeValue: `${window.location.origin}/c/${company.qr_code_id}?cid=${customer.id}`,
      cardNumber: formatCardNumber(customer.id),
      backgroundColor: company.card_bg_color || '#3C414C',
      foregroundColor: company.card_text_color || '#FFFFFF',
      labelColor: company.primary_color || '#FFD700'
    };

    const passBuffer = await walletService.generateLoyaltyPass(passData);
    
    const { data: passRecord, error: passError } = await supabase
      .from('apple_wallet_passes')
      .insert({
        customer_id: customer.id,
        company_id: request.companyId,
        serial_number: `${customer.id}-${Date.now()}`,
        pass_data: passData,
        last_updated: new Date().toISOString()
      })
      .select()
      .single();

    if (passError) {
      console.error('Erreur lors de l\'enregistrement du pass:', passError);
    }

    const passUrl = walletService.generateDownloadUrl(passBuffer);
    
    return {
      passUrl,
      serialNumber: passRecord?.serial_number || '',
      expiresAt: new Date(Date.now() + 3600000).toISOString()
    };
  } catch (error) {
    console.error('Erreur lors de la génération du pass:', error);
    throw error;
  }
}

export async function updateWalletPass(serialNumber: string, points: number): Promise<void> {
  try {
    const { data: passRecord, error } = await supabase
      .from('apple_wallet_passes')
      .select('*')
      .eq('serial_number', serialNumber)
      .single();

    if (error || !passRecord) {
      throw new Error('Pass non trouvé');
    }

    await supabase
      .from('apple_wallet_passes')
      .update({
        pass_data: {
          ...passRecord.pass_data,
          points
        },
        last_updated: new Date().toISOString(),
        needs_update: true
      })
      .eq('serial_number', serialNumber);

    await sendPushNotification(serialNumber, {
      type: 'points_update',
      points
    });
  } catch (error) {
    console.error('Erreur lors de la mise à jour du pass:', error);
    throw error;
  }
}

async function sendPushNotification(serialNumber: string, data: any): Promise<void> {
  console.log(`Notification push pour ${serialNumber}:`, data);
}

function formatCardNumber(id: string): string {
  const clean = id.replace(/-/g, '').toUpperCase().substring(0, 16);
  return clean.match(/.{1,4}/g)?.join(' ') || clean;
}

export async function handleWebServiceRequest(
  method: string,
  path: string,
  body?: any,
  headers?: any
): Promise<any> {
  const pathParts = path.split('/');
  
  if (method === 'POST' && pathParts[1] === 'devices' && pathParts[3] === 'registrations') {
    const deviceId = pathParts[2];
    const passTypeId = pathParts[4];
    const serialNumber = pathParts[5];
    
    const { error } = await supabase
      .from('wallet_devices')
      .upsert({
        device_id: deviceId,
        pass_type_id: passTypeId,
        serial_number: serialNumber,
        push_token: body.pushToken,
        registered_at: new Date().toISOString()
      });
    
    if (error) throw error;
    
    return { status: 201 };
  }
  
  if (method === 'DELETE' && pathParts[1] === 'devices') {
    const deviceId = pathParts[2];
    const serialNumber = pathParts[5];
    
    await supabase
      .from('wallet_devices')
      .delete()
      .eq('device_id', deviceId)
      .eq('serial_number', serialNumber);
    
    return { status: 200 };
  }
  
  if (method === 'GET' && pathParts[1] === 'passes') {
    const serialNumber = pathParts[2];
    
    const { data, error } = await supabase
      .from('apple_wallet_passes')
      .select('*')
      .eq('serial_number', serialNumber)
      .single();
    
    if (error) throw error;
    
    const walletService = new AppleWalletService(walletConfig);
    const passBuffer = await walletService.generateLoyaltyPass(data.pass_data);
    
    return {
      status: 200,
      headers: {
        'Content-Type': 'application/vnd.apple.pkpass',
        'Last-Modified': data.last_updated
      },
      body: passBuffer
    };
  }
  
  return { status: 404 };
}