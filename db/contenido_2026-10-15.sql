-- Contenido de C4 Realty del 15 oct 2026 (reemplaza lo tomado de Instagram)
DELETE FROM propiedades;
DELETE FROM proyectos;
DELETE FROM publicaciones_ig;
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,descripcion,estado,etiqueta,publicada,destacada,orden,fecha_publicacion) VALUES ('orquidea-bagala','casa','Modelo Orquídea','Bágala',NULL,80000,86500,0,'2','1','Techado',450,91.55,'[["Recámaras", "2"], ["Baños", "1"], ["Lavandería", "Cerrada"], ["Estacionamiento", "Techado"], ["Lote", "450 m²"], ["Construcción", "91.55 m² (abierta 18.61 · cerrada 72.94)"]]','["Lavandería cerrada", "Estacionamiento techado", "Teja gala en toda la casa", "Lote de 450 m²"]','["Precio de $80,000 solo por lanzamiento (precio regular $86,500)", "Aplica con salario de $950 a $1,000", "Bancos: Caja de Ahorros y Banco Nacional", "Importante: Si ya tienes propiedad con mejora en el Registro Público, no aplica el beneficio de ley de interés preferencial."]','🏡Bágala
 Modelo Orquídea 

✅2rec 1 baño 
✅Lavandería cerrada 
✅️Estacionamiento techado 
✅️Teja gala en toda la casa 
✅lote de 450m2

Área de construcción 91.55 ( abierta 18.61 y cerrada 72.94) 

💰Precio $80,000 solo por lanzamiento 
Precio regular 86,500 

Aplica con salario 950 a 1,000 bancos Caja de ahorros y banco nacional. 

🚫IMPORTANTE 🚨 
Ya tienes propiedad con mejora en registro publico no aplica a beneficio de ley interés preferencial 👈🏻','disponible','Precio de lanzamiento',1,0,1,'2026-10-15');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,es_principal,orden) SELECT p.id,v.column1,v.column2,v.column3,v.column4,v.column5 FROM propiedades p, (VALUES ('volante','img/p/1c286f60e2.jpg',NULL,1,1),('foto','img/p/1b9471d487.jpg',NULL,0,2),('foto','img/p/02f81028d1.jpg',NULL,0,3),('foto','img/p/810b23891f.jpg',NULL,0,4),('foto','img/p/e32ff4e272.jpg',NULL,0,5),('foto','img/p/92b7704c63.jpg',NULL,0,6),('foto','img/p/ac6e11ce43.jpg',NULL,0,7),('foto','img/p/9417ced63e.jpg',NULL,0,8),('foto','img/p/33b2abd58c.jpg',NULL,0,9),('foto','img/p/b4dd9fbbe1.jpg',NULL,0,10)) v WHERE p.codigo='orquidea-bagala';
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,descripcion,estado,etiqueta,publicada,destacada,orden,fecha_publicacion) VALUES ('jazmin-algarrobos','casa','Modelo Jazmín','Algarrobos',NULL,73185,NULL,1,'2 o 3','2',NULL,450,NULL,'[["Recámaras", "2 o 3"], ["Baños", "2"], ["Lavandería", "Cerrada (2 recámaras)"], ["Lote", "450 m²"]]','["Gastos legales gratis (Banco General y Global Bank)", "Grama frontal", "Tasa especial de 1.25 %"]','["2 rec · 2 baños · lavandería cerrada · sin garaje: $73,185", "3 rec · 2 baños · sin garaje: $82,620", "3 rec · 2 baños · con garaje: $86,700", "Letra aproximada de $275 mensual", "Aplica con salario desde $900 a $1,000 aprox.", "Importante: Si ya tienes propiedad con mejora, no aplicas a la ley de interés preferencial."]','✨️Casas en Montilla 

🏡Modelo Jazmin

Distribución:
2rec 2 baños 
Con lavandería cerrada 
Precio sin garaje $73,185

3rec 2 baños sin garaje $82,620
Con garaje $ 86,700

✅️Promociones 
🔴gastos legales gratis (banco general y global)
🔴 grama frontal con una tasa especial de 1.25%
📌Letra aproximadamente 275 mensual 

👉🏻Aplica con salario desde 900 a 1000 aproximadamente

🚫IMPORTANTE 
si ya tienes propiedad con mejora no aplicas a ley de interés preferencial','disponible',NULL,1,0,2,'2026-10-15');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,es_principal,orden) SELECT p.id,v.column1,v.column2,v.column3,v.column4,v.column5 FROM propiedades p, (VALUES ('volante','img/p/0f1f65a827.jpg',NULL,1,1),('foto','img/p/3176a16905.jpg',NULL,0,2),('foto','img/p/b40afa3fc2.jpg',NULL,0,3),('foto','img/p/2ce5b6d706.jpg',NULL,0,4),('foto','img/p/4860c0a957.jpg',NULL,0,5),('foto','img/p/74b6b5c6bd.jpg',NULL,0,6),('foto','img/p/3d01def824.jpg',NULL,0,7),('plano','docs/planos/modelo-jazmin.pdf',NULL,0,100)) v WHERE p.codigo='jazmin-algarrobos';
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,descripcion,estado,etiqueta,publicada,destacada,orden,fecha_publicacion) VALUES ('coral-spv','casa','Modelo Coral','San Pablo Viejo',NULL,70000,74644,0,'2','1',NULL,600,NULL,'[["Recámaras", "2"], ["Baños", "1"], ["Lote", "600 a 700 m²"]]','["Aplica bono de $3,000 con el Gobierno", "Gastos legales gratis con Global Bank y Banco General", "$500 si es con Caja de Ahorros", "Grama frontal"]','["Valor de $70,000 por tiempo limitado (precio regular $74,644)", "Aplica con salarios desde $900 mensual", "Letra aproximada de $140 quincenal"]','Casas en San Pablo viejo 
🏡Modelo Coral valor $70,000 por (tiempo limitado)
Precio regular $74,644)

