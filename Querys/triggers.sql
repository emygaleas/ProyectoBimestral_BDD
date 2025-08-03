-- Triggers
-- 1. Guardar el porcentaje de un avance al momento de actualizarlo
-- tabla de respaldo
create table avances_fase_historial(
	id SERIAL PRIMARY KEY,
    avance_id integer NOT NULL,
	idea_id integer NOT NULL,
    fase_id integer NOT NULL,
    porcentaje_avance numeric(5,2) NOT NULL,
	porcentaje_anterior numeric (5,2) NOT NULL,
    fecha_avance DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
	fecha_registro DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
	fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	usuario varchar(50),
	descripcion varchar(50)
);

-- funcion
CREATE OR REPLACE FUNCTION registrar_porcentaje_avance()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO avances_fase_historial(
	avance_id, idea_id, fase_id, porcentaje_avance, porcentaje_anterior, usuario, descripcion
	) VALUES (
        OLD.id,
        OLD.idea_id,
        OLD.fase_id,
        NEW.porcentaje_avance,
        OLD.porcentaje_avance,
        current_user,
        'Actualización del porcentaje de avance.'
    );
    RETURN NEW;
END;
$$;

-- trigger
CREATE TRIGGER trg_registrar_porcentaje_avance
BEFORE UPDATE ON avance_fases
FOR EACH ROW
EXECUTE FUNCTION registrar_porcentaje_avance();

-- Comprobación
select * from avances_fase_historial;
update avance_fases set porcentaje_avance = 30 where id=2;

-- 2. Auditoría al actualizar o eliminar ideas de negocio
-- tabla de respaldo
CREATE TABLE ideas_negocio_historial (
    id SERIAL PRIMARY KEY,
    idea_id INTEGER NOT NULL,
    usuario_id INTEGER NOT NULL,
	usuario varchar(50),
    accion VARCHAR(20) NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    titulo VARCHAR(200),
    descripcion TEXT,
    estado INTEGER,
    descripcion_accion VARCHAR(255)
);

-- función
CREATE OR REPLACE FUNCTION auditar_ideas_negocio()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO ideas_negocio_historial (
            idea_id, usuario_id, usuario, accion, titulo, descripcion, estado, descripcion_accion
        ) VALUES (
            OLD.id, OLD.usuario_id, current_user, TG_OP, OLD.titulo, OLD.descripcion, OLD.estado,
            'Eliminación de idea de negocio'
        );
        RETURN OLD;

    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO ideas_negocio_historial (
            idea_id, usuario_id, usuario, accion, titulo, descripcion, estado, descripcion_accion
        ) VALUES (
            NEW.id, NEW.usuario_id, current_user, TG_OP, NEW.titulo, NEW.descripcion, NEW.estado,
            'Actualización de idea de negocio'
        );
        RETURN NEW;

    ELSE -- INSERT
        INSERT INTO ideas_negocio_historial (
            idea_id, usuario_id, usuario, usuario, accion, titulo, descripcion, estado, descripcion_accion
        ) VALUES (
            NEW.id, NEW.usuario_id, current_user, TG_OP, NEW.titulo, NEW.descripcion, NEW.estado,
            'Inserción de idea de negocio'
        );
        RETURN NEW;
    END IF;
END;
$$;


-- trigger
CREATE TRIGGER trg_auditar_ideas
AFTER INSERT OR UPDATE OR DELETE ON ideas_negocio
FOR EACH ROW
EXECUTE FUNCTION auditar_ideas_negocio();

-- Comprobación
select * from ideas_negocio_historial;
update ideas_negocio set titulo = 'Plataforma' where id = 2;


-- 3. Eliminar los registros de las tablas relacionadas si se borra una mentoría.
-- Tabla de respaldo
CREATE TABLE mentoria_historial (
    id SERIAL PRIMARY KEY,
    mentoria_id INTEGER NOT NULL,
	idea_id INTEGER,
    mentor_id INTEGER,
    fecha DATE,
    estado INTEGER,

	observacion text,
    fecha_observacion TIMESTAMP,
	
	accion varchar(30) NOT NULL,
    fecha_accion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	usuario varchar(50) NOT NULL
);

-- Función
CREATE OR REPLACE FUNCTION guardar_historial_mentoria()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insertar una fila por cada observación asociada
    INSERT INTO mentoria_historial (
        mentoria_id, idea_id, mentor_id, fecha, estado,
        observacion, fecha_observacion,
        accion, usuario
    )
    SELECT
        OLD.id, OLD.idea_id, OLD.mentor_id, OLD.fecha, OLD.estado,
        o.comentario, o.fecha_observacion,
        'DELETE', current_user
    FROM observaciones o
    WHERE o.mentoria_id = OLD.id;

    -- Si no hay observaciones, guardar los datos de la mentoría
    IF NOT EXISTS (SELECT 1 FROM observaciones WHERE mentoria_id = OLD.id) THEN
        INSERT INTO mentoria_historial (
            mentoria_id, idea_id, mentor_id, fecha, estado,
            accion, usuario
        )
        VALUES (
            OLD.id, OLD.idea_id, OLD.mentor_id, OLD.fecha, OLD.estado,
            'DELETE', current_user
        );
    END IF;

    -- Eliminar observaciones relacionadas
    DELETE FROM observaciones WHERE mentoria_id = OLD.id;

    -- Eliminar estadísticas relacionadas
    DELETE FROM estadisticas_idea WHERE mentoria_id = OLD.id;

    RETURN OLD;
END;
$$;

-- Trigger
CREATE TRIGGER trg_guardar_mentoria_y_eliminar_estadisticas
BEFORE DELETE ON mentorias
FOR EACH ROW
EXECUTE FUNCTION guardar_historial_mentoria();

-- Comprobación
delete from mentorias where id = 100;
select * from mentoria_historial;


