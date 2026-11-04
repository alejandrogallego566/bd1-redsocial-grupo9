/* =====================================================================
   RED SOCIAL ESTUDIANTIL "PASCUALINA" - Modelo físico en MySQL (DDL)
   Base de Datos I - Grupo 9 - Tarea 4
   Integrantes: Andry Zharick Mariño Moreno y Alejandro Gallego Velásquez
   16 tablas del modelo lógico, 22 llaves foráneas y 2 campos JSON (datos semiestructurados)
   Nombres: minúsculas, con guion bajo, en singular y sin tildes
   Restricciones: pk_ (primaria), fk_ (foránea), uk_ (única), ck_ (regla de valores)
   Requiere MySQL 8.0.16 o más nuevo (por los DEFAULT de fecha y las reglas CHECK)
   ===================================================================== */

-- BASE DE DATOS
CREATE DATABASE IF NOT EXISTS pascualina DEFAULT CHARACTER SET utf8mb4;  -- Crea la base de datos (utf8mb4 guarda tildes y emojis)
USE pascualina;                                                          -- Selecciona la base de datos para trabajar en ella

-- 0. LIMPIEZA: borra las tablas si ya existen (primero las hijas)
DROP TABLE IF EXISTS mentoria;              -- Borra mentoria si existe
DROP TABLE IF EXISTS seguir;                -- Borra seguir si existe
DROP TABLE IF EXISTS reaccion;              -- Borra reaccion si existe
DROP TABLE IF EXISTS comentario;            -- Borra comentario si existe
DROP TABLE IF EXISTS publicacion;           -- Borra publicacion si existe
DROP TABLE IF EXISTS asistente_evento;      -- Borra asistente_evento si existe
DROP TABLE IF EXISTS evento;                -- Borra evento si existe
DROP TABLE IF EXISTS lugar;                 -- Borra lugar si existe
DROP TABLE IF EXISTS miembro_grupo;         -- Borra miembro_grupo si existe
DROP TABLE IF EXISTS grupo;                 -- Borra grupo si existe
DROP TABLE IF EXISTS estudiante_interes;    -- Borra estudiante_interes si existe
DROP TABLE IF EXISTS estudiante_habilidad;  -- Borra estudiante_habilidad si existe
DROP TABLE IF EXISTS interes;               -- Borra interes si existe
DROP TABLE IF EXISTS habilidad;             -- Borra habilidad si existe
DROP TABLE IF EXISTS perfil;                -- Borra perfil si existe
DROP TABLE IF EXISTS estudiante;            -- Borra estudiante si existe

-- 1. TABLA ESTUDIANTE
CREATE TABLE estudiante (                                                     -- Tabla: cada usuario de la red social
    id_estudiante INT NOT NULL AUTO_INCREMENT,                                -- Identificador del estudiante (automático)
    nombre VARCHAR(50) NOT NULL,                                              -- Nombre
    apellido VARCHAR(50) NOT NULL,                                            -- Apellido
    correo VARCHAR(100) NOT NULL,                                             -- Correo institucional, no se repite
    password_hash VARCHAR(255) NOT NULL,                                      -- Contraseña guardada cifrada
    programa_academico VARCHAR(80) NOT NULL,                                  -- Carrera que estudia
    fecha_registro DATE NOT NULL DEFAULT (CURRENT_DATE),                      -- Día en que se registró
    ultima_actividad DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,             -- Última vez que entró
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',                             -- Cuenta activa o inactiva
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante),                     -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_estudiante_correo UNIQUE (correo),                          -- No puede haber dos cuentas con el mismo correo
    CONSTRAINT ck_estudiante_estado CHECK (estado IN ('activo', 'inactivo'))  -- Solo permite 'activo' o 'inactivo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                                      -- Fin de la tabla estudiante

