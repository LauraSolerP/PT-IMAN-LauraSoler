--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2026-09-14 19:11:17

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 527475)
-- Name: campos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.campos (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL,
    tipo_campo_id integer NOT NULL,
    obligatorio boolean DEFAULT false NOT NULL,
    valor_por_defecto text,
    creado_en timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.campos OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 527474)
-- Name: campos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.campos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.campos_id_seq OWNER TO postgres;

--
-- TOC entry 4990 (class 0 OID 0)
-- Dependencies: 221
-- Name: campos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.campos_id_seq OWNED BY public.campos.id;


--
-- TOC entry 226 (class 1259 OID 527508)
-- Name: inventario_campos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventario_campos (
    id integer NOT NULL,
    inventario_id integer NOT NULL,
    campo_id integer NOT NULL,
    orden integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.inventario_campos OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 527507)
-- Name: inventario_campos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventario_campos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventario_campos_id_seq OWNER TO postgres;

--
-- TOC entry 4991 (class 0 OID 0)
-- Dependencies: 225
-- Name: inventario_campos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventario_campos_id_seq OWNED BY public.inventario_campos.id;


--
-- TOC entry 220 (class 1259 OID 527463)
-- Name: inventarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventarios (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL,
    descripcion text,
    creado_en timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.inventarios OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 527462)
-- Name: inventarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventarios_id_seq OWNER TO postgres;

--
-- TOC entry 4992 (class 0 OID 0)
-- Dependencies: 219
-- Name: inventarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventarios_id_seq OWNED BY public.inventarios.id;


--
-- TOC entry 224 (class 1259 OID 527492)
-- Name: opciones_campo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opciones_campo (
    id integer NOT NULL,
    campo_id integer NOT NULL,
    valor character varying(150) NOT NULL,
    orden integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.opciones_campo OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 527491)
-- Name: opciones_campo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.opciones_campo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.opciones_campo_id_seq OWNER TO postgres;

--
-- TOC entry 4993 (class 0 OID 0)
-- Dependencies: 223
-- Name: opciones_campo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.opciones_campo_id_seq OWNED BY public.opciones_campo.id;


--
-- TOC entry 228 (class 1259 OID 527530)
-- Name: productos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productos (
    id integer NOT NULL,
    inventario_id integer NOT NULL,
    creado_en timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.productos OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 527529)
-- Name: productos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productos_id_seq OWNER TO postgres;

--
-- TOC entry 4994 (class 0 OID 0)
-- Dependencies: 227
-- Name: productos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productos_id_seq OWNED BY public.productos.id;


--
-- TOC entry 218 (class 1259 OID 527454)
-- Name: tipos_campo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipos_campo (
    id integer NOT NULL,
    codigo character varying(30) NOT NULL,
    nombre character varying(60) NOT NULL
);


ALTER TABLE public.tipos_campo OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 527453)
-- Name: tipos_campo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tipos_campo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tipos_campo_id_seq OWNER TO postgres;

--
-- TOC entry 4995 (class 0 OID 0)
-- Dependencies: 217
-- Name: tipos_campo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tipos_campo_id_seq OWNED BY public.tipos_campo.id;


--
-- TOC entry 230 (class 1259 OID 527544)
-- Name: valores_producto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.valores_producto (
    id integer NOT NULL,
    producto_id integer NOT NULL,
    campo_id integer NOT NULL,
    valor_texto text,
    valor_numero numeric,
    valor_fecha date,
    valor_booleano boolean,
    valor_opcion_id integer,
    CONSTRAINT valores_producto_check CHECK ((num_nonnulls(valor_texto, valor_numero, valor_fecha, valor_booleano, valor_opcion_id) <= 1))
);


ALTER TABLE public.valores_producto OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 527543)
-- Name: valores_producto_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.valores_producto_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.valores_producto_id_seq OWNER TO postgres;

--
-- TOC entry 4996 (class 0 OID 0)
-- Dependencies: 229
-- Name: valores_producto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.valores_producto_id_seq OWNED BY public.valores_producto.id;


--
-- TOC entry 4775 (class 2604 OID 527478)
-- Name: campos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campos ALTER COLUMN id SET DEFAULT nextval('public.campos_id_seq'::regclass);


--
-- TOC entry 4780 (class 2604 OID 527511)
-- Name: inventario_campos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_campos ALTER COLUMN id SET DEFAULT nextval('public.inventario_campos_id_seq'::regclass);


--
-- TOC entry 4773 (class 2604 OID 527466)
-- Name: inventarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventarios ALTER COLUMN id SET DEFAULT nextval('public.inventarios_id_seq'::regclass);


