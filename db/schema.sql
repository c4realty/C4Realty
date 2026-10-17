-- =====================================================================
-- C4 Realty · Base de datos (Cloudflare D1 / SQLite)
-- Propiedades, medios, clientes (CRM), negocios, citas, usuarios con
-- permisos por rol, 3 plantillas de diseño, bitácora y sincronización
-- con HubSpot.
--
-- Cargar en Cloudflare:
--   npx wrangler d1 execute c4realty --remote --file=db/schema.sql
--   npx wrangler d1 execute c4realty --remote --file=db/seed.sql
-- =====================================================================
-- D1 aplica las llaves foráneas automáticamente (en SQLite local: PRAGMA foreign_keys = ON;)

-- ---------------------------------------------------------------------
-- 1. USUARIOS, ROLES Y PERMISOS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles (
  id          TEXT PRIMARY KEY,              -- administrador, coadministrador, asesor, asistente, lectura
  nombre      TEXT NOT NULL,
  descripcion TEXT NOT NULL
);

-- Qué puede hacer cada rol en cada módulo.
-- alcance = 'todos'  → todos los registros
-- alcance = 'propios'→ solo los registros asignados al usuario (asesor_id = usuario)
CREATE TABLE IF NOT EXISTS permisos (
  rol_id   TEXT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  modulo   TEXT NOT NULL CHECK (modulo IN ('propiedades','medios','clientes','negocios','citas',
                                            'usuarios','configuracion','plantillas','reportes','bitacora')),
  ver      INTEGER NOT NULL DEFAULT 0 CHECK (ver IN (0,1)),
  crear    INTEGER NOT NULL DEFAULT 0 CHECK (crear IN (0,1)),
  editar   INTEGER NOT NULL DEFAULT 0 CHECK (editar IN (0,1)),
  borrar   INTEGER NOT NULL DEFAULT 0 CHECK (borrar IN (0,1)),
  alcance  TEXT NOT NULL DEFAULT 'todos' CHECK (alcance IN ('todos','propios')),
  PRIMARY KEY (rol_id, modulo)
);

