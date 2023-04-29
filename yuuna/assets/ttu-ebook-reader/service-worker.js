const v = [
  "/_app/immutable/assets/fa-32503cb2.css",
  "/_app/immutable/assets/_page-b843624e.css",
  "/_app/immutable/assets/store-ad073191.css",
  "/_app/immutable/assets/_layout-458bc673.css",
  "/_app/immutable/chunks/theme-option-f9f8f697.js",
  "/_app/immutable/chunks/fonts-e5a631ed.js",
  "/_app/immutable/chunks/1-36f4ec71.js",
  "/_app/immutable/components/pages/_page.svelte-a2e11aab.js",
  "/_app/immutable/chunks/4-761fe457.js",
  "/_app/immutable/chunks/2-b84d59c0.js",
  "/_app/immutable/chunks/6-482dfd9c.js",
  "/_app/immutable/chunks/index-61bb0c2c.js",
  "/_app/immutable/chunks/stores-6a6870f3.js",
  "/_app/immutable/components/error.svelte-5086bf37.js",
  "/_app/immutable/chunks/5-3648d17b.js",
  "/_app/immutable/chunks/format-page-title-2ca75b98.js",
  "/_app/immutable/chunks/0-2149c851.js",
  "/_app/immutable/chunks/3-ad0bef55.js",
  "/_app/immutable/chunks/singletons-6176161c.js",
  "/_app/immutable/components/pages/auth/_page.svelte-90066a89.js",
  "/_app/immutable/chunks/error-handler-df8dffd6.js",
  "/_app/immutable/chunks/fa-33dddbd3.js",
  "/_app/immutable/chunks/index-be8ea2fc.js",
  "/_app/immutable/start-31285994.js",
  "/_app/immutable/chunks/merged-header-icon-5b1d438d.js",
  "/_app/immutable/components/pages/manage/_page.svelte-788e593b.js",
  "/_app/immutable/components/pages/_layout.svelte-9a3342ae.js",
  "/_app/immutable/components/pages/b/_page.svelte-f75ac4b0.js",
  "/_app/immutable/components/pages/settings/_page.svelte-2a445305.js",
  "/_app/immutable/chunks/store-fb60485f.js"
], j = [
  "/apple-touch-icon.png",
  "/favicon.ico",
  "/favicon.png",
  "/fonts/genEiKoburiMin5.ttf",
  "/fonts/klee-one-v7-600.woff",
  "/fonts/klee-one-v7-600.woff2",
  "/fonts/klee-one-v7-regular.woff",
  "/fonts/klee-one-v7-regular.woff2",
  "/fonts/noto-sans-v42-500.woff",
  "/fonts/noto-sans-v42-500.woff2",
  "/fonts/noto-sans-v42-700.woff",
  "/fonts/noto-sans-v42-700.woff2",
  "/fonts/noto-sans-v42-regular.woff",
  "/fonts/noto-sans-v42-regular.woff2",
  "/fonts/noto-serif-v21-500.woff",
  "/fonts/noto-serif-v21-500.woff2",
  "/fonts/noto-serif-v21-700.woff",
  "/fonts/noto-serif-v21-700.woff2",
  "/fonts/noto-serif-v21-regular.woff",
  "/fonts/noto-serif-v21-regular.woff2",
  "/fonts/shippori-mincho-v14-500.woff",
  "/fonts/shippori-mincho-v14-500.woff2",
  "/fonts/shippori-mincho-v14-700.woff",
  "/fonts/shippori-mincho-v14-700.woff2",
  "/fonts/shippori-mincho-v14-regular.woff",
  "/fonts/shippori-mincho-v14-regular.woff2",
  "/icons/maskable-icon@128x128.png",
  "/icons/maskable-icon@16x16.png",
  "/icons/maskable-icon@192x192.png",
  "/icons/maskable-icon@32x32.png",
  "/icons/maskable-icon@512x512.png",
  "/icons/regular-icon@16x16.png",
  "/icons/regular-icon@192x192.png",
  "/icons/regular-icon@32x32.png",
  "/icons/regular-icon@512x512.png",
  "/manifest.webmanifest",
  "/safari-pinned-tab.svg"
], b = [
  "/",
  "/__data.json",
  "/auth.html",
  "/auth/__data.json",
  "/b.html",
  "/b/__data.json",
  "/manage.html",
  "/manage/__data.json",
  "/settings.html",
  "/settings/__data.json"
], g = "1682741589948", k = {}.VITE_PAGE_PATH || "";
function x(e) {
  return Object.entries(e).map(([s, n]) => `${encodeURIComponent(s)}=${encodeURIComponent(n)}`).join("&");
}
const R = "ttu-userfonts", i = self, u = `build:${g}`, C = new Set(b), _ = v.concat(j).concat(b), E = new Set(_);
i.addEventListener("install", (e) => {
  i.skipWaiting(), e.waitUntil(caches.open(u).then((s) => s.addAll(_)));
});
i.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((s) => {
      const n = s.filter(
        (t) => t !== u && t !== R
      );
      return Promise.all(n.map((t) => caches.delete(t)));
    })
  );
});
i.addEventListener("fetch", (e) => {
  if (e.request.method !== "GET" || e.request.headers.has("range"))
    return;
  const s = new URL(e.request.url), n = s.protocol.startsWith("http"), t = s.hostname === i.location.hostname && s.port !== i.location.port, o = s.host === i.location.host, p = o && E.has(s.pathname), c = e.request.cache === "only-if-cached" && !p;
  if (!(!n || t || c)) {
    if (o && C.has(s.pathname)) {
      const a = new Request(s.pathname);
      e.respondWith(
        d(e.request, !1, u, a)
      );
      return;
    }
    if (o && s.pathname.startsWith("/userfonts/")) {
      e.respondWith(
        caches.match(s.pathname).then((a) => a ?? w("/fonts/noto-serif-v21-regular.woff2"))
      );
      return;
    }
    if (o) {
      const a = p ? caches.match(s.pathname).then((f) => f ?? fetch(e.request)) : U(e.request);
      if (a) {
        e.respondWith(a);
        return;
      }
    }
    s.host === "fonts.googleapis.com" && e.respondWith(d(e.request));
  }
});
async function d(e, s = !0, n, t) {
  const o = await caches.open(`other:${g}`), p = new AbortController();
  let c, a = !1, f = !1;
  const m = () => n ? caches.match(t ?? e, { cacheName: n }) : void 0, l = async () => {
    if (!s)
      return m();
    const r = await o.match(e);
    if (r)
      return r;
    if (!!n)
      return m();
  };
  try {
    const r = setTimeout(async () => {
      c = await l(), f = !0, !(!c || a) && p.abort();
    }, 1e3), h = await fetch(e, { signal: p.signal });
    return a = !0, clearTimeout(r), s && o.put(e, h.clone()), h;
  } catch (r) {
    if (f || (c = await l()), c)
      return c;
    throw r;
  }
}
function U(e) {
  const s = new URL(e.url), t = /\/b\/(?<id>\d+)\/?(\?|$)/.exec(s.pathname);
  if (t != null && t.groups)
    return w(`${[[k]]}/b?${x(t.groups)}`);
}
function w(e) {
  return new Response(null, {
    status: 302,
    headers: {
      location: e
    }
  });
}
