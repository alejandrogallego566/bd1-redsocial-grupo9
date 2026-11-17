/* =====================================================================
   DATOS DE EJEMPLO (inventados) - Red social estudiantil "Pascualina" - Grupo 9 - Tarea 5
   Se ejecuta en la base de datos pascualina, después de crear las tablas con Script_Tarea3_Grupo9.sql
   ===================================================================== */

TRUNCATE TABLE estudiante, habilidad, interes, lugar RESTART IDENTITY CASCADE;  -- Vacía las tablas y reinicia los ids en 1, para que los datos coincidan

INSERT INTO estudiante (nombre, apellido, correo, password_hash, programa_academico, estado)                      -- Inserta 8 estudiantes; el último está inactivo
VALUES ('Camila', 'Ríos', 'camila.rios@correo.edu.co', 'hash_demo_001', 'Desarrollo de Software', 'activo'),      -- Estudiante 1
       ('Daniel', 'Mora', 'daniel.mora@correo.edu.co', 'hash_demo_002', 'Desarrollo de Software', 'activo'),      -- Estudiante 2
       ('Sara', 'Gómez', 'sara.gomez@correo.edu.co', 'hash_demo_003', 'Diseño Gráfico', 'activo'),                -- Estudiante 3
       ('Andrés', 'Pérez', 'andres.perez@correo.edu.co', 'hash_demo_004', 'Desarrollo de Software', 'activo'),    -- Estudiante 4
       ('Laura', 'Torres', 'laura.torres@correo.edu.co', 'hash_demo_005', 'Electrónica', 'activo'),               -- Estudiante 5
       ('Julián', 'Castro', 'julian.castro@correo.edu.co', 'hash_demo_006', 'Desarrollo de Software', 'activo'),  -- Estudiante 6
       ('Valentina', 'Ruiz', 'valentina.ruiz@correo.edu.co', 'hash_demo_007', 'Diseño Gráfico', 'activo'),        -- Estudiante 7
       ('Mateo', 'Herrera', 'mateo.herrera@correo.edu.co', 'hash_demo_008', 'Electrónica', 'inactivo');           -- Estudiante 8, inactivo

INSERT INTO perfil (id_estudiante, biografia, semestre, area_estudio, ciudad)     -- Inserta 6 perfiles (los estudiantes 7 y 8 no tienen)
VALUES (1, 'Me gusta la programación', 7, 'Software', 'Medellín'),                -- Perfil de Camila
       (2, 'Me gustan los videojuegos', 5, 'Software', 'Medellín'),               -- Perfil de Daniel
       (3, 'Diseño interfaces', 3, 'Diseño', 'Envigado'),                         -- Perfil de Sara
       (4, 'Aprendiendo bases de datos', 4, 'Software', 'Medellín'),              -- Perfil de Andrés
       (5, 'Me interesa la inteligencia artificial', 2, 'Electrónica', 'Bello'),  -- Perfil de Laura
       (6, 'Me gusta Python', 6, 'Software', 'Medellín');                         -- Perfil de Julián

INSERT INTO habilidad (nombre, categoria)  -- Inserta 5 habilidades
VALUES ('Python', 'tecnica'),              -- Habilidad 1
       ('SQL', 'tecnica'),                 -- Habilidad 2
       ('Liderazgo', 'blanda'),            -- Habilidad 3
       ('Diseño UX', 'tecnica'),           -- Habilidad 4
       ('Fútbol', 'deportiva');            -- Habilidad 5

INSERT INTO interes (nombre, categoria)            -- Inserta 4 intereses
VALUES ('Programación competitiva', 'academico'),  -- Interés 1
       ('Videojuegos', 'ocio'),                    -- Interés 2
       ('Inteligencia artificial', 'academico'),   -- Interés 3
       ('Ajedrez', 'ocio');                        -- Interés 4

