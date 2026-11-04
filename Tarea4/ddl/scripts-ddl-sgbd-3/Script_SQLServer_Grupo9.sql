/* =====================================================================
   RED SOCIAL ESTUDIANTIL "PASCUALINA" - Modelo físico en SQL Server (DDL)
   ===================================================================== */

-- BASE DE DATOS
IF DB_ID('pascualina') IS NULL CREATE DATABASE pascualina;  -- Crea la base de datos solo si todavía no existe
-- GO separa los bloques del script en SSMS
GO
USE pascualina;  -- Selecciona la base de datos para trabajar en ella
-- GO separa los bloques del script en SSMS
GO

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
    id_estudiante INT IDENTITY(1,1) NOT NULL,                                 -- Identificador del estudiante (automático)
    nombre NVARCHAR(50) NOT NULL,                                             -- Nombre
    apellido NVARCHAR(50) NOT NULL,                                           -- Apellido
    correo NVARCHAR(100) NOT NULL,                                            -- Correo institucional, no se repite
    password_hash NVARCHAR(255) NOT NULL,                                     -- Contraseña guardada cifrada
    programa_academico NVARCHAR(80) NOT NULL,                                 -- Carrera que estudia
    fecha_registro DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),           -- Día en que se registró
    ultima_actividad DATETIME2 NOT NULL DEFAULT SYSDATETIME(),                -- Última vez que entró
    estado NVARCHAR(20) NOT NULL DEFAULT 'activo',                            -- Cuenta activa o inactiva
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante),                     -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_estudiante_correo UNIQUE (correo),                          -- No puede haber dos cuentas con el mismo correo
    CONSTRAINT ck_estudiante_estado CHECK (estado IN ('activo', 'inactivo'))  -- Solo permite 'activo' o 'inactivo'
);                                                                            -- Fin de la tabla estudiante

-- 2. TABLA PERFIL
CREATE TABLE perfil (                                                     -- Tabla: foto, biografía y datos del perfil
    id_perfil INT IDENTITY(1,1) NOT NULL,                                 -- Identificador del perfil (automático)
    id_estudiante INT NOT NULL,                                           -- Estudiante dueño del perfil
    foto NVARCHAR(255),                                                   -- Link de la foto
    biografia NVARCHAR(MAX),                                              -- Texto libre sobre el estudiante
    semestre INT,                                                         -- Semestre que cursa
    area_estudio NVARCHAR(80),                                            -- Área de estudio
    ciudad NVARCHAR(60),                                                  -- Ciudad donde vive
    fecha_actualizacion DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),  -- Última vez que editó el perfil
    CONSTRAINT pk_perfil PRIMARY KEY (id_perfil),                         -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_perfil_estudiante UNIQUE (id_estudiante),               -- Un estudiante no puede tener dos perfiles
    CONSTRAINT ck_perfil_semestre CHECK (semestre BETWEEN 1 AND 12),      -- El semestre debe estar entre 1 y 12
    CONSTRAINT fk_perfil_estudiante FOREIGN KEY (id_estudiante)           -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                             -- Tabla a la que apunta
        ON DELETE CASCADE                                                 -- Si se borra el estudiante, se borra su perfil
        ON UPDATE NO ACTION                                               -- No se actualiza: el id es IDENTITY y no cambia
);                                                                        -- Fin de la tabla perfil

-- 3. TABLA HABILIDAD
CREATE TABLE habilidad (                                -- Tabla: catálogo de habilidades
    id_habilidad INT IDENTITY(1,1) NOT NULL,            -- Identificador de la habilidad (automático)
    nombre NVARCHAR(60) NOT NULL,                       -- Nombre de la habilidad
    categoria NVARCHAR(40) NOT NULL,                    -- Técnica, blanda, deportiva
    CONSTRAINT pk_habilidad PRIMARY KEY (id_habilidad)  -- Llave primaria: no se repite ni queda vacía
);                                                      -- Fin de la tabla habilidad

