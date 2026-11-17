/* BORRADOR INICIAL - Andry Zharick Mariño Moreno - Tarea 5 - Grupo 9
   Red social estudiantil Pascualina - consultas y vistas en PostgreSQL
   Todavía sin la versión final: alias sin unificar y pocos comentarios */

/* Tablas, campos y tipos que uso:
   interes (id_interes SERIAL, nombre VARCHAR(60))
   estudiante_interes (id_estudiante INTEGER, id_interes INTEGER)
   evento (id_evento SERIAL, nombre VARCHAR(80)), asistente_evento (id_asistente SERIAL, id_evento INTEGER, estado VARCHAR(20))
   estudiante (id_estudiante SERIAL, nombre VARCHAR(50), apellido VARCHAR(50), programa_academico VARCHAR(80))
   publicacion (id_publicacion SERIAL, id_estudiante INTEGER), comentario (id_comentario SERIAL, id_estudiante INTEGER)
   perfil (id_estudiante INTEGER, semestre INTEGER, ciudad VARCHAR(60)) */

-- Consulta 1: cuántos estudiantes tienen cada interés
SELECT i.nombre, COUNT(*) AS total
FROM interes i JOIN estudiante_interes ei ON ei.id_interes = i.id_interes
GROUP BY i.nombre;

-- Consulta 2: asistentes por evento
SELECT ev.nombre, COUNT(a.id_asistente) AS asistentes
FROM evento ev LEFT JOIN asistente_evento a ON a.id_evento = ev.id_evento
GROUP BY ev.nombre;

-- Consulta 3: publicaciones y comentarios por estudiante
SELECT e.nombre, COUNT(p.id_publicacion) AS pubs, COUNT(c.id_comentario) AS coms
FROM estudiante e LEFT JOIN publicacion p ON p.id_estudiante = e.id_estudiante
LEFT JOIN comentario c ON c.id_estudiante = e.id_estudiante
GROUP BY e.nombre;

-- Vista 1: perfiles de estudiantes
CREATE VIEW vista_perfiles AS
SELECT e.id_estudiante, e.nombre, e.programa_academico, pf.semestre, pf.ciudad
FROM estudiante e JOIN perfil pf ON pf.id_estudiante = e.id_estudiante;

-- Vista 2: eventos con su lugar
CREATE VIEW vista_eventos AS
SELECT ev.nombre AS evento, l.nombre AS lugar, ev.fecha_inicio
FROM evento ev JOIN lugar l ON l.id_lugar = ev.id_lugar;
