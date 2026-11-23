/* =====================================================================
   RED SOCIAL ESTUDIANTIL "PASCUALINA" - Arquitectura híbrida (relacional + JSONB + IoT) en PostgreSQL
   Base de Datos I - Grupo 9 - Tarea 6 (VERSIÓN FINAL)
   Integrantes: Andry Zharick Mariño Moreno y Alejandro Gallego Velásquez
   ===================================================================== */

-- ============ PARTE 1: DDL ============
-- Limpieza: borra las tablas nuevas si ya existen (las 16 tablas anteriores no se tocan)
DROP TABLE IF EXISTS lectura_sensor CASCADE;  -- Borra lectura_sensor y sus particiones
DROP TABLE IF EXISTS sensor CASCADE;          -- Borra sensor
DROP TABLE IF EXISTS log_actividad CASCADE;   -- Borra log_actividad

-- 1. Campo JSONB en publicacion
ALTER TABLE publicacion                                                              -- Agrega a publicacion un campo semiestructurado
    ADD COLUMN IF NOT EXISTS metadatos JSONB                                         -- metadatos: etiquetas, adjuntos y dispositivo en formato JSONB
    CONSTRAINT ck_publicacion_metadatos CHECK (jsonb_typeof(metadatos) = 'object');  -- Obliga a que sea un objeto JSON (con llaves), no un texto suelto

-- 2. Tabla sensor
CREATE TABLE sensor (                                                                   -- Tabla de los sensores IoT instalados en el campus
    id_sensor SERIAL,                                                                   -- Número que identifica al sensor (automático)
    id_lugar INTEGER NOT NULL,                                                          -- Lugar donde está instalado; llave foránea; obligatorio
    tipo VARCHAR(30) NOT NULL,                                                          -- Tipo de sensor (aforo o temperatura); obligatorio
    modelo VARCHAR(60),                                                                 -- Modelo del aparato; opcional
    activo BOOLEAN NOT NULL DEFAULT TRUE,                                               -- Si el sensor está funcionando; por defecto sí
    configuracion JSONB,                                                                -- Configuración del sensor en JSONB (intervalo y ubicación); opcional
    fecha_instalacion DATE NOT NULL DEFAULT CURRENT_DATE,                               -- Día de instalación; por defecto, hoy
    CONSTRAINT pk_sensor PRIMARY KEY (id_sensor),                                       -- Llave primaria: id_sensor no se repite ni queda vacía
    CONSTRAINT ck_sensor_tipo CHECK (tipo IN ('aforo', 'temperatura')),                 -- Solo permite sensores de aforo o de temperatura
    CONSTRAINT ck_sensor_configuracion CHECK (jsonb_typeof(configuracion) = 'object'),  -- La configuración debe ser un objeto JSON
    CONSTRAINT fk_sensor_lugar FOREIGN KEY (id_lugar)                                   -- Llave foránea: id_lugar apunta a lugar
        REFERENCES lugar (id_lugar)                                                     -- Tabla a la que apunta
        ON DELETE RESTRICT                                                              -- No deja borrar un lugar que tiene sensores
        ON UPDATE CASCADE                                                               -- Si cambia el id del lugar, el cambio pasa aquí
);                                                                                      -- Fin de la tabla sensor

-- 3. Tabla lectura_sensor (particionada por mes)
CREATE TABLE lectura_sensor (                                                -- Tabla de lecturas de los sensores; crece muy rápido, por eso se particiona
    id_lectura BIGSERIAL,                                                    -- Número de la lectura; BIGSERIAL porque habrá muchísimas filas
    id_sensor INTEGER NOT NULL,                                              -- Sensor que midió; llave foránea; obligatorio
    fecha_hora TIMESTAMP NOT NULL,                                           -- Fecha y hora de la medición; es la columna de partición
    valores JSONB NOT NULL,                                                  -- Lo que midió, en JSONB, porque cada tipo de sensor manda datos distintos
    CONSTRAINT pk_lectura_sensor PRIMARY KEY (id_lectura, fecha_hora),       -- Llave primaria; en una tabla particionada debe incluir la fecha
    CONSTRAINT ck_lectura_valores CHECK (jsonb_typeof(valores) = 'object'),  -- Los valores deben ser un objeto JSON
    CONSTRAINT fk_lectura_sensor FOREIGN KEY (id_sensor)                     -- Llave foránea: id_sensor apunta a sensor
        REFERENCES sensor (id_sensor)                                        -- Tabla a la que apunta
        ON DELETE CASCADE                                                    -- Si se borra el sensor, se borran sus lecturas
        ON UPDATE CASCADE                                                    -- Si cambia el id del sensor, el cambio pasa aquí
) PARTITION BY RANGE (fecha_hora);                                           -- Divide la tabla en partes (una por mes) según la fecha
CREATE TABLE lectura_sensor_2026_11 PARTITION OF lectura_sensor              -- Partición de noviembre de 2026
    FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');                        -- Guarda las lecturas desde el 1 de noviembre hasta antes del 1 de diciembre