-- 4. TABLA INTERES
CREATE TABLE interes (                              -- Tabla: catálogo de intereses
    id_interes INT IDENTITY(1,1) NOT NULL,          -- Identificador del interés (automático)
    nombre NVARCHAR(60) NOT NULL,                   -- Nombre del interés
    categoria NVARCHAR(40) NOT NULL,                -- Académico, deportivo, ocio
    CONSTRAINT pk_interes PRIMARY KEY (id_interes)  -- Llave primaria: no se repite ni queda vacía
);                                                  -- Fin de la tabla interes

-- 5. TABLA ESTUDIANTE_HABILIDAD
CREATE TABLE estudiante_habilidad (                                            -- Tabla: habilidades de cada estudiante y su nivel
    id_estudiante_habilidad INT IDENTITY(1,1) NOT NULL,                        -- Identificador del registro (automático)
    id_estudiante INT NOT NULL,                                                -- Estudiante que tiene la habilidad
    id_habilidad INT NOT NULL,                                                 -- Habilidad que tiene
    nivel NVARCHAR(20) NOT NULL DEFAULT 'basico',                              -- Básico, intermedio o avanzado
    fecha_agregado DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),            -- Día en que la agregó
    CONSTRAINT pk_estudiante_habilidad PRIMARY KEY (id_estudiante_habilidad),  -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_est_hab UNIQUE (id_estudiante, id_habilidad),                -- No se repite la misma habilidad en un estudiante
    CONSTRAINT fk_est_hab_estudiante FOREIGN KEY (id_estudiante)               -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                                  -- Tabla a la que apunta
        ON DELETE CASCADE                                                      -- Si se borra el estudiante, se borran sus habilidades
        ON UPDATE NO ACTION,                                                   -- No se actualiza: el id es IDENTITY y no cambia
    CONSTRAINT fk_est_hab_habilidad FOREIGN KEY (id_habilidad)                 -- Apunta a habilidad
        REFERENCES habilidad (id_habilidad)                                    -- Tabla a la que apunta
        ON DELETE NO ACTION                                                    -- No deja borrar una habilidad que se está usando
        ON UPDATE NO ACTION                                                    -- No se actualiza: el id es IDENTITY y no cambia
);                                                                             -- Fin de la tabla estudiante_habilidad

-- 6. TABLA ESTUDIANTE_INTERES
CREATE TABLE estudiante_interes (                                          -- Tabla: intereses de cada estudiante
    id_estudiante_interes INT IDENTITY(1,1) NOT NULL,                      -- Identificador del registro (automático)
    id_estudiante INT NOT NULL,                                            -- Estudiante que tiene el interés
    id_interes INT NOT NULL,                                               -- Interés que tiene
    fecha_agregado DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),        -- Día en que lo agregó
    CONSTRAINT pk_estudiante_interes PRIMARY KEY (id_estudiante_interes),  -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_est_int UNIQUE (id_estudiante, id_interes),              -- No se repite el mismo interés en un estudiante
    CONSTRAINT fk_est_int_estudiante FOREIGN KEY (id_estudiante)           -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                              -- Tabla a la que apunta
        ON DELETE CASCADE                                                  -- Si se borra el estudiante, se borran sus intereses
        ON UPDATE NO ACTION,                                               -- No se actualiza: el id es IDENTITY y no cambia
    CONSTRAINT fk_est_int_interes FOREIGN KEY (id_interes)                 -- Apunta a interes
        REFERENCES interes (id_interes)                                    -- Tabla a la que apunta
        ON DELETE NO ACTION                                                -- No deja borrar un interés que se está usando
        ON UPDATE NO ACTION                                                -- No se actualiza: el id es IDENTITY y no cambia
);                                                                         -- Fin de la tabla estudiante_interes

