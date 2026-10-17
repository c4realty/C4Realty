// C4 Realty · API (Cloudflare Worker)
// Puente entre la página/panel y la base de datos D1 "c4realty" (binding: DB).
// Secretos opcionales: HUBSPOT_TOKEN (Service Key de HubSpot).

const ITER = 100000;               // PBKDF2 (máximo permitido en Workers)
const SESION_DIAS = 7;
const ETAPAS_HS = {                // etapas de Alicia → etapas por defecto de HubSpot
  cotizacion: 'appointmentscheduled', recorrido: 'qualifiedtobuy', apartado: 'presentationscheduled',
  documentacion: 'decisionmakerboughtin', aprobacion: 'decisionmakerboughtin', contrato: 'contractsent',
  abonos: 'contractsent', entregado: 'closedwon', perdido: 'closedlost'
};

// Tablas que el panel puede manejar, columnas editables y si tienen "asesor" (para alcance propios)
const TABLAS = {
  propiedades: { mod: 'propiedades', own: 'asesor_id', cols: ['codigo','proyecto_id','categoria','titulo','zona','zona_detalle','provincia','precio','precio_antes','precio_desde','precio_texto','renta_mensual','recamaras','banos','estacionamiento','lote_m2','construccion_m2','caracteristicas','incluye','pagos','descripcion','estado','etiqueta','publicada','destacada','orden','asesor_id','fecha_publicacion'], json: ['caracteristicas','incluye','pagos'] },
  clientes:    { mod: 'clientes', own: 'asesor_id', cols: ['nombre','telefono','email','tipo_ingreso','ingreso_mensual','origen','estado','asesor_id','primera_vivienda','banco_preferido','notas'] },
  negocios:    { mod: 'negocios', own: 'asesor_id', cols: ['cliente_id','propiedad_id','etapa','monto','banco','usa_bono','asesor_id','motivo_perdida'] },
  citas:       { mod: 'citas', own: 'asesor_id', cols: ['cliente_id','propiedad_id','tipo','fecha_hora','estado','asesor_id','notas'] },
  medios:      { mod: 'medios', cols: ['propiedad_id','tipo','ruta','portada','es_principal','orden'] },
};

const LISTAS = {
  propiedades: `SELECT p.*, u.nombre AS asesor,
      (SELECT ruta FROM medios m WHERE m.propiedad_id=p.id AND m.tipo IN ('foto','volante') ORDER BY m.es_principal DESC, m.orden LIMIT 1) AS imagen,
      (SELECT COUNT(*) FROM medios m WHERE m.propiedad_id=p.id AND m.tipo IN ('foto','volante')) AS n_fotos,
      (SELECT COUNT(*) FROM medios m WHERE m.propiedad_id=p.id AND m.tipo='video') AS n_videos,
      (SELECT COUNT(*) FROM negocios n WHERE n.propiedad_id=p.id AND n.etapa NOT IN ('entregado','perdido')) AS n_negocios
    FROM propiedades p LEFT JOIN usuarios u ON u.id=p.asesor_id`,
  clientes: `SELECT c.*, u.nombre AS asesor,
      (SELECT COUNT(*) FROM negocios n WHERE n.cliente_id=c.id AND n.etapa NOT IN ('entregado','perdido')) AS n_negocios
    FROM clientes c LEFT JOIN usuarios u ON u.id=c.asesor_id`,
  negocios: `SELECT n.*, c.nombre AS cliente, c.telefono AS cliente_tel, p.titulo AS propiedad, p.codigo AS propiedad_codigo, u.nombre AS asesor
    FROM negocios n JOIN clientes c ON c.id=n.cliente_id LEFT JOIN propiedades p ON p.id=n.propiedad_id LEFT JOIN usuarios u ON u.id=n.asesor_id`,
  citas: `SELECT ci.*, c.nombre AS cliente, c.telefono AS cliente_tel, p.titulo AS propiedad, u.nombre AS asesor
    FROM citas ci JOIN clientes c ON c.id=ci.cliente_id LEFT JOIN propiedades p ON p.id=ci.propiedad_id LEFT JOIN usuarios u ON u.id=ci.asesor_id`,
  medios: `SELECT m.* FROM medios m`,
};
const ALIAS = { propiedades: 'p', clientes: 'c', negocios: 'n', citas: 'ci', medios: 'm' };
const ORDEN = { propiedades: 'p.orden, p.id', clientes: 'c.creado_en DESC', negocios: 'n.actualizado_en DESC', citas: 'ci.fecha_hora DESC', medios: 'm.propiedad_id, m.orden' };

// ---------------------------------------------------------------- utilidades
const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET,POST,PATCH,DELETE,OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization,X-Mime,X-Nombre,X-Subida',
  'Access-Control-Max-Age': '86400',
};
const json = (data, status = 200) => new Response(JSON.stringify(data), { status, headers: { 'Content-Type': 'application/json; charset=utf-8', ...CORS } });
const err = (msg, status = 400) => json({ error: msg }, status);
class HttpError extends Error { constructor(msg, status) { super(msg); this.status = status; } }
const fail = (msg, status = 400) => { throw new HttpError(msg, status); };

const hex = (buf) => [...new Uint8Array(buf)].map(b => b.toString(16).padStart(2, '0')).join('');
const randHex = (n) => hex(crypto.getRandomValues(new Uint8Array(n)));
async function sha256(txt) { return hex(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(txt))); }
async function pbkdf2(clave, salHex) {
  const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(clave), 'PBKDF2', false, ['deriveBits']);
  const sal = new Uint8Array(salHex.match(/../g).map(h => parseInt(h, 16)));
  return hex(await crypto.subtle.deriveBits({ name: 'PBKDF2', hash: 'SHA-256', salt: sal, iterations: ITER }, key, 256));
}
function igual(a, b) { if (!a || !b || a.length !== b.length) return false; let r = 0; for (let i = 0; i < a.length; i++) r |= a.charCodeAt(i) ^ b.charCodeAt(i); return r === 0; }
function claveValida(c) { return typeof c === 'string' && c.length >= 8 && /[A-Za-z]/.test(c) && /\d/.test(c); }
function codigoActivacion() { const a = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; const b = crypto.getRandomValues(new Uint8Array(8)); return [...b].map(x => a[x % a.length]).join('').replace(/(.{4})/, '$1-'); }

async function cuerpo(req) { try { return await req.json(); } catch { return {}; } }
const ip = (req) => req.headers.get('CF-Connecting-IP') || '';

async function bitacora(env, uid, accion, entidad, id, antes, despues, req) {
  try {
    await env.DB.prepare('INSERT INTO bitacora (usuario_id,accion,entidad,entidad_id,antes,despues,ip) VALUES (?,?,?,?,?,?,?)')
      .bind(uid ?? null, accion, entidad, id == null ? null : String(id), antes ? JSON.stringify(antes) : null, despues ? JSON.stringify(despues) : null, req ? ip(req) : null).run();
  } catch (e) { /* la bitácora nunca debe tumbar la operación */ }
}

