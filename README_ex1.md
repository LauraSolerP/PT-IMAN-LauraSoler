# PT-IMAN-LauraSoler

## Descripción general

La aplicación tiene una única página real (`index.html`). El `<header>`, el menú de navegación y el `<footer>` se construyen una sola vez al cargar la página y nunca se vuelven a pedir al servidor ni se re-renderizan. Al navegar entre secciones, únicamente se sustituye el contenido de `#app-container`, componiéndolo a partir de uno o varios fragmentos HTML independientes (`main`, `sidebar`, `banner`, etc.).

Cada sección se define en `routes`:

```js
const routes = {
    dashboard: {
        regions: {
            banner: 'fragments/notice-banner.html',
            sidebar: 'fragments/sidebar.html',
            main: 'fragments/dashboard.html'
        },
        css: ['fragments/dashboard.css'],
        init: initDashboard
    }
};
```

Añadir una sección nueva, o una región nueva a una vista existente, no requiere tocar la lógica de `navigate()`: basta con declarar la entrada en `routes`.

---

## Composición de vistas a partir de varios fragmentos

Cada archivo HTML de `fragments/` contiene únicamente el trozo de marcado correspondiente a esa pieza, nunca una página completa (sin `<html>`, `<head>` ni `<body>`).

`navigate()` resuelve todas las regiones de la ruta solicitada en paralelo con `Promise.all`, y solo pinta el DOM cuando **todas** han llegado. Esto evita el parpadeo de mostrar el `main` un instante antes de que llegue el `sidebar`.

El orden de pintado lo controla `REGION_ORDER`, no el orden en que se declaran en `routes`:

```js
const REGION_ORDER = ['sidebar', 'main', 'banner'];
```

Una misma región puede ser reutilizada por varias rutas apuntando a la misma URL de fragmento. Es el caso del banner de avisos: tanto `dashboard` como `profile` referencian `fragments/notice-banner.html`. Gracias a la cache (ver más abajo), el fragmento solo se descarga una vez en toda la sesión, aunque aparezca en N secciones distintas.

Si una ruta no declara una región (por ejemplo, `home` no tiene `banner` ni `sidebar`), esa región simplemente no se renderiza; no hace falta ningún valor "vacío" ni condicional especial.

---

## Estrategia de cache: cuándo se reutiliza y cuándo se fuerza recarga

**Estrategia por defecto: guardado de fragmentos en memoria, para toda la sesión de página.**

```js
const fragmentCache = new Map();

async function loadFragment(url) {
    if (fragmentCache.has(url)) return fragmentCache.get(url);
    const response = await fetch(url);
    if (!response.ok) throw new Error(`No se pudo cargar el recurso: ${url} (Estado: ${response.status})`);
    const html = await response.text();
    fragmentCache.set(url, html);
    return html;
}
```

Una vez que un fragmento se ha pedido con éxito, no se vuelve a solicitar al servidor mientras dure la sesión de navegación (aunque el usuario visite la sección 50 veces).

**Importante:** si el `fetch` falla (red caída, 404, 500...), la excepción se lanza antes de escribir en la cache. Eso significa que un fallo no queda "cacheado" sino que el siguiente intento de navegar a esa sección vuelve a pedir el recurso al servidor, dándole al usuario una segunda oportunidad sin recargar la página entera.

**Casos en los que sí conviene forzar una recarga** (no ocurre automáticamente, hay que decidirlo explícitamente):

| Caso | Cómo se resuelve |
|---|---|
| El contenido de un fragmento cambia durante la sesión tras una acción de escritura del propio usuario (p. ej. edita su perfil y `fragments/profile.html` ahora debería reflejarlo) | `fragmentCache.delete('fragments/profile.html')` justo después de guardar el cambio, antes de la siguiente navegación a esa ruta |
| Se despliega una nueva versión de la app con fragmentos actualizados | No se resuelve revalidando en cada navegación (rompería el objetivo de la cache); se resuelve versionando la URL en el build (`fragments/profile.html?v=7`), de forma que sea una URL distinta y por tanto una entrada distinta de cache |
| Un fragmento depende de datos que cambian por causas externas al usuario (avisos del sistema, notificaciones) | Se pide explícitamente con un intervalo propio dentro del `init()` de esa sección (ver ciclo de vida más abajo), no invalidando la cache de fragmentos HTML sino refrescando datos vía una llamada a API aparte |

