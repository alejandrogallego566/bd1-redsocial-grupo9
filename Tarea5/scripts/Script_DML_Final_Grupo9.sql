/* =====================================================================
   RED SOCIAL ESTUDIANTIL "PASCUALINA" - Consultas DML y vistas en PostgreSQL
   Base de Datos I - Grupo 9 - Tarea 5 
   Integrantes: Andry Zharick Mariño Moreno y Alejandro Gallego Velásquez
   Se ejecuta en la base de datos pascualina, después de Script_Tarea3_Grupo9.sql y 00_Datos_Ejemplo_Grupo9.sql
   Contiene 6 consultas (parte 1) y 4 vistas con su consulta (parte 2)
   ===================================================================== */

-- ============ PARTE 1: CONSULTAS ============

-- CONSULTA 1: ¿Cuántos estudiantes activos están interesados en cada interés, y cuál es el más popular?
SELECT i.nombre AS interes,                                 -- Nombre del interés (tabla interes)
       COUNT(e.id_estudiante) AS total_estudiantes          -- Cuenta cuántos estudiantes activos tiene cada interés
FROM interes i                                              -- Parte de la tabla interes
JOIN estudiante_interes ei ON ei.id_interes = i.id_interes  -- Une con la tabla intermedia por id_interes
JOIN estudiante e ON e.id_estudiante = ei.id_estudiante     -- Une con estudiante por id_estudiante
WHERE e.estado = 'activo'                                   -- Deja solo a los estudiantes con la cuenta activa
GROUP BY i.nombre                                           -- Agrupa por interés para poder contar
ORDER BY total_estudiantes DESC, interes;                   -- Del más popular al menos popular; si empatan, por nombre

-- CONSULTA 2: ¿Cuántos asistentes confirmados tiene cada evento y qué porcentaje del total de confirmados representa?
SELECT ev.nombre AS evento,                                                                         -- Nombre del evento
       l.nombre AS lugar,                                                                           -- Nombre del lugar donde se hace
       COUNT(a.id_asistente) AS total_confirmados,                                                  -- Cuenta los asistentes confirmados de cada evento
       ROUND(100.0 * COUNT(a.id_asistente) / SUM(COUNT(a.id_asistente)) OVER (), 1) AS porcentaje_del_total  -- Qué parte del total de confirmados es, con 1 decimal
FROM evento ev                                                                                      -- Parte de la tabla evento
JOIN lugar l ON l.id_lugar = ev.id_lugar                                                            -- Une con lugar por id_lugar
LEFT JOIN asistente_evento a ON a.id_evento = ev.id_evento AND a.estado = 'confirmado'              -- LEFT JOIN: trae también los eventos sin confirmados
GROUP BY ev.id_evento, ev.nombre, l.nombre                                                          -- Agrupa por evento para contar
ORDER BY total_confirmados DESC, evento;                                                            -- De más a menos confirmados; si empatan, por nombre

-- CONSULTA 3: ¿Quiénes son los 5 estudiantes más activos, sumando sus publicaciones y sus comentarios?
WITH publicaciones_por_estudiante AS (                                                              -- Tabla temporal 1: publicaciones de cada estudiante
    SELECT id_estudiante, COUNT(*) AS total_publicaciones                                           -- Cuenta las publicaciones por estudiante
    FROM publicacion                                                                                -- Usando la tabla publicacion
    GROUP BY id_estudiante),                                                                        -- Agrupado por estudiante
comentarios_por_estudiante AS (                                                                     -- Tabla temporal 2: comentarios de cada estudiante
    SELECT id_estudiante, COUNT(*) AS total_comentarios                                             -- Cuenta los comentarios por estudiante
    FROM comentario                                                                                 -- Usando la tabla comentario
    GROUP BY id_estudiante)                                                                         -- Agrupado por estudiante
SELECT e.nombre || ' ' || e.apellido AS estudiante,                                                 -- Une nombre y apellido en una sola columna
       COALESCE(p.total_publicaciones, 0) AS total_publicaciones,                                   -- Publicaciones; si no tiene, muestra 0
       COALESCE(c.total_comentarios, 0) AS total_comentarios,                                       -- Comentarios; si no tiene, muestra 0
       COALESCE(p.total_publicaciones, 0) + COALESCE(c.total_comentarios, 0) AS total_interacciones -- Suma de publicaciones y comentarios
