# Base de datos C4 Realty (Cloudflare D1)

Dos archivos:

| Archivo | Qué hace |
|---|---|
| `schema.sql` | Crea las tablas, reglas, automatizaciones (triggers) y vistas de estatus. |
| `seed.sql` | Carga los datos iniciales: roles, permisos, 3 plantillas, configuración, las 23 propiedades del catálogo con sus fotos y videos, y la usuaria de Alicia. |

## Instalar en Cloudflare

En el panel: **Almacenamiento y bases de datos → D1 → Crear base de datos**, nombre `c4realty`.
Luego en la pestaña **Consola**, pega el contenido de `schema.sql` y ejecuta. Después haz lo mismo con `seed.sql`.

Con la terminal (opcional):

```bash
npx wrangler d1 create c4realty
npx wrangler d1 execute c4realty --remote --file=db/schema.sql
npx wrangler d1 execute c4realty --remote --file=db/seed.sql
```

## 1. Usuarios y permisos

Cada usuario tiene **un rol**. Cada rol tiene, por módulo, cuatro permisos (`ver`, `crear`, `editar`, `borrar`) y un **alcance**: `todos` o solo `propios` (lo que tiene asignado).

| Módulo | Administrador | Coadministrador | Asesor | Asistente | Lectura |
|---|---|---|---|---|---|
| Propiedades | Todo | Todo | Ver | Ver, crear, editar | Ver |
| Fotos y videos | Todo | Todo | Ver | Ver, crear, editar | Ver |
| Clientes | Todo | Todo | Lo suyo | Ver, crear, editar | — |
| Negocios | Todo | Todo | Lo suyo | Ver | — |
| Citas | Todo | Todo | Lo suyo | Ver, crear, editar | — |
| Usuarios | Todo | Ver | — | — | — |
| Configuración | Todo | Ver | — | — | — |
| Plantillas | Todo | Ver, editar | — | Ver | — |
| Reportes | Todo | Ver | Los suyos | Ver | Ver |
| Bitácora | Todo | Ver | — | — | — |

Los permisos están en la tabla `permisos`, así que se pueden cambiar sin tocar código.
Alicia queda creada como **administradora** en estado `pendiente`; ella pone su clave la primera vez que entra. Las claves se guardan cifradas (`clave_hash` + `clave_sal`) y nunca en texto plano.

## 2. Catálogo y estatus

**Estados de una propiedad:** `borrador` → `disponible` → `reservada` → `en_negociacion` → `vendida` / `alquilada` → `retirada`.

- Cada cambio de estado queda guardado en `propiedad_estados` (quién, cuándo, de qué a qué).
- Cada cambio de precio queda guardado en `propiedad_precios`.
- `aplica_bono` se calcula solo: casa o apartamento de hasta $80,000.
- `medios` guarda fotos, videos, volantes, planos y brochures por propiedad.
- `publicaciones_ig` enlaza cada foto o video con su publicación original en @c4realty1.

> Las 23 propiedades entran como `disponible`. **Alicia debe confirmar cuáles siguen a la venta** y marcar las vendidas.

## 3. Clientes que escriben (CRM)

- `clientes`: cada persona que llena un formulario o escribe. Se guarda por dónde llegó (`web_cotizar`, `web_contacto`, `whatsapp`, `instagram`, `referido`, `visita`) y su estado (`nuevo`, `contactado`, `en_proceso`, `cliente`, `perdido`, `descartado`).
- `cliente_documentos`: la lista de documentos para cotizar (asalariado o independiente) y si ya los entregó.
- `negocios`: el proceso de compra, con las etapas de Alicia:
  `cotizacion` → `recorrido` → `apartado` → `documentacion` → `aprobacion` → `contrato` → `abonos` → `entregado` (o `perdido`).
- `citas`: recorridos y reuniones.
- `interacciones`: historial de llamadas, WhatsApp, correos, visitas y notas.

**Automatizaciones (ya incluidas):**

| Cuando… | La base de datos hace… |
|---|---|
| Entra un cliente nuevo | Lo pone en la cola para HubSpot. |
| Se abre un negocio | El cliente pasa a `en_proceso`. |
| El negocio llega a **apartado** | La propiedad pasa a `reservada`. |
| El negocio llega a **entregado** | La propiedad pasa a `vendida` y se guarda la fecha. |
| Cambia la etapa del negocio | Se anota en el historial y se avisa a HubSpot. |
| Se registra una interacción | Se actualiza el "último contacto" del cliente. |

## 4. Vistas de estatus (lo que Alicia ve en el panel)

| Vista | Muestra |
|---|---|
| `v_resumen_estatus` | Cuántas propiedades hay por estado y tipo, con su valor de venta y renta (así se ve cuánto queda disponible y cuánto se vendió). |
| `v_catalogo_publico` | Lo que la página web muestra (solo publicadas y no retiradas). |
| `v_embudo` | Cuántos negocios hay en cada etapa y por qué monto. |
| `v_clientes_sin_atender` | Clientes nuevos con más de 24 horas sin contacto. |
| `v_propiedades_incompletas` | Propiedades a la venta a las que les falta foto, video, precio, zona o asesor. |

## 5. Tres plantillas de diseño

La tabla `plantillas` guarda colores, letras y estilo de tarjetas. **Solo una puede estar activa**, y cambiarla cambia el diseño de toda la página.

| Plantilla | Estilo |
|---|---|
| **Noche** (activa) | Azul oscuro `#0b1526` con dorado `#f2b84b`. Letras Plus Jakarta Sans y Manrope. |
| **Claro** | Blanco y gris con texto negro, tipo ficha de portafolio. Letra Inter. |
| **Cálido** | Arena `#f6f1e8` con verde montaña `#2f6b4f`. Letras Fraunces y Source Sans 3. |

## 6. Conexión con HubSpot

Los formularios de la página guardan en D1, y la tabla `hubspot_sync` funciona como cola:

1. Un trigger agrega una fila `pendiente` cuando un cliente o negocio se crea o cambia.
2. Un Worker de Cloudflare (programado cada pocos minutos) lee las filas pendientes y las envía a la API de HubSpot (Contacts y Deals).
3. Si sale bien, marca `enviado` y guarda `hubspot_id` / `hubspot_deal_id`. Si falla, marca `error`, suma `intentos` y lo reintenta después.

Para activarlo hacen falta, en `configuracion`, el **Portal ID** de HubSpot y un **token de app privada**. El token se guarda como *secret* del Worker, no en la base de datos.

## 7. Auditoría

- `bitacora`: quién hizo qué cambio y cuándo.
- `vistas_diarias`: visitas por propiedad y por día, para saber qué interesa más.
