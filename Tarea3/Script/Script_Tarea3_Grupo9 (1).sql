/* =====================================================================
   RED SOCIAL ESTUDIANTIL "PASCUALINA" - Modelo físico en PostgreSQL (DDL)
   Base de Datos I - Grupo 9 - Tarea 3
   Integrantes: Andry Zharick Mariño Moreno y Alejandro Gallego Velásquez
   16 tablas del modelo lógico de la Tarea 2, con sus 22 llaves foráneas
   Nombres: minúsculas, con guion bajo, en singular y sin tildes
   Restricciones: pk_ (primaria), fk_ (foránea), uk_ (única), ck_ (regla de valores)
   ===================================================================== */

-- 0. LIMPIEZA: borra las tablas si ya existen (primero las hijas)
DROP TABLE IF EXISTS mentoria CASCADE;              -- Borra mentoria si existe
DROP TABLE IF EXISTS seguir CASCADE;                -- Borra seguir si existe
DROP TABLE IF EXISTS reaccion CASCADE;              -- Borra reaccion si existe
DROP TABLE IF EXISTS comentario CASCADE;            -- Borra comentario si existe
DROP TABLE IF EXISTS publicacion CASCADE;           -- Borra publicacion si existe
DROP TABLE IF EXISTS asistente_evento CASCADE;      -- Borra asistente_evento si existe
DROP TABLE IF EXISTS evento CASCADE;                -- Borra evento si existe
DROP TABLE IF EXISTS lugar CASCADE;                 -- Borra lugar si existe
DROP TABLE IF EXISTS miembro_grupo CASCADE;         -- Borra miembro_grupo si existe
DROP TABLE IF EXISTS grupo CASCADE;                 -- Borra grupo si existe
DROP TABLE IF EXISTS estudiante_interes CASCADE;    -- Borra estudiante_interes si existe
DROP TABLE IF EXISTS estudiante_habilidad CASCADE;  -- Borra estudiante_habilidad si existe
DROP TABLE IF EXISTS interes CASCADE;               -- Borra interes si existe
DROP TABLE IF EXISTS habilidad CASCADE;             -- Borra habilidad si existe
DROP TABLE IF EXISTS perfil CASCADE;                -- Borra perfil si existe
DROP TABLE IF EXISTS estudiante CASCADE;            -- Borra estudiante si existe

-- 1. TABLA ESTUDIANTE
CREATE TABLE estudiante (                                                     -- Tabla de los usuarios de la red social
    id_estudiante SERIAL,                                                     -- Número que identifica al estudiante (automático)
    nombre VARCHAR(50) NOT NULL,                                              -- Nombre (obligatorio)
    apellido VARCHAR(50) NOT NULL,                                            -- Apellido (obligatorio)
    correo VARCHAR(100) NOT NULL,                                             -- Correo (obligatorio)
    password_hash VARCHAR(255) NOT NULL,                                      -- Contraseña cifrada (obligatoria)
    programa_academico VARCHAR(80) NOT NULL,                                  -- Carrera (obligatoria)
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,                        -- Fecha de registro (hoy por defecto)
    ultima_actividad TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,            -- Última vez que entró (ahora por defecto)
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',                             -- Estado de la cuenta ('activo' por defecto)
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante),                     -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_estudiante_correo UNIQUE (correo),                          -- No puede haber dos cuentas con el mismo correo
    CONSTRAINT ck_estudiante_estado CHECK (estado IN ('activo', 'inactivo'))  -- Solo permite 'activo' o 'inactivo'
);                                                                            -- Fin de la tabla estudiante

-- 2. TABLA PERFIL
CREATE TABLE perfil (                                                 -- Tabla de los perfiles
    id_perfil SERIAL,                                                 -- Número que identifica el perfil (automático)
    id_estudiante INTEGER NOT NULL,                                   -- Dueño del perfil (obligatorio)
    foto VARCHAR(255),                                                -- Link de la foto (opcional)
    biografia TEXT,                                                   -- Texto libre (opcional)
    semestre INTEGER,                                                 -- Semestre (opcional)
    area_estudio VARCHAR(80),                                         -- Área de estudio (opcional)
    ciudad VARCHAR(60),                                               -- Ciudad (opcional)
    fecha_actualizacion DATE NOT NULL DEFAULT CURRENT_DATE,           -- Última edición (hoy por defecto)
    CONSTRAINT pk_perfil PRIMARY KEY (id_perfil),                     -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_perfil_estudiante UNIQUE (id_estudiante),           -- Un estudiante no puede tener dos perfiles
    CONSTRAINT ck_perfil_semestre CHECK (semestre BETWEEN 1 AND 12),  -- El semestre debe estar entre 1 y 12
    CONSTRAINT fk_perfil_estudiante FOREIGN KEY (id_estudiante)       -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                         -- Tabla a la que apunta
        ON DELETE CASCADE                                             -- Si se borra el estudiante, se borra su perfil
        ON UPDATE CASCADE                                             -- Si cambia el id, el cambio se copia aquí
);                                                                    -- Fin de la tabla perfil

