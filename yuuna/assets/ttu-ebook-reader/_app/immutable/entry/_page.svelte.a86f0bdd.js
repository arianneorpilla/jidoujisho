import{S as u,i as f,a as p,b as _,l as b,G as h,j as i,c as v,m as g,p as $,d as l,a5 as x,n as d}from"../chunks/index.a1b1e1bc.js";import{f as m,g as y}from"../chunks/format-page-title.f8574fd6.js";import{j as P,m as j,p as E,t as H}from"../chunks/store.16eecc84.js";/**
 * @license BSD-3-Clause
 * Copyright (c) 2023, ッツ Reader Authors
 * All rights reserved.
 */function I(n,e){const t=e.subscribe();return{destroy:()=>t.unsubscribe()}}function N(n){let e,t,s,r,c;return document.title=e=m("Home"),{c(){t=_(),s=b("div")},l(a){h("svelte-1o30anf",document.head).forEach(i),t=v(a),s=g(a,"DIV",{}),$(s).forEach(i)},m(a,o){l(a,t,o),l(a,s,o),r||(c=x(I.call(null,s,n[0])),r=!0)},p(a,[o]){o&0&&e!==(e=m("Home"))&&(document.title=e)},i:d,o:d,d(a){a&&i(t),a&&i(s),r=!1,c()}}}function S(n){return[P.lastItem$.pipe(j(t=>t?`${E}/b?id=${t.dataId}`:"manage"),H(y))]}class G extends u{constructor(e){super(),f(this,e,S,N,p,{})}}export{G as default};