// ---------------------------------------------------------------- sesión
async function sesion(req, env) {
  const h = req.headers.get('Authorization') || '';
  const tok = h.startsWith('Bearer ') ? h.slice(7).trim() : '';
  if (!tok) fail('Debes iniciar sesión', 401);
  const th = await sha256(tok);
  const u = await env.DB.prepare(`SELECT u.id,u.nombre,u.email,u.telefono,u.rol_id,u.estado,r.nombre AS rol
      FROM sesiones s JOIN usuarios u ON u.id=s.usuario_id JOIN roles r ON r.id=u.rol_id
      WHERE s.token_hash=? AND s.expira_en > datetime('now')`).bind(th).first();
  if (!u || u.estado !== 'activo') fail('Tu sesión venció. Vuelve a entrar.', 401);
  const { results } = await env.DB.prepare('SELECT modulo,ver,crear,editar,borrar,alcance FROM permisos WHERE rol_id=?').bind(u.rol_id).all();
  u.permisos = Object.fromEntries(results.map(p => [p.modulo, p]));
  u.token_hash = th;
  return u;
}
function puede(u, mod, accion) { const p = u.permisos[mod]; return !!(p && p[accion]); }
function exigir(u, mod, accion) { if (!puede(u, mod, accion)) fail('No tienes permiso para esto', 403); }
function propios(u, mod) { return u.permisos[mod]?.alcance === 'propios'; }

async function crearSesion(env, req, uid) {
  const tok = randHex(32);
  await env.DB.prepare(`INSERT INTO sesiones (token_hash,usuario_id,expira_en,ip,agente) VALUES (?,?,datetime('now','+${SESION_DIAS} days'),?,?)`)
    .bind(await sha256(tok), uid, ip(req), (req.headers.get('User-Agent') || '').slice(0, 200)).run();
  await env.DB.prepare(`UPDATE usuarios SET ultimo_ingreso=datetime('now') WHERE id=?`).bind(uid).run();
  await env.DB.prepare(`DELETE FROM sesiones WHERE expira_en < datetime('now')`).run();
  return tok;
}

async function intentosFallidos(env, email) {
  const r = await env.DB.prepare(`SELECT COUNT(*) AS n FROM bitacora WHERE accion='ingreso_fallido' AND entidad='usuario' AND entidad_id=? AND creado_en > datetime('now','-15 minutes')`).bind(email.toLowerCase()).first();
  return r?.n || 0;
}

// ---------------------------------------------------------------- autenticación
async function login(req, env) {
  const { email = '', clave = '' } = await cuerpo(req);
  const em = String(email).trim().toLowerCase();
  if (!em || !clave) fail('Escribe tu correo y tu clave');
  if (await intentosFallidos(env, em) >= 5) fail('Demasiados intentos. Espera 15 minutos.', 429);
  const u = await env.DB.prepare('SELECT * FROM usuarios WHERE email=?').bind(em).first();
  if (u && u.estado === 'pendiente') fail('Tu cuenta aún no está activada. Usa "Activar mi cuenta".', 403);
  const ok = u && u.estado === 'activo' && u.clave_hash && igual(await pbkdf2(clave, u.clave_sal), u.clave_hash);
  if (!ok) { await bitacora(env, u?.id, 'ingreso_fallido', 'usuario', em, null, null, req); fail('Correo o clave incorrectos', 401); }
  const token = await crearSesion(env, req, u.id);
  await bitacora(env, u.id, 'ingresar', 'usuario', u.id, null, null, req);
  return json({ token });
}

// Activación: el usuario pendiente pone su clave con el código de activación.
// Si aún no existe código para ese correo, se genera y se guarda en la tabla configuracion
// (solo quien tiene acceso a Cloudflare o un administrador del panel puede verlo).
async function activar(req, env) {
  const { email = '', codigo = '', clave = '' } = await cuerpo(req);
  const em = String(email).trim().toLowerCase();
  if (!em) fail('Escribe tu correo');
  const u = await env.DB.prepare('SELECT * FROM usuarios WHERE email=?').bind(em).first();
  const k = 'activacion:' + em;
  if (!u || u.estado !== 'pendiente') {
    // Misma respuesta para no revelar qué correos existen
    return json({ ok: false, mensaje: 'Pide tu código de activación al administrador.' });
  }
  let fila = await env.DB.prepare('SELECT valor FROM configuracion WHERE clave=?').bind(k).first();
  if (!fila) {
    await env.DB.prepare('INSERT INTO configuracion (clave,valor,descripcion) VALUES (?,?,?)')
      .bind(k, codigoActivacion(), 'Código de un solo uso para que ' + em + ' active su cuenta').run();
    return json({ ok: false, mensaje: 'Pide tu código de activación al administrador.' });
  }
  if (!codigo) return json({ ok: false, mensaje: 'Pide tu código de activación al administrador.' });
  if (await intentosFallidos(env, em) >= 5) fail('Demasiados intentos. Espera 15 minutos.', 429);
  if (!igual(String(codigo).trim().toUpperCase(), fila.valor)) {
    await bitacora(env, u.id, 'ingreso_fallido', 'usuario', em, null, null, req);
    fail('El código no es correcto', 401);
  }
  if (!claveValida(clave)) fail('La clave debe tener al menos 8 caracteres, con letras y números');
  const sal = randHex(16);
  await env.DB.prepare(`UPDATE usuarios SET clave_hash=?, clave_sal=?, estado='activo', cambiar_clave=0, actualizado_en=datetime('now') WHERE id=?`)
    .bind(await pbkdf2(clave, sal), sal, u.id).run();
  await env.DB.prepare('DELETE FROM configuracion WHERE clave=?').bind(k).run();
  await bitacora(env, u.id, 'activar_cuenta', 'usuario', u.id, null, null, req);
  const token = await crearSesion(env, req, u.id);
  return json({ ok: true, token });
}

async function cambiarClave(req, env, u) {
  const { actual = '', nueva = '' } = await cuerpo(req);
  const f = await env.DB.prepare('SELECT clave_hash,clave_sal FROM usuarios WHERE id=?').bind(u.id).first();
  if (!igual(await pbkdf2(actual, f.clave_sal), f.clave_hash)) fail('La clave actual no es correcta', 401);
  if (!claveValida(nueva)) fail('La clave nueva debe tener al menos 8 caracteres, con letras y números');
  const sal = randHex(16);
  await env.DB.prepare(`UPDATE usuarios SET clave_hash=?, clave_sal=?, actualizado_en=datetime('now') WHERE id=?`).bind(await pbkdf2(nueva, sal), sal, u.id).run();
  await env.DB.prepare('DELETE FROM sesiones WHERE usuario_id=? AND token_hash<>?').bind(u.id, u.token_hash).run();
  await bitacora(env, u.id, 'cambiar_clave', 'usuario', u.id, null, null, req);
  return json({ ok: true });
}