-- 3. TABLA HABILIDAD
CREATE TABLE habilidad (                                -- Catálogo de habilidades
    id_habilidad SERIAL,                                -- Número que identifica la habilidad (automático)
    nombre VARCHAR(60) NOT NULL,                        -- Nombre de la habilidad (obligatorio)
    categoria VARCHAR(40) NOT NULL,                     -- Tipo de habilidad (obligatorio)
    CONSTRAINT pk_habilidad PRIMARY KEY (id_habilidad)  -- Llave primaria: no se repite ni queda vacía
);                                                      -- Fin de la tabla habilidad

-- 4. TABLA INTERES
CREATE TABLE interes (                              -- Catálogo de intereses
    id_interes SERIAL,                              -- Número que identifica el interés (automático)
    nombre VARCHAR(60) NOT NULL,                    -- Nombre del interés (obligatorio)
    categoria VARCHAR(40) NOT NULL,                 -- Tipo de interés (obligatorio)
    CONSTRAINT pk_interes PRIMARY KEY (id_interes)  -- Llave primaria: no se repite ni queda vacía
);                                                  -- Fin de la tabla interes

-- 5. TABLA ESTUDIANTE_HABILIDAD
CREATE TABLE estudiante_habilidad (                                            -- Tabla intermedia estudiante-habilidad
    id_estudiante_habilidad SERIAL,                                            -- Número que identifica el registro (automático)
    id_estudiante INTEGER NOT NULL,                                            -- Estudiante (obligatorio)
    id_habilidad INTEGER NOT NULL,                                             -- Habilidad (obligatoria)
    nivel VARCHAR(20) NOT NULL DEFAULT 'basico',                               -- Nivel ('basico' por defecto)
    fecha_agregado DATE NOT NULL DEFAULT CURRENT_DATE,                         -- Fecha en que se agregó (hoy por defecto)
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
);                                                                             -- Fin de la tabla estudiante_habilidad

-- 6. TABLA ESTUDIANTE_INTERES
CREATE TABLE estudiante_interes (                                          -- Tabla intermedia estudiante-interes
    id_estudiante_interes SERIAL,                                          -- Número que identifica el registro (automático)
    id_estudiante INTEGER NOT NULL,                                        -- Estudiante (obligatorio)
    id_interes INTEGER NOT NULL,                                           -- Interés (obligatorio)
    fecha_agregado DATE NOT NULL DEFAULT CURRENT_DATE,                     -- Fecha en que se agregó (hoy por defecto)
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
);                                                                         -- Fin de la tabla estudiante_interes

-- 7. TABLA GRUPO
CREATE TABLE grupo (                                      -- Tabla de grupos o comunidades
    id_grupo SERIAL,                                      -- Número que identifica el grupo (automático)
    nombre VARCHAR(80) NOT NULL,                          -- Nombre del grupo (obligatorio)
    descripcion TEXT,                                     -- De qué trata (opcional)
    tipo VARCHAR(30) NOT NULL,                            -- Tipo de grupo (obligatorio)
    fecha_creacion DATE NOT NULL DEFAULT CURRENT_DATE,    -- Fecha de creación (hoy por defecto)
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',         -- Estado ('activo' por defecto)
    creador_id INTEGER NOT NULL,                          -- Quién lo creó (obligatorio)
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),           -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT fk_grupo_creador FOREIGN KEY (creador_id)  -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)             -- Tabla a la que apunta
        ON DELETE RESTRICT                                -- No deja borrar a un estudiante que creó un grupo
        ON UPDATE CASCADE                                 -- Si cambia el id, el cambio se copia aquí
);                                                        -- Fin de la tabla grupo

