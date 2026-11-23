/* BORRADOR INICIAL - Alejandro Gallego Velásquez - Tarea 6 - Grupo 9
   Parte IoT: sensores y lecturas. Todavía sin la versión final */

/* Tablas y campos que uso:
   sensor (id_sensor SERIAL, id_lugar INTEGER, tipo VARCHAR(30), modelo VARCHAR(60))
   lectura_sensor (id_lectura SERIAL, id_sensor INTEGER, fecha_hora TIMESTAMP, aforo INTEGER, temperatura NUMERIC(4,1), humedad INTEGER)
   lugar (id_lugar SERIAL, nombre VARCHAR(80)), evento (id_evento SERIAL, nombre VARCHAR(80), id_lugar INTEGER, modalidad VARCHAR(20)) */

-- Sensores
CREATE TABLE sensor (
    id_sensor SERIAL PRIMARY KEY,
    id_lugar INTEGER NOT NULL REFERENCES lugar (id_lugar),
    tipo VARCHAR(30) NOT NULL,
    modelo VARCHAR(60)
);

-- Lecturas: una columna por cada dato (aforo, temperatura y humedad)
CREATE TABLE lectura_sensor (
    id_lectura SERIAL PRIMARY KEY,
    id_sensor INTEGER NOT NULL REFERENCES sensor (id_sensor),
    fecha_hora TIMESTAMP NOT NULL,
    aforo INTEGER,
    temperatura NUMERIC(4,1),
    humedad INTEGER
);

-- Consulta 3: aforo promedio por lugar
SELECT l.nombre, AVG(lc.aforo) AS promedio
FROM lectura_sensor lc JOIN sensor s ON s.id_sensor = lc.id_sensor JOIN lugar l ON l.id_lugar = s.id_lugar
WHERE s.tipo = 'aforo'
GROUP BY l.nombre;

-- Consulta 4: aforo por hora en la biblioteca
SELECT EXTRACT(HOUR FROM lc.fecha_hora) AS hora, AVG(lc.aforo) AS promedio
FROM lectura_sensor lc JOIN sensor s ON s.id_sensor = lc.id_sensor JOIN lugar l ON l.id_lugar = s.id_lugar
WHERE l.nombre = 'Biblioteca central'
GROUP BY hora;

-- Consulta 5: eventos presenciales y el aforo de su lugar (promedio, todavía sin la última lectura)
SELECT ev.nombre, l.nombre AS lugar, AVG(lc.aforo) AS aforo
FROM evento ev JOIN lugar l ON l.id_lugar = ev.id_lugar JOIN sensor s ON s.id_lugar = l.id_lugar JOIN lectura_sensor lc ON lc.id_sensor = s.id_sensor
WHERE ev.modalidad = 'presencial'
GROUP BY ev.nombre, l.nombre;
