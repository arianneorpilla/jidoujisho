import{S as o,i as s,n as r}from"../../chunks/index-51808792.js";/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */function a(e){return Object.entries(e).map(([t,n])=>`${encodeURIComponent(t)}=${encodeURIComponent(n)}`).join("&")}const c=({params:e})=>({status:302,redirect:`/b?${a(e)}`});class u extends o{constructor(t){super(),s(this,t,null,null,r,{})}}export{u as default,c as load};