-- 8. TABLA MIEMBRO_GRUPO
CREATE TABLE miembro_grupo (                                        -- Tabla intermedia estudiante-grupo
    id_miembro SERIAL,                                              -- Número que identifica la membresía (automático)
    id_estudiante INTEGER NOT NULL,                                 -- Estudiante (obligatorio)
    id_grupo INTEGER NOT NULL,                                      -- Grupo (obligatorio)
    fecha_ingreso DATE NOT NULL DEFAULT CURRENT_DATE,               -- Fecha de ingreso (hoy por defecto)
    rol VARCHAR(20) NOT NULL DEFAULT 'miembro',                     -- Rol ('miembro' por defecto)
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
);                                                                  -- Fin de la tabla miembro_grupo

-- 9. TABLA LUGAR
CREATE TABLE lugar (                            -- Tabla de lugares
    id_lugar SERIAL,                            -- Número que identifica el lugar (automático)
    nombre VARCHAR(80) NOT NULL,                -- Nombre del sitio (obligatorio)
    direccion VARCHAR(150) NOT NULL,            -- Dirección (obligatoria)
    CONSTRAINT pk_lugar PRIMARY KEY (id_lugar)  -- Llave primaria: no se repite ni queda vacía
);                                              -- Fin de la tabla lugar

-- 10. TABLA EVENTO
CREATE TABLE evento (                                               -- Tabla de eventos o actividades
    id_evento SERIAL,                                               -- Número que identifica el evento (automático)
    id_grupo INTEGER,                                               -- Grupo organizador (opcional)
    nombre VARCHAR(80) NOT NULL,                                    -- Nombre del evento (obligatorio)
    descripcion TEXT,                                               -- De qué trata (opcional)
    fecha_inicio TIMESTAMP NOT NULL,                                -- Cuándo empieza (obligatorio)
    fecha_fin TIMESTAMP NOT NULL,                                   -- Cuándo termina (obligatorio)
    id_lugar INTEGER NOT NULL,                                      -- Dónde se hace (obligatorio)
    modalidad VARCHAR(20) NOT NULL DEFAULT 'presencial',            -- Presencial o virtual ('presencial' por defecto)
    organizador_id INTEGER NOT NULL,                                -- Responsable del evento (obligatorio)
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
);                                                                  -- Fin de la tabla evento

-- 11. TABLA ASISTENTE_EVENTO
CREATE TABLE asistente_evento (                                     -- Tabla intermedia estudiante-evento
    id_asistente SERIAL,                                            -- Número que identifica la inscripción (automático)
    id_estudiante INTEGER NOT NULL,                                 -- Estudiante (obligatorio)
    id_evento INTEGER NOT NULL,                                     -- Evento (obligatorio)
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente',                -- Estado ('pendiente' por defecto)
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,              -- Fecha de inscripción (hoy por defecto)
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
);                                                                  -- Fin de la tabla asistente_evento

-- 12. TABLA PUBLICACION
CREATE TABLE publicacion (                                            -- Tabla de publicaciones
    id_publicacion SERIAL,                                            -- Número que identifica la publicación (automático)
    id_estudiante INTEGER NOT NULL,                                   -- Autor (obligatorio)
    contenido TEXT NOT NULL,                                          -- Texto de la publicación (obligatorio)
    tipo VARCHAR(20) NOT NULL,                                        -- Pregunta, recurso, noticia o meme
    fecha_publicacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,   -- Cuándo se publicó (ahora por defecto)
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),           -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT fk_publicacion_estudiante FOREIGN KEY (id_estudiante)  -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                         -- Tabla a la que apunta
        ON DELETE CASCADE                                             -- Si se borra el estudiante, se borran sus publicaciones
        ON UPDATE CASCADE                                             -- Si cambia el id, el cambio se copia aquí
);                                                                    -- Fin de la tabla publicacion

-- 13. TABLA COMENTARIO
CREATE TABLE comentario (                                              -- Tabla de comentarios
    id_comentario SERIAL,                                              -- Número que identifica el comentario (automático)
    id_publicacion INTEGER NOT NULL,                                   -- Publicación comentada (obligatoria)
    id_estudiante INTEGER NOT NULL,                                    -- Quién comentó (obligatorio)
    comentario TEXT NOT NULL,                                          -- Texto del comentario (obligatorio)
    fecha_comentario TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,     -- Cuándo se comentó (ahora por defecto)
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),              -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion)  -- Apunta a publicacion
        REFERENCES publicacion (id_publicacion)                        -- Tabla a la que apunta
        ON DELETE CASCADE                                              -- Si se borra la publicación, se borran sus comentarios
        ON UPDATE CASCADE,                                             -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_comentario_estudiante FOREIGN KEY (id_estudiante)    -- Apunta a estudiante
        REFERENCES estudiante (id_estudiante)                          -- Tabla a la que apunta
        ON DELETE CASCADE                                              -- Si se borra el estudiante, se borran sus comentarios
        ON UPDATE CASCADE                                              -- Si cambia el id, el cambio se copia aquí
);                                                                     -- Fin de la tabla comentario

