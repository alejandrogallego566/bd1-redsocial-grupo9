/* BORRADOR INICIAL - Alejandro Gallego Velásquez - Tarea 5 - Grupo 9
   Red social estudiantil Pascualina - consultas y vistas en PostgreSQL
   Todavía sin la versión final: alias sin unificar y pocos comentarios */

/* Tablas, campos y tipos que uso:
   habilidad (id_habilidad SERIAL, nombre VARCHAR(60)), estudiante_habilidad (id_estudiante INTEGER, id_habilidad INTEGER, nivel VARCHAR(20))
   estudiante (id_estudiante SERIAL, nombre VARCHAR(50), apellido VARCHAR(50), estado VARCHAR(20))
   asistente_evento (id_asistente SERIAL, id_estudiante INTEGER, estado VARCHAR(20))
   perfil (id_estudiante INTEGER, semestre INTEGER), mentoria (id_mentor INTEGER, id_aprendiz INTEGER, estado VARCHAR(20))
   publicacion (id_publicacion SERIAL, tipo VARCHAR(20), fecha_publicacion TIMESTAMP), grupo (id_grupo SERIAL, nombre VARCHAR(80), tipo VARCHAR(30), estado VARCHAR(20)) */

-- Consulta 4: cuántos estudiantes tienen cada habilidad
SELECT h.nombre, COUNT(*) AS total
FROM habilidad h JOIN estudiante_habilidad eh ON eh.id_habilidad = h.id_habilidad
GROUP BY h.nombre;

-- Consulta 5: estudiantes que no se han inscrito a ningún evento
SELECT e.nombre
FROM estudiante e LEFT JOIN asistente_evento a ON a.id_estudiante = e.id_estudiante
WHERE a.id_asistente IS NULL;

-- Consulta 6: estudiantes de semestre 6 o más
SELECT e.nombre, pf.semestre
FROM estudiante e JOIN perfil pf ON pf.id_estudiante = e.id_estudiante
WHERE pf.semestre >= 6;

-- Vista 3: publicaciones
CREATE VIEW vista_publicaciones AS
SELECT p.id_publicacion, p.tipo, p.fecha_publicacion
FROM publicacion p;

-- Vista 4: grupos
CREATE VIEW vista_grupos AS
SELECT g.id_grupo, g.nombre AS grupo, g.tipo, g.estado
FROM grupo g;
