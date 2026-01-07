// Utilitaire pour charger le logo FidApp en base64
export async function getFidAppLogoBase64(): Promise<string> {
  return new Promise((resolve, reject) => {
    const img = new Image()
    
    img.onload = () => {
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      
      if (!ctx) {
        reject(new Error('Could not get canvas context'))
        return
      }
      
      // Set canvas dimensions to match image
      canvas.width = img.width
      canvas.height = img.height
      
      // Draw image to canvas
      ctx.drawImage(img, 0, 0)
      
      // Convert to base64
      try {
        const dataURL = canvas.toDataURL('image/png')
        resolve(dataURL)
      } catch (error) {
        reject(error)
      }
    }
    
    img.onerror = () => {
      reject(new Error('Failed to load logo image'))
    }
    
    // Set crossOrigin before src
    img.crossOrigin = 'anonymous'
    
    // Try different paths
    const paths = [
      '/Logo_Trans_unique.png',
      './Logo_Trans_unique.png',
      'Logo_Trans_unique.png'
    ]
    
    let currentPath = 0
    
    const tryNextPath = () => {
      if (currentPath < paths.length) {
        img.src = paths[currentPath]
        currentPath++
      } else {
        reject(new Error('Logo not found in any path'))
      }
    }
    
    img.onerror = tryNextPath
    tryNextPath()
  })
}

// Logo en base64 en fallback (logo simplifié)
export const FIDAPP_LOGO_FALLBACK = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='