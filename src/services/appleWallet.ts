// Service Apple Wallet - Temporairement désactivé pour le déploiement

export interface LoyaltyCardData {
  companyName: string;
  companyLogo?: string;
  customerName: string;
  customerId: string;
  points: number;
  qrCodeValue: string;
  cardNumber: string;
  backgroundColor?: string;
  foregroundColor?: string;
  labelColor?: string;
}

export function isWalletAvailable(): boolean {
  // Temporairement désactivé
  return false;
}

export function formatCardNumber(customerId: string): string {
  const clean = customerId.replace(/-/g, '').toUpperCase();
  return clean.match(/.{1,4}/g)?.join(' ') || clean;
}