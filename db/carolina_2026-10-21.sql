-- Propiedad nueva del 21 de octubre de 2026 (Modelo Carolina Deluxe). Sin precio todavía: sale como "Consultar".
INSERT INTO propiedades (codigo,categoria,titulo,zona,zona_detalle,precio,precio_desde,lote_m2,caracteristicas,incluye,pagos,descripcion,estado,etiqueta,publicada,destacada,orden,fecha_publicacion) VALUES ('carolina-deluxe','casa','Modelo Carolina Deluxe','Vía Interamericana','Vía Interamericana, llegando a la Universidad Agronómica',NULL,0,450,'[["Lote", "450 m²"]]','[]','[]','Modelo Carolina Deluxe

Ubicado en Vía Interamericana llegando a Universidad Agronoma

Lote 450 m²','disponible','Nuevo',1,0,0,'2026-10-21');
INSERT INTO medios (propiedad_id,tipo,ruta,portada,es_principal,orden) SELECT p.id,'volante','img/p/fc18b0aa28.jpg',NULL,1,1 FROM propiedades p WHERE p.codigo='carolina-deluxe';