// ---------------------------------------------------------------- archivos (fotos y documentos guardados en la base)
// Se guardan en base64 (texto) en partes de ~1.5 MB. El navegador manda el base64 ya hecho.
const API_URL = 'https://c4realty-api.c4realty0.workers.dev';
const PARTE = 1_500_000;
const MIME_FOTO = /^image\/(jpeg|png|webp)$/;
const MIME_DOC = /^(image\/(jpeg|png|webp|heic|heif)|application\/pdf)$/;
const urlArchivo = (clave, mime) => `${API_URL}/public/archivo/${clave}.${/png/.test(mime) ? 'png' : /webp/.test(mime) ? 'webp' : /pdf/.test(mime) ? 'pdf' : 'jpg'}`;
async function guardarArchivo(env, req, { privado = 0, cliente_id = null, usuario_id = null, maxMB = 6, mimeOk = MIME_FOTO }) {
  const mime = (req.headers.get('X-Mime') || '').toLowerCase();
  if (!mimeOk.test(mime)) fail('Tipo de archivo no permitido (usa foto JPG/PNG o PDF)');
  let nombre = ''; try { nombre = decodeURIComponent(req.headers.get('X-Nombre') || ''); } catch { }
  const b64 = (await req.text()).replace(/^data:[^,]*,/, '').replace(/\s/g, '');
  if (!b64 || /[^A-Za-z0-9+/=]/.test(b64)) fail('El archivo llegó dañado');
  const tam = Math.floor(b64.length * 3 / 4);
  if (tam > maxMB * 1048576) fail(`El archivo pesa más de ${maxMB} MB`);
  const clave = randHex(16), n = Math.ceil(b64.length / PARTE);
  const r = await env.DB.prepare('INSERT INTO archivos (clave,nombre,tipo_mime,tamano,partes,privado,cliente_id,subido_por) VALUES (?,?,?,?,?,?,?,?)')
    .bind(clave, nombre.slice(0, 160) || null, mime, tam, n, privado ? 1 : 0, cliente_id, usuario_id).run();
  const id = r.meta.last_row_id;
  const st = []; for (let i = 0; i < n; i++) st.push(env.DB.prepare('INSERT INTO archivo_partes (archivo_id,n,datos) VALUES (?,?,?)').bind(id, i, b64.slice(i * PARTE, (i + 1) * PARTE)));
  await env.DB.batch(st);
  return { id, clave, nombre, mime, tamano: tam, url: urlArchivo(clave, mime) };
}
function deB64(b64) {
  if (typeof Uint8Array.fromBase64 === 'function') return Uint8Array.fromBase64(b64);
  const bin = atob(b64), out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}
async function servirArchivo(env, clave, publico) {
  const a = await env.DB.prepare('SELECT * FROM archivos WHERE clave=?').bind(String(clave).replace(/\..*$/, '')).first();
  if (!a || (publico && a.privado)) fail('No existe', 404);
  const { results } = await env.DB.prepare('SELECT datos FROM archivo_partes WHERE archivo_id=? ORDER BY n').bind(a.id).all();
  const bytes = deB64(results.map(x => x.datos).join(''));
  const h = { ...CORS, 'Content-Type': a.tipo_mime, 'Content-Length': String(bytes.length) };
  h['Cache-Control'] = publico ? 'public, max-age=31536000, immutable' : 'private, no-store';
  if (!publico) h['Content-Disposition'] = `inline; filename="${encodeURIComponent(a.nombre || 'documento')}"`;
  return new Response(bytes, { headers: h });
}
async function borrarArchivoDeRuta(env, ruta) {
  const m = /\/public\/archivo\/([0-9a-f]{32})/.exec(ruta || '');
  if (m) await env.DB.prepare('DELETE FROM archivos WHERE clave=?').bind(m[1]).run();
}
async function subirFoto(env, u, req, url) {
  exigir(u, 'medios', 'crear');
  const pid = Number(url.searchParams.get('propiedad_id')) || null;
  const tipo = ['foto', 'volante'].includes(url.searchParams.get('tipo')) ? url.searchParams.get('tipo') : 'foto';
  if (pid && !(await env.DB.prepare('SELECT id FROM propiedades WHERE id=?').bind(pid).first())) fail('La propiedad no existe', 404);
  const a = await guardarArchivo(env, req, { usuario_id: u.id, maxMB: 6, mimeOk: MIME_FOTO });
  let medio = null;
  if (pid) {
    const mx = await env.DB.prepare(`SELECT COALESCE(MAX(orden),-1) AS o, COUNT(*) AS n FROM medios WHERE propiedad_id=? AND tipo IN ('foto','volante')`).bind(pid).first();
    const r = await env.DB.prepare('INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden) VALUES (?,?,?,?,?)').bind(pid, tipo, a.url, mx.n ? 0 : 1, mx.o + 1).run();
    medio = await env.DB.prepare('SELECT * FROM medios WHERE id=?').bind(r.meta.last_row_id).first();
    await bitacora(env, u.id, 'crear', 'medios', medio.id, null, { propiedad_id: pid, tipo, ruta: a.url }, req);
  }
  return json({ ...a, medio }, 201);
}
async function ordenMedios(env, u, req, pid) {
  exigir(u, 'medios', 'editar');
  const { ids = [] } = await cuerpo(req);
  if (!Array.isArray(ids) || !ids.length) fail('Falta el orden');
  await env.DB.batch(ids.map((id, i) => env.DB.prepare('UPDATE medios SET orden=?, es_principal=? WHERE id=? AND propiedad_id=?').bind(i, i === 0 ? 1 : 0, Number(id), pid)));
  await bitacora(env, u.id, 'editar', 'medios', pid, null, { orden: ids }, req);
  return json({ ok: true });
}

// ---------------------------------------------------------------- CRUD genérico
function limpiar(t, data, u) {
  const out = {};
  for (const c of t.cols) if (c in data) {
    let v = data[c];
    if (t.json?.includes(c) && typeof v !== 'string') v = JSON.stringify(v ?? []);
    if (v === '') v = null;
    if (typeof v === 'boolean') v = v ? 1 : 0;
    out[c] = v;
  }
  if (t.own && propios(u, t.mod)) delete out[t.own]; // un asesor no se reasigna registros
  return out;
}

async function fila(env, nombre, id) {
  const a = ALIAS[nombre];
  return await env.DB.prepare(`${LISTAS[nombre]} WHERE ${a}.id=?`).bind(id).first();
}

async function listar(env, nombre, u, url) {
  const t = TABLAS[nombre]; const a = ALIAS[nombre];
  exigir(u, t.mod, 'ver');
  const w = []; const b = [];
  if (t.own && propios(u, t.mod)) { w.push(`${a}.${t.own}=?`); b.push(u.id); }
  if (nombre === 'medios' && url.searchParams.get('propiedad_id')) { w.push('m.propiedad_id=?'); b.push(url.searchParams.get('propiedad_id')); }
  const sql = `${LISTAS[nombre]} ${w.length ? 'WHERE ' + w.join(' AND ') : ''} ORDER BY ${ORDEN[nombre]} LIMIT 2000`;
  const { results } = await env.DB.prepare(sql).bind(...b).all();
  return json(results);
}

