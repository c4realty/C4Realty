-- Bases extra ("gavetas") para fotos y documentos: c4realty-fotos-1 … c4realty-fotos-9 (enlaces FOTOS1 … FOTOS9).
-- Cada una aguanta 500 MB gratis; la página pasa sola a la siguiente cuando una se llena.
CREATE TABLE IF NOT EXISTS archivo_partes (archivo_id INTEGER NOT NULL, n INTEGER NOT NULL, datos TEXT NOT NULL, PRIMARY KEY (archivo_id, n));
