//Definición de rutas y fragmentos asociados
const routes = {
    home: { main: 'fragments/home.html' },
    dashboard: { main: 'fragments/dashboard.html', sidebar: 'fragments/sidebar.html', init: initDashboard },
    profile: { main: 'fragments/profile.html', sidebar: 'fragments/sidebar.html', init: initProfile }
};

// Cache para almacenar fragmentos cargados y evitar recargas innecesarias
const cache = new Map();

// Variable para almacenar la función de limpieza del dashboard, si es necesario
let currentCleanup = null;

// Función para cargar fragmentos HTML de manera asíncrona y almacenarlos en caché
async function loadFragment(url) {
    if (cache.has(url)) {
        return cache.get(url);
    }
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`No se pudo cargar el recurso: ${url} (Estado: ${response.status})`);
    }
    const html = await response.text();
    cache.set(url, html);
    return html;
}

// Función principal para manejar la navegación entre rutas
async function navigate(routeName) {
    const container = document.getElementById('app-container');
    
    // Limpieza de la sección anterior si es necesario
    if (typeof currentCleanup === 'function') {
        currentCleanup();
        currentCleanup = null;
    }

    // Obtención de la ruta correspondiente o manejo de error si no existe
    const route = routes[routeName] || { isError: true };

    try {
        if (route.isError) {
            throw new Error('La sección solicitada no existe en el sistema.');
        }

        let contentHTML = '';
        
        // Carga de fragmentos principales y secundarios si están definidos
        if (route.sidebar) {
            const [mainHtml, sidebarHtml] = await Promise.all([
                loadFragment(route.main),
                loadFragment(route.sidebar)
            ]);
            contentHTML = `<div class="layout-composed"><aside class="sidebar">${sidebarHtml}</aside><section>${mainHtml}</section></div>`;
        } else {
            contentHTML = await loadFragment(route.main);
        }

        container.innerHTML = contentHTML;
        updateActiveNav(routeName);

        // Inicialización de funciones específicas para ciertas rutas, como el dashboard o profile en este caso
        if (typeof route.init === 'function') {
            currentCleanup = route.init();
        }

    } catch (error) {
        container.innerHTML = `
            <div class="error-box">
                <h2>Aviso del sistema</h2>
                <p>${error.message}</p>
                <button data-route="home" style="margin-top: 1rem; padding: 0.5rem 1rem; cursor: pointer;">Regresar al inicio</button>
            </div>
        `;
    }
}

// Función para actualizar la navegación activa en el menú
function updateActiveNav(routeName) {
    document.querySelectorAll('.site-nav a').forEach(a => {
        a.classList.toggle('active', a.getAttribute('data-route') === routeName);
    });
}

// Función para inicializar el dashboard con un temporizador en vivo para comprobar visualmente que la sección se está inyectando sin recargar la página
function initDashboard() {
    const timer = setInterval(() => {
        const timeEl = document.getElementById('live-timer');
        if (timeEl) timeEl.textContent = new Date().toLocaleTimeString();
    }, 1000);

    return () => {
        clearInterval(timer);
    };
}

// Función para inicializar la sección de perfil, como ejemplo para mostrar cómo el código puede ser escalable y modular, permitiendo agregar más secciones con sus propias inicializaciones y limpiezas según sea necesario
function initProfile() {
    console.log("Sección de perfil cargada.");
    
    return () => {
        console.log("Saliendo de la sección de perfil.");
    };
}

// Manejo de eventos de navegación y estado del historial
document.addEventListener('click', (e) => {
    if (e.target.matches('[data-route]')) {
        e.preventDefault();
        const route = e.target.getAttribute('data-route');
        history.pushState({ route }, '', `#${route}`);
        navigate(route);
    }
});

// Manejo del evento popstate para navegación con el botón de retroceso del navegador para mantener la consistencia de la interfaz
window.addEventListener('popstate', (e) => {
    const route = e.state?.route || window.location.hash.replace('#', '') || 'home';
    navigate(route);
});

// Inicialización de la aplicación al cargar la página, navegando a la ruta inicial basada en el hash de la URL o a 'home' por defecto
window.addEventListener('DOMContentLoaded', () => {
    const initialRoute = window.location.hash.replace('#', '') || 'home';
    navigate(initialRoute);
});