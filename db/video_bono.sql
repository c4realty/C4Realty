-- Videos que salen en la guía del Bono Pa' Ti (en vez de la sección Videos)
ALTER TABLE videos ADD COLUMN seccion TEXT NOT NULL DEFAULT 'videos';
INSERT INTO videos (titulo,lugar,codigo,archivo,seccion,orden) SELECT 'Caja de Ahorros confirma su participación','Video','DeAvoR1RuE9','videos/DeAvoR1RuE9','bono',0
 WHERE NOT EXISTS (SELECT 1 FROM videos WHERE codigo='DeAvoR1RuE9');
