const routes = {
    home: {
        regions: { main: 'fragments/home.html' }
    },
    dashboard: {
        regions: {
            banner: 'fragments/banner.html',
            sidebar: 'fragments/sidebar.html',
            main: 'fragments/dashboard.html'
        },
        css: ['fragments/dashboard.css'],
        init: initDashboard
    },
    profile: {
        regions: {
            banner: 'fragments/banner.html',
            sidebar: 'fragments/sidebar.html',
            main: 'fragments/profile.html'
        },
        init: initProfile
    }
};

// Orden en el que se pintan las regiones dentro de #app-container.
const REGION_ORDER = ['sidebar', 'main', 'banner'];

// Cache de fragmentos HTML ya cargados para evitar fetchs repetidos.
const fragmentCache = new Map();

// Carga un fragmento HTML desde el servidor y lo cachea en memoria.
async function loadFragment(url) {
    if (fragmentCache.has(url)) {
        return fragmentCache.get(url);
    }
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`No se pudo cargar el recurso: ${url} (Estado: ${response.status})`);
    }
    const html = await response.text();
    fragmentCache.set(url, html);
    return html;
}

// Cache de CSS de fragmentos ya cargados para evitar reinyectar <link> repetidos.
const loadedFragmentCss = new Set();

// Asegura que los CSS de los fragmentos estén cargados en el <head>.
function ensureFragmentCss(hrefs = []) {
    for (const href of hrefs) {
        if (loadedFragmentCss.has(href)) continue;
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = href;
        link.dataset.fragmentCss = href;
        document.head.appendChild(link);
        loadedFragmentCss.add(href);
    }
}

// La función cleanup de la sección actual, si existe. Se llama antes de cargar la siguiente sección.
let currentCleanup = null;

// Cada navegación obtiene un id único para evitar que navegaciones lentas "pisen" a otras más rápidas.
let navigationId = 0;

// Navega a una sección específica, cargando sus fragmentos y ejecutando su init().
async function navigate(routeName) {
    const myNavId = ++navigationId;

    const container = document.getElementById('app-container');
    const route = routes[routeName];

    if (typeof currentCleanup === 'function') {
        currentCleanup();
        currentCleanup = null;
    }

    try {
        if (!route) {
            throw new Error('La sección solicitada no existe en el sistema.');
        }

        const regionNames = REGION_ORDER.filter(name => route.regions[name]);
        const htmls = await Promise.all(
            regionNames.map(name => loadFragment(route.regions[name]))
        );

        if (myNavId !== navigationId) return;

        const contentHTML = regionNames
            .map((name, i) => `<div class="region-${name}" data-region="${name}">${htmls[i]}</div>`)
            .join('');

        container.innerHTML = wrapRegions(regionNames, contentHTML);
        updateActiveNav(routeName);

        ensureFragmentCss(route.css);

        if (typeof route.init === 'function') {
            currentCleanup = route.init();
        }

    } catch (error) {
        if (myNavId !== navigationId) return;

        container.innerHTML = `
            <div class="error-box">
                <h2>Aviso del sistema</h2>
                <p>${error.message}</p>
                <button data-route="home" style="margin-top: 1rem; padding: 0.5rem 1rem; cursor: pointer;">Regresar al inicio</button>
            </div>
        `;
    }
}

// Si hay más de una región, se envuelven en un contenedor para aplicar un layout compuesto.
function wrapRegions(regionNames, contentHTML) {
    if (regionNames.length <= 1) return contentHTML;
    return `<div class="layout-composed">${contentHTML}</div>`;
}

// Actualiza la navegación para reflejar la sección activa.
function updateActiveNav(routeName) {
    document.querySelectorAll('.site-nav a').forEach(a => {
        a.classList.toggle('active', a.getAttribute('data-route') === routeName);
    });
}

// Ejemplo de init() para la sección "dashboard" que actualiza un reloj en vivo.
function initDashboard() {
    const timer = setInterval(() => {
        const timeEl = document.getElementById('live-timer');
        if (timeEl) timeEl.textContent = new Date().toLocaleTimeString();
    }, 1000);

    return () => {
        clearInterval(timer);
    };
}

// Ejemplo de init() para la sección "profile" que podría inicializar un formulario o cargar datos del usuario.
function initProfile() {
    console.log('Sección de perfil cargada.');

    return () => {
        console.log('Saliendo de la sección de perfil.');
    };
}

// Maneja los clics en enlaces de navegación y actualiza la URL sin recargar la página.
document.addEventListener('click', (e) => {
    const link = e.target.closest('[data-route]');
    if (!link) return;

    e.preventDefault();
    const route = link.getAttribute('data-route');
    history.pushState({ route }, '', `#${route}`);
    navigate(route);
});

// Maneja la navegación hacia atrás/adelante del historial del navegador.
window.addEventListener('popstate', (e) => {
    const route = e.state?.route || window.location.hash.replace('#', '') || 'home';
    navigate(route);
});

// Inicializa la aplicación cargando la sección correspondiente a la URL actual.
window.addEventListener('DOMContentLoaded', () => {
    const initialRoute = window.location.hash.replace('#', '') || 'home';
    navigate(initialRoute);
});

// Maneja el clic en el botón de cerrar del banner para eliminarlo del DOM.
document.addEventListener('click', (e) => {
    if (e.target.closest('[data-action="dismiss-banner"]')) {
        const banner = e.target.closest('.region-banner');
        if (banner) banner.remove();
    }
});