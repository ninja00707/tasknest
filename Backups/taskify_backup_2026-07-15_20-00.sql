--
-- PostgreSQL database dump
--

\restrict ius0151wqx0BQXW0mDaXt051MUWBp1b63qjIxMX0Zob4DhFATataOQUeBKbR68Q

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: update_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$;


ALTER FUNCTION public.update_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.companies (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.companies OWNER TO postgres;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departments (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    code character varying(20) NOT NULL,
    company_id integer,
    parent_id integer,
    tier character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    is_shared boolean DEFAULT false,
    CONSTRAINT departments_tier_check CHECK (((tier)::text = ANY ((ARRAY['upper'::character varying, 'lower'::character varying])::text[])))
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    ticket_id integer,
    message text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(30) NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: sub_ticket_departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sub_ticket_departments (
    id integer NOT NULL,
    ticket_id integer NOT NULL,
    department_id integer NOT NULL,
    task_description text NOT NULL,
    status character varying(20) DEFAULT 'open'::character varying NOT NULL,
    progress_percent integer DEFAULT 0 NOT NULL,
    assigned_to_id integer,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT sub_ticket_departments_progress_percent_check CHECK (((progress_percent >= 0) AND (progress_percent <= 100))),
    CONSTRAINT sub_ticket_departments_status_check CHECK (((status)::text = ANY ((ARRAY['open'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'pending_approval'::character varying, 'approved'::character varying])::text[])))
);


ALTER TABLE public.sub_ticket_departments OWNER TO postgres;

--
-- Name: sub_ticket_departments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sub_ticket_departments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sub_ticket_departments_id_seq OWNER TO postgres;

--
-- Name: sub_ticket_departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sub_ticket_departments_id_seq OWNED BY public.sub_ticket_departments.id;


--
-- Name: ticket_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ticket_comments (
    id integer NOT NULL,
    ticket_id integer NOT NULL,
    user_id integer NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.ticket_comments OWNER TO postgres;

--
-- Name: ticket_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ticket_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ticket_comments_id_seq OWNER TO postgres;

--
-- Name: ticket_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ticket_comments_id_seq OWNED BY public.ticket_comments.id;


--
-- Name: ticket_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ticket_logs (
    id integer NOT NULL,
    ticket_id integer NOT NULL,
    acted_by_id integer NOT NULL,
    action character varying(50) NOT NULL,
    old_value character varying(100),
    new_value character varying(100),
    note text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.ticket_logs OWNER TO postgres;

--
-- Name: ticket_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ticket_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ticket_logs_id_seq OWNER TO postgres;

--
-- Name: ticket_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ticket_logs_id_seq OWNED BY public.ticket_logs.id;


--
-- Name: ticket_number_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ticket_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ticket_number_seq OWNER TO postgres;

--
-- Name: tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tickets (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text NOT NULL,
    status character varying(20) DEFAULT 'open'::character varying NOT NULL,
    priority character varying(20) DEFAULT 'medium'::character varying NOT NULL,
    created_by_id integer NOT NULL,
    created_by_dept integer NOT NULL,
    assigned_dept_id integer NOT NULL,
    assigned_to_id integer,
    transferred_from integer,
    transferred_at timestamp with time zone,
    closed_by_id integer,
    closed_at timestamp with time zone,
    reopened_at timestamp with time zone,
    reopen_count integer DEFAULT 0,
    due_date date,
    is_sub_ticket boolean DEFAULT false,
    parent_ticket_id integer,
    ticket_type character varying(20) DEFAULT 'standard'::character varying,
    overall_progress integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    ticket_number character varying(50),
    reset_token character varying(10),
    is_standard_ticket boolean DEFAULT false,
    is_multi_ticket boolean DEFAULT false,
    closed_label text,
    CONSTRAINT tickets_overall_progress_check CHECK (((overall_progress >= 0) AND (overall_progress <= 100))),
    CONSTRAINT tickets_priority_check CHECK (((priority)::text = ANY ((ARRAY['low'::character varying, 'medium'::character varying, 'high'::character varying, 'urgent'::character varying])::text[]))),
    CONSTRAINT tickets_status_check CHECK (((status)::text = ANY ((ARRAY['open'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'closed'::character varying])::text[]))),
    CONSTRAINT tickets_ticket_type_check CHECK (((ticket_type)::text = ANY ((ARRAY['standard'::character varying, 'multi_task'::character varying])::text[])))
);


ALTER TABLE public.tickets OWNER TO postgres;

--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tickets_id_seq OWNER TO postgres;

--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role_id integer NOT NULL,
    department_id integer NOT NULL,
    company_id integer NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    reset_token character varying(10),
    reset_token_expires timestamp with time zone,
    code character varying(20),
    must_reset_password boolean DEFAULT false,
    reports_to integer,
    designation character varying(200),
    last_active timestamp with time zone,
    see_all_companies boolean DEFAULT false NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: sub_ticket_departments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_ticket_departments ALTER COLUMN id SET DEFAULT nextval('public.sub_ticket_departments_id_seq'::regclass);


--
-- Name: ticket_comments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_comments ALTER COLUMN id SET DEFAULT nextval('public.ticket_comments_id_seq'::regclass);


--
-- Name: ticket_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_logs ALTER COLUMN id SET DEFAULT nextval('public.ticket_logs_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.companies (id, name, slug, created_at) FROM stdin;
0	UM Enterprises	um	2026-06-10 10:45:39.31327+05
1	Matrix Pharma	matrix	2026-06-10 10:45:39.31327+05
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departments (id, name, code, company_id, parent_id, tier, created_at, is_shared) FROM stdin;
51	Product Management [DXDX]	PM_DXDX	0	\N	lower	2026-06-15 12:53:54.138375+05	f
52	SMD [DXDX]	SMD_DXDX	0	\N	lower	2026-06-15 12:53:54.138375+05	f
53	Supply Chain [DXDX]	SC_DXDX	0	\N	lower	2026-06-15 12:53:54.138375+05	f
54	Sales [DXDX]	SAL_DXDX	0	\N	lower	2026-06-15 12:53:54.138375+05	f
55	Cash Management [FDFD]	CM_FDFD	0	\N	lower	2026-06-15 12:53:54.138375+05	f
56	Imports [FDFD]	IMP_FDFD	0	\N	lower	2026-06-15 12:53:54.138375+05	f
57	Indenting [FDFD]	IND_FDFD	0	\N	lower	2026-06-15 12:53:54.138375+05	f
58	Marketing Support [FDFD]	MS_FDFD	0	\N	lower	2026-06-15 12:53:54.138375+05	f
59	Procurement [FDFD]	PRO_FDFD	0	\N	lower	2026-06-15 12:53:54.138375+05	f
60	SMD [FDFD]	SMD_FDFD	0	\N	lower	2026-06-15 12:53:54.138375+05	f
61	Supply Chain [FDFD]	SC_FDFD	0	\N	lower	2026-06-15 12:53:54.138375+05	f
62	Warehouse [FDFD]	WH_FDFD	0	\N	lower	2026-06-15 12:53:54.138375+05	f
63	Marketing [FMAG]	MKT_FMAG	0	\N	lower	2026-06-15 12:53:54.138375+05	f
64	Sales and Distribution [FMAG]	SD_FMAG	0	\N	lower	2026-06-15 12:53:54.138375+05	f
65	Marketing [FMCG]	MKT_FMCG	0	\N	lower	2026-06-15 12:53:54.138375+05	f
66	Marketing Support [FMCG]	MS_FMCG	0	\N	lower	2026-06-15 12:53:54.138375+05	f
67	Sales and Distribution [FMCG]	SD_FMCG	0	\N	lower	2026-06-15 12:53:54.138375+05	f
68	Warehouse [FMCG]	WH_FMCG	0	\N	lower	2026-06-15 12:53:54.138375+05	f
69	Marketing [FMPG]	MKT_FMPG	0	\N	lower	2026-06-15 12:53:54.138375+05	f
70	Sales and Distribution [FMPG]	SD_FMPG	0	\N	lower	2026-06-15 12:53:54.138375+05	f
71	Vaccination Services [FMPG]	VAC_FMPG	0	\N	lower	2026-06-15 12:53:54.138375+05	f
72	Marketing [FMSG]	MKT_FMSG	0	\N	lower	2026-06-15 12:53:54.138375+05	f
73	Sales and Distribution [FMSG]	SD_FMSG	0	\N	lower	2026-06-15 12:53:54.138375+05	f
74	Accounts and Finance [HOCM]	AF_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
76	Compliance and Govt Affairs [HOCM]	CGA_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
77	Human Resources [HOCM]	HR_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
78	Imports [HOCM]	IMP_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
80	Planning [HOCM]	PLN_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
81	Procurement [HOCM]	PRO_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
82	Production [HOCM]	PRD_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
83	QA and Regulatory Affairs [HOCM]	QA_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
84	R and D [HOCM]	RD_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
85	Secretarial [HOCM]	SEC_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
86	Warehouse [HOCM]	WH_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
87	Administration [HOCM Daily Wager]	ADM_HOCMDW	0	\N	lower	2026-06-15 12:53:54.138375+05	f
88	Production [HOCM Daily Wager]	PRD_HOCMDW	0	\N	lower	2026-06-15 12:53:54.138375+05	f
89	Warehouse [HOCM Daily Wager]	WH_HOCMDW	0	\N	lower	2026-06-15 12:53:54.138375+05	f
90	SMD [LAFM]	SMD_LAFM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
91	Warehouse [LAFM]	WH_LAFM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
92	Product Management [LARA]	PM_LARA	0	\N	lower	2026-06-15 12:53:54.138375+05	f
93	SMD [LARA]	SMD_LARA	0	\N	lower	2026-06-15 12:53:54.138375+05	f
94	Warehouse [LARA]	WH_LARA	0	\N	lower	2026-06-15 12:53:54.138375+05	f
95	SMD [LBFM]	SMD_LBFM	0	\N	lower	2026-06-15 12:53:54.138375+05	f
100	Developer	DEV	0	\N	upper	2026-06-15 12:53:54.138375+05	f
50	Administration [Combine Staff]	ADM_CS	0	\N	lower	2026-06-15 12:53:54.138375+05	t
79	Information Technology [HOCM]	IT_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	t
200	Human Resource	HUMRES	1	\N	lower	2026-06-15 13:05:25.698127+05	f
201	Quality Control	QUACON	1	\N	lower	2026-06-15 13:05:25.698127+05	f
202	Procurement	PROCU	1	\N	lower	2026-06-15 13:05:25.698127+05	f
203	Digital Marketing	DIGMAR	1	\N	lower	2026-06-15 13:05:25.698127+05	f
204	Creative	CREAT	1	\N	lower	2026-06-15 13:05:25.698127+05	f
205	Commercial Excellence	COMEXC	1	\N	lower	2026-06-15 13:05:25.698127+05	f
206	Business Development	BUSDEV	1	\N	lower	2026-06-15 13:05:25.698127+05	f
207	Projects	PROJE	1	\N	lower	2026-06-15 13:05:25.698127+05	f
208	Distribution	DISTR	1	\N	lower	2026-06-15 13:05:25.698127+05	f
209	Marketing Services	MARSER	1	\N	lower	2026-06-15 13:05:25.698127+05	f
210	Sales	SALES	1	\N	lower	2026-06-15 13:05:25.698127+05	f
211	Marketing	MARKE	1	\N	lower	2026-06-15 13:05:25.698127+05	f
212	Finance	FINAN	1	\N	lower	2026-06-15 13:05:25.698127+05	f
213	Finish Goods	FINGOO	1	\N	lower	2026-06-15 13:05:25.698127+05	f
214	Production	PRODU	1	\N	lower	2026-06-15 13:05:25.698127+05	f
215	Quality Assurance	QUAASS	1	\N	lower	2026-06-15 13:05:25.698127+05	f
216	Engineering	ENGIN	1	\N	lower	2026-06-15 13:05:25.698127+05	f
217	Export	EXPOR	1	\N	lower	2026-06-15 13:05:25.698127+05	f
218	Regulatory Affairs	REGAFF	1	\N	lower	2026-06-15 13:05:25.698127+05	f
219	Maintenance	MAINT	1	\N	lower	2026-06-15 13:05:25.698127+05	f
75	Administration [HOCM]	ADM_HOCM	0	\N	lower	2026-06-15 12:53:54.138375+05	t
220	ERP[HOCM]	ERP_HOCM	0	\N	lower	2026-06-22 12:59:19.19343+05	f
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, ticket_id, message, is_read, created_at) FROM stdin;
328	394	9	New Ticket Created: Draft an experience letter for MR. QASIM	f	2026-06-20 12:29:25.814392+05
330	390	9	New Ticket Created: Draft an experience letter for MR. QASIM	f	2026-06-20 12:29:25.814392+05
1097	168	107	New Ticket Created: Requirement for Laptop Chargers for Mr. Aleem Shah and Mr. Hassan Adil	t	2026-07-07 13:37:52.147547+05
1108	400	111	Ticket #111 self-assigned by Muhammad Fashi Ullah Khan	f	2026-07-08 15:08:35.06496+05
333	344	9	New Ticket Created: Draft an experience letter for MR. QASIM	f	2026-06-20 12:29:25.814392+05
334	157	9	New Ticket Created: Draft an experience letter for MR. QASIM	f	2026-06-20 12:29:25.814392+05
1118	157	117	Ticket #117 status changed to closed	f	2026-07-09 10:15:12.084457+05
344	394	9	Ticket #9 status changed to completed	f	2026-06-20 12:31:11.888151+05
1127	170	126	New Ticket Created: Open Vendor	f	2026-07-10 11:18:15.964942+05
346	390	9	Ticket #9 status changed to completed	f	2026-06-20 12:31:11.888151+05
349	344	9	Ticket #9 status changed to completed	f	2026-06-20 12:31:11.888151+05
332	155	9	New Ticket Created: Draft an experience letter for MR. QASIM	t	2026-06-20 12:29:25.814392+05
348	155	9	Ticket #9 status changed to completed	t	2026-06-20 12:31:11.888151+05
63	155	4	New Ticket Created: LCD Display Problem	t	2026-06-20 11:04:44.254008+05
80	155	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	t	2026-06-20 11:09:05.77505+05
358	394	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
360	314	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
361	341	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
362	299	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
363	330	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
364	309	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
365	390	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
366	311	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
367	286	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
368	338	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
369	310	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
370	315	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
372	303	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
373	274	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
374	163	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
377	312	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
378	340	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
379	317	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
380	342	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
382	339	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
383	326	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
385	344	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
386	336	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
387	308	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
388	313	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
82	166	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	t	2026-06-20 11:09:05.77505+05
65	166	4	New Ticket Created: LCD Display Problem	t	2026-06-20 11:04:44.254008+05
384	166	11	New Ticket Created: Team view	t	2026-06-20 15:33:04.755787+05
331	153	9	New Ticket Created: Draft an experience letter for MR. QASIM	t	2026-06-20 12:29:25.814392+05
347	153	9	Ticket #9 status changed to completed	t	2026-06-20 12:31:11.888151+05
57	153	4	New Ticket Created: LCD Display Problem	t	2026-06-20 11:04:44.254008+05
75	153	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	t	2026-06-20 11:09:05.77505+05
81	368	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	t	2026-06-20 11:09:05.77505+05
64	368	4	New Ticket Created: LCD Display Problem	t	2026-06-20 11:04:44.254008+05
381	368	11	New Ticket Created: Team view	t	2026-06-20 15:33:04.755787+05
375	168	11	New Ticket Created: Team view	t	2026-06-20 15:33:04.755787+05
61	168	4	New Ticket Created: LCD Display Problem	t	2026-06-20 11:04:44.254008+05
78	168	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	t	2026-06-20 11:09:05.77505+05
329	156	9	New Ticket Created: Draft an experience letter for MR. QASIM	t	2026-06-20 12:29:25.814392+05
345	156	9	Ticket #9 status changed to completed	t	2026-06-20 12:31:11.888151+05
55	156	4	New Ticket Created: LCD Display Problem	t	2026-06-20 11:04:44.254008+05
73	156	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	t	2026-06-20 11:09:05.77505+05
359	162	11	New Ticket Created: Team view	t	2026-06-20 15:33:04.755787+05
54	162	4	New Ticket Created: LCD Display Problem	t	2026-06-20 11:04:44.254008+05
72	162	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	t	2026-06-20 11:09:05.77505+05
389	164	11	New Ticket Created: Team view	t	2026-06-20 15:33:04.755787+05
68	164	4	New Ticket Created: LCD Display Problem	t	2026-06-20 11:04:44.254008+05
85	164	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	t	2026-06-20 11:09:05.77505+05
376	167	11	New Ticket Created: Team view	t	2026-06-20 15:33:04.755787+05
62	167	4	New Ticket Created: LCD Display Problem	t	2026-06-20 11:04:44.254008+05
79	167	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	t	2026-06-20 11:09:05.77505+05
69	154	4	New Ticket Created: LCD Display Problem	t	2026-06-20 11:04:44.254008+05
335	154	9	New Ticket Created: Draft an experience letter for MR. QASIM	t	2026-06-20 12:29:25.814392+05
350	154	9	Ticket #9 status changed to completed	t	2026-06-20 12:31:11.888151+05
53	394	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
56	390	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
59	274	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
60	163	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
66	344	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
67	157	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
70	264	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
71	394	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
74	390	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
76	274	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
77	163	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
83	344	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
84	157	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
1098	89	109	New Ticket Created: Request for mouse pad	f	2026-07-08 11:21:56.871543+05
87	264	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
88	394	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
1099	400	111	New Ticket Created: request for a new  mouse pad	f	2026-07-08 11:22:31.54316+05
91	390	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
406	165	15	New Ticket Created: Implementation	t	2026-06-22 11:20:01.818228+05
93	274	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
94	163	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
100	344	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
101	157	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
104	264	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
105	394	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
108	390	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
110	274	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
111	163	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
117	344	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
118	157	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
121	264	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
336	157	9	You have been assigned to Ticket #9	f	2026-06-20 12:29:26.052285+05
337	394	9	Adnan Najeeb commented on Ticket #9	f	2026-06-20 12:30:08.628711+05
339	390	9	Adnan Najeeb commented on Ticket #9	f	2026-06-20 12:30:08.628711+05
341	344	9	Adnan Najeeb commented on Ticket #9	f	2026-06-20 12:30:08.628711+05
342	157	9	Adnan Najeeb commented on Ticket #9	f	2026-06-20 12:30:08.628711+05
97	155	4	Ticket #4 status changed to completed	t	2026-06-20 11:09:23.789228+05
114	155	4	Ticket #4 status changed to closed	t	2026-06-20 11:09:35.468387+05
351	394	9	Ticket #9 status changed to closed	f	2026-06-20 12:34:56.296398+05
353	390	9	Ticket #9 status changed to closed	f	2026-06-20 12:34:56.296398+05
355	344	9	Ticket #9 status changed to closed	f	2026-06-20 12:34:56.296398+05
356	157	9	Ticket #9 status changed to closed	f	2026-06-20 12:34:56.296398+05
390	264	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
391	273	13	New Ticket Created: Request for shelf	f	2026-06-22 09:44:02.131104+05
392	394	13	New Ticket Created: Request for shelf	f	2026-06-22 09:44:02.131104+05
393	390	13	New Ticket Created: Request for shelf	f	2026-06-22 09:44:02.131104+05
394	306	13	New Ticket Created: Request for shelf	f	2026-06-22 09:44:02.131104+05
395	376	13	New Ticket Created: Request for shelf	f	2026-06-22 09:44:02.131104+05
396	251	13	New Ticket Created: Request for shelf	f	2026-06-22 09:44:02.131104+05
397	287	13	New Ticket Created: Request for shelf	f	2026-06-22 09:44:02.131104+05
398	362	13	New Ticket Created: Request for shelf	f	2026-06-22 09:44:02.131104+05
399	344	13	New Ticket Created: Request for shelf	f	2026-06-22 09:44:02.131104+05
400	260	13	New Ticket Created: Request for shelf	f	2026-06-22 09:44:02.131104+05
401	270	13	New Ticket Created: Request for shelf	f	2026-06-22 09:44:02.131104+05
402	163	11	Manager Dilawar Farrukh Rauf assigned you to Ticket #11	f	2026-06-22 11:13:40.219881+05
403	394	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
405	390	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
407	274	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
408	163	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
413	344	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
416	264	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
417	394	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
419	314	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
420	341	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
421	299	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
422	330	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
423	309	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
424	390	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
425	311	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
426	286	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
427	338	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
99	166	4	Ticket #4 status changed to completed	t	2026-06-20 11:09:23.789228+05
116	166	4	Ticket #4 status changed to closed	t	2026-06-20 11:09:35.468387+05
412	166	15	New Ticket Created: Implementation	t	2026-06-22 11:20:01.818228+05
92	153	4	Ticket #4 status changed to completed	t	2026-06-20 11:09:23.789228+05
109	153	4	Ticket #4 status changed to closed	t	2026-06-20 11:09:35.468387+05
411	368	15	New Ticket Created: Implementation	t	2026-06-22 11:20:01.818228+05
115	368	4	Ticket #4 status changed to closed	t	2026-06-20 11:09:35.468387+05
98	368	4	Ticket #4 status changed to completed	t	2026-06-20 11:09:23.789228+05
95	168	4	Ticket #4 status changed to completed	t	2026-06-20 11:09:23.789228+05
112	168	4	Ticket #4 status changed to closed	t	2026-06-20 11:09:35.468387+05
409	168	15	New Ticket Created: Implementation	t	2026-06-22 11:20:01.818228+05
90	156	4	Ticket #4 status changed to completed	t	2026-06-20 11:09:23.789228+05
107	156	4	Ticket #4 status changed to closed	t	2026-06-20 11:09:35.468387+05
338	156	9	Adnan Najeeb commented on Ticket #9	t	2026-06-20 12:30:08.628711+05
89	162	4	Ticket #4 status changed to completed	t	2026-06-20 11:09:23.789228+05
106	162	4	Ticket #4 status changed to closed	t	2026-06-20 11:09:35.468387+05
404	162	15	New Ticket Created: Implementation	t	2026-06-22 11:20:01.818228+05
418	162	11	Ticket #11 status changed to completed	t	2026-06-22 11:54:06.702537+05
102	164	4	Ticket #4 status changed to completed	t	2026-06-20 11:09:23.789228+05
119	164	4	Ticket #4 status changed to closed	t	2026-06-20 11:09:35.468387+05
414	164	15	New Ticket Created: Implementation	t	2026-06-22 11:20:01.818228+05
415	1	15	New Ticket Created: Implementation	t	2026-06-22 11:20:01.818228+05
96	167	4	Ticket #4 status changed to completed	t	2026-06-20 11:09:23.789228+05
113	167	4	Ticket #4 status changed to closed	t	2026-06-20 11:09:35.468387+05
410	167	15	New Ticket Created: Implementation	t	2026-06-22 11:20:01.818228+05
86	154	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	t	2026-06-20 11:09:05.77505+05
103	154	4	Ticket #4 status changed to completed	t	2026-06-20 11:09:23.789228+05
120	154	4	Ticket #4 status changed to closed	t	2026-06-20 11:09:35.468387+05
343	154	9	Adnan Najeeb commented on Ticket #9	t	2026-06-20 12:30:08.628711+05
357	154	9	Ticket #9 status changed to closed	t	2026-06-20 12:34:56.296398+05
428	310	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
429	315	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
431	303	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
432	274	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
1100	71	113	New Ticket Created: SAP ID (View Only)	t	2026-07-08 11:36:52.818376+05
1110	400	118	New Sub-Ticket #118 created from #111	f	2026-07-08 15:10:48.825042+05
435	312	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
436	340	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
437	317	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
438	342	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
440	339	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
441	326	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
430	165	11	Ticket #11 status changed to completed	t	2026-06-22 11:54:06.702537+05
443	344	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
444	336	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
445	308	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
446	313	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
448	264	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
449	394	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
451	314	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
452	341	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
453	299	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
454	330	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
455	309	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
456	390	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
457	311	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
458	286	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
459	338	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
460	310	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
461	315	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
463	303	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
464	274	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
467	312	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
468	340	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
469	317	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
470	342	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
472	339	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
473	326	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
475	344	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
476	336	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
477	308	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
478	313	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
480	264	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
481	394	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
483	314	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
484	341	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
485	330	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
486	309	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
487	390	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
488	311	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
489	286	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
490	338	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
491	310	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
492	315	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
494	303	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
495	274	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
496	163	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
499	312	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
500	340	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
501	317	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
502	342	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
504	339	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
505	326	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
507	344	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
508	336	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
509	308	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
510	313	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
512	264	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
513	394	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
515	314	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
442	166	11	Ticket #11 status changed to completed	t	2026-06-22 11:54:06.702537+05
474	166	11	Ticket #11 status changed to closed	t	2026-06-22 11:54:19.501086+05
503	368	10	Ticket #10 status changed to completed	t	2026-06-22 11:54:37.837099+05
439	368	11	Ticket #11 status changed to completed	t	2026-06-22 11:54:06.702537+05
471	368	11	Ticket #11 status changed to closed	t	2026-06-22 11:54:19.501086+05
433	168	11	Ticket #11 status changed to completed	t	2026-06-22 11:54:06.702537+05
450	162	11	Ticket #11 status changed to closed	t	2026-06-22 11:54:19.501086+05
482	162	10	Ticket #10 status changed to completed	t	2026-06-22 11:54:37.837099+05
514	162	10	Ticket #10 status changed to closed	t	2026-06-22 11:55:07.825521+05
447	164	11	Ticket #11 status changed to completed	t	2026-06-22 11:54:06.702537+05
479	164	11	Ticket #11 status changed to closed	t	2026-06-22 11:54:19.501086+05
511	164	10	Ticket #10 status changed to completed	t	2026-06-22 11:54:37.837099+05
434	167	11	Ticket #11 status changed to completed	t	2026-06-22 11:54:06.702537+05
466	167	11	Ticket #11 status changed to closed	t	2026-06-22 11:54:19.501086+05
516	341	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
517	330	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
518	309	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
519	390	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
520	311	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
521	286	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
522	338	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
523	310	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
524	315	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
526	303	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
527	274	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
528	163	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
1111	157	117	Ticket #117 status changed to completed	f	2026-07-08 15:19:00.1434+05
531	312	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
532	340	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
533	317	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
534	342	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
536	339	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
537	326	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
539	344	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
540	336	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
541	308	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
542	313	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
544	264	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
545	394	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
546	314	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
547	341	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
548	299	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
549	330	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
550	309	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
551	390	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
552	311	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
553	286	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
554	306	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
555	376	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
556	338	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
557	310	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
558	251	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
559	315	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
560	303	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
561	287	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
562	312	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
563	340	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
564	317	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
565	342	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
566	339	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
567	326	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
568	344	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
569	336	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
570	308	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
571	313	17	New Ticket Created: GMP shoes require	f	2026-06-22 12:31:01.0387+05
572	116	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
573	394	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
574	146	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
575	350	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
576	132	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
577	364	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
578	114	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
579	115	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
580	112	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
581	135	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
582	127	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
583	124	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
584	149	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
585	390	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
586	269	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
587	121	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
588	117	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
589	119	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
590	113	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
591	125	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
592	147	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
593	358	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
594	120	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
595	131	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
596	357	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
597	151	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
598	283	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
599	347	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
600	138	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
601	134	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
535	368	10	Ticket #10 status changed to closed	t	2026-06-22 11:55:07.825521+05
529	168	10	Ticket #10 status changed to closed	t	2026-06-22 11:55:07.825521+05
543	164	10	Ticket #10 status changed to closed	t	2026-06-22 11:55:07.825521+05
602	144	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
603	363	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
604	327	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
605	118	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
606	133	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
607	111	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
1102	172	105	Manager Muhammad Fahim assigned you to Ticket #105	f	2026-07-08 12:09:50.566298+05
609	128	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
610	126	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
611	344	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
612	367	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
613	142	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
614	355	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
615	318	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
616	136	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
617	150	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
618	359	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
619	140	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
620	139	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
621	137	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
622	122	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
623	141	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
624	250	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
625	110	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
626	145	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
627	148	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
628	129	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
629	130	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
630	143	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
631	116	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
632	394	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
633	146	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
634	350	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
635	132	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
636	364	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
637	114	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
638	115	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
639	112	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
640	135	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
641	127	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
642	124	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
643	149	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
644	390	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
645	269	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
646	121	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
647	117	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
648	119	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
649	113	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
650	125	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
651	147	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
652	358	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
653	120	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
654	131	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
655	357	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
656	151	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
657	283	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
658	347	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
659	138	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
660	134	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
661	144	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
662	363	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
663	327	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
664	118	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
665	133	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
666	111	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
667	128	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
668	126	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
669	344	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
670	367	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
671	142	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
672	355	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
673	318	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
674	136	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
675	150	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
676	359	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
677	140	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
678	139	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
679	137	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
680	122	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
681	141	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
682	250	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
683	110	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
684	145	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
685	148	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
686	129	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
687	130	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
688	143	19	Ticket #19 self-assigned by Huraira Khan	f	2026-06-22 12:46:45.732344+05
689	116	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
690	394	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
691	146	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
692	350	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
693	132	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
694	364	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
695	114	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
696	115	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
697	112	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
698	135	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
699	127	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
700	124	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
701	149	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
702	390	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
703	269	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
704	121	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
705	117	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
706	119	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
707	113	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
708	125	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
709	147	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
710	358	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
711	120	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
712	131	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
713	357	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
714	151	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
715	283	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
716	347	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
717	138	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
718	134	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
719	144	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
720	363	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
721	327	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
722	118	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
723	133	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
724	111	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
725	128	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
726	126	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
727	344	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
728	367	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
729	142	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
730	355	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
731	318	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
732	136	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
733	150	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
734	359	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
735	140	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
736	139	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
737	137	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
738	122	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
739	141	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
740	250	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
741	110	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
742	145	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
743	148	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
744	129	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
745	130	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
746	143	19	Ticket #19 status changed to completed	f	2026-06-22 14:40:42.480407+05
747	116	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
748	394	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
749	146	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
750	350	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
751	132	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
752	364	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
753	114	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
754	115	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
755	112	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
756	135	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
757	127	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
758	124	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
759	149	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
760	390	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
761	269	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
762	121	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
763	117	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
764	119	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
765	113	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
766	125	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
767	147	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
768	358	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
769	120	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
770	131	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
771	357	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
772	151	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
773	283	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
774	347	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
775	138	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
776	134	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
777	144	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
778	363	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
779	327	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
780	118	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
781	133	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
782	111	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
783	128	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
784	126	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
785	344	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
786	367	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
787	142	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
788	355	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
789	318	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
790	136	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
791	150	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
792	359	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
793	140	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
794	139	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
795	137	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
796	122	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
797	141	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
798	250	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
799	110	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
800	145	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
801	148	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
802	129	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
803	130	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
804	143	19	Ticket #19 status changed to closed	f	2026-06-22 15:12:25.240178+05
805	394	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
806	390	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
1038	1	83	Ticket #83 status changed to closed	t	2026-07-03 11:01:41.144359+05
809	274	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
810	163	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
808	165	3	Azhan Ahmed Qureshi commented on Ticket #3	t	2026-06-22 15:36:42.601662+05
813	155	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
815	344	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
816	157	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
818	264	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
819	394	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
820	314	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
821	341	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
822	299	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
823	330	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
824	309	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
825	390	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
826	311	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
827	286	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
828	376	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
829	338	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
830	310	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
831	251	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
832	315	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
833	303	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
834	287	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
835	312	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
836	340	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
837	317	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
838	342	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
839	339	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
840	326	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
841	344	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
842	336	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
843	308	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
844	313	17	Ticket #17 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:45.965829+05
845	273	13	Ticket #13 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:53.850451+05
846	394	13	Ticket #13 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:53.850451+05
847	390	13	Ticket #13 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:53.850451+05
848	376	13	Ticket #13 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:53.850451+05
849	251	13	Ticket #13 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:53.850451+05
850	287	13	Ticket #13 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:53.850451+05
851	362	13	Ticket #13 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:53.850451+05
852	344	13	Ticket #13 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:53.850451+05
853	260	13	Ticket #13 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:53.850451+05
854	270	13	Ticket #13 self-assigned by Daniyal Jawaid	f	2026-06-23 11:16:53.850451+05
855	394	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
856	390	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
859	274	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
860	163	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
863	155	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
814	368	3	Azhan Ahmed Qureshi commented on Ticket #3	t	2026-06-22 15:36:42.601662+05
811	168	3	Azhan Ahmed Qureshi commented on Ticket #3	t	2026-06-22 15:36:42.601662+05
861	168	3	Ticket #3 status changed to completed	t	2026-06-23 11:59:13.726715+05
812	167	3	Azhan Ahmed Qureshi commented on Ticket #3	t	2026-06-22 15:36:42.601662+05
862	167	3	Ticket #3 status changed to completed	t	2026-06-23 11:59:13.726715+05
817	154	3	Azhan Ahmed Qureshi commented on Ticket #3	t	2026-06-22 15:36:42.601662+05
1104	170	107	Manager Muhammad Fahim assigned you to Ticket #107	f	2026-07-08 12:09:58.628191+05
865	344	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
866	157	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
868	264	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
869	394	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
870	390	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
1105	168	107	Manager Muhammad Fahim assigned you to Ticket #107	t	2026-07-08 12:09:58.628191+05
1112	167	116	Muhammad Sufiyan commented on Ticket #116	f	2026-07-08 16:04:23.995639+05
873	274	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
874	163	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
877	155	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
1045	166	78	Ticket #78 status changed to completed	t	2026-07-03 11:48:05.767159+05
879	344	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
880	157	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
1121	154	121	Ticket #121 status changed to closed	t	2026-07-09 10:16:55.995957+05
882	264	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
883	163	21	New Ticket Created: Requesting approval of attendance 13-June	f	2026-06-24 10:19:45.507413+05
538	166	10	Ticket #10 status changed to closed	t	2026-06-22 11:55:07.825521+05
506	166	10	Ticket #10 status changed to completed	t	2026-06-22 11:54:37.837099+05
340	153	9	Adnan Najeeb commented on Ticket #9	t	2026-06-20 12:30:08.628711+05
354	153	9	Ticket #9 status changed to closed	t	2026-06-20 12:34:56.296398+05
807	153	3	Azhan Ahmed Qureshi commented on Ticket #3	t	2026-06-22 15:36:42.601662+05
857	153	3	Ticket #3 status changed to completed	t	2026-06-23 11:59:13.726715+05
871	153	3	Ticket #3 status changed to closed	t	2026-06-23 11:59:25.52165+05
884	66	23	New Ticket Created: Need Field Force List	f	2026-06-29 10:46:28.228047+05
885	66	23	Ticket #23 self-assigned by Akber Mughal	f	2026-06-29 11:23:55.76569+05
886	223	25	New Ticket Created: Mouse required , UM-LA dept	f	2026-06-29 11:24:18.255812+05
887	223	25	Ticket #25 self-assigned by Adnan Zahid 	f	2026-06-29 11:27:25.943779+05
888	223	25	Ticket #25 status changed to completed	f	2026-06-29 12:00:00.281551+05
889	223	25	Ticket #25 status changed to closed	f	2026-06-29 12:04:35.645294+05
1120	154	121	Ticket #121 status changed to completed	t	2026-07-09 10:16:45.615751+05
1119	154	121	Ticket #121 self-assigned by Muhammad Hamza Khan	t	2026-07-09 10:16:32.192334+05
892	65	27	New Ticket Created: Zong Internet Devices	f	2026-06-29 13:59:05.656929+05
1103	154	105	Manager Muhammad Fahim assigned you to Ticket #105	t	2026-07-08 12:09:50.566298+05
894	66	22	Akber Mughal commented on Ticket #22	f	2026-06-29 15:46:59.591635+05
895	66	23	Ticket #23 status changed to completed	f	2026-06-29 15:47:40.288628+05
896	66	23	Ticket #23 status changed to closed	f	2026-06-29 15:47:48.774247+05
897	65	27	Ticket #27 self-assigned by Dilawar Farrukh Rauf	f	2026-06-29 16:37:15.403773+05
1130	162	130	Ticket #130 self-assigned by Muhammad Yahya Ajmal	f	2026-07-11 13:03:26.525953+05
899	65	26	Dilawar Farrukh Rauf commented on Ticket #26	f	2026-06-30 09:45:38.1147+05
900	65	22	Ticket #22 status changed to completed	f	2026-06-30 10:37:27.22801+05
1134	162	132	New Ticket Created: Laptop Screen	f	2026-07-11 13:05:41.881855+05
1091	123	47	Manager Muhammad Fahim assigned you to Ticket #47	t	2026-07-07 09:49:34.938919+05
1142	170	128	Manager Muhammad Fahim assigned you to Ticket #128	f	2026-07-14 11:32:03.775021+05
904	137	35	New Ticket Created: Filling Of LPG in new cylinder Gas for Green house	f	2026-06-30 11:51:36.648053+05
905	116	36	New Ticket Created: Purchasing of Air Pump for HO Vehicles	f	2026-06-30 12:08:27.406223+05
906	137	36	New Ticket Created: Purchasing of Air Pump for HO Vehicles	f	2026-06-30 12:08:27.406223+05
908	137	37	New Ticket Created: Comparison of Comercial Vehicles	f	2026-06-30 12:14:00.863045+05
909	137	39	New Ticket Created: Improvement in Taskify (SPell Check)	f	2026-06-30 12:31:58.224976+05
910	138	40	New Ticket Created: P.R For three Fans AC/DC Fan	f	2026-06-30 12:37:08.143748+05
911	137	40	New Ticket Created: P.R For three Fans AC/DC Fan	f	2026-06-30 12:37:08.143748+05
912	157	42	New Ticket Created: Printer Issue	f	2026-06-30 12:37:15.70778+05
913	157	42	Ticket #42 self-assigned by Adnan Zahid 	f	2026-06-30 12:38:21.461618+05
914	157	42	Ticket #42 status changed to completed	f	2026-06-30 12:43:10.044238+05
915	157	42	Ticket #42 status changed to closed	f	2026-06-30 12:43:17.131475+05
918	137	40	Ticket #40 status changed to completed	f	2026-06-30 12:57:33.623804+05
922	137	40	Kamran commented on Ticket #40	f	2026-06-30 13:01:52.45463+05
925	138	40	Ticket #40 status changed to closed	f	2026-06-30 14:25:29.247118+05
926	137	35	Ticket #35 self-assigned by Mohsin Ahmed Chohan	f	2026-06-30 14:29:24.230177+05
927	137	35	Mohsin Ahmed Chohan commented on Ticket #35	f	2026-06-30 14:29:48.658838+05
933	137	35	Muhammad Fahim commented on Ticket #35	f	2026-06-30 14:35:23.354158+05
935	170	33	Muhammad Fahim commented on Ticket #33	f	2026-06-30 14:39:02.035384+05
938	137	36	Ticket #36 status changed to completed	f	2026-06-30 14:40:13.971714+05
939	137	36	Abdul Rehman commented on Ticket #36	f	2026-06-30 14:42:14.035939+05
941	116	36	Ticket #36 status changed to closed	f	2026-06-30 14:54:30.110128+05
916	368	41	Ticket #41 status changed to completed	t	2026-06-30 12:55:54.524836+05
891	368	24	Ticket #24 status changed to closed	t	2026-06-29 12:35:26.663145+05
890	368	24	Ticket #24 status changed to completed	t	2026-06-29 12:13:36.007533+05
864	368	3	Ticket #3 status changed to completed	t	2026-06-23 11:59:13.726715+05
878	368	3	Ticket #3 status changed to closed	t	2026-06-23 11:59:25.52165+05
930	123	45	Muhammad Fahim commented on Ticket #45	t	2026-06-30 14:33:59.921193+05
875	168	3	Ticket #3 status changed to closed	t	2026-06-23 11:59:25.52165+05
893	168	15	Ticket #15 self-assigned by Qasim	t	2026-06-29 15:39:05.627861+05
898	168	29	New Ticket Created: Procurement of Refurb System for Mr. Sohail Malik	t	2026-06-29 17:13:43.548005+05
901	168	29	Ticket #29 self-assigned by Mohsin Ahmed Chohan	t	2026-06-30 10:47:26.69746+05
907	113	37	New Ticket Created: Comparison of Comercial Vehicles	t	2026-06-30 12:14:00.863045+05
932	170	35	Muhammad Fahim commented on Ticket #35	t	2026-06-30 14:35:23.354158+05
876	167	3	Ticket #3 status changed to closed	t	2026-06-23 11:59:25.52165+05
917	193	44	New Ticket Created: Required Net 200 running ft.	t	2026-06-30 12:56:56.193924+05
931	193	45	Muhammad Fahim commented on Ticket #45	t	2026-06-30 14:33:59.921193+05
929	193	45	New Sub-Ticket #45 created from #44	t	2026-06-30 14:32:08.772382+05
919	193	44	Ticket #44 self-assigned by Huraira Khan	t	2026-06-30 12:58:19.215349+05
867	154	3	Ticket #3 status changed to completed	t	2026-06-23 11:59:13.726715+05
881	154	3	Ticket #3 status changed to closed	t	2026-06-23 11:59:25.52165+05
943	35	51	New Ticket Created: Material Shifting From Green House to Dhabaeji Land Gate - 1	f	2026-06-30 15:31:46.4098+05
921	368	41	Ticket #41 status changed to closed	t	2026-06-30 12:58:51.904587+05
937	123	47	Muhammad Fahim commented on Ticket #47	t	2026-06-30 14:39:41.835797+05
936	123	33	Muhammad Fahim commented on Ticket #33	t	2026-06-30 14:39:02.035384+05
934	123	47	New Ticket Created: Requirement For Trial Shed - Memon Goth - GRP. 53	t	2026-06-30 14:37:01.132497+05
928	123	45	New Sub-Ticket #45 created from #44	t	2026-06-30 14:32:08.772382+05
924	123	31	Ticket #31 self-assigned by Mohsin Ahmed Chohan	t	2026-06-30 14:21:42.490982+05
923	123	33	Ticket #33 self-assigned by Mohsin Ahmed Chohan	t	2026-06-30 14:21:33.615057+05
920	123	44	Manager Syed Rameez Hussain assigned you to Ticket #44	t	2026-06-30 12:58:28.790809+05
903	123	33	New Ticket Created: Washroom Tiles - Warehouse Project (Green House)	t	2026-06-30 11:37:39.440013+05
902	123	31	New Ticket Created: Aluminium Ladder - Height Adjustable Required	t	2026-06-30 11:34:27.104832+05
608	123	19	New Ticket Created: insectecuter, AC not working	t	2026-06-22 12:38:44.700162+05
940	123	49	New Ticket Created: Required Vaccum Pump - Head Office	t	2026-06-30 14:53:24.192681+05
942	123	33	Mohsin Ahmed Chohan commented on Ticket #33	t	2026-06-30 15:10:31.402956+05
945	137	52	New Ticket Created: Rasie P.R for comercial Vehicles Top Most Urgent	f	2026-06-30 16:16:35.959791+05
944	123	52	New Ticket Created: Rasie P.R for comercial Vehicles Top Most Urgent	t	2026-06-30 16:16:35.959791+05
947	137	53	New Sub-Ticket #53 created from #52	f	2026-06-30 16:19:17.571367+05
946	123	53	New Sub-Ticket #53 created from #52	t	2026-06-30 16:19:17.571367+05
465	168	11	Ticket #11 status changed to closed	t	2026-06-22 11:54:19.501086+05
497	168	10	Ticket #10 status changed to completed	t	2026-06-22 11:54:37.837099+05
948	138	54	New Ticket Created: ac temperature	f	2026-06-30 16:33:47.112214+05
949	137	37	Ticket #37 status changed to completed	f	2026-06-30 17:04:48.772143+05
950	113	37	Ticket #37 status changed to closed	f	2026-06-30 17:06:15.60173+05
951	138	54	Ticket #54 self-assigned by Huraira Khan	f	2026-06-30 17:12:49.643816+05
952	138	54	Ticket #54 status changed to completed	f	2026-06-30 17:13:01.504599+05
953	116	55	New Ticket Created: Director Vehicle Starting Issue	f	2026-06-30 17:52:31.436432+05
954	137	55	New Ticket Created: Director Vehicle Starting Issue	f	2026-06-30 17:52:31.436432+05
955	137	55	Ticket #55 status changed to completed	f	2026-06-30 17:53:20.753221+05
956	116	55	Ticket #55 status changed to closed	f	2026-06-30 17:54:24.23615+05
959	163	21	Ticket #21 self-assigned by Azhan Ahmed Qureshi	f	2026-07-01 10:16:20.108328+05
960	163	21	Ticket #21 status changed to completed	f	2026-07-01 10:16:37.141211+05
961	163	21	Ticket #21 status changed to closed	f	2026-07-01 10:17:04.869631+05
352	156	9	Ticket #9 status changed to closed	t	2026-06-20 12:34:56.296398+05
957	156	57	New Ticket Created: Printer Not Working	t	2026-07-01 10:08:03.343148+05
958	156	57	Ticket #57 self-assigned by Muhammad Fashi Ullah Khan	t	2026-07-01 10:13:30.747882+05
962	156	20	Ticket #20 status changed to completed	t	2026-07-01 10:17:11.912565+05
963	156	20	Ticket #20 status changed to closed	t	2026-07-01 10:17:43.830558+05
964	156	57	Ticket #57 status changed to completed	t	2026-07-01 10:18:11.781048+05
965	156	57	Ticket #57 status changed to closed	t	2026-07-01 10:18:34.061768+05
968	123	54	Ticket #54 status changed to closed	t	2026-07-01 10:48:53.482418+05
971	137	58	New Ticket Created: Lunch Arrangements (Stock Count Activity)	f	2026-07-01 11:24:06.282905+05
972	170	59	New Sub-Ticket #59 created from #35	f	2026-07-01 11:36:21.787451+05
973	137	59	New Sub-Ticket #59 created from #35	f	2026-07-01 11:36:21.787451+05
974	101	61	New Ticket Created: Arrange Lunch for stock count team for 01.007.2026	f	2026-07-01 11:40:08.475998+05
975	101	61	Manager Syed Rameez Hussain assigned you to Ticket #61	f	2026-07-01 11:53:06.850535+05
977	101	61	Ticket #61 status changed to completed	f	2026-07-01 11:53:43.410592+05
978	101	61	Ticket #61 status changed to closed	f	2026-07-01 11:53:48.213599+05
979	113	63	New Ticket Created: Envelopes for faisalabad office	f	2026-07-01 11:59:02.297224+05
976	123	61	Manager Syed Rameez Hussain assigned you to Ticket #61	t	2026-07-01 11:53:06.850535+05
970	123	58	New Ticket Created: Lunch Arrangements (Stock Count Activity)	t	2026-07-01 11:24:06.282905+05
969	123	49	Muhammad Fahim commented on Ticket #49	t	2026-07-01 11:17:18.101403+05
980	116	64	New Ticket Created: Settlement of Imprest Account	f	2026-07-01 12:15:26.613611+05
981	137	64	New Ticket Created: Settlement of Imprest Account	f	2026-07-01 12:15:26.613611+05
983	137	65	New Ticket Created: Raise P.R of Machine procure for LA-RFA (Production)	f	2026-07-01 12:18:06.014171+05
984	138	66	New Ticket Created: Cable Tray For Green House	f	2026-07-01 12:20:52.721757+05
985	137	66	New Ticket Created: Cable Tray For Green House	f	2026-07-01 12:20:52.721757+05
986	137	39	Ticket #39 self-assigned by Qasim	f	2026-07-01 12:26:32.355985+05
987	137	38	Qasim commented on Ticket #38	f	2026-07-01 12:27:04.827332+05
988	137	65	Ticket #65 status changed to completed	f	2026-07-01 12:55:37.158721+05
989	137	58	Ticket #58 status changed to completed	f	2026-07-01 12:57:16.518405+05
982	123	65	New Ticket Created: Raise P.R of Machine procure for LA-RFA (Production)	t	2026-07-01 12:18:06.014171+05
990	116	67	New Ticket Created: Comercial Vehicles Survey	f	2026-07-01 15:48:36.745034+05
991	137	67	New Ticket Created: Comercial Vehicles Survey	f	2026-07-01 15:48:36.745034+05
992	137	66	Kamran commented on Ticket #66	f	2026-07-01 16:05:37.69789+05
993	137	67	Ticket #67 status changed to completed	f	2026-07-01 16:15:01.968914+05
994	137	64	Ticket #64 status changed to completed	f	2026-07-01 16:15:33.145029+05
995	123	49	Muhammad Fahim commented on Ticket #49	t	2026-07-01 16:20:30.581687+05
996	123	69	New Ticket Created: Bug	t	2026-07-01 16:37:52.193811+05
997	123	71	New Ticket Created: Suggestion: Direct Navigation from Notifications	t	2026-07-01 16:42:33.028967+05
999	116	67	Ticket #67 status changed to closed	f	2026-07-01 17:04:08.575154+05
1000	116	72	New Ticket Created: Send Bike File GD 110 to FSD Office...	f	2026-07-01 17:59:22.011726+05
1001	170	59	Ticket #59 self-assigned by Syed Rameez Hussain	f	2026-07-02 10:18:33.835092+05
1002	170	73	New Sub-Ticket #73 created from #59	f	2026-07-02 10:19:57.443754+05
1003	137	73	New Sub-Ticket #73 created from #59	f	2026-07-02 10:19:57.443754+05
998	123	65	Ticket #65 status changed to closed	t	2026-07-01 17:03:58.064086+05
1004	193	45	Huraira Khan commented on Ticket #45	t	2026-07-02 10:39:44.929239+05
1005	36	75	New Ticket Created: sap print issue and pdf issue	t	2026-07-02 14:48:27.486125+05
1006	36	75	Ticket #75 self-assigned by Muhammad Fashi Ullah Khan	f	2026-07-02 15:49:18.14001+05
1007	36	74	Muhammad Fashi Ullah Khan commented on Ticket #74	f	2026-07-02 15:50:12.264427+05
1008	36	75	Ticket #75 status changed to completed	f	2026-07-02 15:50:29.056207+05
1101	71	115	New Ticket Created: Additional Extension Required	t	2026-07-08 11:53:51.900179+05
1122	157	124	New Ticket Created: Report Print Issue SAP	f	2026-07-09 15:33:58.601858+05
1115	154	122	New Ticket Created: Arrangements Email ID	t	2026-07-08 16:27:35.454131+05
1114	154	121	New Ticket Created: SAP DFF	t	2026-07-08 16:27:35.44033+05
1113	154	120	New Ticket Created: Arrangements	t	2026-07-08 16:27:35.425105+05
1131	162	130	Ticket #130 status changed to completed	f	2026-07-11 13:03:40.447688+05
1132	162	130	Ticket #130 status changed to closed	f	2026-07-11 13:03:49.479393+05
1135	162	132	Ticket #132 self-assigned by Muhammad Fashi Ullah Khan	f	2026-07-13 11:53:24.730993+05
1136	162	132	Ticket #132 status changed to completed	f	2026-07-13 11:53:36.460837+05
1137	162	132	Ticket #132 status changed to closed	f	2026-07-13 11:53:46.642695+05
1128	123	128	New Ticket Created: Refilling Of Gas Cylinder	t	2026-07-11 11:58:39.993076+05
1139	154	134	New Ticket Created: Arrangements	f	2026-07-13 16:33:41.939889+05
1140	154	136	New Ticket Created: Arrangements	f	2026-07-13 16:34:43.352739+05
1144	172	105	Muhammad Fahim commented on Ticket #105	f	2026-07-14 11:34:11.789913+05
1145	154	105	Muhammad Fahim commented on Ticket #105	f	2026-07-14 11:34:11.789913+05
1149	137	53	Ticket #53 status changed to closed	f	2026-07-14 12:49:57.053203+05
1148	123	53	Ticket #53 status changed to closed	t	2026-07-14 12:49:57.053203+05
1143	123	128	Manager Muhammad Fahim assigned you to Ticket #128	t	2026-07-14 11:32:03.775021+05
371	165	11	New Ticket Created: Team view	t	2026-06-20 15:33:04.755787+05
58	165	4	New Ticket Created: LCD Display Problem	t	2026-06-20 11:04:44.254008+05
462	165	11	Ticket #11 status changed to closed	t	2026-06-22 11:54:19.501086+05
493	165	10	Ticket #10 status changed to completed	t	2026-06-22 11:54:37.837099+05
525	165	10	Ticket #10 status changed to closed	t	2026-06-22 11:55:07.825521+05
858	165	3	Ticket #3 status changed to completed	t	2026-06-23 11:59:13.726715+05
872	165	3	Ticket #3 status changed to closed	t	2026-06-23 11:59:25.52165+05
966	165	56	Ticket #56 status changed to completed	t	2026-07-01 10:18:44.768306+05
967	165	56	Ticket #56 status changed to closed	t	2026-07-01 10:18:55.449936+05
1011	165	74	Ticket #74 status changed to closed	t	2026-07-02 15:50:49.906445+05
1153	165	142	New Ticket Created: Logitech MK250 Wireless Combo	f	2026-07-15 12:29:32.013214+05
1155	165	146	New Ticket Created: Precision Screw Driver Set	f	2026-07-15 12:32:51.041857+05
1009	36	75	Ticket #75 status changed to closed	f	2026-07-02 15:50:33.134422+05
1020	193	45	Muhammad Fahim commented on Ticket #45	t	2026-07-02 17:19:13.527558+05
1013	170	79	New Ticket Created: Open vendor	f	2026-07-02 16:56:16.804939+05
1014	170	79	Ticket #79 self-assigned by Muhammad Hamza Khan	f	2026-07-02 16:57:48.053898+05
1015	170	78	Muhammad Hamza Khan commented on Ticket #78	f	2026-07-02 16:58:13.477007+05
1016	170	79	Ticket #79 status changed to completed	f	2026-07-02 16:58:36.813217+05
1017	170	79	Ticket #79 status changed to closed	f	2026-07-02 16:59:07.221579+05
1106	157	117	New Ticket Created: Printer Issue	f	2026-07-08 14:05:23.105223+05
1116	172	104	Muhammad Rasheed commented on Ticket #104	f	2026-07-08 16:28:17.962682+05
1046	166	78	Ticket #78 status changed to closed	t	2026-07-03 11:48:38.25064+05
1123	168	107	Mohsin Ahmed Chohan commented on Ticket #107	f	2026-07-10 10:56:30.03327+05
1085	123	81	Manager Muhammad Fahim assigned you to Ticket #81	t	2026-07-07 09:48:33.570187+05
1023	123	69	Ticket #69 status changed to closed	t	2026-07-02 18:04:14.920066+05
1022	123	69	Ticket #69 status changed to completed	t	2026-07-02 18:03:52.613034+05
1021	123	69	Ticket #69 self-assigned by Qasim	t	2026-07-02 18:03:03.531836+05
1019	123	45	Muhammad Fahim commented on Ticket #45	t	2026-07-02 17:19:13.527558+05
1018	123	47	Muhammad Fahim commented on Ticket #47	t	2026-07-02 17:17:43.731257+05
1087	123	103	Manager Muhammad Fahim assigned you to Ticket #103	t	2026-07-07 09:48:44.541573+05
1024	123	81	New Ticket Created: Required Hygrometers	t	2026-07-03 10:04:00.213515+05
1082	123	86	Manager Muhammad Fahim assigned you to Ticket #86	t	2026-07-07 09:48:22.912763+05
1089	123	49	Manager Muhammad Fahim assigned you to Ticket #49	t	2026-07-07 09:49:21.094096+05
1027	170	31	Muhammad Fahim commented on Ticket #31	f	2026-07-03 10:26:16.835992+05
1010	165	74	Ticket #74 status changed to completed	t	2026-07-02 15:50:44.568689+05
1028	123	31	Muhammad Fahim commented on Ticket #31	t	2026-07-03 10:26:16.835992+05
1026	123	45	Muhammad Fahim commented on Ticket #45	t	2026-07-03 10:25:10.537928+05
1025	123	81	Muhammad Fahim commented on Ticket #81	t	2026-07-03 10:23:09.702599+05
1029	170	31	Huraira Khan commented on Ticket #31	f	2026-07-03 10:30:04.731615+05
1030	170	30	Huraira Khan commented on Ticket #30	f	2026-07-03 10:44:45.016235+05
1012	32	77	New Ticket Created: SAP Login Issue – User Already Connected	t	2026-07-02 16:42:30.797359+05
1031	1	68	Ticket #68 status changed to completed	f	2026-07-03 10:55:30.559376+05
1032	1	68	Ticket #68 status changed to closed	f	2026-07-03 10:55:47.988344+05
1033	1	83	New Ticket Created: Testing Live Commnet	f	2026-07-03 10:57:48.944598+05
1034	1	83	Ticket #83 self-assigned by Huraira Khan	f	2026-07-03 10:59:58.418895+05
1035	1	82	Huraira Khan commented on Ticket #82	f	2026-07-03 11:00:14.391335+05
1037	1	83	Ticket #83 status changed to completed	f	2026-07-03 11:01:38.242332+05
1041	116	84	New Ticket Created: Confidential Task by Directors	f	2026-07-03 11:29:47.634325+05
1042	137	84	New Ticket Created: Confidential Task by Directors	f	2026-07-03 11:29:47.634325+05
1043	137	84	Ticket #84 status changed to completed	f	2026-07-03 11:31:41.614613+05
1040	123	82	Ticket #82 status changed to closed	t	2026-07-03 11:02:04.364066+05
1039	123	82	Ticket #82 status changed to completed	t	2026-07-03 11:01:57.460543+05
1036	123	82	Qasim commented on Ticket #82	t	2026-07-03 11:00:54.469536+05
1044	137	66	Ticket #66 status changed to completed	f	2026-07-03 11:43:47.596676+05
1049	123	81	Muhammad Fahim commented on Ticket #81	t	2026-07-03 12:17:25.845491+05
1047	123	31	Ticket #31 status changed to completed	t	2026-07-03 12:12:27.843641+05
1048	123	31	Ticket #31 status changed to closed	t	2026-07-03 12:12:58.807252+05
1051	137	85	New Ticket Created: Fire Proof Cabinet	f	2026-07-03 15:05:02.194722+05
1053	137	86	New Sub-Ticket #86 created from #85	f	2026-07-03 15:10:09.699181+05
1050	123	85	New Ticket Created: Fire Proof Cabinet	t	2026-07-03 15:05:02.194722+05
1052	123	86	New Sub-Ticket #86 created from #85	t	2026-07-03 15:10:09.699181+05
1055	137	53	Muhammad Fahim commented on Ticket #53	f	2026-07-03 16:15:05.807567+05
1056	113	63	Fazal ur Rehman Khan commented on Ticket #63	f	2026-07-03 17:07:28.539177+05
1057	113	63	Ticket #63 self-assigned by Fazal ur Rehman Khan	f	2026-07-03 17:12:54.368684+05
1061	200	92	New Ticket Created: Modification required on Feed & FM Store dock.	t	2026-07-03 18:12:22.942185+05
1062	34	94	New Ticket Created: SAP Print & PDF issue	t	2026-07-03 18:14:05.208635+05
1063	200	96	New Ticket Created: Development of changing area with lockers	t	2026-07-03 18:35:30.567128+05
1054	123	53	Muhammad Fahim commented on Ticket #53	t	2026-07-03 16:15:05.807567+05
1066	170	30	Ticket #30 status changed to completed	f	2026-07-04 09:46:22.612089+05
1070	170	30	Ticket #30 status changed to closed	f	2026-07-04 10:28:57.387382+05
1071	138	66	Ticket #66 status changed to closed	f	2026-07-04 10:37:05.392315+05
1064	34	94	Ticket #94 self-assigned by Bilal Ahmed	t	2026-07-04 09:43:18.263435+05
1065	34	93	Bilal Ahmed commented on Ticket #93	t	2026-07-04 09:45:42.618614+05
1073	243	99	New Ticket Created: polythene bags required	t	2026-07-06 10:15:35.712318+05
1072	243	98	New Ticket Created: polythene bags required	t	2026-07-06 10:15:35.673326+05
1075	172	98	Manager Muhammad Fahim assigned you to Ticket #98	f	2026-07-06 12:24:44.475786+05
1077	170	53	Manager Muhammad Fahim assigned you to Ticket #53	f	2026-07-06 12:25:10.233303+05
1079	137	53	Manager Muhammad Fahim assigned you to Ticket #53	f	2026-07-06 12:25:10.233303+05
1078	123	53	Manager Muhammad Fahim assigned you to Ticket #53	t	2026-07-06 12:25:10.233303+05
1080	123	103	New Ticket Created: Required Table Mate	t	2026-07-06 13:23:00.795255+05
1074	37	101	New Ticket Created: Printing& PDFIssue	t	2026-07-06 11:19:46.344955+05
1076	243	98	Manager Muhammad Fahim assigned you to Ticket #98	t	2026-07-06 12:24:44.475786+05
498	167	10	Ticket #10 status changed to completed	t	2026-06-22 11:54:37.837099+05
530	167	10	Ticket #10 status changed to closed	t	2026-06-22 11:55:07.825521+05
1081	172	86	Manager Muhammad Fahim assigned you to Ticket #86	f	2026-07-07 09:48:22.912763+05
1083	137	86	Manager Muhammad Fahim assigned you to Ticket #86	f	2026-07-07 09:48:22.912763+05
1084	170	81	Manager Muhammad Fahim assigned you to Ticket #81	f	2026-07-07 09:48:33.570187+05
1086	170	103	Manager Muhammad Fahim assigned you to Ticket #103	f	2026-07-07 09:48:44.541573+05
1088	170	49	Manager Muhammad Fahim assigned you to Ticket #49	f	2026-07-07 09:49:21.094096+05
1090	170	47	Manager Muhammad Fahim assigned you to Ticket #47	f	2026-07-07 09:49:34.938919+05
1059	154	89	New Ticket Created: Arrangements	t	2026-07-03 17:15:37.169001+05
1060	154	90	New Ticket Created: DFF	t	2026-07-03 17:15:37.183374+05
1068	154	88	Dilawar Farrukh Rauf commented on Ticket #88	t	2026-07-04 09:56:22.703902+05
1069	154	88	Ticket #88 status changed to completed	t	2026-07-04 09:57:11.555778+05
1092	170	45	Manager Muhammad Fahim assigned you to Ticket #45	f	2026-07-07 09:49:41.122259+05
1095	137	34	Mohsin Ahmed Chohan commented on Ticket #34	f	2026-07-07 10:39:06.28969+05
1094	193	45	Manager Muhammad Fahim assigned you to Ticket #45	t	2026-07-07 09:49:41.122259+05
1058	154	88	New Ticket Created: Arrangements	t	2026-07-03 17:15:37.154215+05
1067	154	88	Ticket #88 self-assigned by Dilawar Farrukh Rauf	t	2026-07-04 09:52:10.269557+05
1096	154	105	New Ticket Created: Request for Design of Official Visiting Cards	t	2026-07-07 11:39:29.37746+05
1107	157	117	Ticket #117 self-assigned by Muhammad Yahya Ajmal	f	2026-07-08 15:02:56.804827+05
1117	168	87	Muhammad Rasheed commented on Ticket #87	f	2026-07-08 16:33:07.868357+05
1124	170	118	Manager Muhammad Fahim assigned you to Ticket #118	f	2026-07-10 11:12:37.378696+05
1126	400	118	Manager Muhammad Fahim assigned you to Ticket #118	f	2026-07-10 11:12:37.378696+05
1129	162	130	New Ticket Created: Laptop Bag	f	2026-07-11 12:58:58.353605+05
1133	167	129	Ticket #129 status changed to completed	f	2026-07-11 13:04:51.377725+05
1093	123	45	Manager Muhammad Fahim assigned you to Ticket #45	t	2026-07-07 09:49:41.122259+05
1138	167	116	Ticket #116 status changed to completed	f	2026-07-13 12:00:00.266295+05
1141	154	138	New Ticket Created: DFF	f	2026-07-13 16:35:49.610935+05
1147	137	53	Ticket #53 status changed to completed	f	2026-07-14 12:49:29.041478+05
1146	123	53	Ticket #53 status changed to completed	t	2026-07-14 12:49:29.041478+05
1150	170	52	Ticket #52 status changed to completed	f	2026-07-15 09:40:29.934095+05
1151	137	52	Ticket #52 status changed to completed	f	2026-07-15 09:40:29.934095+05
1125	165	118	Manager Muhammad Fahim assigned you to Ticket #118	t	2026-07-10 11:12:37.378696+05
1109	165	118	New Sub-Ticket #118 created from #111	t	2026-07-08 15:10:48.825042+05
1154	165	144	New Ticket Created: Corning (3M) Cat 6 Original Cable Roll	f	2026-07-15 12:30:38.068743+05
1152	123	140	New Ticket Created: Shelve - Trial Shed - Memon Goth - GRP# 47	t	2026-07-15 12:18:17.586124+05
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name) FROM stdin;
0	ceo
1	manager
2	employee
3	developer
\.


--
-- Data for Name: sub_ticket_departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sub_ticket_departments (id, ticket_id, department_id, task_description, status, progress_percent, assigned_to_id, completed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ticket_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ticket_comments (id, ticket_id, user_id, message, created_at) FROM stdin;
2	4	165	[COMPLETED REMARK]: Complete	2026-06-20 11:09:23.785434+05
3	4	165	[CLOSED REMARK]: Complete	2026-06-20 11:09:35.464331+05
11	9	155	TEST PLEASE CLOSE IT	2026-06-20 12:30:08.624023+05
12	9	157	[COMPLETED REMARK]: Issued	2026-06-20 12:31:11.880977+05
13	9	155	[CLOSED REMARK]: Good Work	2026-06-20 12:34:56.290407+05
14	11	163	[COMPLETED REMARK]: CD	2026-06-22 11:54:06.686329+05
15	11	163	[CLOSED REMARK]: Done	2026-06-22 11:54:19.496977+05
16	10	299	[COMPLETED REMARK]: Done	2026-06-22 11:54:37.833089+05
17	10	299	[CLOSED REMARK]: Done	2026-06-22 11:55:07.821469+05
18	19	123	[COMPLETED REMARK]: Task Done	2026-06-22 14:40:42.47621+05
19	19	123	[CLOSED REMARK]: please close the loop if your work done	2026-06-22 15:12:25.236034+05
20	3	156	Automatically Resolved by our side	2026-06-22 15:36:42.596388+05
21	3	156	[COMPLETED REMARK]: Resolved	2026-06-23 11:59:13.685328+05
22	3	156	[CLOSED REMARK]: Resolved	2026-06-23 11:59:25.51746+05
23	20	163	It's already approved by My Deputy manager Bilal	2026-06-24 10:21:05.80389+05
24	25	368	[COMPLETED REMARK]: done	2026-06-29 12:00:00.192585+05
25	25	368	[CLOSED REMARK]: done	2026-06-29 12:04:35.642302+05
26	24	223	[COMPLETED REMARK]: received , thank you	2026-06-29 12:13:36.004458+05
27	24	223	[CLOSED REMARK]: completed	2026-06-29 12:35:26.660016+05
28	22	65	Owais, I have sent you the employee list via email.	2026-06-29 15:46:59.581912+05
29	23	65	[COMPLETED REMARK]: Done	2026-06-29 15:47:40.283447+05
30	23	65	[CLOSED REMARK]: Done	2026-06-29 15:47:48.76732+05
31	26	168	I have forwarded it to Mr. Shehzad Riaz in order to obtain approval from Ali sb. Will update as soon as I receive the response...	2026-06-30 09:45:38.057484+05
32	22	66	[COMPLETED REMARK]: Completed	2026-06-30 10:37:27.221028+05
33	32	123	Dear Team,\n\nPlease update.	2026-06-30 11:38:10.103643+05
34	42	368	[COMPLETED REMARK]: done	2026-06-30 12:43:10.038652+05
35	42	368	[CLOSED REMARK]: done	2026-06-30 12:43:17.12457+05
36	41	157	[COMPLETED REMARK]: Resolved.	2026-06-30 12:55:54.517783+05
37	40	138	[COMPLETED REMARK]: DONE	2026-06-30 12:57:33.616989+05
38	41	157	[CLOSED REMARK]: Resolved	2026-06-30 12:58:51.897747+05
39	40	138	P.R Raised, PR num 626109072	2026-06-30 13:01:52.448734+05
40	40	137	[CLOSED REMARK]: .	2026-06-30 14:25:29.241466+05
41	35	170	Please Provide us a PR	2026-06-30 14:29:48.653289+05
42	45	404	Kindly raise the PR first. Without an approved PR, the procurement process cannot be initiated.	2026-06-30 14:33:59.912289+05
43	35	404	Kindly raise the PR first. Without an approved PR, the procurement process cannot be initiated.	2026-06-30 14:35:23.346242+05
44	33	404	Kindly raise the PR first. Without an approved PR, the procurement process cannot be initiated.	2026-06-30 14:39:02.027689+05
45	47	404	Kindly raise the PR first. Without an approved PR, the procurement process cannot be initiated.	2026-06-30 14:39:41.8273+05
46	36	116	[COMPLETED REMARK]: Task Completed Alhamdulillah...	2026-06-30 14:40:13.964777+05
47	36	116	Sir Purchased new air pumps for our commercial and pool parked vehicles...	2026-06-30 14:42:14.02735+05
48	46	123	Edit: This Requirement is for Trial Shed of Matrix Plot: GRP. 47. PR updated	2026-06-30 14:47:40.593302+05
49	36	137	[CLOSED REMARK]: DOne	2026-06-30 14:54:30.103305+05
50	33	170	director approvals pending	2026-06-30 15:10:31.386992+05
51	37	113	[COMPLETED REMARK]: share via email	2026-06-30 17:04:48.739975+05
52	37	137	[CLOSED REMARK]: Done	2026-06-30 17:06:15.594729+05
53	54	123	[COMPLETED REMARK]: .	2026-06-30 17:13:01.501179+05
54	55	116	[COMPLETED REMARK]: Task Completed...	2026-06-30 17:53:20.744773+05
55	55	137	[CLOSED REMARK]: Done	2026-06-30 17:54:24.229137+05
56	21	156	[COMPLETED REMARK]: done	2026-07-01 10:16:37.137784+05
57	21	156	[CLOSED REMARK]: done	2026-07-01 10:17:04.866543+05
58	20	163	[COMPLETED REMARK]: done	2026-07-01 10:17:11.909319+05
59	20	163	[CLOSED REMARK]: cd	2026-07-01 10:17:43.827261+05
60	57	165	[COMPLETED REMARK]: Completed	2026-07-01 10:18:11.77805+05
61	57	165	[CLOSED REMARK]: Completed	2026-07-01 10:18:34.058675+05
62	56	156	[COMPLETED REMARK]: Done	2026-07-01 10:18:44.76532+05
63	56	156	[CLOSED REMARK]: Done	2026-07-01 10:18:55.44686+05
64	54	138	[CLOSED REMARK]: done	2026-07-01 10:48:53.477919+05
65	49	404	Approved PR is still awaited.	2026-07-01 11:17:18.096413+05
66	61	123	[COMPLETED REMARK]: done	2026-07-01 11:53:43.407128+05
67	61	123	[CLOSED REMARK]: done	2026-07-01 11:53:48.210523+05
68	38	1	Acknowledged.	2026-07-01 12:27:04.823724+05
69	65	123	[COMPLETED REMARK]: done	2026-07-01 12:55:37.155113+05
70	58	123	[COMPLETED REMARK]: done	2026-07-01 12:57:16.514921+05
71	47	123	PR# already mentioned in description.	2026-07-01 13:00:01.436437+05
72	66	138	We have received two quotations. We are now waiting for the remaining one quotation.	2026-07-01 16:05:37.691186+05
73	67	116	[COMPLETED REMARK]: Task completed...	2026-07-01 16:15:01.965318+05
74	64	116	[COMPLETED REMARK]: prepared summary and given to IQs for approval...	2026-07-01 16:15:33.141886+05
75	49	404	Kindly share the details/specifications against your requirement or approved PR. Once received, we will start working on it and resolve the matter within a week.	2026-07-01 16:20:30.576949+05
76	65	137	[CLOSED REMARK]: done	2026-07-01 17:03:58.023839+05
77	67	137	[CLOSED REMARK]: done	2026-07-01 17:04:08.572075+05
78	72	116	[COMPLETED REMARK]: done...	2026-07-01 18:02:32.270169+05
79	72	116	[CLOSED REMARK]: delivered...	2026-07-01 18:02:56.888705+05
80	45	123	No approval is required for purchases below Rs. 50,000. Please proceed with the procurement accordingly.	2026-07-02 10:39:44.924416+05
81	74	36	closed	2026-07-02 15:30:08.696156+05
82	74	36	mistakely created to it dept	2026-07-02 15:48:22.902426+05
83	74	165	acknlowedged kindly send this to ERP department (in knowledge to Mr.Qasim [DEV]department )	2026-07-02 15:50:12.261072+05
84	75	165	[COMPLETED REMARK]: CCD	2026-07-02 15:50:29.053183+05
85	75	165	[CLOSED REMARK]: CD	2026-07-02 15:50:33.131054+05
86	74	36	[COMPLETED REMARK]: CD	2026-07-02 15:50:44.565098+05
87	74	36	[CLOSED REMARK]: CD	2026-07-02 15:50:49.903397+05
88	78	166	Done	2026-07-02 16:58:13.473077+05
89	79	166	[COMPLETED REMARK]: Done	2026-07-02 16:58:36.809876+05
90	79	166	[CLOSED REMARK]: Done	2026-07-02 16:59:07.218442+05
91	47	404	Awaiting for PR	2026-07-02 17:17:43.661158+05
92	45	404	Awaiting for PR	2026-07-02 17:19:13.523977+05
93	69	1	[COMPLETED REMARK]: fixed and uploaded its live now	2026-07-02 18:03:52.60815+05
94	69	1	[CLOSED REMARK]: Publish on web	2026-07-02 18:04:14.916559+05
95	81	404	Kindly provide the signed physical copy of the PR, as it is required to proceed with the procurement process.	2026-07-03 10:23:09.697599+05
96	45	404	The Purchase Requisition is the primary document required to initiate the procurement process. Without an approved and signed PR, no procurement request can be entertained or processed.	2026-07-03 10:25:10.533298+05
97	31	404	The ladder was delivered yesterday.	2026-07-03 10:26:16.831353+05
98	31	123	Thanks. Please complete the task so i can close.	2026-07-03 10:30:04.727929+05
99	81	123	No need of physical PR. Please check Faraz-ERP email related to this for your assistance.	2026-07-03 10:37:41.887434+05
100	30	123	TESTING QASIM	2026-07-03 10:44:45.011437+05
101	68	123	[COMPLETED REMARK]: CD	2026-07-03 10:55:30.555843+05
102	68	123	[CLOSED REMARK]: CD	2026-07-03 10:55:47.984934+05
103	82	123	completed TESTING COMMENT	2026-07-03 11:00:14.387615+05
104	82	1	QASIM TESTING @	2026-07-03 11:00:54.466226+05
105	83	123	[COMPLETED REMARK]: CD	2026-07-03 11:01:38.239321+05
106	83	123	[CLOSED REMARK]: CD	2026-07-03 11:01:41.140949+05
107	82	1	[COMPLETED REMARK]: CD	2026-07-03 11:01:57.457478+05
108	82	1	[CLOSED REMARK]: CD	2026-07-03 11:02:04.360847+05
109	84	116	[COMPLETED REMARK]: Payment Deposited Successfully...	2026-07-03 11:31:41.611005+05
110	66	138	[COMPLETED REMARK]: done	2026-07-03 11:43:47.593041+05
111	78	170	[COMPLETED REMARK]: thanks and work done	2026-07-03 11:48:05.763718+05
112	78	170	[CLOSED REMARK]: work done	2026-07-03 11:48:38.247457+05
113	31	170	[COMPLETED REMARK]: Laddar has been successfully delivered	2026-07-03 12:12:27.840156+05
114	31	170	[CLOSED REMARK]: Laddar has been successfully delivered	2026-07-03 12:12:58.804169+05
115	81	404	As per company policy, signed or approved PR is mandatory before processing any procurement request or related document. Without an approved PR, we are unable to proceed.	2026-07-03 12:17:25.840965+05
116	53	404	Isuzu: Approval is currently pending with the Directors for final decision.\nSuzuki Ravi: The approval is currently in the selection/evaluation phase.	2026-07-03 16:15:05.802603+05
117	63	201	completed	2026-07-03 17:07:28.381341+05
118	63	201	Task completed, please close the ticket	2026-07-03 17:13:25.119215+05
119	93	164	We rasied complaint to cloud team . cloud team sent his representator to resolve this issue kindly if this issue come again kindly inform ASAP today.	2026-07-04 09:45:42.614262+05
120	30	123	[COMPLETED REMARK]: Done	2026-07-04 09:46:22.608922+05
121	88	168	ali.sahito@um.com.pk	2026-07-04 09:56:22.699062+05
122	88	168	[COMPLETED REMARK]: Done	2026-07-04 09:57:11.55109+05
123	30	123	[CLOSED REMARK]: done	2026-07-04 10:28:57.380214+05
124	66	137	[CLOSED REMARK]: Done	2026-07-04 10:37:05.385606+05
125	26	168	Devices have been approved by Ali sb. and ordered has been placed with Zong	2026-07-06 12:28:53.909843+05
126	102	123	PR# 726109020	2026-07-06 13:23:23.6548+05
127	34	170	job has been done kindly huraira close this task	2026-07-07 10:39:06.144795+05
128	104	154	I kindly request you to process this request at the earliest.	2026-07-07 11:41:38.993949+05
129	50	35	Material has been shifted successfully.	2026-07-08 15:06:43.939904+05
130	117	167	[COMPLETED REMARK]: Task Resolved	2026-07-08 15:19:00.139912+05
131	116	157	Resolved. Thanks Yahya	2026-07-08 16:04:23.989368+05
132	104	154	Any update	2026-07-08 16:28:17.956972+05
133	119	154	Admin and ERP any update	2026-07-08 16:32:16.033918+05
134	87	154	Dear Team,\n\nPlease make the necessary arrangements as mentioned below Also kindly provide me with the email ID and official phone number.	2026-07-08 16:33:07.864664+05
135	117	167	[CLOSED REMARK]: Task Completed	2026-07-09 10:15:12.054406+05
136	121	166	[COMPLETED REMARK]: Done	2026-07-09 10:16:45.612649+05
137	121	166	[CLOSED REMARK]: .	2026-07-09 10:16:55.992704+05
138	107	170	please provide us charger Picture and spacification	2026-07-10 10:56:30.002648+05
139	126	170	thanks work done	2026-07-10 14:11:08.712398+05
140	104	154	Any Update	2026-07-10 15:28:56.531462+05
141	130	167	[COMPLETED REMARK]: Task Completed	2026-07-11 13:03:40.375721+05
142	130	167	[CLOSED REMARK]: Task Completed	2026-07-11 13:03:49.475815+05
143	129	162	[COMPLETED REMARK]: Thanks	2026-07-11 13:04:51.372584+05
144	132	165	[COMPLETED REMARK]: completed	2026-07-13 11:53:36.421686+05
145	132	165	[CLOSED REMARK]: Done	2026-07-13 11:53:46.639801+05
146	116	157	[COMPLETED REMARK]: Thanks	2026-07-13 12:00:00.263258+05
147	105	404	All cards has been delivered	2026-07-14 11:34:11.721663+05
148	125	170	job done kindly close task	2026-07-14 11:36:33.816451+05
149	53	170	[COMPLETED REMARK]: I have completed all the required documentation from my side and forwarded it for payment processing. The documents are currently with the Treasury Department for the preparation of the pay order.	2026-07-14 12:49:29.038335+05
150	53	170	[CLOSED REMARK]: I have completed all the required documentation from my side and forwarded it for payment processing. The documents are currently with the Treasury Department for the preparation of the pay order.	2026-07-14 12:49:57.050097+05
151	52	123	[COMPLETED REMARK]: .	2026-07-15 09:40:29.900365+05
\.


--
-- Data for Name: ticket_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ticket_logs (id, ticket_id, acted_by_id, action, old_value, new_value, note, created_at) FROM stdin;
10	3	156	created	\N	open	Project Master created for department oversight	2026-06-20 11:04:44.237331+05
11	4	156	created	\N	open	Created by Azhan Ahmed Qureshi as a sub-ticket of #3	2026-06-20 11:04:44.248191+05
12	3	156	sub_ticket_created	\N	4	Sub-ticket #4 created by Azhan Ahmed Qureshi	2026-06-20 11:04:44.248845+05
13	4	165	assigned	Unassigned	Muhammad Fashi Ullah Khan	Self-assigned	2026-06-20 11:09:05.770819+05
14	4	165	status_changed	open	in_progress	Status changed via self-assignment	2026-06-20 11:09:05.77183+05
15	4	165	status_changed	in_progress	completed	Status updated to completed by Muhammad Fashi Ullah Khan. Remark: Complete	2026-06-20 11:09:23.781906+05
16	3	165	all_children_completed	\N	\N	All sub-tickets completed via #4	2026-06-20 11:09:23.783887+05
17	3	165	all_children_completed	\N	\N	All sub-tickets completed via #4	2026-06-20 11:09:23.784853+05
18	4	165	comment_added	\N	[COMPLETED REMARK]: Complete	Completed remark added by Muhammad Fashi Ullah Khan	2026-06-20 11:09:23.786289+05
19	4	165	status_changed	completed	closed	Status updated to closed by Muhammad Fashi Ullah Khan. Remark: Complete	2026-06-20 11:09:35.463278+05
20	4	165	comment_added	\N	[CLOSED REMARK]: Complete	Closed remark added by Muhammad Fashi Ullah Khan	2026-06-20 11:09:35.465234+05
50	9	155	created	\N	in_progress	Created by Adnan Najeeb and assigned to Muhammad Sufiyan	2026-06-20 12:29:25.808858+05
51	9	155	comment_added	\N	TEST PLEASE CLOSE IT	Comment added by Adnan Najeeb	2026-06-20 12:30:08.625205+05
52	9	157	status_changed	in_progress	completed	Status updated to completed by Muhammad Sufiyan. Remark: Issued	2026-06-20 12:31:11.880026+05
53	9	157	comment_added	\N	[COMPLETED REMARK]: Issued	Completed remark added by Muhammad Sufiyan	2026-06-20 12:31:11.881858+05
54	9	155	status_changed	completed	closed	Status updated to closed by Adnan Najeeb. Remark: Good Work	2026-06-20 12:34:56.289399+05
55	9	155	comment_added	\N	[CLOSED REMARK]: Good Work	Closed remark added by Adnan Najeeb	2026-06-20 12:34:56.29133+05
56	10	299	created	\N	open	Project Master created for department oversight	2026-06-20 15:33:04.738461+05
57	11	299	created	\N	open	Created by Asif Ali as a sub-ticket of #10	2026-06-20 15:33:04.749714+05
58	10	299	sub_ticket_created	\N	11	Sub-ticket #11 created by Asif Ali	2026-06-20 15:33:04.750402+05
59	12	273	created	\N	open	Project Master created for department oversight	2026-06-22 09:44:02.107063+05
60	13	273	created	\N	open	Created by Muhammad Waseem  as a sub-ticket of #12	2026-06-22 09:44:02.127296+05
61	12	273	sub_ticket_created	\N	13	Sub-ticket #13 created by Muhammad Waseem 	2026-06-22 09:44:02.127985+05
62	11	168	assigned	Unassigned	Muhammad Qasim Mehmood	Manager Dilawar Farrukh Rauf assigned the ticket.	2026-06-22 11:13:40.218933+05
63	11	168	status_changed	open	in_progress	Status changed due to assignment	2026-06-22 11:13:40.222804+05
64	14	168	created	\N	open	Project Master created for department oversight	2026-06-22 11:20:01.801751+05
65	15	168	created	\N	open	Created by Dilawar Farrukh Rauf as a sub-ticket of #14	2026-06-22 11:20:01.812543+05
66	14	168	sub_ticket_created	\N	15	Sub-ticket #15 created by Dilawar Farrukh Rauf	2026-06-22 11:20:01.813191+05
67	11	163	status_changed	in_progress	completed	Status updated to completed by Muhammad Qasim Mehmood. Remark: CD	2026-06-22 11:54:06.682336+05
68	10	163	all_children_completed	\N	\N	All sub-tickets completed via #11	2026-06-22 11:54:06.684682+05
69	10	163	all_children_completed	\N	\N	All sub-tickets completed via #11	2026-06-22 11:54:06.685683+05
70	11	163	comment_added	\N	[COMPLETED REMARK]: CD	Completed remark added by Muhammad Qasim Mehmood	2026-06-22 11:54:06.698758+05
71	11	163	status_changed	completed	closed	Status updated to closed by Muhammad Qasim Mehmood. Remark: Done	2026-06-22 11:54:19.496037+05
72	11	163	comment_added	\N	[CLOSED REMARK]: Done	Closed remark added by Muhammad Qasim Mehmood	2026-06-22 11:54:19.497867+05
73	10	299	status_changed	in_progress	completed	Status updated to completed by Asif Ali. Remark: Done	2026-06-22 11:54:37.832094+05
74	10	299	comment_added	\N	[COMPLETED REMARK]: Done	Completed remark added by Asif Ali	2026-06-22 11:54:37.833966+05
75	10	299	status_changed	completed	closed	Status updated to closed by Asif Ali. Remark: Done	2026-06-22 11:55:07.820453+05
76	10	299	comment_added	\N	[CLOSED REMARK]: Done	Closed remark added by Asif Ali	2026-06-22 11:55:07.822395+05
77	16	310	created	\N	open	Project Master created for department oversight	2026-06-22 12:31:01.024207+05
78	17	310	created	\N	open	Created by Muhammad Naveed as a sub-ticket of #16	2026-06-22 12:31:01.034963+05
79	16	310	sub_ticket_created	\N	17	Sub-ticket #17 created by Muhammad Naveed	2026-06-22 12:31:01.035559+05
80	18	318	created	\N	open	Project Master created for department oversight	2026-06-22 12:38:44.685685+05
81	19	318	created	\N	open	Created by Syed Muhammad Ali Naqvi as a sub-ticket of #18	2026-06-22 12:38:44.696436+05
82	18	318	sub_ticket_created	\N	19	Sub-ticket #19 created by Syed Muhammad Ali Naqvi	2026-06-22 12:38:44.697044+05
83	19	123	assigned	Unassigned	Huraira Khan	Self-assigned	2026-06-22 12:46:45.728187+05
84	19	123	status_changed	open	in_progress	Status changed via self-assignment	2026-06-22 12:46:45.729138+05
85	19	123	status_changed	in_progress	completed	Status updated to completed by Huraira Khan. Remark: Task Done	2026-06-22 14:40:42.472656+05
86	18	123	all_children_completed	\N	\N	All sub-tickets completed via #19	2026-06-22 14:40:42.474713+05
87	18	123	all_children_completed	\N	\N	All sub-tickets completed via #19	2026-06-22 14:40:42.475657+05
88	19	123	comment_added	\N	[COMPLETED REMARK]: Task Done	Completed remark added by Huraira Khan	2026-06-22 14:40:42.477182+05
89	19	123	status_changed	completed	closed	Status updated to closed by Huraira Khan. Remark: please close the loop if your work done	2026-06-22 15:12:25.235049+05
90	19	123	comment_added	\N	[CLOSED REMARK]: please close the loop if your work done	Closed remark added by Huraira Khan	2026-06-22 15:12:25.236886+05
91	3	156	comment_added	\N	Automatically Resolved by our side	Comment added by Azhan Ahmed Qureshi	2026-06-22 15:36:42.598252+05
92	17	306	assigned	Unassigned	Daniyal Jawaid	Self-assigned	2026-06-23 11:16:45.940608+05
93	17	306	status_changed	open	in_progress	Status changed via self-assignment	2026-06-23 11:16:45.961769+05
94	13	306	assigned	Unassigned	Daniyal Jawaid	Self-assigned	2026-06-23 11:16:53.846444+05
95	13	306	status_changed	open	in_progress	Status changed via self-assignment	2026-06-23 11:16:53.847348+05
96	3	156	status_changed	in_progress	completed	Status updated to completed by Azhan Ahmed Qureshi. Remark: Resolved	2026-06-23 11:59:13.684175+05
97	3	156	comment_added	\N	[COMPLETED REMARK]: Resolved	Completed remark added by Azhan Ahmed Qureshi	2026-06-23 11:59:13.723557+05
98	3	156	status_changed	completed	closed	Status updated to closed by Azhan Ahmed Qureshi. Remark: Resolved	2026-06-23 11:59:25.516429+05
99	3	156	comment_added	\N	[CLOSED REMARK]: Resolved	Closed remark added by Azhan Ahmed Qureshi	2026-06-23 11:59:25.518353+05
100	20	163	created	\N	open	Project Master created for department oversight	2026-06-24 10:19:45.466845+05
101	21	163	created	\N	open	Created by Muhammad Qasim Mehmood as a sub-ticket of #20	2026-06-24 10:19:45.503456+05
102	20	163	sub_ticket_created	\N	21	Sub-ticket #21 created by Muhammad Qasim Mehmood	2026-06-24 10:19:45.504117+05
103	20	163	comment_added	\N	It's already approved by My Deputy manager Bilal	Comment added by Muhammad Qasim Mehmood	2026-06-24 10:21:05.874687+05
104	22	66	created	\N	open	Project Master created for department oversight	2026-06-29 10:46:28.183957+05
105	23	66	created	\N	open	Created by Owais Najam as a sub-ticket of #22	2026-06-29 10:46:28.224792+05
106	22	66	sub_ticket_created	\N	23	Sub-ticket #23 created by Owais Najam	2026-06-29 10:46:28.225397+05
107	23	65	assigned	Unassigned	Akber Mughal	Self-assigned	2026-06-29 11:23:55.762588+05
108	23	65	status_changed	open	in_progress	Status changed via self-assignment	2026-06-29 11:23:55.763528+05
109	24	223	created	\N	open	Project Master created for department oversight	2026-06-29 11:24:18.242111+05
110	25	223	created	\N	open	Created by Hamza Ali Khan as a sub-ticket of #24	2026-06-29 11:24:18.253147+05
111	24	223	sub_ticket_created	\N	25	Sub-ticket #25 created by Hamza Ali Khan	2026-06-29 11:24:18.253747+05
112	25	368	assigned	Unassigned	Adnan Zahid 	Self-assigned	2026-06-29 11:27:25.9411+05
113	25	368	status_changed	open	in_progress	Status changed via self-assignment	2026-06-29 11:27:25.941763+05
114	25	368	status_changed	in_progress	completed	Status updated to completed by Adnan Zahid . Remark: done	2026-06-29 12:00:00.188869+05
115	24	368	all_children_completed	\N	\N	All sub-tickets completed via #25	2026-06-29 12:00:00.191038+05
116	24	368	all_children_completed	\N	\N	All sub-tickets completed via #25	2026-06-29 12:00:00.191949+05
117	25	368	comment_added	\N	[COMPLETED REMARK]: done	Completed remark added by Adnan Zahid 	2026-06-29 12:00:00.279476+05
118	25	368	status_changed	completed	closed	Status updated to closed by Adnan Zahid . Remark: done	2026-06-29 12:04:35.641344+05
119	25	368	comment_added	\N	[CLOSED REMARK]: done	Closed remark added by Adnan Zahid 	2026-06-29 12:04:35.64317+05
120	24	223	status_changed	in_progress	completed	Status updated to completed by Hamza Ali Khan. Remark: received , thank you	2026-06-29 12:13:36.003417+05
121	24	223	comment_added	\N	[COMPLETED REMARK]: received , thank you	Completed remark added by Hamza Ali Khan	2026-06-29 12:13:36.0054+05
122	24	223	status_changed	completed	closed	Status updated to closed by Hamza Ali Khan. Remark: completed	2026-06-29 12:35:26.658913+05
123	24	223	comment_added	\N	[CLOSED REMARK]: completed	Closed remark added by Hamza Ali Khan	2026-06-29 12:35:26.660976+05
124	26	65	created	\N	open	Project Master created for department oversight	2026-06-29 13:59:05.643501+05
125	27	65	created	\N	open	Created by Akber Mughal as a sub-ticket of #26	2026-06-29 13:59:05.654207+05
126	26	65	sub_ticket_created	\N	27	Sub-ticket #27 created by Akber Mughal	2026-06-29 13:59:05.6548+05
127	15	1	assigned	Unassigned	Qasim	Self-assigned	2026-06-29 15:39:05.619793+05
128	15	1	status_changed	open	in_progress	Status changed via self-assignment	2026-06-29 15:39:05.620778+05
129	22	65	comment_added	\N	Owais, I have sent you the employee list via email.	Comment added by Akber Mughal	2026-06-29 15:46:59.584826+05
130	23	65	status_changed	in_progress	completed	Status updated to completed by Akber Mughal. Remark: Done	2026-06-29 15:47:40.28009+05
131	22	65	all_children_completed	\N	\N	All sub-tickets completed via #23	2026-06-29 15:47:40.281962+05
132	22	65	all_children_completed	\N	\N	All sub-tickets completed via #23	2026-06-29 15:47:40.282883+05
133	23	65	comment_added	\N	[COMPLETED REMARK]: Done	Completed remark added by Akber Mughal	2026-06-29 15:47:40.284075+05
134	23	65	status_changed	completed	closed	Status updated to closed by Akber Mughal. Remark: Done	2026-06-29 15:47:48.766354+05
135	23	65	comment_added	\N	[CLOSED REMARK]: Done	Closed remark added by Akber Mughal	2026-06-29 15:47:48.768176+05
136	27	168	assigned	Unassigned	Dilawar Farrukh Rauf	Self-assigned	2026-06-29 16:37:15.396923+05
137	27	168	status_changed	open	in_progress	Status changed via self-assignment	2026-06-29 16:37:15.397825+05
138	28	168	created	\N	open	Project Master created for department oversight	2026-06-29 17:13:43.516614+05
139	29	168	created	\N	open	Created by Dilawar Farrukh Rauf as a sub-ticket of #28	2026-06-29 17:13:43.539107+05
140	28	168	sub_ticket_created	\N	29	Sub-ticket #29 created by Dilawar Farrukh Rauf	2026-06-29 17:13:43.539728+05
141	26	168	comment_added	\N	I have forwarded it to Mr. Shehzad Riaz in order to obtain approval from Ali sb. Will update as soon	Comment added by Dilawar Farrukh Rauf	2026-06-30 09:45:38.108306+05
142	22	66	status_changed	in_progress	completed	Status updated to completed by Owais Najam. Remark: Completed	2026-06-30 10:37:27.220014+05
143	22	66	comment_added	\N	[COMPLETED REMARK]: Completed	Completed remark added by Owais Najam	2026-06-30 10:37:27.22191+05
144	29	170	assigned	Unassigned	Mohsin Ahmed Chohan	Self-assigned	2026-06-30 10:47:26.690481+05
145	29	170	status_changed	open	in_progress	Status changed via self-assignment	2026-06-30 10:47:26.691352+05
146	30	123	created	\N	open	Project Master created for department oversight	2026-06-30 11:34:27.087158+05
147	31	123	created	\N	open	Created by Huraira Khan as a sub-ticket of #30	2026-06-30 11:34:27.098009+05
148	30	123	sub_ticket_created	\N	31	Sub-ticket #31 created by Huraira Khan	2026-06-30 11:34:27.09864+05
149	32	123	created	\N	open	Project Master created for department oversight	2026-06-30 11:37:39.422958+05
150	33	123	created	\N	open	Created by Huraira Khan as a sub-ticket of #32	2026-06-30 11:37:39.433472+05
151	32	123	sub_ticket_created	\N	33	Sub-ticket #33 created by Huraira Khan	2026-06-30 11:37:39.434078+05
152	32	123	comment_added	\N	Dear Team,\n\nPlease update.	Comment added by Huraira Khan	2026-06-30 11:38:10.105297+05
153	34	137	created	\N	open	Project Master created for department oversight	2026-06-30 11:51:36.601016+05
154	35	137	created	\N	open	Created by Syed Rameez Hussain as a sub-ticket of #34	2026-06-30 11:51:36.621456+05
155	34	137	sub_ticket_created	\N	35	Sub-ticket #35 created by Syed Rameez Hussain	2026-06-30 11:51:36.624566+05
156	36	137	created	\N	in_progress	Created by Syed Rameez Hussain and assigned to Abdul Rehman	2026-06-30 12:08:27.398194+05
157	37	137	created	\N	in_progress	Created by Syed Rameez Hussain and assigned to Muhammad Owais Raza	2026-06-30 12:14:00.856611+05
158	38	137	created	\N	open	Project Master created for department oversight	2026-06-30 12:31:58.201061+05
159	39	137	created	\N	open	Created by Syed Rameez Hussain as a sub-ticket of #38	2026-06-30 12:31:58.215369+05
160	38	137	sub_ticket_created	\N	39	Sub-ticket #39 created by Syed Rameez Hussain	2026-06-30 12:31:58.216193+05
161	40	137	created	\N	in_progress	Created by Syed Rameez Hussain and assigned to Kamran	2026-06-30 12:37:08.137191+05
162	41	157	created	\N	open	Project Master created for department oversight	2026-06-30 12:37:15.691615+05
163	42	157	created	\N	open	Created by Muhammad Sufiyan as a sub-ticket of #41	2026-06-30 12:37:15.702451+05
164	41	157	sub_ticket_created	\N	42	Sub-ticket #42 created by Muhammad Sufiyan	2026-06-30 12:37:15.703112+05
165	42	368	assigned	Unassigned	Adnan Zahid 	Self-assigned	2026-06-30 12:38:21.454668+05
166	42	368	status_changed	open	in_progress	Status changed via self-assignment	2026-06-30 12:38:21.455551+05
167	42	368	status_changed	in_progress	completed	Status updated to completed by Adnan Zahid . Remark: done	2026-06-30 12:43:09.972697+05
168	41	368	all_children_completed	\N	\N	All sub-tickets completed via #42	2026-06-30 12:43:09.975385+05
169	41	368	all_children_completed	\N	\N	All sub-tickets completed via #42	2026-06-30 12:43:10.038076+05
170	42	368	comment_added	\N	[COMPLETED REMARK]: done	Completed remark added by Adnan Zahid 	2026-06-30 12:43:10.039616+05
171	42	368	status_changed	completed	closed	Status updated to closed by Adnan Zahid . Remark: done	2026-06-30 12:43:17.123611+05
172	42	368	comment_added	\N	[CLOSED REMARK]: done	Closed remark added by Adnan Zahid 	2026-06-30 12:43:17.125465+05
173	41	157	status_changed	in_progress	completed	Status updated to completed by Muhammad Sufiyan. Remark: Resolved.	2026-06-30 12:55:54.48455+05
174	41	157	comment_added	\N	[COMPLETED REMARK]: Resolved.	Completed remark added by Muhammad Sufiyan	2026-06-30 12:55:54.518713+05
175	43	193	created	\N	open	Project Master created for department oversight	2026-06-30 12:56:56.176697+05
176	44	193	created	\N	open	Created by Hunain Ali as a sub-ticket of #43	2026-06-30 12:56:56.187362+05
177	43	193	sub_ticket_created	\N	44	Sub-ticket #44 created by Hunain Ali	2026-06-30 12:56:56.187963+05
178	40	138	status_changed	in_progress	completed	Status updated to completed by Kamran. Remark: DONE	2026-06-30 12:57:33.616091+05
179	40	138	comment_added	\N	[COMPLETED REMARK]: DONE	Completed remark added by Kamran	2026-06-30 12:57:33.61787+05
180	44	123	assigned	Unassigned	Huraira Khan	Self-assigned	2026-06-30 12:58:19.208552+05
181	44	123	status_changed	open	in_progress	Status changed via self-assignment	2026-06-30 12:58:19.209417+05
182	44	137	assigned	Huraira Khan	Huraira Khan	Manager Syed Rameez Hussain assigned the ticket.	2026-06-30 12:58:28.788164+05
183	41	157	status_changed	completed	closed	Status updated to closed by Muhammad Sufiyan. Remark: Resolved	2026-06-30 12:58:51.89676+05
184	41	157	comment_added	\N	[CLOSED REMARK]: Resolved	Closed remark added by Muhammad Sufiyan	2026-06-30 12:58:51.898638+05
185	40	138	comment_added	\N	P.R Raised, PR num 626109072	Comment added by Kamran	2026-06-30 13:01:52.449712+05
186	33	170	assigned	Unassigned	Mohsin Ahmed Chohan	Self-assigned	2026-06-30 14:21:33.60813+05
187	33	170	status_changed	open	in_progress	Status changed via self-assignment	2026-06-30 14:21:33.609083+05
188	31	170	assigned	Unassigned	Mohsin Ahmed Chohan	Self-assigned	2026-06-30 14:21:42.48425+05
189	31	170	status_changed	open	in_progress	Status changed via self-assignment	2026-06-30 14:21:42.485106+05
190	40	137	status_changed	completed	closed	Status updated to closed by Syed Rameez Hussain. Remark: .	2026-06-30 14:25:29.240552+05
191	40	137	comment_added	\N	[CLOSED REMARK]: .	Closed remark added by Syed Rameez Hussain	2026-06-30 14:25:29.242341+05
192	35	170	assigned	Unassigned	Mohsin Ahmed Chohan	Self-assigned	2026-06-30 14:29:24.224333+05
193	35	170	status_changed	open	in_progress	Status changed via self-assignment	2026-06-30 14:29:24.225065+05
194	35	170	comment_added	\N	Please Provide us a PR	Comment added by Mohsin Ahmed Chohan	2026-06-30 14:29:48.654058+05
195	44	123	sub_ticket_created	\N	45	Sub-ticket #45 created for department Procurement [HOCM] (formerly Transfer)	2026-06-30 14:32:08.764785+05
196	45	123	created	\N	open	Created as a sub-ticket of #44	2026-06-30 14:32:08.765766+05
197	45	404	comment_added	\N	Kindly raise the PR first. Without an approved PR, the procurement process cannot be initiated.	Comment added by Muhammad Fahim	2026-06-30 14:33:59.913953+05
198	35	404	comment_added	\N	Kindly raise the PR first. Without an approved PR, the procurement process cannot be initiated.	Comment added by Muhammad Fahim	2026-06-30 14:35:23.347795+05
199	46	123	created	\N	open	Project Master created for department oversight	2026-06-30 14:37:01.115288+05
200	47	123	created	\N	open	Created by Huraira Khan as a sub-ticket of #46	2026-06-30 14:37:01.125888+05
201	46	123	sub_ticket_created	\N	47	Sub-ticket #47 created by Huraira Khan	2026-06-30 14:37:01.126473+05
202	33	404	comment_added	\N	Kindly raise the PR first. Without an approved PR, the procurement process cannot be initiated.	Comment added by Muhammad Fahim	2026-06-30 14:39:02.028825+05
203	47	404	comment_added	\N	Kindly raise the PR first. Without an approved PR, the procurement process cannot be initiated.	Comment added by Muhammad Fahim	2026-06-30 14:39:41.82926+05
204	36	116	status_changed	in_progress	completed	Status updated to completed by Abdul Rehman. Remark: Task Completed Alhamdulillah...	2026-06-30 14:40:13.963847+05
205	36	116	comment_added	\N	[COMPLETED REMARK]: Task Completed Alhamdulillah...	Completed remark added by Abdul Rehman	2026-06-30 14:40:13.965654+05
206	36	116	comment_added	\N	Sir Purchased new air pumps for our commercial and pool parked vehicles...	Comment added by Abdul Rehman	2026-06-30 14:42:14.029273+05
207	46	123	comment_added	\N	Edit: This Requirement is for Trial Shed of Matrix Plot: GRP. 47. PR updated	Comment added by Huraira Khan	2026-06-30 14:47:40.595329+05
208	48	123	created	\N	open	Project Master created for department oversight	2026-06-30 14:53:24.175129+05
209	49	123	created	\N	open	Created by Huraira Khan as a sub-ticket of #48	2026-06-30 14:53:24.185999+05
210	48	123	sub_ticket_created	\N	49	Sub-ticket #49 created by Huraira Khan	2026-06-30 14:53:24.186556+05
211	36	137	status_changed	completed	closed	Status updated to closed by Syed Rameez Hussain. Remark: DOne	2026-06-30 14:54:30.102455+05
212	36	137	comment_added	\N	[CLOSED REMARK]: DOne	Closed remark added by Syed Rameez Hussain	2026-06-30 14:54:30.104161+05
213	33	170	comment_added	\N	director approvals pending	Comment added by Mohsin Ahmed Chohan	2026-06-30 15:10:31.395126+05
214	50	35	created	\N	open	Project Master created for department oversight	2026-06-30 15:31:46.392538+05
215	51	35	created	\N	open	Created by Muhammad Qamar Khan as a sub-ticket of #50	2026-06-30 15:31:46.403253+05
216	50	35	sub_ticket_created	\N	51	Sub-ticket #51 created by Muhammad Qamar Khan	2026-06-30 15:31:46.403843+05
217	52	137	created	\N	in_progress	Created by Syed Rameez Hussain and assigned to Huraira Khan	2026-06-30 16:16:35.956249+05
218	52	123	sub_ticket_created	\N	53	Sub-ticket #53 created for department Procurement [HOCM] (formerly Transfer)	2026-06-30 16:19:17.567465+05
219	53	123	created	\N	open	Created as a sub-ticket of #52	2026-06-30 16:19:17.568471+05
220	54	138	created	\N	open	Created by Kamran	2026-06-30 16:33:47.109256+05
221	37	113	status_changed	in_progress	completed	Status updated to completed by Muhammad Owais Raza. Remark: share via email	2026-06-30 17:04:48.719949+05
222	37	113	comment_added	\N	[COMPLETED REMARK]: share via email	Completed remark added by Muhammad Owais Raza	2026-06-30 17:04:48.765617+05
223	37	137	status_changed	completed	closed	Status updated to closed by Syed Rameez Hussain. Remark: Done	2026-06-30 17:06:15.592838+05
224	37	137	comment_added	\N	[CLOSED REMARK]: Done	Closed remark added by Syed Rameez Hussain	2026-06-30 17:06:15.595676+05
225	54	123	assigned	Unassigned	Huraira Khan	Self-assigned	2026-06-30 17:12:49.640147+05
226	54	123	status_changed	open	in_progress	Status changed via self-assignment	2026-06-30 17:12:49.641171+05
227	54	123	status_changed	in_progress	completed	Status updated to completed by Huraira Khan. Remark: .	2026-06-30 17:13:01.500501+05
228	54	123	comment_added	\N	[COMPLETED REMARK]: .	Completed remark added by Huraira Khan	2026-06-30 17:13:01.502124+05
229	55	137	created	\N	in_progress	Created by Syed Rameez Hussain and assigned to Abdul Rehman	2026-06-30 17:52:31.429271+05
230	55	116	status_changed	in_progress	completed	Status updated to completed by Abdul Rehman. Remark: Task Completed...	2026-06-30 17:53:20.743313+05
231	55	116	comment_added	\N	[COMPLETED REMARK]: Task Completed...	Completed remark added by Abdul Rehman	2026-06-30 17:53:20.746047+05
232	55	137	status_changed	completed	closed	Status updated to closed by Syed Rameez Hussain. Remark: Done	2026-06-30 17:54:24.22814+05
233	55	137	comment_added	\N	[CLOSED REMARK]: Done	Closed remark added by Syed Rameez Hussain	2026-06-30 17:54:24.230057+05
234	56	156	created	\N	open	Project Master created for department oversight	2026-07-01 10:08:03.301137+05
235	57	156	created	\N	open	Created by Azhan Ahmed Qureshi as a sub-ticket of #56	2026-07-01 10:08:03.339514+05
236	56	156	sub_ticket_created	\N	57	Sub-ticket #57 created by Azhan Ahmed Qureshi	2026-07-01 10:08:03.340157+05
237	57	165	assigned	Unassigned	Muhammad Fashi Ullah Khan	Self-assigned	2026-07-01 10:13:30.744335+05
238	57	165	status_changed	open	in_progress	Status changed via self-assignment	2026-07-01 10:13:30.745304+05
239	21	156	assigned	Unassigned	Azhan Ahmed Qureshi	Self-assigned	2026-07-01 10:16:20.104735+05
240	21	156	status_changed	open	in_progress	Status changed via self-assignment	2026-07-01 10:16:20.105644+05
241	21	156	status_changed	in_progress	completed	Status updated to completed by Azhan Ahmed Qureshi. Remark: done	2026-07-01 10:16:37.134166+05
242	20	156	all_children_completed	\N	\N	All sub-tickets completed via #21	2026-07-01 10:16:37.136304+05
243	20	156	all_children_completed	\N	\N	All sub-tickets completed via #21	2026-07-01 10:16:37.137222+05
244	21	156	comment_added	\N	[COMPLETED REMARK]: done	Completed remark added by Azhan Ahmed Qureshi	2026-07-01 10:16:37.13873+05
245	21	156	status_changed	completed	closed	Status updated to closed by Azhan Ahmed Qureshi. Remark: done	2026-07-01 10:17:04.865924+05
246	21	156	comment_added	\N	[CLOSED REMARK]: done	Closed remark added by Azhan Ahmed Qureshi	2026-07-01 10:17:04.867159+05
247	20	163	status_changed	in_progress	completed	Status updated to completed by Muhammad Qasim Mehmood. Remark: done	2026-07-01 10:17:11.908777+05
248	20	163	comment_added	\N	[COMPLETED REMARK]: done	Completed remark added by Muhammad Qasim Mehmood	2026-07-01 10:17:11.910022+05
249	20	163	status_changed	completed	closed	Status updated to closed by Muhammad Qasim Mehmood. Remark: cd	2026-07-01 10:17:43.826583+05
250	20	163	comment_added	\N	[CLOSED REMARK]: cd	Closed remark added by Muhammad Qasim Mehmood	2026-07-01 10:17:43.828155+05
251	57	165	status_changed	in_progress	completed	Status updated to completed by Muhammad Fashi Ullah Khan. Remark: Completed	2026-07-01 10:18:11.77531+05
252	56	165	all_children_completed	\N	\N	All sub-tickets completed via #57	2026-07-01 10:18:11.77681+05
253	56	165	all_children_completed	\N	\N	All sub-tickets completed via #57	2026-07-01 10:18:11.777595+05
254	57	165	comment_added	\N	[COMPLETED REMARK]: Completed	Completed remark added by Muhammad Fashi Ullah Khan	2026-07-01 10:18:11.778738+05
255	57	165	status_changed	completed	closed	Status updated to closed by Muhammad Fashi Ullah Khan. Remark: Completed	2026-07-01 10:18:34.058158+05
256	57	165	comment_added	\N	[CLOSED REMARK]: Completed	Closed remark added by Muhammad Fashi Ullah Khan	2026-07-01 10:18:34.0593+05
257	56	156	status_changed	in_progress	completed	Status updated to completed by Azhan Ahmed Qureshi. Remark: Done	2026-07-01 10:18:44.764805+05
258	56	156	comment_added	\N	[COMPLETED REMARK]: Done	Completed remark added by Azhan Ahmed Qureshi	2026-07-01 10:18:44.765955+05
259	56	156	status_changed	completed	closed	Status updated to closed by Azhan Ahmed Qureshi. Remark: Done	2026-07-01 10:18:55.446183+05
260	56	156	comment_added	\N	[CLOSED REMARK]: Done	Closed remark added by Azhan Ahmed Qureshi	2026-07-01 10:18:55.447506+05
261	54	138	status_changed	completed	closed	Status updated to closed by Kamran. Remark: done	2026-07-01 10:48:53.47679+05
262	54	138	comment_added	\N	[CLOSED REMARK]: done	Closed remark added by Kamran	2026-07-01 10:48:53.47901+05
263	49	404	comment_added	\N	Approved PR is still awaited.	Comment added by Muhammad Fahim	2026-07-01 11:17:18.098187+05
264	58	137	created	\N	in_progress	Created by Syed Rameez Hussain and assigned to Huraira Khan	2026-07-01 11:24:06.280088+05
265	35	170	sub_ticket_created	\N	59	Sub-ticket #59 created for department Administration [HOCM] (formerly Transfer)	2026-07-01 11:36:21.783918+05
266	59	170	created	\N	open	Created as a sub-ticket of #35	2026-07-01 11:36:21.784795+05
267	60	101	created	\N	open	Project Master created for department oversight	2026-07-01 11:40:08.462247+05
268	61	101	created	\N	open	Created by Shah Fahad Khan as a sub-ticket of #60	2026-07-01 11:40:08.472912+05
269	60	101	sub_ticket_created	\N	61	Sub-ticket #61 created by Shah Fahad Khan	2026-07-01 11:40:08.473498+05
270	61	137	assigned	Unassigned	Huraira Khan	Manager Syed Rameez Hussain assigned the ticket.	2026-07-01 11:53:06.847528+05
271	61	137	status_changed	open	in_progress	Status changed due to assignment	2026-07-01 11:53:06.852705+05
272	61	123	status_changed	in_progress	completed	Status updated to completed by Huraira Khan. Remark: done	2026-07-01 11:53:43.403609+05
273	60	123	all_children_completed	\N	\N	All sub-tickets completed via #61	2026-07-01 11:53:43.4056+05
274	60	123	all_children_completed	\N	\N	All sub-tickets completed via #61	2026-07-01 11:53:43.406551+05
275	61	123	comment_added	\N	[COMPLETED REMARK]: done	Completed remark added by Huraira Khan	2026-07-01 11:53:43.408055+05
276	61	123	status_changed	completed	closed	Status updated to closed by Huraira Khan. Remark: done	2026-07-01 11:53:48.209765+05
277	61	123	comment_added	\N	[CLOSED REMARK]: done	Closed remark added by Huraira Khan	2026-07-01 11:53:48.211214+05
278	62	113	created	\N	open	Project Master created for department oversight	2026-07-01 11:59:02.284543+05
279	63	113	created	\N	open	Created by Muhammad Owais Raza as a sub-ticket of #62	2026-07-01 11:59:02.294635+05
280	62	113	sub_ticket_created	\N	63	Sub-ticket #63 created by Muhammad Owais Raza	2026-07-01 11:59:02.295129+05
281	64	137	created	\N	in_progress	Created by Syed Rameez Hussain and assigned to Abdul Rehman	2026-07-01 12:15:26.610693+05
282	65	137	created	\N	in_progress	Created by Syed Rameez Hussain and assigned to Huraira Khan	2026-07-01 12:18:06.011313+05
283	66	137	created	\N	in_progress	Created by Syed Rameez Hussain and assigned to Kamran	2026-07-01 12:20:52.718997+05
284	39	1	assigned	Unassigned	Qasim	Self-assigned	2026-07-01 12:26:32.352441+05
285	39	1	status_changed	open	in_progress	Status changed via self-assignment	2026-07-01 12:26:32.353367+05
286	38	1	comment_added	\N	Acknowledged.	Comment added by Qasim	2026-07-01 12:27:04.824814+05
287	65	123	status_changed	in_progress	completed	Status updated to completed by Huraira Khan. Remark: done	2026-07-01 12:55:37.154092+05
288	65	123	comment_added	\N	[COMPLETED REMARK]: done	Completed remark added by Huraira Khan	2026-07-01 12:55:37.156052+05
289	58	123	status_changed	in_progress	completed	Status updated to completed by Huraira Khan. Remark: done	2026-07-01 12:57:16.513819+05
290	58	123	comment_added	\N	[COMPLETED REMARK]: done	Completed remark added by Huraira Khan	2026-07-01 12:57:16.515832+05
291	47	123	comment_added	\N	PR# already mentioned in description.	Comment added by Huraira Khan	2026-07-01 13:00:01.437229+05
292	67	137	created	\N	in_progress	Created by Syed Rameez Hussain and assigned to Abdul Rehman	2026-07-01 15:48:36.742087+05
293	66	138	comment_added	\N	We have received two quotations. We are now waiting for the remaining one quotation.	Comment added by Kamran	2026-07-01 16:05:37.693652+05
294	67	116	status_changed	in_progress	completed	Status updated to completed by Abdul Rehman. Remark: Task completed...	2026-07-01 16:15:01.935478+05
295	67	116	comment_added	\N	[COMPLETED REMARK]: Task completed...	Completed remark added by Abdul Rehman	2026-07-01 16:15:01.966251+05
296	64	116	status_changed	in_progress	completed	Status updated to completed by Abdul Rehman. Remark: prepared summary and given to IQs for approval...	2026-07-01 16:15:33.141192+05
297	64	116	comment_added	\N	[COMPLETED REMARK]: prepared summary and given to IQs for approval...	Completed remark added by Abdul Rehman	2026-07-01 16:15:33.142521+05
298	49	404	comment_added	\N	Kindly share the details/specifications against your requirement or approved PR. Once received, we w	Comment added by Muhammad Fahim	2026-07-01 16:20:30.578707+05
299	68	123	created	\N	open	Project Master created for department oversight	2026-07-01 16:37:52.178945+05
300	69	123	created	\N	open	Created by Huraira Khan as a sub-ticket of #68	2026-07-01 16:37:52.190591+05
301	68	123	sub_ticket_created	\N	69	Sub-ticket #69 created by Huraira Khan	2026-07-01 16:37:52.191212+05
302	70	123	created	\N	open	Project Master created for department oversight	2026-07-01 16:42:33.014501+05
303	71	123	created	\N	open	Created by Huraira Khan as a sub-ticket of #70	2026-07-01 16:42:33.025694+05
304	70	123	sub_ticket_created	\N	71	Sub-ticket #71 created by Huraira Khan	2026-07-01 16:42:33.026328+05
305	65	137	status_changed	completed	closed	Status updated to closed by Syed Rameez Hussain. Remark: done	2026-07-01 17:03:58.010191+05
306	65	137	comment_added	\N	[CLOSED REMARK]: done	Closed remark added by Syed Rameez Hussain	2026-07-01 17:03:58.057334+05
307	67	137	status_changed	completed	closed	Status updated to closed by Syed Rameez Hussain. Remark: done	2026-07-01 17:04:08.571301+05
308	67	137	comment_added	\N	[CLOSED REMARK]: done	Closed remark added by Syed Rameez Hussain	2026-07-01 17:04:08.572684+05
309	72	116	created	\N	open	Created by Abdul Rehman	2026-07-01 17:59:22.008714+05
310	72	116	assigned	Unassigned	Abdul Rehman	Self-assigned	2026-07-01 17:59:51.833059+05
311	72	116	status_changed	open	in_progress	Status changed via self-assignment	2026-07-01 17:59:51.833731+05
312	72	116	status_changed	in_progress	completed	Status updated to completed by Abdul Rehman. Remark: done...	2026-07-01 18:02:32.269049+05
313	72	116	comment_added	\N	[COMPLETED REMARK]: done...	Completed remark added by Abdul Rehman	2026-07-01 18:02:32.271056+05
314	72	116	status_changed	completed	closed	Status updated to closed by Abdul Rehman. Remark: delivered...	2026-07-01 18:02:56.888031+05
315	72	116	comment_added	\N	[CLOSED REMARK]: delivered...	Closed remark added by Abdul Rehman	2026-07-01 18:02:56.889315+05
316	59	137	assigned	Unassigned	Syed Rameez Hussain	Self-assigned	2026-07-02 10:18:33.831325+05
317	59	137	status_changed	open	in_progress	Status changed via self-assignment	2026-07-02 10:18:33.832368+05
318	59	137	sub_ticket_created	\N	73	Sub-ticket #73 created for department Warehouse [FDFD] (formerly Transfer)	2026-07-02 10:19:57.440139+05
319	73	137	created	\N	open	Created as a sub-ticket of #59	2026-07-02 10:19:57.441054+05
320	45	123	comment_added	\N	No approval is required for purchases below Rs. 50,000. Please proceed with the procurement accordin	Comment added by Huraira Khan	2026-07-02 10:39:44.926078+05
321	74	36	created	\N	open	Project Master created for department oversight	2026-07-02 14:48:27.471879+05
322	75	36	created	\N	open	Created by Muhammad Ammar Waseem as a sub-ticket of #74	2026-07-02 14:48:27.483037+05
323	74	36	sub_ticket_created	\N	75	Sub-ticket #75 created by Muhammad Ammar Waseem	2026-07-02 14:48:27.483617+05
324	74	36	comment_added	\N	closed	Comment added by Muhammad Ammar Waseem	2026-07-02 15:30:08.698091+05
325	74	36	comment_added	\N	mistakely created to it dept	Comment added by Muhammad Ammar Waseem	2026-07-02 15:48:22.904282+05
326	75	165	assigned	Unassigned	Muhammad Fashi Ullah Khan	Self-assigned	2026-07-02 15:49:18.136465+05
327	75	165	status_changed	open	in_progress	Status changed via self-assignment	2026-07-02 15:49:18.137388+05
328	74	165	comment_added	\N	acknlowedged kindly send this to ERP department (in knowledge to Mr.Qasim [DEV]department )	Comment added by Muhammad Fashi Ullah Khan	2026-07-02 15:50:12.261901+05
329	75	165	status_changed	in_progress	completed	Status updated to completed by Muhammad Fashi Ullah Khan. Remark: CCD	2026-07-02 15:50:29.049784+05
330	74	165	all_children_completed	\N	\N	All sub-tickets completed via #75	2026-07-02 15:50:29.051687+05
331	74	165	all_children_completed	\N	\N	All sub-tickets completed via #75	2026-07-02 15:50:29.052619+05
332	75	165	comment_added	\N	[COMPLETED REMARK]: CCD	Completed remark added by Muhammad Fashi Ullah Khan	2026-07-02 15:50:29.053784+05
333	75	165	status_changed	completed	closed	Status updated to closed by Muhammad Fashi Ullah Khan. Remark: CD	2026-07-02 15:50:33.130378+05
334	75	165	comment_added	\N	[CLOSED REMARK]: CD	Closed remark added by Muhammad Fashi Ullah Khan	2026-07-02 15:50:33.131949+05
335	74	36	status_changed	in_progress	completed	Status updated to completed by Muhammad Ammar Waseem. Remark: CD	2026-07-02 15:50:44.564423+05
336	74	36	comment_added	\N	[COMPLETED REMARK]: CD	Completed remark added by Muhammad Ammar Waseem	2026-07-02 15:50:44.565689+05
337	74	36	status_changed	completed	closed	Status updated to closed by Muhammad Ammar Waseem. Remark: CD	2026-07-02 15:50:49.902815+05
338	74	36	comment_added	\N	[CLOSED REMARK]: CD	Closed remark added by Muhammad Ammar Waseem	2026-07-02 15:50:49.904049+05
339	76	32	created	\N	open	Project Master created for department oversight	2026-07-02 16:42:30.783154+05
340	77	32	created	\N	open	Created by Kosain Hanif as a sub-ticket of #76	2026-07-02 16:42:30.794123+05
341	76	32	sub_ticket_created	\N	77	Sub-ticket #77 created by Kosain Hanif	2026-07-02 16:42:30.794777+05
342	78	170	created	\N	open	Project Master created for department oversight	2026-07-02 16:56:16.790729+05
343	79	170	created	\N	open	Created by Mohsin Ahmed Chohan as a sub-ticket of #78	2026-07-02 16:56:16.801723+05
344	78	170	sub_ticket_created	\N	79	Sub-ticket #79 created by Mohsin Ahmed Chohan	2026-07-02 16:56:16.802361+05
345	79	166	assigned	Unassigned	Muhammad Hamza Khan	Self-assigned	2026-07-02 16:57:48.05046+05
346	79	166	status_changed	open	in_progress	Status changed via self-assignment	2026-07-02 16:57:48.051406+05
347	78	166	comment_added	\N	Done	Comment added by Muhammad Hamza Khan	2026-07-02 16:58:13.474346+05
348	79	166	status_changed	in_progress	completed	Status updated to completed by Muhammad Hamza Khan. Remark: Done	2026-07-02 16:58:36.806375+05
349	78	166	all_children_completed	\N	\N	All sub-tickets completed via #79	2026-07-02 16:58:36.808369+05
350	78	166	all_children_completed	\N	\N	All sub-tickets completed via #79	2026-07-02 16:58:36.809315+05
351	79	166	comment_added	\N	[COMPLETED REMARK]: Done	Completed remark added by Muhammad Hamza Khan	2026-07-02 16:58:36.810714+05
352	79	166	status_changed	completed	closed	Status updated to closed by Muhammad Hamza Khan. Remark: Done	2026-07-02 16:59:07.217762+05
353	79	166	comment_added	\N	[CLOSED REMARK]: Done	Closed remark added by Muhammad Hamza Khan	2026-07-02 16:59:07.219054+05
354	47	404	comment_added	\N	Awaiting for PR	Comment added by Muhammad Fahim	2026-07-02 17:17:43.697406+05
355	45	404	comment_added	\N	Awaiting for PR	Comment added by Muhammad Fahim	2026-07-02 17:19:13.524755+05
356	69	1	assigned	Unassigned	Qasim	Self-assigned	2026-07-02 18:03:03.50173+05
357	69	1	status_changed	open	in_progress	Status changed via self-assignment	2026-07-02 18:03:03.528285+05
358	69	1	status_changed	in_progress	completed	Status updated to completed by Qasim. Remark: fixed and uploaded its live now	2026-07-02 18:03:52.604183+05
359	68	1	all_children_completed	\N	\N	All sub-tickets completed via #69	2026-07-02 18:03:52.606455+05
360	68	1	all_children_completed	\N	\N	All sub-tickets completed via #69	2026-07-02 18:03:52.607475+05
361	69	1	comment_added	\N	[COMPLETED REMARK]: fixed and uploaded its live now	Completed remark added by Qasim	2026-07-02 18:03:52.609071+05
362	69	1	status_changed	completed	closed	Status updated to closed by Qasim. Remark: Publish on web	2026-07-02 18:04:14.915855+05
363	69	1	comment_added	\N	[CLOSED REMARK]: Publish on web	Closed remark added by Qasim	2026-07-02 18:04:14.917233+05
364	80	123	created	\N	open	Project Master created for department oversight	2026-07-03 10:04:00.198913+05
365	81	123	created	\N	open	Created by Huraira Khan as a sub-ticket of #80	2026-07-03 10:04:00.210166+05
366	80	123	sub_ticket_created	\N	81	Sub-ticket #81 created by Huraira Khan	2026-07-03 10:04:00.210868+05
367	81	404	comment_added	\N	Kindly provide the signed physical copy of the PR, as it is required to proceed with the procurement	Comment added by Muhammad Fahim	2026-07-03 10:23:09.699686+05
368	45	404	comment_added	\N	The Purchase Requisition is the primary document required to initiate the procurement process. Witho	Comment added by Muhammad Fahim	2026-07-03 10:25:10.534935+05
369	31	404	comment_added	\N	The ladder was delivered yesterday.	Comment added by Muhammad Fahim	2026-07-03 10:26:16.833137+05
370	31	123	comment_added	\N	Thanks. Please complete the task so i can close.	Comment added by Huraira Khan	2026-07-03 10:30:04.728835+05
371	81	123	comment_added	\N	No need of physical PR. Please check Faraz-ERP email related to this for your assistance.	Comment added by Huraira Khan	2026-07-03 10:37:41.902846+05
372	30	123	comment_added	\N	TESTING QASIM	Comment added by Huraira Khan	2026-07-03 10:44:45.013316+05
373	68	123	status_changed	in_progress	completed	Status updated to completed by Huraira Khan. Remark: CD	2026-07-03 10:55:30.554911+05
374	68	123	comment_added	\N	[COMPLETED REMARK]: CD	Completed remark added by Huraira Khan	2026-07-03 10:55:30.556705+05
375	68	123	status_changed	completed	closed	Status updated to closed by Huraira Khan. Remark: CD	2026-07-03 10:55:47.983953+05
376	68	123	comment_added	\N	[CLOSED REMARK]: CD	Closed remark added by Huraira Khan	2026-07-03 10:55:47.985831+05
377	82	1	created	\N	open	Project Master created for department oversight	2026-07-03 10:57:48.93056+05
378	83	1	created	\N	open	Created by Qasim as a sub-ticket of #82	2026-07-03 10:57:48.941435+05
379	82	1	sub_ticket_created	\N	83	Sub-ticket #83 created by Qasim	2026-07-03 10:57:48.942066+05
380	83	123	assigned	Unassigned	Huraira Khan	Self-assigned	2026-07-03 10:59:58.415483+05
381	83	123	status_changed	open	in_progress	Status changed via self-assignment	2026-07-03 10:59:58.416387+05
382	82	123	comment_added	\N	completed TESTING COMMENT	Comment added by Huraira Khan	2026-07-03 11:00:14.38882+05
383	82	1	comment_added	\N	QASIM TESTING @	Comment added by Qasim	2026-07-03 11:00:54.466967+05
384	83	123	status_changed	in_progress	completed	Status updated to completed by Huraira Khan. Remark: CD	2026-07-03 11:01:38.235955+05
385	82	123	all_children_completed	\N	\N	All sub-tickets completed via #83	2026-07-03 11:01:38.237918+05
386	82	123	all_children_completed	\N	\N	All sub-tickets completed via #83	2026-07-03 11:01:38.238859+05
387	83	123	comment_added	\N	[COMPLETED REMARK]: CD	Completed remark added by Huraira Khan	2026-07-03 11:01:38.239937+05
388	83	123	status_changed	completed	closed	Status updated to closed by Huraira Khan. Remark: CD	2026-07-03 11:01:41.140024+05
389	83	123	comment_added	\N	[CLOSED REMARK]: CD	Closed remark added by Huraira Khan	2026-07-03 11:01:41.141801+05
390	82	1	status_changed	in_progress	completed	Status updated to completed by Qasim. Remark: CD	2026-07-03 11:01:57.456819+05
391	82	1	comment_added	\N	[COMPLETED REMARK]: CD	Completed remark added by Qasim	2026-07-03 11:01:57.458128+05
392	82	1	status_changed	completed	closed	Status updated to closed by Qasim. Remark: CD	2026-07-03 11:02:04.360168+05
393	82	1	comment_added	\N	[CLOSED REMARK]: CD	Closed remark added by Qasim	2026-07-03 11:02:04.361527+05
394	84	137	created	\N	in_progress	Created by Syed Rameez Hussain and assigned to Abdul Rehman	2026-07-03 11:29:47.631357+05
395	84	116	status_changed	in_progress	completed	Status updated to completed by Abdul Rehman. Remark: Payment Deposited Successfully...	2026-07-03 11:31:41.610045+05
396	84	116	comment_added	\N	[COMPLETED REMARK]: Payment Deposited Successfully...	Completed remark added by Abdul Rehman	2026-07-03 11:31:41.611892+05
397	66	138	status_changed	in_progress	completed	Status updated to completed by Kamran. Remark: done	2026-07-03 11:43:47.591993+05
398	66	138	comment_added	\N	[COMPLETED REMARK]: done	Completed remark added by Kamran	2026-07-03 11:43:47.593914+05
399	78	170	status_changed	in_progress	completed	Status updated to completed by Mohsin Ahmed Chohan. Remark: thanks and work done	2026-07-03 11:48:05.76279+05
400	78	170	comment_added	\N	[COMPLETED REMARK]: thanks and work done	Completed remark added by Mohsin Ahmed Chohan	2026-07-03 11:48:05.764591+05
401	78	170	status_changed	completed	closed	Status updated to closed by Mohsin Ahmed Chohan. Remark: work done	2026-07-03 11:48:38.246764+05
402	78	170	comment_added	\N	[CLOSED REMARK]: work done	Closed remark added by Mohsin Ahmed Chohan	2026-07-03 11:48:38.248125+05
403	31	170	status_changed	in_progress	completed	Status updated to completed by Mohsin Ahmed Chohan. Remark: Laddar has been successfully delivered	2026-07-03 12:12:27.836462+05
404	30	170	all_children_completed	\N	\N	All sub-tickets completed via #31	2026-07-03 12:12:27.838627+05
405	30	170	all_children_completed	\N	\N	All sub-tickets completed via #31	2026-07-03 12:12:27.83955+05
406	31	170	comment_added	\N	[COMPLETED REMARK]: Laddar has been successfully delivered	Completed remark added by Mohsin Ahmed Chohan	2026-07-03 12:12:27.841034+05
407	31	170	status_changed	completed	closed	Status updated to closed by Mohsin Ahmed Chohan. Remark: Laddar has been successfully delivered	2026-07-03 12:12:58.803493+05
408	31	170	comment_added	\N	[CLOSED REMARK]: Laddar has been successfully delivered	Closed remark added by Mohsin Ahmed Chohan	2026-07-03 12:12:58.804771+05
409	81	404	comment_added	\N	As per company policy, signed or approved PR is mandatory before processing any procurement request 	Comment added by Muhammad Fahim	2026-07-03 12:17:25.842573+05
410	85	137	created	\N	in_progress	Created by Syed Rameez Hussain and assigned to Huraira Khan	2026-07-03 15:05:02.191492+05
411	85	123	sub_ticket_created	\N	86	Sub-ticket #86 created for department Procurement [HOCM] (formerly Transfer)	2026-07-03 15:10:09.695642+05
412	86	123	created	\N	open	Created as a sub-ticket of #85	2026-07-03 15:10:09.696593+05
413	53	404	comment_added	\N	Isuzu: Approval is currently pending with the Directors for final decision.\nSuzuki Ravi: The approva	Comment added by Muhammad Fahim	2026-07-03 16:15:05.804707+05
414	63	201	comment_added	\N	completed	Comment added by Fazal ur Rehman Khan	2026-07-03 17:07:28.514258+05
415	63	201	assigned	Unassigned	Fazal ur Rehman Khan	Self-assigned	2026-07-03 17:12:54.36356+05
416	63	201	status_changed	open	in_progress	Status changed via self-assignment	2026-07-03 17:12:54.364693+05
417	63	201	comment_added	\N	Task completed, please close the ticket	Comment added by Fazal ur Rehman Khan	2026-07-03 17:13:25.120195+05
418	87	154	created	\N	open	Project Master created for multi-department task	2026-07-03 17:15:37.136076+05
419	88	154	created	\N	open	Created by Muhammad Rasheed as a sub-ticket of #87	2026-07-03 17:15:37.147756+05
420	87	154	sub_ticket_created	\N	88	Sub-ticket #88 created by Muhammad Rasheed	2026-07-03 17:15:37.148399+05
421	89	154	created	\N	open	Created by Muhammad Rasheed as a sub-ticket of #87	2026-07-03 17:15:37.166+05
422	87	154	sub_ticket_created	\N	89	Sub-ticket #89 created by Muhammad Rasheed	2026-07-03 17:15:37.166579+05
423	90	154	created	\N	open	Created by Muhammad Rasheed as a sub-ticket of #87	2026-07-03 17:15:37.180457+05
424	87	154	sub_ticket_created	\N	90	Sub-ticket #90 created by Muhammad Rasheed	2026-07-03 17:15:37.181069+05
425	91	200	created	\N	open	Project Master created for department oversight	2026-07-03 18:12:22.924201+05
426	92	200	created	\N	open	Created by Sarfaraz Ahmed Khan as a sub-ticket of #91	2026-07-03 18:12:22.935698+05
427	91	200	sub_ticket_created	\N	92	Sub-ticket #92 created by Sarfaraz Ahmed Khan	2026-07-03 18:12:22.936299+05
428	93	34	created	\N	open	Project Master created for department oversight	2026-07-03 18:14:05.190836+05
429	94	34	created	\N	open	Created by Muhammad Uzair as a sub-ticket of #93	2026-07-03 18:14:05.202338+05
430	93	34	sub_ticket_created	\N	94	Sub-ticket #94 created by Muhammad Uzair	2026-07-03 18:14:05.202941+05
431	95	200	created	\N	open	Project Master created for department oversight	2026-07-03 18:35:30.548987+05
432	96	200	created	\N	open	Created by Sarfaraz Ahmed Khan as a sub-ticket of #95	2026-07-03 18:35:30.560482+05
433	95	200	sub_ticket_created	\N	96	Sub-ticket #96 created by Sarfaraz Ahmed Khan	2026-07-03 18:35:30.561098+05
434	94	164	assigned	Unassigned	Bilal Ahmed	Self-assigned	2026-07-04 09:43:18.258578+05
435	94	164	status_changed	open	in_progress	Status changed via self-assignment	2026-07-04 09:43:18.259557+05
436	93	164	comment_added	\N	We rasied complaint to cloud team . cloud team sent his representator to resolve this issue kindly i	Comment added by Bilal Ahmed	2026-07-04 09:45:42.61567+05
437	30	123	status_changed	in_progress	completed	Status updated to completed by Huraira Khan. Remark: Done	2026-07-04 09:46:22.608185+05
438	30	123	comment_added	\N	[COMPLETED REMARK]: Done	Completed remark added by Huraira Khan	2026-07-04 09:46:22.60955+05
439	88	168	assigned	Unassigned	Dilawar Farrukh Rauf	Self-assigned	2026-07-04 09:52:10.26471+05
440	88	168	status_changed	open	in_progress	Status changed via self-assignment	2026-07-04 09:52:10.265604+05
441	88	168	comment_added	\N	ali.sahito@um.com.pk	Comment added by Dilawar Farrukh Rauf	2026-07-04 09:56:22.700908+05
442	88	168	status_changed	in_progress	completed	Status updated to completed by Dilawar Farrukh Rauf. Remark: Done	2026-07-04 09:57:11.548993+05
443	88	168	comment_added	\N	[COMPLETED REMARK]: Done	Completed remark added by Dilawar Farrukh Rauf	2026-07-04 09:57:11.551905+05
444	30	123	status_changed	completed	closed	Status updated to closed by Huraira Khan. Remark: done	2026-07-04 10:28:57.379175+05
445	30	123	comment_added	\N	[CLOSED REMARK]: done	Closed remark added by Huraira Khan	2026-07-04 10:28:57.381076+05
446	66	137	status_changed	completed	closed	Status updated to closed by Syed Rameez Hussain. Remark: Done	2026-07-04 10:37:05.384128+05
447	66	137	comment_added	\N	[CLOSED REMARK]: Done	Closed remark added by Syed Rameez Hussain	2026-07-04 10:37:05.386499+05
448	97	243	created	\N	open	Project Master created for multi-department task	2026-07-06 10:15:35.609072+05
449	98	243	created	\N	open	Created by Irfan Baloch as a sub-ticket of #97	2026-07-06 10:15:35.666778+05
450	97	243	sub_ticket_created	\N	98	Sub-ticket #98 created by Irfan Baloch	2026-07-06 10:15:35.667391+05
451	99	243	created	\N	open	Created by Irfan Baloch as a sub-ticket of #97	2026-07-06 10:15:35.709284+05
452	97	243	sub_ticket_created	\N	99	Sub-ticket #99 created by Irfan Baloch	2026-07-06 10:15:35.709862+05
453	100	37	created	\N	open	Project Master created for department oversight	2026-07-06 11:19:46.330575+05
454	101	37	created	\N	open	Created by Muhammad Sarfaraz Hussain as a sub-ticket of #100	2026-07-06 11:19:46.341849+05
455	100	37	sub_ticket_created	\N	101	Sub-ticket #101 created by Muhammad Sarfaraz Hussain	2026-07-06 11:19:46.342424+05
456	98	404	assigned	Unassigned	Mohammad Farhan	Manager Muhammad Fahim assigned the ticket.	2026-07-06 12:24:44.472625+05
457	98	404	status_changed	open	in_progress	Status changed due to assignment	2026-07-06 12:24:44.483108+05
458	53	404	assigned	Unassigned	Mohsin Ahmed Chohan	Manager Muhammad Fahim assigned the ticket.	2026-07-06 12:25:10.230677+05
459	53	404	status_changed	open	in_progress	Status changed due to assignment	2026-07-06 12:25:10.283272+05
460	26	168	comment_added	\N	Devices have been approved by Ali sb. and ordered has been placed with Zong	Comment added by Dilawar Farrukh Rauf	2026-07-06 12:28:53.947743+05
461	102	123	created	\N	open	Project Master created for department oversight	2026-07-06 13:23:00.781038+05
462	103	123	created	\N	open	Created by Huraira Khan as a sub-ticket of #102	2026-07-06 13:23:00.792048+05
463	102	123	sub_ticket_created	\N	103	Sub-ticket #103 created by Huraira Khan	2026-07-06 13:23:00.792681+05
464	102	123	comment_added	\N	PR# 726109020	Comment added by Huraira Khan	2026-07-06 13:23:23.655827+05
465	86	404	assigned	Unassigned	Mohammad Farhan	Manager Muhammad Fahim assigned the ticket.	2026-07-07 09:48:22.868198+05
466	86	404	status_changed	open	in_progress	Status changed due to assignment	2026-07-07 09:48:22.985318+05
467	81	404	assigned	Unassigned	Mohsin Ahmed Chohan	Manager Muhammad Fahim assigned the ticket.	2026-07-07 09:48:33.567504+05
468	81	404	status_changed	open	in_progress	Status changed due to assignment	2026-07-07 09:48:33.572037+05
469	103	404	assigned	Unassigned	Mohsin Ahmed Chohan	Manager Muhammad Fahim assigned the ticket.	2026-07-07 09:48:44.538943+05
470	103	404	status_changed	open	in_progress	Status changed due to assignment	2026-07-07 09:48:44.543346+05
471	49	404	assigned	Unassigned	Mohsin Ahmed Chohan	Manager Muhammad Fahim assigned the ticket.	2026-07-07 09:49:21.09156+05
472	49	404	status_changed	open	in_progress	Status changed due to assignment	2026-07-07 09:49:21.095719+05
473	47	404	assigned	Unassigned	Mohsin Ahmed Chohan	Manager Muhammad Fahim assigned the ticket.	2026-07-07 09:49:34.936293+05
474	47	404	status_changed	open	in_progress	Status changed due to assignment	2026-07-07 09:49:34.940563+05
475	45	404	assigned	Unassigned	Mohsin Ahmed Chohan	Manager Muhammad Fahim assigned the ticket.	2026-07-07 09:49:41.11967+05
476	45	404	status_changed	open	in_progress	Status changed due to assignment	2026-07-07 09:49:41.167337+05
477	34	170	comment_added	\N	job has been done kindly huraira close this task	Comment added by Mohsin Ahmed Chohan	2026-07-07 10:39:06.283678+05
478	104	154	created	\N	open	Project Master created for department oversight	2026-07-07 11:39:29.362657+05
479	105	154	created	\N	open	Created by Muhammad Rasheed as a sub-ticket of #104	2026-07-07 11:39:29.374179+05
480	104	154	sub_ticket_created	\N	105	Sub-ticket #105 created by Muhammad Rasheed	2026-07-07 11:39:29.37478+05
481	104	154	comment_added	\N	I kindly request you to process this request at the earliest.	Comment added by Muhammad Rasheed	2026-07-07 11:41:38.995895+05
482	106	168	created	\N	open	Project Master created for department oversight	2026-07-07 13:37:52.13228+05
483	107	168	created	\N	open	Created by Dilawar Farrukh Rauf as a sub-ticket of #106	2026-07-07 13:37:52.14434+05
484	106	168	sub_ticket_created	\N	107	Sub-ticket #107 created by Dilawar Farrukh Rauf	2026-07-07 13:37:52.144986+05
485	108	89	created	\N	open	Project Master created for department oversight	2026-07-08 11:21:56.828653+05
486	109	89	created	\N	open	Created by Muhammad Noshad Gull as a sub-ticket of #108	2026-07-08 11:21:56.868223+05
487	108	89	sub_ticket_created	\N	109	Sub-ticket #109 created by Muhammad Noshad Gull	2026-07-08 11:21:56.868895+05
488	110	400	created	\N	open	Project Master created for department oversight	2026-07-08 11:22:31.529413+05
489	111	400	created	\N	open	Created by Hassan Ahmed Faruqi as a sub-ticket of #110	2026-07-08 11:22:31.54006+05
490	110	400	sub_ticket_created	\N	111	Sub-ticket #111 created by Hassan Ahmed Faruqi	2026-07-08 11:22:31.540703+05
491	112	71	created	\N	open	Project Master created for department oversight	2026-07-08 11:36:52.803723+05
492	113	71	created	\N	open	Created by Syed Mohsin Hasan as a sub-ticket of #112	2026-07-08 11:36:52.815189+05
493	112	71	sub_ticket_created	\N	113	Sub-ticket #113 created by Syed Mohsin Hasan	2026-07-08 11:36:52.815764+05
494	114	71	created	\N	open	Project Master created for department oversight	2026-07-08 11:53:51.885528+05
495	115	71	created	\N	open	Created by Syed Mohsin Hasan as a sub-ticket of #114	2026-07-08 11:53:51.89688+05
496	114	71	sub_ticket_created	\N	115	Sub-ticket #115 created by Syed Mohsin Hasan	2026-07-08 11:53:51.897542+05
497	105	404	assigned	Unassigned	Mohammad Farhan	Manager Muhammad Fahim assigned the ticket.	2026-07-08 12:09:50.563182+05
498	105	404	status_changed	open	in_progress	Status changed due to assignment	2026-07-08 12:09:50.578102+05
499	107	404	assigned	Unassigned	Mohsin Ahmed Chohan	Manager Muhammad Fahim assigned the ticket.	2026-07-08 12:09:58.625549+05
500	107	404	status_changed	open	in_progress	Status changed due to assignment	2026-07-08 12:09:58.630007+05
501	116	157	created	\N	open	Project Master created for department oversight	2026-07-08 14:05:23.089548+05
502	117	157	created	\N	open	Created by Muhammad Sufiyan as a sub-ticket of #116	2026-07-08 14:05:23.101632+05
503	116	157	sub_ticket_created	\N	117	Sub-ticket #117 created by Muhammad Sufiyan	2026-07-08 14:05:23.102358+05
504	117	167	assigned	Unassigned	Muhammad Yahya Ajmal	Self-assigned	2026-07-08 15:02:56.801134+05
505	117	167	status_changed	open	in_progress	Status changed via self-assignment	2026-07-08 15:02:56.802114+05
506	50	35	comment_added	\N	Material has been shifted successfully.	Comment added by Muhammad Qamar Khan	2026-07-08 15:06:43.976942+05
507	111	165	assigned	Unassigned	Muhammad Fashi Ullah Khan	Self-assigned	2026-07-08 15:08:35.061711+05
508	111	165	status_changed	open	in_progress	Status changed via self-assignment	2026-07-08 15:08:35.062472+05
509	111	165	sub_ticket_created	\N	118	Sub-ticket #118 created for department Procurement [HOCM] (formerly Transfer)	2026-07-08 15:10:48.821311+05
510	118	165	created	\N	open	Created as a sub-ticket of #111	2026-07-08 15:10:48.822241+05
511	117	167	status_changed	in_progress	completed	Status updated to completed by Muhammad Yahya Ajmal. Remark: Task Resolved	2026-07-08 15:19:00.136197+05
512	116	167	all_children_completed	\N	\N	All sub-tickets completed via #117	2026-07-08 15:19:00.138417+05
513	116	167	all_children_completed	\N	\N	All sub-tickets completed via #117	2026-07-08 15:19:00.139353+05
514	117	167	comment_added	\N	[COMPLETED REMARK]: Task Resolved	Completed remark added by Muhammad Yahya Ajmal	2026-07-08 15:19:00.140784+05
515	116	157	comment_added	\N	Resolved. Thanks Yahya	Comment added by Muhammad Sufiyan	2026-07-08 16:04:23.992081+05
516	119	154	created	\N	open	Project Master created for multi-department task	2026-07-08 16:27:35.411131+05
517	120	154	created	\N	open	Created by Muhammad Rasheed as a sub-ticket of #119	2026-07-08 16:27:35.421999+05
518	119	154	sub_ticket_created	\N	120	Sub-ticket #120 created by Muhammad Rasheed	2026-07-08 16:27:35.422602+05
519	121	154	created	\N	open	Created by Muhammad Rasheed as a sub-ticket of #119	2026-07-08 16:27:35.437145+05
520	119	154	sub_ticket_created	\N	121	Sub-ticket #121 created by Muhammad Rasheed	2026-07-08 16:27:35.437904+05
521	122	154	created	\N	open	Created by Muhammad Rasheed as a sub-ticket of #119	2026-07-08 16:27:35.451307+05
522	119	154	sub_ticket_created	\N	122	Sub-ticket #122 created by Muhammad Rasheed	2026-07-08 16:27:35.4519+05
523	104	154	comment_added	\N	Any update	Comment added by Muhammad Rasheed	2026-07-08 16:28:17.958785+05
524	119	154	comment_added	\N	Admin and ERP any update	Comment added by Muhammad Rasheed	2026-07-08 16:32:16.035797+05
525	87	154	comment_added	\N	Dear Team,\n\nPlease make the necessary arrangements as mentioned below Also kindly provide me with th	Comment added by Muhammad Rasheed	2026-07-08 16:33:07.865629+05
526	117	167	status_changed	completed	closed	Status updated to closed by Muhammad Yahya Ajmal. Remark: Task Completed	2026-07-09 10:15:11.980617+05
527	117	167	comment_added	\N	[CLOSED REMARK]: Task Completed	Closed remark added by Muhammad Yahya Ajmal	2026-07-09 10:15:12.081684+05
528	121	166	assigned	Unassigned	Muhammad Hamza Khan	Self-assigned	2026-07-09 10:16:32.188954+05
529	121	166	status_changed	open	in_progress	Status changed via self-assignment	2026-07-09 10:16:32.189611+05
530	121	166	status_changed	in_progress	completed	Status updated to completed by Muhammad Hamza Khan. Remark: Done	2026-07-09 10:16:45.610917+05
531	121	166	comment_added	\N	[COMPLETED REMARK]: Done	Completed remark added by Muhammad Hamza Khan	2026-07-09 10:16:45.613261+05
532	121	166	status_changed	completed	closed	Status updated to closed by Muhammad Hamza Khan. Remark: .	2026-07-09 10:16:55.992127+05
533	121	166	comment_added	\N	[CLOSED REMARK]: .	Closed remark added by Muhammad Hamza Khan	2026-07-09 10:16:55.993484+05
534	123	157	created	\N	open	Project Master created for department oversight	2026-07-09 15:33:58.587088+05
535	124	157	created	\N	open	Created by Muhammad Sufiyan as a sub-ticket of #123	2026-07-09 15:33:58.598565+05
536	123	157	sub_ticket_created	\N	124	Sub-ticket #124 created by Muhammad Sufiyan	2026-07-09 15:33:58.599176+05
537	107	170	comment_added	\N	please provide us charger Picture and spacification	Comment added by Mohsin Ahmed Chohan	2026-07-10 10:56:30.019809+05
538	118	404	assigned	Unassigned	Mohsin Ahmed Chohan	Manager Muhammad Fahim assigned the ticket.	2026-07-10 11:12:37.375563+05
539	118	404	status_changed	open	in_progress	Status changed due to assignment	2026-07-10 11:12:37.447199+05
540	125	170	created	\N	open	Project Master created for department oversight	2026-07-10 11:18:15.950372+05
541	126	170	created	\N	open	Created by Mohsin Ahmed Chohan as a sub-ticket of #125	2026-07-10 11:18:15.961558+05
542	125	170	sub_ticket_created	\N	126	Sub-ticket #126 created by Mohsin Ahmed Chohan	2026-07-10 11:18:15.962228+05
543	126	170	comment_added	\N	thanks work done	Comment added by Mohsin Ahmed Chohan	2026-07-10 14:11:08.714646+05
544	104	154	comment_added	\N	Any Update	Comment added by Muhammad Rasheed	2026-07-10 15:28:56.533214+05
545	127	123	created	\N	open	Project Master created for department oversight	2026-07-11 11:58:39.933918+05
546	128	123	created	\N	open	Created by Huraira Khan as a sub-ticket of #127	2026-07-11 11:58:39.986071+05
547	127	123	sub_ticket_created	\N	128	Sub-ticket #128 created by Huraira Khan	2026-07-11 11:58:39.987018+05
548	129	162	created	\N	open	Project Master created for department oversight	2026-07-11 12:58:58.321105+05
549	130	162	created	\N	open	Created by Faraz as a sub-ticket of #129	2026-07-11 12:58:58.347027+05
550	129	162	sub_ticket_created	\N	130	Sub-ticket #130 created by Faraz	2026-07-11 12:58:58.347611+05
551	130	167	assigned	Unassigned	Muhammad Yahya Ajmal	Self-assigned	2026-07-11 13:03:26.522076+05
552	130	167	status_changed	open	in_progress	Status changed via self-assignment	2026-07-11 13:03:26.523165+05
553	130	167	status_changed	in_progress	completed	Status updated to completed by Muhammad Yahya Ajmal. Remark: Task Completed	2026-07-11 13:03:40.371671+05
554	129	167	all_children_completed	\N	\N	All sub-tickets completed via #130	2026-07-11 13:03:40.373962+05
555	129	167	all_children_completed	\N	\N	All sub-tickets completed via #130	2026-07-11 13:03:40.375056+05
556	130	167	comment_added	\N	[COMPLETED REMARK]: Task Completed	Completed remark added by Muhammad Yahya Ajmal	2026-07-11 13:03:40.44468+05
557	130	167	status_changed	completed	closed	Status updated to closed by Muhammad Yahya Ajmal. Remark: Task Completed	2026-07-11 13:03:49.474987+05
558	130	167	comment_added	\N	[CLOSED REMARK]: Task Completed	Closed remark added by Muhammad Yahya Ajmal	2026-07-11 13:03:49.47654+05
559	129	162	status_changed	in_progress	completed	Status updated to completed by Faraz. Remark: Thanks	2026-07-11 13:04:51.37152+05
560	129	162	comment_added	\N	[COMPLETED REMARK]: Thanks	Completed remark added by Faraz	2026-07-11 13:04:51.373507+05
561	131	162	created	\N	open	Project Master created for department oversight	2026-07-11 13:05:41.863241+05
562	132	162	created	\N	open	Created by Faraz as a sub-ticket of #131	2026-07-11 13:05:41.874872+05
563	131	162	sub_ticket_created	\N	132	Sub-ticket #132 created by Faraz	2026-07-11 13:05:41.875487+05
564	132	165	assigned	Unassigned	Muhammad Fashi Ullah Khan	Self-assigned	2026-07-13 11:53:24.681092+05
565	132	165	status_changed	open	in_progress	Status changed via self-assignment	2026-07-13 11:53:24.728265+05
566	132	165	status_changed	in_progress	completed	Status updated to completed by Muhammad Fashi Ullah Khan. Remark: completed	2026-07-13 11:53:36.418413+05
567	131	165	all_children_completed	\N	\N	All sub-tickets completed via #132	2026-07-13 11:53:36.420122+05
568	131	165	all_children_completed	\N	\N	All sub-tickets completed via #132	2026-07-13 11:53:36.421122+05
569	132	165	comment_added	\N	[COMPLETED REMARK]: completed	Completed remark added by Muhammad Fashi Ullah Khan	2026-07-13 11:53:36.458153+05
570	132	165	status_changed	completed	closed	Status updated to closed by Muhammad Fashi Ullah Khan. Remark: Done	2026-07-13 11:53:46.639205+05
571	132	165	comment_added	\N	[CLOSED REMARK]: Done	Closed remark added by Muhammad Fashi Ullah Khan	2026-07-13 11:53:46.640421+05
572	116	157	status_changed	in_progress	completed	Status updated to completed by Muhammad Sufiyan. Remark: Thanks	2026-07-13 12:00:00.262358+05
573	116	157	comment_added	\N	[COMPLETED REMARK]: Thanks	Completed remark added by Muhammad Sufiyan	2026-07-13 12:00:00.264106+05
574	133	154	created	\N	open	Project Master created for department oversight	2026-07-13 16:33:41.921278+05
575	134	154	created	\N	open	Created by Muhammad Rasheed as a sub-ticket of #133	2026-07-13 16:33:41.933338+05
576	133	154	sub_ticket_created	\N	134	Sub-ticket #134 created by Muhammad Rasheed	2026-07-13 16:33:41.93396+05
577	135	154	created	\N	open	Project Master created for department oversight	2026-07-13 16:34:43.338002+05
578	136	154	created	\N	open	Created by Muhammad Rasheed as a sub-ticket of #135	2026-07-13 16:34:43.349434+05
579	135	154	sub_ticket_created	\N	136	Sub-ticket #136 created by Muhammad Rasheed	2026-07-13 16:34:43.350076+05
580	137	154	created	\N	open	Project Master created for department oversight	2026-07-13 16:35:49.592705+05
581	138	154	created	\N	open	Created by Muhammad Rasheed as a sub-ticket of #137	2026-07-13 16:35:49.604345+05
582	137	154	sub_ticket_created	\N	138	Sub-ticket #138 created by Muhammad Rasheed	2026-07-13 16:35:49.604937+05
583	128	404	assigned	Unassigned	Mohsin Ahmed Chohan	Manager Muhammad Fahim assigned the ticket.	2026-07-14 11:32:03.698727+05
584	128	404	status_changed	open	in_progress	Status changed due to assignment	2026-07-14 11:32:03.784979+05
585	105	404	comment_added	\N	All cards has been delivered	Comment added by Muhammad Fahim	2026-07-14 11:34:11.787329+05
586	125	170	comment_added	\N	job done kindly close task	Comment added by Mohsin Ahmed Chohan	2026-07-14 11:36:33.818222+05
587	53	170	status_changed	in_progress	completed	Status updated to completed by Mohsin Ahmed Chohan. Remark: I have completed all the required documentation from my side and forwarded it for payment processing. The documents are currently with the Treasury Department for the preparation of the pay order.	2026-07-14 12:49:29.034909+05
588	52	170	all_children_completed	\N	\N	All sub-tickets completed via #53	2026-07-14 12:49:29.036862+05
589	52	170	all_children_completed	\N	\N	All sub-tickets completed via #53	2026-07-14 12:49:29.037774+05
590	53	170	comment_added	\N	[COMPLETED REMARK]: I have completed all the required documentation from my side and forwarded it fo	Completed remark added by Mohsin Ahmed Chohan	2026-07-14 12:49:29.039193+05
591	53	170	status_changed	completed	closed	Status updated to closed by Mohsin Ahmed Chohan. Remark: I have completed all the required documentation from my side and forwarded it for payment processing. The documents are currently with the Treasury Department for the preparation of the pay order.	2026-07-14 12:49:57.049151+05
592	53	170	comment_added	\N	[CLOSED REMARK]: I have completed all the required documentation from my side and forwarded it for p	Closed remark added by Mohsin Ahmed Chohan	2026-07-14 12:49:57.050957+05
593	52	123	status_changed	in_progress	completed	Status updated to completed by Huraira Khan. Remark: .	2026-07-15 09:40:29.846203+05
594	52	123	comment_added	\N	[COMPLETED REMARK]: .	Completed remark added by Huraira Khan	2026-07-15 09:40:29.927828+05
595	139	123	created	\N	open	Project Master created for department oversight	2026-07-15 12:18:17.571125+05
596	140	123	created	\N	open	Created by Huraira Khan as a sub-ticket of #139	2026-07-15 12:18:17.582557+05
597	139	123	sub_ticket_created	\N	140	Sub-ticket #140 created by Huraira Khan	2026-07-15 12:18:17.583258+05
598	141	165	created	\N	open	Project Master created for department oversight	2026-07-15 12:29:31.994938+05
599	142	165	created	\N	open	Created by Muhammad Fashi Ullah Khan as a sub-ticket of #141	2026-07-15 12:29:32.009131+05
600	141	165	sub_ticket_created	\N	142	Sub-ticket #142 created by Muhammad Fashi Ullah Khan	2026-07-15 12:29:32.009788+05
601	143	165	created	\N	open	Project Master created for department oversight	2026-07-15 12:30:38.054523+05
602	144	165	created	\N	open	Created by Muhammad Fashi Ullah Khan as a sub-ticket of #143	2026-07-15 12:30:38.065464+05
603	143	165	sub_ticket_created	\N	144	Sub-ticket #144 created by Muhammad Fashi Ullah Khan	2026-07-15 12:30:38.06612+05
604	145	165	created	\N	open	Project Master created for department oversight	2026-07-15 12:32:51.026873+05
605	146	165	created	\N	open	Created by Muhammad Fashi Ullah Khan as a sub-ticket of #145	2026-07-15 12:32:51.038404+05
606	145	165	sub_ticket_created	\N	146	Sub-ticket #146 created by Muhammad Fashi Ullah Khan	2026-07-15 12:32:51.039079+05
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tickets (id, title, description, status, priority, created_by_id, created_by_dept, assigned_dept_id, assigned_to_id, transferred_from, transferred_at, closed_by_id, closed_at, reopened_at, reopen_count, due_date, is_sub_ticket, parent_ticket_id, ticket_type, overall_progress, created_at, updated_at, ticket_number, reset_token, is_standard_ticket, is_multi_ticket, closed_label) FROM stdin;
27	Zong Internet Devices	I have noted down the details for the four (04) new Zong Internet Devices as requested by Mr. Mohsin Akhlas.\nHere is the summary of the allocation for confirmation:\n1) Mr. Ahmed Sohaib - Karachi - Product Manager - Avico Group\n2) Mr. Nauman Haider Siddiqui - Karachi - Product Manager - Supportive Group\n3) Dr. Rizwan Ahmed - Lahore - Technical Manager - Common Group\n4) Dr. Zahid Ur Rehman - Peshawar - Sales Manager (KPK) - Common Group	in_progress	medium	65	66	79	168	\N	\N	\N	\N	\N	0	\N	t	26	standard	0	2026-06-29 13:59:05.645058+05	2026-06-29 16:37:15.386042+05	UMP-TKQ-014-SUB-001	\N	f	f	\N
28	Project: Procurement of Refurb System for Mr. Sohail Malik	Master oversight for: Please procure a refurb system for Mr. Sohail Malik (Feed) with below specs:\n\nDELL  Tower\nCorei5 10th gen\n32 gb ram\n128 gb ssd \n2 tb Hdd\nWith all cables	in_progress	medium	168	79	79	168	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-29 17:13:43.450689+05	2026-06-29 17:13:43.450689+05	UMP-TKQ-015	\N	f	f	\N
22	Project: Need Field Force List	Master oversight for: Kindly share field force list	completed	medium	66	67	67	66	\N	\N	66	2026-06-30 10:37:27.104223+05	\N	0	\N	f	\N	standard	0	2026-06-29 10:46:28.087832+05	2026-06-30 10:37:27.104223+05	UMP-TKQ-012	\N	f	f	\N
29	Procurement of Refurb System for Mr. Sohail Malik	Please procure a refurb system for Mr. Sohail Malik (Feed) with below specs:\n\nDELL  Tower\nCorei5 10th gen\n32 gb ram\n128 gb ssd \n2 tb Hdd\nWith all cables	in_progress	medium	168	79	81	170	\N	\N	\N	\N	\N	0	\N	t	28	standard	0	2026-06-29 17:13:43.529606+05	2026-06-30 10:47:26.679591+05	UMP-TKQ-015-SUB-001	\N	f	f	\N
84	Confidential Task by Directors	Cash related matters	completed	urgent	137	75	75	116	\N	\N	116	2026-07-03 11:31:41.598871+05	\N	0	\N	f	\N	standard	0	2026-07-03 11:29:47.606449+05	2026-07-03 11:31:41.598871+05	UMP-TKQ-047	\N	f	f	\N
14	Project: Implementation	Master oversight for: There is no need for  the originator to close the ticket. It should be automatically closed once it is resolved by the resolver.	in_progress	high	168	79	79	168	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-22 11:20:01.791294+05	2026-06-22 11:20:01.791294+05	UMP-TKQ-008	\N	f	f	\N
32	Project: Washroom Tiles - Warehouse Project (Green House)	Master oversight for: Required tiles for washrooms in warehouse at green house. PR provided.	in_progress	high	123	75	75	123	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-30 11:37:39.413107+05	2026-06-30 11:37:39.413107+05	UMP-TKQ-017	\N	f	f	\N
31	Aluminium Ladder - Height Adjustable Required	Required ladders for Green House & Head Office. PR revised -\nPR No. 626109057	closed	high	123	75	81	170	\N	\N	170	2026-07-03 12:12:58.793899+05	\N	0	\N	t	30	standard	0	2026-06-30 11:34:27.088805+05	2026-07-03 12:12:58.793899+05	UMP-TKQ-016-SUB-001	\N	f	f	\N
95	Development of changing area with lockers	Please develop a changing area with lockers for Green House workers and drivers.	in_progress	high	200	86	86	200	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-03 18:35:30.492529+05	2026-07-03 18:35:30.492529+05	UMP-TKQ-052	\N	f	f	\N
37	Comparison of Comercial Vehicles	Comparison of Old Commercial Vehicle Values and New Vehicle Rates	closed	urgent	137	75	75	113	\N	\N	137	2026-06-30 17:06:15.580998+05	\N	0	\N	f	\N	standard	0	2026-06-30 12:14:00.846651+05	2026-06-30 17:06:15.580998+05	UMP-TKQ-020	\N	f	f	\N
20	Project: Requesting approval of attendance 13-June	Master oversight for: Kindly approve my attendance of 13 June because the machine was malfunctioning in the morning	closed	high	163	79	79	163	\N	\N	163	2026-07-01 10:17:43.817017+05	\N	0	\N	f	\N	standard	0	2026-06-24 10:19:45.420109+05	2026-07-01 10:17:43.817017+05	UMP-TKQ-011	\N	f	f	\N
4	LCD Display Problem	LCD Display Problem	closed	high	156	77	79	165	\N	\N	165	2026-06-20 11:09:35.451679+05	\N	0	\N	t	3	standard	0	2026-06-20 11:04:44.238963+05	2026-06-20 11:09:35.451679+05	UMP-TKQ-002-SUB-001	\N	f	f	\N
9	Draft an experience letter for MR. QASIM	Share with him via email	closed	high	155	77	77	157	\N	\N	155	2026-06-20 12:34:56.278455+05	\N	0	\N	f	\N	standard	0	2026-06-20 12:29:25.793632+05	2026-06-20 12:34:56.278455+05	UMP-TKQ-005	\N	f	f	\N
12	Project: Request for shelf	Master oversight for: need extra shelf to keep clinical files	in_progress	medium	273	210	210	273	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-22 09:44:02.084906+05	2026-06-22 09:44:02.084906+05	UMP-TKQ-007	\N	f	f	\N
11	Team view	i wish to see my team reported to me if possible	closed	medium	299	214	79	163	\N	\N	163	2026-06-22 11:54:19.485335+05	\N	0	\N	t	10	standard	0	2026-06-20 15:33:04.740218+05	2026-06-22 11:54:19.485335+05	UMP-TKQ-006-SUB-001	\N	f	f	\N
10	Project: Team view	Master oversight for: i wish to see my team reported to me if possible	closed	medium	299	214	214	299	\N	\N	299	2026-06-22 11:55:07.809548+05	\N	0	\N	f	\N	standard	0	2026-06-20 15:33:04.722891+05	2026-06-22 11:55:07.809548+05	UMP-TKQ-006	\N	f	f	\N
16	Project: GMP shoes require	Master oversight for: GMP shoes for plant staff	in_progress	urgent	310	214	214	310	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-22 12:31:01.013383+05	2026-06-22 12:31:01.013383+05	UMP-TKQ-009	\N	f	f	\N
18	Project: insectecuter, AC not working	Master oversight for: 1- Insectecuter not working.\n2- Ac in Instrument room and Micro lab not working	in_progress	urgent	318	201	201	318	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-22 12:38:44.675787+05	2026-06-22 12:38:44.675787+05	UMP-TKQ-010	\N	f	f	\N
19	insectecuter, AC not working	1- Insectecuter not working.\n2- Ac in Instrument room and Micro lab not working	closed	urgent	318	201	75	123	\N	\N	123	2026-06-22 15:12:25.224302+05	\N	0	\N	t	18	standard	0	2026-06-22 12:38:44.687178+05	2026-06-22 15:12:25.224302+05	UMP-TKQ-010-SUB-001	\N	f	f	\N
17	GMP shoes require	GMP shoes for plant staff	in_progress	urgent	310	214	202	306	\N	\N	\N	\N	\N	0	\N	t	16	standard	0	2026-06-22 12:31:01.025768+05	2026-06-23 11:16:45.851433+05	UMP-TKQ-009-SUB-001	\N	f	f	\N
13	Request for shelf	need extra shelf to keep clinical files	in_progress	medium	273	210	202	306	\N	\N	\N	\N	\N	0	\N	t	12	standard	0	2026-06-22 09:44:02.117978+05	2026-06-23 11:16:53.835358+05	UMP-TKQ-007-SUB-001	\N	f	f	\N
3	Project: LCD Display Problem	Master oversight for: LCD Display Problem	closed	high	156	77	77	156	\N	\N	156	2026-06-23 11:59:25.505684+05	\N	0	\N	f	\N	standard	0	2026-06-20 11:04:44.225294+05	2026-06-23 11:59:25.505684+05	UMP-TKQ-002	\N	f	f	\N
25	Mouse required , UM-LA dept	mouse scroller not working , kindly get this https://www.czone.com.pk/a4tech-fg30s-fstyler-24g-wireless-mouse-24ghz-2000-dpi-silent-clicks-grey	closed	medium	223	90	79	368	\N	\N	368	2026-06-29 12:04:35.63046+05	\N	0	\N	t	24	standard	0	2026-06-29 11:24:18.243672+05	2026-06-29 12:04:35.63046+05	UMP-TKQ-013-SUB-001	\N	f	f	\N
24	Project: Mouse required , UM-LA dept	Master oversight for: mouse scroller not working , kindly get this https://www.czone.com.pk/a4tech-fg30s-fstyler-24g-wireless-mouse-24ghz-2000-dpi-silent-clicks-grey	closed	medium	223	90	90	223	\N	\N	223	2026-06-29 12:35:26.647722+05	\N	0	\N	f	\N	standard	0	2026-06-29 11:24:18.231355+05	2026-06-29 12:35:26.647722+05	UMP-TKQ-013	\N	f	f	\N
26	Project: Zong Internet Devices	Master oversight for: I have noted down the details for the four (04) new Zong Internet Devices as requested by Mr. Mohsin Akhlas.\nHere is the summary of the allocation for confirmation:\n1) Mr. Ahmed Sohaib - Karachi - Product Manager - Avico Group\n2) Mr. Nauman Haider Siddiqui - Karachi - Product Manager - Supportive Group\n3) Dr. Rizwan Ahmed - Lahore - Technical Manager - Common Group\n4) Dr. Zahid Ur Rehman - Peshawar - Sales Manager (KPK) - Common Group	in_progress	medium	65	66	66	65	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-29 13:59:05.633505+05	2026-06-29 13:59:05.633505+05	UMP-TKQ-014	\N	f	f	\N
15	Implementation	There is no need for  the originator to close the ticket. It should be automatically closed once it is resolved by the resolver.	in_progress	high	168	79	100	1	\N	\N	\N	\N	\N	0	\N	t	14	standard	0	2026-06-22 11:20:01.803378+05	2026-06-29 15:39:05.60908+05	UMP-TKQ-008-SUB-001	\N	f	f	\N
23	Need Field Force List	Kindly share field force list	closed	medium	66	67	66	65	\N	\N	65	2026-06-29 15:47:48.755162+05	\N	0	\N	t	22	standard	0	2026-06-29 10:46:28.215454+05	2026-06-29 15:47:48.755162+05	UMP-TKQ-012-SUB-001	\N	f	f	\N
34	Project: Filling Of LPG in new cylinder Gas for Green house	Master oversight for: A new 15 kg cylinder has been purchased for the Greenhouse. It currently requires approximately 10 kg of filling. Once the filling is completed, please let us know so that we can arrange its delivery to the Greenhouse.	in_progress	urgent	137	75	75	137	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-30 11:51:36.532141+05	2026-06-30 11:51:36.532141+05	UMP-TKQ-018	\N	f	f	\N
85	Fire Proof Cabinet	Require fire Proof Cabinet For LM	in_progress	urgent	137	75	75	123	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-03 15:05:02.180949+05	2026-07-03 15:05:02.180949+05	UMP-TKQ-048	\N	f	f	\N
91	Modification required on Feed & FM Store dock.	The Feed and FM Store dock ramp incline needs to modify, as the new stacker gets stuck while moving between the dock and the floor.	in_progress	high	200	86	86	200	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-03 18:12:22.908619+05	2026-07-03 18:12:22.908619+05	UMP-TKQ-050	\N	f	f	\N
38	Project: Improvement in Taskify (SPell Check)	Master oversight for: For improved usability and accuracy, it is recommended to incorporate a spell-check feature within the software's Title and Description fields. This functionality should automatically highlight misspelled words (e.g., with a red underline) while users are typing, enabling them to identify and correct errors in real time.	in_progress	medium	137	75	75	137	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-30 12:31:58.184704+05	2026-06-30 12:31:58.184704+05	UMP-TKQ-021	\N	f	f	\N
92	Modification required on Feed & FM Store dock.	The Feed and FM Store dock ramp incline needs to modify, as the new stacker gets stuck while moving between the dock and the floor.	open	high	200	86	75	\N	\N	\N	\N	\N	\N	0	\N	t	91	standard	0	2026-07-03 18:12:22.925811+05	2026-07-03 18:12:22.925811+05	UMP-TKQ-050-SUB-001	\N	f	f	\N
35	Filling Of LPG in new cylinder Gas for Green house	A new 15 kg cylinder has been purchased for the Greenhouse. It currently requires approximately 10 kg of filling. Once the filling is completed, please let us know so that we can arrange its delivery to the Greenhouse.	in_progress	urgent	137	75	81	170	\N	\N	\N	\N	\N	0	\N	t	34	standard	0	2026-06-30 11:51:36.609768+05	2026-06-30 14:29:24.21473+05	UMP-TKQ-018-SUB-001	\N	f	f	\N
96	Development of changing area with lockers	Please develop a changing area with lockers for Green House workers and drivers.	open	high	200	86	75	\N	\N	\N	\N	\N	\N	0	\N	t	95	standard	0	2026-07-03 18:35:30.550552+05	2026-07-03 18:35:30.550552+05	UMP-TKQ-052-SUB-001	\N	f	f	\N
36	Purchasing of Air Pump for HO Vehicles	An air pump is required for Head Office vehicles to address any tire-related emergencies. Once arranged, it will be kept available at the main gate for immediate use whenever needed.	closed	urgent	137	75	75	116	\N	\N	137	2026-06-30 14:54:30.091605+05	\N	0	\N	f	\N	standard	0	2026-06-30 12:08:27.332896+05	2026-06-30 14:54:30.091605+05	UMP-TKQ-019	\N	f	f	\N
39	Improvement in Taskify (SPell Check)	For improved usability and accuracy, it is recommended to incorporate a spell-check feature within the software's Title and Description fields. This functionality should automatically highlight misspelled words (e.g., with a red underline) while users are typing, enabling them to identify and correct errors in real time.	in_progress	medium	137	75	100	1	\N	\N	\N	\N	\N	0	\N	t	38	standard	0	2026-06-30 12:31:58.202905+05	2026-07-01 12:26:32.340695+05	UMP-TKQ-021-SUB-001	\N	f	f	\N
66	Cable Tray For Green House	Please make the comparison of cable tray at your earliest.	closed	high	137	75	75	138	\N	\N	137	2026-07-04 10:37:05.37252+05	\N	0	\N	f	\N	standard	0	2026-07-01 12:20:52.70902+05	2026-07-04 10:37:05.37252+05	UMP-TKQ-037	\N	f	f	\N
99	polythene bags required	mr fazal & ubaid kindly raise PR\npolythene bags required on urgent basis out of stock at wareshouse. size 20*30  and 24*26  200kg required each size.	open	urgent	243	94	89	\N	\N	\N	\N	\N	\N	0	\N	t	97	standard	0	2026-07-06 10:15:35.699328+05	2026-07-06 10:15:35.699328+05	UMP-TKQ-053-SUB-011	\N	f	f	\N
100	Printing& PDFIssue	we are facing this issue since one month, kindly resolve this matter ASAP.	in_progress	high	37	60	60	37	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-06 11:19:46.305876+05	2026-07-06 11:19:46.305876+05	UMP-TKQ-054	\N	f	f	\N
101	Printing& PDFIssue	we are facing this issue since one month, kindly resolve this matter ASAP.	open	high	37	60	220	\N	\N	\N	\N	\N	\N	0	\N	t	100	standard	0	2026-07-06 11:19:46.33218+05	2026-07-06 11:19:46.33218+05	UMP-TKQ-054-SUB-001	\N	f	f	\N
98	polythene bags required	MR Mohsin & Mr Farhan \nkindly arrenge polythene bags for lara wareshouse  its physical stock is nill... therefore its urgent required for packing material and dispatching.polythene bags required on urgent basis out of stock at wareshouse. size 20*30  and 24*26  200kg required each size.	in_progress	urgent	243	94	81	172	\N	\N	\N	\N	\N	0	\N	t	97	standard	0	2026-07-06 10:15:35.65679+05	2026-07-06 12:24:44.293664+05	UMP-TKQ-053-SUB-001	\N	f	f	\N
102	Required Table Mate	Required Table Mate For Mr. Farhan Sagheer - Head Of HR Department	in_progress	high	123	75	75	123	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-06 13:23:00.770767+05	2026-07-06 13:23:00.770767+05	UMP-TKQ-055	\N	f	f	\N
81	Required Hygrometers	Required Hygrometers for Feed & FMP Stores\nPR# 726109005	in_progress	high	123	75	81	170	\N	\N	\N	\N	\N	0	\N	t	80	standard	0	2026-07-03 10:04:00.200728+05	2026-07-07 09:48:33.53145+05	UMP-TKQ-045-SUB-001	\N	f	f	\N
103	Required Table Mate	Required Table Mate For Mr. Farhan Sagheer - Head Of HR Department	in_progress	high	123	75	81	170	\N	\N	\N	\N	\N	0	\N	t	102	standard	0	2026-07-06 13:23:00.782665+05	2026-07-07 09:48:44.527592+05	UMP-TKQ-055-SUB-001	\N	f	f	\N
104	Request for Design of Official Visiting Cards	10000925\tDr. Muhammad Asif Raza\n10000879\tMr. Muhammad Hammad Bashir\n10000936\tDr. Tehsin Ullah\n10000937\tMr. Farhan Arif\n10000927\tDr. Muhammad Saad Ullah\n10000916\tMuhammad Fahim\n10000434/919170\tMr. Kashif Hussain\n10000917\tShahzaib Shakeel	in_progress	urgent	154	77	77	154	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-07 11:39:29.34768+05	2026-07-07 11:39:29.34768+05	UMP-TKQ-056	\N	f	f	\N
106	Requirement for Laptop Chargers for Mr. Aleem Shah and Mr. Hassan Adil	Please procure 2 original laptop chargers for Mr. Aleem Shah(Indenting) and Mr. Hassan Adil(Diagnostics).. We need them on urgent basis as current chargers are working properly..\n\nHP Probook 460 G11\nCU 5 125U	in_progress	urgent	168	79	79	168	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-07 13:37:52.122226+05	2026-07-07 13:37:52.122226+05	UMP-TKQ-057	\N	f	f	\N
108	Request for mouse pad	Need a mouse pad at FM Poultry SMD.	in_progress	high	89	70	70	89	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-08 11:21:56.759424+05	2026-07-08 11:21:56.759424+05	UMP-TKQ-058	\N	f	f	\N
109	Request for mouse pad	Need a mouse pad at FM Poultry SMD.	open	high	89	70	79	\N	\N	\N	\N	\N	\N	0	\N	t	108	standard	0	2026-07-08 11:21:56.858593+05	2026-07-08 11:21:56.858593+05	UMP-TKQ-058-SUB-001	\N	f	f	\N
110	request for a new  mouse pad	kinldy issue me a new  mouse pad	in_progress	urgent	400	67	67	400	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-08 11:22:31.519764+05	2026-07-08 11:22:31.519764+05	UMP-TKQ-059	\N	f	f	\N
107	Requirement for Laptop Chargers for Mr. Aleem Shah and Mr. Hassan Adil	Please procure 2 original laptop chargers for Mr. Aleem Shah(Indenting) and Mr. Hassan Adil(Diagnostics).. We need them on urgent basis as current chargers are working properly..\n\nHP Probook 460 G11\nCU 5 125U	in_progress	urgent	168	79	81	170	\N	\N	\N	\N	\N	0	\N	t	106	standard	0	2026-07-07 13:37:52.134849+05	2026-07-08 12:09:58.614531+05	UMP-TKQ-057-SUB-001	\N	f	f	\N
111	request for a new  mouse pad	kinldy issue me a new  mouse pad	in_progress	urgent	400	67	79	165	\N	\N	\N	\N	\N	0	\N	t	110	standard	0	2026-07-08 11:22:31.530677+05	2026-07-08 15:08:35.050634+05	UMP-TKQ-059-SUB-001	\N	f	f	\N
118	Sub: request for a new  mouse pad	Please arrange mouse pad for stock	in_progress	urgent	165	79	81	170	\N	\N	\N	\N	\N	0	\N	t	111	standard	0	2026-07-08 15:10:48.810246+05	2026-07-10 11:12:37.324972+05	UMP-TKQ-059-SUB-001-SUB-001	\N	f	f	\N
116	Printer Issue	The printer is malfunctioning, please help to rectify it.	completed	urgent	157	77	77	157	\N	\N	157	2026-07-13 12:00:00.251059+05	\N	0	\N	f	\N	standard	0	2026-07-08 14:05:23.07895+05	2026-07-13 12:00:00.251059+05	UMP-TKQ-062	\N	f	f	\N
63	Envelopes for faisalabad office	send half A4 & A4 sizes envelopes to faisalabad office on the name of naveed. each sizes 200 qty.	in_progress	high	113	75	86	201	\N	\N	\N	\N	\N	0	\N	t	62	standard	0	2026-07-01 11:59:02.286036+05	2026-07-03 17:12:54.178252+05	UMP-TKQ-034-SUB-001	\N	f	f	\N
93	SAP Print & PDF issue	We have been facing a printing & PDF issue since 27th of june. Kindly resolve it ASAP.	in_progress	urgent	34	60	60	34	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-03 18:14:05.174732+05	2026-07-03 18:14:05.174732+05	UMP-TKQ-051	\N	f	f	\N
42	Printer Issue	The printer is malfunctioning, please help to rectify i.	closed	urgent	157	77	79	368	\N	\N	368	2026-06-30 12:43:17.112705+05	\N	0	\N	t	41	standard	0	2026-06-30 12:37:15.693153+05	2026-06-30 12:43:17.112705+05	UMP-TKQ-023-SUB-001	\N	f	f	\N
86	Sub: Fire Proof Cabinet	PR# 726109008 provided.	in_progress	urgent	123	75	81	172	\N	\N	\N	\N	\N	0	\N	t	85	standard	0	2026-07-03 15:10:09.685075+05	2026-07-07 09:48:22.779947+05	UMP-TKQ-048-SUB-001	\N	f	f	\N
43	Project: Required Net 200 running ft.	Master oversight for: Net for our chicks trial shed Matrix plot.\n200 running ft wdth 6 ft.	in_progress	high	193	84	84	193	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-30 12:56:56.152349+05	2026-06-30 12:56:56.152349+05	UMP-TKQ-024	\N	f	f	\N
49	Required Vaccum Pump - Head Office	Vaccum Pump Required For Head Office\nPR# 326109032	in_progress	high	123	75	81	170	\N	\N	\N	\N	\N	0	\N	t	48	standard	0	2026-06-30 14:53:24.17663+05	2026-07-07 09:49:21.0814+05	UMP-TKQ-026-SUB-001	\N	f	f	\N
47	Requirement For Trial Shed - Memon Goth - GRP. 53	Required Cement Sheets\nPR # 626109074	in_progress	high	123	75	81	170	\N	\N	\N	\N	\N	0	\N	t	46	standard	0	2026-06-30 14:37:01.116775+05	2026-07-07 09:49:34.926367+05	UMP-TKQ-025-SUB-001	\N	f	f	\N
44	Required Net 200 running ft.	Net for our chicks trial shed Matrix plot.\n200 running ft wdth 6 ft.	in_progress	high	193	84	75	123	\N	\N	\N	\N	\N	0	\N	t	43	standard	0	2026-06-30 12:56:56.178204+05	2026-06-30 12:58:28.776944+05	UMP-TKQ-024-SUB-001	\N	f	f	\N
41	Project: Printer Issue	Master oversight for: The printer is malfunctioning, please help to rectify i.	closed	urgent	157	77	77	157	\N	\N	157	2026-06-30 12:58:51.885517+05	\N	0	\N	f	\N	standard	0	2026-06-30 12:37:15.68167+05	2026-06-30 12:58:51.885517+05	UMP-TKQ-023	\N	f	f	\N
33	Washroom Tiles - Warehouse Project (Green House)	Required tiles for washrooms in warehouse at green house. PR provided.	in_progress	high	123	75	81	170	\N	\N	\N	\N	\N	0	\N	t	32	standard	0	2026-06-30 11:37:39.424402+05	2026-06-30 14:21:33.596795+05	UMP-TKQ-017-SUB-001	\N	f	f	\N
40	P.R For three Fans AC/DC Fan	Please raise P.R for three AC/DC fan for Memon GOth trial Shed GRP-53	closed	high	137	75	75	138	\N	\N	137	2026-06-30 14:25:29.229126+05	\N	0	\N	f	\N	standard	0	2026-06-30 12:37:08.126965+05	2026-06-30 14:25:29.229126+05	UMP-TKQ-022	\N	f	f	\N
46	Project: Requirement For Trial Shed - Memon Goth - GRP. 53	Master oversight for: Required Cement Sheets\nPR # 626109074	in_progress	high	123	75	75	123	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-30 14:37:01.105518+05	2026-06-30 14:37:01.105518+05	UMP-TKQ-025	\N	f	f	\N
48	Project: Required Vaccum Pump - Head Office	Master oversight for: Vaccum Pump Required For Head Office\nPR# 326109032	in_progress	high	123	75	75	123	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-30 14:53:24.164466+05	2026-06-30 14:53:24.164466+05	UMP-TKQ-026	\N	f	f	\N
50	Project: Material Shifting From Green House to Dhabaeji Land Gate - 1	Master oversight for: Dear Sarfaraz Sb,\n\nAs discussed, some guarders are currently placed at the greenhouse and need to be shifted to the Dhabeji land using a Shehzore truck.\n\nThis is an urgent task. Please arrange to transport all the guarders to the Dhabeji land as soon as possible.\n\nThank you for your prompt attention to this matter.\n\nRegards,\nQamar Khan	in_progress	urgent	35	60	60	35	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-30 15:31:46.382436+05	2026-06-30 15:31:46.382436+05	UMP-TKQ-027	\N	f	f	\N
51	Material Shifting From Green House to Dhabaeji Land Gate - 1	Dear Sarfaraz Sb,\n\nAs discussed, some guarders are currently placed at the greenhouse and need to be shifted to the Dhabeji land using a Shehzore truck.\n\nThis is an urgent task. Please arrange to transport all the guarders to the Dhabeji land as soon as possible.\n\nThank you for your prompt attention to this matter.\n\nRegards,\nQamar Khan	open	urgent	35	60	62	\N	\N	\N	\N	\N	\N	0	\N	t	50	standard	0	2026-06-30 15:31:46.394066+05	2026-06-30 15:31:46.394066+05	UMP-TKQ-027-SUB-001	\N	f	f	\N
45	Sub: Required Net 200 running ft.	Required Mosquito Net & Binding Wire For Trial Shed At Matrix Plot - GRP. 47 \nPR # 626109073	in_progress	high	123	75	81	170	\N	\N	\N	\N	\N	0	\N	t	44	standard	0	2026-06-30 14:32:08.754602+05	2026-07-07 09:49:41.109556+05	UMP-TKQ-024-SUB-001-SUB-001	\N	f	f	\N
53	Sub: Rasie P.R for comercial Vehicles Top Most Urgent	Commercial Vehicles PR# 626109075	closed	urgent	123	75	81	170	\N	\N	170	2026-07-14 12:49:57.038984+05	\N	0	\N	t	52	standard	0	2026-06-30 16:19:17.55606+05	2026-07-14 12:49:57.038984+05	UMP-TKQ-028-SUB-001	\N	f	f	\N
52	Rasie P.R for comercial Vehicles Top Most Urgent	Two Ravi and One E-Suzu	completed	urgent	137	75	75	123	\N	\N	123	2026-07-15 09:40:29.740359+05	\N	0	\N	f	\N	standard	0	2026-06-30 16:16:35.945853+05	2026-07-15 09:40:29.740359+05	UMP-TKQ-028	\N	f	f	\N
55	Director Vehicle Starting Issue	Battery down and Puncture	closed	high	137	75	75	116	\N	\N	137	2026-06-30 17:54:24.216191+05	\N	0	\N	f	\N	standard	0	2026-06-30 17:52:31.387348+05	2026-06-30 17:54:24.216191+05	UMP-TKQ-030	\N	f	f	\N
21	Requesting approval of attendance 13-June	Kindly approve my attendance of 13 June because the machine was malfunctioning in the morning	closed	high	163	79	77	156	\N	\N	156	2026-07-01 10:17:04.856745+05	\N	0	\N	t	20	standard	0	2026-06-24 10:19:45.494063+05	2026-07-01 10:17:04.856745+05	UMP-TKQ-011-SUB-001	\N	f	f	\N
57	Printer Not Working	Printer Not Working	closed	high	156	77	79	165	\N	\N	165	2026-07-01 10:18:34.049138+05	\N	0	\N	t	56	standard	0	2026-07-01 10:08:03.329648+05	2026-07-01 10:18:34.049138+05	UMP-TKQ-031-SUB-001	\N	f	f	\N
56	Printer Not Working	Printer Not Working	closed	high	156	77	77	156	\N	\N	156	2026-07-01 10:18:55.436503+05	\N	0	\N	f	\N	standard	0	2026-07-01 10:08:03.278306+05	2026-07-01 10:18:55.436503+05	UMP-TKQ-031	\N	f	f	\N
54	ac temperature	Dear huraria please maintain the ac temperature 22 ciencias.	closed	urgent	138	75	75	123	\N	\N	138	2026-07-01 10:48:53.465499+05	\N	0	\N	f	\N	standard	0	2026-06-30 16:33:47.098889+05	2026-07-01 10:48:53.465499+05	UMP-TKQ-029	\N	f	f	\N
60	Arrange Lunch for stock count team for 01.007.2026	Arrange Lunch for stock count team fro 72 persons	in_progress	urgent	101	74	74	101	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-01 11:40:08.45229+05	2026-07-01 11:40:08.45229+05	UMP-TKQ-033	\N	f	f	\N
61	Arrange Lunch for stock count team for 01.007.2026	Arrange Lunch for stock count team fro 72 persons	closed	urgent	101	74	75	123	\N	\N	123	2026-07-01 11:53:48.200127+05	\N	0	\N	t	60	standard	0	2026-07-01 11:40:08.463754+05	2026-07-01 11:53:48.200127+05	UMP-TKQ-033-SUB-001	\N	f	f	\N
62	Envelopes for faisalabad office	send half A4 & A4 sizes envelopes to faisalabad office on the name of naveed. each sizes 200 qty.	in_progress	high	113	75	75	113	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-01 11:59:02.275856+05	2026-07-01 11:59:02.275856+05	UMP-TKQ-034	\N	f	f	\N
58	Lunch Arrangements (Stock Count Activity)	76 persons	completed	medium	137	75	75	123	\N	\N	123	2026-07-01 12:57:16.502676+05	\N	0	\N	f	\N	standard	0	2026-07-01 11:24:06.270062+05	2026-07-01 12:57:16.502676+05	UMP-TKQ-032	\N	f	f	\N
64	Settlement of Imprest Account	Please settle the amount incurred for guest-related expenses, as this activity was assigned to you by the Management.	completed	high	137	75	75	116	\N	\N	116	2026-07-01 16:15:33.132027+05	\N	0	\N	f	\N	standard	0	2026-07-01 12:15:26.600355+05	2026-07-01 16:15:33.132027+05	UMP-TKQ-035	\N	f	f	\N
67	Comercial Vehicles Survey	All Comercial vehicles and other vehicles survey for the quotations	closed	high	137	75	75	116	\N	\N	137	2026-07-01 17:04:08.561782+05	\N	0	\N	f	\N	standard	0	2026-07-01 15:48:36.732019+05	2026-07-01 17:04:08.561782+05	UMP-TKQ-038	\N	f	f	\N
59	Sub: Filling Of LPG in new cylinder Gas for Green house	need driver support for arranging gas	in_progress	urgent	170	81	75	137	\N	\N	\N	\N	\N	0	\N	t	35	standard	0	2026-07-01 11:36:21.772579+05	2026-07-02 10:18:33.820243+05	UMP-TKQ-018-SUB-001-SUB-001	\N	f	f	\N
70	Suggestion: Direct Navigation from Notifications	Dear Team,\nI would like to suggest an enhancement to the notification system.\nSimilar to Facebook, when a user clicks on a notification, it should automatically open the specific page or task related to that notification. This would allow users to view the relevant information immediately without any additional steps.\n\nCurrently, after receiving a notification, we have to manually search for the ticket number and then open the corresponding task to check the update. This process is time-consuming and reduces efficiency.\nImplementing direct navigation from notifications to the relevant task or ticket would significantly improve the user experience and save valuable time.\nThank you for considering this enhancement.	in_progress	high	123	75	75	123	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-01 16:42:33.004469+05	2026-07-01 16:42:33.004469+05	UMP-TKQ-040	\N	f	f	\N
71	Suggestion: Direct Navigation from Notifications	Dear Team,\nI would like to suggest an enhancement to the notification system.\nSimilar to Facebook, when a user clicks on a notification, it should automatically open the specific page or task related to that notification. This would allow users to view the relevant information immediately without any additional steps.\n\nCurrently, after receiving a notification, we have to manually search for the ticket number and then open the corresponding task to check the update. This process is time-consuming and reduces efficiency.\nImplementing direct navigation from notifications to the relevant task or ticket would significantly improve the user experience and save valuable time.\nThank you for considering this enhancement.	open	high	123	75	100	\N	\N	\N	\N	\N	\N	0	\N	t	70	standard	0	2026-07-01 16:42:33.01611+05	2026-07-01 16:42:33.01611+05	UMP-TKQ-040-SUB-001	\N	f	f	\N
65	Raise P.R of Machine procure for LA-RFA (Production)	Please generate and inform to Procurement for further process	closed	urgent	137	75	75	123	\N	\N	137	2026-07-01 17:03:57.776175+05	\N	0	\N	f	\N	standard	0	2026-07-01 12:18:06.001074+05	2026-07-01 17:03:57.776175+05	UMP-TKQ-036	\N	f	f	\N
82	Testing Live Commnet	Checking Huraira {10000306}	closed	urgent	1	100	100	1	\N	\N	1	2026-07-03 11:02:04.350606+05	\N	0	\N	f	\N	standard	0	2026-07-03 10:57:48.920518+05	2026-07-03 11:02:04.350606+05	UMP-TKQ-046	\N	f	f	\N
78	Open vendor	please open vendor in ERP ASAP	closed	urgent	170	81	81	170	\N	\N	170	2026-07-03 11:48:38.236163+05	\N	0	\N	f	\N	standard	0	2026-07-02 16:56:16.78048+05	2026-07-03 11:48:38.236163+05	UMP-TKQ-044	\N	f	f	\N
72	Send Bike File GD 110 to FSD Office...	Send Original file to naveed faisalabad office GD-110...	closed	high	116	75	75	116	\N	\N	116	2026-07-01 18:02:56.878959+05	\N	0	\N	f	\N	standard	0	2026-07-01 17:59:21.998644+05	2026-07-01 18:02:56.878959+05	UMP-TKQ-041	\N	f	f	\N
73	Sub: Sub: Filling Of LPG in new cylinder Gas for Green house	Need Driver Assistance	open	urgent	137	75	62	\N	\N	\N	\N	\N	\N	0	\N	t	59	standard	0	2026-07-02 10:19:57.42943+05	2026-07-02 10:19:57.42943+05	UMP-TKQ-018-SUB-001-SUB-001-SUB-001	\N	f	f	\N
87	Arrangements & SAP DFF	Sr\tEmp ID\tName Asper CNIC\tDesignation\tBase Area\tDepartment & Division\tDOJ\tAdministration (01)\tIT\tReplacement\tAdministration (D.O.B)(02)\tAdministration (CNIC)(03)\tAdministration (D.O.I)(04)\n1\t10000944\tAli Raza Sahito\tSenior Sales Promotion Officer\tKarachi\tSales - LBFM\t1/7/2026\tCar (Alto  ),Sim ,& Fuel Card (100 L) \tEmail\tFaraz Hussain Khaskhali(10000795)\t02/May/2001\t45301-3520440-7\t18-10-2024\n\nEMP  Code\tFull Name\tEMP  Code\tFull Name\t \tDIV\tDEPARTMENTS\tDEPARTMENTS\n10000944\tAli Raza Sahito\t10000944\tAli Raza Sahito\t \tLBFM\t104	in_progress	medium	154	77	77	154	\N	\N	\N	\N	\N	0	\N	f	\N	multi_task	0	2026-07-03 17:15:37.101874+05	2026-07-03 17:15:37.101874+05	UMP-TKQ-049	\N	f	f	\N
89	Arrangements	Car (Alto  ),Sim ,& Fuel Card (100 L)	open	medium	154	77	75	\N	\N	\N	\N	\N	\N	0	\N	t	87	standard	0	2026-07-03 17:15:37.156336+05	2026-07-03 17:15:37.156336+05	UMP-TKQ-049-SUB-011	\N	f	f	\N
90	DFF	EMP  Code\tFull Name\tEMP  Code\tFull Name\t \tDIV\tDEPARTMENTS\tDEPARTMENTS\n10000944\tAli Raza Sahito\t10000944\tAli Raza Sahito\t \tLBFM\t104	open	medium	154	77	220	\N	\N	\N	\N	\N	\N	0	\N	t	87	standard	0	2026-07-03 17:15:37.170811+05	2026-07-03 17:15:37.170811+05	UMP-TKQ-049-SUB-021	\N	f	f	\N
75	sap print issue and pdf issue	There is an issue with printing, and the same issue is occurring with the PDF as well.	closed	high	36	60	79	165	\N	\N	165	2026-07-02 15:50:33.120973+05	\N	0	\N	t	74	standard	0	2026-07-02 14:48:27.473489+05	2026-07-02 15:50:33.120973+05	UMP-TKQ-042-SUB-001	\N	f	f	\N
74	sap print issue and pdf issue	There is an issue with printing, and the same issue is occurring with the PDF as well.	closed	high	36	60	60	36	\N	\N	36	2026-07-02 15:50:49.892764+05	\N	0	\N	f	\N	standard	0	2026-07-02 14:48:27.461737+05	2026-07-02 15:50:49.892764+05	UMP-TKQ-042	\N	f	f	\N
76	SAP Login Issue – User Already Connected	Kindly check SAP ID smd026.\n\nWhen I attempt to log in, the system shows that another user ("Owais Najam") is already connected using this SAP ID. As a result, I am unable to log in.\n\nKindly terminate the active session (if appropriate) and restore my access.	in_progress	urgent	32	58	58	32	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-02 16:42:30.773044+05	2026-07-02 16:42:30.773044+05	UMP-TKQ-043	\N	f	f	\N
77	SAP Login Issue – User Already Connected	Kindly check SAP ID smd026.\n\nWhen I attempt to log in, the system shows that another user ("Owais Najam") is already connected using this SAP ID. As a result, I am unable to log in.\n\nKindly terminate the active session (if appropriate) and restore my access.	open	urgent	32	58	220	\N	\N	\N	\N	\N	\N	0	\N	t	76	standard	0	2026-07-02 16:42:30.784765+05	2026-07-02 16:42:30.784765+05	UMP-TKQ-043-SUB-001	\N	f	f	\N
94	SAP Print & PDF issue	We have been facing a printing & PDF issue since 27th of june. Kindly resolve it ASAP.	in_progress	urgent	34	60	220	164	\N	\N	\N	\N	\N	0	\N	t	93	standard	0	2026-07-03 18:14:05.192433+05	2026-07-04 09:43:18.246727+05	UMP-TKQ-051-SUB-001	\N	f	f	\N
79	Open vendor	please open vendor in ERP ASAP	closed	urgent	170	81	220	166	\N	\N	166	2026-07-02 16:59:07.208518+05	\N	0	\N	t	78	standard	0	2026-07-02 16:56:16.792294+05	2026-07-02 16:59:07.208518+05	UMP-TKQ-044-SUB-001	\N	f	f	\N
88	Arrangements	Email	completed	medium	154	77	79	168	\N	\N	168	2026-07-04 09:57:11.537397+05	\N	0	\N	t	87	standard	0	2026-07-03 17:15:37.137836+05	2026-07-04 09:57:11.537397+05	UMP-TKQ-049-SUB-001	\N	f	f	\N
30	Project: Aluminium Ladder - Height Adjustable Required	Master oversight for: Required ladders for Green House & Head Office. PR revised -\nPR No. 626109057	closed	high	123	75	75	123	\N	\N	123	2026-07-04 10:28:57.367411+05	\N	0	\N	f	\N	standard	0	2026-06-30 11:34:27.077001+05	2026-07-04 10:28:57.367411+05	UMP-TKQ-016	\N	f	f	\N
69	Bug	Hello Team,\n\nThe search option has not been functioning properly recently. Could you please look into this issue and investigate it at your earliest convenience?\n\nThank you.	closed	high	123	75	100	1	\N	\N	1	2026-07-02 18:04:14.905979+05	\N	0	\N	t	68	standard	0	2026-07-01 16:37:52.180595+05	2026-07-02 18:04:14.905979+05	UMP-TKQ-039-SUB-001	\N	f	f	\N
80	Required Hygrometers	Required Hygrometers for Feed & FMP Stores\nPR# 726109005	in_progress	high	123	75	75	123	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-03 10:04:00.114883+05	2026-07-03 10:04:00.114883+05	UMP-TKQ-045	\N	f	f	\N
97	Required polythene bags	polythene bags required on urgent basis out of stock at wareshouse. size 20*30  and 24*26  200kg required each size.	in_progress	urgent	243	94	94	243	\N	\N	\N	\N	\N	0	\N	f	\N	multi_task	0	2026-07-06 10:15:35.517545+05	2026-07-06 10:15:35.517545+05	UMP-TKQ-053	\N	f	f	\N
68	Bug	Hello Team,\n\nThe search option has not been functioning properly recently. Could you please look into this issue and investigate it at your earliest convenience?\n\nThank you.	closed	high	123	75	75	123	\N	\N	123	2026-07-03 10:55:47.971801+05	\N	0	\N	f	\N	standard	0	2026-07-01 16:37:52.168693+05	2026-07-03 10:55:47.971801+05	UMP-TKQ-039	\N	f	f	\N
83	Testing Live Commnet	Checking Huraira {10000306}	closed	urgent	1	100	75	123	\N	\N	123	2026-07-03 11:01:41.128856+05	\N	0	\N	t	82	standard	0	2026-07-03 10:57:48.932141+05	2026-07-03 11:01:41.128856+05	UMP-TKQ-046-SUB-001	\N	f	f	\N
112	SAP ID (View Only)	We are required to arrange two new SAP ID's (view only) for our team members\nMr. Noshan Gul \nMr. Hassan Ahmed Farqui\nfor view report like stock, party ledger, debtor summary, etc	in_progress	high	71	67	67	71	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-08 11:36:52.793129+05	2026-07-08 11:36:52.793129+05	UMP-TKQ-060	\N	f	f	\N
113	SAP ID (View Only)	We are required to arrange two new SAP ID's (view only) for our team members\nMr. Noshan Gul \nMr. Hassan Ahmed Farqui\nfor view report like stock, party ledger, debtor summary, etc	open	high	71	67	220	\N	\N	\N	\N	\N	\N	0	\N	t	112	standard	0	2026-07-08 11:36:52.805301+05	2026-07-08 11:36:52.805301+05	UMP-TKQ-060-SUB-001	\N	f	f	\N
114	Additional Extension Required	Dear Admin Team,\n\nSince moving to the new floor, our team of seventeen has been sharing three telephone extensions (251"5", 252"7", 275"5"). This is significantly impacting our daily workflow and communication within the company.\n\nPlease let us know when we can expect new extension to be installed to resolve this issue. We appreciate your prompt attention to this matter.\n\nRegards,	in_progress	high	71	67	67	71	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-08 11:53:51.843847+05	2026-07-08 11:53:51.843847+05	UMP-TKQ-061	\N	f	f	\N
115	Additional Extension Required	Dear Admin Team,\n\nSince moving to the new floor, our team of seventeen has been sharing three telephone extensions (251"5", 252"7", 275"5"). This is significantly impacting our daily workflow and communication within the company.\n\nPlease let us know when we can expect new extension to be installed to resolve this issue. We appreciate your prompt attention to this matter.\n\nRegards,	open	high	71	67	75	\N	\N	\N	\N	\N	\N	0	\N	t	114	standard	0	2026-07-08 11:53:51.887169+05	2026-07-08 11:53:51.887169+05	UMP-TKQ-061-SUB-001	\N	f	f	\N
105	Request for Design of Official Visiting Cards	10000925\tDr. Muhammad Asif Raza\n10000879\tMr. Muhammad Hammad Bashir\n10000936\tDr. Tehsin Ullah\n10000937\tMr. Farhan Arif\n10000927\tDr. Muhammad Saad Ullah\n10000916\tMuhammad Fahim\n10000434/919170\tMr. Kashif Hussain\n10000917\tShahzaib Shakeel	in_progress	urgent	154	77	81	172	\N	\N	\N	\N	\N	0	\N	t	104	standard	0	2026-07-07 11:39:29.364403+05	2026-07-08 12:09:50.464101+05	UMP-TKQ-056-SUB-001	\N	f	f	\N
119	Arrangements & SAP DFF	Sr\tEmp ID\tName Asper CNIC\tDesignation\tBase Area\tDepartment & Division\tDOJ\tAdministration (01)\tIT\tReplacement\tAdministration (D.O.B)(02)\tAdministration (CNIC)(03)\tAdministration (D.O.I)(04)\n1\t10000945\tNadeem Ahmed\tSenior Sales Promotion Officer\tSukkur\tSales - LBFM\t1/7/2026\tCar (Alto  ),Sim ,& Fuel Card (100 L) \tEmail\t Abdul Salam(10000823)\t14-09-1994\t43303-7546408-5\t27-11-2017\n\nEMP  Code\tFull Name\tEMP  Code\tFull Name\t \tDIV\tDEPARTMENTS\tDEPARTMENTS\n10000945\tNadeem Ahmed\t10000945\tNadeem Ahmed\t \tLBFM\t104	in_progress	high	154	77	77	154	\N	\N	\N	\N	\N	0	\N	f	\N	multi_task	0	2026-07-08 16:27:35.385958+05	2026-07-08 16:27:35.385958+05	UMP-TKQ-063	\N	f	f	\N
120	Arrangements	Sr\tEmp ID\tName Asper CNIC\tDesignation\tBase Area\tDepartment & Division\tDOJ\tAdministration (01)\tIT\tReplacement\tAdministration (D.O.B)(02)\tAdministration (CNIC)(03)\tAdministration (D.O.I)(04)\n1\t10000945\tNadeem Ahmed\tSenior Sales Promotion Officer\tSukkur\tSales - LBFM\t1/7/2026\tCar (Alto  ),Sim ,& Fuel Card (100 L) \tEmail\t Abdul Salam(10000823)\t14-09-1994\t43303-7546408-5\t27-11-2017	open	high	154	77	75	\N	\N	\N	\N	\N	\N	0	\N	t	119	standard	0	2026-07-08 16:27:35.412813+05	2026-07-08 16:27:35.412813+05	UMP-TKQ-063-SUB-001	\N	f	f	\N
122	Arrangements Email ID	Sr\tEmp ID\tName Asper CNIC\tDesignation\tBase Area\tDepartment & Division\tDOJ\tAdministration (01)\tIT\tReplacement\tAdministration (D.O.B)(02)\tAdministration (CNIC)(03)\tAdministration (D.O.I)(04)\n1\t10000945\tNadeem Ahmed\tSenior Sales Promotion Officer\tSukkur\tSales - LBFM\t1/7/2026\tCar (Alto  ),Sim ,& Fuel Card (100 L) \tEmail\t Abdul Salam(10000823)\t14-09-1994\t43303-7546408-5\t27-11-2017	open	high	154	77	79	\N	\N	\N	\N	\N	\N	0	\N	t	119	standard	0	2026-07-08 16:27:35.44208+05	2026-07-08 16:27:35.44208+05	UMP-TKQ-063-SUB-021	\N	f	f	\N
117	Printer Issue	The printer is malfunctioning, please help to rectify it.	closed	urgent	157	77	79	167	\N	\N	167	2026-07-09 10:15:11.896875+05	\N	0	\N	t	116	standard	0	2026-07-08 14:05:23.091473+05	2026-07-09 10:15:11.896875+05	UMP-TKQ-062-SUB-001	\N	f	f	\N
121	SAP DFF	EMP  Code\tFull Name\tEMP  Code\tFull Name\t \tDIV\tDEPARTMENTS\tDEPARTMENTS\n10000945\tNadeem Ahmed\t10000945\tNadeem Ahmed\t \tLBFM\t104	closed	high	154	77	220	166	\N	\N	166	2026-07-09 10:16:55.982437+05	\N	0	\N	t	119	standard	0	2026-07-08 16:27:35.427412+05	2026-07-09 10:16:55.982437+05	UMP-TKQ-063-SUB-011	\N	f	f	\N
123	Report Print Issue SAP	Please help to print reports from SAP	in_progress	urgent	157	77	77	157	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-09 15:33:58.559411+05	2026-07-09 15:33:58.559411+05	UMP-TKQ-064	\N	f	f	\N
124	Report Print Issue SAP	Please help to print reports from SAP	open	urgent	157	77	220	\N	\N	\N	\N	\N	\N	0	\N	t	123	standard	0	2026-07-09 15:33:58.588801+05	2026-07-09 15:33:58.588801+05	UMP-TKQ-064-SUB-001	\N	f	f	\N
125	Open Vendor	Please Open Vendor in ERP	in_progress	urgent	170	81	81	170	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-10 11:18:15.927047+05	2026-07-10 11:18:15.927047+05	UMP-TKQ-065	\N	f	f	\N
126	Open Vendor	Please Open Vendor in ERP	open	urgent	170	81	220	\N	\N	\N	\N	\N	\N	0	\N	t	125	standard	0	2026-07-10 11:18:15.952015+05	2026-07-10 11:18:15.952015+05	UMP-TKQ-065-SUB-001	\N	f	f	\N
127	Refilling Of Gas Cylinder	Dear Procurement,\nPlease refill gas in cylinder of green house for smooth operations.	in_progress	urgent	123	75	75	123	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-11 11:58:39.903185+05	2026-07-11 11:58:39.903185+05	UMP-TKQ-066	\N	f	f	\N
130	Laptop Bag	Kindly Issue Laptop Bag	closed	medium	162	220	79	167	\N	\N	167	2026-07-11 13:03:49.46466+05	\N	0	\N	t	129	standard	0	2026-07-11 12:58:58.336874+05	2026-07-11 13:03:49.46466+05	UMP-TKQ-067-SUB-001	\N	f	f	\N
129	Laptop Bag	Kindly Issue Laptop Bag	completed	medium	162	220	220	162	\N	\N	162	2026-07-11 13:04:51.358926+05	\N	0	\N	f	\N	standard	0	2026-07-11 12:58:58.30494+05	2026-07-11 13:04:51.358926+05	UMP-TKQ-067	\N	f	f	\N
131	Laptop Screen	Laptop Screen	in_progress	urgent	162	220	220	162	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-11 13:05:41.846717+05	2026-07-11 13:05:41.846717+05	UMP-TKQ-068	\N	f	f	\N
132	Laptop Screen	Laptop Screen	closed	urgent	162	220	79	165	\N	\N	165	2026-07-13 11:53:46.629875+05	\N	0	\N	t	131	standard	0	2026-07-11 13:05:41.864893+05	2026-07-13 11:53:46.629875+05	UMP-TKQ-068-SUB-001	\N	f	f	\N
133	Arrangements	Sr\tEmp ID\tName Asper CNIC\tDesignation\tBase Area\tDepartment & Division\n1\t10000946\tAbdul Jabbar\tZonal Sales Manager\tRawalpindi\tSales-FMCG      IT\nEmail ,Laptop,Internet Device	in_progress	medium	154	77	77	154	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-13 16:33:41.891006+05	2026-07-13 16:33:41.891006+05	UMP-TKQ-069	\N	f	f	\N
134	Arrangements	Sr\tEmp ID\tName Asper CNIC\tDesignation\tBase Area\tDepartment & Division\n1\t10000946\tAbdul Jabbar\tZonal Sales Manager\tRawalpindi\tSales-FMCG      IT\nEmail ,Laptop,Internet Device	open	medium	154	77	79	\N	\N	\N	\N	\N	\N	0	\N	t	133	standard	0	2026-07-13 16:33:41.922963+05	2026-07-13 16:33:41.922963+05	UMP-TKQ-069-SUB-001	\N	f	f	\N
135	Arrangements	Sr\tEmp ID\tName Asper CNIC\tDesignation\tBase Area\tDepartment & Division\tDOJ\tAdministration (01)\tIT\tReplacement\tAdministration (D.O.B)(02)\tAdministration (CNIC)(03)\tAdministration (D.O.I)(04)\n1\t10000946\tAbdul Jabbar\tZonal Sales Manager\tRawalpindi\tSales-FMCG\t1/7/2026\tCar(Toyota- Corolla-Auto-CBS 418) & Fuel Card(200) Sim(0309-7770186)\tEmail ,Laptop,Internet Device\t Shahbaz Afzal(10000735)\t07/May/1992\t38101-4788979-3\t30-5-2026	in_progress	medium	154	77	77	154	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-13 16:34:43.327827+05	2026-07-13 16:34:43.327827+05	UMP-TKQ-070	\N	f	f	\N
136	Arrangements	Sr\tEmp ID\tName Asper CNIC\tDesignation\tBase Area\tDepartment & Division\tDOJ\tAdministration (01)\tIT\tReplacement\tAdministration (D.O.B)(02)\tAdministration (CNIC)(03)\tAdministration (D.O.I)(04)\n1\t10000946\tAbdul Jabbar\tZonal Sales Manager\tRawalpindi\tSales-FMCG\t1/7/2026\tCar(Toyota- Corolla-Auto-CBS 418) & Fuel Card(200) Sim(0309-7770186)\tEmail ,Laptop,Internet Device\t Shahbaz Afzal(10000735)\t07/May/1992\t38101-4788979-3\t30-5-2026	open	medium	154	77	75	\N	\N	\N	\N	\N	\N	0	\N	t	135	standard	0	2026-07-13 16:34:43.339494+05	2026-07-13 16:34:43.339494+05	UMP-TKQ-070-SUB-001	\N	f	f	\N
137	DFF	EMP  Code\tFull Name\tEMP  Code\tFull Name\t\tDIV\tDEPARTMENTS\tDEPARTMENTS\t\n10000945\tNadeem Ahmed\t10000945\tNadeem Ahmed\t\tLBFM\t104\t\tUM\n10000946\tAbdul Jabbar\t10000946\tAbdul Jabbar\t\tFMCG\t104\t\tUM\n10000947\tArif Shehzad\t10000947\tArif Shehzad\t\tFMAG\t104\t\tUM\n10000948\tMuhammad Abubakar\t10000948\tMuhammad Abubakar\t\tFMPG\t104\t\tUM\n10000949\tMuhammad Adrees\t10000949\tMuhammad Adrees\t\tFMPG\t101\t\tUM\n10000950\tFazal Abbas\t10000950\tFazal Abbas\t\tFMPG\t101\t\tUM\n10000951\tSafeer Abbas\t10000951\tSafeer Abbas\t\tFMPG\t101\t\tUM\n10000952\tShakeel Ahmad\t10000952\tShakeel Ahmad\t\tFMPG\t101\t\tUM\n10000953\tMuhammad Saif Ullah Khalid\t10000953\tMuhammad Saif Ullah Khalid\t\tFMPG\t101\t\tUM\n10000954\tMuhammad Hamza Qurashi\t10000954\tMuhammad Hamza Qurashi\t\tFMPG\t101\t\tUM\n10000955\tEhtasham Nisar\t10000955\tEhtasham Nisar\t\tFMPG\t101\t\tUM\n10000956\tAli Abbas\t10000956\tAli Abbas\t\tFMPG\t101\t\tUM	in_progress	medium	154	77	77	154	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-13 16:35:49.575741+05	2026-07-13 16:35:49.575741+05	UMP-TKQ-071	\N	f	f	\N
138	DFF	EMP  Code\tFull Name\tEMP  Code\tFull Name\t\tDIV\tDEPARTMENTS\tDEPARTMENTS\t\n10000945\tNadeem Ahmed\t10000945\tNadeem Ahmed\t\tLBFM\t104\t\tUM\n10000946\tAbdul Jabbar\t10000946\tAbdul Jabbar\t\tFMCG\t104\t\tUM\n10000947\tArif Shehzad\t10000947\tArif Shehzad\t\tFMAG\t104\t\tUM\n10000948\tMuhammad Abubakar\t10000948\tMuhammad Abubakar\t\tFMPG\t104\t\tUM\n10000949\tMuhammad Adrees\t10000949\tMuhammad Adrees\t\tFMPG\t101\t\tUM\n10000950\tFazal Abbas\t10000950\tFazal Abbas\t\tFMPG\t101\t\tUM\n10000951\tSafeer Abbas\t10000951\tSafeer Abbas\t\tFMPG\t101\t\tUM\n10000952\tShakeel Ahmad\t10000952\tShakeel Ahmad\t\tFMPG\t101\t\tUM\n10000953\tMuhammad Saif Ullah Khalid\t10000953\tMuhammad Saif Ullah Khalid\t\tFMPG\t101\t\tUM\n10000954\tMuhammad Hamza Qurashi\t10000954\tMuhammad Hamza Qurashi\t\tFMPG\t101\t\tUM\n10000955\tEhtasham Nisar\t10000955\tEhtasham Nisar\t\tFMPG\t101\t\tUM\n10000956\tAli Abbas\t10000956\tAli Abbas\t\tFMPG\t101\t\tUM	open	medium	154	77	220	\N	\N	\N	\N	\N	\N	0	\N	t	137	standard	0	2026-07-13 16:35:49.594292+05	2026-07-13 16:35:49.594292+05	UMP-TKQ-071-SUB-001	\N	f	f	\N
128	Refilling Of Gas Cylinder	Dear Procurement,\nPlease refill gas in cylinder of green house for smooth operations.	in_progress	urgent	123	75	81	170	\N	\N	\N	\N	\N	0	\N	t	127	standard	0	2026-07-11 11:58:39.975831+05	2026-07-14 11:32:03.59805+05	UMP-TKQ-066-SUB-001	\N	f	f	\N
139	Shelve - Trial Shed - Memon Goth - GRP# 47	Please procure the shelves. PR# 726109039	in_progress	high	123	75	75	123	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-15 12:18:17.545803+05	2026-07-15 12:18:17.545803+05	UMP-TKQ-072	\N	f	f	\N
140	Shelve - Trial Shed - Memon Goth - GRP# 47	Please procure the shelves. PR# 726109039	open	high	123	75	81	\N	\N	\N	\N	\N	\N	0	\N	t	139	standard	0	2026-07-15 12:18:17.572893+05	2026-07-15 12:18:17.572893+05	UMP-TKQ-072-SUB-001	\N	f	f	\N
141	Logitech MK250 Wireless Combo	For Mr. Farhan Sagheer	in_progress	medium	165	79	79	165	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-15 12:29:31.976875+05	2026-07-15 12:29:31.976875+05	UMP-TKQ-073	\N	f	f	\N
142	Logitech MK250 Wireless Combo	For Mr. Farhan Sagheer	open	medium	165	79	81	\N	\N	\N	\N	\N	\N	0	\N	t	141	standard	0	2026-07-15 12:29:31.998893+05	2026-07-15 12:29:31.998893+05	UMP-TKQ-073-SUB-001	\N	f	f	\N
143	Corning (3M) Cat 6 Original Cable Roll	For IT department	in_progress	high	165	79	79	165	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-15 12:30:38.043511+05	2026-07-15 12:30:38.043511+05	UMP-TKQ-074	\N	f	f	\N
144	Corning (3M) Cat 6 Original Cable Roll	For IT department	open	high	165	79	81	\N	\N	\N	\N	\N	\N	0	\N	t	143	standard	0	2026-07-15 12:30:38.056019+05	2026-07-15 12:30:38.056019+05	UMP-TKQ-074-SUB-001	\N	f	f	\N
145	Precision Screw Driver Set	For IT department	in_progress	medium	165	79	79	165	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-07-15 12:32:51.016387+05	2026-07-15 12:32:51.016387+05	UMP-TKQ-075	\N	f	f	\N
146	Precision Screw Driver Set	For IT department	open	medium	165	79	81	\N	\N	\N	\N	\N	\N	0	\N	t	145	standard	0	2026-07-15 12:32:51.028478+05	2026-07-15 12:32:51.028478+05	UMP-TKQ-075-SUB-001	\N	f	f	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password_hash, role_id, department_id, company_id, is_active, created_at, reset_token, reset_token_expires, code, must_reset_password, reports_to, designation, last_active, see_all_companies) FROM stdin;
100	Muhammad Naveed	naveed.jabbar@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000278	t	\N	Chief Financial Officer	\N	f
21	Muhammad Sultan	sultan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	52	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000012	t	22	Senior Executive	\N	f
22	Muhammad Umair	scm.ops@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	53	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000779	t	19	Deputy Manager	\N	f
23	Muhammad Faisal Khan	mfaisal@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	53	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000648	t	22	Executive	\N	f
24	Muhammad Talha Sabeel	talhasabeelflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	53	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000848	t	22	Junior Executive	\N	f
157	Muhammad Sufiyan	sufiyan.hr@um.com.pk	$2b$10$rW1uP4IKVtwP2BPLJSqM8uO4JD1WvD.hDiyzNMJa96r310FfjUj/a	2	77	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000813	f	155	Senior Executive	2026-07-07 09:54:50.181301+05	f
1	Qasim	qasim@um.com	$2b$10$l229ufLzJfZTixGmtEku5.gHBijE1YbCX/Ojncx5x7CNgHi49TxUG	0	100	0	t	2026-06-15 12:53:54.138375+05	\N	\N	ADMIN001	f	\N		2026-07-14 14:19:32.260363+05	t
163	Muhammad Qasim Mehmood	Qasim.flow@um.com.pk	$2b$10$ZQ1RIHPP.Rf9KYadMkauBuzqhwoiqgj2fcrfouUpp3Rj.KWoHagrm	2	79	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000920	f	164	Business Application Developer	2026-07-02 18:00:10.546797+05	f
376	Wajahat Ali Khan	waji@matrixpharma.com.pk	$2b$10$IhS3yPLIhCis6AqLQRYLZuazGu2bDOyFIe1uUhSnPjwkT42JIsxGK	1	202	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200007	f	248	Deputy Manager Procurement	2026-06-23 11:15:59.147082+05	f
26	Syed Muhammed Khaliq Uzzaman	khaliq@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	55	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000016	t	38	Manager	\N	f
27	Haider Ali	haider.ali@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	55	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000019	t	25	Officer	\N	f
25	Sheikh Shahbaz Akhtar	shahbaz.akhtar@um.com.pk	$2b$10$DDzzE8MTHKujL10o1gurPeiMjg0lYhRyaDikhuWNDrYVtGqhr2Uk.	1	55	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000018	f	38	Assistant Manager	2026-06-29 09:57:44.934563+05	f
28	Muhammad Zeeshan Khan	m.zeeshan.@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	56	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000739	t	39	Assistant	\N	f
29	Muhammad Faizan	doc@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	57	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000022	t	31	Assistant Manager	\N	f
31	Khawaja Aleem Shah	cr@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	57	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000021	t	100	Senior Manager	\N	f
33	Muhammad Saad	procurement.fa@um.com.pk	$2b$10$vK5.cwTxjdb0KihLHrBzreIQ9uq5s1D8KYyAUBKyVT.r3mPF53KuW	1	59	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000610	f	100	Manager	2026-06-29 10:01:13.382688+05	f
396	Simran Ali Malik	simranmalik@um.com.pk	$2b$10$XuCW04hBYJnL7PaIxoPh0efr.yCx021s7BEyx8go4Bnl4iZkUa6UO	1	77	0	t	2026-06-30 09:56:03.698458+05	\N	\N	10000933	f	153	Lead HR Projects	2026-07-01 17:21:40.896893+05	f
32	Kosain Hanif	coordinator.fa@um.com.pk	$2b$10$ZUdBl5VXgtTpLy7KLyzFNO.zO/c7lSOmGBkXrQmKS0QMEPCh5rABe	2	58	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000050	f	153	Senior Executive	2026-07-07 16:55:26.466192+05	f
59	Ahmed Sohaib	ahmed.sohaib@um.com.pk	$2b$10$vT6Na8EUPTAdxPKXenXGjOsSLLPTrtM4/CtJwoQ4xMpz2UbuOZxXe	1	63	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000069	f	62	Product Manager	2026-06-29 10:49:34.161071+05	f
65	Akber Mughal	stats.fm@um.com.pk	$2b$10$G085V4XnbT.H5TW3yoh92Olm4hV0exlNnZ0S/wiXCrzHJ9ZtSaRQS	1	66	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000168	f	62	Assistant Manager	2026-06-29 10:49:05.498481+05	f
90	Syed Kashif Nayyar Ahmed Jilani	vaccination.services@um.com.pk	$2b$10$vmGxT2nib2iP62n8rt3esekT2YxE7.8fYvY6QRe4XeYQWBnV9VKwm	1	71	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000169	f	71	Assistant Manager	2026-06-29 14:51:51.136078+05	f
39	Sajid Mustafa	scm@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	61	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000051	t	100	Manager	\N	f
40	Adeel Ahmed	adeel.ahmed@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000056	t	46	Assistant Accountant	\N	f
41	Abdul Aziz	abdulaziz@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000062	t	46	Driver	\N	f
42	Dost Muhammad	dost.muhammad@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000055	t	46	Driver	\N	f
43	Muhammad Arshad	muhammadarshad@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000058	t	46	Driver	\N	f
44	Tanveer Ahmed Khan	tanveerahmedkhanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000059	t	46	Driver	\N	f
45	Abdul Salam	abdulsalamflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000897	t	46	Officer	\N	f
46	Imran	Imranflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000597	t	200	Senior Executive	\N	f
47	Ali Akbar	aliakbar@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000061	t	46	Worker	\N	f
48	Malik Muhammad Nasir Asad	nasirflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000547	t	46	Worker	\N	f
49	Malik Mushtaq Ahmed	mushtaq.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000918	t	76	Worker	\N	f
50	Mastan Khan	mastankhan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000057	t	46	Worker	\N	f
51	Muhammad Ali	muhammadali@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000065	t	46	Worker	\N	f
52	Muhammad Muneer	muneerflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000875	t	46	Worker	\N	f
53	Muhammad Nasir	m.nasirflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000860	t	200	Worker	\N	f
54	Muhammad Sameen	muhammadsameenflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000060	t	46	Worker	\N	f
55	Naveed	naveed@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000054	t	46	Worker	\N	f
327	Maryam Zehra	mariam@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100175	t	318	Quality Control Officer	\N	f
56	Sadiq Ali	sadiqali@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000066	t	46	Worker	\N	f
57	Wazeer Muhammad	wazeermuhammad@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000052	t	46	Worker	\N	f
58	Muhammad Zohaib Soomro	mzohaib@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	63	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000068	t	62	Assistant Manager	\N	f
82	Muhammad Farhan	muhammadfarhanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000124	t	76	Worker	\N	f
83	Muhammad Sohail	muhammad.sohail@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000064	t	76	Worker	\N	f
84	Muhammad Waseem Aslam	muhammadwaseemaslamflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000387	t	76	Worker	\N	f
85	Rehan Uddin Siddiqui	rehanuddinsiddiquiflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000117	t	76	Worker	\N	f
87	Sarfaraz Owais Siddiqui	sarfraz.owais@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	69	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000129	t	62	Senior Product Manager	\N	f
88	Muhammad Arsalan Irshad	arsalan.irshad.msd@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	70	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000171	t	68	Executive	\N	f
91	Muhammad Fahad	m.fahadflow@gmail.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	71	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000723	t	71	Officer	\N	f
92	Nauman Haider Siddiqui	nauman.siddiqui@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	72	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000551	t	62	Product Manager	\N	f
93	Hafiz Humayun Khan	humayun.khan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	72	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000067	t	62	Senior Executive	\N	f
35	Muhammad Qamar Khan	oaf@um.com.pk	$2b$10$udHpVdse/t/bWvtQHKYj4.LsnQ2J9SCb7bWtEfsjOF8v/2IETChlW	2	60	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000632	f	198	Coordinator	2026-07-08 15:05:41.153348+05	f
34	Muhammad Uzair	uzair.saeed@um.com.pk	$2b$10$.nmnygXvAZJtW1EOWz6FBeCg1q7U4K..ETLpd/b9yyPnEStOiiRiy	1	60	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000048	f	38	Assistant Manager	2026-07-01 17:59:03.367242+05	f
38	Kabeer Alam	kabeer.alam@um.com.pk	$2b$10$nhjybIGOFAghLal0FBBeau96C1Et6dsYbkTxifCmIaOnIWdYAExbi	1	60	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000045	f	100	Senior Manager	2026-07-01 17:59:02.690594+05	f
37	Muhammad Sarfaraz Hussain	sarfaraz.hussain@um.com.pk	$2b$10$Ssiv26Q0bx/dBQQkMLldzOzlgXj/Zykuh01ELHhe1ZeOPUb0PG/8K	2	60	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000046	f	38	Senior Executive	2026-07-01 18:04:19.149299+05	f
36	Muhammad Ammar Waseem	ammar.waseem@um.com.pk	$2b$10$yYyhoGkNp64WjU/HfvSha.GpHhYHWsi7zR09.zrSV9.ebYxXeEd5G	2	60	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000047	f	38	Officer	2026-07-02 14:45:33.85315+05	f
89	Muhammad Noshad Gull	noshad.flow@um.com.pk	$2b$10$e9abGZLHJKO16EEJsa4WUeV3UZBhE9nexjAluN2sTtffqn5a61Hg2	2	70	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000913	f	68	Senior Officer	2026-07-08 11:19:22.794468+05	f
398	Mian Altaf Jilani	mian.flow@um.com.pk	$2b$10$JI8lOFzTYXN6iDXEw1u0jemK9I4i7XNEM/Zi29pnmDuXQBrCngTN.	2	62	0	t	2026-06-30 10:26:53.157901+05	\N	\N	10000938	t	46	Worker	\N	f
399	Sadia Imtiaz	Sadia.imtiaz@um.com.pk	$2b$10$aB77lgsuMkSeIHqM8vtgPuKHUj7Pzs6m12eGijLiAqaJzWY3s6rl2	1	63	0	t	2026-06-30 10:28:19.291434+05	\N	\N	10000930	t	62	Senior Officer	\N	f
401	Ali Raza Abbasi	ali.abbasi@um.com.pk	$2b$10$8IGDJ6uGJprf51/c7cOA..uywjvEonkQKDgL0UyHwuRhafunRuC46	2	74	0	t	2026-06-30 10:32:49.57088+05	\N	\N	10000931	t	104	Officer	\N	f
400	Hassan Ahmed Faruqi	hassanahmed.flow@um.com.pk	$2b$10$.DFh/yRu4Gx3mHZZflnake5zpJrmIPc9gQ1jGwIOMpmJq7y5ZVnyC	2	67	0	t	2026-06-30 10:30:27.059259+05	\N	\N	10000943	f	68	Officer	2026-07-15 11:41:15.933758+05	f
30	Zehrish	doc2@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	57	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000023	t	31	Executive	\N	f
403	Shahzad Ali	shahzadaliflow@um.com.pk	$2b$10$hB2YWBtQiXwhhpjh3V1zsenSTKhuSMIMITywG3uc7eQImz3y.P/nq	2	75	0	t	2026-06-30 10:41:41.435058+05	\N	\N	10000656	f	113	Rider	\N	f
402	Muhammad Daniyal Hussain	daniyal.hussain@um.com.pk	$2b$10$g5OJsSPh0L7WSmkdt7I4Lebj5KJA7p.YkN8jwE.AAOiARrm1Lq8eq	2	74	0	t	2026-06-30 10:38:05.409155+05	\N	\N	10000932	t	104	Officer	\N	f
404	Muhammad Fahim	purchase@um.com.pk	$2b$10$orsPs1X1ESrzQ/StVfrt7OFtKihOc3PpxaPn479Serq3a15DpaSBe	1	81	0	t	2026-06-30 10:44:14.28321+05	\N	\N	10000916	f	100	Manager	2026-07-08 12:09:04.651441+05	f
170	Mohsin Ahmed Chohan	mohsin.chohan@um.com.pk	$2b$10$stO2.Au9z1zxfQ9cx/LdqelzwUcT62dn96lbSoQISGtVexEEos.Pi	2	81	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000373	f	100	Officer	2026-07-08 13:59:35.478868+05	f
405	Noor Hussain	Noor.flow@um.com.pk	$2b$10$zH6X5exAJ1cgO6AZLlmeMOKM94oM3mMLagZ1EnSRFwiIqjbLz4Anm	2	87	0	t	2026-06-30 10:53:13.694285+05	\N	\N	10000630	f	113	Office Boy	\N	f
94	Muhammad Hunain	m.hunainflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	73	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000903	t	68	Officer	\N	f
165	Muhammad Fashi Ullah Khan	it.support@um.com.pk	$2b$10$Yndy0GIDfrsGuD9qd9YpzuiCVCTQz0Y3nolg25QUlBrlzbW75F7ku	2	79	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000368	f	168	Executive	2026-07-13 11:51:42.657208+05	f
105	Muhammad Umer Farooq	umer.farooq@um.com.pk	$2b$10$/1Gzi6XnwHatKKCunANwmu2X/m0AcTRtMtSOFu/BMjcWBpz27CR.6	2	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000275	f	104	Officer	2026-06-29 10:39:54.066554+05	f
397	Khuzaima Hassan	pm.dx@um.com.pk	$2b$10$6HAQA1azCPpLneJzRSTtr.IYuxU31IGbj/3zc.5I3IfBnwcC9LqaO	2	51	0	t	2026-06-30 10:24:53.007827+05	\N	\N	10000942	t	19	Management Trainee Officer	\N	f
101	Shah Fahad Khan	shahfahad@um.com.pk	$2b$10$1uEOH92766TGqPAEFhu20.tKTJb9XpbfTNat9DcC15nbQgRnpTLJO	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000266	f	104	Deputy Manager	2026-07-01 11:38:38.74132+05	f
96	Ali Inayat	ali.inayat@um.com.pk	$2b$10$GHyANhtYEgel68zPbSLwvuNoI.x.QqE8ZdUrr3FCD6IvQG7dgEGia	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000277	f	104	Assistant Manager	2026-06-30 15:59:15.86828+05	f
95	Muhammad Hussain	hussainflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	73	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000886	t	68	Officer	\N	f
97	Muhammad Siraj	muhammad.siraj@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000269	t	104	Assistant Manager	\N	f
98	Muhammad Zaki Uddin Farooqui	zaki@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000261	t	108	Assistant Manager	\N	f
99	Tariq Ali Khan	tariq.khan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000265	t	104	Assistant Manager	\N	f
102	Muhammad Ziyad Ashrafi	ziyad.ashrafi@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000279	t	108	Executive	\N	f
103	Syed Adeel Mashkoor	adeel.mashkoor@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000273	t	104	Executive	\N	f
104	Muhammad Arsalan	muhammad.arsalan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000276	t	100	Head Of Department	\N	f
107	Wajahat Ullah Khan	wajahatullah@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000274	t	104	Senior Executive	\N	f
108	Shabbir	shabbir.hussain@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000270	t	100	Senior Manager	\N	f
109	Sheraz Ahmad	sheraz.ahmad@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000262	t	100	Senior Manager	\N	f
110	Muhammad Hamid	hamidflow.@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000889	t	138	Ac Technician	\N	f
112	Muhammad Yaqoob Chohan	yaqoobchohanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000301	t	137	Caretaker	\N	f
114	Chanzeb	chanzebflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000348	t	152	Driver	\N	f
115	Muhammad Aslam	muhammadaslamflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000303	t	138	Electrician	\N	f
122	Syed Wasi Hassan	syedwasihassan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000292	t	\N	\N	\N	f
266	Umair Nadeem	umairns.matrix@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	204	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100063	t	273	Deputy Manager CD	\N	f
117	Muhammad Riaz Hussain	muhammadriazhussain@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000282	t	138	Helper	\N	f
118	Haider Ali	haiderali@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000280	t	113	Office Boy	\N	f
119	Muhammad Adnan	muhammadadnan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000315	t	113	Office Boy	\N	f
120	Muhammad Gulzaar Ahmed	gulzar.flowahmed@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000800	t	113	Office Boy	\N	f
121	Noor Ud Din	nooruddin@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000298	t	113	Office Boy	\N	f
124	Ali Ramzan	aliramzanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000343	t	113	Photocopier	\N	f
125	Amna Siddiq	amnasiddiqui@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000294	t	137	Receptionist	\N	f
126	Humera Atiq	humeraatiq@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000285	t	137	Receptionist	\N	f
382	Azmat Ali Khan	aliazmat5666@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	207	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200018	t	334	Projects Officer	\N	f
116	Abdul Rehman	abdurrehman@um.com.pk	$2b$10$fKTR3Ktd7NuC/RpEP8JETec8TyNpN5r2zyPfmuCOtzUjTxiC1eVA2	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000314	f	137	Executive	2026-06-30 14:38:23.936884+05	f
111	Kumail Arif	kumail.arif@um.com.pk	$2b$10$CrJWVH1QRRuzFw3k7OcabemyKwxNqgC4Zh6bj2.B9ZuocpL5/OjQ6	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000287	f	113	Assistant	2026-06-30 17:12:08.654947+05	f
71	Syed Mohsin Hasan	Mohsin.hassan@um.com.pk	$2b$10$iF8drgMkFQgU8Awn7P8/2uBzB9V0BF/JeR7CFYtVF/WnB1KnHfzGu	1	67	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000112	f	62	Senior Manager	2026-07-08 11:20:32.930592+05	f
113	Muhammad Owais Raza	owais.raza@um.com.pk	$2b$10$.mOhiRF9dqJ9duOSUaDwaOV4.k3UyiAf41EfyXkSUDbFHd/J0h7hK	1	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000284	f	137	Deputy Manager	2026-07-01 11:55:21.246726+05	f
167	Muhammad Yahya Ajmal	yahyaajmalflow@um.com.pk	$2b$10$TGZMx0p3xJ0962OtgWwuCOMHIKEmLfblTiCWe7qAwsN8hGSWZEKhq	2	79	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000657	f	168	Junior Assistant	2026-07-11 13:02:48.665503+05	f
344	Syed Muhammed Jamshed 	syed.jamshed@matrixpharma.com.pk	$2b$10$Icr9/T.x.Mf.JZFglk9UIuhnQ1rTZrjggxfED/Yoz5.moczuBdRjC	0	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100199	f	394	Chief Executive Officer	2026-06-23 10:04:02.116678+05	f
127	Owais Ahmed Khan	owaisahmedkhanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000297	t	113	Recovery Officer Rider	\N	f
128	Muhammad Athar Khan	muhammadatharkhanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000296	t	113	Rider	\N	f
129	Muhammad Khurram Ali	muhammadkhurramali@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000289	t	113	Rider	\N	f
130	Umair Maqbool	umairmaqbool@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000281	t	113	Rider	\N	f
131	Dost Muhammad	dostmuhammad@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000341	t	113	Security Guard	\N	f
132	Ghulam Rasool	ghulamrasoolflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000344	t	137	Security Guard	\N	f
133	Hafiz Muhammad	hafizmuhammad@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000333	t	113	Security Guard	\N	f
134	Ibrahim Shah	ibrahimshahflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000346	t	137	Security Guard	\N	f
135	Safdar Ali	safdaraliflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000316	t	113	Security Guard	\N	f
136	Zar Malik Shah	zarmalikshahflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000312	t	113	Security Guard	\N	f
139	Anwar	anwar.manzoor@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000763	t	113	Sweeper	\N	f
140	Ashfaq Gill	Ashfaqgillflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000628	t	113	Sweeper	\N	f
141	Imran Ayoub	imranayoub@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000304	t	113	Sweeper	\N	f
142	Imran Pervez	imranpervezflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000313	t	113	Sweeper	\N	f
143	Johnson	johnsonjozafflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000291	t	113	Sweeper	\N	f
144	Johnson	johnson@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000353	t	175	Sweeper	\N	f
145	Kalsey Dona	kalseydona@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000340	t	113	Sweeper	\N	f
146	Kashif	Kashiflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000550	t	113	Sweeper	\N	f
147	Munir Bashir	munirbashirflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000293	t	113	Sweeper	\N	f
149	Sehoon Joseph	sehoon.joseph@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000764	t	113	Sweeper	\N	f
151	Muhammad Saqib	muhammadsaqib@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000300	t	138	Worker	\N	f
152	Muhammad Shahid Siddiqui	ss@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	76	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000357	t	100	Head Of Department	\N	f
159	Amna Khan	amna.khan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	78	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000363	t	39	Executive	\N	f
160	Talha Bashir	talhabashir@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	78	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000362	t	39	Rider	\N	f
123	Huraira Khan	huraira.khan@um.com.pk	$2b$10$OO3gNqZS5UNYPeKzwabTf.i8tkT/0igV5nTZJ/nn6ytd097Una3Ia	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000306	f	137	Officer	2026-07-10 15:11:14.525759+05	f
137	Syed Rameez Hussain	rameez.hussain@um.com.pk	$2b$10$JiulQipr/uQ8sXXuXDxeCOuaB7dLQVhHTvPDPb6lBYkMXOzeoGPZO	1	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000371	f	153	Senior Manager	2026-06-30 10:51:13.64459+05	f
164	Bilal Ahmed	bilal.ahmed@um.com.pk	$2b$10$s6sw3btsPnKjDnf4rv1sNO93ZER6LT97YBzFZZkut0c3nHmQrlZ/i	1	220	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000369	f	100	Deputy Manager	2026-07-15 16:48:00.37757+05	f
166	Muhammad Hamza Khan	mhamzakhan@um.com.pk	$2b$10$nt7XBA6RoCsugp5SuIYEye2p9VIvO1Fe20jxlG9qiXFb5tDtdz.wS	2	220	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000641	f	100	Executive	2026-07-09 10:15:00.701112+05	f
161	Muhammad Asad Sheikh	import.doc@um.com.pk	$2b$10$e16ZoReQ7xe9VBE0zavX7uchXOx2e1.0yF1wNFmaI8cqLWLZRAIBG	2	78	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000528	f	39	Senior Executive	2026-06-29 10:22:04.390378+05	f
162	Faraz	faraz.hanif@um.com.pk	$2b$10$iok1PTLqIsF80dsRTd3AdOB5A1ylYQPQHky2dfFQ1FYryHozEMJTq	2	220	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000366	f	100	Assistant Manager	2026-07-11 12:57:28.118692+05	f
168	Dilawar Farrukh Rauf	farrukh.rauf@um.com.pk	$2b$10$gk1VOWj0v9wqlDtKtgIiCOASN9z035oi0IBXrdC5I16NujPLendEG	1	79	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000365	f	100	Senior Manager	2026-07-07 10:49:20.717484+05	f
153	Farhan Saghir	farhan.saghir@um.com.pk	$2b$10$NLjKEs7flLrZLfeKaoZ.ee6sus3RY/z.o.qPElO1MDO1SDY9wxu/C	1	77	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000822	f	153	Head Of Department	2026-07-03 11:30:44.490081+05	f
171	Naveed Ahmed	naveedahmed@um.com.pk	$2b$10$oeH/41HwcVbpuPdEHv2/R.8z0ed/hKV2khLAHLPXfPtlW72BYvA66	2	81	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000372	f	404	Rider	2026-07-07 15:33:07.785521+05	f
172	Mohammad Farhan	mohammad.farhan@um.com.pk	$2b$10$4PlA2MwqUfIVWSUOHaK4Te.ywqpHMkhw.Vz6B4lyK4./D1CBVfQfK	1	81	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000375	t	100	Senior Executive	\N	f
138	Kamran	kamran.flow@um.com.pk	$2b$10$KX5ulGLDWchjOE0QT8bMB.bEMvYehdQ/VzKrjqXi4CmUQUBSorlb2	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000726	f	137	Supervisor	2026-06-30 11:44:22.167525+05	f
169	Shahzad Riaz	shahzadriaz@um.com.pk	$2b$10$u2kh1VCfzPki203ZWt3bO.j5aVLJWd4wIVfywWmbS5Efhp38JU9am	1	80	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000013	f	153	Manager	2026-06-30 14:24:56.468257+05	f
158	Zia ul Hassan	zia@um.com.pk	$2b$10$w08xhaDKeKMwfeisY/1X0OkJPAUOJ08uymG/yuEzNaiKxBu/jeqBS	1	78	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000364	f	39	Deputy Manager	2026-07-15 09:35:16.081375+05	f
189	Shiraz	shiraz.silas@um.com.pk	$2b$10$1MSCkIBl3g1mbcgN5si2weJaRuJhxN9NKEXTs001eNhdY5f/vOc6q	2	83	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000826	f	187	Officer	2026-06-30 10:00:35.017869+05	f
190	Muhammad Raheel Abbasi	muhammad.raheel@um.com.pk	$2b$10$PI7T3nsVjbGQg8PIV8Fd..xMEIFy0wruCp7jwS7UNcKtpoNZJdZZe	2	83	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000398	f	186	Senior Executive	2026-07-02 09:56:14.514231+05	f
193	Hunain Ali	hunain.ali@um.com.pk	$2b$10$kFLp.jevRRGeIQJditziWeRLzkusbvcUEr9KPbJsPWDNckyXOpb8a	2	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000025	f	194	Coordinator	2026-07-08 11:41:16.089762+05	f
154	Muhammad Rasheed	rasheed.hr@um.com.pk	$2b$10$t9TVV26PUxVlJgXdgR8Fge2ycL7CNwCaqLYBobQIEjP90EgY8ej9K	2	77	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000359	f	155	Junior Assistant	2026-07-13 16:31:42.404038+05	f
173	Qamar Uddin	Qamar.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	82	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000915	t	175	Machine Operator	\N	f
174	Riaz Hussain	riazhussainflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	82	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000681	t	175	Machine Operator	\N	f
176	Muhammad Afzal	muhammadafzalflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	82	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000378	t	175	Worker	\N	f
177	Muhammad Ghalib	muhammadghalib@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	82	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000384	t	175	Worker	\N	f
178	Muhammad Salman Siddiqui	muhammadsalmansiddiquiflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	82	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000379	t	175	Worker	\N	f
179	Muhammad Suleman	m.sulemanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	82	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000392	t	175	Worker	\N	f
180	Muhammad Ubaid Siraj	muhammadubaidsirajflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	82	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000382	t	175	Worker	\N	f
181	Rizwan Ahmed	rizwanahmedflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	82	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000383	t	175	Worker	\N	f
182	Salman Malik	salmanmalik@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	82	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000380	t	175	Worker	\N	f
183	Shahriyar	shahriyar@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	82	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000385	t	175	Worker	\N	f
184	Shakir Ullah	shakirullah@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	82	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000381	t	175	Worker	\N	f
185	Mehr Un Nisa	mehr.khan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	83	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000399	t	187	Deputy Manager	\N	f
186	Abdul Hafeez	abdul.hafeez@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	83	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000396	t	100	Manager	\N	f
187	Muhammad Masood	muhammad.masood@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	83	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000397	t	153	Manager	\N	f
188	Muhammad Noman	mnoman@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	83	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000627	t	186	Officer	\N	f
191	Abdul Qayoom	abdulqayoomflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000718	t	194	Caretaker	\N	f
192	Mehtab Ali	mehtabaliflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000288	t	194	Caretaker	\N	f
194	Muhammad Sami Khan	sami.khan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000131	t	20	Manager	\N	f
195	Miraal Javed	miraalflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000693	t	194	Officer	\N	f
200	Sarfaraz Ahmed Khan	sarfaraz.ahmed@um.com.pk	$2b$10$PERX2uYjyKue8YTp.tk7xOslaR7Cv5Vo5uynKiOuINKOH6JXm4ZoO	1	86	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000409	f	153	Manager	2026-07-14 15:20:35.272247+05	f
196	Naima Mukhtar	Naimaflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000698	t	194	Officer	\N	f
197	Khizer Ur Rehman Khan Ghori	khizerflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000796	t	194	Senior Officer	\N	f
198	Muhammad Sohail	pa.im@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	85	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000401	t	100	Assistant to Director	\N	f
199	Muhammad Shamim Azim	azim@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	85	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000400	t	100	Senior Liaison Officer	\N	f
20	Abdul Wasay Malik	wasaymalik@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	52	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000011	t	153	Deputy Business Unit Head	\N	f
202	Adnan Rehmat	adnanrehmatflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	86	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000407	t	201	Worker	\N	f
203	Kashmir	kashmirflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	86	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000404	t	201	Worker	\N	f
204	Muhammad Kaleem	muhammadkaleem@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	86	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000405	t	201	Worker	\N	f
205	Sikandar	sikandar@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	86	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000406	t	201	Worker	\N	f
206	Ubaid Ur Rehman	ubaidurrehmanflow.@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	86	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000127	t	201	Worker	\N	f
207	Waseem Akram	waseemakram@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	86	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000388	t	201	Worker	\N	f
208	Shams Ullah Rafeeq	Shams.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	87	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000825	t	113	Driver	\N	f
209	Aslam Muhammad	aslam.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	87	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000310	t	113	Gardener	\N	f
210	Yousaf Khan	yousuf.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	87	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000736	t	113	Security Guard	\N	f
211	Khalil Akram	Khalil.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	88	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000622	t	175	Worker	\N	f
213	Muhammad Israfeel Khan	Israfeel.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	88	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000705	t	175	Worker	\N	f
214	Muhammad Kashif	kashif.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	88	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000828	t	175	Worker	\N	f
215	Muhammad Nauman Malik	Nauman.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	88	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000618	t	175	Worker	\N	f
216	Naveed Ahmed	Naveed.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	88	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000704	t	175	Worker	\N	f
217	Noor Alam	noorflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	88	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000746	t	175	Worker	\N	f
218	Shafi Muhammad	shafi.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	88	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000700	t	175	Worker	\N	f
219	Shaman	shaman.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	88	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000702	t	175	Worker	\N	f
220	Waqas	waqas.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	88	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000063	t	175	Worker	\N	f
221	Waseem Ahmed	waseem.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	88	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000623	t	175	Worker	\N	f
222	Saqib Khan	saqibkhanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	89	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000851	t	200	Officer	\N	f
224	Ammar Malik	boviteam@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	90	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000490	t	153	Business Unit Head	\N	f
226	Muhammad Waqas Saleem	waqas.saleem@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	90	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000491	t	224	Manager	\N	f
228	Syed Muzammil Ali	muzammilflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000852	t	76	Officer	\N	f
229	Abdul Muqeet	abdulflow.@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000742	t	76	Worker	\N	f
230	Abdul Wahab	abdul.wahabflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000854	t	76	Worker	\N	f
260	Waqar Ahmed Abbasi	wqr.abbasi@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	210	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100033	t	273	Senior Business Manager	\N	f
261	Saima Khalil	saimasaima008763@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100041	t	248	Import Officer	\N	f
86	Khalid Gulab	khalid@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	69	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000128	t	62	Assistant Manager	\N	f
225	Muhammad Aziz Ur Rehman	cod.la@um.com.pk	$2b$10$2x3re/i0pCUbYO.9FFqH5OKmlBmOfHahk9sUVosCL/bx5wVCt4akG	1	90	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000493	f	226	Deputy Manager	2026-06-30 12:13:23.767368+05	f
155	Adnan Najeeb	adnan.hr@um.com.pk	$2b$10$390XJrg6wjINxnhVRHR.8OxduNPwAKSZXcxI0r40RDb00rTkDS11i	1	77	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000358	f	153	Manager	2026-07-14 13:59:19.039134+05	f
223	Hamza Ali Khan	hamza.khan@um.com.pk	$2b$10$mLbabUfthVj7muhyB5S4OOPbFijlgrytZV9SxHtfcmDwJyyikA4Qi	1	90	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000492	f	224	Assistant Manager	2026-06-29 11:17:56.752002+05	f
274	Atta Ur Rehman 	it.support@matrixpharma.com.pk	$2b$10$ed3GoGKNndusbVjk84e8xuwqczLgrJMs7ceOaGB7OApF.ZYufUzd6	2	79	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100079	f	264	IT Officer	2026-07-13 11:20:22.86885+05	f
227	Sufyan Malik	cod.la2@um.com.pk	$2b$10$EUkDMgIygYi5vHCDxQ0eOuSBcUOko6xC3hV7Kvav8977PIEk1Osym	2	90	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000494	f	226	Officer	2026-06-30 12:16:45.163986+05	f
201	Fazal ur Rehman Khan	pkg.store@um.com.pk	$2b$10$0iriwu09EjCzCYbcs0OO2uxvdZtLdjJmT45d6KJk/q0lBdHE.CVh6	2	86	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000408	f	200	Supervisor	2026-07-03 17:05:01.255119+05	f
262	Iqra Nadeem	iqra.nadeem@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	206	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100056	t	255	Deputy Manager Business Development	\N	f
264	Kashif Musawer	it@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	79	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100060	t	248	Manager IT	\N	f
265	Ehsan Ul Huda 	ehsan.ul.huda@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	211	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100062	t	273	Business Manager	\N	f
267	Shahrukh Jamal	supportofficer@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	205	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100065	t	272	Senior Sales Excellence Officer	\N	f
268	Hammad Zafar	hammad@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	212	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100066	t	275	Accounts Assistant	\N	f
269	Raheel Ahmed Khan	raheel.ahmed@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100070	t	318	Assistant Manager Quality Control	\N	f
270	Habib Ur Rehman 	rehman.cheema74@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	210	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100074	t	273	Deputy GM Sales	\N	f
272	Muhammad Tahir 	m.tahir@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	205	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100077	t	344	Sr Manager Commercial Excelence	\N	f
275	Aaqib Jawed	aaqib@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	212	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100080	t	344	Chief Financial Officer	\N	f
276	Muhammad Moiz Ahmed	sales@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	209	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100083	t	375	Senior Marketing Officer	\N	f
277	Muhammad Owais 	m.owais@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100086	t	373	Store Helper	\N	f
278	Sajid Iqbal	sajidiqbal@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100087	t	373	Store Helper	\N	f
279	Amir Shah	amirshah@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100088	t	373	Store Helper	\N	f
280	Zohaib Arif	zohaibarif@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100090	t	373	Store Helper	\N	f
281	Muhammad Ali 	ali.muhammad@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100092	t	373	Store Helper	\N	f
282	Muhammad Azeem 	azeem@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100093	t	373	Store Helper	\N	f
283	Riffat Abbas	riffatabbas30@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100095	t	301	Helper	\N	f
284	Sher Ali	ali.mani1983@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100096	t	248	Supervisor	\N	f
286	Kamran Uddin	kamranuddin@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100098	t	299	Helper	\N	f
287	Muhammad Usman Khan	muhammad.usman@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	202	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100099	t	376	Purchaser	\N	f
288	Muhammad Naeem Afzal	m.naeem@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100100	t	373	Store Helper	\N	f
289	Muhammad Shahid	m.shahid@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100104	t	373	Store Helper	\N	f
290	Syed Aqib Hussain Shah	syedaqib@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100105	t	373	Store Helper	\N	f
291	Muhammad Irfan 	m.irfan@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100106	t	373	Store Helper	\N	f
292	Kamil Nawaz	kamil.nawaz@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100107	t	373	Store Helper	\N	f
293	Muhammad Hassan Raza	ccrs@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	205	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100108	t	272	Marketing Assistant	\N	f
294	Shahid Ali	Shahid.Ali@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100110	t	390	Para Legal	\N	f
296	Shazil Aslam	shazil.aslam@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	211	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100121	t	273	Product Manager	\N	f
297	Muhammad Ibrar Fahim	ibrarkhushi333@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	212	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100122	t	275	Accounts Assistant	\N	f
298	Hamza Khan	distribution.officer@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	208	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100123	t	372	Senior Officer Distribution	\N	f
300	Muhammad Naeem 	rana@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	203	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100125	t	273	Deputy Manager Digital Marketing	\N	f
301	Imrana Faheem Qureshi	imrana.faheem@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	215	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100128	t	248	Sr Manager Quality Operations	\N	f
303	Shaukat Ali	shaukatali@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100133	t	331	Machine Operator	\N	f
304	Muhammad Anas 	marketing@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	208	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100135	t	372	Distribution Officer	\N	f
295	Muhammad Usman 	usman@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100119	t	373	Sr. Store Executive	\N	f
302	Muhammad Pervaiz	pervaiz@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	215	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100131	t	301	Assistant Manager Quality Assurance	\N	f
2	Muhammad Naveed Akhtar	muhammadnaveedakhtar@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000317	t	138	Ac Technician	\N	f
299	Asif Ali	asif.ali@matrixpharma.com.pk	$2b$10$gOunEVRZGCniJKq5OrhFaujJPMlLf4JVbyt5wYAfGUOlPXKONOWhC	1	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100124	f	248	Senior Plant Manager	2026-06-20 15:29:25.056145+05	f
273	Muhammad Waseem 	m.waseem@matrixpharma.com.pk	$2b$10$dGvTxXgF7xiUIeoiYcMwuedH75TZvd5uOhm7kNRTRzApfDPFGgi9i	2	210	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100078	f	344	Head of Sales And Marketing	2026-06-22 09:42:15.30654+05	f
310	Muhammad Naveed	production1@matrixpharma.com.pk	$2b$10$yTZl.044tyDfeC8y076BV.dJuHQaaHJztd335onaCVbY0HT.qI4Fa	1	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100141	f	299	Senior Officer Planning	2026-06-22 12:26:50.89887+05	f
247	Fareed Ahmed Soomro	cod.la3@um.com.pk	$2b$10$W9YXmkqHtdgqQUp2XEinr.oB1FMtmyoOxDXg/Cqmoeu7I/4QZhyJ2	1	95	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000797	f	226	Deputy Manager	2026-06-30 09:15:19.529453+05	f
3	Rashid Ali	rashidaliflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000318	t	138	Ac Technician	\N	f
4	Ghulam Abbas	ghulamabbas@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000319	t	113	Gardener	\N	f
5	Muhammad Imran	imran@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000320	t	138	Helper	\N	f
6	Amir Abbas	amirabbas@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000321	t	113	Security Guard	\N	f
7	Majid Hussain	majidhussainflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000324	t	113	Security Guard	\N	f
8	Muhammad Nasir Khan	nasirflow.@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000322	t	113	Security Guard	\N	f
9	Shafqat Hussain	shafqathussain@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000323	t	113	Security Guard	\N	f
10	Adeel Shahzad Gill	adeelshahzadgillflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000327	t	113	Sweeper	\N	f
11	Asghar	asgharflow.@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000869	t	113	Sweeper	\N	f
12	Farooq Masih	farooqmasihflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000329	t	113	Sweeper	\N	f
13	Lal Victor	lalvictorflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000328	t	113	Sweeper	\N	f
14	Rafaqat Salamat	rafaqatsalamatflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000330	t	113	Sweeper	\N	f
15	Yousuf Masih	yousufmasihflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000326	t	113	Sweeper	\N	f
16	Farhat Perveen	farhat.perveen@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	51	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000870	t	19	Executive	\N	f
17	Yusra	yusra.jabbar@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	51	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000001	t	19	Executive	\N	f
18	Humais Khan	crm.dx@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	54	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000871	t	19	Intern	\N	f
19	Hassan Adil	hassan.adil@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	52	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000010	t	20	Business Unit Manager	\N	f
305	Kamran Robert	kamranrobert2@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	208	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100136	t	372	Distribution Officer	\N	f
307	Minha Shah	minha.shah@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	211	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100138	t	273	Assistant Product Manager	\N	f
308	Musa Parvez Khan Swati	musa.khan@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100139	t	299	Project Manager Plant	\N	f
309	Muhammad Panah	m.panah@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100140	t	299	MixingAndDispensing Incharge	\N	f
311	Zameer Ahmed Bhatti	zameerbhatti@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100142	t	299	Machine Operator	\N	f
314	Laraib Khan	laraibkhan@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100145	t	299	Machine Operator	\N	f
315	Erum Ikram	erumikram@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100146	t	299	Line Incharge	\N	f
316	Muhammad Noman 	m.noman@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	216	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100147	t	331	Senior Officer Engineering	\N	f
317	Mazhar Iqbal	mazhariqbal@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100151	t	299	Machine Operator	\N	f
319	Azmat Ali	azmat.ali@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	217	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100161	t	390	GM International Business	\N	f
320	Syed Imran Ali	imran@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	203	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100162	t	273	Animation Executive	\N	f
321	Syeda Amna Meraj	vectors@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	206	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100163	t	255	Business Development Executive	\N	f
322	Syed Jamil Ahmed	jamil.ahmed@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	215	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100165	t	301	Executive Quality Assurance	\N	f
323	Sahar Saleem	sahar.saleem@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	206	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100170	t	255	Business Development Executive	\N	f
324	Namra Sabir	namra.sabir@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	218	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100171	t	248	Export  Regulatory Executive	\N	f
325	Muhammad Umais Siddiqui	umais.siddiqui@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	211	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100173	t	273	Assistant Product Manager	\N	f
326	Laiba Ahmed 	laiba.ahmed@matrixpharma.com.pk	$2b$10$PoD.FjfZkxU9P.tWzWtFlecpvA9WC2f/cUiBKXNgUqnz33bz0gBEG	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100174	f	299	Production Officer	2026-06-22 12:26:14.764842+05	f
306	Daniyal Jawaid	daniyal@matrixpharma.com.pk	$2b$10$Ybgu50IpMp2TwGK58XPUjuxecCUghU/u6u5wNHXd2wYuMdi0XZfp2	2	202	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100137	f	376	Sr. Supply Chain Operations Officer	2026-06-23 11:15:55.477014+05	f
66	Owais Najam	owais.najam@um.com.pk	$2b$10$bdzl/gFRQpkx12.cOss0SuIH7z4bh8BMUDuUBhmBdxRhptLYR2oxW	1	67	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000115	f	68	Assistant Manager	2026-06-29 10:37:19.130448+05	f
348	Maheen Asif	maheen@matrixpharma.com.pk	$2b$10$Q/UV5uckOj10D0jkjoEZouIe.jKp2qKanEA0jApjLSQWSPh.uKmFi	2	215	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100203	f	301	Quality Assurance Officer	2026-06-29 15:15:31.046413+05	f
329	Muhammad Arsalan 	arsiarsalan058@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100179	t	373	Store Officer	\N	f
332	Fariza Sohail	fariza.sohail@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	218	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100182	t	248	Regulatory Affairs Executive	\N	f
333	Muhammad Sufiyan 	sufyangraphix@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	203	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100183	t	300	Sr. Graphics Designer	\N	f
334	Muhammad Salman Shahid 	salmanmss@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	207	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100186	t	394	General Manager Projects	\N	f
335	Mina Naz	minamatrix013@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100187	t	248	Import Officer	\N	f
336	Muhammad Saad Tariq 	tariqsaad997@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100189	t	299	Production Officer	\N	f
337	Muhammad Uzair 	muhammad.uzair@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	211	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100192	t	273	Assistant Product Manager	\N	f
338	Muhammad Zeeshan 	mmzeeshan2011@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100193	t	299	Operator - Sachet Filling	\N	f
339	Faiza Riaz 	faizariaz@mp.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100194	t	299	Line Incharge - Packaging	\N	f
340	Muhammad Tehseen Hussain 	tehseen.11@mp.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100195	t	299	Operator - Sachet Filling	\N	f
341	Muhammad Aqil 	m.aqil.tu.mb786@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100196	t	299	Operator - Mixing	\N	f
150	Viki	viki@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000302	t	113	Sweeper	\N	f
342	Ubaid Rehman 	ubaidshah246@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100197	t	299	Operator - Liquid Filling	\N	f
343	Abdul Wakeel 	wakeel.1@mp.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	216	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100198	t	331	AC Technician	\N	f
345	Ansa Rafique 	ansarafiq879@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	212	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100200	t	275	Accounts Officer	\N	f
346	Qunoot Ghazanfar 	qunootghazanfar05@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	212	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100201	t	275	Accounts Officer	\N	f
347	Muhammad Usama Saleem 	uq8599764@gmaiL.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100202	t	318	Lab Attendant	\N	f
350	Areeba Naqvi	areeba.naqvi@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100205	t	318	QC Officer Microbiologist	\N	f
351	Tanzeel Fatima 	tanzeel.fatima@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	217	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100206	t	319	Product Executive	\N	f
318	Syed Muhammad Ali Naqvi	ali.naqvi@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100158	t	301	Manager Quality Control	\N	f
331	Aman UL Hassan	aman.ul.hassan@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	216	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100181	t	299	Manager Engineering	\N	f
328	Sameer Ali Shaikh	hrb@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	200	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100178	t	257	HR Executive	\N	f
352	Wajeeha 	Wajeeha.shahid@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	203	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100207	t	300	Jr. E-Commerce Officer	\N	f
355	Neha Rasheed	neharasheed798@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100210	t	301	Product Development Officer	\N	f
356	Syeda Baneen Zehra 	sbaneenzehra110@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	218	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100211	t	248	Regulatory Affairs Officer	\N	f
357	Khwaja Sulaeman Hasan 	hksulaeman@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100212	t	318	Quality Control Officer	\N	f
358	Abdul Wasay 	wasayshafi24@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100213	t	318	Lab Assistant	\N	f
360	Warisha 	warisha.inayat@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	203	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100215	t	300	Social Media Officer	\N	f
361	Waqar Ahmed 	waqarali325902@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	215	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100217	t	301	Quality Assurance Officer	\N	f
362	Yasir Hussain 	yasir.hussain@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	210	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100218	t	273	Business Manager	\N	f
363	Janees Hasan	janeeshasanofficial@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100219	t	318	Quality Control Officer	\N	f
364	Nosherwan 	muhammad.nosherwan52@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100220	t	318	Assistant Manager Quality Control	\N	f
365	Hafsa Hadia	hafsa.hadia@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	206	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100221	t	255	Business Development Executive	\N	f
366	Ahmed Abbas 	ahmed.abbas@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	211	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100222	t	273	Assistant Product Manager	\N	f
353	Neha 	nehaanajam@gmail.com	$2b$10$1o4TPW2Sj.naeiNkp7OZAOH4C3Q4yKowKEHeIgEuhKQCr8Mdlr2o.	2	200	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100208	f	249	HR Officer	2026-06-22 09:46:13.267981+05	f
354	Muhammad Zahim Khan 	zahim.khan@matrixpharma.com.pk	$2b$10$AqHYt/Q.mOywiMD4yWD7xOoo564Xhuz4/AbikIxe9us8/nKARUGWq	2	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100209	f	248	Executive Import	2026-06-22 10:07:43.296681+05	f
330	Kiran Saeed	kiransaeed111@gmail.com	$2b$10$BELsO88aIMqPM4hvaKO0r.8hZG.B0eCpsmM1S0gvIN36uoVh4g9za	1	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100180	f	299	Senior Executive Production	2026-06-22 12:52:19.085363+05	f
72	Abdul Jabbar Khan	abdul.jabbar@um.com.pk	$2b$10$E.ECR6f01rCqHftskbmt7OcOCiGaNdK4/YRvpZh1TvBBfzTIgSnhC	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000121	f	76	Assistant	2026-07-07 16:23:37.21916+05	f
370	Ivon Junaid 	ivonjunaid7@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	204	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100226	t	266	Graphic Designer	\N	f
371	Sagheer Raza	raza@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	212	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200002	t	275	Manager Accounts	\N	f
372	Asif Ali	distribution@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	208	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200003	t	273	Sr Manager Distribution	\N	f
373	Muhammad Amin Khattak	aminkhattak@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200004	t	248	Sr Manager Logistics	\N	f
374	Naeem Ur Rehman 	naeemrehman@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200005	t	248	Office Boy	\N	f
375	Haroon Ur Rasheed 	msd@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	209	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200006	t	273	Deputy Manager Marketing Services	\N	f
377	Abdul Qadeer Baig	qadeer@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	212	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200010	t	275	Deputy Manager Accounts	\N	f
378	Muhammad Qamar 	muhammad.qamar@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	219	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200011	t	248	Electrician	\N	f
379	Shabana Masood	shabana@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	211	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200012	t	273	Business Support Manager	\N	f
380	Muhammad Amin 	amin.accounts@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	212	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200013	t	390	Chief Accountant	\N	f
381	Muhammad Adnan 	store@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200015	t	373	Assistant Manager Store	\N	f
383	Shahbaz Ali	fg@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200019	t	373	Store Executive	\N	f
384	Sherazuddin 	sherazuddinsheraz@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200020	t	373	Store Helper	\N	f
385	Ahmed Saeed	ahmedsaeed@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200021	t	373	Store Helper	\N	f
386	Muhammad Babar 	warehouse@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200022	t	373	Sr. Store Executive	\N	f
387	Saira Ashraf	accounts2@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	212	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200023	t	275	Accounts Executive	\N	f
388	Muhammad Hamza Khan	accounts5@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	212	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200024	t	275	Accounts Officer	\N	f
389	Faizan Khan	promo@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	213	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200027	t	373	Store Executive	\N	f
263	Ammad Shams	ammad.shams@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	211	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100059	t	273	Associate Business Manager	\N	f
60	Hasan Ali	hasanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	64	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000904	t	68	Officer	\N	f
61	Syed Anzal Ali	syedanzalaliflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	64	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000722	t	68	Officer	\N	f
62	Mohsin Akhlas	mohsin.akhlas@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	65	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000114	t	100	Business Unit Manager	\N	f
63	Safi Ullah Wasim	safiullah@flow.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	65	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000812	t	64	Executive	\N	f
64	Emran Farook	emranfarook@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	65	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000565	t	62	Graphic Designer	\N	f
67	Tamanna Qasim	cod.msdz1@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	67	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000170	t	68	Assistant Manager	\N	f
69	Hafeez Ur Rehman	hafeezurrehmanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	67	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000111	t	71	Recovery Officer	\N	f
70	Muhammad Umair	umair.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	67	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000892	t	76	Recovery Officer	\N	f
73	Laiq Zada	Laiqflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000905	t	76	Driver	\N	f
74	Muhammad Qamar	muhammadqamar@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000119	t	46	Driver	\N	f
75	Syed Farooq Azam	syedfarooqazamflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000122	t	76	Driver	\N	f
76	Farhan Jamal	farhan.jamal@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000116	t	200	Senior Supervisor	\N	f
77	Aliyaan	aliyaan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000125	t	76	Worker	\N	f
78	Amjad Ansari	amjadansariflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000120	t	76	Worker	\N	f
79	Arsalan	arsalan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000118	t	76	Worker	\N	f
80	Hafiz Farhan	hafizfarhan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000123	t	76	Worker	\N	f
369	Murad Ali 	murad.ali@matrixpharma.com.pk	$2b$10$GIF1LIM6JkpzsR7Vwqy9Se//QjnpfpNnDRyT.bEZxtRoagQASURtm	2	211	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100225	f	273	Marketing Executive	2026-06-23 12:02:49.368806+05	f
81	Khan Sher	khansher@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000126	t	76	Worker	\N	f
68	Masood Ahmed	masood.ahmed@um.com.pk	$2b$10$/7oC.FJ9brVdbaANqs8x.u8nD.zl/KZGSK/zO3eEQlMQ6Htjzlsqu	1	67	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000113	f	71	Manager	2026-06-29 10:58:20.695187+05	f
243	Irfan Baloch	irfan.baloch@um.com.pk	$2b$10$bvw1Zv3hHZ/PZZbySJFM.uG6Sg3Yk7Qb9xgcp4v.SZJ6X.O8KrJu.	2	94	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000053	f	226	Supervisor	2026-07-06 10:00:46.227054+05	f
239	Ghalib Akhter Saleemi	ghalib.akhter@um.com.pk	$2b$10$jnmHFeEUv5XsQexRYpv5EuMFrgVKG4.aOIpNs27bmLkqVyhxP0wBy	1	92	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000495	f	224	Assistant Manager	2026-06-29 10:03:06.652459+05	f
241	Muhammad Saqib Shamim	saqib.shamim@um.com.pk	$2b$10$9rKpsoirNLtM9j6kvhZ49OB3NBuARm9qjkisGmCNZ7TdHz1zgQZo2	2	93	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000516	f	226	Executive	2026-06-29 11:18:22.543298+05	f
156	Azhan Ahmed Qureshi	azhan.hr@um.com.pk	$2b$10$9e9aV3cHX3q.uq1.msqZXOeThF2gdv1q1oOghtV9/wKjiov25cwyi	2	77	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000734	f	155	Senior Executive	2026-07-01 10:03:45.49272+05	f
175	Muhammad Yaqoob	muhammadyaqoobflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	82	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000376	t	137	Supervisor	\N	f
212	Muhammad Ali Hamza	Ali.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	88	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000766	t	175	Worker	\N	f
285	Hafeez Khan	hafeezkhan@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100097	t	248	Office Boy	\N	f
106	Syed Muhammad Ramiz	syedm.ramizflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000919	t	109	Senior Executive	\N	f
148	Naveed Masih	naveedmasihflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000336	t	113	Sweeper	\N	f
231	Adnan Hafeez	adnanhafeezflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000858	t	76	Worker	\N	f
232	Muhammad Ali	muhammad.aliflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000855	t	76	Worker	\N	f
233	Muhammad Sufyan	m.sufyanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000857	t	76	Worker	\N	f
234	Muhammad Waqar	m.waqarflow.@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000861	t	76	Worker	\N	f
235	Muheet	muheetflow.@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000890	t	76	Worker	\N	f
236	Sameer	sameerflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000853	t	76	Worker	\N	f
237	Tahir Imam Bukhsh	tahirflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000620	t	76	Worker	\N	f
238	Zubair Ahmed	zubairflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000856	t	76	Worker	\N	f
240	Faisal Shahab	faisal.shahab@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	93	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000513	t	226	Deputy Manager	\N	f
242	Hammad Ali	hammadali@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	93	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000902	t	226	Officer	\N	f
244	Muhammad Ramiz Hussain	muhammadramizhussainflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	94	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000519	t	46	Worker	\N	f
245	Sabir Khan	sabirkhan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	94	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000517	t	76	Worker	\N	f
312	Saima Maraj	saimamaraj@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100143	t	299	Documentation Incharge	\N	f
313	Tariq Ali Abbasi	tariqabbasi@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100144	t	299	Sr Operator Liquid Manufacturing	\N	f
246	Sherin Khan	sherinkhan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	94	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000518	t	46	Worker	\N	f
367	Muhammad Zain Siddiqui	zain.siddiqui@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100223	t	318	Deputy Manager QC	\N	f
359	Muhammad Seemab Tariq 	seemab.tariq@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100214	t	318	Assistant Manager Quality Control	\N	f
368	Adnan Zahid 	zahidadnan650@gmail.com	$2b$10$tefBq6vZ/v4WJZ8QS4QMVegFfmM5XBxR/x4tX2AhPJssQbNLttGWK	2	79	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100224	f	264	IT Support Officer	2026-07-14 08:17:06.062515+05	f
349	Fahad 	fahad11@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	207	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100204	t	334	Site Assistant	\N	f
249	Josephine Khurram	hr@matrixpharma.com.pk	$2b$10$0Mijp4sN6BoHf04RFnBhuuTUQCHslDMPo6OiEc8c.Uep18i0bN4B.	1	200	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100003	f	248	Human Resource Manager	2026-06-22 09:45:35.633751+05	f
394	Liaquat Ali Malik	ummalik2@yahoo.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	0	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	300005	t	\N	Director	\N	t
257	Muhammad Musab Ahmed	hrso@matrixpharma.com.pk	$2b$10$u5T9FG.a8B1Wc0Btv3c3XOtRXwpOYRh2pb1mtbGteOGUNk6DcAWHG	1	200	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100025	f	248	Deputy Manager HR	2026-07-06 08:20:29.782235+05	f
250	Imtiaz Hussain	imtiazhussain@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100004	t	301	Senior Product Development Officer	\N	f
248	Muhammad Amir Kaleem	amirkaleem@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100001	t	390	Head Of Operations	\N	f
251	Rizwan Ansari	ra44779900@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	202	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100006	t	248	Purchase Officer	\N	f
252	Ayesha Gulfam	ayesha.gulfam@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	203	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100007	t	273	Senior Officer Digital Marketing	\N	f
253	Sharmeen Sarwat	sharmeengr8@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	204	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100008	t	273	Deputy Manager CD	\N	f
254	Waqas Ahmed	sas@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	205	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100010	t	272	Deputy Manager Business Analysis	\N	f
255	Mehwish Taj	Mehwish.taj@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	206	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100019	t	390	Senior Manager BD	\N	f
256	Bakhtawar Faheem	bakhtawar@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	207	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100024	t	334	Projects Executive	\N	f
258	Zahid Ali Siddiqui	zahidalisiddique342@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	208	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100031	t	372	Senior Field Executive	\N	f
259	Adeel Baig	sales.report@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	209	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100032	t	375	Marketing Executive	\N	f
271	Abdul Rehman	abdulrehman.25j96@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	207	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100075	t	334	Assistant SITE Supervisor	\N	f
390	Sameer Liaquat Malik	sameer@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	0	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	300001	t	394	Director	\N	f
391	Laraib Malik	laraib.malik@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	206	1	t	2026-06-15 13:05:25.698127+05	\N	\N	300002	t	390	Business Development Executive	\N	f
392	Iman Liaquat Malik	iman.malik@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	206	1	t	2026-06-15 13:05:25.698127+05	\N	\N	300003	t	390	Business Development Executive	\N	f
393	Ayzza Liaquat Malik	ayzzamalik@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	206	1	t	2026-06-15 13:05:25.698127+05	\N	\N	300004	t	390	Business Development Executive	\N	f
395	Samreen Liaquat Malik	samreena934@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	1	f	2026-06-15 13:05:25.698127+05	\N	\N	300006	t	394	Advisor To CEO	\N	f
\.


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1155, true);