INSERT INTO estudiante_habilidad (id_estudiante, id_habilidad, nivel)  -- Asigna habilidades con su nivel
VALUES (1, 1, 'avanzado'), (1, 2, 'avanzado'), (1, 3, 'intermedio'),   -- Camila: Python, SQL y Liderazgo
       (2, 1, 'intermedio'), (2, 2, 'basico'),                         -- Daniel: Python y SQL
       (3, 4, 'avanzado'),                                             -- Sara: Diseño UX
       (4, 1, 'basico'), (4, 3, 'intermedio'),                         -- Andrés: Python y Liderazgo
       (5, 2, 'basico'),                                               -- Laura: SQL
       (6, 1, 'avanzado'), (6, 5, 'intermedio'),                       -- Julián: Python y Fútbol
       (7, 4, 'intermedio');                                           -- Valentina: Diseño UX

INSERT INTO estudiante_interes (id_estudiante, id_interes)  -- Asigna intereses a los estudiantes
VALUES (1, 1), (1, 3),                                      -- Camila: programación competitiva e IA
       (2, 1), (2, 2),                                      -- Daniel: programación competitiva y videojuegos
       (3, 2), (4, 1),                                      -- Sara: videojuegos; Andrés: programación competitiva
       (5, 3), (6, 1), (6, 4),                              -- Laura: IA; Julián: programación competitiva y ajedrez
       (7, 2), (8, 4);                                      -- Valentina: videojuegos; Mateo: ajedrez

INSERT INTO grupo (nombre, descripcion, tipo, estado, creador_id)                             -- Inserta 4 grupos, cada uno con su creador
VALUES ('Estudio de Bases de Datos', 'Repaso de la materia', 'estudio', 'activo', 1),         -- Grupo 1
       ('Equipo Hackatón Pascual', 'Preparación para la hackatón', 'hackaton', 'activo', 2),  -- Grupo 2
       ('Club de Videojuegos', 'Torneos entre estudiantes', 'club', 'activo', 3),             -- Grupo 3
       ('Club de Ajedrez', 'Partidas y torneos', 'club', 'cerrado', 4);                       -- Grupo 4, cerrado

INSERT INTO miembro_grupo (id_estudiante, id_grupo, rol)                          -- Inserta quién pertenece a cada grupo
VALUES (1, 1, 'admin'), (2, 1, 'miembro'), (3, 1, 'miembro'), (4, 1, 'miembro'),  -- Grupo 1 con 4 miembros
       (2, 2, 'admin'), (5, 2, 'miembro'), (6, 2, 'miembro'),                     -- Grupo 2 con 3 miembros
       (3, 3, 'admin'), (7, 3, 'miembro'),                                        -- Grupo 3 con 2 miembros
       (4, 4, 'admin'), (1, 4, 'miembro');                                        -- Grupo 4 con 2 miembros

INSERT INTO lugar (nombre, direccion)                   -- Inserta 3 lugares
VALUES ('Biblioteca central', 'Campus principal'),      -- Lugar 1
       ('Auditorio', 'Bloque 2'),                       -- Lugar 2
       ('Plataforma virtual', 'Enlace de la reunión');  -- Lugar 3

INSERT INTO evento (id_grupo, nombre, descripcion, fecha_inicio, fecha_fin, id_lugar, modalidad, organizador_id)      -- Inserta 5 eventos
VALUES (1, 'Repaso de normalización', 'Taller de 1FN a 3FN', '2026-11-05 14:00', '2026-11-05 16:00', 1, 'presencial', 1),  -- Evento 1, del grupo 1
       (2, 'Maratón de programación', 'Práctica para la hackatón', '2026-11-12 09:00', '2026-11-12 13:00', 2, 'presencial', 2),  -- Evento 2, del grupo 2
       (NULL, 'Charla de mentoría', 'Charla abierta', '2026-11-18 18:00', '2026-11-18 19:00', 3, 'virtual', 5),       -- Evento 3, sin grupo
       (3, 'Torneo de videojuegos', 'Torneo entre estudiantes', '2026-11-20 15:00', '2026-11-20 18:00', 2, 'presencial', 3),  -- Evento 4, del grupo 3
       (1, 'Taller de PostgreSQL', 'Práctica de consultas', '2026-11-25 10:00', '2026-11-25 12:00', 1, 'presencial', 1);  -- Evento 5, del grupo 1

