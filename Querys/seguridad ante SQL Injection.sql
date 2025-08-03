-- Ejemplo de login vulnerable
SELECT p.*, u.* FROM personas p 
JOIN usuarios u ON p.id = u.persona_id
WHERE u.contraseña = '' OR '1'='1';

-- Consulta segura
PREPARE consulta_login_seguro(text, text) AS
SELECT p.*, u.*
FROM personas p
JOIN usuarios u ON p.id = u.persona_id
WHERE p.correo = $1 AND u.contraseña = crypt($2, u.contraseña);

EXECUTE consulta_login_seguro('emy@gmail.com', 'emi123');


-- Validaciones previas en procedimientos y vistas

-- Función segura para login
DROP FUNCTION login_seguro;
CREATE OR REPLACE FUNCTION login_seguro(p_correo text, p_password text)
RETURNS TABLE (
  id_persona integer,
  correo character varying(100),
  tipo_usuario tipo_usuario_enum
)
AS $$
BEGIN
  RETURN QUERY
  SELECT p.id, p.correo, u.tipo_usuario
  FROM personas p
  JOIN usuarios u ON p.id = u.persona_id
  WHERE p.correo = p_correo
    AND u.contraseña = crypt(p_password, u.contraseña);
END;
$$ LANGUAGE plpgsql;

-- Comprobación
SELECT * FROM login_seguro('alejo@gmail.com', 'alejo123');

-- Vista que solo muestra información general sin exponer contraseñas
CREATE OR REPLACE VIEW vista_usuarios_activos AS
SELECT p.id AS persona_id, p.correo, u.tipo_usuario
FROM personas p
JOIN usuarios u ON p.id = u.persona_id;

-- Comprobación
select * from vista_usuarios_activos;

-- Trigger que previene la creación de personas con correos duplicados
CREATE OR REPLACE FUNCTION validar_correo_unico()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM personas WHERE correo = NEW.correo) THEN
    RAISE EXCEPTION 'El correo ya está registrado.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Asocia el trigger a la tabla personas
CREATE TRIGGER trg_correo_unico
BEFORE INSERT ON personas
FOR EACH ROW
EXECUTE FUNCTION validar_correo_unico();

-- Comprobación
INSERT INTO personas (nombres, correo)
VALUES ('Emily A', 'emy@gmail.com');