async function obtener(env, nombre, u, id) {
  const t = TABLAS[nombre];
  exigir(u, t.mod, 'ver');
  const r = await fila(env, nombre, id);
  if (!r) fail('No existe', 404);
  if (t.own && propios(u, t.mod) && r[t.own] !== u.id) fail('No tienes permiso para esto', 403);
  if (nombre === 'propiedades') {
    r.medios = (await env.DB.prepare('SELECT * FROM medios WHERE propiedad_id=? ORDER BY tipo, orden').bind(id).all()).results;
    r.historial_estados = (await env.DB.prepare(`SELECT e.*, u.nombre AS usuario FROM propiedad_estados e LEFT JOIN usuarios u ON u.id=e.usuario_id WHERE propiedad_id=? ORDER BY e.id DESC LIMIT 50`).bind(id).all()).results;
    r.historial_precios = (await env.DB.prepare(`SELECT pp.*, u.nombre AS usuario FROM propiedad_precios pp LEFT JOIN usuarios u ON u.id=pp.usuario_id WHERE propiedad_id=? ORDER BY pp.id DESC LIMIT 50`).bind(id).all()).results;
    r.publicaciones = (await env.DB.prepare(`SELECT pi.codigo, pi.fecha, pi.tipo, pi.url, pi.texto FROM propiedad_publicaciones pp JOIN publicaciones_ig pi ON pi.codigo=pp.codigo WHERE pp.propiedad_id=? ORDER BY pp.orden`).bind(id).all()).results;
    r.negocios = (await env.DB.prepare(`${LISTAS.negocios} WHERE n.propiedad_id=? ORDER BY n.actualizado_en DESC`).bind(id).all()).results;
  }
  if (nombre === 'clientes') {
    r.interacciones = (await env.DB.prepare(`SELECT i.*, u.nombre AS usuario, p.titulo AS propiedad FROM interacciones i LEFT JOIN usuarios u ON u.id=i.usuario_id LEFT JOIN propiedades p ON p.id=i.propiedad_id WHERE i.cliente_id=? ORDER BY i.id DESC LIMIT 200`).bind(id).all()).results;
    r.negocios = (await env.DB.prepare(`${LISTAS.negocios} WHERE n.cliente_id=? ORDER BY n.actualizado_en DESC`).bind(id).all()).results;
    r.citas = (await env.DB.prepare(`${LISTAS.citas} WHERE ci.cliente_id=? ORDER BY ci.fecha_hora DESC`).bind(id).all()).results;
    r.documentos = (await env.DB.prepare('SELECT * FROM cliente_documentos WHERE cliente_id=? ORDER BY documento').bind(id).all()).results;
    r.archivos = (await env.DB.prepare('SELECT id,clave,nombre,tipo_mime,tamano,creado_en FROM archivos WHERE cliente_id=? ORDER BY id DESC').bind(id).all()).results;
  }
  return json(r);
}

async function crear(env, nombre, u, req) {
  const t = TABLAS[nombre];
  exigir(u, t.mod, 'crear');
  const d = limpiar(t, await cuerpo(req), u);
  if (t.own && propios(u, t.mod)) d[t.own] = u.id;
  if (nombre === 'propiedades') d.creado_por = u.id;
  const cols = Object.keys(d);
  if (!cols.length) fail('No enviaste datos');
  const r = await env.DB.prepare(`INSERT INTO ${nombre} (${cols.join(',')}) VALUES (${cols.map(() => '?').join(',')})`).bind(...cols.map(c => d[c])).run();
  const id = r.meta.last_row_id;
  await bitacora(env, u.id, 'crear', nombre, id, null, d, req);
  return json(await fila(env, nombre, id), 201);
}

async function editar(env, nombre, u, req, id) {
  const t = TABLAS[nombre];
  exigir(u, t.mod, 'editar');
  const antes = await env.DB.prepare(`SELECT * FROM ${nombre} WHERE id=?`).bind(id).first();
  if (!antes) fail('No existe', 404);
  if (t.own && propios(u, t.mod) && antes[t.own] !== u.id) fail('No tienes permiso para esto', 403);
  const body = await cuerpo(req);
  const d = limpiar(t, body, u);
  const cols = Object.keys(d).filter(c => JSON.stringify(d[c]) !== JSON.stringify(antes[c]));
  if (cols.length) {
    await env.DB.prepare(`UPDATE ${nombre} SET ${cols.map(c => c + '=?').join(',')} WHERE id=?`).bind(...cols.map(c => d[c]), id).run();
    // Quién hizo el cambio en los historiales automáticos
    if (nombre === 'propiedades') {
      if (cols.includes('estado')) await env.DB.prepare(`UPDATE propiedad_estados SET usuario_id=?, nota=? WHERE id=(SELECT MAX(id) FROM propiedad_estados WHERE propiedad_id=?)`).bind(u.id, body.nota || null, id).run();
      if (cols.includes('precio')) await env.DB.prepare(`UPDATE propiedad_precios SET usuario_id=?, motivo=? WHERE id=(SELECT MAX(id) FROM propiedad_precios WHERE propiedad_id=?)`).bind(u.id, body.motivo || null, id).run();
    }
    if (nombre === 'negocios' && cols.includes('etapa')) await env.DB.prepare(`UPDATE interacciones SET usuario_id=? WHERE id=(SELECT MAX(id) FROM interacciones WHERE negocio_id=? AND tipo='cambio_etapa')`).bind(u.id, id).run();
    await bitacora(env, u.id, 'editar', nombre, id, Object.fromEntries(cols.map(c => [c, antes[c]])), Object.fromEntries(cols.map(c => [c, d[c]])), req);
  }
  return json(await fila(env, nombre, id));
}

async function borrar(env, nombre, u, req, id) {
  const t = TABLAS[nombre];
  exigir(u, t.mod, 'borrar');
  const antes = await env.DB.prepare(`SELECT * FROM ${nombre} WHERE id=?`).bind(id).first();
  if (!antes) fail('No existe', 404);
  if (t.own && propios(u, t.mod) && antes[t.own] !== u.id) fail('No tienes permiso para esto', 403);
  await env.DB.prepare(`DELETE FROM ${nombre} WHERE id=?`).bind(id).run();
  if (nombre === 'medios') await borrarArchivoDeRuta(env, antes.ruta);
  await bitacora(env, u.id, 'borrar', nombre, id, antes, null, req);
  return json({ ok: true });
}

// ---------------------------------------------------------------- módulos especiales
async function resumen(env, u) {
  exigir(u, 'reportes', 'ver');
  const own = propios(u, 'reportes');
  const q = async (sql, ...b) => (await env.DB.prepare(sql).bind(...b).all()).results;
  const f = own ? ' AND asesor_id=' + Number(u.id) : '';
  return json({
    estatus: await q('SELECT * FROM v_resumen_estatus ORDER BY estado, categoria'),
    embudo: await q(`SELECT etapa, COUNT(*) AS negocios, SUM(COALESCE(monto,0)) AS monto FROM negocios WHERE 1=1${f} GROUP BY etapa`),
    clientes_estado: await q(`SELECT estado, COUNT(*) AS n FROM clientes WHERE 1=1${f} GROUP BY estado`),
    sin_atender: await q(`SELECT id,nombre,telefono,email,origen,creado_en,horas_sin_contacto FROM v_clientes_sin_atender WHERE 1=1${f} ORDER BY horas_sin_contacto DESC LIMIT 50`),
    nuevos: await q(`SELECT id,nombre,telefono,email,origen,estado,creado_en FROM clientes WHERE 1=1${f} ORDER BY creado_en DESC LIMIT 8`),
    incompletas: await q('SELECT * FROM v_propiedades_incompletas ORDER BY sin_precio DESC, fotos ASC'),
    citas_proximas: await q(`${LISTAS.citas} WHERE ci.estado='programada' AND ci.fecha_hora >= datetime('now','-1 day')${own ? ' AND ci.asesor_id=' + Number(u.id) : ''} ORDER BY ci.fecha_hora LIMIT 10`),
    vistas: await q(`SELECT p.id, p.titulo, SUM(v.vistas) AS vistas, SUM(v.clics_whatsapp) AS whatsapp FROM vistas_diarias v JOIN propiedades p ON p.id=v.propiedad_id WHERE v.fecha >= date('now','-30 days') GROUP BY p.id ORDER BY vistas DESC LIMIT 10`),
    hubspot: await q(`SELECT estado, COUNT(*) AS n FROM hubspot_sync GROUP BY estado`),
  });
}

