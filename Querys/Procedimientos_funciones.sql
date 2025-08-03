select * from personas;
select * from usuarios;
select * from ideas_negocio;
select * from mentores;
select * from tipo_estados;
select * from mentorias;
select * from categorias;
select * from fases_proyecto;
select * from avance_fases;
select * from resultados;
select * from observaciones;
select * from reportes;

insert into personas(nombres,apellidos,correo,telefono,direccion)values
('Xavier Alejandro','Guanoluisa Quevedo','alejo@gmail.com','0993630096','Reino de Quito'),
('Emily Alejandra','Galeas Tingo','emy@gmail.com','0987458521','Carcelen'),
('Eduardo Steven','Chacha Guzman','edu@mail.com','0987458578','Conocoto'),
('Rosa Maria','Ganchala Chulde','rosa@gmail.com','0963212541','Calderon'),
('Angelica Fernanda','Garcia Torres','ange@gmail.com','0912541236','La Carolina'),
('Jose Manuel','Rojas Cruz','jose@gmail.com','0987485421','Chillogallo');

ALTER TYPE tipo_usuario_enum ADD VALUE 'mentor';

insert into usuarios(persona_id,contraseña, tipo_usuario)values
(1,'alejo123','administrador'),
(2,'emi123','administrador'),
(3,'edu123','mentor'),
(4,'rosa123','emprendedor'),
(5,'ange123','emprendedor');

insert into ideas_negocio(usuario_id,categoria_id,titulo,descripcion,estado)values
(4,1,'SuperTV','Television con ia',1),
(5,5,'AuntoBufanda','Bufanda que se cierra sola',1);

insert into mentores(persona_id,especialidad)values
(3,'Tecnologia');

insert into mentorias(idea_id,mentor_id,fecha,estado) values
(3,1,'2025-07-30',2)


-- Procedimientos almacenados

create procedure insertar_idea_validada(
    in p_usuario_id int,
    in p_categoria_id int,
    in p_titulo varchar(200),
    in p_descripcion text,
	in p_estado int
)
language plpgsql
as $$
declare
    existe_usuario BOOLEAN;
    existe_categoria BOOLEAN;
begin
    select exists(select 1 from usuarios where id = p_usuario_id) into existe_usuario;
    select exists(select 1 from categorias where id = p_categoria_id) into existe_categoria;

    if not existe_usuario then
        raise exception 'Usuario no existe';
    elseif not existe_categoria then
        raise exception 'Categoría no existe';
    end if;

    insert into ideas_negocio(usuario_id, categoria_id, titulo, descripcion,estado)
    values (p_usuario_id, p_categoria_id, p_titulo, p_descripcion,p_estado);
end;
$$;

call insertar_idea_validada(4,10,'Super tablet', 'tablet con bateria auto recargable',1);

create procedure cambio_estado_idea(
in nuevo_estado int
)
language plpgsql
as $$
begin
	update ideas_negocio
	set estado = nuevo_estado
	where estado = 1;
end;
$$
call cambio_estado_idea(2);
drop procedure eliminar_mentor_sin_mentorias;

create procedure eliminar_mentor_sin_mentorias(in mentorId int)
language plpgsql
as $$
declare 
existen_mentorias boolean;
begin 
select exists(select 1 from mentorias where mentor_id = mentorId or estado = 2 )
into existen_mentorias;

if existen_mentorias then 
	raise exception 'El mentor tiene mentorias asignadas';
else
	delete from mentores where id = mentorId;
end if;
end;
$$
call eliminar_mentor_sin_mentorias(1);

drop procedure insertar_mentor;

create procedure insertar_mentor(in personaId INT, in espe VARCHAR(100))
language plpgsql
as $$
declare
    la_persona_existe BOOLEAN;
begin
    select exists(select 1 from personas where id = personaId) into la_persona_existe;

    if not la_persona_existe then
        raise exception 'La persona no existe';
    else
        insert into mentores(persona_id, especialidad) values (personaId, espe);
    end if;
end;
$$;
call insertar_mentor(10,'Salud');

create procedure registrar_resultado_con_transaccion(
    IN usuarioId INT,
    IN estadisticaId INT
)
language plpgsql
as $$
begi
    START TRANSACTION;

    SAVEPOINT antes_de_insertar;

    INSERT INTO resultados(usuario_id, estadisticas_id)
    VALUES (usuarioId, estadisticaId);

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE NOTICE 'Error al registrar resultado. Transacción cancelada.';
END;
$$;