--
-- TOC entry 4778 (class 2604 OID 527495)
-- Name: opciones_campo id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opciones_campo ALTER COLUMN id SET DEFAULT nextval('public.opciones_campo_id_seq'::regclass);


--
-- TOC entry 4782 (class 2604 OID 527533)
-- Name: productos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos ALTER COLUMN id SET DEFAULT nextval('public.productos_id_seq'::regclass);


--
-- TOC entry 4772 (class 2604 OID 527457)
-- Name: tipos_campo id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos_campo ALTER COLUMN id SET DEFAULT nextval('public.tipos_campo_id_seq'::regclass);


--
-- TOC entry 4784 (class 2604 OID 527547)
-- Name: valores_producto id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valores_producto ALTER COLUMN id SET DEFAULT nextval('public.valores_producto_id_seq'::regclass);


--
-- TOC entry 4976 (class 0 OID 527475)
-- Dependencies: 222
-- Data for Name: campos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.campos (id, nombre, tipo_campo_id, obligatorio, valor_por_defecto, creado_en) FROM stdin;
1	Matricula	1	t	\N	2026-09-14 19:05:22.6719
2	Fecha de matriculacion	3	f	\N	2026-09-14 19:05:22.6719
3	Kilometros	2	f	0	2026-09-14 19:05:22.6719
4	Asegurado	4	f	false	2026-09-14 19:05:22.6719
5	Centro de trabajo	5	t	\N	2026-09-14 19:05:22.6719
6	Numero de serie	1	t	\N	2026-09-14 19:05:22.6719
7	Modelo	1	f	\N	2026-09-14 19:05:22.6719
8	Fecha de compra	3	f	\N	2026-09-14 19:05:22.6719
9	Estado	5	t	\N	2026-09-14 19:05:22.6719
\.


--
-- TOC entry 4980 (class 0 OID 527508)
-- Dependencies: 226
-- Data for Name: inventario_campos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventario_campos (id, inventario_id, campo_id, orden) FROM stdin;
1	1	1	1
2	1	2	2
3	1	3	3
4	1	4	4
5	1	5	5
6	2	6	1
7	2	7	2
8	2	8	3
9	2	9	4
\.


--
-- TOC entry 4974 (class 0 OID 527463)
-- Dependencies: 220
-- Data for Name: inventarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventarios (id, nombre, descripcion, creado_en) FROM stdin;
1	Vehiculos	Flota de vehiculos de la empresa	2026-09-14 19:05:22.6719
2	Material informatico	Equipos informaticos asignados a empleados	2026-09-14 19:05:22.6719
\.


--
-- TOC entry 4978 (class 0 OID 527492)
-- Dependencies: 224
-- Data for Name: opciones_campo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opciones_campo (id, campo_id, valor, orden) FROM stdin;
1	5	Sede Central	1
2	5	Delegacion Norte	2
3	5	Delegacion Sur	3
4	9	En uso	1
5	9	En reparacion	2
6	9	Baja	3
\.


--
-- TOC entry 4982 (class 0 OID 527530)
-- Dependencies: 228
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.productos (id, inventario_id, creado_en) FROM stdin;
1	1	2026-09-14 19:05:22.6719
2	1	2026-09-14 19:05:22.6719
3	1	2026-09-14 19:05:22.6719
4	1	2026-09-14 19:05:22.6719
5	2	2026-09-14 19:05:22.6719
6	2	2026-09-14 19:05:22.6719
7	2	2026-09-14 19:05:22.6719
8	2	2026-09-14 19:05:22.6719
\.


--
-- TOC entry 4972 (class 0 OID 527454)
-- Dependencies: 218
-- Data for Name: tipos_campo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tipos_campo (id, codigo, nombre) FROM stdin;
1	texto	Texto
2	numero	Numero
3	fecha	Fecha
4	booleano	Si/No
5	lista_opciones	Lista de opciones
\.


