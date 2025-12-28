// API Apple Wallet - Temporairement désactivée pour le déploiement

export interface WalletPassRequest {
  customerId: string;
  companyId: string;
}

export interface WalletPassResponse {
  passUrl: string;
  serialNumber: string;
  expiresAt: string;
}

export async function generateWalletPass(request: WalletPassRequest): Promise<WalletPassResponse> {
  // Temporairement désactivé
  console.log('Apple Wallet API temporairement désactivée');
  
  return {
    passUrl: '#',
    serialNumber: 'disabled',
    expiresAt: new Date().toISOString()
  };
}

export async function updateWalletPass(serialNumber: string, points: number): Promise<void> {
  console.log('Update pass disabled');
}

export async function handleWebServiceRequest(
  method: string,
  path: string,
  body?: any,
  headers?: any
): Promise<any> {
  return { status: 501, message: 'Not implemented' };
}