-- 7. TABLA GRUPO
CREATE TABLE grupo (                                                 -- Tabla: grupos de estudio, equipos y clubes
    id_grupo INT IDENTITY(1,1) NOT NULL,                             -- Identificador del grupo (automático)
    nombre NVARCHAR(80) NOT NULL,                                    -- Nombre del grupo
    descripcion NVARCHAR(MAX),                                       -- De qué trata el grupo
    tipo NVARCHAR(30) NOT NULL,                                      -- Estudio, hackatón o club
    fecha_creacion DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),  -- Día en que se creó
    estado NVARCHAR(20) NOT NULL DEFAULT 'activo',                   -- Grupo activo o cerrado
    creador_id INT NOT NULL,                                         -- Estudiante que lo creó
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),                      -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT fk_grupo_creador FOREIGN KEY (creador_id)             -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                        -- Tabla a la que apunta
        ON DELETE NO ACTION                                          -- No deja borrar a un estudiante que creó un grupo
        ON UPDATE NO ACTION                                          -- No se actualiza: el id es IDENTITY y no cambia
);                                                                   -- Fin de la tabla grupo

-- 8. TABLA MIEMBRO_GRUPO
CREATE TABLE miembro_grupo (                                        -- Tabla: qué estudiante está en qué grupo y su rol
    id_miembro INT IDENTITY(1,1) NOT NULL,                          -- Identificador de la membresía (automático)
    id_estudiante INT NOT NULL,                                     -- Estudiante que está en el grupo
    id_grupo INT NOT NULL,                                          -- Grupo al que pertenece
    fecha_ingreso DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),  -- Día en que entró
    rol NVARCHAR(20) NOT NULL DEFAULT 'miembro',                    -- Miembro o admin
    CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_miembro),           -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_miembro UNIQUE (id_estudiante, id_grupo),         -- Nadie entra dos veces al mismo grupo
    CONSTRAINT ck_miembro_rol CHECK (rol IN ('miembro', 'admin')),  -- Solo permite 'miembro' o 'admin'
    CONSTRAINT fk_miembro_estudiante FOREIGN KEY (id_estudiante)    -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                       -- Tabla a la que apunta
        ON DELETE CASCADE                                           -- Si se borra el estudiante, se borran sus membresías
        ON UPDATE NO ACTION,                                        -- No se actualiza: el id es IDENTITY y no cambia
    CONSTRAINT fk_miembro_grupo FOREIGN KEY (id_grupo)              -- Apunta a grupo
        REFERENCES grupo (id_grupo)                                 -- Tabla a la que apunta
        ON DELETE CASCADE                                           -- Si se borra el grupo, se borran sus membresías
        ON UPDATE NO ACTION                                         -- No se actualiza: el id es IDENTITY y no cambia
);                                                                  -- Fin de la tabla miembro_grupo

-- 9. TABLA LUGAR
CREATE TABLE lugar (                                             -- Tabla: sitios donde se hacen los eventos
    id_lugar INT IDENTITY(1,1) NOT NULL,                         -- Identificador del lugar (automático)
    nombre NVARCHAR(80) NOT NULL,                                -- Nombre del sitio
    direccion NVARCHAR(150) NOT NULL,                            -- Dirección o ubicación
    datos_iot NVARCHAR(MAX),                                     -- coordenadas y lecturas de sensores del lugar (JSON)
    CONSTRAINT pk_lugar PRIMARY KEY (id_lugar),                  -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT ck_lugar_datos_iot CHECK (ISJSON(datos_iot) = 1)  -- Solo acepta texto que sea JSON válido
);                                                               -- Fin de la tabla lugar

