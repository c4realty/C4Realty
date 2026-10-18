-- C4 Realty · datos iniciales (generado desde las publicaciones de @c4realty1, jul–oct 2026)
-- D1 aplica las llaves foráneas automáticamente (en SQLite local: PRAGMA foreign_keys = ON;)

-- Roles
INSERT INTO roles (id,nombre,descripcion) VALUES
 ('administrador','Administrador','Control total: propiedades, clientes, usuarios, plantillas y configuración.'),
 ('coadministrador','Coadministrador','Todo lo operativo; no crea ni borra usuarios ni cambia la configuración.'),
 ('lectura','Solo lectura','Ve el catálogo, el estatus y los reportes; no modifica nada.');

-- Permisos (ver, crear, editar, borrar, alcance)
INSERT INTO permisos (rol_id,modulo,ver,crear,editar,borrar,alcance) VALUES
 ('administrador','propiedades',1,1,1,1,'todos'),
 ('administrador','medios',1,1,1,1,'todos'),
 ('administrador','clientes',1,1,1,1,'todos'),
 ('administrador','negocios',1,1,1,1,'todos'),
 ('administrador','citas',1,1,1,1,'todos'),
 ('administrador','usuarios',1,1,1,1,'todos'),
 ('administrador','configuracion',1,1,1,1,'todos'),
 ('administrador','plantillas',1,1,1,1,'todos'),
 ('administrador','reportes',1,1,1,1,'todos'),
 ('administrador','bitacora',1,1,1,1,'todos'),
 ('coadministrador','propiedades',1,1,1,1,'todos'),
 ('coadministrador','medios',1,1,1,1,'todos'),
 ('coadministrador','clientes',1,1,1,1,'todos'),
 ('coadministrador','negocios',1,1,1,1,'todos'),
 ('coadministrador','citas',1,1,1,1,'todos'),
 ('coadministrador','usuarios',1,0,0,0,'todos'),
 ('coadministrador','configuracion',1,0,0,0,'todos'),
 ('coadministrador','plantillas',1,0,1,0,'todos'),
 ('coadministrador','reportes',1,0,0,0,'todos'),
 ('coadministrador','bitacora',1,0,0,0,'todos'),
 ('lectura','propiedades',1,0,0,0,'todos'),
 ('lectura','medios',1,0,0,0,'todos'),
 ('lectura','clientes',0,0,0,0,'todos'),
 ('lectura','negocios',0,0,0,0,'todos'),
 ('lectura','citas',0,0,0,0,'todos'),
 ('lectura','usuarios',0,0,0,0,'todos'),
 ('lectura','configuracion',0,0,0,0,'todos'),
 ('lectura','plantillas',0,0,0,0,'todos'),
 ('lectura','reportes',1,0,0,0,'todos'),
 ('lectura','bitacora',0,0,0,0,'todos');

-- Plantillas de diseño (solo una activa)
INSERT INTO plantillas (id,nombre,descripcion,tokens,activa) VALUES
 ('noche','Noche','Azul oscuro con acento dorado. Elegante y moderna (la actual).','{"fondo":"#0b1526","superficie":"#132342","texto":"#eaf0fa","texto_suave":"#9fb0c8","acento":"#f2b84b","linea":"#25395f","titulos":"Plus Jakarta Sans","cuerpo":"Manrope","radio":16,"tarjeta":"foto-arriba","ficha":"panel-claro"}',1),
 ('claro','Claro','Blanco y gris con texto negro, estilo portafolio profesional (inspirada en la ficha de Pantera).','{"fondo":"#ffffff","superficie":"#f4f5f7","texto":"#14171c","texto_suave":"#6b7280","acento":"#0b1526","linea":"#e6e8ec","titulos":"Inter Tight","cuerpo":"Inter","radio":10,"tarjeta":"foto-arriba-minimal","ficha":"panel-claro"}',0),
 ('calido','Cálido','Tonos arena y verde montaña, pensada para casas en Boquete y Chiriquí.','{"fondo":"#f6f1e8","superficie":"#ffffff","texto":"#2b2620","texto_suave":"#6e6457","acento":"#2f6b4f","linea":"#e4dccd","titulos":"Fraunces","cuerpo":"Source Sans 3","radio":14,"tarjeta":"foto-grande","ficha":"pagina-completa"}',0);

-- Configuración
INSERT INTO configuracion (clave,valor,descripcion) VALUES
 ('nombre_sitio','C4 Realty','Nombre que aparece en la página'),
 ('whatsapp','50762531751','WhatsApp para botones (formato internacional, sin +)'),
 ('whatsapp_visible','6253-1751','WhatsApp como se muestra'),
 ('correo','c4realty1@gmail.com','Correo de contacto'),
 ('instagram','c4realty1','Usuario de Instagram'),
 ('hero_titulo','Cotizar es tu primer paso para obtener tu vivienda','Título de la portada'),
 ('hero_etiqueta','Casas · Terrenos · Fincas en Chiriquí','Línea pequeña amarilla encima del título de la portada'),
 ('hero_texto','Somos especialistas en casas en Chiriquí. Boquete, Algarrobos, San Pablo Viejo, Bágala, Montilla, Bugaba, Boquerón, Aguacatal y más: compara proyectos, precios y planes de pago en un solo lugar.','Párrafo debajo del título de la portada'),
 ('hubspot_portal_id','','ID de portal de HubSpot (pendiente)'),
 ('hubspot_form_registro','','ID del formulario de registro en HubSpot'),
 ('hubspot_form_cotizacion','','ID del formulario de cotización en HubSpot'),
 ('hubspot_form_contacto','','ID del formulario de contacto en HubSpot'),
 ('bono_monto','3000','Monto del Bono Pa’ Ti'),
 ('bono_tope_precio','80000','Precio máximo de vivienda para el bono');