--
-- TOC entry 4984 (class 0 OID 527544)
-- Dependencies: 230
-- Data for Name: valores_producto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.valores_producto (id, producto_id, campo_id, valor_texto, valor_numero, valor_fecha, valor_booleano, valor_opcion_id) FROM stdin;
1	1	1	1234-BCD	\N	\N	\N	\N
2	2	1	5678-FGH	\N	\N	\N	\N
3	3	1	9012-JKL	\N	\N	\N	\N
4	4	1	3456-MNO	\N	\N	\N	\N
5	1	2	\N	\N	2019-03-15	\N	\N
6	2	2	\N	\N	2021-07-01	\N	\N
7	3	2	\N	\N	2017-11-20	\N	\N
8	4	2	\N	\N	2022-01-10	\N	\N
9	1	3	\N	82340	\N	\N	\N
10	2	3	\N	45210	\N	\N	\N
11	3	3	\N	130500	\N	\N	\N
12	4	3	\N	12800	\N	\N	\N
13	1	4	\N	\N	\N	t	\N
14	2	4	\N	\N	\N	t	\N
15	3	4	\N	\N	\N	f	\N
16	4	4	\N	\N	\N	t	\N
17	1	5	\N	\N	\N	\N	1
18	2	5	\N	\N	\N	\N	2
19	3	5	\N	\N	\N	\N	3
20	4	5	\N	\N	\N	\N	1
21	5	6	SN-000123	\N	\N	\N	\N
22	6	6	SN-000124	\N	\N	\N	\N
23	7	6	SN-000098	\N	\N	\N	\N
24	8	6	SN-000045	\N	\N	\N	\N
25	5	7	Dell Latitude 5420	\N	\N	\N	\N
26	6	7	HP EliteBook 840	\N	\N	\N	\N
27	7	7	Lenovo ThinkPad T14	\N	\N	\N	\N
28	8	7	Dell OptiPlex 3080	\N	\N	\N	\N
29	5	8	\N	\N	2022-05-02	\N	\N
30	6	8	\N	\N	2021-09-15	\N	\N
31	7	8	\N	\N	2019-02-20	\N	\N
32	8	8	\N	\N	2018-06-11	\N	\N
33	5	9	\N	\N	\N	\N	4
34	6	9	\N	\N	\N	\N	4
35	7	9	\N	\N	\N	\N	5
36	8	9	\N	\N	\N	\N	6
\.


--
-- TOC entry 4997 (class 0 OID 0)
-- Dependencies: 221
-- Name: campos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.campos_id_seq', 9, true);


--
-- TOC entry 4998 (class 0 OID 0)
-- Dependencies: 225
-- Name: inventario_campos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventario_campos_id_seq', 9, true);


--
-- TOC entry 4999 (class 0 OID 0)
-- Dependencies: 219
-- Name: inventarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventarios_id_seq', 2, true);


--
-- TOC entry 5000 (class 0 OID 0)
-- Dependencies: 223
-- Name: opciones_campo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.opciones_campo_id_seq', 6, true);


--
-- TOC entry 5001 (class 0 OID 0)
-- Dependencies: 227
-- Name: productos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productos_id_seq', 8, true);


--
-- TOC entry 5002 (class 0 OID 0)
-- Dependencies: 217
-- Name: tipos_campo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipos_campo_id_seq', 5, true);


--
-- TOC entry 5003 (class 0 OID 0)
-- Dependencies: 229
-- Name: valores_producto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.valores_producto_id_seq', 36, true);


--
-- TOC entry 4795 (class 2606 OID 527484)
-- Name: campos campos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campos
    ADD CONSTRAINT campos_pkey PRIMARY KEY (id);


--
-- TOC entry 4805 (class 2606 OID 527516)
-- Name: inventario_campos inventario_campos_inventario_id_campo_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_campos
    ADD CONSTRAINT inventario_campos_inventario_id_campo_id_key UNIQUE (inventario_id, campo_id);


--
-- TOC entry 4807 (class 2606 OID 527514)
-- Name: inventario_campos inventario_campos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_campos
    ADD CONSTRAINT inventario_campos_pkey PRIMARY KEY (id);


--
-- TOC entry 4791 (class 2606 OID 527473)
-- Name: inventarios inventarios_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventarios
    ADD CONSTRAINT inventarios_nombre_key UNIQUE (nombre);


--
-- TOC entry 4793 (class 2606 OID 527471)
-- Name: inventarios inventarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventarios
    ADD CONSTRAINT inventarios_pkey PRIMARY KEY (id);


--
-- TOC entry 4799 (class 2606 OID 527500)
-- Name: opciones_campo opciones_campo_campo_id_valor_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opciones_campo
    ADD CONSTRAINT opciones_campo_campo_id_valor_key UNIQUE (campo_id, valor);


--
-- TOC entry 4801 (class 2606 OID 527498)
-- Name: opciones_campo opciones_campo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opciones_campo
    ADD CONSTRAINT opciones_campo_pkey PRIMARY KEY (id);


--
-- TOC entry 4810 (class 2606 OID 527536)
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);