async function nuevaInteraccion(env, u, req, clienteId) {
  exigir(u, 'clientes', 'editar');
  const c = await env.DB.prepare('SELECT * FROM clientes WHERE id=?').bind(clienteId).first();
  if (!c) fail('No existe', 404);
  if (propios(u, 'clientes') && c.asesor_id !== u.id) fail('No tienes permiso para esto', 403);
  const { tipo = 'nota', detalle = '', propiedad_id = null, negocio_id = null } = await cuerpo(req);
  if (!['whatsapp','llamada','correo','visita','nota'].includes(tipo)) fail('Tipo no válido');
  await env.DB.prepare('INSERT INTO interacciones (cliente_id,propiedad_id,negocio_id,tipo,detalle,usuario_id) VALUES (?,?,?,?,?,?)')
    .bind(clienteId, propiedad_id || null, negocio_id || null, tipo, String(detalle).slice(0, 4000), u.id).run();
  if (c.estado === 'nuevo' && tipo !== 'nota') await env.DB.prepare(`UPDATE clientes SET estado='contactado' WHERE id=?`).bind(clienteId).run();
  return json({ ok: true }, 201);
}

async function documentos(env, u, req, clienteId) {
  exigir(u, 'clientes', 'editar');
  const { documento = '', lo_tiene = 0 } = await cuerpo(req);
  if (!documento) fail('Falta el documento');
  await env.DB.prepare(`INSERT INTO cliente_documentos (cliente_id,documento,lo_tiene) VALUES (?,?,?)
      ON CONFLICT(cliente_id,documento) DO UPDATE SET lo_tiene=excluded.lo_tiene, actualizado=datetime('now')`).bind(clienteId, String(documento).slice(0, 200), lo_tiene ? 1 : 0).run();
  return json({ ok: true });
}

async function usuarios(env, u, req, url, partes) {
  const m = req.method; const id = partes[2] ? Number(partes[2]) : null;
  if (m === 'GET' && !id) {
    exigir(u, 'usuarios', 'ver');
    const { results } = await env.DB.prepare(`SELECT u.id,u.nombre,u.email,u.telefono,u.rol_id,r.nombre AS rol,u.estado,u.ultimo_ingreso,u.creado_en,
        (SELECT valor FROM configuracion WHERE clave='activacion:'||lower(u.email)) AS codigo_activacion
      FROM usuarios u JOIN roles r ON r.id=u.rol_id ORDER BY u.id`).all();
    if (!puede(u, 'usuarios', 'editar')) results.forEach(x => delete x.codigo_activacion);
    return json(results);
  }
  if (m === 'POST' && !id) {
    exigir(u, 'usuarios', 'crear');
    const { nombre = '', email = '', telefono = null, rol_id = 'asesor' } = await cuerpo(req);
    const em = String(email).trim().toLowerCase();
    if (!nombre || !em) fail('Nombre y correo son obligatorios');
    if (rol_id === 'administrador' && u.rol_id !== 'administrador') fail('Solo un administrador puede crear otro administrador', 403);
    const r = await env.DB.prepare(`INSERT INTO usuarios (nombre,email,telefono,rol_id,estado,cambiar_clave) VALUES (?,?,?,?, 'pendiente',1)`).bind(nombre, em, telefono || null, rol_id).run();
    const codigo = codigoActivacion();
    await env.DB.prepare('INSERT OR REPLACE INTO configuracion (clave,valor,descripcion) VALUES (?,?,?)').bind('activacion:' + em, codigo, 'Código de un solo uso para que ' + em + ' active su cuenta').run();
    await bitacora(env, u.id, 'crear', 'usuarios', r.meta.last_row_id, null, { nombre, email: em, rol_id }, req);
    return json({ id: r.meta.last_row_id, codigo_activacion: codigo }, 201);
  }
  if (m === 'PATCH' && id) {
    exigir(u, 'usuarios', 'editar');
    const b = await cuerpo(req); const antes = await env.DB.prepare('SELECT * FROM usuarios WHERE id=?').bind(id).first();
    if (!antes) fail('No existe', 404);
    if (id === u.id && (b.rol_id || b.estado)) fail('No puedes cambiar tu propio rol o estado');
    if ((b.rol_id === 'administrador' || antes.rol_id === 'administrador') && u.rol_id !== 'administrador') fail('Solo un administrador puede cambiar a un administrador', 403);
    const d = {}; for (const c of ['nombre','telefono','rol_id','estado']) if (c in b) d[c] = b[c] === '' ? null : b[c];
    if (d.estado === 'pendiente') delete d.estado;
    const cols = Object.keys(d);
    if (cols.length) await env.DB.prepare(`UPDATE usuarios SET ${cols.map(c => c + '=?').join(',')}, actualizado_en=datetime('now') WHERE id=?`).bind(...cols.map(c => d[c]), id).run();
    if (d.estado === 'inactivo') await env.DB.prepare('DELETE FROM sesiones WHERE usuario_id=?').bind(id).run();
    await bitacora(env, u.id, 'editar', 'usuarios', id, null, d, req);
    return json({ ok: true });
  }
  if (m === 'POST' && id && partes[3] === 'reiniciar') {
    exigir(u, 'usuarios', 'editar');
    const x = await env.DB.prepare('SELECT * FROM usuarios WHERE id=?').bind(id).first();
    if (!x) fail('No existe', 404);
    if (x.rol_id === 'administrador' && u.rol_id !== 'administrador') fail('Solo un administrador puede hacer esto', 403);
    const codigo = codigoActivacion();
    await env.DB.prepare(`UPDATE usuarios SET estado='pendiente', clave_hash=NULL, clave_sal=NULL, cambiar_clave=1 WHERE id=?`).bind(id).run();
    await env.DB.prepare('DELETE FROM sesiones WHERE usuario_id=?').bind(id).run();
    await env.DB.prepare('INSERT OR REPLACE INTO configuracion (clave,valor,descripcion) VALUES (?,?,?)').bind('activacion:' + x.email.toLowerCase(), codigo, 'Código de un solo uso para que ' + x.email + ' active su cuenta').run();
    await bitacora(env, u.id, 'reiniciar_clave', 'usuarios', id, null, null, req);
    return json({ codigo_activacion: codigo });
  }
  fail('Ruta no encontrada', 404);
}

async function roles(env, u, req) {
  if (req.method === 'GET') {
    exigir(u, 'usuarios', 'ver');
    const r = (await env.DB.prepare('SELECT * FROM roles').all()).results;
    const p = (await env.DB.prepare('SELECT * FROM permisos').all()).results;
    return json(r.map(x => ({ ...x, permisos: p.filter(y => y.rol_id === x.id) })));
  }
  if (req.method === 'PATCH') {
    if (u.rol_id !== 'administrador') fail('Solo el administrador cambia permisos', 403);
    const { rol_id, modulo, ver, crear, editar, borrar, alcance } = await cuerpo(req);
    if (rol_id === 'administrador') fail('Los permisos del administrador no se cambian');
    await env.DB.prepare(`UPDATE permisos SET ver=?,crear=?,editar=?,borrar=?,alcance=? WHERE rol_id=? AND modulo=?`)
      .bind(ver ? 1 : 0, crear ? 1 : 0, editar ? 1 : 0, borrar ? 1 : 0, alcance === 'propios' ? 'propios' : 'todos', rol_id, modulo).run();
    await bitacora(env, u.id, 'editar', 'permisos', rol_id + ':' + modulo, null, { ver, crear, editar, borrar, alcance }, req);
    return json({ ok: true });
  }
  fail('Ruta no encontrada', 404);
}