CREATE TABLE lectura_sensor_2026_12 PARTITION OF lectura_sensor              -- Partición de diciembre de 2026
    FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');                        -- Guarda las lecturas de diciembre

-- 4. Tabla log_actividad
CREATE TABLE log_actividad (                                             -- Tabla del registro de actividad de los estudiantes
    id_log BIGSERIAL,                                                    -- Número del registro; BIGSERIAL porque habrá muchísimos
    id_estudiante INTEGER NOT NULL,                                      -- Estudiante que hizo la acción; llave foránea; obligatorio
    accion VARCHAR(40) NOT NULL,                                         -- Qué hizo (inicio_sesion, ver_publicacion...); obligatorio
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,             -- Cuándo lo hizo; por defecto, ahora
    detalle JSONB,                                                       -- Datos de la acción en JSONB (dispositivo, duración...); opcional
    CONSTRAINT pk_log_actividad PRIMARY KEY (id_log),                    -- Llave primaria: id_log no se repite ni queda vacía
    CONSTRAINT ck_log_detalle CHECK (jsonb_typeof(detalle) = 'object'),  -- El detalle debe ser un objeto JSON
    CONSTRAINT fk_log_estudiante FOREIGN KEY (id_estudiante)             -- Llave foránea: id_estudiante apunta a estudiante
        REFERENCES estudiante (id_estudiante)                            -- Tabla a la que apunta
        ON DELETE CASCADE                                                -- Si se borra el estudiante, se borra su registro de actividad
        ON UPDATE CASCADE                                                -- Si cambia el id del estudiante, el cambio pasa aquí
);                                                                       -- Fin de la tabla log_actividad

-- 5. Índices (GIN para buscar dentro del JSON)
CREATE INDEX IF NOT EXISTS idx_publicacion_metadatos ON publicacion USING GIN (metadatos jsonb_path_ops);  -- Índice GIN: búsquedas rápidas dentro de metadatos con @>
CREATE INDEX idx_lectura_sensor_sensor_fecha ON lectura_sensor (id_sensor, fecha_hora);                  -- Búsquedas rápidas por sensor y rango de fechas
CREATE INDEX idx_lectura_sensor_valores ON lectura_sensor USING GIN (valores);                           -- Índice GIN: búsquedas rápidas dentro de valores
CREATE INDEX idx_log_actividad_detalle ON log_actividad USING GIN (detalle);                             -- Índice GIN: búsquedas rápidas dentro de detalle
CREATE INDEX idx_log_actividad_estudiante ON log_actividad (id_estudiante, fecha_hora);                  -- Búsquedas rápidas por estudiante y fecha

