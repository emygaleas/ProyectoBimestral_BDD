-- Tabla de respaldo completa
CREATE TABLE log_acciones(
	id SERIAL PRIMARY KEY,
	usuario varchar(50) NOT NULL,
	ip text,
	fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	accion text,
	tabla text,
	id_afectado int
);
alter table log_acciones
add column rol varchar(50);

-- Función 
CREATE OR REPLACE FUNCTION auditoria_tablas()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
DECLARE
	ID_afectado int;
BEGIN
	ID_afectado := COALESCE(NEW.id, OLD.id);
	INSERT INTO log_acciones(usuario, ip, accion, tabla, id_afectado, rol)
	    VALUES (
	        current_user,
	        inet_client_addr()::TEXT,
	        TG_OP,
	        TG_TABLE_NAME,
	        ID_afectado,
			current_setting('role')
	    );
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

-- Trigger para la tabla personas
CREATE TRIGGER trg_aud_personas
AFTER INSERT OR UPDATE OR DELETE ON personas
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Trigger para la tabla usuarios
CREATE TRIGGER trg_aud_usuarios
AFTER INSERT OR UPDATE OR DELETE ON usuarios
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Trigger para la tabla avance_fases
CREATE TRIGGER trg_aud_avance_fases
AFTER INSERT OR UPDATE OR DELETE ON avance_fases
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Trigger para la tabla categorias
CREATE TRIGGER trg_aud_categorias
AFTER INSERT OR UPDATE OR DELETE ON categorias
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Trigger para la tabla estadisticas_idea
CREATE TRIGGER trg_aud_estadisticas_idea
AFTER INSERT OR UPDATE OR DELETE ON estadisticas_idea
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Trigger para la tabla fases_proyecto
CREATE TRIGGER trg_aud_fases_proyecto
AFTER INSERT OR UPDATE OR DELETE ON fases_proyecto
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Trigger para la tabla ideas_negocio
CREATE TRIGGER trg_aud_ideas_negocio
AFTER INSERT OR UPDATE OR DELETE ON ideas_negocio
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Trigger para la tabla mentores
CREATE TRIGGER trg_aud_mentores
AFTER INSERT OR UPDATE OR DELETE ON mentores
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Trigger para la tabla mentorias
CREATE TRIGGER trg_aud_mentorias
AFTER INSERT OR UPDATE OR DELETE ON mentorias
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Trigger para la tabla observaciones
CREATE TRIGGER trg_aud_observaciones
AFTER INSERT OR UPDATE OR DELETE ON observaciones
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Trigger para la tabla reportes
CREATE TRIGGER trg_aud_reportes
AFTER INSERT OR UPDATE OR DELETE ON reportes
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Trigger para la tabla resultados
CREATE TRIGGER trg_aud_resultados
AFTER INSERT OR UPDATE OR DELETE ON resultados
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Trigger para la tabla tipo_estados
CREATE TRIGGER trg_aud_tipo_estados
AFTER INSERT OR UPDATE OR DELETE ON tipo_estados
FOR EACH ROW EXECUTE FUNCTION auditoria_tablas();

-- Comprobación
select * from personas;
insert into personas(id, nombres, apellidos, correo, telefono, direccion)
	values
	(804, 'María José', 'Peñafiel Torres', 'majo@gmail.com', '0995471823', 'La Luz');
delete from personas where id = 804;

select * from log_acciones;

-- Reportes
-- vista general
CREATE OR REPLACE VIEW vista_log_acciones_general AS
SELECT 
	id,
	usuario,
	rol,
	ip,
	fecha,
	accion,
	tabla,
	id_afectado
FROM log_acciones;
-- Comprobación
select * from vista_log_acciones_general;


-- vista por usuario
CREATE OR REPLACE VIEW vista_log_acciones_usuario AS
SELECT * FROM log_acciones
ORDER BY usuario, fecha DESC;
-- Comprobación
SELECT * FROM vista_auditoria_por_usuario WHERE usuario = 'admin';


-- vista por tabla
CREATE OR REPLACE VIEW vista_log_acciones_tabla AS
SELECT * FROM log_acciones
ORDER BY tabla, fecha DESC;
-- Comprobación
SELECT * FROM vista_log_acciones_tabla WHERE tabla = 'personas';


-- vista por fecha (últimos 7 días)
CREATE OR REPLACE VIEW vista_log_acciones_fecha AS
SELECT * FROM log_acciones
WHERE fecha >= current_date - INTERVAL '7 days'
ORDER BY fecha DESC;
-- Comprobación
select * from vista_log_acciones_fecha;