-- Publicaciones de Instagram usadas en el catálogo
INSERT INTO publicaciones_ig (codigo,fecha,texto,tipo) VALUES
 ('Dd-U0i-RUv4','2026-10-01','Modelo Coral rebaja solo en San Pablo Viejo y por tiempo limitado

Adicional lotes de mas de 600m2 con precios especiales 

Aplica desde 850 aproximadamente 

Escríbenos al 6253-1751','video'),
 ('DcufbgIxIZG','2026-10-01','Promoción que no te puedes perder si te gustan los lotes grandes.

✅️Casa Modelo Coral rebajada de $73,644 a $70,000 ( modelo sin estacionamiento techado) 

✅️Lotes de casi 700m2 rebajados en precio especial 

✅️gastos legales gratis ( Banco general y Global )

✅️Grama Frontal 

✨️Aplica con salarios desde 900 y lerra mensual de 285 aproximadamente 

Escríbenos para cotizar y visitar el proyecto WhatsApp 6253-1751','video'),
 ('Dbd2WZjRkBZ','2026-10-01','Anuncio  de último momento

Rebaja en casas en San pablo viejo  Chiriquí 

🏡Casas de $73,644 en $70,000

Distribución 
2rec 1 baño 
Lavanderia abierta 
Sin estacionamiento techado 

➡️Lotes especiales desde 600m2 hasta 700m2 con precios especiales

✅️Gastos legales gratis ( banco generla y con Global bank) 
✅️Grama frontal 

Escríbenos al WhatsApp 6253-1751','video'),
 ('DdVKVX2xxG6','2026-09-15','Estas a tiempo de recibir tu casa este año 

Casa de entrega inmediata 
En San Pablo viejo 

Distribución 
✅️3rec
✅️2baños
✅️lavanderia cerrada 
✅️lote de 612 

👉🏻Pasa la navidad 2026 en tu casa nueva ✨️ Escríbenos al 6253-1751','video'),
 ('Db4WgESkZso','2026-08-10','Estas a tiempo de mudarte este mismo año, pasa las fiestas de fin de año en tu casa nueva.

🏡Casa en Algarrobos Bariloche última casa de 2rec 1 baño Lote de 460m2
Esquina valor $80,000 

🏡Casa en Algarrobos Las Marías 2rec 2 baños y estacionamiento techado valor $80,540, lote de 450m2

🏡Casa en Aguacatal Punta Roca con 2 rec 1 baño Lote de 500m2 

💥💥💥Todas estas opciones tiene una tasa especial del 0.75% 💥💥💥💥

✅️Si te interesa saber con que banco y que ofertas tenemos para ti escríbenos al 6253-1751 WhatsApp.

Tenemos promociones especiales','carrusel'),
 ('DccX6ioRPIp','2026-08-24','Si buscas realizar una inversión rentable y la seguridad es prioridad para ti. Tienes que conocer este proyecto.

✅️Cerca perimetrada 
✅️Portones eléctricos 
✅️Gimnasio
✅️Canchas deportivas 
✅️ Agua 💧 24/7 de buena calidad 

Todos los modelos incluyen closet y estacionamiento.

Con modelos desde los $114,750 y lotes de 600m2 información al 6253-1751 WhatsApp 

#interéspreferencial #casasnuevas #primeravivienda','video'),
 ('DcPh7MpxQds','2026-08-24','Ahora también tenemos para ti esta nueva propuesta en Algarrobos, donde la seguridad, armonía y tranquilidad son prioridad. 

Casas desde los $ 114,750 en lotes de 600m2.

Agenda tu visita al 6253-1751 WhatsApp','video'),
 ('DbcFFwMxg40','2026-08-10','Así como lo vez recibe hasta 50 m2 gratis por la compra de tu casa en Aguacatal.

Ademas recibe:

✅️Gastos legales gratis 
✅️Grama
✅️verjas 
✅️m2 adicionales a solo $15 

Escríbenos al WhatsApp 6253-1751 

#casasnuevas #promoción #viviendas #hipoteca','video'),
 ('Ddke02gxHxd','2026-09-21','Cuando me preguntan ¿tienes proyecto económico?
👉🏻Apatir de hoy no diré que Sí💥

Visitamos esta Opción en Aguacatal y nos gusto la casa y el precio de la misma.

Así que te la presento 

🏡Casas desde 2rec 1 baño hasta 3rec 2 baños 
Precio inicial en promoción desde $55,000

✅️Lote 205 m2 
✅️Calles de concreto 
✅️Agua privada 

Información 6253-1751 y 6475-5101 WhatsApp 

#casasnuevas #interéspreferencial ##patrimoniofamiliar','video'),
 ('DdSgwtbxhbD','2026-09-16','🏡Boquete el Francés 2da etapa de Residencial las Hortencias 

Características 

✅️Casas con 2rec 1 baño
✅️Lavanderia abierta 
✅️Lote de 450m2 

Aplica con salarios desde 900 mensuales 
Letra quincenal 133.

Escríbenos al 6253-1751 WhatsApp','foto'),
 ('DdXvidHOVLs','2026-09-16','Nos llego una nueva propuesta para Boquete el Francés.

Si buscas algo económico con letra aproximada de 266 mensual esta casa puede ser la que estabas esperando.

🏡Distribución de 2 rec 1 baño, lavanderia abierta y lote de 450m2 

Valor $70,000

Cotiza al 6253-1751 WhatsApp 

#casasnuevas #Boquete #interéspreferencial','video'),
 ('DcAMnqsRVbA','2026-08-25','💥💥Muchos nos ha  escrito por Boquete el Francés con este modelo, por eso queremos atenderlos en la casa modelo este  15 de agosto.💥💥💥

Desde las 9:00am hasta las 3:00 pm

Casa de $80,000 y $100,000

Letra mensual desde $300 aplica con salarios desde $900.

✅️Confirmar asistencia para enviar la dirección al 6475 5101 ✨️','foto'),
 ('Dbo5wH1xkZL','2026-08-25','Vive en Boquete el Francés 
Letra quincenal desde $155 con tasa rebaja por feria en $1.25%

También puedes escojer plazo de 35 años
Letra quincenal  en $137.

Aplica con salarios desde $900 

Lotes de 450m2

🏡características 

✅️2rec 1 baño
✅️Lavanderia cerrada 

Escríbenos al WhatsApp 6253-1751 para ayudarte desde cero. 

Una casa es un sueño, es una inversión, es una meta convertida en patrimonio. 

#casasenboquete #interéspreferencial ##patrimoniofamiliar','video'),
 ('DcfFsrDxuDh','2026-08-25','Últimos lotes disponibles 

🏡Casas en el Francés Boquete con distribución:

3rec 2 baños 
Lavanderia cerrada 
Estacionamiento techado ( modelo Natasha)

Aplica desde $1350 aproximadamente 

Escríbenos al 6253-1751 WhatsApp 

#casasenDavid #Boquete #interéspreferencial','video'),
 ('DdaTUj7xgP1','2026-09-17','🏡 en Boquete Vía Caldera 
Entrega este año
✨️Mantenemos una casa solo una disponible en la etapa 1 y ya esta en construcción ✨️

Distribución 

3Recamaras
2baños 
Estacionamiento 2 autos 
Terraza

Con la terraza con vista a las montañas y cerca del área del parque. 

Escribenos 6253-1751 WhatsApp','foto'),
 ('DdIN_4ZxRqz','2026-09-17','Alerta nos queda una casa en construcción en Boquete Vía Caldera 

🏡Modelo Star Plus 

✨️Distribución: 
✅️3rec 2 baños 
✅️Estacionamiento techado para 2 autos 
✅️Lavanderia cerrada
✅️Terraza 

✨️Valor $110,000 
Escribenos al 6253-1751 WhatsApp 

#interéspreferencial #casasnuevas #primeravivienda #casasenboquete','video'),
 ('DdDHjB5xsYs','2026-09-17','Modelo Onix Boquete Vía Caldera 
Vistas expectaculares 

Distribución de 2 rec 2 baños en lote 540m2 con precios desde $128,750 

También tenemos el modelo Platino en $145,000 

Te gustaría conocerlo escríbenos al 6253-1751','video'),
 ('Dd5JIqqx-uo','2026-09-29','¿Cuanto vale la ubicación de tu casa ?

Tu casa nueva puede ser hoy tu hogar pero mañana puede ser una fuente de ingresos, por eso elegir bien en tu presente puede ser Dinero, mayor plusvalía y una gran inversión en el futuro.

Casas desde los $95,000
Con diferentes distribución 

Te gustaria recibir toda la información del Residencial la Fontana.

Escríbenos al 6253-1751 WhatsApp','video'),
 ('DchkGexRP0e','2026-08-26','Con acceso a Trasporte, cerca de hospitales, universidad y área comercial 

El modelo Jazmín ha sido el favoritos de muchas familias.

🏡Distribución 

✔️2rec 
✔️2 baños 
✔️Lavanderia cerrada 
✔️lote de 450m2 

Aplica con salarios desde $900 y financiamiento hasta 35 años. 

Información, cotizaciones y visitas al WhatsApp 6253-1751','video'),
 ('DdAezX_xxKH','2026-09-07','La casa más grande en el mercado hasta precios de $80,000 

El primer tramo de interés preferencial llega hasta 80mil con tasas desde 0.75% 

Esta casa es la más grande en el mercado de hasta $80,000 pero es por una rebaja especial. Valor real $86,500 ❌️ por tiempo limitado 

Mantienen 2 rec 1 baño, lavanderia cerrada y estacionamiento techado todo en teja gala y buenos acabados. 

91.55m2 de construcción 

Te gustaría conocer la casa modelo escríbenos al 6253-1751 y te cotizamos.

#casaanuevas #interéspreferencial ##patrimoniofamiliar','video'),
 ('DeDX-FBRPLY','2026-10-03','Casas soñadas en Boquete 

Iniciando con un lote amplio de 904m2 

🏡Distribución 

✅️3rec 2 baños 
✅️Estacionamiento doble 
✅️Terraza 
✅️Mini bar 
✅️Medio baño
✅️Terraza salida en recamara principal 

✨️Acabados de lujo 
✔️Incluye lavavajillas 
✔️Muebles de cocina superiores e inferiores
✔️ extractor
✔️Lamparas
✔️ventiladores 
✔️Caños 

Valor $275,000

Agenda tu visita al 6253-1751 WhatsApp','video'),
 ('DbKGygdRUF9','2026-07-23','Casa en Las Trancas 

Lote de 614m2 
M2 de construcción 196m2 

🏡Distribución
✅3rec 2 baños 
✅️Terraza 
✅️Medio baño 
✅️Estacionamiento doble.

✨️Incluye muebles superiores e inferiores de cocina y closet en todas las habitaciones 

➡️Cerca de piedra y grama en todo el terreno

Valor $210,000

Mayor información al WhatsApp 6253-1751','video'),
 ('DdxXy82R5o4','2026-09-26','Casa de entrega inmediata ( falta retoques finales) 

Lote único en Volcán 
Altura paso Ancho 

Lote de 582.12 m2

Distribución 2rec 2 baños y estacionamiento techado 

Valor $125mil 

Salario aproximado para aplicar  1500

Bancos Banistmo 
Banco Aliados
Caja de Ahorros 
Danvivienda 

WhatsApp 6948-2167','video'),
 ('Dbmd0tSxMWl','2026-08-03','Se vende finca de 4 Hectáreas a 25 el m2 
En la vía Volcán Paso Ancho frente a la calle principal. 

Vistas a las montañas ⛰️ clima garantizado inversión inteligente.

Mayor información 6253-1751','foto'),
 ('DcbQ1KBRjs7','2026-08-24','Se vende lote en Boquete Altura Coutry Club Boquete. 
Superficie de 1,770.50 m2 ideal para vivienda con amplio lote o estructuras como apartamentos. Zona de alta Plusvalía y buen clima.

Información al 6253-1751','foto'),
 ('DcdwO0SxPHn','2026-08-25','Lote comercial sobre la vía Boquete 
Ubicación: El Francés frente entrada los Molinos 

Superficie de 4,064.07 m2 valor 60 x m2 se vende completo. 

Interesados escribir para información y agendar visita al 6253-1751','foto'),
 ('DbWa2yugWbU','2026-07-28','Si buscas alquiler desliza para que veas las opciones que tenemos disponibles 

Mayor información y visitas al 6253-1751','carrusel'),
 ('DbW7cZMxp-G',NULL,NULL,'video');

-- Propiedades (estado disponible y publicadas; confirmar disponibilidad con C4 Realty)
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('coral','casa','Modelo Coral','San Pablo Viejo',NULL,70000,73644,0,NULL,NULL,'2','1',NULL,NULL,NULL,'[["Recámaras","2"],["Baños","1"],["Lavandería","Abierta"],["Lotes","600 a 700 m²"]]','["Rebaja de $73,644 a $70,000 por tiempo limitado","Modelo sin estacionamiento techado","Lotes de 600 a 700 m² con precio especial","Gastos legales gratis con Banco General y Global Bank","Grama frontal"]','["Aplica con salarios desde $850–$900 aprox.","Letra mensual aproximada de $285"]','disponible','Rebaja por tiempo limitado',1,0,'2026-10-01');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('sp3','casa','Casa de 3 recámaras','San Pablo Viejo',NULL,NULL,NULL,0,NULL,NULL,'3','2',NULL,612,NULL,'[["Recámaras","3"],["Baños","2"],["Lavandería","Cerrada"],["Lote","612 m²"]]','["Recíbela y pasa la Navidad 2026 en tu casa nueva"]','["Precio: consultar por WhatsApp"]','disponible','Entrega inmediata',1,1,'2026-09-15');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('bariloche','casa','Bariloche · Modelo Santiago A','Los Algarrobos',NULL,80000,NULL,0,NULL,NULL,'2','1',NULL,461,NULL,'[["Recámaras","2"],["Baños","1"],["Lote","461 m²"],["Ubicación","Esquina, entrada principal"]]','["Entrega inmediata","Lote 129, a un lado de Nuevo Horizonte"]','["Tasa especial del 0.75 %"]','disponible','Última casa',1,2,'2026-08-10');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('marias','casa','Las Marías','Los Algarrobos',NULL,80540,NULL,0,NULL,NULL,'2','2','Techado',450,NULL,'[["Recámaras","2"],["Baños","2"],["Estacionamiento","Techado"],["Lote","450 m²"]]','["Múdate este mismo año"]','["Tasa especial del 0.75 %"]','disponible',NULL,1,3,'2026-08-10');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('algarrobos','casa','Nuevo residencial en Algarrobos','Los Algarrobos',NULL,114750,NULL,1,NULL,NULL,NULL,NULL,NULL,600,NULL,'[["Lotes","600 m²"],["Incluye","Closet y estacionamiento"]]','["Cerca perimetrada","Portones eléctricos","Gimnasio","Canchas deportivas","Agua 24/7 de buena calidad"]','["Modelos desde $114,750"]','disponible','Nuevo',1,4,'2026-08-24');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('puntaroca','casa','Residencial Punta Roca','Aguacatal','David, vía Aguacatal',NULL,NULL,0,NULL,NULL,'2','1',NULL,500,NULL,'[["Recámaras","2"],["Baños","1"],["Lote","500 m²"]]','["Promoción en Aguacatal (julio): hasta 50 m² de terreno gratis","Gastos legales gratis, grama y verjas","m² adicionales a $15"]','["Tasa especial del 0.75 %","Precio: consultar por WhatsApp"]','disponible','Entrega inmediata',1,5,'2026-08-10');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('aguacatal','casa','Casas económicas en Aguacatal','Aguacatal',NULL,55000,NULL,1,NULL,NULL,'2 a 3','1 a 2',NULL,205,NULL,'[["Recámaras","2 a 3"],["Baños","1 a 2"],["Lote","205 m²"]]','["Calles de concreto","Agua privada"]','["Precio inicial en promoción desde $55,000","Aplica con salario desde $750"]','disponible','Promoción',1,6,'2026-09-21');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('hortencias','casa','Las Hortencias · 2da etapa','Boquete','El Francés, Boquete',70000,NULL,0,NULL,NULL,'2','1',NULL,450,NULL,'[["Recámaras","2"],["Baños","1"],["Lavandería","Abierta"],["Lote","450 m²"]]','["Segunda etapa de Residencial Las Hortencias"]','["Aplica con salarios desde $900","Letra quincenal de $133","Letra mensual aproximada de $266"]','disponible',NULL,1,7,'2026-09-16');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('francés','casa','Modelos en El Francés','Boquete','El Francés, Boquete',80000,NULL,1,NULL,NULL,'2 a 3','1 a 2',NULL,450,NULL,'[["Recámaras","2 a 3"],["Baños","1 a 2"],["Lote","450 m²"]]','["Casas de $80,000 y $100,000 con casa modelo","Modelo de 2 recámaras, 1 baño y lavandería cerrada","Modelo Natasha: 3 recámaras, 2 baños, lavandería cerrada y estacionamiento techado (últimos lotes)"]','["Letra quincenal desde $155 con tasa de feria de 1.25 %","A 35 años, letra quincenal de $137","Letra mensual desde $300; aplica con salarios desde $900","Modelo Natasha: aplica desde $1,350 aprox."]','disponible',NULL,1,8,'2026-08-25');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('caldera','casa','Boquete Vía Caldera','Boquete','Vía Caldera, Boquete',110000,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[["Modelos","Star Plus, Onix, Platino"],["Lotes","451.64 a 540 m²"]]','["Star Plus: 3 recámaras, 2 baños, lavandería cerrada, terraza y estacionamiento para 2 autos; lote de 451.64 m²; $110,000; única casa disponible en la etapa 1, entrega este año","Onix: 2 recámaras, 2 baños, lote de 540 m², desde $128,750","Platino: $145,000","Terraza con vista a las montañas, cerca del área del parque"]','["Star Plus $110,000 · Onix desde $128,750 · Platino $145,000"]','disponible','En construcción',1,9,'2026-09-17');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('fontana','casa','Residencial La Fontana',NULL,NULL,95000,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'[["Distribuciones","Varias"]]','["Ubicación pensada para plusvalía e inversión"]','["Casas desde $95,000"]','disponible',NULL,1,10,'2026-09-29');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('jazmin','casa','Modelo Jazmín','Montilla',NULL,73185,NULL,1,NULL,NULL,'2','2',NULL,450,NULL,'[["Recámaras","2"],["Baños","2"],["Lavandería","Cerrada"],["Lote","450 m²"]]','["Acceso a transporte","Cerca de hospitales, universidad y área comercial"]','["Aplica con salarios desde $900","Financiamiento hasta 35 años"]','disponible',NULL,1,11,'2026-08-26');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('grande80','casa','La casa más grande hasta $80,000',NULL,NULL,80000,86500,0,NULL,NULL,'2','1','Techado',NULL,91.55,'[["Recámaras","2"],["Baños","1"],["Construcción","91.55 m²"],["Estacionamiento","Techado"]]','["Lavandería cerrada","Techo de teja y buenos acabados","Valor real $86,500, rebaja por tiempo limitado"]','["Primer tramo de interés preferencial con tasas desde 0.75 %"]','disponible','Rebaja',1,12,'2026-09-07');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('trancas904','casa','Casa de lujo en Las Trancas','Boquete','Las Trancas, Boquete',275000,NULL,0,NULL,NULL,'3','2 y medio','Doble',904,NULL,'[["Recámaras","3"],["Baños","2 y medio"],["Estacionamiento","Doble"],["Lote","904 m²"]]','["Terraza con mini bar y salida desde la recámara principal","Acabados de lujo: lavavajillas, muebles de cocina, extractor, lámparas, ventiladores y caños","Grama incluida"]','["Valor $275,000"]','disponible','Entrega inmediata',1,13,'2026-10-03');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('trancas210','casa','Casa en Las Trancas','Boquete','Las Trancas, Boquete',210000,NULL,0,NULL,NULL,'3','2 y medio',NULL,614,196,'[["Recámaras","3"],["Baños","2 y medio"],["Construcción","196 m²"],["Lote","614 m²"]]','["Terraza y estacionamiento doble","Muebles de cocina superiores e inferiores y closet en todas las recámaras","Cerca de piedra y grama en todo el terreno"]','["Valor $210,000"]','disponible',NULL,1,14,'2026-07-23');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('volcan','casa','Casa en Altura Paso Ancho','Volcán',NULL,125000,NULL,0,NULL,NULL,'2','2','Techado',582.12,NULL,'[["Recámaras","2"],["Baños","2"],["Estacionamiento","Techado"],["Lote","582.12 m²"]]','["Lote único, faltan retoques finales"]','["Salario aproximado para aplicar: $1,500","Bancos: Banistmo, Banco Aliado, Caja de Ahorros y Danvivienda"]','disponible','Entrega inmediata',1,15,'2026-09-26');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('finca','finca','Finca de 4 hectáreas','Volcán','Vía Volcán – Paso Ancho',NULL,NULL,0,'$25 por m²',NULL,NULL,NULL,NULL,NULL,NULL,'[["Superficie","4 hectáreas"]]','["Frente a la calle principal","Vista a las montañas","Clima garantizado"]','["$25 por m²"]','disponible',NULL,1,16,'2026-08-03');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('lotecc','terreno','Lote detrás del Country Club','Boquete',NULL,135000,NULL,0,NULL,NULL,NULL,NULL,NULL,1770.5,NULL,'[["Superficie","1,770.50 m²"]]','["Ideal para vivienda o apartamentos","Zona de alta plusvalía y buen clima"]','["Valor $135,000"]','disponible',NULL,1,17,'2026-08-24');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('lotecom','terreno','Lote comercial en El Francés','Boquete','El Francés, Boquete',NULL,NULL,0,'$60 por m²',NULL,NULL,NULL,NULL,4064.07,NULL,'[["Superficie","4,064.07 m²"]]','["Sobre la vía principal, frente a la entrada de Los Molinos","Se vende completo","Excelente para inversiones"]','["$60 por m²"]','disponible',NULL,1,18,'2026-08-25');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('alq750','alquiler','Casa amoblada en Las Trancas','Boquete','Las Trancas, Boquete',NULL,NULL,0,NULL,750,'2','2','Techado',NULL,NULL,'[["Recámaras","2"],["Baños","2"],["Lavandería","Cerrada"],["Estacionamiento","Techado"]]','["Amoblada","Zona tranquila y de clima agradable"]','["$750 mensuales"]','disponible',NULL,1,19,'2026-07-28');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('alq850','alquiler','Casa amoblada en Las Trancas','Boquete','Las Trancas, Boquete',NULL,NULL,0,NULL,850,'2','2',NULL,NULL,NULL,'[["Recámaras","2"],["Baños","2"],["Lavandería","Cerrada"]]','["Amoblada"]','["$850 mensuales"]','disponible',NULL,1,20,'2026-07-28');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('alq475','alquiler','Casa amoblada en San Pablo Viejo','San Pablo Viejo',NULL,NULL,NULL,0,NULL,475,'3','1',NULL,600,NULL,'[["Recámaras","3"],["Baños","1"],["Lote","600 m²"]]','["Amoblada"]','["$475 mensuales"]','disponible',NULL,1,21,'2026-07-28');
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,precio_texto,renta_mensual,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,estado,etiqueta,publicada,orden,fecha_publicacion) VALUES ('alq260','alquiler','Casa en El Flor','Dolega','El Flor, Dolega',NULL,NULL,0,NULL,260,'2 con A/A','1','Techado',NULL,NULL,'[["Habitaciones","2 con A/A"],["Baños","1"],["Estacionamiento","Techado"]]','["Lavandería techada","Puertas y verjas de seguridad","Agua 24/7"]','["$260 mensuales"]','disponible',NULL,1,22,'2026-07-28');

-- Medios: fotos, volantes y videos
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='coral'),'foto','img/Dd-U0i-RUv4_1.jpg',1,0,'Dd-U0i-RUv4');
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='coral'),'foto','img/DcufbgIxIZG_1.jpg',0,1,'DcufbgIxIZG');
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='coral'),'foto','img/DbW7cZMxp-G_1.jpg',0,2,'DbW7cZMxp-G');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='coral'),'video','videos/Dd-U0i-RUv4.mp4','videos/Dd-U0i-RUv4.jpg',100,'Dd-U0i-RUv4');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='coral'),'video','videos/Dbd2WZjRkBZ.mp4','videos/Dbd2WZjRkBZ.jpg',101,'Dbd2WZjRkBZ');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='coral'),'Dd-U0i-RUv4',0);
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='coral'),'DcufbgIxIZG',1);
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='coral'),'Dbd2WZjRkBZ',2);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='sp3'),'foto','img/DdVKVX2xxG6_1.jpg',1,0,'DdVKVX2xxG6');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='sp3'),'video','videos/DdVKVX2xxG6.mp4','videos/DdVKVX2xxG6.jpg',100,'DdVKVX2xxG6');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='sp3'),'DdVKVX2xxG6',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='bariloche'),'foto','img/Db4WgESkZso_3.jpg',1,0,'Db4WgESkZso');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='bariloche'),'Db4WgESkZso',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='marias'),'foto','img/Db4WgESkZso_2.jpg',1,0,'Db4WgESkZso');
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='marias'),'foto','img/Db4WgESkZso_1.jpg',0,1,'Db4WgESkZso');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='marias'),'Db4WgESkZso',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='algarrobos'),'foto','img/DccX6ioRPIp_1.jpg',1,0,'DccX6ioRPIp');
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='algarrobos'),'foto','img/DcPh7MpxQds_1.jpg',0,1,'DcPh7MpxQds');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='algarrobos'),'video','videos/DccX6ioRPIp.mp4','videos/DccX6ioRPIp.jpg',100,'DccX6ioRPIp');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='algarrobos'),'video','videos/DcPh7MpxQds.mp4','videos/DcPh7MpxQds.jpg',101,'DcPh7MpxQds');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='algarrobos'),'DccX6ioRPIp',0);
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='algarrobos'),'DcPh7MpxQds',1);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='puntaroca'),'foto','img/Db4WgESkZso_4.jpg',1,0,'Db4WgESkZso');
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='puntaroca'),'foto','img/DbcFFwMxg40_1.jpg',0,1,'DbcFFwMxg40');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='puntaroca'),'video','videos/DbcFFwMxg40.mp4','videos/DbcFFwMxg40.jpg',100,'DbcFFwMxg40');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='puntaroca'),'Db4WgESkZso',0);
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='puntaroca'),'DbcFFwMxg40',1);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='aguacatal'),'foto','img/Ddke02gxHxd_1.jpg',1,0,'Ddke02gxHxd');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='aguacatal'),'video','videos/Ddke02gxHxd.mp4','videos/Ddke02gxHxd.jpg',100,'Ddke02gxHxd');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='aguacatal'),'Ddke02gxHxd',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='hortencias'),'foto','img/DdSgwtbxhbD_1.jpg',1,0,'DdSgwtbxhbD');
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='hortencias'),'foto','img/DdXvidHOVLs_1.jpg',0,1,'DdXvidHOVLs');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='hortencias'),'video','videos/DdXvidHOVLs.mp4','videos/DdXvidHOVLs.jpg',100,'DdXvidHOVLs');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='hortencias'),'DdSgwtbxhbD',0);
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='hortencias'),'DdXvidHOVLs',1);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='francés'),'foto','img/DcAMnqsRVbA_1.jpg',1,0,'DcAMnqsRVbA');
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='francés'),'foto','img/Dbo5wH1xkZL_1.jpg',0,1,'Dbo5wH1xkZL');
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='francés'),'foto','img/DcfFsrDxuDh_1.jpg',0,2,'DcfFsrDxuDh');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='francés'),'video','videos/Dbo5wH1xkZL.mp4','videos/Dbo5wH1xkZL.jpg',100,'Dbo5wH1xkZL');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='francés'),'video','videos/DcfFsrDxuDh.mp4','videos/DcfFsrDxuDh.jpg',101,'DcfFsrDxuDh');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='francés'),'DcAMnqsRVbA',0);
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='francés'),'Dbo5wH1xkZL',1);
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='francés'),'DcfFsrDxuDh',2);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='caldera'),'foto','img/DdaTUj7xgP1_1.jpg',1,0,'DdaTUj7xgP1');
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='caldera'),'foto','img/DdIN_4ZxRqz_1.jpg',0,1,'DdIN_4ZxRqz');
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='caldera'),'foto','img/DdDHjB5xsYs_1.jpg',0,2,'DdDHjB5xsYs');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='caldera'),'video','videos/DdIN_4ZxRqz.mp4','videos/DdIN_4ZxRqz.jpg',100,'DdIN_4ZxRqz');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='caldera'),'video','videos/DdDHjB5xsYs.mp4','videos/DdDHjB5xsYs.jpg',101,'DdDHjB5xsYs');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='caldera'),'DdaTUj7xgP1',0);
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='caldera'),'DdIN_4ZxRqz',1);
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='caldera'),'DdDHjB5xsYs',2);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='fontana'),'foto','img/Dd5JIqqx-uo_1.jpg',1,0,'Dd5JIqqx-uo');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='fontana'),'video','videos/Dd5JIqqx-uo.mp4','videos/Dd5JIqqx-uo.jpg',100,'Dd5JIqqx-uo');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='fontana'),'Dd5JIqqx-uo',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='jazmin'),'foto','img/DchkGexRP0e_1.jpg',1,0,'DchkGexRP0e');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='jazmin'),'video','videos/DchkGexRP0e.mp4','videos/DchkGexRP0e.jpg',100,'DchkGexRP0e');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='jazmin'),'DchkGexRP0e',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='grande80'),'foto','img/DdAezX_xxKH_1.jpg',1,0,'DdAezX_xxKH');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='grande80'),'video','videos/DdAezX_xxKH.mp4','videos/DdAezX_xxKH.jpg',100,'DdAezX_xxKH');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='grande80'),'DdAezX_xxKH',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='trancas904'),'foto','img/DeDX-FBRPLY_1.jpg',1,0,'DeDX-FBRPLY');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='trancas904'),'video','videos/DeDX-FBRPLY.mp4','videos/DeDX-FBRPLY.jpg',100,'DeDX-FBRPLY');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='trancas904'),'DeDX-FBRPLY',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='trancas210'),'foto','img/DbKGygdRUF9_1.jpg',1,0,'DbKGygdRUF9');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='trancas210'),'video','videos/DbKGygdRUF9.mp4','videos/DbKGygdRUF9.jpg',100,'DbKGygdRUF9');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='trancas210'),'DbKGygdRUF9',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='volcan'),'foto','img/DdxXy82R5o4_1.jpg',1,0,'DdxXy82R5o4');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='volcan'),'video','videos/DdxXy82R5o4.mp4','videos/DdxXy82R5o4.jpg',100,'DdxXy82R5o4');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='volcan'),'DdxXy82R5o4',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='finca'),'foto','img/Dbmd0tSxMWl_1.jpg',1,0,'Dbmd0tSxMWl');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='finca'),'Dbmd0tSxMWl',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='lotecc'),'foto','img/DcbQ1KBRjs7_1.jpg',1,0,'DcbQ1KBRjs7');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='lotecc'),'DcbQ1KBRjs7',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='lotecom'),'foto','img/DcdwO0SxPHn_1.jpg',1,0,'DcdwO0SxPHn');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='lotecom'),'DcdwO0SxPHn',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='alq750'),'foto','img/DbWa2yugWbU_1.jpg',1,0,'DbWa2yugWbU');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='alq750'),'DbWa2yugWbU',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='alq850'),'foto','img/DbWa2yugWbU_2.jpg',1,0,'DbWa2yugWbU');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='alq850'),'DbWa2yugWbU',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='alq475'),'foto','img/DbWa2yugWbU_3.jpg',1,0,'DbWa2yugWbU');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='alq475'),'DbWa2yugWbU',0);
INSERT INTO medios (propiedad_id,tipo,ruta,es_principal,orden,ig_codigo) VALUES ((SELECT id FROM propiedades WHERE codigo='alq260'),'foto','img/DbWa2yugWbU_4.jpg',1,0,'DbWa2yugWbU');
INSERT INTO propiedad_publicaciones (propiedad_id,codigo,orden) VALUES ((SELECT id FROM propiedades WHERE codigo='alq260'),'DbWa2yugWbU',0);