--
-- Name: sub_ticket_departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sub_ticket_departments_id_seq', 1, false);


--
-- Name: ticket_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ticket_comments_id_seq', 151, true);


--
-- Name: ticket_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ticket_logs_id_seq', 606, true);


--
-- Name: ticket_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ticket_number_seq', 75, true);


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tickets_id_seq', 146, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 405, true);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: companies companies_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_slug_key UNIQUE (slug);


--
-- Name: departments departments_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_code_key UNIQUE (code);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sub_ticket_departments sub_ticket_departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_ticket_departments
    ADD CONSTRAINT sub_ticket_departments_pkey PRIMARY KEY (id);


--
-- Name: sub_ticket_departments sub_ticket_departments_ticket_id_department_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_ticket_departments
    ADD CONSTRAINT sub_ticket_departments_ticket_id_department_id_key UNIQUE (ticket_id, department_id);


--
-- Name: ticket_comments ticket_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_comments
    ADD CONSTRAINT ticket_comments_pkey PRIMARY KEY (id);


--
-- Name: ticket_logs ticket_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_logs
    ADD CONSTRAINT ticket_logs_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_notifications; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications ON public.notifications USING btree (user_id, is_read);


--
-- Name: idx_sub_ticket_dept; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sub_ticket_dept ON public.sub_ticket_departments USING btree (ticket_id);