-- 14. TABLA REACCION
CREATE TABLE reaccion (                                              -- Tabla de reacciones
    id_reaccion SERIAL,                                              -- Número que identifica la reacción (automático)
    id_estudiante INTEGER NOT NULL,                                  -- Quién reaccionó (obligatorio)
    id_publicacion INTEGER NOT NULL,                                 -- Publicación (obligatoria)
    tipo_reaccion VARCHAR(20) NOT NULL DEFAULT 'me_gusta',           -- Tipo de reacción ('me_gusta' por defecto)
    fecha_reaccion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,     -- Cuándo reaccionó (ahora por defecto)
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
);                                                                   -- Fin de la tabla reaccion

-- 15. TABLA SEGUIR
CREATE TABLE seguir (                                        -- Tabla de seguimientos entre estudiantes
    id_seguir SERIAL,                                        -- Número que identifica el seguimiento (automático)
    id_seguidor INTEGER NOT NULL,                            -- El que sigue (obligatorio)
    id_seguido INTEGER NOT NULL,                             -- El que es seguido (obligatorio)
    fecha_seguimiento DATE NOT NULL DEFAULT CURRENT_DATE,    -- Desde cuándo lo sigue (hoy por defecto)
    CONSTRAINT pk_seguir PRIMARY KEY (id_seguir),            -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT uk_seguir UNIQUE (id_seguidor, id_seguido),   -- No se sigue dos veces a la misma persona
    CONSTRAINT fk_seguir_seguidor FOREIGN KEY (id_seguidor)  -- Apunta a estudiante (el que sigue)
        REFERENCES estudiante (id_estudiante)                -- Tabla a la que apunta
        ON DELETE CASCADE                                    -- Si se borra el seguidor, se borran sus seguimientos
        ON UPDATE CASCADE,                                   -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_seguir_seguido FOREIGN KEY (id_seguido)    -- Apunta a estudiante (el seguido)
        REFERENCES estudiante (id_estudiante)                -- Tabla a la que apunta
        ON DELETE CASCADE                                    -- Si se borra el seguido, se borran los seguimientos hacia él
        ON UPDATE CASCADE                                    -- Si cambia el id, el cambio se copia aquí
);                                                           -- Fin de la tabla seguir

-- 16. TABLA MENTORIA
CREATE TABLE mentoria (                                        -- Tabla de mentorías entre estudiantes
    id_mentoria SERIAL,                                        -- Número que identifica la mentoría (automático)
    id_mentor INTEGER NOT NULL,                                -- Quién da la mentoría (obligatorio)
    id_aprendiz INTEGER NOT NULL,                              -- Quién la recibe (obligatorio)
    fecha_inicio DATE NOT NULL DEFAULT CURRENT_DATE,           -- Cuándo empezó (hoy por defecto)
    estado VARCHAR(20) NOT NULL DEFAULT 'activa',              -- Estado ('activa' por defecto)
    CONSTRAINT pk_mentoria PRIMARY KEY (id_mentoria),          -- Llave primaria: no se repite ni queda vacía
    CONSTRAINT fk_mentoria_mentor FOREIGN KEY (id_mentor)      -- Apunta a estudiante (mentor)
        REFERENCES estudiante (id_estudiante)                  -- Tabla a la que apunta
        ON DELETE CASCADE                                      -- Si se borra el mentor, se borran sus mentorías
        ON UPDATE CASCADE,                                     -- Si cambia el id, el cambio se copia aquí
    CONSTRAINT fk_mentoria_aprendiz FOREIGN KEY (id_aprendiz)  -- Apunta a estudiante (aprendiz)
        REFERENCES estudiante (id_estudiante)                  -- Tabla a la que apunta
        ON DELETE CASCADE                                      -- Si se borra el aprendiz, se borran sus mentorías
        ON UPDATE CASCADE                                      -- Si cambia el id, el cambio se copia aquí
);                                                             -- Fin de la tabla mentoria

-- 17. VERIFICACIÓN: lista las tablas creadas (deben salir 16)
SELECT table_name FROM information_schema.tables    -- Consulta las tablas de la base de datos
WHERE table_schema = 'public' ORDER BY table_name;  -- Solo las nuestras, en orden alfabético
