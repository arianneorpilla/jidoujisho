function j(e) {
  return Object.entries(e).map(([s, a]) => `${encodeURIComponent(s)}=${encodeURIComponent(a)}`).join("&");
}
const k = [
  "/_app/immutable/assets/merged-header-icon-32503cb2.css",
  "/_app/immutable/assets/_page-b843624e.css",
  "/_app/immutable/assets/_layout-0bd84ed3.css",
  "/_app/immutable/components/pages/_page.svelte-2cfb38ff.js",
  "/_app/immutable/chunks/theme-option-fbb9d515.js",
  "/_app/immutable/chunks/stores-41bc0127.js",
  "/_app/immutable/chunks/utils-87ab534e.js",
  "/_app/immutable/components/error.svelte-68a20358.js",
  "/_app/immutable/chunks/storage-c0963857.js",
  "/_app/immutable/chunks/2-aed06ae9.js",
  "/_app/immutable/chunks/4-7c8d775b.js",
  "/_app/immutable/chunks/0-924cb057.js",
  "/_app/immutable/chunks/1-d6e2df69.js",
  "/_app/immutable/chunks/index-970eb221.js",
  "/_app/immutable/chunks/5-d31ee921.js",
  "/_app/immutable/chunks/3-a33c2a11.js",
  "/_app/immutable/chunks/dialog-manager-6307dd27.js",
  "/_app/immutable/chunks/singletons-54206af0.js",
  "/_app/immutable/start-c71708d3.js",
  "/_app/immutable/chunks/format-page-title-2ec229d3.js",
  "/_app/immutable/chunks/merged-header-icon-f43ceb7d.js",
  "/_app/immutable/components/pages/settings/_page.svelte-7702f7ef.js",
  "/_app/immutable/components/pages/_layout.svelte-af2db04c.js",
  "/_app/immutable/components/pages/b/_page.svelte-d73721fb.js",
  "/_app/immutable/components/pages/manage/_page.svelte-ea0b31ea.js"
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
], g = [
  "/",
  "/__data.json",
  "/b.html",
  "/b/__data.json",
  "/manage.html",
  "/manage/__data.json",
  "/settings.html",
  "/settings/__data.json"
], f = "1673248452555", o = self, u = `build:${f}`, x = new Set(g), _ = k.concat(w).concat(g), v = new Set(_);
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
  const i = await caches.open(`other:${f}`), p = new AbortController();
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