async function plantillas(env, u, req, partes) {
  if (req.method === 'GET') { exigir(u, 'plantillas', 'ver'); return json((await env.DB.prepare('SELECT * FROM plantillas ORDER BY rowid').all()).results); }
  if (req.method === 'POST' && partes[3] === 'activar') {
    exigir(u, 'plantillas', 'editar');
    const id = partes[2];
    const x = await env.DB.prepare('SELECT id FROM plantillas WHERE id=?').bind(id).first();
    if (!x) fail('No existe', 404);
    await env.DB.batch([
      env.DB.prepare(`UPDATE plantillas SET activa=0, actualizado_en=datetime('now') WHERE activa=1`),
      env.DB.prepare(`UPDATE plantillas SET activa=1, actualizado_en=datetime('now') WHERE id=?`).bind(id),
    ]);
    await bitacora(env, u.id, 'activar', 'plantillas', id, null, null, req);
    return json({ ok: true });
  }
  fail('Ruta no encontrada', 404);
}

async function configuracion(env, u, req) {
  if (req.method === 'GET') {
    exigir(u, 'configuracion', 'ver');
    return json((await env.DB.prepare(`SELECT * FROM configuracion WHERE clave NOT LIKE 'activacion:%' ORDER BY clave`).all()).results);
  }
  if (req.method === 'PATCH') {
    exigir(u, 'configuracion', 'editar');
    const b = await cuerpo(req);
    for (const [k, v] of Object.entries(b)) {
      if (k.startsWith('activacion:')) continue;
      await env.DB.prepare(`UPDATE configuracion SET valor=?, actualizado_en=datetime('now') WHERE clave=?`).bind(v == null ? null : String(v), k).run();
    }
    await bitacora(env, u.id, 'editar', 'configuracion', null, null, b, req);
    return json({ ok: true });
  }
  fail('Ruta no encontrada', 404);
}

async function verBitacora(env, u) {
  exigir(u, 'bitacora', 'ver');
  return json((await env.DB.prepare(`SELECT b.*, u.nombre AS usuario FROM bitacora b LEFT JOIN usuarios u ON u.id=b.usuario_id ORDER BY b.id DESC LIMIT 300`).all()).results);
}

// ---------------------------------------------------------------- público (página web)
async function publico(req, env, partes, ctx) {
  const r = partes[1];
  if (req.method === 'GET' && r === 'catalogo') {
    const { results } = await env.DB.prepare('SELECT * FROM v_catalogo_publico ORDER BY destacada DESC, orden').all();
    return json(results);
  }
  if (req.method === 'GET' && r === 'archivo' && partes[2]) return servirArchivo(env, partes[2], true);
  if (req.method === 'POST' && r === 'documento') {
    const tok = String(req.headers.get('X-Subida') || '');
    const sb = tok && await env.DB.prepare(`SELECT * FROM subidas WHERE token=? AND expira > datetime('now')`).bind(await sha256(tok)).first();
    if (!sb) fail('El enlace para subir documentos venció. Vuelve a tocar Enviar.', 403);
    if (sb.usados >= 12) fail('Ya subiste el máximo de 12 documentos', 403);
    const a = await guardarArchivo(env, req, { privado: 1, cliente_id: sb.cliente_id, maxMB: 8, mimeOk: MIME_DOC });
    await env.DB.prepare('UPDATE subidas SET usados=usados+1 WHERE token=?').bind(sb.token).run();
    return json({ ok: true, nombre: a.nombre, tamano: a.tamano }, 201);
  }
  if (req.method === 'GET' && r === 'sitio') {
    const pl = await env.DB.prepare('SELECT id,nombre,tokens FROM plantillas WHERE activa=1').first();
    const cf = (await env.DB.prepare(`SELECT clave,valor FROM configuracion WHERE clave IN ('nombre_sitio','whatsapp','whatsapp_visible','correo','instagram','hero_titulo','bono_monto','bono_tope_precio')`).all()).results;
    return json({ plantilla: pl ? { ...pl, tokens: JSON.parse(pl.tokens) } : null, config: Object.fromEntries(cf.map(x => [x.clave, x.valor])) });
  }
  if (req.method === 'POST' && r === 'contacto') {
    const b = await cuerpo(req);
    if (b.sitio_web) return json({ ok: true }); // trampa para robots
    const nombre = String(b.nombre || '').trim().slice(0, 120);
    const tel = String(b.telefono || '').replace(/[^\d+]/g, '').slice(0, 20) || null;
    const email = String(b.email || '').trim().toLowerCase().slice(0, 160) || null;
    if (!nombre || (!tel && !email)) fail('Escribe tu nombre y un teléfono o correo');
    const origen = ['web_cotizar', 'web_contacto', 'web'].includes(b.origen) ? b.origen : 'web';
    const tipo = ['asalariado', 'independiente', 'jubilado', 'otro'].includes(b.tipo_ingreso) ? b.tipo_ingreso : null;
    const ing = Number(String(b.ingreso_mensual ?? '').replace(/[^\d.]/g, '')) || null;
    let c = await env.DB.prepare('SELECT id,telefono,email FROM clientes WHERE (telefono IS NOT NULL AND telefono=?) OR (email IS NOT NULL AND email=?) LIMIT 1').bind(tel, email).first();
    if (!c) {
      const ins = await env.DB.prepare('INSERT INTO clientes (nombre,telefono,email,tipo_ingreso,ingreso_mensual,origen) VALUES (?,?,?,?,?,?)').bind(nombre, tel, email, tipo, ing, origen).run();
      c = { id: ins.meta.last_row_id };
    } else {
      // cliente que ya existía: se completan el correo o el teléfono que le faltaban (eso también pasa a HubSpot)
      if ((!c.email && email) || (!c.telefono && tel)) await env.DB.prepare('UPDATE clientes SET email=COALESCE(email,?), telefono=COALESCE(telefono,?) WHERE id=?').bind(email, tel, c.id).run();
      // el salario y el tipo de ingreso se actualizan con lo último que escribió
      if (ing || tipo) await env.DB.prepare('UPDATE clientes SET ingreso_mensual=COALESCE(?,ingreso_mensual), tipo_ingreso=COALESCE(?,tipo_ingreso) WHERE id=?').bind(ing, tipo, c.id).run();
    }
    let pid = null;
    if (b.propiedad) { const p = await env.DB.prepare('SELECT id FROM propiedades WHERE codigo=?').bind(String(b.propiedad)).first(); pid = p?.id || null; }
    const datos = { ...b }; delete datos.sitio_web;
    const it = await env.DB.prepare(`INSERT INTO interacciones (cliente_id,propiedad_id,tipo,detalle,datos) VALUES (?,?,'formulario',?,?)`)
      .bind(c.id, pid, String(b.mensaje || (origen === 'web_cotizar' ? 'Solicitud de cotización' : 'Mensaje desde la página')).slice(0, 2000), JSON.stringify(datos).slice(0, 8000)).run();
    // cada formulario llega a HubSpot como una nota en la ficha del contacto (aunque el contacto ya exista)
    await env.DB.prepare(`INSERT INTO hubspot_sync (entidad,entidad_id,accion) VALUES ('interaccion',?,'crear')`).bind(it.meta.last_row_id).run();
    if (Array.isArray(b.documentos)) for (const d of b.documentos.slice(0, 20)) {
      await env.DB.prepare(`INSERT INTO cliente_documentos (cliente_id,documento,lo_tiene) VALUES (?,?,1) ON CONFLICT(cliente_id,documento) DO UPDATE SET lo_tiene=1, actualizado=datetime('now')`).bind(c.id, String(d).slice(0, 200)).run();
    }
    // Si el cliente va a subir documentos, se le da un permiso de 2 horas ligado a su ficha
    let subida = null;
    if (b.subir_documentos) {
      subida = randHex(24);
      await env.DB.prepare(`INSERT INTO subidas (token,cliente_id,expira) VALUES (?,?,datetime('now','+2 hours'))`).bind(await sha256(subida), c.id).run();
    }
    // HubSpot al instante: se envía apenas llega el formulario (el envío cada minuto queda de respaldo)
    if (env.HUBSPOT_TOKEN && ctx) ctx.waitUntil(sincronizarHubSpot(env).catch(() => { }));
    return json(subida ? { ok: true, subida } : { ok: true }, 201);
  }
  if (req.method === 'POST' && r === 'vista') {
    const b = await cuerpo(req);
    const p = await env.DB.prepare('SELECT id FROM propiedades WHERE codigo=?').bind(String(b.propiedad || '')).first();
    if (!p) return json({ ok: false });
    const col = b.tipo === 'whatsapp' ? 'clics_whatsapp' : 'vistas';
    await env.DB.prepare(`INSERT INTO vistas_diarias (propiedad_id,fecha,${col}) VALUES (?,date('now'),1) ON CONFLICT(propiedad_id,fecha) DO UPDATE SET ${col}=${col}+1`).bind(p.id).run();
    return json({ ok: true });
  }
  fail('Ruta no encontrada', 404);
}