--
-- TOC entry 4787 (class 2606 OID 527461)
-- Name: tipos_campo tipos_campo_codigo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos_campo
    ADD CONSTRAINT tipos_campo_codigo_key UNIQUE (codigo);


--
-- TOC entry 4789 (class 2606 OID 527459)
-- Name: tipos_campo tipos_campo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos_campo
    ADD CONSTRAINT tipos_campo_pkey PRIMARY KEY (id);


--
-- TOC entry 4815 (class 2606 OID 527552)
-- Name: valores_producto valores_producto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valores_producto
    ADD CONSTRAINT valores_producto_pkey PRIMARY KEY (id);


--
-- TOC entry 4817 (class 2606 OID 527554)
-- Name: valores_producto valores_producto_producto_id_campo_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valores_producto
    ADD CONSTRAINT valores_producto_producto_id_campo_id_key UNIQUE (producto_id, campo_id);


--
-- TOC entry 4796 (class 1259 OID 527490)
-- Name: idx_campos_tipo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_campos_tipo ON public.campos USING btree (tipo_campo_id);


--
-- TOC entry 4802 (class 1259 OID 527528)
-- Name: idx_inv_campos_campo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inv_campos_campo ON public.inventario_campos USING btree (campo_id);


--
-- TOC entry 4803 (class 1259 OID 527527)
-- Name: idx_inv_campos_inventario; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inv_campos_inventario ON public.inventario_campos USING btree (inventario_id);


--
-- TOC entry 4797 (class 1259 OID 527506)
-- Name: idx_opciones_campo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_opciones_campo ON public.opciones_campo USING btree (campo_id);


--
-- TOC entry 4808 (class 1259 OID 527542)
-- Name: idx_productos_inventario; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_productos_inventario ON public.productos USING btree (inventario_id);


--
-- TOC entry 4811 (class 1259 OID 527571)
-- Name: idx_valores_campo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_valores_campo ON public.valores_producto USING btree (campo_id);


--
-- TOC entry 4812 (class 1259 OID 527572)
-- Name: idx_valores_opcion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_valores_opcion ON public.valores_producto USING btree (valor_opcion_id);


--
-- TOC entry 4813 (class 1259 OID 527570)
-- Name: idx_valores_producto; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_valores_producto ON public.valores_producto USING btree (producto_id);


--
-- TOC entry 4818 (class 2606 OID 527485)
-- Name: campos campos_tipo_campo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campos
    ADD CONSTRAINT campos_tipo_campo_id_fkey FOREIGN KEY (tipo_campo_id) REFERENCES public.tipos_campo(id);


--
-- TOC entry 4820 (class 2606 OID 527522)
-- Name: inventario_campos inventario_campos_campo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_campos
    ADD CONSTRAINT inventario_campos_campo_id_fkey FOREIGN KEY (campo_id) REFERENCES public.campos(id) ON DELETE CASCADE;


--
-- TOC entry 4821 (class 2606 OID 527517)
-- Name: inventario_campos inventario_campos_inventario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_campos
    ADD CONSTRAINT inventario_campos_inventario_id_fkey FOREIGN KEY (inventario_id) REFERENCES public.inventarios(id) ON DELETE CASCADE;


--
-- TOC entry 4819 (class 2606 OID 527501)
-- Name: opciones_campo opciones_campo_campo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opciones_campo
    ADD CONSTRAINT opciones_campo_campo_id_fkey FOREIGN KEY (campo_id) REFERENCES public.campos(id) ON DELETE CASCADE;


--
-- TOC entry 4822 (class 2606 OID 527537)
-- Name: productos productos_inventario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_inventario_id_fkey FOREIGN KEY (inventario_id) REFERENCES public.inventarios(id) ON DELETE CASCADE;


--
-- TOC entry 4823 (class 2606 OID 527560)
-- Name: valores_producto valores_producto_campo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valores_producto
    ADD CONSTRAINT valores_producto_campo_id_fkey FOREIGN KEY (campo_id) REFERENCES public.campos(id) ON DELETE CASCADE;


--
-- TOC entry 4824 (class 2606 OID 527555)
-- Name: valores_producto valores_producto_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valores_producto
    ADD CONSTRAINT valores_producto_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id) ON DELETE CASCADE;


--
-- TOC entry 4825 (class 2606 OID 527565)
-- Name: valores_producto valores_producto_valor_opcion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valores_producto
    ADD CONSTRAINT valores_producto_valor_opcion_id_fkey FOREIGN KEY (valor_opcion_id) REFERENCES public.opciones_campo(id);


-- Completed on 2026-09-14 19:11:17

--
-- PostgreSQL database dump complete
--