FROM estudiante e                                                                                   -- Parte de la tabla estudiante
LEFT JOIN publicaciones_por_estudiante p ON p.id_estudiante = e.id_estudiante                       -- Trae sus publicaciones, aunque no tenga
LEFT JOIN comentarios_por_estudiante c ON c.id_estudiante = e.id_estudiante                         -- Trae sus comentarios, aunque no tenga
ORDER BY total_interacciones DESC, estudiante                                                       -- Del más activo al menos activo
LIMIT 5;                                                                                            -- Muestra solo los 5 primeros

-- CONSULTA 4: ¿Qué habilidades tienen al menos 2 estudiantes y cuál es el nivel promedio de dominio de cada una?
SELECT h.nombre AS habilidad,                                     -- Nombre de la habilidad
       COUNT(eh.id_estudiante) AS total_estudiantes,              -- Cuántos estudiantes la tienen
       ROUND(AVG(CASE eh.nivel                                    -- Promedio del nivel, con 2 decimales; CASE pasa el texto a número
                     WHEN 'basico' THEN 1                         -- Básico vale 1
                     WHEN 'intermedio' THEN 2                     -- Intermedio vale 2
                     WHEN 'avanzado' THEN 3                       -- Avanzado vale 3
                END), 2) AS promedio_nivel                        -- Cierra el CASE y el promedio
FROM habilidad h                                                  -- Parte de la tabla habilidad
JOIN estudiante_habilidad eh ON eh.id_habilidad = h.id_habilidad  -- Une con los estudiantes que la tienen
GROUP BY h.nombre                                                 -- Agrupa por habilidad
HAVING COUNT(eh.id_estudiante) >= 2                               -- Deja solo las habilidades con 2 estudiantes o más
ORDER BY promedio_nivel DESC, habilidad;                          -- De mayor a menor nivel promedio

-- CONSULTA 5: ¿Qué estudiantes no han confirmado su asistencia a ningún evento?
SELECT e.nombre || ' ' || e.apellido AS estudiante,  -- Nombre completo del estudiante
       e.programa_academico AS programa,             -- Carrera que estudia
       e.estado                                      -- Si su cuenta está activa o inactiva
FROM estudiante e                                    -- Parte de la tabla estudiante
WHERE NOT EXISTS (                                   -- Deja solo a los estudiantes para los que NO existe lo siguiente
    SELECT 1                                         -- No importa qué columna traiga, solo si existe la fila
    FROM asistente_evento a                          -- Revisa la tabla de inscripciones
    WHERE a.id_estudiante = e.id_estudiante          -- Inscripciones de este mismo estudiante
      AND a.estado = 'confirmado')                   -- Que estén confirmadas
ORDER BY estudiante;                                 -- Ordena por nombre

-- CONSULTA 6: ¿Qué estudiantes de semestre 6 o más tienen habilidades avanzadas y podrían ser mentores, y a cuántos aprendices acompañan ahora?
SELECT e.nombre || ' ' || e.apellido AS mentor_potencial,                                     -- Nombre completo del posible mentor
       pf.semestre,                                                                           -- Semestre que cursa (tabla perfil)
       COUNT(DISTINCT eh.id_habilidad) AS total_habilidades_avanzadas,                        -- Cuántas habilidades avanzadas tiene
       COUNT(DISTINCT m.id_aprendiz) AS total_aprendices_activos                              -- A cuántos aprendices acompaña ahora