// ---------------------------------------------------------------- HubSpot (cada 10 minutos)
async function hs(env, metodo, ruta, body) {
  const r = await fetch('https://api.hubapi.com' + ruta, {
    method: metodo,
    headers: { Authorization: 'Bearer ' + env.HUBSPOT_TOKEN, 'Content-Type': 'application/json' },
    body: body ? JSON.stringify(body) : undefined,
  });
  const t = await r.text(); let j = null; try { j = JSON.parse(t); } catch { }
  return { ok: r.ok, status: r.status, data: j, text: t };
}

async function syncCliente(env, id) {
  const c = await env.DB.prepare('SELECT * FROM clientes WHERE id=?').bind(id).first();
  if (!c) return 'enviado';
  const [nombre, ...resto] = c.nombre.split(' ');
  const props = { firstname: nombre, lastname: resto.join(' ') || undefined, phone: c.telefono || undefined, email: c.email || undefined };
  let r;
  if (c.hubspot_id) r = await hs(env, 'PATCH', '/crm/v3/objects/contacts/' + c.hubspot_id, { properties: props });
  else {
    r = await hs(env, 'POST', '/crm/v3/objects/contacts', { properties: props });
    if (r.status === 409 && c.email) {
      const s = await hs(env, 'POST', '/crm/v3/objects/contacts/search', { filterGroups: [{ filters: [{ propertyName: 'email', operator: 'EQ', value: c.email }] }], limit: 1 });
      if (s.ok && s.data?.results?.[0]) r = { ok: true, data: s.data.results[0] };
    }
    if (r.ok && r.data?.id) await env.DB.prepare('UPDATE clientes SET hubspot_id=? WHERE id=?').bind(String(r.data.id), id).run();
  }
  if (!r.ok) throw new Error('HubSpot ' + r.status + ': ' + (r.text || '').slice(0, 300));
  return 'enviado';
}

async function syncNegocio(env, id) {
  const n = await env.DB.prepare(`SELECT n.*, c.nombre AS cliente, c.hubspot_id AS contacto, p.titulo AS propiedad FROM negocios n JOIN clientes c ON c.id=n.cliente_id LEFT JOIN propiedades p ON p.id=n.propiedad_id WHERE n.id=?`).bind(id).first();
  if (!n) return 'enviado';
  if (!n.contacto) return 'pendiente'; // primero tiene que subir el cliente
  let mapa = ETAPAS_HS;
  const cfg = await env.DB.prepare(`SELECT valor FROM configuracion WHERE clave='hubspot_etapas'`).first();
  if (cfg?.valor) { try { mapa = { ...ETAPAS_HS, ...JSON.parse(cfg.valor) }; } catch { } }
  const props = { dealname: n.cliente + (n.propiedad ? ' · ' + n.propiedad : ''), dealstage: mapa[n.etapa], amount: n.monto ?? undefined, pipeline: 'default' };
  let r;
  if (n.hubspot_deal_id) r = await hs(env, 'PATCH', '/crm/v3/objects/deals/' + n.hubspot_deal_id, { properties: props });
  else {
    r = await hs(env, 'POST', '/crm/v3/objects/deals', { properties: props, associations: [{ to: { id: n.contacto }, types: [{ associationCategory: 'HUBSPOT_DEFINED', associationTypeId: 3 }] }] });
    if (r.ok && r.data?.id) await env.DB.prepare('UPDATE negocios SET hubspot_deal_id=? WHERE id=?').bind(String(r.data.id), id).run();
  }
  if (!r.ok) throw new Error('HubSpot ' + r.status + ': ' + (r.text || '').slice(0, 300));
  return 'enviado';
}