--
-- Name: idx_sub_ticket_dept_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sub_ticket_dept_id ON public.sub_ticket_departments USING btree (department_id);


--
-- Name: idx_tickets_creator; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tickets_creator ON public.tickets USING btree (created_by_id);


--
-- Name: idx_tickets_dept; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tickets_dept ON public.tickets USING btree (assigned_dept_id);


--
-- Name: idx_tickets_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tickets_status ON public.tickets USING btree (status);


--
-- Name: idx_tickets_sub; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tickets_sub ON public.tickets USING btree (is_sub_ticket);


--
-- Name: sub_ticket_departments sub_ticket_departments_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER sub_ticket_departments_updated_at BEFORE UPDATE ON public.sub_ticket_departments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: tickets tickets_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tickets_updated_at BEFORE UPDATE ON public.tickets FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: departments departments_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: departments departments_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.departments(id);


--
-- Name: notifications notifications_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: sub_ticket_departments sub_ticket_departments_assigned_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_ticket_departments
    ADD CONSTRAINT sub_ticket_departments_assigned_to_id_fkey FOREIGN KEY (assigned_to_id) REFERENCES public.users(id);


--
-- Name: sub_ticket_departments sub_ticket_departments_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_ticket_departments
    ADD CONSTRAINT sub_ticket_departments_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: sub_ticket_departments sub_ticket_departments_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sub_ticket_departments
    ADD CONSTRAINT sub_ticket_departments_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id) ON DELETE CASCADE;