INSERT INTO asistente_evento (id_estudiante, id_evento, estado)                                -- Inserta las inscripciones a los eventos
VALUES (1, 1, 'confirmado'), (2, 1, 'confirmado'), (3, 1, 'pendiente'), (4, 1, 'confirmado'),  -- Evento 1
       (2, 2, 'confirmado'), (5, 2, 'confirmado'), (6, 2, 'pendiente'),                        -- Evento 2
       (5, 3, 'confirmado'), (3, 3, 'cancelado'),                                              -- Evento 3
       (3, 4, 'confirmado'), (7, 4, 'confirmado'), (2, 4, 'pendiente'),                        -- Evento 4
       (1, 5, 'confirmado'), (2, 5, 'confirmado'), (4, 5, 'pendiente'), (6, 5, 'pendiente');   -- Evento 5

INSERT INTO publicacion (id_estudiante, contenido, tipo, fecha_publicacion)          -- Inserta 10 publicaciones con su fecha
VALUES (1, 'Apuntes de normalización', 'recurso', '2026-10-01 10:00'),               -- Publicación 1
       (1, '¿Alguien me explica la 3FN?', 'pregunta', '2026-10-02 11:30'),           -- Publicación 2
       (1, 'Resumen de PostgreSQL', 'recurso', '2026-10-05 09:15'),                  -- Publicación 3
       (2, 'Tips para la hackatón', 'noticia', '2026-10-06 16:00'),                  -- Publicación 4
       (2, 'Meme de bases de datos', 'meme', '2026-10-07 20:10'),                    -- Publicación 5
       (3, 'Torneo de videojuegos el viernes', 'noticia', '2026-10-08 12:00'),       -- Publicación 6
       (4, 'Dudas sobre la tarea 3', 'pregunta', '2026-10-09 18:45'),                -- Publicación 7
       (6, 'Recursos de Python para principiantes', 'recurso', '2026-10-10 08:30'),  -- Publicación 8
       (6, 'Nueva versión de PostgreSQL', 'noticia', '2026-10-12 14:20'),            -- Publicación 9
       (7, 'Meme de diseño', 'meme', '2026-10-13 21:05');                            -- Publicación 10

INSERT INTO comentario (id_publicacion, id_estudiante, comentario)  -- Inserta 8 comentarios
VALUES (1, 2, 'Yo tengo, te los paso'),                             -- Daniel en la publicación 1
       (2, 1, 'Con gusto te explico'),                              -- Camila en la publicación 2
       (2, 4, 'A mí también me sirve'),                             -- Andrés en la publicación 2
       (3, 6, 'Gracias por compartir'),                             -- Julián en la publicación 3
       (5, 1, 'Jajaja muy bueno'),                                  -- Camila en la publicación 5
       (5, 3, 'Excelente'),                                         -- Sara en la publicación 5
       (8, 2, 'Muy útil'),                                          -- Daniel en la publicación 8
       (7, 5, 'Yo te ayudo');                                       -- Laura en la publicación 7

INSERT INTO reaccion (id_estudiante, id_publicacion, tipo_reaccion)  -- Inserta 11 reacciones
VALUES (2, 1, 'me_sirve'), (3, 1, 'me_gusta'), (4, 1, 'me_sirve'),   -- Reacciones a la publicación 1
       (1, 4, 'me_gusta'), (5, 4, 'me_gusta'),                       -- Reacciones a la publicación 4
       (1, 8, 'me_sirve'), (2, 8, 'me_sirve'), (4, 8, 'me_sirve'),   -- Reacciones a la publicación 8
       (3, 5, 'me_divierte'), (7, 5, 'me_divierte'),                 -- Reacciones a la publicación 5
       (1, 6, 'me_gusta');                                           -- Reacción a la publicación 6

INSERT INTO seguir (id_seguidor, id_seguido)  -- Inserta 9 seguimientos
VALUES (2, 1), (3, 1), (4, 1), (5, 1),        -- Cuatro estudiantes siguen a Camila
       (6, 2), (1, 2),                        -- Julián y Camila siguen a Daniel
       (7, 3), (4, 6), (5, 6);                -- Otros seguimientos

INSERT INTO mentoria (id_mentor, id_aprendiz, estado)  -- Inserta 3 mentorías
VALUES (1, 5, 'activa'), (6, 4, 'activa'),             -- Camila mentora de Laura; Julián mentor de Andrés
       (1, 3, 'terminada');                            -- Camila fue mentora de Sara