FROM estudiante e                                                                             -- Parte de la tabla estudiante
JOIN perfil pf ON pf.id_estudiante = e.id_estudiante                                          -- Une con su perfil para saber el semestre
JOIN estudiante_habilidad eh ON eh.id_estudiante = e.id_estudiante AND eh.nivel = 'avanzado'  -- Une solo con sus habilidades avanzadas
LEFT JOIN mentoria m ON m.id_mentor = e.id_estudiante AND m.estado = 'activa'                 -- LEFT JOIN: incluye también a quien aún no tiene aprendices
WHERE pf.semestre >= 6                                                                        -- Solo semestre 6 o más
GROUP BY e.id_estudiante, e.nombre, e.apellido, pf.semestre                                   -- Agrupa por estudiante para contar
ORDER BY total_aprendices_activos DESC, mentor_potencial;                                     -- Primero los que más aprendices tienen

-- ============ PARTE 2: VISTAS ============

-- VISTA 1: Perfil de estudiantes con sus intereses
CREATE OR REPLACE VIEW vista_perfil_intereses AS                                               -- Crea la vista (o la reemplaza si ya existe)
SELECT e.id_estudiante,                                                                        -- Id del estudiante
       e.nombre || ' ' || e.apellido AS estudiante,                                            -- Nombre completo
       e.programa_academico AS programa,                                                       -- Carrera
       pf.semestre,                                                                            -- Semestre (tabla perfil)
       pf.ciudad,                                                                              -- Ciudad (tabla perfil)
       COALESCE(STRING_AGG(i.nombre, ', ' ORDER BY i.nombre), 'Sin intereses') AS intereses,   -- Junta sus intereses en un solo texto
       COUNT(i.id_interes) AS total_intereses                                                  -- Cuántos intereses tiene
FROM estudiante e                                                                              -- Parte de la tabla estudiante
LEFT JOIN perfil pf ON pf.id_estudiante = e.id_estudiante                                      -- Trae el perfil, aunque no tenga
LEFT JOIN estudiante_interes ei ON ei.id_estudiante = e.id_estudiante                          -- Trae sus intereses, aunque no tenga
LEFT JOIN interes i ON i.id_interes = ei.id_interes                                            -- Trae el nombre de cada interés
GROUP BY e.id_estudiante, e.nombre, e.apellido, e.programa_academico, pf.semestre, pf.ciudad;  -- Agrupa para tener una fila por estudiante

-- Consulta a la vista vista_perfil_intereses
SELECT estudiante, programa, intereses  -- Consulta a la vista: qué columnas mostrar
FROM vista_perfil_intereses             -- Se consulta como si fuera una tabla
ORDER BY estudiante;                    -- Ordena por nombre

-- VISTA 2: Resumen de eventos
CREATE OR REPLACE VIEW vista_resumen_eventos AS                                                     -- Crea la vista (o la reemplaza si ya existe)
SELECT ev.id_evento,                                                                                -- Id del evento
       ev.nombre AS evento,                                                                         -- Nombre del evento
       ev.fecha_inicio,                                                                             -- Cuándo empieza
       ev.modalidad,                                                                                -- Presencial o virtual
       l.nombre AS lugar,                                                                           -- Nombre del lugar
       COALESCE(g.nombre, 'Sin grupo') AS grupo,                                                    -- Grupo organizador; si no tiene, 'Sin grupo'
       o.nombre || ' ' || o.apellido AS organizador,                                                -- Nombre completo del organizador
       (SELECT COUNT(*) FROM asistente_evento a WHERE a.id_evento = ev.id_evento) AS total_inscritos,  -- Cuántos se inscribieron
       (SELECT COUNT(*) FROM asistente_evento a WHERE a.id_evento = ev.id_evento AND a.estado = 'confirmado') AS total_confirmados  -- Cuántos confirmaron
FROM evento ev                                                                                      -- Parte de la tabla evento
JOIN lugar l ON l.id_lugar = ev.id_lugar                                                            -- Une con el lugar
JOIN estudiante o ON o.id_estudiante = ev.organizador_id                                            -- Une con el organizador
LEFT JOIN grupo g ON g.id_grupo = ev.id_grupo;                                                      -- Trae el grupo, aunque el evento no tenga

-- Consulta a la vista vista_resumen_eventos
SELECT evento, lugar, grupo, total_inscritos, total_confirmados  -- Consulta a la vista: qué columnas mostrar
FROM vista_resumen_eventos                                       -- Se consulta como si fuera una tabla
ORDER BY fecha_inicio;                                           -- Del evento más próximo al más lejano