-- 10. TABLA EVENTO
CREATE TABLE evento (                                               -- Tabla: reuniones, talleres y actividades
    id_evento INT IDENTITY(1,1) NOT NULL,                           -- Identificador del evento (automático)
    id_grupo INT,                                                   -- Grupo que lo organiza (puede quedar vacío)
    nombre NVARCHAR(80) NOT NULL,                                   -- Nombre del evento
    descripcion NVARCHAR(MAX),                                      -- De qué trata el evento
    fecha_inicio DATETIME2 NOT NULL,                                -- Fecha y hora de inicio
    fecha_fin DATETIME2 NOT NULL,                                   -- Fecha y hora de fin
    id_lugar INT NOT NULL,                                          -- Lugar del evento
    modalidad NVARCHAR(20) NOT NULL DEFAULT 'presencial',           -- Presencial o virtual
    organizador_id INT NOT NULL,                                    -- Estudiante responsable
    CONSTRAINT pk_evento PRIMARY KEY (id_evento),                   -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT ck_evento_fechas CHECK (fecha_fin >= fecha_inicio),  -- El evento no puede terminar antes de empezar
    CONSTRAINT fk_evento_grupo FOREIGN KEY (id_grupo)               -- Apunta a grupo
        REFERENCES grupo (id_grupo)                                 -- Tabla a la que apunta
        ON DELETE SET NULL                                          -- Si se borra el grupo, el evento queda sin grupo
        ON UPDATE NO ACTION,                                        -- No se actualiza: el id es IDENTITY y no cambia
    CONSTRAINT fk_evento_lugar FOREIGN KEY (id_lugar)               -- Apunta a lugar
        REFERENCES lugar (id_lugar)                                 -- Tabla a la que apunta
        ON DELETE NO ACTION                                         -- No deja borrar un lugar con eventos
        ON UPDATE NO ACTION,                                        -- No se actualiza: el id es IDENTITY y no cambia
    CONSTRAINT fk_evento_organizador FOREIGN KEY (organizador_id)   -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                       -- Tabla a la que apunta
        ON DELETE NO ACTION                                         -- No deja borrar al organizador de un evento
        ON UPDATE NO ACTION                                         -- No se actualiza: el id es IDENTITY y no cambia
);                                                                  -- Fin de la tabla evento

-- 11. TABLA ASISTENTE_EVENTO
CREATE TABLE asistente_evento (                                      -- Tabla: quién se inscribió a qué evento
    id_asistente INT IDENTITY(1,1) NOT NULL,                         -- Identificador de la inscripción (automático)
    id_estudiante INT NOT NULL,                                      -- Estudiante que se inscribe
    id_evento INT NOT NULL,                                          -- Evento al que se inscribe
    estado NVARCHAR(20) NOT NULL DEFAULT 'pendiente',                -- Pendiente, confirmado o cancelado
    fecha_registro DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),  -- Día en que se inscribió
    CONSTRAINT pk_asistente_evento PRIMARY KEY (id_asistente),       -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_asistente UNIQUE (id_estudiante, id_evento),       -- Nadie se inscribe dos veces al mismo evento
    CONSTRAINT fk_asistente_estudiante FOREIGN KEY (id_estudiante)   -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                        -- Tabla a la que apunta
        ON DELETE CASCADE                                            -- Si se borra el estudiante, se borran sus inscripciones
        ON UPDATE NO ACTION,                                         -- No se actualiza: el id es IDENTITY y no cambia
    CONSTRAINT fk_asistente_evento FOREIGN KEY (id_evento)           -- Apunta a evento
        REFERENCES evento (id_evento)                                -- Tabla a la que apunta
        ON DELETE CASCADE                                            -- Si se borra el evento, se borran sus inscripciones
        ON UPDATE NO ACTION                                          -- No se actualiza: el id es IDENTITY y no cambia
);                                                                   -- Fin de la tabla asistente_evento

-- 12. TABLA PUBLICACION
CREATE TABLE publicacion (                                              -- Tabla: preguntas, recursos, noticias y memes
    id_publicacion INT IDENTITY(1,1) NOT NULL,                          -- Identificador de la publicación (automático)
    id_estudiante INT NOT NULL,                                         -- Autor de la publicación
    contenido NVARCHAR(MAX) NOT NULL,                                   -- Texto de la publicación
    tipo NVARCHAR(20) NOT NULL,                                         -- Pregunta, recurso, noticia o meme
    fecha_publicacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),         -- Fecha y hora de publicación
    metadatos NVARCHAR(MAX),                                            -- etiquetas, enlaces y dispositivo de la publicación (JSON)
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),             -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT ck_publicacion_metadatos CHECK (ISJSON(metadatos) = 1),  -- Solo acepta texto que sea JSON válido
    CONSTRAINT fk_publicacion_estudiante FOREIGN KEY (id_estudiante)    -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                           -- Tabla a la que apunta
        ON DELETE CASCADE                                               -- Si se borra el estudiante, se borran sus publicaciones
        ON UPDATE NO ACTION                                             -- No se actualiza: el id es IDENTITY y no cambia
);                                                                      -- Fin de la tabla publicacion

