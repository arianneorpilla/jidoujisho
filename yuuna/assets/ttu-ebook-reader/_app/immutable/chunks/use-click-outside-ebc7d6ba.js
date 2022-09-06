var C=Object.defineProperty,d=Object.defineProperties;var m=Object.getOwnPropertyDescriptors;var u=Object.getOwnPropertySymbols;var h=Object.prototype.hasOwnProperty,f=Object.prototype.propertyIsEnumerable;var b=(o,r,e)=>r in o?C(o,r,{enumerable:!0,configurable:!0,writable:!0,value:e}):o[r]=e,n=(o,r)=>{for(var e in r||(r={}))h.call(r,e)&&b(o,e,r[e]);if(u)for(var e of u(r))f.call(r,e)&&b(o,e,r[e]);return o},t=(o,r)=>d(o,m(r));import{q as k}from"./store-afb7c6c1.js";import{h as F,j as T}from"./format-page-title-d2ff14dd.js";/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */function S(){return k(F(()=>""),T((o,r)=>!r))}/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */function s(o){return t(n({},o),{hintFuriganaFontColor:t(n({},o.fontColor),{a:o.fontColor.a?o.fontColor.a*.38:.38})})}const i=s({fontColor:{r:0,g:0,b:0,a:.87},backgroundColor:{r:255,g:255,b:255},selectionFontColor:{r:245,g:245,b:245},selectionBackgroundColor:{r:151,g:151,b:151},hintFuriganaFontColor:{r:0,g:0,b:0},hintFuriganaShadowColor:{r:34,g:34,b:49,a:.3},tooltipTextFontColor:{r:0,g:0,b:0,a:.6}}),g=s({fontColor:{r:255,g:255,b:255,a:.87},backgroundColor:{r:35,g:39,b:42},selectionFontColor:{r:85,g:90,b:92,a:.6},selectionBackgroundColor:{r:212,g:217,b:220,a:.8},hintFuriganaFontColor:{r:0,g:0,b:0},hintFuriganaShadowColor:{r:240,g:240,b:241,a:.3},tooltipTextFontColor:{r:255,g:255,b:255,a:.6}});function p(o){return Object.entries(o).reduce((r,[e,a])=>{var c;const l=a;return r[e]=`rgba(${l.r}, ${l.g}, ${l.b}, ${(c=l.a)!=null?c:1})`,r},{})}const j={lightTheme:i,ecruTheme:t(n({},i),{backgroundColor:{r:247,g:246,b:235}}),waterTheme:t(n({},i),{backgroundColor:{r:223,g:236,b:244}}),grayTheme:g,darkTheme:t(n({},g),{fontColor:{r:255,g:255,b:255,a:.6},backgroundColor:{r:18,g:18,b:18}}),blackTheme:t(n({},g),{backgroundColor:{r:0,g:0,b:0}})};function w(o){return o.replace(/[A-Z]/g,r=>`-${r.toLowerCase()}`)}const x=new Map(Object.entries(j).map(([o,r])=>[w(o),p(r)]));/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */function y(o,r){const e=a=>{!a.defaultPrevented&&!o.contains(a.target)&&r(a)};return document.addEventListener("click",e,!0),{destroy(){document.removeEventListener("click",e,!0)}}}export{x as a,y as c,S as r};
