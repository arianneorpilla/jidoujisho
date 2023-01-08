function j(e) {
  return Object.entries(e).map(([s, a]) => `${encodeURIComponent(s)}=${encodeURIComponent(a)}`).join("&");
}
const k = [
  "/_app/immutable/assets/merged-header-icon-32503cb2.css",
  "/_app/immutable/assets/_page-2c8707b3.css",
  "/_app/immutable/assets/_layout-380f49f7.css",
  "/_app/immutable/chunks/utils-62d9d9d7.js",
  "/_app/immutable/chunks/stores-41bc0127.js",
  "/_app/immutable/chunks/4-c3666f27.js",
  "/_app/immutable/chunks/storage-c0963857.js",
  "/_app/immutable/chunks/2-6abbd74e.js",
  "/_app/immutable/chunks/theme-option-7cf46fe1.js",
  "/_app/immutable/chunks/5-46b1d073.js",
  "/_app/immutable/chunks/1-d6e2df69.js",
  "/_app/immutable/chunks/3-84acf07d.js",
  "/_app/immutable/chunks/0-97ab93f6.js",
  "/_app/immutable/components/error.svelte-68a20358.js",
  "/_app/immutable/components/pages/_page.svelte-89ffe3da.js",
  "/_app/immutable/chunks/index-63863b80.js",
  "/_app/immutable/chunks/dialog-manager-6307dd27.js",
  "/_app/immutable/chunks/singletons-54206af0.js",
  "/_app/immutable/start-e64e3e18.js",
  "/_app/immutable/chunks/merged-header-icon-aec892cb.js",
  "/_app/immutable/chunks/format-page-title-24d86e72.js",
  "/_app/immutable/components/pages/settings/_page.svelte-77627ad4.js",
  "/_app/immutable/components/pages/_layout.svelte-3cc38fc8.js",
  "/_app/immutable/components/pages/b/_page.svelte-26688fc8.js",
  "/_app/immutable/components/pages/manage/_page.svelte-9a8c7745.js"
], w = [
  "/apple-touch-icon.png",
  "/favicon.ico",
  "/favicon.png",
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
], f = [
  "/",
  "/__data.json",
  "/b",
  "/b/__data.json",
  "/manage",
  "/manage/__data.json",
  "/settings",
  "/settings/__data.json"
], g = "1673178127438", o = self, u = `build:${g}`, x = new Set(f), _ = k.concat(w).concat(f), v = new Set(_);
o.addEventListener("install", (e) => {
  o.skipWaiting(), e.waitUntil(caches.open(u).then((s) => s.addAll(_)));
});
o.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((s) => {
      const a = s.filter((t) => t !== u);
      return Promise.all(a.map((t) => caches.delete(t)));
    })
  );
});
o.addEventListener("fetch", (e) => {
  if (e.request.method !== "GET" || e.request.headers.has("range"))
    return;
  const s = new URL(e.request.url), a = s.protocol.startsWith("http"), t = s.hostname === o.location.hostname && s.port !== o.location.port, i = s.host === o.location.host, p = i && v.has(s.pathname), n = e.request.cache === "only-if-cached" && !p;
  if (!(!a || t || n)) {
    if (i && x.has(s.pathname)) {
      const c = new Request(s.pathname);
      e.respondWith(
        b(e.request, !1, u, c)
      );
      return;
    }
    if (i) {
      const c = p ? caches.match(s.pathname).then((m) => m ?? fetch(e.request)) : R(e.request);
      if (c) {
        e.respondWith(c);
        return;
      }
    }
    s.host === "fonts.googleapis.com" && e.respondWith(b(e.request));
  }
});
async function b(e, s = !0, a, t) {
  const i = await caches.open(`other:${g}`), p = new AbortController();
  let n, c = !1, m = !1;
  const l = () => a ? caches.match(t ?? e, { cacheName: a }) : void 0, h = async () => {
    if (!s)
      return l();
    const r = await i.match(e);
    if (r)
      return r;
    if (!!a)
      return l();
  };
  try {
    const r = setTimeout(async () => {
      n = await h(), m = !0, !(!n || c) && p.abort();
    }, 1e3), d = await fetch(e, { signal: p.signal });
    return c = !0, clearTimeout(r), s && i.put(e, d.clone()), d;
  } catch (r) {
    if (m || (n = await h()), n)
      return n;
    throw r;
  }
}
function R(e) {
  const s = new URL(e.url), t = /\/b\/(?<id>\d+)\/?(\?|$)/.exec(s.pathname);
  if (t != null && t.groups)
    return y(`/b?${j(t.groups)}`);
}
function y(e) {
  return new Response(null, {
    status: 302,
    headers: {
      location: e
    }
  });
}