-- ============ PARTE 2: DATOS DE EJEMPLO (inventados) ============
UPDATE publicacion AS p                                                                                  -- Llena el JSON de las 10 publicaciones de ejemplo
SET metadatos = v.meta::jsonb                                                                            -- Convierte el texto en JSONB y lo guarda
FROM (VALUES                                                                                             -- Lista de pares (id de publicación, JSON)
    (1, '{"etiquetas": ["normalizacion", "bases_de_datos"], "dispositivo": "web", "adjuntos": [{"tipo": "pdf"}]}'),  -- Publicación 1
    (2, '{"etiquetas": ["3fn", "normalizacion"], "dispositivo": "movil"}'),                              -- Publicación 2
    (3, '{"etiquetas": ["postgresql", "bases_de_datos"], "dispositivo": "web", "adjuntos": [{"tipo": "pdf"}]}'),  -- Publicación 3
    (4, '{"etiquetas": ["hackaton", "programacion"], "dispositivo": "movil"}'),                          -- Publicación 4
    (5, '{"etiquetas": ["meme", "bases_de_datos"], "dispositivo": "movil", "adjuntos": [{"tipo": "imagen"}]}'),  -- Publicación 5
    (6, '{"etiquetas": ["videojuegos", "torneo"], "dispositivo": "web"}'),                               -- Publicación 6
    (7, '{"etiquetas": ["tarea", "bases_de_datos"], "dispositivo": "movil"}'),                           -- Publicación 7
    (8, '{"etiquetas": ["python", "programacion"], "dispositivo": "web"}'),                              -- Publicación 8
    (9, '{"etiquetas": ["postgresql", "noticias"], "dispositivo": "web"}'),                              -- Publicación 9
    (10, '{"etiquetas": ["meme", "diseno"], "dispositivo": "movil", "adjuntos": [{"tipo": "imagen"}]}')  -- Publicación 10
) AS v(id, meta)                                                                                         -- Nombres de las columnas de la lista
WHERE p.id_publicacion = v.id;                                                                           -- Une cada JSON con su publicación por el id
INSERT INTO sensor (id_lugar, tipo, modelo, configuracion)                                               -- Inserta 3 sensores de ejemplo
VALUES (1, 'aforo', 'Contador infrarrojo CI-100', '{"intervalo_minutos": 10, "ubicacion": {"lat": 6.2442, "lng": -75.5812, "piso": 1}}'),  -- Sensor 1: aforo de la biblioteca
       (2, 'aforo', 'Contador infrarrojo CI-100', '{"intervalo_minutos": 10, "ubicacion": {"lat": 6.2447, "lng": -75.5807, "piso": 1}}'),  -- Sensor 2: aforo del auditorio
       (1, 'temperatura', 'Termómetro TH-20', '{"intervalo_minutos": 10, "ubicacion": {"lat": 6.2442, "lng": -75.5812, "piso": 1}}');  -- Sensor 3: temperatura de la biblioteca
INSERT INTO lectura_sensor (id_sensor, fecha_hora, valores)                                              -- Inserta una lectura cada 10 minutos de noviembre para los sensores de aforo
SELECT s.id_sensor, t.ts,                                                                                -- Un registro por cada sensor y cada momento
       jsonb_build_object('aforo', (EXTRACT(HOUR FROM t.ts)::int * 3 + s.id_sensor * 5) % 40, 'unidad', 'personas')  -- Arma el JSON: el aforo depende de la hora (datos de ejemplo)
FROM sensor s                                                                                            -- Parte de la tabla sensor
CROSS JOIN generate_series('2026-11-01 00:00'::timestamp, '2026-11-30 23:50'::timestamp, INTERVAL '10 minutes') AS t(ts)  -- Combina cada sensor con cada momento (cada 10 minutos)
WHERE s.tipo = 'aforo';                                                                                  -- Solo para los sensores de aforo
INSERT INTO lectura_sensor (id_sensor, fecha_hora, valores)                                              -- Inserta las lecturas del sensor de temperatura
SELECT s.id_sensor, t.ts,                                                                                -- Un registro por cada sensor y cada momento
       jsonb_build_object('temperatura', 20 + ((EXTRACT(MINUTE FROM t.ts)::int / 10 + s.id_sensor) % 8) * 0.5, 'humedad', 50 + EXTRACT(HOUR FROM t.ts)::int % 10)  -- JSON con temperatura y humedad (datos de ejemplo)
FROM sensor s                                                                                            -- Parte de la tabla sensor
CROSS JOIN generate_series('2026-11-01 00:00'::timestamp, '2026-11-30 23:50'::timestamp, INTERVAL '10 minutes') AS t(ts)  -- Combina cada sensor con cada momento (cada 10 minutos)
WHERE s.tipo = 'temperatura';                                                                            -- Solo para los sensores de temperatura
INSERT INTO log_actividad (id_estudiante, accion, fecha_hora, detalle)                                   -- Inserta 12 registros de actividad de ejemplo
VALUES (1, 'inicio_sesion', '2026-11-02 08:00', '{"dispositivo": "web"}'),                               -- Acción 1: inicio_sesion
       (1, 'ver_publicacion', '2026-11-02 08:05', '{"dispositivo": "web", "duracion_segundos": 40}'),    -- Acción 2: ver_publicacion
       (2, 'inicio_sesion', '2026-11-02 09:10', '{"dispositivo": "movil"}'),                             -- Acción 3: inicio_sesion
       (2, 'ver_publicacion', '2026-11-02 09:12', '{"dispositivo": "movil", "duracion_segundos": 25}'),  -- Acción 4: ver_publicacion
       (2, 'comentar', '2026-11-02 09:15', '{"dispositivo": "movil", "publicacion_id": 2}'),             -- Acción 5: comentar
       (3, 'inicio_sesion', '2026-11-03 10:00', '{"dispositivo": "movil"}'),                             -- Acción 6: inicio_sesion
       (3, 'ver_publicacion', '2026-11-03 10:03', '{"dispositivo": "movil", "duracion_segundos": 60}'),  -- Acción 7: ver_publicacion
       (4, 'inicio_sesion', '2026-11-03 11:20', '{"dispositivo": "web"}'),                               -- Acción 8: inicio_sesion
       (4, 'ver_publicacion', '2026-11-03 11:25', '{"dispositivo": "web", "duracion_segundos": 90}'),    -- Acción 9: ver_publicacion
       (4, 'crear_publicacion', '2026-11-03 11:40', '{"dispositivo": "web"}'),                           -- Acción 10: crear_publicacion
       (5, 'ver_publicacion', '2026-11-04 15:00', '{"dispositivo": "movil", "duracion_segundos": 30}'),  -- Acción 11: ver_publicacion
       (6, 'ver_publicacion', '2026-11-04 16:30', '{"dispositivo": "movil", "duracion_segundos": 55}');  -- Acción 12: ver_publicacion