-- Usuaria administradora (la clave se crea en el primer ingreso)
INSERT INTO usuarios (nombre,email,rol_id,estado,cambiar_clave) VALUES ('Alicia','c4realty1@gmail.com','administrador','pendiente',1);

-- Videos que ya estaban en la página
INSERT INTO videos (titulo,lugar,codigo,archivo,orden) SELECT * FROM (VALUES
  ('Nuevo residencial desde $114,750','Algarrobos','DcPh7MpxQds','videos/DcPh7MpxQds',0),
  ('Modelo Onix en Boquete','Vía Caldera','DdDHjB5xsYs','videos/DdDHjB5xsYs',1),
  ('Casa de lujo, lote de 904 m²','Las Trancas','DeDX-FBRPLY','videos/DeDX-FBRPLY',2),
  ('Casa de $70,000 en Boquete','El Francés','DdXvidHOVLs','videos/DdXvidHOVLs',3),
  ('Entrega inmediata en Paso Ancho','Volcán','DdxXy82R5o4','videos/DdxXy82R5o4',4),
  ('Casas desde $55,000','Aguacatal','Ddke02gxHxd','videos/Ddke02gxHxd',5),
  ('Modelo Star Plus','Vía Caldera','DdIN_4ZxRqz','videos/DdIN_4ZxRqz',6),
  ('Casa en lote de 614 m²','Las Trancas','DbKGygdRUF9','videos/DbKGygdRUF9',7)
) WHERE NOT EXISTS (SELECT 1 FROM videos);
