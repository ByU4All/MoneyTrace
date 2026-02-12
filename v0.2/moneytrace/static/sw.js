/**
 * MoneyTrace Service Worker
 *
 * Caches static assets for offline PWA functionality.
 * API calls are NOT cached - they always go to local Python server.
 */

const CACHE_NAME = 'moneytrace-v0.2.0';
const STATIC_ASSETS = [
    '/',
    '/index.html',
    '/manifest.json',
    '/css/app.css',
    '/js/api.js',
    '/js/screens.js',
    '/js/app.js',
    '/icons/icon-192.png',
    '/icons/icon-512.png'
];

// Install - cache static assets
self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => cache.addAll(STATIC_ASSETS))
            .then(() => self.skipWaiting())
    );
});

// Activate - clean old caches
self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys()
            .then(keys => Promise.all(
                keys.filter(key => key !== CACHE_NAME)
                    .map(key => caches.delete(key))
            ))
            .then(() => self.clients.claim())
    );
});

// Fetch - cache-first for static, network-only for API
self.addEventListener('fetch', event => {
    const url = new URL(event.request.url);

    // API requests always go to network (local server)
    if (url.pathname.startsWith('/api/')) {
        event.respondWith(fetch(event.request));
        return;
    }

    // Static assets: cache-first
    event.respondWith(
        caches.match(event.request)
            .then(cached => cached || fetch(event.request))
    );
});

