--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9
-- Dumped by pg_dump version 16.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: categoria_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.categoria_enum AS ENUM (
    'Tecnología',
    'Educación',
    'Salud',
    'Alimentos',
    'Moda',
    'Turismo',
    'Finanzas'
);


ALTER TYPE public.categoria_enum OWNER TO postgres;

--
-- Name: estado_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.estado_enum AS ENUM (
    'pendiente',
    'aprobado',
    'rechazado',
    'en_proceso',
    'finalizado'
);


ALTER TYPE public.estado_enum OWNER TO postgres;

--
-- Name: fase_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.fase_enum AS ENUM (
    'Ideación',
    'Planificación',
    'Desarrollo',
    'Validación',
    'Lanzamiento',
    'Seguimiento'
);


ALTER TYPE public.fase_enum OWNER TO postgres;

--
-- Name: tipo_usuario_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tipo_usuario_enum AS ENUM (
    'emprendedor',
    'administrador'
);


ALTER TYPE public.tipo_usuario_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: avance_fases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.avance_fases (
    id integer NOT NULL,
    idea_id integer NOT NULL,
    fase_id integer NOT NULL,
    porcentaje_avance numeric(5,2) NOT NULL,
    fecha_avance date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT avance_fases_porcentaje_avance_check CHECK (((porcentaje_avance >= (0)::numeric) AND (porcentaje_avance <= (100)::numeric)))
);


ALTER TABLE public.avance_fases OWNER TO postgres;

--
-- Name: avance_fases_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.avance_fases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.avance_fases_id_seq OWNER TO postgres;

--
-- Name: avance_fases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.avance_fases_id_seq OWNED BY public.avance_fases.id;


--
-- Name: categorias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categorias (
    id integer NOT NULL,
    nombre public.categoria_enum NOT NULL,
    descripcion text
);


ALTER TABLE public.categorias OWNER TO postgres;

--
-- Name: categorias_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categorias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categorias_id_seq OWNER TO postgres;

--
-- Name: categorias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categorias_id_seq OWNED BY public.categorias.id;


--
-- Name: estadisticas_idea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estadisticas_idea (
    id integer NOT NULL,
    avance_fase_id integer NOT NULL,
    mentoria_id integer
);


ALTER TABLE public.estadisticas_idea OWNER TO postgres;

--
-- Name: estadisticas_idea_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.estadisticas_idea_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.estadisticas_idea_id_seq OWNER TO postgres;

--
-- Name: estadisticas_idea_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.estadisticas_idea_id_seq OWNED BY public.estadisticas_idea.id;


--
-- Name: fases_proyecto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fases_proyecto (
    id integer NOT NULL,
    fase public.fase_enum NOT NULL,
    descripcion text
);


ALTER TABLE public.fases_proyecto OWNER TO postgres;

--
-- Name: fases_proyecto_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fases_proyecto_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fases_proyecto_id_seq OWNER TO postgres;

--
-- Name: fases_proyecto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fases_proyecto_id_seq OWNED BY public.fases_proyecto.id;


--
-- Name: ideas_negocio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ideas_negocio (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    categoria_id integer NOT NULL,
    titulo character varying(200) NOT NULL,
    descripcion text,
    estado integer DEFAULT 1
);


ALTER TABLE public.ideas_negocio OWNER TO postgres;

--
-- Name: ideas_negocio_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ideas_negocio_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ideas_negocio_id_seq OWNER TO postgres;

--
-- Name: ideas_negocio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ideas_negocio_id_seq OWNED BY public.ideas_negocio.id;


