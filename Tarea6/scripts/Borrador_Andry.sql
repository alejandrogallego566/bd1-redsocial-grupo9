/* BORRADOR INICIAL - Andry Zharick Mariño Moreno - Tarea 6 - Grupo 9
   Parte JSON: publicaciones y registro de actividad. Todavía sin la versión final */

/* Tablas y campos que uso:
   publicacion (id_publicacion SERIAL, id_estudiante INTEGER, tipo VARCHAR(20)) + metadatos JSONB (nuevo)
   log_actividad (id_log SERIAL, id_estudiante INTEGER, accion VARCHAR(40), fecha_hora TIMESTAMP, detalle TEXT) */

-- Campo JSONB en publicacion
ALTER TABLE publicacion ADD COLUMN IF NOT EXISTS metadatos JSONB;

-- Registro de actividad (el detalle lo guardo como texto)
CREATE TABLE log_actividad (
    id_log SERIAL PRIMARY KEY,
    id_estudiante INTEGER NOT NULL REFERENCES estudiante (id_estudiante),
    accion VARCHAR(40) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    detalle TEXT
);

-- Consulta 1: etiquetas más usadas
SELECT t.etiqueta, COUNT(*) AS total
FROM publicacion p CROSS JOIN LATERAL jsonb_array_elements_text(p.metadatos -> 'etiquetas') AS t(etiqueta)
GROUP BY t.etiqueta;

-- Consulta 2: publicaciones desde el celular
SELECT e.nombre, COUNT(*) AS moviles
FROM publicacion p JOIN estudiante e ON e.id_estudiante = p.id_estudiante
WHERE p.metadatos ->> 'dispositivo' = 'movil'
GROUP BY e.nombre;

-- Consulta 6: acciones por dispositivo (con el detalle en texto no puedo sacar el dispositivo)
SELECT accion, COUNT(*) AS total FROM log_actividad GROUP BY accion;