-- 13. TABLA COMENTARIO
CREATE TABLE comentario (                                              -- Tabla: comentarios de las publicaciones
    id_comentario INT IDENTITY(1,1) NOT NULL,                          -- Identificador del comentario (automático)
    id_publicacion INT NOT NULL,                                       -- Publicación que se comenta
    id_estudiante INT NOT NULL,                                        -- Estudiante que comenta
    comentario NVARCHAR(MAX) NOT NULL,                                 -- Texto del comentario
    fecha_comentario DATETIME2 NOT NULL DEFAULT SYSDATETIME(),         -- Fecha y hora del comentario
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),              -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion)  -- Apunta a publicacion
        REFERENCES publicacion (id_publicacion)                        -- Tabla a la que apunta
        ON DELETE CASCADE                                              -- Si se borra la publicación, se borran sus comentarios
        ON UPDATE NO ACTION,                                           -- No se actualiza: el id es IDENTITY y no cambia
    CONSTRAINT fk_comentario_estudiante FOREIGN KEY (id_estudiante)    -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                          -- Tabla a la que apunta
        ON DELETE NO ACTION                                            -- SQL Server no deja cascada doble: borrar estos registros antes
        ON UPDATE NO ACTION                                            -- No se actualiza: el id es IDENTITY y no cambia
);                                                                     -- Fin de la tabla comentario

-- 14. TABLA REACCION
CREATE TABLE reaccion (                                              -- Tabla: reacciones a las publicaciones
    id_reaccion INT IDENTITY(1,1) NOT NULL,                          -- Identificador de la reacción (automático)
    id_estudiante INT NOT NULL,                                      -- Estudiante que reacciona
    id_publicacion INT NOT NULL,                                     -- Publicación que recibe la reacción
    tipo_reaccion NVARCHAR(20) NOT NULL DEFAULT 'me_gusta',          -- Me gusta, me sirve, etc.
    fecha_reaccion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),         -- Fecha y hora de la reacción
    CONSTRAINT pk_reaccion PRIMARY KEY (id_reaccion),                -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_reaccion UNIQUE (id_estudiante, id_publicacion),   -- Una reacción por estudiante en cada publicación
    CONSTRAINT fk_reaccion_estudiante FOREIGN KEY (id_estudiante)    -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                        -- Tabla a la que apunta
        ON DELETE NO ACTION                                          -- SQL Server no deja cascada doble: borrar estos registros antes
        ON UPDATE NO ACTION,                                         -- No se actualiza: el id es IDENTITY y no cambia
    CONSTRAINT fk_reaccion_publicacion FOREIGN KEY (id_publicacion)  -- Apunta a publicacion
        REFERENCES publicacion (id_publicacion)                      -- Tabla a la que apunta
        ON DELETE CASCADE                                            -- Si se borra la publicación, se borran sus reacciones
        ON UPDATE NO ACTION                                          -- No se actualiza: el id es IDENTITY y no cambia
);                                                                   -- Fin de la tabla reaccion