--
-- Name: logs_sistema; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs_sistema (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    accion text,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.logs_sistema OWNER TO postgres;

--
-- Name: logs_sistema_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.logs_sistema_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.logs_sistema_id_seq OWNER TO postgres;

--
-- Name: logs_sistema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.logs_sistema_id_seq OWNED BY public.logs_sistema.id;


--
-- Name: mentores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mentores (
    id integer NOT NULL,
    persona_id integer NOT NULL,
    especialidad character varying(100)
);


ALTER TABLE public.mentores OWNER TO postgres;

--
-- Name: mentores_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mentores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mentores_id_seq OWNER TO postgres;

--
-- Name: mentores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mentores_id_seq OWNED BY public.mentores.id;


--
-- Name: mentorias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mentorias (
    id integer NOT NULL,
    idea_id integer NOT NULL,
    mentor_id integer NOT NULL,
    fecha date DEFAULT CURRENT_TIMESTAMP,
    estado integer
);


ALTER TABLE public.mentorias OWNER TO postgres;

--
-- Name: mentorias_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mentorias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mentorias_id_seq OWNER TO postgres;

--
-- Name: mentorias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mentorias_id_seq OWNED BY public.mentorias.id;


--
-- Name: observaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.observaciones (
    id integer NOT NULL,
    mentoria_id integer NOT NULL,
    comentario text NOT NULL,
    fecha_observacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.observaciones OWNER TO postgres;

--
-- Name: observaciones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.observaciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.observaciones_id_seq OWNER TO postgres;

--
-- Name: observaciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.observaciones_id_seq OWNED BY public.observaciones.id;


--
-- Name: personas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personas (
    id integer NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    correo character varying(100) NOT NULL,
    telefono character varying(20),
    direccion text
);


ALTER TABLE public.personas OWNER TO postgres;

--
-- Name: personas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personas_id_seq OWNER TO postgres;

--
-- Name: personas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personas_id_seq OWNED BY public.personas.id;


--
-- Name: reportes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reportes (
    id integer NOT NULL,
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    resultado_id integer NOT NULL
);


ALTER TABLE public.reportes OWNER TO postgres;

--
-- Name: reportes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reportes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reportes_id_seq OWNER TO postgres;

--
-- Name: reportes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reportes_id_seq OWNED BY public.reportes.id;


--
-- Name: resultados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resultados (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    estadisticas_id integer NOT NULL
);


ALTER TABLE public.resultados OWNER TO postgres;

--
-- Name: resultados_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.resultados_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resultados_id_seq OWNER TO postgres;

--
-- Name: resultados_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.resultados_id_seq OWNED BY public.resultados.id;


--
-- Name: tipo_estados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipo_estados (
    id integer NOT NULL,
    tipo character varying(50)
);


ALTER TABLE public.tipo_estados OWNER TO postgres;

--
-- Name: tipo_estados_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tipo_estados_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tipo_estados_id_seq OWNER TO postgres;

--
-- Name: tipo_estados_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tipo_estados_id_seq OWNED BY public.tipo_estados.id;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    persona_id integer NOT NULL,
    "contraseña" character varying(100) NOT NULL,
    tipo_usuario public.tipo_usuario_enum NOT NULL
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_seq OWNER TO postgres;

--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- Name: avance_fases id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avance_fases ALTER COLUMN id SET DEFAULT nextval('public.avance_fases_id_seq'::regclass);


--
-- Name: categorias id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias ALTER COLUMN id SET DEFAULT nextval('public.categorias_id_seq'::regclass);


--
-- Name: estadisticas_idea id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estadisticas_idea ALTER COLUMN id SET DEFAULT nextval('public.estadisticas_idea_id_seq'::regclass);


--
-- Name: fases_proyecto id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fases_proyecto ALTER COLUMN id SET DEFAULT nextval('public.fases_proyecto_id_seq'::regclass);


--
-- Name: ideas_negocio id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ideas_negocio ALTER COLUMN id SET DEFAULT nextval('public.ideas_negocio_id_seq'::regclass);


--
-- Name: logs_sistema id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs_sistema ALTER COLUMN id SET DEFAULT nextval('public.logs_sistema_id_seq'::regclass);


--
-- Name: mentores id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentores ALTER COLUMN id SET DEFAULT nextval('public.mentores_id_seq'::regclass);


--
-- Name: mentorias id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentorias ALTER COLUMN id SET DEFAULT nextval('public.mentorias_id_seq'::regclass);


--
-- Name: observaciones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observaciones ALTER COLUMN id SET DEFAULT nextval('public.observaciones_id_seq'::regclass);


--
-- Name: personas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas ALTER COLUMN id SET DEFAULT nextval('public.personas_id_seq'::regclass);


--
-- Name: reportes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes ALTER COLUMN id SET DEFAULT nextval('public.reportes_id_seq'::regclass);


--
-- Name: resultados id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resultados ALTER COLUMN id SET DEFAULT nextval('public.resultados_id_seq'::regclass);


--
-- Name: tipo_estados id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_estados ALTER COLUMN id SET DEFAULT nextval('public.tipo_estados_id_seq'::regclass);


--
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- Name: avance_fases avance_fases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avance_fases
    ADD CONSTRAINT avance_fases_pkey PRIMARY KEY (id);


--
-- Name: categorias categorias_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_nombre_key UNIQUE (nombre);


--
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id);


--
-- Name: estadisticas_idea estadisticas_idea_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estadisticas_idea
    ADD CONSTRAINT estadisticas_idea_pkey PRIMARY KEY (id);


--
-- Name: fases_proyecto fases_proyecto_fase_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fases_proyecto
    ADD CONSTRAINT fases_proyecto_fase_key UNIQUE (fase);


--
-- Name: fases_proyecto fases_proyecto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fases_proyecto
    ADD CONSTRAINT fases_proyecto_pkey PRIMARY KEY (id);


--
-- Name: ideas_negocio ideas_negocio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ideas_negocio
    ADD CONSTRAINT ideas_negocio_pkey PRIMARY KEY (id);


--
-- Name: logs_sistema logs_sistema_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs_sistema
    ADD CONSTRAINT logs_sistema_pkey PRIMARY KEY (id);


--
-- Name: mentores mentores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentores
    ADD CONSTRAINT mentores_pkey PRIMARY KEY (id);


--
-- Name: mentorias mentorias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentorias
    ADD CONSTRAINT mentorias_pkey PRIMARY KEY (id);


--
-- Name: observaciones observaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observaciones
    ADD CONSTRAINT observaciones_pkey PRIMARY KEY (id);


--
-- Name: personas personas_correo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_correo_key UNIQUE (correo);


--
-- Name: personas personas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_pkey PRIMARY KEY (id);


--
-- Name: reportes reportes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT reportes_pkey PRIMARY KEY (id);


--
-- Name: resultados resultados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resultados
    ADD CONSTRAINT resultados_pkey PRIMARY KEY (id);


--
-- Name: tipo_estados tipo_estados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipo_estados
    ADD CONSTRAINT tipo_estados_pkey PRIMARY KEY (id);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: avance_fases fk_avance_fase; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avance_fases
    ADD CONSTRAINT fk_avance_fase FOREIGN KEY (fase_id) REFERENCES public.fases_proyecto(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estadisticas_idea fk_avance_fase; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estadisticas_idea
    ADD CONSTRAINT fk_avance_fase FOREIGN KEY (avance_fase_id) REFERENCES public.avance_fases(id);


--
-- Name: avance_fases fk_avance_idea; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.avance_fases
    ADD CONSTRAINT fk_avance_idea FOREIGN KEY (idea_id) REFERENCES public.ideas_negocio(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: resultados fk_estadisticas_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resultados
    ADD CONSTRAINT fk_estadisticas_id FOREIGN KEY (estadisticas_id) REFERENCES public.estadisticas_idea(id) ON DELETE CASCADE;


--
-- Name: mentorias fk_estado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentorias
    ADD CONSTRAINT fk_estado FOREIGN KEY (estado) REFERENCES public.tipo_estados(id);


--
-- Name: ideas_negocio fk_idea_categoria; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ideas_negocio
    ADD CONSTRAINT fk_idea_categoria FOREIGN KEY (categoria_id) REFERENCES public.categorias(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ideas_negocio fk_idea_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ideas_negocio
    ADD CONSTRAINT fk_idea_usuario FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: logs_sistema fk_log_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs_sistema
    ADD CONSTRAINT fk_log_usuario FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: mentores fk_mentor_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentores
    ADD CONSTRAINT fk_mentor_persona FOREIGN KEY (persona_id) REFERENCES public.personas(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estadisticas_idea fk_mentoria_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estadisticas_idea
    ADD CONSTRAINT fk_mentoria_id FOREIGN KEY (mentoria_id) REFERENCES public.mentorias(id);


--
-- Name: mentorias fk_mentoria_idea; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentorias
    ADD CONSTRAINT fk_mentoria_idea FOREIGN KEY (idea_id) REFERENCES public.ideas_negocio(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mentorias fk_mentoria_mentor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mentorias
    ADD CONSTRAINT fk_mentoria_mentor FOREIGN KEY (mentor_id) REFERENCES public.mentores(id);


--
-- Name: observaciones fk_observacion_mentoria; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.observaciones
    ADD CONSTRAINT fk_observacion_mentoria FOREIGN KEY (mentoria_id) REFERENCES public.mentorias(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reportes fk_resultado_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reportes
    ADD CONSTRAINT fk_resultado_id FOREIGN KEY (resultado_id) REFERENCES public.resultados(id) ON DELETE CASCADE;


--
-- Name: resultados fk_usuario_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resultados
    ADD CONSTRAINT fk_usuario_id FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: usuarios fk_usuario_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT fk_usuario_persona FOREIGN KEY (persona_id) REFERENCES public.personas(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ideas_negocio ideas_negocio_estado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ideas_negocio
    ADD CONSTRAINT ideas_negocio_estado_fkey FOREIGN KEY (estado) REFERENCES public.tipo_estados(id);


--
-- PostgreSQL database dump complete
--