-- ============ PARTE 3: CONSULTAS CON DATOS SEMIESTRUCTURADOS ============

-- CONSULTA 1: ¿Cuáles son las 5 etiquetas más usadas en las publicaciones?
SELECT t.etiqueta,                                                                       -- Nombre de la etiqueta
       COUNT(*) AS total_publicaciones                                                   -- Cuántas publicaciones la usan
FROM publicacion p                                                                       -- Parte de la tabla publicacion
CROSS JOIN LATERAL jsonb_array_elements_text(p.metadatos -> 'etiquetas') AS t(etiqueta)  -- Abre la lista de etiquetas del JSON: una fila por etiqueta
GROUP BY t.etiqueta                                                                      -- Agrupa por etiqueta para contar
ORDER BY total_publicaciones DESC, t.etiqueta                                            -- De la más usada a la menos usada
LIMIT 5;                                                                                 -- Muestra solo las 5 primeras

-- CONSULTA 2: ¿Cuántas publicaciones hizo cada estudiante desde un celular?
SELECT e.nombre || ' ' || e.apellido AS autor,          -- Nombre completo del autor
       COUNT(*) AS total_publicaciones_movil            -- Cuántas publicaciones hizo desde el celular
FROM publicacion p                                      -- Parte de la tabla publicacion
JOIN estudiante e ON e.id_estudiante = p.id_estudiante  -- Une con el autor por id_estudiante
WHERE p.metadatos @> '{"dispositivo": "movil"}'         -- Solo las publicaciones cuyo JSON contiene dispositivo = movil
GROUP BY e.id_estudiante, e.nombre, e.apellido          -- Agrupa por autor para contar
ORDER BY total_publicaciones_movil DESC, autor;         -- De más a menos publicaciones

-- CONSULTA 3: ¿Cuál es el aforo promedio y el máximo de cada lugar durante noviembre?
SELECT l.nombre AS lugar,                                                   -- Nombre del lugar
       COUNT(*) AS total_lecturas,                                          -- Cuántas lecturas hay
       ROUND(AVG((lc.valores ->> 'aforo')::numeric), 1) AS promedio_aforo,  -- Promedio del aforo con 1 decimal; ->> saca el dato como texto y :: lo vuelve número
       MAX((lc.valores ->> 'aforo')::int) AS maximo_aforo                   -- El aforo más alto registrado
FROM lectura_sensor lc                                                      -- Parte de la tabla de lecturas
JOIN sensor s ON s.id_sensor = lc.id_sensor                                 -- Une con el sensor que midió
JOIN lugar l ON l.id_lugar = s.id_lugar                                     -- Une con el lugar donde está el sensor
WHERE s.tipo = 'aforo'                                                      -- Solo sensores de aforo
  AND lc.fecha_hora >= '2026-11-01' AND lc.fecha_hora < '2026-12-01'        -- Solo noviembre: PostgreSQL revisa únicamente esa partición
GROUP BY l.nombre                                                           -- Agrupa por lugar
ORDER BY promedio_aforo DESC;                                               -- Del lugar más lleno al menos lleno

-- CONSULTA 4: ¿A qué horas del día hay más gente en la biblioteca?
SELECT EXTRACT(HOUR FROM lc.fecha_hora)::int AS hora,                      -- Hora del día (0 a 23) de cada lectura
       ROUND(AVG((lc.valores ->> 'aforo')::numeric), 1) AS promedio_aforo  -- Aforo promedio en esa hora
