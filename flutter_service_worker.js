'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"manifest.json": "159b6ff2d65a2b525af3e39426bad9c0",
"main.dart.js": "1706c020db8535afa8dd482cb6a66293",
"version.json": "453338ebab7b2c938f3f00516d7a4aa5",
"assets/NOTICES": "c6b2e090c10bdaa16a72f162fcc21159",
"assets/fonts/MaterialIcons-Regular.otf": "f245cf70da2ebae715e11b43933b3580",
"assets/AssetManifest.json": "5181e1685db26bd240fd47ed77c01afe",
"assets/assets/fonts/Nunito/Nunito-Light.ttf": "97c4f09517669dba7c6d64e9aba2b3c4",
"assets/assets/fonts/Nunito/Nunito-Bold.ttf": "c133c0b8cd169e7798d0cd239477cf32",
"assets/assets/fonts/Nunito/Nunito-Regular.ttf": "f04f0e9ff969fd52a75deade3a9761cd",
"assets/assets/icons/export.png": "4f770cd494969968da97db6bbd318727",
"assets/assets/icons/droplet.png": "4f770cd494969968da97db6bbd318727",
"assets/assets/icons/clock.png": "4f770cd494969968da97db6bbd318727",
"assets/assets/icons/bottle.png": "4f770cd494969968da97db6bbd318727",
"assets/assets/icons/notification.png": "4f770cd494969968da97db6bbd318727",
"assets/assets/icons/history.png": "4f770cd494969968da97db6bbd318727",
"assets/assets/icons/settings.png": "4f770cd494969968da97db6bbd318727",
"assets/assets/icons/poop.png": "4f770cd494969968da97db6bbd318727",
"assets/assets/images/illustrations/feeding_time.png": "2f5ca72ad9b1f63322bf49ec6f82231f",
"assets/assets/images/illustrations/empty_history.png": "611290c9541d4976d61db90373cb93c1",
"assets/assets/images/illustrations/splash_logo.png": "6183a6a23430fc21245c6b8334c3886e",
"assets/assets/images/illustrations/welcome_baby.png": "70ada6fdf4fa54dbfd28fd3d65c5f2a5",
"assets/assets/images/splash/splash_logo.png": "a0ab42638ec9cca1bad7a6509d8d8ab9",
"assets/assets/images/app_icon/icon.png": "041bb12fe0d16170321f18c8950b8fa9",
"assets/assets/animations/loading_baby.json": "c2e0515b33a29cf7fd60d2dea9612962",
"assets/assets/animations/success_check.json": "49ff10bcd8cdaaaac6c911a3c9003989",
"assets/assets/animations/feeding_timer.json": "3866ab543ce2500c4806c661c7ae255f",
"assets/FontManifest.json": "33571905fab6652b2469facd7d9c9bac",
"assets/AssetManifest.bin.json": "95b9bd0dcfd2bc21b2ce389d529aab21",
"assets/AssetManifest.bin": "25e26e802b8cc2536790319b8d48cbef",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"flutter_bootstrap.js": "f0e29bf6350d8fab259e02c569fe9f45",
"index.html": "74f5d6390614e9fbb283956bdff8d13d",
"/": "74f5d6390614e9fbb283956bdff8d13d"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
