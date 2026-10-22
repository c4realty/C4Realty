-- Propiedad nueva del 21 de octubre de 2026 (Modelo Montreal, Entrada de Santa Rosa)
INSERT INTO propiedades (codigo,categoria,titulo,zona,precio,precio_desde,recamaras,banos,estacionamiento,lote_m2,caracteristicas,incluye,pagos,descripcion,estado,etiqueta,publicada,destacada,orden,fecha_publicacion) VALUES ('montreal-santa-rosa','casa','Modelo Montreal','Entrada de Santa Rosa',72000,1,'2 o 3','1 o 2','Opcional (2 recámaras)',450,'[["Recámaras", "2 o 3"], ["Baños", "1 o 2"], ["Lavandería", "Cerrada"], ["Estacionamiento", "Opcional (2 recámaras)"], ["Lote", "450 m²"]]','["Gastos legales gratis (Banco General y Global Bank)", "Grama frontal", "Verjas"]','["2 rec · 1 baño · lavandería cerrada · sin estacionamiento: $72,000", "2 rec · 1 baño · lavandería cerrada · con estacionamiento: $75,000", "3 rec · 2 baños · lavandería cerrada · sin estacionamiento: $80,000"]','🏡Modelo Montreal 

Ubicado en Entrada Santa Rosa 

☑️2rec 1 baño, valanderia cerrada 
 sin estacionamiento Valor $72,000
Con estacionamiento $75,000

☑️3rec 2 baños con lavandería cerrada sin estacionamiento $80,000

✅️Lote de 450m2 

Promociones

Gastoa legales gratis con banco general y global 
Grama frontal y verjas','disponible','Nuevo',1,0,0,'2026-10-21');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,es_principal,orden) SELECT p.id,'volante','img/p/b9e1576cde.jpg',NULL,1,1 FROM propiedades p WHERE p.codigo='montreal-santa-rosa';