-- 2. TABLA PERFIL
CREATE TABLE perfil (                                                 -- Tabla: foto, biografía y datos del perfil
    id_perfil INT NOT NULL AUTO_INCREMENT,                            -- Identificador del perfil (automático)
    id_estudiante INT NOT NULL,                                       -- Estudiante dueño del perfil
    foto VARCHAR(255),                                                -- Link de la foto
    biografia TEXT,                                                   -- Texto libre sobre el estudiante
    semestre INT,                                                     -- Semestre que cursa
    area_estudio VARCHAR(80),                                         -- Área de estudio
    ciudad VARCHAR(60),                                               -- Ciudad donde vive
    fecha_actualizacion DATE NOT NULL DEFAULT (CURRENT_DATE),         -- Última vez que editó el perfil
    CONSTRAINT pk_perfil PRIMARY KEY (id_perfil),                     -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_perfil_estudiante UNIQUE (id_estudiante),           -- Un estudiante no puede tener dos perfiles
    CONSTRAINT ck_perfil_semestre CHECK (semestre BETWEEN 1 AND 12),  -- El semestre debe estar entre 1 y 12
    CONSTRAINT fk_perfil_estudiante FOREIGN KEY (id_estudiante)       -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                         -- Tabla a la que apunta
        ON DELETE CASCADE                                             -- Si se borra el estudiante, se borra su perfil
        ON UPDATE CASCADE                                             -- Si cambia el id, el cambio se copia aquí
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                              -- Fin de la tabla perfil

-- 3. TABLA HABILIDAD
CREATE TABLE habilidad (                                -- Tabla: catálogo de habilidades
    id_habilidad INT NOT NULL AUTO_INCREMENT,           -- Identificador de la habilidad (automático)
    nombre VARCHAR(60) NOT NULL,                        -- Nombre de la habilidad
    categoria VARCHAR(40) NOT NULL,                     -- Técnica, blanda, deportiva
    CONSTRAINT pk_habilidad PRIMARY KEY (id_habilidad)  -- Llave primaria: no se repite ni queda vacía
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                -- Fin de la tabla habilidad

-- 4. TABLA INTERES
CREATE TABLE interes (                              -- Tabla: catálogo de intereses
    id_interes INT NOT NULL AUTO_INCREMENT,         -- Identificador del interés (automático)
    nombre VARCHAR(60) NOT NULL,                    -- Nombre del interés
    categoria VARCHAR(40) NOT NULL,                 -- Académico, deportivo, ocio
    CONSTRAINT pk_interes PRIMARY KEY (id_interes)  -- Llave primaria: no se repite ni queda vacía
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;            -- Fin de la tabla interes

-- 5. TABLA ESTUDIANTE_HABILIDAD
CREATE TABLE estudiante_habilidad (                                            -- Tabla: habilidades de cada estudiante y su nivel
    id_estudiante_habilidad INT NOT NULL AUTO_INCREMENT,                       -- Identificador del registro (automático)
    id_estudiante INT NOT NULL,                                                -- Estudiante que tiene la habilidad
    id_habilidad INT NOT NULL,                                                 -- Habilidad que tiene
    nivel VARCHAR(20) NOT NULL DEFAULT 'basico',                               -- Básico, intermedio o avanzado
    fecha_agregado DATE NOT NULL DEFAULT (CURRENT_DATE),                       -- Día en que la agregó
    CONSTRAINT pk_estudiante_habilidad PRIMARY KEY (id_estudiante_habilidad),  -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_est_hab UNIQUE (id_estudiante, id_habilidad),                -- No se repite la misma habilidad en un estudiante
    CONSTRAINT fk_est_hab_estudiante FOREIGN KEY (id_estudiante)               -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                                  -- Tabla a la que apunta
        ON DELETE CASCADE                                                      -- Si se borra el estudiante, se borran sus habilidades
        ON UPDATE CASCADE,                                                     -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_est_hab_habilidad FOREIGN KEY (id_habilidad)                 -- Apunta a habilidad
        REFERENCES habilidad (id_habilidad)                                    -- Tabla a la que apunta
        ON DELETE RESTRICT                                                     -- No deja borrar una habilidad que se está usando
        ON UPDATE CASCADE                                                      -- Si cambia el id, el cambio se copia aquí
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                                       -- Fin de la tabla estudiante_habilidad

-- 6. TABLA ESTUDIANTE_INTERES
CREATE TABLE estudiante_interes (                                          -- Tabla: intereses de cada estudiante
    id_estudiante_interes INT NOT NULL AUTO_INCREMENT,                     -- Identificador del registro (automático)
    id_estudiante INT NOT NULL,                                            -- Estudiante que tiene el interés
    id_interes INT NOT NULL,                                               -- Interés que tiene
    fecha_agregado DATE NOT NULL DEFAULT (CURRENT_DATE),                   -- Día en que lo agregó
    CONSTRAINT pk_estudiante_interes PRIMARY KEY (id_estudiante_interes),  -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_est_int UNIQUE (id_estudiante, id_interes),              -- No se repite el mismo interés en un estudiante
    CONSTRAINT fk_est_int_estudiante FOREIGN KEY (id_estudiante)           -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                              -- Tabla a la que apunta
        ON DELETE CASCADE                                                  -- Si se borra el estudiante, se borran sus intereses
        ON UPDATE CASCADE,                                                 -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_est_int_interes FOREIGN KEY (id_interes)                 -- Apunta a interes
        REFERENCES interes (id_interes)                                    -- Tabla a la que apunta
        ON DELETE RESTRICT                                                 -- No deja borrar un interés que se está usando
        ON UPDATE CASCADE                                                  -- Si cambia el id, el cambio se copia aquí
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                                   -- Fin de la tabla estudiante_interes

-- 7. TABLA GRUPO
CREATE TABLE grupo (                                      -- Tabla: grupos de estudio, equipos y clubes
    id_grupo INT NOT NULL AUTO_INCREMENT,                 -- Identificador del grupo (automático)
    nombre VARCHAR(80) NOT NULL,                          -- Nombre del grupo
    descripcion TEXT,                                     -- De qué trata el grupo
    tipo VARCHAR(30) NOT NULL,                            -- Estudio, hackatón o club
    fecha_creacion DATE NOT NULL DEFAULT (CURRENT_DATE),  -- Día en que se creó
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',         -- Grupo activo o cerrado
    creador_id INT NOT NULL,                              -- Estudiante que lo creó
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),           -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT fk_grupo_creador FOREIGN KEY (creador_id)  -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)             -- Tabla a la que apunta
        ON DELETE RESTRICT                                -- No deja borrar a un estudiante que creó un grupo
        ON UPDATE CASCADE                                 -- Si cambia el id, el cambio se copia aquí
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                  -- Fin de la tabla grupo

-- 8. TABLA MIEMBRO_GRUPO
CREATE TABLE miembro_grupo (                                        -- Tabla: qué estudiante está en qué grupo y su rol
    id_miembro INT NOT NULL AUTO_INCREMENT,                         -- Identificador de la membresía (automático)
    id_estudiante INT NOT NULL,                                     -- Estudiante que está en el grupo
    id_grupo INT NOT NULL,                                          -- Grupo al que pertenece
    fecha_ingreso DATE NOT NULL DEFAULT (CURRENT_DATE),             -- Día en que entró
    rol VARCHAR(20) NOT NULL DEFAULT 'miembro',                     -- Miembro o admin
    CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_miembro),           -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_miembro UNIQUE (id_estudiante, id_grupo),         -- Nadie entra dos veces al mismo grupo
    CONSTRAINT ck_miembro_rol CHECK (rol IN ('miembro', 'admin')),  -- Solo permite 'miembro' o 'admin'
    CONSTRAINT fk_miembro_estudiante FOREIGN KEY (id_estudiante)    -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                       -- Tabla a la que apunta
        ON DELETE CASCADE                                           -- Si se borra el estudiante, se borran sus membresías
        ON UPDATE CASCADE,                                          -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_miembro_grupo FOREIGN KEY (id_grupo)              -- Apunta a grupo
        REFERENCES grupo (id_grupo)                                 -- Tabla a la que apunta
        ON DELETE CASCADE                                           -- Si se borra el grupo, se borran sus membresías
        ON UPDATE CASCADE                                           -- Si cambia el id, el cambio se copia aquí
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                            -- Fin de la tabla miembro_grupo

-- 9. TABLA LUGAR
CREATE TABLE lugar (                            -- Tabla: sitios donde se hacen los eventos
    id_lugar INT NOT NULL AUTO_INCREMENT,       -- Identificador del lugar (automático)
    nombre VARCHAR(80) NOT NULL,                -- Nombre del sitio
    direccion VARCHAR(150) NOT NULL,            -- Dirección o ubicación
    datos_iot JSON,                             -- coordenadas y lecturas de sensores del lugar (JSON)
    CONSTRAINT pk_lugar PRIMARY KEY (id_lugar)  -- Llave primaria: no se repite ni queda vacía
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;        -- Fin de la tabla lugar

-- 10. TABLA EVENTO
CREATE TABLE evento (                                               -- Tabla: reuniones, talleres y actividades
    id_evento INT NOT NULL AUTO_INCREMENT,                          -- Identificador del evento (automático)
    id_grupo INT,                                                   -- Grupo que lo organiza (puede quedar vacío)
    nombre VARCHAR(80) NOT NULL,                                    -- Nombre del evento
    descripcion TEXT,                                               -- De qué trata el evento
    fecha_inicio DATETIME NOT NULL,                                 -- Fecha y hora de inicio
    fecha_fin DATETIME NOT NULL,                                    -- Fecha y hora de fin
    id_lugar INT NOT NULL,                                          -- Lugar del evento
    modalidad VARCHAR(20) NOT NULL DEFAULT 'presencial',            -- Presencial o virtual
    organizador_id INT NOT NULL,                                    -- Estudiante responsable
    CONSTRAINT pk_evento PRIMARY KEY (id_evento),                   -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT ck_evento_fechas CHECK (fecha_fin >= fecha_inicio),  -- El evento no puede terminar antes de empezar
    CONSTRAINT fk_evento_grupo FOREIGN KEY (id_grupo)               -- Apunta a grupo
        REFERENCES grupo (id_grupo)                                 -- Tabla a la que apunta
        ON DELETE SET NULL                                          -- Si se borra el grupo, el evento queda sin grupo
        ON UPDATE CASCADE,                                          -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_evento_lugar FOREIGN KEY (id_lugar)               -- Apunta a lugar
        REFERENCES lugar (id_lugar)                                 -- Tabla a la que apunta
        ON DELETE RESTRICT                                          -- No deja borrar un lugar con eventos
        ON UPDATE CASCADE,                                          -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_evento_organizador FOREIGN KEY (organizador_id)   -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                       -- Tabla a la que apunta
        ON DELETE RESTRICT                                          -- No deja borrar al organizador de un evento
        ON UPDATE CASCADE                                           -- Si cambia el id, el cambio se copia aquí
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                            -- Fin de la tabla evento

-- 11. TABLA ASISTENTE_EVENTO
CREATE TABLE asistente_evento (                                     -- Tabla: quién se inscribió a qué evento
    id_asistente INT NOT NULL AUTO_INCREMENT,                       -- Identificador de la inscripción (automático)
    id_estudiante INT NOT NULL,                                     -- Estudiante que se inscribe
    id_evento INT NOT NULL,                                         -- Evento al que se inscribe
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente',                -- Pendiente, confirmado o cancelado
    fecha_registro DATE NOT NULL DEFAULT (CURRENT_DATE),            -- Día en que se inscribió
    CONSTRAINT pk_asistente_evento PRIMARY KEY (id_asistente),      -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_asistente UNIQUE (id_estudiante, id_evento),      -- Nadie se inscribe dos veces al mismo evento
    CONSTRAINT fk_asistente_estudiante FOREIGN KEY (id_estudiante)  -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                       -- Tabla a la que apunta
        ON DELETE CASCADE                                           -- Si se borra el estudiante, se borran sus inscripciones
        ON UPDATE CASCADE,                                          -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_asistente_evento FOREIGN KEY (id_evento)          -- Apunta a evento
        REFERENCES evento (id_evento)                               -- Tabla a la que apunta
        ON DELETE CASCADE                                           -- Si se borra el evento, se borran sus inscripciones
        ON UPDATE CASCADE                                           -- Si cambia el id, el cambio se copia aquí
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                            -- Fin de la tabla asistente_evento

-- 12. TABLA PUBLICACION
CREATE TABLE publicacion (                                            -- Tabla: preguntas, recursos, noticias y memes
    id_publicacion INT NOT NULL AUTO_INCREMENT,                       -- Identificador de la publicación (automático)
    id_estudiante INT NOT NULL,                                       -- Autor de la publicación
    contenido TEXT NOT NULL,                                          -- Texto de la publicación
    tipo VARCHAR(20) NOT NULL,                                        -- Pregunta, recurso, noticia o meme
    fecha_publicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,    -- Fecha y hora de publicación
    metadatos JSON,                                                   -- etiquetas, enlaces y dispositivo de la publicación (JSON)
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),           -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT fk_publicacion_estudiante FOREIGN KEY (id_estudiante)  -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                         -- Tabla a la que apunta
        ON DELETE CASCADE                                             -- Si se borra el estudiante, se borran sus publicaciones
        ON UPDATE CASCADE                                             -- Si cambia el id, el cambio se copia aquí
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                              -- Fin de la tabla publicacion

-- 13. TABLA COMENTARIO
CREATE TABLE comentario (                                              -- Tabla: comentarios de las publicaciones
    id_comentario INT NOT NULL AUTO_INCREMENT,                         -- Identificador del comentario (automático)
    id_publicacion INT NOT NULL,                                       -- Publicación que se comenta
    id_estudiante INT NOT NULL,                                        -- Estudiante que comenta
    comentario TEXT NOT NULL,                                          -- Texto del comentario
    fecha_comentario DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,      -- Fecha y hora del comentario
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),              -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion)  -- Apunta a publicacion
        REFERENCES publicacion (id_publicacion)                        -- Tabla a la que apunta
        ON DELETE CASCADE                                              -- Si se borra la publicación, se borran sus comentarios
        ON UPDATE CASCADE,                                             -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_comentario_estudiante FOREIGN KEY (id_estudiante)    -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                          -- Tabla a la que apunta
        ON DELETE CASCADE                                              -- Si se borra el estudiante, se borran sus comentarios
        ON UPDATE CASCADE                                              -- Si cambia el id, el cambio se copia aquí
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                               -- Fin de la tabla comentario

-- 14. TABLA REACCION
CREATE TABLE reaccion (                                              -- Tabla: reacciones a las publicaciones
    id_reaccion INT NOT NULL AUTO_INCREMENT,                         -- Identificador de la reacción (automático)
    id_estudiante INT NOT NULL,                                      -- Estudiante que reacciona
    id_publicacion INT NOT NULL,                                     -- Publicación que recibe la reacción
    tipo_reaccion VARCHAR(20) NOT NULL DEFAULT 'me_gusta',           -- Me gusta, me sirve, etc.
    fecha_reaccion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,      -- Fecha y hora de la reacción
    CONSTRAINT pk_reaccion PRIMARY KEY (id_reaccion),                -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_reaccion UNIQUE (id_estudiante, id_publicacion),   -- Una reacción por estudiante en cada publicación
    CONSTRAINT fk_reaccion_estudiante FOREIGN KEY (id_estudiante)    -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                        -- Tabla a la que apunta
        ON DELETE CASCADE                                            -- Si se borra el estudiante, se borran sus reacciones
        ON UPDATE CASCADE,                                           -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_reaccion_publicacion FOREIGN KEY (id_publicacion)  -- Apunta a publicacion
        REFERENCES publicacion (id_publicacion)                      -- Tabla a la que apunta
        ON DELETE CASCADE                                            -- Si se borra la publicación, se borran sus reacciones
        ON UPDATE CASCADE                                            -- Si cambia el id, el cambio se copia aquí
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                             -- Fin de la tabla reaccion

-- 15. TABLA SEGUIR
CREATE TABLE seguir (                                        -- Tabla: quién sigue a quién
    id_seguir INT NOT NULL AUTO_INCREMENT,                   -- Identificador del seguimiento (automático)
    id_seguidor INT NOT NULL,                                -- Estudiante que sigue
    id_seguido INT NOT NULL,                                 -- Estudiante que es seguido
    fecha_seguimiento DATE NOT NULL DEFAULT (CURRENT_DATE),  -- Día en que empezó a seguirlo
    CONSTRAINT pk_seguir PRIMARY KEY (id_seguir),            -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_seguir UNIQUE (id_seguidor, id_seguido),   -- No se sigue dos veces a la misma persona
    CONSTRAINT fk_seguir_seguidor FOREIGN KEY (id_seguidor)  -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                -- Tabla a la que apunta
        ON DELETE CASCADE                                    -- Si se borra el seguidor, se borran sus seguimientos
        ON UPDATE CASCADE,                                   -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_seguir_seguido FOREIGN KEY (id_seguido)    -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                -- Tabla a la que apunta
        ON DELETE CASCADE                                    -- Si se borra el seguido, se borran los seguimientos hacia él
        ON UPDATE CASCADE                                    -- Si cambia el id, el cambio se copia aquí
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                     -- Fin de la tabla seguir

-- 16. TABLA MENTORIA
CREATE TABLE mentoria (                                        -- Tabla: mentorías entre estudiantes
    id_mentoria INT NOT NULL AUTO_INCREMENT,                   -- Identificador de la mentoría (automático)
    id_mentor INT NOT NULL,                                    -- Estudiante mentor
    id_aprendiz INT NOT NULL,                                  -- Estudiante aprendiz
    fecha_inicio DATE NOT NULL DEFAULT (CURRENT_DATE),         -- Día en que empezó
    estado VARCHAR(20) NOT NULL DEFAULT 'activa',              -- Activa, pausada o terminada
    CONSTRAINT pk_mentoria PRIMARY KEY (id_mentoria),          -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT fk_mentoria_mentor FOREIGN KEY (id_mentor)      -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                  -- Tabla a la que apunta
        ON DELETE CASCADE                                      -- Si se borra el mentor, se borran sus mentorías
        ON UPDATE CASCADE,                                     -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_mentoria_aprendiz FOREIGN KEY (id_aprendiz)  -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                  -- Tabla a la que apunta
        ON DELETE CASCADE                                      -- Si se borra el aprendiz, se borran sus mentorías
        ON UPDATE CASCADE                                      -- Si cambia el id, el cambio se copia aquí
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;                       -- Fin de la tabla mentoria

-- 17. PRUEBA DE LOS CAMPOS JSON (datos de ejemplo inventados)
INSERT INTO estudiante (nombre, apellido, correo, password_hash, programa_academico)           -- Inserta un estudiante de ejemplo
VALUES ('Camila', 'Ríos', 'camila.rios@correo.edu.co', 'hash_demo_001', 'Software');           -- Su id será 1 porque la tabla es nueva
INSERT INTO lugar (nombre, direccion, datos_iot)                                               -- Inserta un lugar con su JSON de coordenadas y sensores
VALUES ('Biblioteca central', 'Campus principal',                                              -- Nombre y dirección del lugar
        '{"coordenadas": {"lat": 6.2442, "lng": -75.5812}, "sensores": {"aforo": 35, "temperatura": 24.5}}');-- JSON: ubicación y lecturas de los sensores
INSERT INTO publicacion (id_estudiante, contenido, tipo, metadatos)                            -- Inserta una publicación con su JSON de metadatos
VALUES (1, 'Un recurso útil de bases de datos', 'recurso',                                     -- Autor 1, texto y tipo
        '{"etiquetas": ["sql", "bases_de_datos"], "enlace": "https://ejemplo.com/recurso", "dispositivo": "movil"}');-- JSON: etiquetas, enlace y dispositivo
SELECT nombre, datos_iot->>'$.sensores.aforo' AS aforo FROM lugar;                             -- Lee un dato dentro del JSON (->> devuelve texto)
SELECT contenido, metadatos->>'$.dispositivo' AS dispositivo FROM publicacion WHERE metadatos->>'$.dispositivo' = 'movil';-- Filtra publicaciones por un dato del JSON
SELECT table_name FROM information_schema.tables WHERE table_schema = 'pascualina' ORDER BY table_name;-- Lista las tablas creadas (deben salir 16)