-- 15. TABLA SEGUIR
CREATE TABLE seguir (                                                   -- Tabla: quién sigue a quién
    id_seguir INT IDENTITY(1,1) NOT NULL,                               -- Identificador del seguimiento (automático)
    id_seguidor INT NOT NULL,                                           -- Estudiante que sigue
    id_seguido INT NOT NULL,                                            -- Estudiante que es seguido
    fecha_seguimiento DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),  -- Día en que empezó a seguirlo
    CONSTRAINT pk_seguir PRIMARY KEY (id_seguir),                       -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_seguir UNIQUE (id_seguidor, id_seguido),              -- No se sigue dos veces a la misma persona
    CONSTRAINT fk_seguir_seguidor FOREIGN KEY (id_seguidor)             -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                           -- Tabla a la que apunta
        ON DELETE CASCADE                                               -- Si se borra el seguidor, se borran sus seguimientos
        ON UPDATE NO ACTION,                                            -- No se actualiza: el id es IDENTITY y no cambia
    CONSTRAINT fk_seguir_seguido FOREIGN KEY (id_seguido)               -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                           -- Tabla a la que apunta
        ON DELETE NO ACTION                                             -- SQL Server no deja cascada doble: borrar estos registros antes
        ON UPDATE NO ACTION                                             -- No se actualiza: el id es IDENTITY y no cambia
);                                                                      -- Fin de la tabla seguir

-- 16. TABLA MENTORIA
CREATE TABLE mentoria (                                            -- Tabla: mentorías entre estudiantes
    id_mentoria INT IDENTITY(1,1) NOT NULL,                        -- Identificador de la mentoría (automático)
    id_mentor INT NOT NULL,                                        -- Estudiante mentor
    id_aprendiz INT NOT NULL,                                      -- Estudiante aprendiz
    fecha_inicio DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),  -- Día en que empezó
    estado NVARCHAR(20) NOT NULL DEFAULT 'activa',                 -- Activa, pausada o terminada
    CONSTRAINT pk_mentoria PRIMARY KEY (id_mentoria),              -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT fk_mentoria_mentor FOREIGN KEY (id_mentor)          -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                      -- Tabla a la que apunta
        ON DELETE CASCADE                                          -- Si se borra el mentor, se borran sus mentorías
        ON UPDATE NO ACTION,                                       -- No se actualiza: el id es IDENTITY y no cambia
    CONSTRAINT fk_mentoria_aprendiz FOREIGN KEY (id_aprendiz)      -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                      -- Tabla a la que apunta
        ON DELETE NO ACTION                                        -- SQL Server no deja cascada doble: borrar estos registros antes
        ON UPDATE NO ACTION                                        -- No se actualiza: el id es IDENTITY y no cambia
);                                                                 -- Fin de la tabla mentoria

-- 17. PRUEBA DE LOS CAMPOS JSON (datos de ejemplo inventados)
INSERT INTO estudiante (nombre, apellido, correo, password_hash, programa_academico)           -- Inserta un estudiante de ejemplo
VALUES (N'Camila', N'Ríos', 'camila.rios@correo.edu.co', 'hash_demo_001', 'Software');         -- Su id será 1 porque la tabla es nueva
INSERT INTO lugar (nombre, direccion, datos_iot)                                               -- Inserta un lugar con su JSON de coordenadas y sensores
VALUES (N'Biblioteca central', N'Campus principal',                                            -- Nombre y dirección del lugar
        N'{"coordenadas": {"lat": 6.2442, "lng": -75.5812}, "sensores": {"aforo": 35, "temperatura": 24.5}}');-- JSON: ubicación y lecturas de los sensores
INSERT INTO publicacion (id_estudiante, contenido, tipo, metadatos)                            -- Inserta una publicación con su JSON de metadatos
VALUES (1, N'Un recurso útil de bases de datos', 'recurso',                                    -- Autor 1, texto y tipo
        N'{"etiquetas": ["sql", "bases_de_datos"], "enlace": "https://ejemplo.com/recurso", "dispositivo": "movil"}');-- JSON: etiquetas, enlace y dispositivo
SELECT nombre, JSON_VALUE(datos_iot, '$.sensores.aforo') AS aforo FROM lugar;                  -- Lee un dato dentro del JSON con JSON_VALUE
SELECT contenido, JSON_VALUE(metadatos, '$.dispositivo') AS dispositivo FROM publicacion WHERE JSON_VALUE(metadatos, '$.dispositivo') = 'movil';-- Filtra publicaciones por un dato del JSON
SELECT name FROM sys.tables ORDER BY name;                                                     -- Lista las tablas creadas (deben salir 16)