const esc = v => String(v ?? '').replace(/[&<>"]/g, ch => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[ch]));
async function syncInteraccion(env, id) {
  const it = await env.DB.prepare(`SELECT i.*, c.hubspot_id AS contacto, c.email AS email_ficha, c.telefono AS tel_ficha, p.titulo AS propiedad FROM interacciones i JOIN clientes c ON c.id=i.cliente_id LEFT JOIN propiedades p ON p.id=i.propiedad_id WHERE i.id=?`).bind(id).first();
  if (!it) return 'enviado';
  if (!it.contacto) return 'pendiente'; // primero tiene que subir el cliente
  let d = {}; try { d = JSON.parse(it.datos || '{}'); } catch { }
  const fuente = { web_cotizar: 'Formulario Cotizar', web_contacto: 'Formulario de Contacto' }[d.origen] || 'Formulario de la página';
  const L = [];
  if (d.nombre) L.push(['Nombre', d.nombre]);
  if (d.telefono) L.push(['Teléfono', d.telefono]);
  if (d.email) L.push(['Correo', d.email]);
  if (d.interes || it.propiedad) L.push(['Le interesa', d.interes || it.propiedad]);
  if (d.tipo_ingreso) L.push(['Tipo de ingreso', d.tipo_ingreso]);
  if (d.ingreso_mensual) L.push(['Ingreso mensual', '$' + d.ingreso_mensual]);
  if (Array.isArray(d.documentos) && d.documentos.length) L.push(['Documentos que dice tener', d.documentos.join('; ')]);
  if (d.mensaje && !/^Solicitud de cotización$/.test(d.mensaje)) L.push(['Mensaje', d.mensaje]);
  const html = `<p><b>${esc(fuente)}</b> (página web)</p>` + L.map(([k, v]) => `<p><b>${esc(k)}:</b> ${esc(v)}</p>`).join('');
  const ts = new Date(String(it.creado_en).replace(' ', 'T') + 'Z');
  const r = await hs(env, 'POST', '/crm/v3/objects/notes', {
    properties: { hs_timestamp: isNaN(ts) ? new Date().toISOString() : ts.toISOString(), hs_note_body: html },
    associations: [{ to: { id: it.contacto }, types: [{ associationCategory: 'HUBSPOT_DEFINED', associationTypeId: 202 }] }],
  });
  if (!r.ok) throw new Error('HubSpot ' + r.status + ': ' + (r.text || '').slice(0, 300));
  return 'enviado';
}

async function sincronizarHubSpot(env) {
  if (!env.HUBSPOT_TOKEN) return { omitido: 'Sin HUBSPOT_TOKEN' };
  // candado: si el envío instantáneo y el de cada minuto coinciden, solo uno trabaja (así nadie se crea dos veces en HubSpot)
  await env.DB.prepare(`INSERT OR IGNORE INTO configuracion (clave,valor,descripcion) VALUES ('hubspot_candado','2000-01-01 00:00:00','Uso interno')`).run();
  const lk = await env.DB.prepare(`UPDATE configuracion SET valor=datetime('now') WHERE clave='hubspot_candado' AND valor < datetime('now','-50 seconds')`).run();
  if (!lk.meta.changes) return { ocupado: true };
  try { return await enviarPendientesHubSpot(env); }
  finally { await env.DB.prepare(`UPDATE configuracion SET valor='2000-01-01 00:00:00' WHERE clave='hubspot_candado'`).run(); }
}

async function enviarPendientesHubSpot(env) {
  const { results } = await env.DB.prepare(`SELECT * FROM hubspot_sync WHERE estado IN ('pendiente','error') AND intentos < 5 ORDER BY id LIMIT 25`).all();
  const hecho = new Set(); let enviados = 0;
  for (const s of results) {
    const k = s.entidad + ':' + s.entidad_id;
    try {
      let est = 'enviado';
      if (!hecho.has(k)) {
        if (s.entidad === 'cliente') est = await syncCliente(env, s.entidad_id);
        else if (s.entidad === 'negocio') est = await syncNegocio(env, s.entidad_id);
        else if (s.entidad === 'interaccion') est = await syncInteraccion(env, s.entidad_id);
      }
      if (est === 'enviado') { hecho.add(k); enviados++; await env.DB.prepare(`UPDATE hubspot_sync SET estado='enviado', enviado_en=datetime('now') WHERE id=?`).bind(s.id).run(); }
    } catch (e) {
      await env.DB.prepare(`UPDATE hubspot_sync SET estado='error', intentos=intentos+1, ultimo_error=? WHERE id=?`).bind(String(e.message).slice(0, 500), s.id).run();
    }
  }
  return { revisados: results.length, enviados };
}

// ---------------------------------------------------------------- enrutador
async function rutas(req, env, ctx) {
  const url = new URL(req.url);
  const partes = url.pathname.replace(/^\/+|\/+$/g, '').split('/');
  const m = req.method;

  if (!partes[0]) return json({ servicio: 'C4 Realty API', ok: true });
  if (partes[0] === 'public') return publico(req, env, partes, ctx);
  if (partes[0] === 'auth' && m === 'POST' && partes[1] === 'login') return login(req, env);
  if (partes[0] === 'auth' && m === 'POST' && partes[1] === 'activar') return activar(req, env);

  if (partes[0] !== 'api' && partes[0] !== 'auth') fail('Ruta no encontrada', 404);
  const u = await sesion(req, env);

  if (partes[0] === 'auth') {
    if (partes[1] === 'salir') { await env.DB.prepare('DELETE FROM sesiones WHERE token_hash=?').bind(u.token_hash).run(); return json({ ok: true }); }
    if (partes[1] === 'clave') return cambiarClave(req, env, u);
    fail('Ruta no encontrada', 404);
  }

  const r = partes[1]; const id = partes[2] ? Number(partes[2]) : null;
  if (r === 'yo') { const { token_hash, ...yo } = u; return json(yo); }
  if (r === 'resumen') return resumen(env, u);
  if (r === 'usuarios') return usuarios(env, u, req, url, partes);
  if (r === 'roles') return roles(env, u, req);
  if (r === 'plantillas') return plantillas(env, u, req, partes);
  if (r === 'configuracion') return configuracion(env, u, req);
  if (r === 'bitacora') return verBitacora(env, u);
  if (r === 'hubspot' && partes[2] === 'sincronizar' && m === 'POST') { exigir(u, 'configuracion', 'editar'); return json(await sincronizarHubSpot(env)); }
  if (r === 'clientes' && id && partes[3] === 'interacciones' && m === 'POST') return nuevaInteraccion(env, u, req, id);
  if (r === 'clientes' && id && partes[3] === 'documentos' && m === 'POST') return documentos(env, u, req, id);
  if (r === 'archivos' && m === 'POST' && !partes[2]) return subirFoto(env, u, req, url);
  if (r === 'archivos' && m === 'GET' && partes[2]) { exigir(u, 'clientes', 'ver'); return servirArchivo(env, partes[2], false); }
  if (r === 'archivos' && m === 'DELETE' && partes[2]) {
    exigir(u, 'clientes', 'editar');
    const a = await env.DB.prepare('SELECT id,cliente_id,nombre FROM archivos WHERE clave=? AND privado=1').bind(String(partes[2])).first();
    if (!a) fail('No existe', 404);
    await env.DB.prepare('DELETE FROM archivos WHERE id=?').bind(a.id).run();
    await bitacora(env, u.id, 'borrar', 'archivos', a.id, { cliente_id: a.cliente_id, nombre: a.nombre }, null, req);
    return json({ ok: true });
  }
  if (r === 'propiedades' && id && partes[3] === 'orden-medios' && m === 'POST') return ordenMedios(env, u, req, id);
  if (TABLAS[r]) {
    if (m === 'GET' && !id) return listar(env, r, u, url);
    if (m === 'GET' && id) return obtener(env, r, u, id);
    if (m === 'POST' && !id) return crear(env, r, u, req);
    if (m === 'PATCH' && id) return editar(env, r, u, req, id);
    if (m === 'DELETE' && id) return borrar(env, r, u, req, id);
  }
  fail('Ruta no encontrada', 404);
}

export default {
  async fetch(req, env, ctx) {
    if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: CORS });
    try { return await rutas(req, env, ctx); }
    catch (e) {
      if (e instanceof HttpError) return err(e.message, e.status);
      const msg = String(e?.message || e);
      if (/constraint|CHECK|UNIQUE|NOT NULL|FOREIGN/i.test(msg)) return err('Datos no válidos: ' + msg.replace(/^.*?:\s*/, ''), 400);
      return err('Error interno: ' + msg, 500);
    }
  },
  async scheduled(event, env, ctx) { ctx.waitUntil(sincronizarHubSpot(env)); },
};
