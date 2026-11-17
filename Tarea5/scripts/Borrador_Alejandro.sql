/* BORRADOR INICIAL - Alejandro Gallego Velásquez - Tarea 5 - Grupo 9 */


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
