import { PKPass } from 'passkit-generator';

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

export interface AppleWalletConfig {
  teamIdentifier: string;
  passTypeIdentifier: string;
  organizationName: string;
  description: string;
  certificates: {
    wwdr: string;
    signerCert: string;
    signerKey: string;
    signerKeyPassphrase?: string;
  };
}

export class AppleWalletService {
  private config: AppleWalletConfig;

  constructor(config: AppleWalletConfig) {
    this.config = config;
  }

  async generateLoyaltyPass(data: LoyaltyCardData): Promise<Buffer> {
    try {
      const pass = new PKPass({
        'pass.json': Buffer.from(JSON.stringify({
          formatVersion: 1,
          passTypeIdentifier: this.config.passTypeIdentifier,
          serialNumber: `${data.customerId}-${Date.now()}`,
          teamIdentifier: this.config.teamIdentifier,
          webServiceURL: `${window.location.origin}/api/wallet`,
          authenticationToken: this.generateAuthToken(),
          organizationName: this.config.organizationName,
          description: this.config.description,
          logoText: data.companyName,
          foregroundColor: data.foregroundColor || 'rgb(255, 255, 255)',
          backgroundColor: data.backgroundColor || 'rgb(60, 65, 76)',
          labelColor: data.labelColor || 'rgb(255, 255, 255)',
          
          storeCard: {
            headerFields: [
              {
                key: 'points',
                label: 'POINTS',
                value: data.points,
                changeMessage: 'Vos points: %@'
              }
            ],
            primaryFields: [
              {
                key: 'customerName',
                value: data.customerName
              }
            ],
            secondaryFields: [
              {
                key: 'cardNumber',
                label: 'N° DE CARTE',
                value: data.cardNumber
              }
            ],
            auxiliaryFields: [
              {
                key: 'level',
                label: 'NIVEAU',
                value: this.getCustomerLevel(data.points)
              }
            ],
            backFields: [
              {
                key: 'terms',
                label: 'Conditions d\'utilisation',
                value: 'Cette carte de fidélité est valable dans tous nos établissements. Les points sont cumulables et ne peuvent être échangés contre de l\'argent.'
              },
              {
                key: 'website',
                label: 'Site Web',
                value: window.location.origin
              },
              {
                key: 'customerService',
                label: 'Service Client',
                value: 'contact@fidapp.fr'
              }
            ]
          },
          
          barcode: {
            format: 'PKBarcodeFormatQR',
            message: data.qrCodeValue,
            messageEncoding: 'iso-8859-1'
          },
          
          relevantLocations: [],
          maxDistance: 100,
          relevantDate: new Date().toISOString()
        })),
        
        'icon.png': await this.getImageBuffer(data.companyLogo || '/Logo_Trans.png'),
        'icon@2x.png': await this.getImageBuffer(data.companyLogo || '/Logo_Trans.png', 2),
        'logo.png': await this.getImageBuffer(data.companyLogo || '/Logo_Trans.png'),
        'logo@2x.png': await this.getImageBuffer(data.companyLogo || '/Logo_Trans.png', 2)
      }, {
        wwdr: this.config.certificates.wwdr,
        signerCert: this.config.certificates.signerCert,
        signerKey: {
          keyFile: this.config.certificates.signerKey,
          passphrase: this.config.certificates.signerKeyPassphrase
        }
      });

      return pass.generate();
    } catch (error) {
      console.error('Erreur lors de la génération du pass:', error);
      throw new Error('Impossible de générer le pass Apple Wallet');
    }
  }

  private getCustomerLevel(points: number): string {
    if (points >= 1000) return 'GOLD';
    if (points >= 500) return 'SILVER';
    return 'BRONZE';
  }

  private generateAuthToken(): string {
    return btoa(`${Date.now()}-${Math.random()}`).replace(/=/g, '');
  }

  private async getImageBuffer(url: string, scale: number = 1): Promise<Buffer> {
    const response = await fetch(url);
    const blob = await response.blob();
    const arrayBuffer = await blob.arrayBuffer();
    
    if (scale === 1) {
      return Buffer.from(arrayBuffer);
    }
    
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    const img = new Image();
    
    return new Promise((resolve, reject) => {
      img.onload = () => {
        canvas.width = img.width * scale;
        canvas.height = img.height * scale;
        ctx?.drawImage(img, 0, 0, canvas.width, canvas.height);
        
        canvas.toBlob((blob) => {
          if (blob) {
            blob.arrayBuffer().then(buffer => {
              resolve(Buffer.from(buffer));
            });
          } else {
            reject(new Error('Failed to scale image'));
          }
        }, 'image/png');
      };
      
      img.onerror = reject;
      img.src = URL.createObjectURL(blob);
    });
  }

  async updatePass(serialNumber: string, updates: Partial<LoyaltyCardData>): Promise<void> {
    const response = await fetch(`${window.location.origin}/api/wallet/passes/${serialNumber}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(updates)
    });

    if (!response.ok) {
      throw new Error('Failed to update pass');
    }
  }

  generateDownloadUrl(passBuffer: Buffer): string {
    const blob = new Blob([passBuffer], { type: 'application/vnd.apple.pkpass' });
    return URL.createObjectURL(blob);
  }
}

export function isWalletAvailable(): boolean {
  const userAgent = navigator.userAgent || navigator.vendor;
  return /iPhone|iPad|iPod/i.test(userAgent) || /Mac/i.test(userAgent);
}

export function formatCardNumber(customerId: string): string {
  const clean = customerId.replace(/-/g, '').toUpperCase();
  return clean.match(/.{1,4}/g)?.join(' ') || clean;
}