-- VISTA 3: Actividad de las publicaciones
CREATE OR REPLACE VIEW vista_actividad_publicaciones AS                                             -- Crea la vista (o la reemplaza si ya existe)
SELECT p.id_publicacion,                                                                            -- Id de la publicación
       e.nombre || ' ' || e.apellido AS autor,                                                      -- Nombre completo del autor
       p.tipo,                                                                                      -- Pregunta, recurso, noticia o meme
       p.fecha_publicacion,                                                                         -- Fecha y hora de publicación
       (SELECT COUNT(*) FROM comentario c WHERE c.id_publicacion = p.id_publicacion) AS total_comentarios,  -- Cuántos comentarios recibió
       (SELECT COUNT(*) FROM reaccion r WHERE r.id_publicacion = p.id_publicacion) AS total_reacciones  -- Cuántas reacciones recibió
FROM publicacion p                                                                                  -- Parte de la tabla publicacion
JOIN estudiante e ON e.id_estudiante = p.id_estudiante;                                             -- Une con el autor

-- Consulta a la vista vista_actividad_publicaciones
SELECT autor, tipo, total_comentarios, total_reacciones        -- Consulta a la vista: qué columnas mostrar
FROM vista_actividad_publicaciones                             -- Se consulta como si fuera una tabla
ORDER BY total_reacciones DESC, total_comentarios DESC, autor  -- Las que más reacciones recibieron primero
LIMIT 5;                                                       -- Solo las 5 primeras

-- VISTA 4: Resumen de grupos
CREATE OR REPLACE VIEW vista_resumen_grupos AS                                                  -- Crea la vista (o la reemplaza si ya existe)
SELECT g.id_grupo,                                                                              -- Id del grupo
       g.nombre AS grupo,                                                                       -- Nombre del grupo
       g.tipo,                                                                                  -- Estudio, hackatón o club
       g.estado,                                                                                -- Activo o cerrado
       c.nombre || ' ' || c.apellido AS creador,                                                -- Nombre completo del creador
       (SELECT COUNT(*) FROM miembro_grupo m WHERE m.id_grupo = g.id_grupo) AS total_miembros,  -- Cuántos miembros tiene
       (SELECT COUNT(*) FROM evento ev WHERE ev.id_grupo = g.id_grupo) AS total_eventos         -- Cuántos eventos ha organizado
FROM grupo g                                                                                    -- Parte de la tabla grupo
JOIN estudiante c ON c.id_estudiante = g.creador_id;                                            -- Une con el creador

-- Consulta a la vista vista_resumen_grupos
SELECT grupo, tipo, estado, total_miembros, total_eventos  -- Consulta a la vista: qué columnas mostrar
FROM vista_resumen_grupos                                  -- Se consulta como si fuera una tabla
ORDER BY total_miembros DESC, grupo;                       -- Del grupo con más miembros al que tiene menos

-- ============ PARTE 3: OPTIMIZACIÓN ============
-- Índices en las columnas que las consultas y vistas usan para unir tablas y filtrar
CREATE INDEX IF NOT EXISTS idx_asistente_evento_evento_estado ON asistente_evento (id_evento, estado);  -- Acelera la consulta 2 y la vista 2 (filtran por evento y estado)
CREATE INDEX IF NOT EXISTS idx_publicacion_estudiante ON publicacion (id_estudiante);               -- Acelera la consulta 3 (cuenta publicaciones por estudiante)
CREATE INDEX IF NOT EXISTS idx_comentario_publicacion ON comentario (id_publicacion);               -- Acelera la vista 3 (cuenta comentarios por publicación)
CREATE INDEX IF NOT EXISTS idx_reaccion_publicacion ON reaccion (id_publicacion);                   -- Acelera la vista 3 (cuenta reacciones por publicación)

-- Ver cómo ejecuta PostgreSQL una consulta y cuánto demora
EXPLAIN ANALYZE SELECT * FROM asistente_evento WHERE id_evento = 1 AND estado = 'confirmado';  -- Muestra el plan de ejecución y el tiempo real de la consulta

