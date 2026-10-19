-- Videos de la sección "Videos" de la página. Los que traen archivo se ven desde GitHub;
-- los que se agregan desde el panel solo guardan el código del enlace de Instagram.
CREATE TABLE IF NOT EXISTS videos (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo         TEXT NOT NULL,
  lugar          TEXT,
  codigo         TEXT NOT NULL,
  archivo        TEXT,
  mp4            TEXT,
  poster         TEXT,
  seccion        TEXT NOT NULL DEFAULT 'videos',
  publicado      INTEGER NOT NULL DEFAULT 1,
  orden          INTEGER NOT NULL DEFAULT 0,
  creado_en      TEXT NOT NULL DEFAULT (datetime('now')),
  actualizado_en TEXT
);

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
