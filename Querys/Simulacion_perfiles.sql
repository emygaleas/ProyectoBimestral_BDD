select * from ideas_negocio;
select * from personas;
select * from usuarios;
select * from logs_sistema;
select * from mentorias;
select * from mentores;

-- Administrador
-- mantenimiento de indices
-- Mejorar rendimiento de búsqueda por correo
CREATE INDEX idx_personas_correo ON personas(correo_old);
EXPLAIN SELECT * FROM personas WHERE correo_old = 'alejo@gmail.com';


-- Acelerar búsqueda de ideas por estado
CREATE INDEX idx_ideas_estado ON ideas_negocio(estado);
EXPLAIN SELECT * FROM ideas_negocio WHERE estado = 2;

-- monitoreo simple
-- Ver tamaño de tablas
SELECT relname AS tabla, pg_size_pretty(pg_total_relation_size(relid)) AS tamano
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;


-- Arquitecto
-- Listar claves foráneas
SELECT conname AS restriccion, relname AS tabla
FROM pg_constraint
JOIN pg_class ON conrelid = pg_class.oid
WHERE contype = 'f';

-- Revisar campos tipo ENUM
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ideas_negocio';


-- Ejemplo de enmascarar correo
ALTER TABLE personas
ALTER COLUMN correo_old TYPE text;

UPDATE personas
SET correo_old = pgp_sym_encrypt(correo_old::text, 'nueva_clave');

SELECT LEFT(pgp_sym_decrypt(correo_old::bytea, 'nueva_clave')::text, 255)
FROM personas;

-- Revision de actividad
CREATE TABLE logs_sistema_2 (
    id SERIAL PRIMARY KEY,
    accion VARCHAR(50),
    usuario VARCHAR(50),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    datos JSONB
);


CREATE OR REPLACE FUNCTION log_acciones_personas()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO logs_sistema_2 (accion, usuario,datos)
        VALUES ('INSERT', current_user, row_to_json(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO logs_sistema_2 (accion, usuario, datos)
        VALUES ('UPDATE', current_user, row_to_json(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO logs_sistema_2 (accion, usuario, datos)
        VALUES ('DELETE', current_user, row_to_json(OLD));
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER personas_audit
AFTER INSERT OR UPDATE OR DELETE ON personas
FOR EACH ROW EXECUTE FUNCTION log_acciones_personas();

insert into personas(nombres,apellidos,correo_old,telefono,direccion,correo) values
('Samuel','Cahngo','sam@gmail.com','0996584716','Mena2','sam@gmail.com');

select * from logs_sistema_2;


-- desarrollador de consultas
CREATE OR REPLACE VIEW vista_ideas_estado AS
SELECT estado, COUNT(*) AS total
FROM ideas_negocio
GROUP BY estado;

select * from vista_ideas_estado;


-- funcion
drop function ideas_por_usuario;
CREATE OR REPLACE FUNCTION ideas_por_usuario(uid INT)
RETURNS TABLE(titulo_idea varchar(200), estado_idea int) AS $$
BEGIN
  RETURN QUERY
  SELECT titulo, estado FROM ideas_negocio WHERE usuario_id = uid;
END;
$$ LANGUAGE plpgsql;
select ideas_por_usuario(5);

-- procedimiento
CREATE OR REPLACE PROCEDURE aprobar_idea(idea INT, mentor INT)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ideas_negocio SET estado = 2 WHERE id = idea;
  INSERT INTO mentorias(idea_id, mentor_id, fecha, estado) 
  VALUES (idea, mentor, NOW(), 2);
END;
$$;

insert into ideas_negocio(usuario_id,categoria_id,titulo,descripcion,estado)values
(4,1,'SuperTablet','Tablet con ia',1);

call aprobar_idea(5,1);


-- Analista de Datos
SELECT c.nombre AS categoria, COUNT(*) AS total_ideas
FROM ideas_negocio i
JOIN categorias c ON c.id = i.categoria_id
GROUP BY c.nombre;

-- exportar como csv
COPY (
  SELECT * FROM ideas_negocio
) TO 'C:\Users\Flia Guanoluisa\OneDrive\Documentos\Proyecto_Bases_de_datos\export_ideas_estado.csv' DELIMITER ',' CSV HEADER;


-- Vista usuario final
CREATE OR REPLACE VIEW vista_mis_ideas AS
SELECT 
    i.id as id,
    i.titulo,
    i.descripcion,
    i.estado,
    c.nombre AS categoria,
    u.id as usuario_id,
    p.nombres || ' ' || p.apellidos AS emprendedor
FROM ideas_negocio i
JOIN categorias c ON c.id = i.categoria_id
JOIN usuarios u ON u.id = i.usuario_id
JOIN personas p ON p.id = u.persona_id;
select * from vista_mis_ideas;

CREATE OR REPLACE VIEW vista_mis_mentorias AS
SELECT 
    m.id,
    m.fecha,
    m.estado,
    i.titulo AS idea,
    p.nombres || ' ' || p.apellidos AS mentor
FROM mentorias m
JOIN mentores mt ON mt.id = m.mentor_id
JOIN personas p ON p.id = mt.persona_id
JOIN ideas_negocio i ON i.id = m.idea_id;
select * from vista_mis_mentorias;
select * from mentores;
select * from mentorias;
select * from observaciones;

CREATE OR REPLACE VIEW vista_mis_observaciones AS
SELECT 
    o.id,
    o.comentario,
    o.mentoria_id,
    m.fecha,
    i.titulo AS idea
FROM observaciones o
JOIN mentorias m ON m.id = o.mentoria_id
JOIN ideas_negocio i ON i.id = m.idea_id;
select * from vista_mis_observaciones;
select * from resultados;
select * from estadisticas_idea;
select * from avance_fases;

insert into avance_fases(idea_id,fase_id,porcentaje_avance,fecha_avance)values
(3,3,50,'2025-08-01');
insert into estadisticas_idea(avance_fase_id,mentoria_id)values
(2,2);
insert into resultados(usuario_id,estadisticas_id)values
(3,1);

CREATE OR REPLACE VIEW vista_mis_resultados AS
SELECT 
    r.id,
    p.nombres || ' ' || p.apellidos AS emprendedor,
    e.avance_fase_id AS fase_asignada,
    i.titulo AS idea
FROM resultados r
JOIN usuarios u ON u.id = r.usuario_id
JOIN personas p ON p.id = u.persona_id
JOIN estadisticas_idea e ON e.id = r.estadisticas_id
JOIN mentorias m ON m.id = e.mentoria_id
JOIN ideas_negocio i ON i.id = m.idea_id;
select * from vista_mis_resultados;


CREATE OR REPLACE VIEW vista_estado_ideas AS
SELECT 
    i.id,
    i.titulo,
    i.estado,
    COALESCE(p.nombres || ' ' || p.apellidos, 'Sin mentor') AS mentor_asignado
FROM ideas_negocio i
LEFT JOIN mentorias m ON m.idea_id = i.id
LEFT JOIN mentores mt ON mt.persona_id = m.mentor_id
LEFT JOIN personas p ON p.id = mt.persona_id;
select * from vista_estado_ideas;