--
-- Name: ticket_comments ticket_comments_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_comments
    ADD CONSTRAINT ticket_comments_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id) ON DELETE CASCADE;


--
-- Name: ticket_comments ticket_comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_comments
    ADD CONSTRAINT ticket_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ticket_logs ticket_logs_acted_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_logs
    ADD CONSTRAINT ticket_logs_acted_by_id_fkey FOREIGN KEY (acted_by_id) REFERENCES public.users(id);


--
-- Name: ticket_logs ticket_logs_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket_logs
    ADD CONSTRAINT ticket_logs_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id) ON DELETE CASCADE;


--
-- Name: tickets tickets_assigned_dept_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_assigned_dept_id_fkey FOREIGN KEY (assigned_dept_id) REFERENCES public.departments(id);


--
-- Name: tickets tickets_assigned_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_assigned_to_id_fkey FOREIGN KEY (assigned_to_id) REFERENCES public.users(id);


--
-- Name: tickets tickets_closed_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_closed_by_id_fkey FOREIGN KEY (closed_by_id) REFERENCES public.users(id);


--
-- Name: tickets tickets_created_by_dept_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_created_by_dept_fkey FOREIGN KEY (created_by_dept) REFERENCES public.departments(id);


--
-- Name: tickets tickets_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: tickets tickets_parent_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_parent_ticket_id_fkey FOREIGN KEY (parent_ticket_id) REFERENCES public.tickets(id) ON DELETE CASCADE;


--
-- Name: tickets tickets_transferred_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_transferred_from_fkey FOREIGN KEY (transferred_from) REFERENCES public.departments(id);


--
-- Name: users users_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: users users_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: users users_reports_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_reports_to_fkey FOREIGN KEY (reports_to) REFERENCES public.users(id);


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict ius0151wqx0BQXW0mDaXt051MUWBp1b63qjIxMX0Zob4DhFATataOQUeBKbR68Q