call registrar_resultado_con_transaccion(1,1);


create procedure asignar_mentoria(in ideaId INT,in mentorId INT, in p_fecha DATE, in nuevo_estado int)
language plpgsql
as $$
begin
    if p_fecha < current_date then
        raise exception 'La fecha debe ser futura.';
    end if;

    insert into mentorias(idea_id, mentor_id, fecha, estado)
    values (ideaId, mentorId, p_fecha, nuevo_estado);
end;
$$;

call asignar_mentoria(3,1,'2024-07-30',2);


create procedure insertar_observacion_si_existe_mentoria(in mentoriaId int,in nuevo_comentario text)
language plpgsql
as $$
declare
existe_mentoria boolean;
begin
select exists(select 1 from mentorias where id = mentoriaId) into existe_mentoria;
if not existe_mentoria then
	raise exception 'No existe una mentoria previa';
else
	insert into observaciones(mentoria_id,comentario)values
	(mentoriaId,nuevo_comentario);
end if;
end;
$$
call insertar_observacion_si_existe_mentoria(5,'Le falta documentacion');
call insertar_observacion_si_existe_mentoria(2,'Le falta documentacion');

create procedure crear_usuario(in personaId int,in n_contrasenia varchar(100),in n_tipo varchar(100))
language plpgsql
as $$
declare
existe_persona boolean;
begin
select exists(select 1 from personas where id = personaId) into existe_persona;
if existe_persona then
insert into usuarios(persona_id,contraseña,tipo_usuario)values
(personaId,n_contrasenia,n_tipo);
else
raise exception 'La persona no existe';
end if;
end;
$$
call crear_usuario(10,'nuevo123','mentor');

create or replace procedure cambiar_tipo_usuario(in tipo_actual varchar(50), in tipo_nuevo varchar(50))
language plpgsql
as $$
begin
update usuarios
set tipo_usuario = tipo_nuevo::tipo_usuario_enum
where tipo_usuario = tipo_actual::tipo_usuario_enum;
end;
$$
call cambiar_tipo_usuario('mentor','emprendedor');

create or replace procedure agregar_nuevo_avance(in ideaId int,in faseId int,in porcentaje numeric(5,2),in n_fecha_avance date)
language plpgsql
as $$
begin
if n_fecha_avance < current_date or n_fecha_avance > current_date then 
        raise exception 'La fecha debe ser actual.';
    end if;

    insert into avance_fases(idea_id, fase_id, porcentaje_avance, fecha_avance)
    values (ideaId, faseId, porcentaje, n_fecha_avance);
end;
$$
call agregar_nuevo_avance(3,3,50,'2025-08-01');


create function reporte_mentorias_mentor(
    in p_mentor_id INT,
    in fecha_inicio DATE,
    in fecha_fin DATE
)
returns table(out_idea_id INT, out_mentor_id INT, out_fecha DATE, out_estado INT)  
language plpgsql
as $$
begin
    return query
    select m.idea_id, m.mentor_id, m.fecha, m.estado
    from mentorias m  
    where m.mentor_id = p_mentor_id
      and m.fecha::DATE between fecha_inicio and fecha_fin;
end;
$$;

select reporte_mentorias_mentor(1,'2025-07-01','2025-08-01');


create or replace function porcentaje_ideas_finalizadas(p_usuario_id int)
returns nemeric as $$
declare
    total int;
    finalizadas int;
begin
    select count(*) into total from ideas_negocio where usuario_id = p_usuario_id;
    select count(*) into finalizadas from ideas_negocio where usuario_id = p_usuario_id and estado = 5;

    if total = 0 then
        return 0;
    end if;

    return (finalizadas * 100.0) / total;
end;
$$ language plpgsql;
select porcentaje_ideas_finalizadas(4); 

create function estado_usuario(p_usuario_id int)
returns text as $$
declare
    ideas int;
begin
    select count(*) into ideas from ideas_negocio where usuario_id = p_usuario_id;

    if ideas = 0 then
        return 'Inactivo';
    elseif ideas < 3 then
        return 'Activo';
    else
        return 'Emprendedor Destacado';
    end if;
end;
$$ language plpgsql;
select estado_usuario(4);


