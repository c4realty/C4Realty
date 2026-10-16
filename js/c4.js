/* C4 Realty · núcleo compartido de los diseños (datos, ficha, carrusel, contacto) */
(function () {
  const API = "https://c4realty-api.c4realty0.workers.dev";
  const BASE = window.C4_BASE || "";
  const WA = "50762531751";
  const $ = (s, r = document) => r.querySelector(s), $$ = (s, r = document) => [...r.querySelectorAll(s)];
  const esc = s => String(s ?? "").replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  const fmt = n => "$" + Math.round(n).toLocaleString("en-US");
  const ruta = r => !r ? "" : /^https?:/.test(r) ? r : BASE + r;
  const J = s => { try { const v = JSON.parse(s || "[]"); return Array.isArray(v) ? v : []; } catch (e) { return []; } };
  const CAT = { casa: "Casa", apartamento: "Casa", terreno: "Terreno", local: "Terreno", finca: "Finca", alquiler: "Alquiler" };

  /* ---------- diseño activo: cada diseño vive en su página ---------- */
  const PAG = { azul: "index.html", residencial: "d/residencial.html", cinematico: "d/cinematico.html" };
  function irDiseno(layout, propio) {
    if (/[?&]vista=/.test(location.search)) return;
    const l = PAG[layout] ? layout : "azul"; if (l === propio) return;
    const q = location.search.replace(/^\?/, ""), dest = BASE + PAG[l] + (q ? "?" + q : "") + location.hash;
    location.replace(dest);
  }
  function tema(propio) {
    try { const t = JSON.parse(localStorage.getItem("c4_tema") || "null"); if (t && t.tokens) irDiseno(t.tokens.layout || "azul", propio); } catch (e) { }
    fetch(API + "/public/sitio").then(r => r.ok ? r.json() : null).then(j => { if (!j || !j.plantilla) return; try { localStorage.setItem("c4_tema", JSON.stringify(j.plantilla)); } catch (e) { } irDiseno(j.plantilla.tokens.layout || "azul", propio); }).catch(() => { });
  }

  /* ---------- datos ---------- */
  function mapear(d) {
    const vr = [], pg = []; let av = "";
    J(d.pagos).forEach(x => { x = String(x).trim(); const m = /^(.+?):\s*\$\s*([\d,]+(?:\.\d+)?)$/.exec(x); if (m) vr.push([m[1], +m[2].replace(/,/g, "")]); else if (/^importante\s*:/i.test(x)) av = x.replace(/^importante\s*:\s*/i, ""); else if (x) pg.push(x); });
    let kv = J(d.caracteristicas).map(x => Array.isArray(x) ? x.map(String) : [String(x), ""]);
    if (!kv.length) kv = [["Recámaras", d.recamaras], ["Baños", d.banos], ["Lote", d.lote_m2 ? (+d.lote_m2) + " m²" : ""]].filter(x => x[1]);
    let M = []; try { M = JSON.parse(d.medios_json || "[]"); } catch (e) { }
    M.sort((a, b) => (a.o || 0) - (b.o || 0));
    const img = M.filter(x => x.t === "volante" || x.t === "foto").map(x => ruta(x.r));
    const plano = M.filter(x => x.t === "plano").map(x => ["Plano " + x.r.split("/").pop().replace(/\.pdf$/i, "").replace(/-/g, " ").replace(/\b\w/g, c => c.toUpperCase()), ruta(x.r)]);
    const vids = M.filter(x => x.t === "video").map(x => ruta(x.r).replace(/\.mp4$/i, ""));
    const ant = +d.precio_antes > +d.precio ? +d.precio_antes : null;
    return { id: d.codigo, cat: CAT[d.categoria] || "Casa", n: d.titulo, z: d.zona || "", zl: d.zona_detalle || "", precio: d.precio, antes: ant, desde: !!d.precio_desde, tag: d.estado === "reservada" ? "Reservada" : d.estado === "en_negociacion" ? "En negociación" : (d.etiqueta || ""), destacada: +d.destacada === 1, lote: d.lote_m2 ? +d.lote_m2 : null, kv, pts: J(d.incluye).map(String), pagos: pg, vr, aviso: av, txt: d.descripcion || "", img: img.length ? img : [ruta(d.imagen) || BASE + "img/logo.png"], plano, vids };
  }
  async function cargar() {
    const tryJ = async (u, ms) => { const c = new AbortController(); const t = setTimeout(() => c.abort(), ms); try { const r = await fetch(u, { signal: c.signal }); if (!r.ok) throw 0; return await r.json(); } finally { clearTimeout(t); } };
    let L = null; try { L = await tryJ(API + "/public/catalogo", 7000); } catch (e) { }
    if (!Array.isArray(L) || !L.length) { try { L = await tryJ(BASE + "data/catalogo.json", 7000); } catch (e) { L = []; } }
    return L.map(mapear);
  }
  const desc = p => p.antes ? Math.round((1 - p.precio / p.antes) * 100) : 0;
  const precioTxt = p => p.precio == null ? "Consultar" : (p.desde ? "Desde " : "") + fmt(p.precio);
  const datos = p => { const g = k => (p.kv.find(x => x[0] === k) || [])[1]; return [g("Recámaras") && g("Recámaras") + " rec.", g("Baños") && g("Baños") + (g("Baños") === "1" ? " baño" : " baños"), (g("Lote") || g("Lotes")) && "Lote " + (g("Lote") || g("Lotes"))].filter(Boolean); };
  const link = p => { try { return new URL(BASE + "?p=" + encodeURIComponent(p.id), location.href).href; } catch (e) { return "?p=" + p.id; } };
  const waHref = t => "https://wa.me/" + WA + "?text=" + encodeURIComponent(t);
  const waProp = p => waHref("Hola C4 Realty, me interesa: " + p.n + (p.z ? " (" + p.z + ")" : "") + ".\n" + link(p));

  /* ---------- estilos de ficha y carrusel (toman los colores de cada diseño) ---------- */
  const CSS = `
.c4f{position:fixed;inset:0;z-index:80;display:none}.c4f.open{display:block}
.c4f-scrim{position:absolute;inset:0;background:rgba(10,14,18,.55);backdrop-filter:blur(3px)}
.c4f-panel{position:absolute;top:0;right:0;bottom:0;width:min(620px,100%);overflow:auto;background:var(--f-bg,#fff);color:var(--f-fg,#14171c);font-family:var(--f-body,inherit);box-shadow:-30px 0 60px rgba(0,0,0,.25);animation:c4in .28s ease}
@keyframes c4in{from{transform:translateX(40px);opacity:.4}to{transform:none;opacity:1}}
@media (prefers-reduced-motion:reduce){.c4f-panel{animation:none}}
.c4f-bar{position:sticky;top:0;z-index:2;display:flex;justify-content:space-between;align-items:center;padding:12px 18px;background:color-mix(in srgb,var(--f-bg,#fff) 92%,transparent);backdrop-filter:blur(8px);border-bottom:1px solid var(--f-line,#e6e8ec)}
.c4f-bar button{border:0;background:transparent;color:inherit;font:inherit;font-weight:600;cursor:pointer;padding:8px 10px;border-radius:8px}
.c4f-hero{position:relative;background:var(--f-media,#0b1526)}
.c4f-hero img{display:block;width:100%;max-height:min(600px,70vh);object-fit:contain;margin:0 auto;cursor:zoom-in}
.c4f-nav{position:absolute;top:50%;transform:translateY(-50%);width:44px;height:44px;border-radius:50%;border:0;background:rgba(255,255,255,.9);color:#14171c;font-size:1.5rem;cursor:pointer;display:grid;place-items:center;padding-bottom:3px}
.c4f-nav.p{left:12px}.c4f-nav.n{right:12px}
.c4f-th{display:flex;gap:6px;overflow-x:auto;padding:10px 18px 0}
.c4f-th button{flex:none;width:56px;height:56px;border-radius:8px;overflow:hidden;border:2px solid transparent;padding:0;cursor:pointer;background:var(--f-soft,#f4f5f7)}
.c4f-th button.on{border-color:var(--f-acc,#14171c)}.c4f-th img{width:100%;height:100%;object-fit:cover}
.c4f-body{padding:20px 22px 34px;display:grid;gap:22px}
.c4f-body h2{font-family:var(--f-title,inherit);font-size:clamp(1.6rem,4vw,2.2rem);line-height:1.08;margin:0;font-weight:var(--f-tw,700)}
.c4f-loc{color:var(--f-mut,#6b7280);margin-top:6px}
.c4f-price{font-family:var(--f-title,inherit);font-size:2rem;font-weight:700;display:flex;gap:10px;align-items:baseline;flex-wrap:wrap}
.c4f-price s{font-size:1rem;color:var(--f-mut,#6b7280);font-weight:500}.c4f-price small{font-size:.9rem;color:var(--f-mut);font-weight:500}
.c4f-tag{display:inline-block;background:var(--f-acc,#14171c);color:var(--f-acc-ink,#fff);border-radius:999px;padding:5px 12px;font-size:.82rem;font-weight:700}
.c4f-sec{display:grid;gap:10px}.c4f-sec h3{margin:0;font-size:.95rem;font-weight:700;padding-bottom:8px;border-bottom:1px solid var(--f-line,#e6e8ec)}
.c4f-rows div{display:grid;grid-template-columns:140px 1fr;gap:12px;padding:6px 0}.c4f-rows span:first-child{color:var(--f-mut,#6b7280)}
.c4f-vr{border:1px solid var(--f-line,#e6e8ec);border-radius:12px;overflow:hidden}.c4f-vr div{display:flex;justify-content:space-between;gap:12px;padding:10px 14px}.c4f-vr div+div{border-top:1px solid var(--f-line,#e6e8ec)}.c4f-vr b{white-space:nowrap}
.c4f ul{margin:0;padding-left:18px;display:grid;gap:6px}
.c4f-aviso{background:#fff4e5;border:1px solid #f5c98b;color:#5c3a00;border-radius:10px;padding:10px 14px;font-size:.9rem}
.c4f-btns{display:flex;gap:10px;flex-wrap:wrap}
.c4f-btn{display:inline-flex;align-items:center;gap:8px;border-radius:999px;padding:12px 18px;font-weight:700;text-decoration:none;border:1px solid var(--f-line,#e6e8ec);background:transparent;color:inherit;cursor:pointer;font:inherit;font-weight:700}
.c4f-btn.wa{background:#25d366;border-color:#25d366;color:#05230f}
.c4f-vids{display:grid;grid-template-columns:repeat(3,1fr);gap:8px}.c4f-vids video{width:100%;aspect-ratio:9/16;object-fit:cover;border-radius:12px;background:#000}
.c4f details{border:1px solid var(--f-line,#e6e8ec);border-radius:10px;padding:10px 14px}.c4f summary{cursor:pointer;font-weight:600}.c4f details p{white-space:pre-line;margin:8px 0 0;font-size:.92rem}
.c4lb{position:fixed;inset:0;z-index:95;background:rgba(6,9,12,.97);display:none;grid-template-rows:auto 3px 1fr auto;color:#fff;font-family:var(--f-body,system-ui)}.c4lb.open{display:grid}
.c4lb-top{display:flex;align-items:center;gap:10px;padding:12px 16px}.c4lb-cap{flex:1;min-width:0;display:grid}.c4lb-cap b{white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.c4lb-cap span{font-size:.8rem;color:#aab4c0}
.c4lb-b{height:42px;min-width:42px;border-radius:999px;border:1px solid rgba(255,255,255,.25);background:transparent;color:#fff;cursor:pointer;padding:0 12px;font:inherit;font-weight:700;text-decoration:none;display:inline-flex;align-items:center}
.c4lb-bar{background:rgba(255,255,255,.08)}.c4lb-bar i{display:block;height:100%;width:0;background:var(--f-acc,#f2b84b)}.c4lb-bar i.run{animation:c4bar 3.2s linear forwards}@keyframes c4bar{to{width:100%}}
.c4lb-st{position:relative;overflow:hidden;min-height:0;scrollbar-width:none}.c4lb-st::-webkit-scrollbar{display:none}
.c4lb-st img{position:absolute;inset:0;margin:auto;max-width:100%;max-height:100%;object-fit:contain;transition:opacity .35s}
.c4lb-st.z{overflow:auto}.c4lb-st.z img{position:static;max-width:none;max-height:none;margin:0 auto;cursor:grab}
.c4lb-nav{position:fixed;top:50%;transform:translateY(-50%);width:50px;height:50px;border-radius:50%;border:1px solid rgba(255,255,255,.3);background:rgba(15,20,30,.6);color:#fff;font-size:1.8rem;cursor:pointer;display:grid;place-items:center;padding-bottom:4px}.c4lb-nav.p{left:12px}.c4lb-nav.n{right:12px}
.c4lb-th{display:flex;gap:8px;overflow-x:auto;padding:12px 16px;justify-content:safe center}.c4lb-th button{flex:none;width:52px;height:68px;border-radius:8px;overflow:hidden;border:2px solid transparent;padding:0;opacity:.55;cursor:pointer;background:#111}.c4lb-th button.on{opacity:1;border-color:var(--f-acc,#f2b84b)}.c4lb-th img{width:100%;height:100%;object-fit:cover}
:where(.c4f,.c4lb) :focus-visible{outline:2px solid var(--f-acc,#f2b84b);outline-offset:2px}
@media (max-width:620px){.c4f-vids{grid-template-columns:repeat(2,1fr)}.c4f-rows div{grid-template-columns:110px 1fr}}`;
  function montar() {
    if ($("#c4f")) return;
    const st = document.createElement("style"); st.textContent = CSS; document.head.append(st);
    document.body.insertAdjacentHTML("beforeend", `<div class="c4f" id="c4f" role="dialog" aria-modal="true" aria-label="Ficha de la casa"><div class="c4f-scrim" data-x></div><div class="c4f-panel" id="c4f-p"></div></div>
<div class="c4lb" id="c4lb" role="dialog" aria-modal="true" aria-label="Fotos"><div class="c4lb-top"><div class="c4lb-cap"><b id="c4lb-c"></b><span id="c4lb-n"></span></div><a class="c4lb-b" id="c4lb-pdf" target="_blank" rel="noopener">Descargar PDF</a><button class="c4lb-b" id="c4lb-play" type="button" aria-label="Pausar">❚❚</button><button class="c4lb-b" id="c4lb-x" type="button" aria-label="Cerrar">✕</button></div><div class="c4lb-bar"><i id="c4lb-bar"></i></div><div class="c4lb-st" id="c4lb-st"><img id="c4lb-i" alt="" draggable="false"></div><div class="c4lb-th" id="c4lb-th"></div><button class="c4lb-nav p" id="c4lb-p" type="button" aria-label="Anterior">‹</button><button class="c4lb-nav n" id="c4lb-nx" type="button" aria-label="Siguiente">›</button></div>`);
    $("#c4f").addEventListener("click", e => { if (e.target.closest("[data-x]")) cerrar(); });
    $("#c4lb-x").onclick = lbCerrar; $("#c4lb-p").onclick = () => lbGo(I - 1); $("#c4lb-nx").onclick = () => lbGo(I + 1); $("#c4lb-play").onclick = () => play(!T);
    const stg = $("#c4lb-st"); let x0 = null, mv = false, pan = null;
    stg.addEventListener("pointerdown", e => { mv = false; if (stg.classList.contains("z")) { if (e.pointerType === "mouse") { pan = { x: e.clientX, y: e.clientY, l: stg.scrollLeft, t: stg.scrollTop }; e.preventDefault(); } return; } x0 = e.clientX; });
    stg.addEventListener("pointermove", e => { if (pan) { mv = true; stg.scrollLeft = pan.l - (e.clientX - pan.x); stg.scrollTop = pan.t - (e.clientY - pan.y); return; } if (x0 !== null && Math.abs(e.clientX - x0) > 12) mv = true; });
    addEventListener("pointerup", () => { pan = null; });
    stg.addEventListener("pointerup", e => { if (x0 === null) return; const dx = e.clientX - x0; x0 = null; if (Math.abs(dx) > 50) lbGo(I + (dx < 0 ? 1 : -1)); });
    $("#c4lb-i").addEventListener("click", e => { if (mv) { mv = false; return; } zoom(!stg.classList.contains("z"), e); });
    document.addEventListener("keydown", e => {
      if ($("#c4lb").classList.contains("open")) { if (e.key === "Escape") lbCerrar(); if (e.key === "ArrowRight") lbGo(I + 1); if (e.key === "ArrowLeft") lbGo(I - 1); return; }
      if ($("#c4f").classList.contains("open") && e.key === "Escape") cerrar();
    });
  }
  /* carrusel */
  let S = [], I = 0, T = null;
  function play(on) { clearInterval(T); T = null; if (on && S.length > 1) T = setInterval(() => { if (!$("#c4lb-st").classList.contains("z")) lbGo(I + 1, true); }, 3200); $("#c4lb-play").textContent = T ? "❚❚" : "▶"; const b = $("#c4lb-bar"); b.classList.toggle("run", !!T); }
  function zoom(on, ev) {
    if (on && !(S[I] && S[I].plano)) on = false; if (on && T) play(false);
    const st = $("#c4lb-st"), im = $("#c4lb-i"), r = im.getBoundingClientRect(); im.style.width = on ? Math.round(r.width * 2.4) + "px" : ""; st.classList.toggle("z", !!on);
    if (on && ev) setTimeout(() => { st.scrollLeft = (ev.clientX - r.left) / r.width * im.offsetWidth - st.clientWidth / 2; st.scrollTop = (ev.clientY - r.top) / r.height * im.offsetHeight - st.clientHeight / 2; }, 30);
  }
  function lbGo(k, auto) {
    if (!S.length) return; if (!auto && T) play(false); I = (k + S.length) % S.length; const x = S[I]; zoom(false);
    const im = $("#c4lb-i"); im.style.opacity = 0; im.onload = () => im.style.opacity = 1; im.src = x.src; if (im.complete) im.style.opacity = 1; im.style.cursor = x.plano ? "zoom-in" : "default";
    $("#c4lb-c").textContent = x.cap; $("#c4lb-n").textContent = (x.plano ? "Plano · " : "Foto ") + (I + 1) + " de " + S.length;
    const a = $("#c4lb-pdf"); a.style.display = x.pdf ? "" : "none"; if (x.pdf) a.href = x.pdf;
    $("#c4lb-p").style.display = $("#c4lb-nx").style.display = $("#c4lb-play").style.display = S.length > 1 ? "" : "none";
    $$("#c4lb-th button").forEach((b, j) => b.classList.toggle("on", j === I)); const t = $$("#c4lb-th button")[I]; if (t) t.scrollIntoView({ block: "nearest", inline: "center" });
    const bar = $("#c4lb-bar"); bar.classList.remove("run"); void bar.offsetWidth; if (T) bar.classList.add("run");
  }
  function galeria(p, i, auto) {
    montar();
    S = p.img.map(src => ({ src, cap: p.n + (p.z ? ", " + p.z : "") })).concat(p.plano.map(([t, u]) => ({ src: u.replace(/\.pdf$/i, ".jpg"), cap: t, pdf: u, plano: 1 })));
    $("#c4lb-th").innerHTML = S.map((x, k) => `<button type="button" aria-label="Imagen ${k + 1}"><img src="${esc(x.src)}" alt="" loading="lazy"></button>`).join("");
    $$("#c4lb-th button").forEach((b, k) => b.onclick = () => lbGo(k));
    $("#c4lb").classList.add("open"); lbGo(i || 0, true); play(auto !== false);
  }
  function lbCerrar() { play(false); zoom(false); $("#c4lb").classList.remove("open"); }

  /* ficha */
  let CUR = null, CI = 0;
  function verFoto(i) { if (!CUR) return; CI = (i + CUR.img.length) % CUR.img.length; $("#c4f-img").src = CUR.img[CI]; $$("#c4f-th button").forEach((b, k) => b.classList.toggle("on", k === CI)); }
  function ficha(p) {
    montar(); CUR = p; CI = 0;
    const d = desc(p);
    $("#c4f-p").innerHTML = `<div class="c4f-bar"><button type="button" data-x>‹ Volver</button><span style="font-size:.85rem;color:var(--f-mut)">${esc(p.z)}</span></div>
     <div class="c4f-hero"><img id="c4f-img" alt="${esc(p.n)}">${p.img.length > 1 ? `<button type="button" class="c4f-nav p" aria-label="Foto anterior">‹</button><button type="button" class="c4f-nav n" aria-label="Foto siguiente">›</button>` : ""}</div>
     ${p.img.length > 1 ? `<div class="c4f-th" id="c4f-th">${p.img.map((s, k) => `<button type="button" aria-label="Foto ${k + 1}"><img src="${esc(s)}" alt="" loading="lazy"></button>`).join("")}</div>` : ""}
     <div class="c4f-body">
      <div><h2>${esc(p.n)}</h2><div class="c4f-loc">${esc(p.zl || p.z)}${p.z ? ", Chiriquí" : ""}</div></div>
      ${p.tag ? `<div><span class="c4f-tag">${esc(p.tag)}</span></div>` : ""}
      <div class="c4f-price">${esc(precioTxt(p))}${p.antes ? `<s>${fmt(p.antes)}</s><small>−${d} %</small>` : ""}</div>
      ${p.kv.length ? `<div class="c4f-sec"><h3>Características</h3><div class="c4f-rows">${p.kv.map(([k, v]) => `<div><span>${esc(k)}</span><span>${esc(v)}</span></div>`).join("")}</div></div>` : ""}
      ${p.pts.length ? `<div class="c4f-sec"><h3>Lo que incluye</h3><ul>${p.pts.map(x => `<li>${esc(x)}</li>`).join("")}</ul></div>` : ""}
      ${p.vr.length || p.pagos.length || p.aviso ? `<div class="c4f-sec"><h3>Precio y financiamiento</h3>${p.vr.length ? `<div class="c4f-vr">${p.vr.map(([k, v]) => `<div><span>${esc(k)}</span><b>${fmt(v)}</b></div>`).join("")}</div>` : ""}${p.pagos.length ? `<ul>${p.pagos.map(x => `<li>${esc(x)}</li>`).join("")}</ul>` : ""}${p.aviso ? `<div class="c4f-aviso"><b>Importante:</b> ${esc(p.aviso)}</div>` : ""}</div>` : ""}
      ${p.plano.length ? `<div class="c4f-sec"><h3>Plano</h3><div class="c4f-btns">${p.plano.map(([t], k) => `<button type="button" class="c4f-btn" data-pl="${k}">Ver ${esc(t)}</button>`).join("")}</div></div>` : ""}
      ${p.vids.length ? `<div class="c4f-sec"><h3>Videos</h3><div class="c4f-vids">${p.vids.map(v => `<video autoplay muted loop playsinline preload="metadata" poster="${esc(v)}.jpg" src="${esc(v)}.mp4"></video>`).join("")}</div></div>` : ""}
      ${p.txt ? `<details><summary>Texto completo</summary><p>${esc(p.txt)}</p></details>` : ""}
      <div class="c4f-btns"><a class="c4f-btn wa" href="${esc(waProp(p))}" target="_blank" rel="noopener">Consultar por WhatsApp</a><button type="button" class="c4f-btn" data-cita>Agendar recorrido</button></div>
      <p style="font-size:.8rem;color:var(--f-mut);margin:0">Confirma precio y disponibilidad por WhatsApp al 6253-1751.</p>
     </div>`;
    verFoto(0);
    $("#c4f-img").onclick = () => galeria(p, CI, true);
    const nv = $$(".c4f-nav"); if (nv.length) { nv[0].onclick = () => verFoto(CI - 1); nv[1].onclick = () => verFoto(CI + 1); }
    $$("#c4f-th button").forEach((b, k) => b.onclick = () => verFoto(k));
    $$("[data-pl]").forEach(b => b.onclick = () => galeria(p, p.img.length + +b.dataset.pl, false));
    $("[data-cita]").onclick = () => { cerrar(); const f = document.querySelector("[data-c4-contacto]"); if (f) { const s = f.querySelector("select"); if (s) s.value = p.id; f.scrollIntoView({ behavior: "smooth", block: "center" }); } };
    $("#c4f").classList.add("open"); document.body.style.overflow = "hidden"; $("#c4f-p").scrollTop = 0;
  }
  function cerrar() { $$("#c4f video").forEach(v => v.pause()); $("#c4f").classList.remove("open"); document.body.style.overflow = ""; }

  /* fotos que cambian al pasar el mouse */
  function hover(sel, P) {
    let t = null, box = null, k = 0;
    const stop = () => { clearInterval(t); t = null; if (box) { const p = P.find(x => x.id === box.dataset.c4); const im = box.querySelector("img"); if (p && im) im.src = p.img[0]; } box = null; };
    document.addEventListener("mouseover", e => {
      const g = e.target.closest(sel); if (g === box) return; stop(); if (!g || !matchMedia("(hover:hover)").matches) return;
      const p = P.find(x => x.id === g.dataset.c4); if (!p || p.img.length < 2) return; box = g; k = 0;
      p.img.slice(1, 4).forEach(s => { const i = new Image(); i.src = s; });
      t = setInterval(() => { if (!box) return; k = (k + 1) % p.img.length; const im = box.querySelector("img"); if (im) { im.style.opacity = .35; setTimeout(() => { im.src = p.img[k]; im.style.opacity = 1; }, 160); } }, 1300);
    });
  }

  /* aviso por correo de cada formulario (FormSubmit; la primera vez hay que activarlo desde el correo) */
  const AVISO = "c4realty0@gmail.com";
  async function avisar(d) {
    if (d.sitio_web) return;
    try {
      await fetch("https://formsubmit.co/ajax/" + AVISO, { method: "POST", headers: { "Content-Type": "application/json", Accept: "application/json" },
        body: JSON.stringify({ _subject: "Nuevo cliente desde la página: " + (d.nombre || ""), _template: "table", _captcha: "false", Nombre: d.nombre || "", "Teléfono": d.telefono || "", Correo: d.email || "", "Salario mensual": d.ingreso_mensual || d.salario || "", "Casa que le interesa": d.interes || "Aún no sabe", "Página": location.href }) });
    } catch (e) { }
  }
  /* contacto */
  async function contacto(form, P) {
    const msg = form.querySelector("[data-msg]");
    form.addEventListener("submit", async e => {
      e.preventDefault(); const f = new FormData(form);
      const prop = P.find(p => p.id === f.get("propiedad"));
      const body = { nombre: String(f.get("nombre") || "").trim(), telefono: f.get("telefono"), email: f.get("email") || "", ingreso_mensual: f.get("salario") || "", propiedad: f.get("propiedad") || "", interes: prop ? prop.n + (prop.z ? " (" + prop.z + ")" : "") : "", origen: "web_contacto", sitio_web: f.get("sitio_web") || "" };
      if (!body.nombre || !body.telefono) { msg.textContent = "Escribe tu nombre y tu teléfono."; return; }
      avisar(body);
      let ok = false; try { const r = await fetch(API + "/public/contacto", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) }); ok = r.ok; } catch (x) { }
      msg.textContent = ok ? "Recibido. Te escribimos pronto por WhatsApp." : "No se pudo enviar. Escríbenos al 6253-1751."; if (ok) form.reset();
    });
  }
  /* enlace directo ?p=codigo */
  function abrirDesdeUrl(P) { try { const c = new URLSearchParams(location.search).get("p"); const p = c && P.find(x => x.id === c); if (p) ficha(p); } catch (e) { } }

  window.C4 = { avisar, API, WA, $, $$, esc, fmt, ruta, cargar, desc, precioTxt, datos, link, waHref, waProp, ficha, galeria, hover, contacto, abrirDesdeUrl, tema, montar };
})();