CREATE TABLE IF NOT EXISTS usuarios (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre          TEXT NOT NULL,
  email           TEXT NOT NULL UNIQUE COLLATE NOCASE,
  telefono        TEXT,
  rol_id          TEXT NOT NULL REFERENCES roles(id),
  estado          TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo','inactivo','pendiente')),
  clave_hash      TEXT,                        -- PBKDF2/SHA-256, nunca la clave en texto
  clave_sal       TEXT,
  cambiar_clave   INTEGER NOT NULL DEFAULT 1 CHECK (cambiar_clave IN (0,1)),
  ultimo_ingreso  TEXT,
  creado_en       TEXT NOT NULL DEFAULT (datetime('now')),
  actualizado_en  TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS sesiones (
  token_hash  TEXT PRIMARY KEY,
  usuario_id  INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  creada_en   TEXT NOT NULL DEFAULT (datetime('now')),
  expira_en   TEXT NOT NULL,
  ip          TEXT,
  agente      TEXT
);
CREATE INDEX IF NOT EXISTS ix_sesiones_usuario ON sesiones(usuario_id);

-- ---------------------------------------------------------------------
-- 2. CATÁLOGO: PROYECTOS, PROPIEDADES, MEDIOS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS proyectos (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre       TEXT NOT NULL,                  -- ej. Residencial Las Hortencias
  zona         TEXT,                           -- ej. Boquete
  zona_detalle TEXT,                           -- ej. El Francés, Boquete
  provincia    TEXT NOT NULL DEFAULT 'Chiriquí',
  promotora    TEXT,
  descripcion  TEXT,
  lat          REAL,
  lng          REAL,
  activo       INTEGER NOT NULL DEFAULT 1 CHECK (activo IN (0,1)),
  creado_en    TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS propiedades (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo           TEXT NOT NULL UNIQUE,       -- ej. coral, trancas904 (se usa en la URL)
  proyecto_id      INTEGER REFERENCES proyectos(id) ON DELETE SET NULL,
  categoria        TEXT NOT NULL CHECK (categoria IN ('casa','terreno','finca','alquiler','local','apartamento')),
  titulo           TEXT NOT NULL,
  zona             TEXT,
  zona_detalle     TEXT,
  provincia        TEXT NOT NULL DEFAULT 'Chiriquí',
  -- precio
  precio           REAL,                        -- precio de venta (NULL = consultar)
  precio_antes     REAL,                        -- precio tachado en rebajas
  precio_desde     INTEGER NOT NULL DEFAULT 0 CHECK (precio_desde IN (0,1)),
  precio_texto     TEXT,                        -- ej. "$25 por m²"
  renta_mensual    REAL,                        -- solo alquileres
  -- características
  recamaras        TEXT,
  banos            TEXT,
  estacionamiento  TEXT,
  lote_m2          REAL,
  construccion_m2  REAL,
  caracteristicas  TEXT NOT NULL DEFAULT '[]',  -- JSON [["Lavandería","Cerrada"], ...]
  incluye          TEXT NOT NULL DEFAULT '[]',  -- JSON ["Grama frontal", ...]
  pagos            TEXT NOT NULL DEFAULT '[]',  -- JSON ["Aplica con salarios desde $900", ...]
  descripcion      TEXT,
  -- estatus
  estado           TEXT NOT NULL DEFAULT 'borrador'
                   CHECK (estado IN ('borrador','disponible','reservada','en_negociacion','vendida','alquilada','retirada')),
  etiqueta         TEXT,                        -- ej. "Entrega inmediata", "Rebaja"
  publicada        INTEGER NOT NULL DEFAULT 0 CHECK (publicada IN (0,1)),
  destacada        INTEGER NOT NULL DEFAULT 0 CHECK (destacada IN (0,1)),
  orden            INTEGER NOT NULL DEFAULT 0,
  aplica_bono      INTEGER GENERATED ALWAYS AS (CASE WHEN categoria IN ('casa','apartamento') AND precio IS NOT NULL AND precio <= 80000 THEN 1 ELSE 0 END) VIRTUAL,
  asesor_id        INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  fecha_publicacion TEXT,                       -- fecha del post de origen
  vendida_en       TEXT,
  creado_por       INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  creado_en        TEXT NOT NULL DEFAULT (datetime('now')),
  actualizado_en   TEXT NOT NULL DEFAULT (datetime('now')),
  CHECK (categoria <> 'alquiler' OR renta_mensual IS NOT NULL OR estado = 'borrador')
);
CREATE INDEX IF NOT EXISTS ix_prop_estado    ON propiedades(estado, publicada);
CREATE INDEX IF NOT EXISTS ix_prop_categoria ON propiedades(categoria, zona);
CREATE INDEX IF NOT EXISTS ix_prop_asesor    ON propiedades(asesor_id);

-- Historial de estatus de cada propiedad (quién la pasó a reservada, vendida…)
CREATE TABLE IF NOT EXISTS propiedad_estados (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  propiedad_id  INTEGER NOT NULL REFERENCES propiedades(id) ON DELETE CASCADE,
  estado_antes  TEXT,
  estado_nuevo  TEXT NOT NULL,
  usuario_id    INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  nota          TEXT,
  creado_en     TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS ix_prop_estados ON propiedad_estados(propiedad_id, creado_en);

-- Historial de precios
CREATE TABLE IF NOT EXISTS propiedad_precios (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  propiedad_id  INTEGER NOT NULL REFERENCES propiedades(id) ON DELETE CASCADE,
  precio_antes  REAL,
  precio_nuevo  REAL,
  motivo        TEXT,
  usuario_id    INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  creado_en     TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Fotos, videos y volantes (los archivos viven en Cloudflare R2 o en /img y /videos)
CREATE TABLE IF NOT EXISTS medios (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  propiedad_id  INTEGER NOT NULL REFERENCES propiedades(id) ON DELETE CASCADE,
  tipo          TEXT NOT NULL CHECK (tipo IN ('foto','video','volante','plano','brochure')),
  ruta          TEXT NOT NULL,                  -- ej. img/Dd-U0i-RUv4_1.jpg o clave en R2
  portada       TEXT,                           -- póster de un video
  es_principal  INTEGER NOT NULL DEFAULT 0 CHECK (es_principal IN (0,1)),
  orden         INTEGER NOT NULL DEFAULT 0,
  ig_codigo     TEXT REFERENCES publicaciones_ig(codigo) ON DELETE SET NULL,
  creado_en     TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS ix_medios_prop ON medios(propiedad_id, orden);

-- Publicaciones de Instagram de @c4realty1 (fuente de textos y medios)
CREATE TABLE IF NOT EXISTS publicaciones_ig (
  codigo        TEXT PRIMARY KEY,               -- ej. DdaTUj7xgP1
  fecha         TEXT,                           -- NULL si no se conoce la fecha exacta
  texto         TEXT,
  tipo          TEXT CHECK (tipo IN ('foto','video','carrusel')),
  url           TEXT GENERATED ALWAYS AS ('https://www.instagram.com/p/' || codigo || '/') VIRTUAL
);

CREATE TABLE IF NOT EXISTS propiedad_publicaciones (
  propiedad_id  INTEGER NOT NULL REFERENCES propiedades(id) ON DELETE CASCADE,
  codigo        TEXT NOT NULL REFERENCES publicaciones_ig(codigo) ON DELETE CASCADE,
  orden         INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (propiedad_id, codigo)
);

-- ---------------------------------------------------------------------
-- 3. CRM: CLIENTES QUE ESCRIBEN, NEGOCIOS, CITAS, ACTIVIDAD
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS clientes (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre           TEXT NOT NULL,
  telefono         TEXT,
  email            TEXT COLLATE NOCASE,
  tipo_ingreso     TEXT CHECK (tipo_ingreso IN ('asalariado','independiente','jubilado','otro')),
  ingreso_mensual  REAL,
  origen           TEXT NOT NULL DEFAULT 'web'
                   CHECK (origen IN ('web_cotizar','web_contacto','web','whatsapp','instagram','referido','visita','otro')),
  estado           TEXT NOT NULL DEFAULT 'nuevo'
                   CHECK (estado IN ('nuevo','contactado','en_proceso','cliente','perdido','descartado')),
  asesor_id        INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  primera_vivienda INTEGER CHECK (primera_vivienda IN (0,1)),
  banco_preferido  TEXT,
  notas            TEXT,
  hubspot_id       TEXT UNIQUE,
  ultimo_contacto  TEXT,
  creado_en        TEXT NOT NULL DEFAULT (datetime('now')),
  actualizado_en   TEXT NOT NULL DEFAULT (datetime('now')),
  CHECK (telefono IS NOT NULL OR email IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS ix_clientes_estado ON clientes(estado, asesor_id);
CREATE INDEX IF NOT EXISTS ix_clientes_tel    ON clientes(telefono);
CREATE INDEX IF NOT EXISTS ix_clientes_email  ON clientes(email);

-- Documentos que el cliente ya tiene (la lista del cotizador)
CREATE TABLE IF NOT EXISTS cliente_documentos (
  cliente_id   INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
  documento    TEXT NOT NULL,                   -- ej. 'Carta de trabajo'
  lo_tiene     INTEGER NOT NULL DEFAULT 0 CHECK (lo_tiene IN (0,1)),
  actualizado  TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (cliente_id, documento)
);

-- Un negocio = un cliente interesado en una propiedad, avanzando por los 7 pasos
CREATE TABLE IF NOT EXISTS negocios (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  cliente_id     INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
  propiedad_id   INTEGER REFERENCES propiedades(id) ON DELETE SET NULL,
  etapa          TEXT NOT NULL DEFAULT 'cotizacion'
                 CHECK (etapa IN ('cotizacion','recorrido','apartado','documentacion','aprobacion','contrato','abonos','entregado','perdido')),
  monto          REAL,
  banco          TEXT,
  usa_bono       INTEGER NOT NULL DEFAULT 0 CHECK (usa_bono IN (0,1)),
  asesor_id      INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  motivo_perdida TEXT,
  hubspot_deal_id TEXT UNIQUE,
  creado_en      TEXT NOT NULL DEFAULT (datetime('now')),
  actualizado_en TEXT NOT NULL DEFAULT (datetime('now')),
  cerrado_en     TEXT
);
CREATE INDEX IF NOT EXISTS ix_negocios_etapa ON negocios(etapa, asesor_id);
CREATE INDEX IF NOT EXISTS ix_negocios_prop  ON negocios(propiedad_id);

CREATE TABLE IF NOT EXISTS citas (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  cliente_id    INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
  propiedad_id  INTEGER REFERENCES propiedades(id) ON DELETE SET NULL,
  tipo          TEXT NOT NULL DEFAULT 'recorrido' CHECK (tipo IN ('recorrido','llamada','firma','entrega','reunion')),
  fecha_hora    TEXT NOT NULL,
  estado        TEXT NOT NULL DEFAULT 'programada' CHECK (estado IN ('programada','realizada','cancelada','no_asistio')),
  asesor_id     INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  notas         TEXT,
  creado_en     TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS ix_citas_fecha ON citas(fecha_hora, estado);

-- Todo lo que pasa con un cliente: formulario web, WhatsApp, llamada, nota…
CREATE TABLE IF NOT EXISTS interacciones (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  cliente_id    INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
  propiedad_id  INTEGER REFERENCES propiedades(id) ON DELETE SET NULL,
  negocio_id    INTEGER REFERENCES negocios(id) ON DELETE SET NULL,
  tipo          TEXT NOT NULL CHECK (tipo IN ('formulario','whatsapp','llamada','correo','visita','nota','cambio_etapa')),
  detalle       TEXT,
  datos         TEXT,                            -- JSON con lo enviado en el formulario
  usuario_id    INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  creado_en     TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS ix_inter_cliente ON interacciones(cliente_id, creado_en);

-- ---------------------------------------------------------------------
-- 4. SITIO: PLANTILLAS DE DISEÑO Y CONFIGURACIÓN
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS plantillas (
  id           TEXT PRIMARY KEY,                -- noche, claro, calido
  nombre       TEXT NOT NULL,
  descripcion  TEXT NOT NULL,
  tokens       TEXT NOT NULL,                   -- JSON: colores, tipografías, radios, estilo de tarjetas
  activa       INTEGER NOT NULL DEFAULT 0 CHECK (activa IN (0,1)),
  actualizado_en TEXT NOT NULL DEFAULT (datetime('now'))
);
-- Solo una plantilla activa a la vez
CREATE UNIQUE INDEX IF NOT EXISTS ux_plantilla_activa ON plantillas(activa) WHERE activa = 1;

CREATE TABLE IF NOT EXISTS configuracion (
  clave        TEXT PRIMARY KEY,
  valor        TEXT,
  descripcion  TEXT,
  actualizado_en TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ---------------------------------------------------------------------
-- 5. HUBSPOT Y AUDITORÍA
-- ---------------------------------------------------------------------
-- Cola de sincronización: cada cliente/negocio nuevo o cambiado se envía a HubSpot
CREATE TABLE IF NOT EXISTS hubspot_sync (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  entidad     TEXT NOT NULL CHECK (entidad IN ('cliente','negocio','interaccion')),
  entidad_id  INTEGER NOT NULL,
  accion      TEXT NOT NULL CHECK (accion IN ('crear','actualizar')),
  estado      TEXT NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente','enviado','error')),
  intentos    INTEGER NOT NULL DEFAULT 0,
  ultimo_error TEXT,
  creado_en   TEXT NOT NULL DEFAULT (datetime('now')),
  enviado_en  TEXT
);
CREATE INDEX IF NOT EXISTS ix_sync_pend ON hubspot_sync(estado, creado_en);

CREATE TABLE IF NOT EXISTS bitacora (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  usuario_id  INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  accion      TEXT NOT NULL,                    -- crear, editar, borrar, ingresar, cambiar_estado…
  entidad     TEXT NOT NULL,
  entidad_id  TEXT,
  antes       TEXT,                             -- JSON
  despues     TEXT,                             -- JSON
  ip          TEXT,
  creado_en   TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS ix_bitacora_fecha ON bitacora(creado_en);

-- Vistas de la página (para saber qué propiedades interesan más)
CREATE TABLE IF NOT EXISTS vistas_diarias (
  propiedad_id INTEGER NOT NULL REFERENCES propiedades(id) ON DELETE CASCADE,
  fecha        TEXT NOT NULL,
  vistas       INTEGER NOT NULL DEFAULT 0,
  clics_whatsapp INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (propiedad_id, fecha)
);

-- ---------------------------------------------------------------------
-- 6. AUTOMATISMOS (TRIGGERS)
-- ---------------------------------------------------------------------
CREATE TRIGGER IF NOT EXISTS tg_prop_actualizado AFTER UPDATE ON propiedades
FOR EACH ROW WHEN NEW.actualizado_en = OLD.actualizado_en
BEGIN UPDATE propiedades SET actualizado_en = datetime('now') WHERE id = NEW.id; END;

CREATE TRIGGER IF NOT EXISTS tg_prop_estado AFTER UPDATE OF estado ON propiedades
FOR EACH ROW WHEN NEW.estado <> OLD.estado
BEGIN
  INSERT INTO propiedad_estados (propiedad_id, estado_antes, estado_nuevo) VALUES (NEW.id, OLD.estado, NEW.estado);
  UPDATE propiedades SET vendida_en = CASE WHEN NEW.estado = 'vendida' THEN datetime('now') ELSE vendida_en END WHERE id = NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS tg_prop_precio AFTER UPDATE OF precio ON propiedades
FOR EACH ROW WHEN IFNULL(NEW.precio,-1) <> IFNULL(OLD.precio,-1)
BEGIN INSERT INTO propiedad_precios (propiedad_id, precio_antes, precio_nuevo) VALUES (NEW.id, OLD.precio, NEW.precio); END;

CREATE TRIGGER IF NOT EXISTS tg_cliente_nuevo AFTER INSERT ON clientes
BEGIN INSERT INTO hubspot_sync (entidad, entidad_id, accion) VALUES ('cliente', NEW.id, 'crear'); END;

CREATE TRIGGER IF NOT EXISTS tg_cliente_cambio AFTER UPDATE OF nombre, telefono, email, estado, asesor_id ON clientes
FOR EACH ROW
BEGIN
  UPDATE clientes SET actualizado_en = datetime('now') WHERE id = NEW.id;
  INSERT INTO hubspot_sync (entidad, entidad_id, accion) VALUES ('cliente', NEW.id, 'actualizar');
END;

CREATE TRIGGER IF NOT EXISTS tg_negocio_nuevo AFTER INSERT ON negocios
BEGIN
  INSERT INTO hubspot_sync (entidad, entidad_id, accion) VALUES ('negocio', NEW.id, 'crear');
  UPDATE clientes SET estado = CASE WHEN estado IN ('nuevo','contactado') THEN 'en_proceso' ELSE estado END WHERE id = NEW.cliente_id;
END;

CREATE TRIGGER IF NOT EXISTS tg_negocio_etapa AFTER UPDATE OF etapa ON negocios
FOR EACH ROW WHEN NEW.etapa <> OLD.etapa
BEGIN
  UPDATE negocios SET actualizado_en = datetime('now'),
         cerrado_en = CASE WHEN NEW.etapa IN ('entregado','perdido') THEN datetime('now') ELSE NULL END
   WHERE id = NEW.id;
  INSERT INTO interacciones (cliente_id, propiedad_id, negocio_id, tipo, detalle)
  VALUES (NEW.cliente_id, NEW.propiedad_id, NEW.id, 'cambio_etapa', OLD.etapa || ' → ' || NEW.etapa);
  INSERT INTO hubspot_sync (entidad, entidad_id, accion) VALUES ('negocio', NEW.id, 'actualizar');
  -- Al apartar, la propiedad queda reservada; al entregar, vendida
  UPDATE propiedades SET estado = CASE
      WHEN NEW.etapa = 'apartado'  AND estado = 'disponible' THEN 'reservada'
      WHEN NEW.etapa = 'entregado' THEN 'vendida'
      ELSE estado END
   WHERE id = NEW.propiedad_id;
END;

CREATE TRIGGER IF NOT EXISTS tg_interaccion_contacto AFTER INSERT ON interacciones
BEGIN UPDATE clientes SET ultimo_contacto = NEW.creado_en WHERE id = NEW.cliente_id; END;

-- ---------------------------------------------------------------------
-- 7. VISTAS PARA EL PANEL
-- ---------------------------------------------------------------------
-- Lo que ve la página pública
CREATE VIEW IF NOT EXISTS v_catalogo_publico AS
SELECT p.*, (SELECT ruta FROM medios m WHERE m.propiedad_id = p.id ORDER BY m.es_principal DESC, m.orden LIMIT 1) AS imagen,
  (SELECT json_group_array(json_object('t', tipo, 'r', ruta, 'o', orden)) FROM (SELECT tipo, ruta, orden FROM medios m WHERE m.propiedad_id = p.id ORDER BY orden)) AS medios_json
FROM propiedades p
WHERE p.publicada = 1 AND p.estado IN ('disponible','reservada','en_negociacion');

-- Estatus de la cartera (cuántas hay en cada estado y su valor)
CREATE VIEW IF NOT EXISTS v_resumen_estatus AS
SELECT estado, categoria, COUNT(*) AS cantidad,
       SUM(COALESCE(precio,0)) AS valor_venta, SUM(COALESCE(renta_mensual,0)) AS renta_mensual
FROM propiedades GROUP BY estado, categoria;

-- Embudo de negocios por etapa
CREATE VIEW IF NOT EXISTS v_embudo AS
SELECT etapa, COUNT(*) AS negocios, SUM(COALESCE(monto,0)) AS monto
FROM negocios GROUP BY etapa;

-- Clientes que escribieron y nadie les ha respondido en 24 h
CREATE VIEW IF NOT EXISTS v_clientes_sin_atender AS
SELECT c.*, ROUND((julianday('now') - julianday(COALESCE(c.ultimo_contacto, c.creado_en))) * 24, 1) AS horas_sin_contacto
FROM clientes c
WHERE c.estado = 'nuevo' AND julianday('now') - julianday(COALESCE(c.ultimo_contacto, c.creado_en)) > 1;

-- Qué le falta a cada propiedad para estar completa
CREATE VIEW IF NOT EXISTS v_propiedades_incompletas AS
SELECT p.id, p.codigo, p.titulo, p.estado,
  (SELECT COUNT(*) FROM medios m WHERE m.propiedad_id = p.id AND m.tipo IN ('foto','volante')) AS fotos,
  (SELECT COUNT(*) FROM medios m WHERE m.propiedad_id = p.id AND m.tipo = 'video') AS videos,
  CASE WHEN p.precio IS NULL AND p.renta_mensual IS NULL AND p.precio_texto IS NULL THEN 1 ELSE 0 END AS sin_precio,
  CASE WHEN p.zona IS NULL OR p.zona = '' THEN 1 ELSE 0 END AS sin_zona,
  CASE WHEN p.asesor_id IS NULL THEN 1 ELSE 0 END AS sin_asesor
FROM propiedades p
WHERE p.estado NOT IN ('vendida','retirada');

-- Archivos subidos desde el panel (fotos) o por clientes (documentos privados). Base64 en partes.
CREATE TABLE IF NOT EXISTS archivos (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  clave       TEXT NOT NULL UNIQUE,
  nombre      TEXT,
  tipo_mime   TEXT NOT NULL,
  tamano      INTEGER NOT NULL DEFAULT 0,
  partes      INTEGER NOT NULL DEFAULT 1,
  privado     INTEGER NOT NULL DEFAULT 0 CHECK (privado IN (0,1)),
  cliente_id  INTEGER REFERENCES clientes(id) ON DELETE CASCADE,
  subido_por  INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
  creado_en   TEXT NOT NULL DEFAULT (datetime('now')),
  gaveta      INTEGER NOT NULL DEFAULT 0   -- 0 = esta base; 1..9 = bases extra solo para fotos (db/gaveta_fotos.sql)
);
CREATE INDEX IF NOT EXISTS ix_archivos_cliente ON archivos(cliente_id);
CREATE TABLE IF NOT EXISTS archivo_partes (
  archivo_id  INTEGER NOT NULL REFERENCES archivos(id) ON DELETE CASCADE,
  n           INTEGER NOT NULL,
  datos       TEXT NOT NULL,
  PRIMARY KEY (archivo_id, n)
);
-- Permiso temporal para que un cliente suba documentos después de enviar el formulario
CREATE TABLE IF NOT EXISTS subidas (
  token       TEXT PRIMARY KEY,
  cliente_id  INTEGER NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
  usados      INTEGER NOT NULL DEFAULT 0,
  expira      TEXT NOT NULL
);