✅2rec 
✅1 baño 
✅Lote mínimo 600 base lotes con m2 adicional hasta 700m2 

✅️Aplica bono de $3,000 con el Gobierno
Promo 

🎁Gastos legales gratis con : 
Global bank y banco general 
500 si es con Caja de ahorros 
🌿Grama frontal 

Aplica con salarios desde $900 mensual 

Letra aproximada de 140 quincenal','disponible','Por tiempo limitado',1,0,3,'2026-10-15');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,es_principal,orden) SELECT p.id,v.column1,v.column2,v.column3,v.column4,v.column5 FROM propiedades p, (VALUES ('volante','img/p/3a308d1380.jpg',NULL,1,1),('foto','img/p/ccb0d26ce4.jpg',NULL,0,2),('foto','img/p/463af14490.jpg',NULL,0,3),('foto','img/p/334d86bce5.jpg',NULL,0,4),('foto','img/p/fe53eb34db.jpg',NULL,0,5),('foto','img/p/f5791d26e5.jpg',NULL,0,6),('foto','img/p/a84eea9edd.jpg',NULL,0,7),('plano','docs/planos/modelo-coral.pdf',NULL,0,100)) v WHERE p.codigo='coral-spv';
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,descripcion,estado,etiqueta,publicada,destacada,orden,fecha_publicacion) VALUES ('girasol-spv','casa','Modelo Girasol','San Pablo Viejo',NULL,71604,NULL,1,'2 o 3','1',NULL,600,NULL,'[["Recámaras", "2 o 3"], ["Baños", "1"], ["Lote", "Mínimo 600 m², hasta 700 m²"]]','["Gastos legales gratis con Global Bank y Banco General", "$500 si es con Caja de Ahorros", "Grama frontal"]','["2 rec · 1 baño · sin garaje: $71,604", "2 rec · 1 baño · con garaje: $73,644", "3 rec · 1 baño · sin garaje: $76,194", "3 rec · 1 baño · con garaje: $79,254", "Aplica con salarios desde $900 mensual", "Letra aproximada de $152 quincenal"]','Casas en San Pablo viejo 
🏡Modelo Girasol 
 
☑️2rec 1 baño sin Garaje $71,604
Con garaje $73,644
☑️3rec 1 baño sin garaje 
$76,194
☑️3rec 1 baño con garaje$79,254 

✅3rec 
✅1 baño 
✅Lote mínimo 600 base lotes con m2 adicional hasta 700m2 

Promo 

🎁Gastos legales gratis con : 
Global bank y banco general 
500 si es con Caja de ahorros 
🌿Grama frontal 

Aplica con salarios desde $900 mensual 

Letra aproximada de 152 quincenal','disponible',NULL,1,0,4,'2026-10-15');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,es_principal,orden) SELECT p.id,v.column1,v.column2,v.column3,v.column4,v.column5 FROM propiedades p, (VALUES ('volante','img/p/6c84b5dc27.jpg',NULL,1,1),('foto','img/p/c4c5b58e1b.jpg',NULL,0,2),('foto','img/p/0fb8e99865.jpg',NULL,0,3),('foto','img/p/583ca38bde.jpg',NULL,0,4),('foto','img/p/29ab233ae6.jpg',NULL,0,5),('foto','img/p/8b7722e36d.jpg',NULL,0,6),('foto','img/p/30f2131a35.jpg',NULL,0,7),('foto','img/p/3ab7c37574.jpg',NULL,0,8),('foto','img/p/48efc7f628.jpg',NULL,0,9),('plano','docs/planos/modelo-girasol.pdf',NULL,0,100)) v WHERE p.codigo='girasol-spv';
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,descripcion,estado,etiqueta,publicada,destacada,orden,fecha_publicacion) VALUES ('coral-bagala','casa','Modelo Coral','Bágala',NULL,66300,NULL,1,'2','1',NULL,450,NULL,'[["Recámaras", "2"], ["Baños", "1"], ["Lote", "450 m²"]]','["Gastos legales gratis (Global Bank y Banco General)", "Grama frontal"]','["2 rec · 1 baño · sin garaje: $66,300", "2 rec · 1 baño · con garaje: $70,380", "Salario promedio de $850 a $900"]','🏡Modelo Coral Bágala 

☑️2rec 1 baño sin garaje $66,300 
Con garaje $70,380

✅Lote de 450m2

Promo Gastos legales gratis ( Global bank y banci general) 
Grama frontal 

Salario promedio 850 - 900','disponible',NULL,1,0,5,'2026-10-15');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,es_principal,orden) SELECT p.id,v.column1,v.column2,v.column3,v.column4,v.column5 FROM propiedades p, (VALUES ('volante','img/p/2ad8cdb485.jpg',NULL,1,1),('foto','img/p/ccb0d26ce4.jpg',NULL,0,2),('foto','img/p/463af14490.jpg',NULL,0,3),('foto','img/p/334d86bce5.jpg',NULL,0,4),('foto','img/p/fe53eb34db.jpg',NULL,0,5),('foto','img/p/f5791d26e5.jpg',NULL,0,6),('foto','img/p/a84eea9edd.jpg',NULL,0,7),('plano','docs/planos/modelo-coral.pdf',NULL,0,100)) v WHERE p.codigo='coral-bagala';
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,descripcion,estado,etiqueta,publicada,destacada,orden,fecha_publicacion) VALUES ('coral-montilla','casa','Modelo Coral','Montilla',NULL,68300,NULL,1,'2 o 3','1',NULL,450,NULL,'[["Recámaras", "2 o 3"], ["Baños", "1"], ["Lotes", "450 m²"]]','["Gastos legales gratis (Global Bank y Banco General)", "Grama frontal"]','["2 rec · 1 baño · sin estacionamiento: $68,300", "2 rec · 1 baño · con estacionamiento: $69,360", "3 rec · 1 baño · sin garaje: $72,930", "3 rec · 1 baño · con garaje: $79,990", "Letra quincenal de $135", "Salario para aplicar: $900 aproximadamente", "Importante: Si ya tienes propiedad con vivienda en el Registro Público, no aplica al beneficio de ley de interés preferencial 2026."]','🏡Modelo Coral

Disponible en 2 ubicaciones 
🚩 Montilla 

Distribución:
☑️2rec 1 baños sin estacionamiento $68,300
Con estacionamiento $69,360

☑️3rec 1 baño sin garaje $72,930
Con garaje $79,990

✅️Lotes 450m2
Letra quincenal 135 

Gastos legales gratis ( Global bank y banco general) 
 grama Frontal
Salario para aplicar $900 aproximadamente 

🚫importante si ya tiene propiedad con vivienda en registro publico no aplica al beneficio de ley interés preferencial 2026.','disponible',NULL,1,0,6,'2026-10-15');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,es_principal,orden) SELECT p.id,v.column1,v.column2,v.column3,v.column4,v.column5 FROM propiedades p, (VALUES ('volante','img/p/6003655d90.jpg',NULL,1,1),('foto','img/p/ccb0d26ce4.jpg',NULL,0,2),('foto','img/p/a84eea9edd.jpg',NULL,0,3),('foto','img/p/463af14490.jpg',NULL,0,4),('foto','img/p/334d86bce5.jpg',NULL,0,5),('foto','img/p/fe53eb34db.jpg',NULL,0,6),('foto','img/p/f5791d26e5.jpg',NULL,0,7)) v WHERE p.codigo='coral-montilla';
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,descripcion,estado,etiqueta,publicada,destacada,orden,fecha_publicacion) VALUES ('coral-bugaba','casa','Modelo Coral','Bugaba',NULL,72250,NULL,0,'2','1','Sin garaje',450,NULL,'[["Recámaras", "2"], ["Baños", "1"], ["Garaje", "Sin garaje"], ["Lote", "450 m²"]]','["Promo: gastos legales gratis (Global Bank)", "Caja de Ahorros: bono de $500 para gastos legales"]','["2 rec · 1 baño · sin garaje: $72,250"]','🏡Modelo Coral en Bugaba

☑️2rec 1 baño sin garaje $ 72,250 

Promo gastos legales Gratis ( banco global )
Caja de ahorros Boko de 500 para Gastos legales','disponible',NULL,1,0,7,'2026-10-15');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,es_principal,orden) SELECT p.id,v.column1,v.column2,v.column3,v.column4,v.column5 FROM propiedades p, (VALUES ('volante','img/p/2e7d862a49.jpg',NULL,1,1),('foto','img/p/f5791d26e5.jpg',NULL,0,2),('foto','img/p/a84eea9edd.jpg',NULL,0,3),('foto','img/p/ccb0d26ce4.jpg',NULL,0,4),('foto','img/p/463af14490.jpg',NULL,0,5),('foto','img/p/334d86bce5.jpg',NULL,0,6),('foto','img/p/fe53eb34db.jpg',NULL,0,7),('plano','docs/planos/modelo-coral.pdf',NULL,0,100)) v WHERE p.codigo='coral-bugaba';
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,descripcion,estado,etiqueta,publicada,destacada,orden,fecha_publicacion) VALUES ('coral-boqueron','casa','Modelo Coral','Boquerón',NULL,74760,NULL,1,'2 o 3','1',NULL,600,NULL,'[["Recámaras", "2 o 3"], ["Baños", "1"], ["Lote", "600 m²"]]','["Gastos legales gratis (Banco General y Global Bank)", "Caja de Ahorros: bono de $500"]','["2 rec · 1 baño · sin garaje: $74,760", "2 rec · 1 baño · con garaje: $76,500", "3 rec · 1 baño · sin garaje: $79,050", "3 rec · 1 baño · con garaje: $82,110", "Aplica con salarios desde $900 aprox."]','🏡Modelo Coral en Boqueron 

☑️2rec 1 baño sin garaje $74,760
Con garaje $ 76,500
☑️3rec 1 baño sin garaje $ 79,050
Con garaje $82,110 

📌Promo 

Gastos legales gratis ( banco general y global bank)
Caja de ahorros Bono de 500

Aplica con salarios desde 900 aprox','disponible',NULL,1,0,8,'2026-10-15');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,es_principal,orden) SELECT p.id,v.column1,v.column2,v.column3,v.column4,v.column5 FROM propiedades p, (VALUES ('volante','img/p/0fcebdacc0.jpg',NULL,1,1),('foto','img/p/ccb0d26ce4.jpg',NULL,0,2),('foto','img/p/463af14490.jpg',NULL,0,3),('foto','img/p/334d86bce5.jpg',NULL,0,4),('foto','img/p/fe53eb34db.jpg',NULL,0,5),('foto','img/p/f5791d26e5.jpg',NULL,0,6),('foto','img/p/a84eea9edd.jpg',NULL,0,7)) v WHERE p.codigo='coral-boqueron';
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,descripcion,estado,etiqueta,publicada,destacada,orden,fecha_publicacion) VALUES ('jade-frances','casa','Modelo Jade · Las Hortencias','Boquete','El Francés, Boquete',70000,NULL,0,'2','1',NULL,450,NULL,'[["Recámaras", "2"], ["Baños", "1"], ["Lote", "450 m²"]]','[]','["Financiamiento con Caja de Ahorros", "Salario aproximado desde $900"]','Las Hortencias 

📍El Francés Boquete 

🏡Modelo Jade 
2 Recamaras 1 baño 
Lote 450m2

Precio $70,000

financiamiento con caja de ahorros 

Salario aproximado desde $900','disponible',NULL,1,0,9,'2026-10-15');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,es_principal,orden) SELECT p.id,v.column1,v.column2,v.column3,v.column4,v.column5 FROM propiedades p, (VALUES ('volante','img/p/1fae001299.jpg',NULL,1,1),('foto','img/p/c562b68c34.jpg',NULL,0,2),('foto','img/p/b767049113.jpg',NULL,0,3),('foto','img/p/ea358c1e84.jpg',NULL,0,4),('foto','img/p/55b04c09f8.jpg',NULL,0,5),('foto','img/p/f110183be6.jpg',NULL,0,6),('foto','img/p/7f725f9c1e.jpg',NULL,0,7),('foto','img/p/1b35e68b4d.jpg',NULL,0,8),('foto','img/p/cfcce30997.jpg',NULL,0,9),('foto','img/p/27e072c36a.jpg',NULL,0,10),('foto','img/p/2f02aba0ec.jpg',NULL,0,11),('foto','img/p/6e0d49674a.jpg',NULL,0,12)) v WHERE p.codigo='jade-frances';
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_antes,precio_desde,recamaras,banos,estacionamiento,lote_m2,construccion_m2,caracteristicas,incluye,pagos,descripcion,estado,etiqueta,publicada,destacada,orden,fecha_publicacion) VALUES ('vila-aguacatal','casa','Modelo Vila','Aguacatal',NULL,NULL,NULL,0,NULL,NULL,NULL,200,NULL,'[["Lote", "200 m²"]]','[]','["Precio: consultar por WhatsApp"]',NULL,'disponible','Nuevo',1,0,10,'2026-10-15');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,es_principal,orden) SELECT p.id,v.column1,v.column2,v.column3,v.column4,v.column5 FROM propiedades p, (VALUES ('volante','img/p/05454e334f.jpg',NULL,1,1),('foto','img/p/0d9a610af8.jpg',NULL,0,2),('foto','img/p/d0fe933b48.jpg',NULL,0,3),('foto','img/p/abf94a5823.jpg',NULL,0,4),('video','videos/aguacatal-vila-1.mp4','videos/aguacatal-vila-1.jpg',0,200),('video','videos/aguacatal-vila-2.mp4','videos/aguacatal-vila-2.jpg',0,201),('video','videos/aguacatal-vila-3.mp4','videos/aguacatal-vila-3.jpg',0,202)) v WHERE p.codigo='vila-aguacatal';
