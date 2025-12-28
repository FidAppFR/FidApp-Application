// Version ULTRA simple sans aucune dépendance complexe
console.log('=== FidApp Starting ===');

// Attendre que le DOM soit prêt
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}

function init() {
    console.log('DOM ready, initializing app...');
    
    const app = document.getElementById('app');
    if (!app) {
        console.error('Element #app not found!');
        return;
    }
    
    // Remplacer le contenu
    app.innerHTML = `
        <div style="
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        ">
            <header style="
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 40px;
                border-radius: 12px;
                text-align: center;
                margin-bottom: 30px;
            ">
                <h1 style="margin: 0; font-size: 48px;">🎯 FidApp</h1>
                <p style="margin: 10px 0 0 0; opacity: 0.9;">Système de Fidélisation Client</p>
            </header>
            
            <div style="
                background: white;
                padding: 30px;
                border-radius: 12px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                margin-bottom: 20px;
            ">
                <h2 style="color: #333; margin-top: 0;">Bienvenue sur FidApp!</h2>
                <p style="color: #666; line-height: 1.6;">
                    L'application fonctionne correctement. Utilisez les boutons ci-dessous pour naviguer.
                </p>
                <div style="margin-top: 30px; display: flex; gap: 10px; justify-content: center;">
                    <button onclick="window.location.href='/login'" style="
                        background: #667eea;
                        color: white;
                        border: none;
                        padding: 12px 30px;
                        border-radius: 6px;
                        font-size: 16px;
                        cursor: pointer;
                    ">Se connecter</button>
                    <button onclick="window.location.href='/register'" style="
                        background: #764ba2;
                        color: white;
                        border: none;
                        padding: 12px 30px;
                        border-radius: 6px;
                        font-size: 16px;
                        cursor: pointer;
                    ">S'inscrire</button>
                </div>
            </div>
            
            <div style="
                background: #f8f9fa;
                padding: 20px;
                border-radius: 12px;
                text-align: center;
                color: #666;
            ">
                <p style="margin: 0;">Version: 1.0.0 | ${new Date().toLocaleString('fr-FR')}</p>
            </div>
        </div>
    `;
    
    console.log('App initialized successfully!');
}

// Export pour éviter les erreurs de module
export {};