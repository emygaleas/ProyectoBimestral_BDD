create extension if not exists pgcrypto;
select * from personas;
select * from usuarios;

-- 1. Renombrar la columna original
ALTER TABLE personas RENAME COLUMN correo TO correo_old;

-- 2. Crear la nueva columna con tipo correcto
ALTER TABLE personas ADD COLUMN correo text;

-- 3. Copiar y cifrar los valores antiguos
UPDATE personas SET correo = encode(pgp_sym_encrypt(correo_old, 'correo_seguro'),'base64');

-- 4. (Opcional)Eliminar la columna antigua A
ALTER TABLE personas DROP COLUMN correo_old;

INSERT INTO personas(nombres, apellidos, correo_old, telefono, direccion,correo)VALUES 
(
  'Laura Sofia',
  'Gomez Franco',
  'laura@gmail.com',
  '0987417802',
  'Mena 2',
  encode(pgp_sym_encrypt('laura@gmail.com', 'correo_seguro'),'base64')
);

SELECT nombres, apellidos,
       pgp_sym_decrypt(decode(correo, 'base64'), 'correo_seguro') AS correo_descifrado
FROM personas;

-- Inserta 
INSERT INTO personas(nombres,apellidos,correo_old,telefono,direccion,correo)VALUES 
(
  'Laura Sofia',
  'Gomez Franco',
  'laura@gmail.com',
  '0987417802',
  'Mena 2',
  encode(pgp_sym_encrypt('laura@gmail.com', 'correo_seguro'), 'base64')
);

-- Verifica que el correo fue insertado bien
SELECT nombres, correo FROM personas WHERE nombres = 'Laura Sofia';

-- Intenta descifrar
SELECT nombres, apellidos,
       pgp_sym_decrypt(decode(correo, 'base64'), 'correo_seguro') AS correo_descifrado
FROM personas;


ALTER TABLE usuarios RENAME COLUMN contraseña TO contrasenia_old;
ALTER TABLE usuarios ADD COLUMN contrasenia text;
UPDATE usuarios SET contrasenia = encode(pgp_sym_encrypt(contrasenia_old, 'contraseña_seguro'),'base64');
ALTER TABLE usuarios DROP COLUMN contrasenia_old;


-- 2. Simulación de anonimización y enmascaramiento
-- Simulación de anonimización
UPDATE personas
SET nombres = 'Usuario', apellidos = 'Anónimo', correo = NULL
WHERE id = 2;
select * from personas where id = 2;



-- Enmascaramiento simple
CREATE TABLE personas_cifrado (
    id SERIAL PRIMARY KEY,
    nombres TEXT,
    apellidos TEXT,
    correo BYTEA -- importante: tipo bytea
);
INSERT INTO personas_cifrado(nombres, apellidos, correo)
VALUES (
    'Pepe',
    'Espin',
    pgp_sym_encrypt('pepe@gmail.com', 'clave_segura')
);
SELECT nombres, apellidos,
       pgp_sym_decrypt(correo, 'clave_segura') AS correo_descifrado
FROM personas_cifrado;

SELECT nombres,
       apellidos,
       -- Primero se descifra el correo, luego se enmascara
       regexp_replace(pgp_sym_decrypt(correo, 'clave_segura')::TEXT,
                      '(^.).*(@.*)',
                      '\1***\2') AS correo_enmascarado
FROM personas_cifrado;


CREATE OR REPLACE PROCEDURE insertar_persona_encriptada(
    p_nombres TEXT,
    p_apellidos TEXT,
    p_correo TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO personas(nombres, apellidos, correo)
    VALUES (
        p_nombres,
        p_apellidos,
        pgp_sym_encrypt(p_correo, 'clave_segura') -- Encripta el correo
    );
END;
$$;

create or replace procedure insertar_persona_encriptada(
in p_nombres varchar(100),
in p_apellidos varchar(100),
in p_correoOld varchar(100),
in p_telefono varchar(20),
in p_direccion text,
in p_correo text
)
language plpgsql
as $$
begin
insert into personas(nombres,apellidos,correo_old,telefono,direccion,correo)values
(p_nombres,p_apellidos,p_correoOld,p_telefono,p_direccion,pgp_sym_encrypt(p_correo, 'correo_seguro'));
end;
$$
call insertar_persona_encriptada(
'Isaac Steven','Pozo Achig','isac@gmail.com','0987410210','Reino de Quito','isac@gmail.com'
);

ALTER TABLE personas
ALTER COLUMN correo TYPE bytea
USING convert_to(correo, 'UTF8');



CREATE OR REPLACE FUNCTION obtener_personas_desencriptadas()
RETURNS TABLE (
    nombres TEXT,
    apellidos TEXT,
    correo_original TEXT,
    correo_enmascarado TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.nombres,
        p.apellidos,
        pgp_sym_decrypt(p.correo, 'clave_segura')::text AS correo_original,
        -- Enmascarar el correo, mostrando solo la parte antes de '@' como '***'
        regexp_replace(pgp_sym_decrypt(p.correo, 'clave_segura')::text, '^[^@]+', '***') || '@' ||
        SPLIT_PART(pgp_sym_decrypt(p.correo, 'clave_segura')::text, '@', 2) AS correo_enmascarado
    FROM personas_cifrado p;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM obtener_personas_desencriptadas();