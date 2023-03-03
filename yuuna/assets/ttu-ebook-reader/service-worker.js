function j(e) {
  return Object.entries(e).map(([s, a]) => `${encodeURIComponent(s)}=${encodeURIComponent(a)}`).join("&");
}
const k = [
  "/_app/immutable/assets/_page-b843624e.css",
  "/_app/immutable/assets/merged-header-icon-32503cb2.css",
  "/_app/immutable/assets/_layout-7b47a741.css",
  "/_app/immutable/chunks/stores-41bc0127.js",
  "/_app/immutable/chunks/storage-c0963857.js",
  "/_app/immutable/chunks/1-d6e2df69.js",
  "/_app/immutable/chunks/2-248ae2f9.js",
  "/_app/immutable/chunks/theme-option-56eff79b.js",
  "/_app/immutable/chunks/3-7a94f7e3.js",
  "/_app/immutable/chunks/utils-87ab534e.js",
  "/_app/immutable/chunks/5-a8b975f9.js",
  "/_app/immutable/chunks/0-5e766e1c.js",
  "/_app/immutable/chunks/4-feab9671.js",
  "/_app/immutable/components/pages/_page.svelte-ad22f881.js",
  "/_app/immutable/components/error.svelte-68a20358.js",
  "/_app/immutable/chunks/index-cb88fc2b.js",
  "/_app/immutable/chunks/dialog-manager-6307dd27.js",
  "/_app/immutable/chunks/singletons-54206af0.js",
  "/_app/immutable/start-6e359251.js",
  "/_app/immutable/chunks/format-page-title-d410bd5f.js",
  "/_app/immutable/chunks/merged-header-icon-3ae6f6f3.js",
  "/_app/immutable/components/pages/settings/_page.svelte-4df55ee5.js",
  "/_app/immutable/components/pages/_layout.svelte-f15cbc52.js",
  "/_app/immutable/components/pages/b/_page.svelte-282b9c01.js",
  "/_app/immutable/components/pages/manage/_page.svelte-ad04dff1.js"
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
  "/b.html",
  "/b/__data.json",
  "/manage.html",
  "/manage/__data.json",
  "/settings.html",
  "/settings/__data.json"
], g = "1677808139749", c = self, u = `build:${g}`, x = new Set(f), _ = k.concat(w).concat(f), v = new Set(_);
c.addEventListener("install", (e) => {
  c.skipWaiting(), e.waitUntil(caches.open(u).then((s) => s.addAll(_)));
});
c.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((s) => {
      const a = s.filter((t) => t !== u);
      return Promise.all(a.map((t) => caches.delete(t)));
    })
  );
});
c.addEventListener("fetch", (e) => {
  if (e.request.method !== "GET" || e.request.headers.has("range"))
    return;
  const s = new URL(e.request.url), a = s.protocol.startsWith("http"), t = s.hostname === c.location.hostname && s.port !== c.location.port, i = s.host === c.location.host, p = i && v.has(s.pathname), n = e.request.cache === "only-if-cached" && !p;
  if (!(!a || t || n)) {
    if (i && x.has(s.pathname)) {
      const o = new Request(s.pathname);
      e.respondWith(
        b(e.request, !1, u, o)
      );
      return;
    }
    if (i) {
      const o = p ? caches.match(s.pathname).then((m) => m ?? fetch(e.request)) : R(e.request);
      if (o) {
        e.respondWith(o);
        return;
      }
    }
    s.host === "fonts.googleapis.com" && e.respondWith(b(e.request));
  }
});
async function b(e, s = !0, a, t) {
  const i = await caches.open(`other:${g}`), p = new AbortController();
  let n, o = !1, m = !1;
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
      n = await h(), m = !0, !(!n || o) && p.abort();
    }, 1e3), d = await fetch(e, { signal: p.signal });
    return o = !0, clearTimeout(r), s && i.put(e, d.clone()), d;
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