FROM lectura_sensor lc                                                     -- Parte de la tabla de lecturas
JOIN sensor s ON s.id_sensor = lc.id_sensor                                -- Une con el sensor
JOIN lugar l ON l.id_lugar = s.id_lugar                                    -- Une con el lugar
WHERE l.nombre = 'Biblioteca central' AND s.tipo = 'aforo'                 -- Solo el sensor de aforo de la biblioteca
GROUP BY EXTRACT(HOUR FROM lc.fecha_hora)::int                             -- Agrupa por hora
ORDER BY promedio_aforo DESC, hora                                         -- De la hora más llena a la menos llena
LIMIT 3;                                                                   -- Muestra solo las 3 horas más llenas

-- CONSULTA 5: ¿Qué eventos presenciales se harán en lugares con poca gente según la última lectura del sensor?
WITH ultima_lectura AS (                                            -- Tabla temporal con la última lectura de cada sensor
    SELECT DISTINCT ON (lc.id_sensor) lc.id_sensor, lc.fecha_hora,  -- Se queda con una sola fila por sensor
           (lc.valores ->> 'aforo')::int AS aforo                   -- Saca el aforo del JSON como número
    FROM lectura_sensor lc                                          -- Parte de la tabla de lecturas
    WHERE lc.valores ->> 'aforo' IS NOT NULL                        -- Solo lecturas que traen el dato aforo
    ORDER BY lc.id_sensor, lc.fecha_hora DESC)                      -- Dentro de cada sensor, primero la lectura más reciente
SELECT ev.nombre AS evento,                                         -- Nombre del evento
       l.nombre AS lugar,                                           -- Lugar del evento
       ul.aforo AS aforo_actual,                                    -- Aforo de la última lectura de ese lugar
       ul.fecha_hora AS momento_lectura                             -- Cuándo se midió
FROM evento ev                                                      -- Parte de la tabla evento
JOIN lugar l ON l.id_lugar = ev.id_lugar                            -- Une con el lugar del evento
JOIN sensor s ON s.id_lugar = l.id_lugar AND s.tipo = 'aforo'       -- Une con el sensor de aforo de ese lugar
JOIN ultima_lectura ul ON ul.id_sensor = s.id_sensor                -- Une con su última lectura
WHERE ev.modalidad = 'presencial'                                   -- Solo eventos presenciales
ORDER BY ul.aforo, ev.fecha_inicio;                                 -- Primero los lugares con menos gente

-- CONSULTA 6: ¿Qué acciones hacen más los estudiantes, desde qué dispositivo, y cuánto tiempo suman?
SELECT l.accion,                                                                     -- Qué acción hicieron
       l.detalle ->> 'dispositivo' AS dispositivo,                                   -- Dispositivo, sacado del JSON detalle
       COUNT(*) AS total_acciones,                                                   -- Cuántas veces se hizo
       COUNT(DISTINCT e.id_estudiante) AS total_estudiantes,                         -- Cuántos estudiantes distintos la hicieron
       COALESCE(SUM((l.detalle ->> 'duracion_segundos')::int), 0) AS total_segundos  -- Suma de segundos; si no hay duración, 0
FROM log_actividad l                                                                 -- Parte de la tabla de registros
JOIN estudiante e ON e.id_estudiante = l.id_estudiante                               -- Une con el estudiante
GROUP BY l.accion, l.detalle ->> 'dispositivo'                                       -- Agrupa por acción y dispositivo
ORDER BY total_acciones DESC, l.accion, dispositivo;                                 -- De la más frecuente a la menos frecuente

-- ============ PARTE 4: OPTIMIZACIÓN Y CAPACIDAD ============
SELECT COUNT(*) AS total_lecturas FROM lectura_sensor;                                                   -- Cuenta todas las lecturas guardadas (la capacidad de almacenamiento)
SELECT tableoid::regclass AS particion, COUNT(*) AS total_lecturas FROM lectura_sensor GROUP BY particion ORDER BY particion;  -- Muestra en qué partición está cada lectura
ANALYZE lectura_sensor;                                                                                  -- Actualiza las estadísticas para que PostgreSQL planee mejor
EXPLAIN ANALYZE SELECT COUNT(*) FROM lectura_sensor WHERE id_sensor = 1 AND fecha_hora >= '2026-11-10' AND fecha_hora < '2026-11-11';  -- Muestra el plan: solo revisa la partición de noviembre y usa el índice
