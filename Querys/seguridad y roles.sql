-- Roles
-- Creación de roles
CREATE ROLE administrador NOLOGIN SUPERUSER;
CREATE ROLE auditor NOLOGIN NOSUPERUSER;
CREATE ROLE operador NOLOGIN NOSUPERUSER;
CREATE ROLE mentor NOLOGIN NOSUPERUSER;
CREATE ROLE emprendedor NOLOGIN NOSUPERUSER;

-- Gestión de privilegios
-- Privilegios para administrador
GRANT ALL PRIVILEGES ON DATABASE bdd_juveniles TO administrador;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO administrador;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO administrador;

-- Privilegios para auditor
GRANT SELECT ON ALL TABLES IN SCHEMA public TO auditor;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO auditor;

-- Privilegios para operador
GRANT SELECT, INSERT, UPDATE ON personas, usuarios, ideas_negocio TO operador;
GRANT SELECT ON categorias, fases_proyecto, tipo_estados TO operador;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO operador;

-- Privilegios para mentores
GRANT SELECT, INSERT, UPDATE ON mentorias, observaciones TO mentor;
GRANT SELECT ON ideas_negocio, avance_fases TO mentor;
GRANT USAGE ON SEQUENCE mentorias_id_seq, observaciones_id_seq TO mentor;

-- Privilegios para emprendedores
GRANT SELECT, INSERT, UPDATE ON ideas_negocio TO emprendedor;
GRANT SELECT ON mentorias, observaciones, avance_fases TO emprendedor;
GRANT USAGE ON SEQUENCE ideas_negocio_id_seq TO emprendedor;

-- Encriptación 
-- Extensión para funciones criptográficas
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Cambiar el tamaño de contraseña en usuarios para guardar la contraseña encriptada
ALTER TABLE public.usuarios
ALTER COLUMN "contraseña" type text;

-- 2. Actualizar las contraseñas existentes en usuarios a contraseñas encriptadas
UPDATE public.usuarios 
SET "contraseña" = crypt("contraseña", gen_salt('bf', 8));

-- 3. Función para encriptar nuevas contraseñas
CREATE OR REPLACE FUNCTION encriptar_contrasenia()
RETURNS TRIGGER AS $$
BEGIN
    NEW.contraseña = crypt(NEW.contraseña, gen_salt('bf'));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para guardar siempre la contraseña como encriptada 
CREATE TRIGGER tr_encriptar_contrasenia
BEFORE INSERT OR UPDATE OF "contraseña" ON usuarios
FOR EACH ROW EXECUTE FUNCTION encriptar_contrasenia();

-- Verificación de SSL
SELECT name, setting FROM pg_settings WHERE name LIKE '%ssl%';
SELECT datname, usename, ssl, client_addr FROM pg_stat_ssl 
JOIN pg_stat_activity ON pg_stat_ssl.pid = pg_stat_activity.pid;
SELECT ssl FROM pg_stat_ssl WHERE pid = pg_backend_pid();

-- Tabla de respaldo para el registro de intentos fallidos
CREATE TABLE intentos_fallidos (
    id SERIAL PRIMARY KEY,
    usuario int,
    contrasenia_ingresada TEXT,
    fecha_intento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT
);

-- Función para simular la validación de login
CREATE OR REPLACE FUNCTION validar_login(usuario_input int, contrasena_input TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    hash_guardado TEXT;
BEGIN
    -- Buscar la contraseña encriptada del usuario por su id
    SELECT "contraseña" INTO hash_guardado
    FROM usuarios
    WHERE id = usuario_input;

    IF NOT FOUND THEN
        INSERT INTO intentos_fallidos(usuario, contrasenia_ingresada, motivo)
        VALUES (usuario_input, contrasena_input, 'Usuario no encontrado');
        RETURN FALSE;
    END IF;

    -- Comparar contraseñas encriptadas
    IF NOT (crypt(contrasena_input, hash_guardado) = hash_guardado) THEN
        INSERT INTO intentos_fallidos(usuario, contrasenia_ingresada, motivo)
        VALUES (usuario_input, contrasena_input, 'Contraseña incorrecta');
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$;

-- Uso de la función
SELECT validar_login('1000', 'user123');

-- Comprobación de registros
select * from intentos_fallidos;

-- Validaciones de entrada usando expresiones regulares

-- Trigger que valida el correo en la tabla personas
CREATE OR REPLACE FUNCTION validar_correo()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.correo !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Correo inválido: %', NEW.correo;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_correo
BEFORE INSERT OR UPDATE ON personas
FOR EACH ROW EXECUTE FUNCTION validar_correo();

-- Ejemplo de uso
INSERT INTO personas (correo) VALUES ('email_invalido');    -- Error

-- Trigger que valida que la contraseña contenga solo letras, números y algunos símbolos seguros
-- mínimo 6 caracteres 
CREATE OR REPLACE FUNCTION validar_contrasena()
RETURNS TRIGGER 
LANGUAGE plpgsql;
AS $$
BEGIN
    IF NEW."contraseña" !~ '^[A-Za-z0-9@#$%^&+=]{6,}$' THEN
        RAISE EXCEPTION USING MESSAGE = 'Contraseña inválida: debe tener al menos 6 caracteres y solo letras, números o @#$%^&+=';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_contrasena
BEFORE INSERT OR UPDATE ON usuarios
FOR EACH ROW EXECUTE FUNCTION validar_contrasena();

-- Ejemplo de uso
INSERT INTO usuarios ("contraseña") VALUES ('abc');

INSERT INTO usuarios ("contraseña") VALUES ('abc**##');

-- Revisión del historial de roles asignados y auditoría de privilegios activos

-- Tabla historial_roles
CREATE TABLE historial_roles (
    id SERIAL PRIMARY KEY,
    usuario_rol varchar(50) NOT NULL,
    rol varchar(50) NOT NULL,
    accion varchar(50) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	usuario_encargado varchar(50) NOT NULL
);

-- Función para asignar rol y registrar el cambio
CREATE OR REPLACE FUNCTION asignar_rol(usuario TEXT, rol TEXT) RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    EXECUTE FORMAT('GRANT %I TO %I', rol, usuario);
    INSERT INTO historial_roles(usuario_rol, rol, accion, usuario_encargado) 
	VALUES (usuario, rol, 'ASIGNADO', current_user);
END;
$$;

CREATE OR REPLACE FUNCTION revocar_rol(usuario TEXT, rol TEXT) RETURNS VOID 
LANGUAGE plpgsql
AS $$
BEGIN
    EXECUTE FORMAT('REVOKE %I FROM %I', rol, usuario);
    INSERT INTO historial_roles(usuario_rol, rol, accion, usuario_encargado) 
	VALUES (usuario, rol, 'REVOCADO', current_user);
END;
$$;

-- Crear usuarios con login
CREATE ROLE alejo WITH LOGIN PASSWORD 'alejo123';
CREATE ROLE emy WITH LOGIN PASSWORD 'emy123';
CREATE ROLE pedro WITH LOGIN PASSWORD 'pedro123';

-- Asignar roles a usuarios usando la funcion
SELECT asignar_rol('alejo', 'administrador');
SELECT asignar_rol('emy', 'operador');
SELECT revocar_rol('pedro', 'emprendedor');

-- Comprobar las inserciones
select * from historial_roles;

-- Comprobar roles activos de cada usuario
SELECT 
    pg_get_userbyid(member) AS usuario,
    pg_get_userbyid(roleid) AS rol
FROM pg_auth_members
ORDER BY usuario;