La cache de CSS de fragmento (`loadedFragmentCss`, ver siguiente sección) sigue la misma lógica: se marca una vez inyectado y no se vuelve a insertar el mismo `<link>`.

---

## JavaScript propio de cada fragmento

Cada sección que necesita comportamiento propio (temporizadores, listeners no delegados, llamadas a API periódicas) expone una función `init` en su entrada de `routes`:

```js
dashboard: {
    /* ... */
    init: initDashboard
}
```

**Regla del contrato:** `init()` debe devolver una función `cleanup` (o no devolver nada si no hay nada que limpiar). `navigate()` llama automáticamente a `currentCleanup()` justo antes de cargar la siguiente sección, tanto si la navegación siguiente tiene éxito como si termina en pantalla de error — así nunca queda un timer o listener de una sección "huérfano" corriendo en segundo plano después de abandonarla.

```js
function initDashboard() {
    const timer = setInterval(() => {
        const timeEl = document.getElementById('live-timer');
        if (timeEl) timeEl.textContent = new Date().toLocaleTimeString();
    }, 1000);

    return () => clearInterval(timer); // se ejecuta al salir de dashboard
}
```

`init`/`cleanup` es responsable de limpiar todo lo que la sección haya registrado: `setInterval`/`setTimeout`, listeners añadidos directamente sobre elementos concretos (no delegados), `IntersectionObserver`/`MutationObserver`, y `fetch` en curso que ya no tenga sentido completar (cancelándolos con `AbortController` si el tiempo de respuesta pudiera ser largo).

**Excepción deliberada: eventos delegados en `document`:** tanto la navegación (clics en `[data-route]`) como el cierre del banner (clic en `[data-action="dismiss-banner"]`) se gestionan con un único listener en `document`, registrado una sola vez al cargar la app:

```js
document.addEventListener('click', (e) => {
    const link = e.target.closest('[data-route]');
    if (link) { /* navegar */ }
});

document.addEventListener('click', (e) => {
    if (e.target.closest('[data-action="dismiss-banner"]')) { /* cerrar banner */ }
});
```

Estos listeners no se registran ni se limpian en cada `init`/`cleanup` de sección: siguen funcionando sin importar qué fragmento se haya inyectado en cada momento, incluido contenido que se reinyecta varias veces (como el banner reutilizado entre `dashboard` y `profile`). Esto evita tanto duplicar listeners como tener que acordarse de limpiarlos al cambiar de sección.

---

## Qué ocurre cuando la sección no existe o falla la carga

Ambos casos comparten el mismo `catch` en `navigate()` y el mismo resultado visual: nunca se deja al usuario ante una pantalla en blanco.

- **Sección inexistente** (`routeName` no está en `routes`): se lanza `Error('La sección solicitada no existe en el sistema.')` de forma controlada, sin llegar a intentar ningún `fetch`.
- **Fallo de red o HTTP** al cargar un fragmento (servidor caído, fragmento movido, 404 real del archivo): `loadFragment()` lanza con el detalle del estado HTTP y la URL que falló.

En ambos casos se muestra el mismo bloque de error dentro de `#app-container`, con un botón para volver a `home`:

```html
<div class="error-box">
    <h2>Aviso del sistema</h2>
    <p>[mensaje del error]</p>
    <button data-route="home">Regresar al inicio</button>
</div>
```

Como el botón usa `data-route="home"`, el clic pasa por el mismo listener delegado de navegación — no necesita lógica aparte.

---

## Condición de carrera al navegar rápido entre secciones

Si el usuario pulsa dos enlaces seguidos antes de que la primera navegación termine de resolver sus fragmentos, existe el riesgo de que la respuesta más lenta "llegue tarde" y sobreescriba lo que ya se está mostrando de la navegación más reciente. Se resuelve con un token incremental:

```js
let navigationId = 0;

async function navigate(routeName) {
    const myNavId = ++navigationId;
    // ...
    if (myNavId !== navigationId) return; // esta navegación quedó obsoleta, se descarta
    // ... solo aquí se toca el DOM y se asigna currentCleanup
}
```

Cualquier navegación cuyo id ya no coincide con el id global al terminar de resolver sus fragmentos se descarta silenciosamente, tanto en el camino de éxito como en el de error. Así el DOM siempre refleja la navegación más reciente que el usuario solicitó, nunca una anterior que tardó más en responder.

---


