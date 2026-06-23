--
-- PostgreSQL database dump
--

\restrict bv2Hc6hdQea8xH0DvmnuvuAIPPfqRSIXLUrPB7baO2AoEKtzWXpW8wN086RSsYg

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
329	156	9	New Ticket Created: Draft an experience letter for MR. QASIM	f	2026-06-20 12:29:25.814392+05
330	390	9	New Ticket Created: Draft an experience letter for MR. QASIM	f	2026-06-20 12:29:25.814392+05
331	153	9	New Ticket Created: Draft an experience letter for MR. QASIM	f	2026-06-20 12:29:25.814392+05
333	344	9	New Ticket Created: Draft an experience letter for MR. QASIM	f	2026-06-20 12:29:25.814392+05
334	157	9	New Ticket Created: Draft an experience letter for MR. QASIM	f	2026-06-20 12:29:25.814392+05
335	154	9	New Ticket Created: Draft an experience letter for MR. QASIM	f	2026-06-20 12:29:25.814392+05
344	394	9	Ticket #9 status changed to completed	f	2026-06-20 12:31:11.888151+05
345	156	9	Ticket #9 status changed to completed	f	2026-06-20 12:31:11.888151+05
346	390	9	Ticket #9 status changed to completed	f	2026-06-20 12:31:11.888151+05
347	153	9	Ticket #9 status changed to completed	f	2026-06-20 12:31:11.888151+05
349	344	9	Ticket #9 status changed to completed	f	2026-06-20 12:31:11.888151+05
350	154	9	Ticket #9 status changed to completed	f	2026-06-20 12:31:11.888151+05
332	155	9	New Ticket Created: Draft an experience letter for MR. QASIM	t	2026-06-20 12:29:25.814392+05
348	155	9	Ticket #9 status changed to completed	t	2026-06-20 12:31:11.888151+05
63	155	4	New Ticket Created: LCD Display Problem	t	2026-06-20 11:04:44.254008+05
80	155	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	t	2026-06-20 11:09:05.77505+05
358	394	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
359	162	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
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
371	165	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
372	303	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
373	274	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
374	163	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
375	168	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
376	167	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
377	312	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
378	340	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
379	317	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
380	342	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
381	368	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
382	339	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
383	326	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
384	166	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
385	344	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
386	336	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
387	308	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
388	313	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
389	164	11	New Ticket Created: Team view	f	2026-06-20 15:33:04.755787+05
53	394	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
54	162	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
55	156	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
56	390	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
57	153	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
58	165	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
59	274	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
60	163	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
61	168	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
62	167	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
64	368	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
65	166	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
66	344	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
67	157	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
68	164	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
69	154	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
70	264	4	New Ticket Created: LCD Display Problem	f	2026-06-20 11:04:44.254008+05
71	394	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
72	162	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
73	156	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
74	390	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
75	153	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
76	274	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
77	163	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
78	168	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
79	167	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
81	368	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
82	166	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
83	344	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
84	157	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
85	164	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
86	154	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
87	264	4	Ticket #4 self-assigned by Muhammad Fashi Ullah Khan	f	2026-06-20 11:09:05.77505+05
88	394	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
89	162	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
90	156	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
91	390	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
92	153	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
93	274	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
94	163	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
95	168	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
96	167	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
98	368	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
99	166	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
100	344	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
101	157	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
102	164	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
103	154	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
104	264	4	Ticket #4 status changed to completed	f	2026-06-20 11:09:23.789228+05
105	394	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
106	162	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
107	156	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
108	390	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
109	153	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
110	274	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
111	163	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
112	168	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
113	167	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
115	368	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
116	166	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
117	344	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
118	157	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
119	164	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
120	154	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
121	264	4	Ticket #4 status changed to closed	f	2026-06-20 11:09:35.468387+05
336	157	9	You have been assigned to Ticket #9	f	2026-06-20 12:29:26.052285+05
337	394	9	Adnan Najeeb commented on Ticket #9	f	2026-06-20 12:30:08.628711+05
338	156	9	Adnan Najeeb commented on Ticket #9	f	2026-06-20 12:30:08.628711+05
339	390	9	Adnan Najeeb commented on Ticket #9	f	2026-06-20 12:30:08.628711+05
340	153	9	Adnan Najeeb commented on Ticket #9	f	2026-06-20 12:30:08.628711+05
341	344	9	Adnan Najeeb commented on Ticket #9	f	2026-06-20 12:30:08.628711+05
342	157	9	Adnan Najeeb commented on Ticket #9	f	2026-06-20 12:30:08.628711+05
343	154	9	Adnan Najeeb commented on Ticket #9	f	2026-06-20 12:30:08.628711+05
97	155	4	Ticket #4 status changed to completed	t	2026-06-20 11:09:23.789228+05
114	155	4	Ticket #4 status changed to closed	t	2026-06-20 11:09:35.468387+05
351	394	9	Ticket #9 status changed to closed	f	2026-06-20 12:34:56.296398+05
352	156	9	Ticket #9 status changed to closed	f	2026-06-20 12:34:56.296398+05
353	390	9	Ticket #9 status changed to closed	f	2026-06-20 12:34:56.296398+05
354	153	9	Ticket #9 status changed to closed	f	2026-06-20 12:34:56.296398+05
355	344	9	Ticket #9 status changed to closed	f	2026-06-20 12:34:56.296398+05
356	157	9	Ticket #9 status changed to closed	f	2026-06-20 12:34:56.296398+05
357	154	9	Ticket #9 status changed to closed	f	2026-06-20 12:34:56.296398+05
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
404	162	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
405	390	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
406	165	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
407	274	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
408	163	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
409	168	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
410	167	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
411	368	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
412	166	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
413	344	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
414	164	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
415	1	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
416	264	15	New Ticket Created: Implementation	f	2026-06-22 11:20:01.818228+05
417	394	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
418	162	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
419	314	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
420	341	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
421	299	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
422	330	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
423	309	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
424	390	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
425	311	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
426	286	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
427	338	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
428	310	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
429	315	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
430	165	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
431	303	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
432	274	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
433	168	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
434	167	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
435	312	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
436	340	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
437	317	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
438	342	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
439	368	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
440	339	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
441	326	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
442	166	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
443	344	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
444	336	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
445	308	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
446	313	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
447	164	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
448	264	11	Ticket #11 status changed to completed	f	2026-06-22 11:54:06.702537+05
449	394	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
450	162	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
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
462	165	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
463	303	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
464	274	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
465	168	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
466	167	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
467	312	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
468	340	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
469	317	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
470	342	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
471	368	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
472	339	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
473	326	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
474	166	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
475	344	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
476	336	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
477	308	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
478	313	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
479	164	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
480	264	11	Ticket #11 status changed to closed	f	2026-06-22 11:54:19.501086+05
481	394	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
482	162	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
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
493	165	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
494	303	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
495	274	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
496	163	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
497	168	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
498	167	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
499	312	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
500	340	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
501	317	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
502	342	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
503	368	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
504	339	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
505	326	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
506	166	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
507	344	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
508	336	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
509	308	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
510	313	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
511	164	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
512	264	10	Ticket #10 status changed to completed	f	2026-06-22 11:54:37.837099+05
513	394	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
514	162	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
515	314	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
516	341	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
517	330	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
518	309	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
519	390	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
520	311	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
521	286	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
522	338	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
523	310	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
524	315	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
525	165	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
526	303	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
527	274	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
528	163	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
529	168	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
530	167	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
531	312	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
532	340	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
533	317	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
534	342	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
535	368	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
536	339	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
537	326	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
538	166	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
539	344	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
540	336	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
541	308	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
542	313	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
543	164	10	Ticket #10 status changed to closed	f	2026-06-22 11:55:07.825521+05
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
602	144	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
603	363	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
604	327	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
605	118	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
606	133	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
607	111	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
608	123	19	New Ticket Created: insectecuter, AC not working	f	2026-06-22 12:38:44.700162+05
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
807	153	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
808	165	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
809	274	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
810	163	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
811	168	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
812	167	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
813	155	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
814	368	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
815	344	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
816	157	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
817	154	3	Azhan Ahmed Qureshi commented on Ticket #3	f	2026-06-22 15:36:42.601662+05
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
857	153	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
858	165	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
859	274	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
860	163	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
861	168	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
862	167	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
863	155	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
864	368	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
865	344	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
866	157	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
867	154	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
868	264	3	Ticket #3 status changed to completed	f	2026-06-23 11:59:13.726715+05
869	394	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
870	390	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
871	153	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
872	165	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
873	274	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
874	163	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
875	168	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
876	167	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
877	155	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
878	368	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
879	344	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
880	157	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
881	154	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
882	264	3	Ticket #3 status changed to closed	f	2026-06-23 11:59:25.52165+05
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
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tickets (id, title, description, status, priority, created_by_id, created_by_dept, assigned_dept_id, assigned_to_id, transferred_from, transferred_at, closed_by_id, closed_at, reopened_at, reopen_count, due_date, is_sub_ticket, parent_ticket_id, ticket_type, overall_progress, created_at, updated_at, ticket_number, reset_token, is_standard_ticket, is_multi_ticket, closed_label) FROM stdin;
14	Project: Implementation	Master oversight for: There is no need for  the originator to close the ticket. It should be automatically closed once it is resolved by the resolver.	in_progress	high	168	79	79	168	\N	\N	\N	\N	\N	0	\N	f	\N	standard	0	2026-06-22 11:20:01.791294+05	2026-06-22 11:20:01.791294+05	UMP-TKQ-008	\N	f	f	\N
15	Implementation	There is no need for  the originator to close the ticket. It should be automatically closed once it is resolved by the resolver.	open	high	168	79	100	\N	\N	\N	\N	\N	\N	0	\N	t	14	standard	0	2026-06-22 11:20:01.803378+05	2026-06-22 11:20:01.803378+05	UMP-TKQ-008-SUB-001	\N	f	f	\N
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
157	Muhammad Sufiyan	sufiyan.hr@um.com.pk	$2b$10$rW1uP4IKVtwP2BPLJSqM8uO4JD1WvD.hDiyzNMJa96r310FfjUj/a	2	77	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000813	f	155	Senior Executive	2026-06-23 11:18:25.918872+05	f
1	Qasim	qasim@um.com	$2b$10$l229ufLzJfZTixGmtEku5.gHBijE1YbCX/Ojncx5x7CNgHi49TxUG	3	100	0	t	2026-06-15 12:53:54.138375+05	\N	\N	ADMIN001	f	\N	\N	2026-06-23 18:40:04.343143+05	f
163	Muhammad Qasim Mehmood	Qasim.flow@um.com.pk	$2b$10$ZQ1RIHPP.Rf9KYadMkauBuzqhwoiqgj2fcrfouUpp3Rj.KWoHagrm	2	79	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000920	f	164	Business Application Developer	2026-06-23 19:59:47.043754+05	f
376	Wajahat Ali Khan	waji@matrixpharma.com.pk	$2b$10$IhS3yPLIhCis6AqLQRYLZuazGu2bDOyFIe1uUhSnPjwkT42JIsxGK	1	202	1	t	2026-06-15 13:05:25.698127+05	\N	\N	200007	f	248	Deputy Manager Procurement	2026-06-23 11:15:59.147082+05	f
26	Syed Muhammed Khaliq Uzzaman	khaliq@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	55	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000016	t	38	Manager	\N	f
27	Haider Ali	haider.ali@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	55	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000019	t	25	Officer	\N	f
28	Muhammad Zeeshan Khan	m.zeeshan.@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	56	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000739	t	39	Assistant	\N	f
29	Muhammad Faizan	doc@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	57	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000022	t	31	Assistant Manager	\N	f
31	Khawaja Aleem Shah	cr@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	57	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000021	t	100	Senior Manager	\N	f
32	Kosain Hanif	coordinator.fa@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	58	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000050	t	153	Senior Executive	\N	f
33	Muhammad Saad	procurement.fa@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	59	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000610	t	100	Manager	\N	f
34	Muhammad Uzair	uzair.saeed@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	60	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000048	t	38	Assistant Manager	\N	f
35	Muhammad Qamar Khan	oaf@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	60	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000632	t	198	Coordinator	\N	f
36	Muhammad Ammar Waseem	ammar.waseem@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	60	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000047	t	38	Officer	\N	f
37	Muhammad Sarfaraz Hussain	sarfaraz.hussain@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	60	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000046	t	38	Senior Executive	\N	f
38	Kabeer Alam	kabeer.alam@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	60	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000045	t	100	Senior Manager	\N	f
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
65	Akber Mughal	stats.fm@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	66	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000168	t	62	Assistant Manager	\N	f
327	Maryam Zehra	mariam@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100175	t	318	Quality Control Officer	\N	f
56	Sadiq Ali	sadiqali@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000066	t	46	Worker	\N	f
57	Wazeer Muhammad	wazeermuhammad@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	62	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000052	t	46	Worker	\N	f
58	Muhammad Zohaib Soomro	mzohaib@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	63	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000068	t	62	Assistant Manager	\N	f
59	Ahmed Sohaib	ahmed.sohaib@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	63	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000069	t	62	Product Manager	\N	f
82	Muhammad Farhan	muhammadfarhanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000124	t	76	Worker	\N	f
83	Muhammad Sohail	muhammad.sohail@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000064	t	76	Worker	\N	f
84	Muhammad Waseem Aslam	muhammadwaseemaslamflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000387	t	76	Worker	\N	f
85	Rehan Uddin Siddiqui	rehanuddinsiddiquiflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000117	t	76	Worker	\N	f
87	Sarfaraz Owais Siddiqui	sarfraz.owais@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	69	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000129	t	62	Senior Product Manager	\N	f
88	Muhammad Arsalan Irshad	arsalan.irshad.msd@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	70	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000171	t	68	Executive	\N	f
89	Muhammad Noshad Gull	noshad.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	70	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000913	t	68	Senior Officer	\N	f
90	Syed Kashif Nayyar Ahmed Jilani	vaccination.services@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	71	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000169	t	71	Assistant Manager	\N	f
91	Muhammad Fahad	m.fahadflow@gmail.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	71	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000723	t	71	Officer	\N	f
92	Nauman Haider Siddiqui	nauman.siddiqui@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	72	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000551	t	62	Product Manager	\N	f
93	Hafiz Humayun Khan	humayun.khan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	72	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000067	t	62	Senior Executive	\N	f
30	Zehrish	doc2@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	57	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000023	t	31	Executive	\N	f
94	Muhammad Hunain	m.hunainflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	73	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000903	t	68	Officer	\N	f
95	Muhammad Hussain	hussainflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	73	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000886	t	68	Officer	\N	f
96	Ali Inayat	ali.inayat@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000277	t	104	Assistant Manager	\N	f
97	Muhammad Siraj	muhammad.siraj@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000269	t	104	Assistant Manager	\N	f
98	Muhammad Zaki Uddin Farooqui	zaki@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000261	t	108	Assistant Manager	\N	f
99	Tariq Ali Khan	tariq.khan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000265	t	104	Assistant Manager	\N	f
101	Shah Fahad Khan	shahfahad@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000266	t	104	Deputy Manager	\N	f
102	Muhammad Ziyad Ashrafi	ziyad.ashrafi@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000279	t	108	Executive	\N	f
103	Syed Adeel Mashkoor	adeel.mashkoor@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000273	t	104	Executive	\N	f
104	Muhammad Arsalan	muhammad.arsalan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000276	t	100	Head Of Department	\N	f
105	Muhammad Umer Farooq	umer.farooq@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000275	t	104	Officer	\N	f
71	Syed Mohsin Hasan	Mohsin.hassan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	67	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000112	t	62	Senior Manager	\N	f
107	Wajahat Ullah Khan	wajahatullah@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000274	t	104	Senior Executive	\N	f
108	Shabbir	shabbir.hussain@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000270	t	100	Senior Manager	\N	f
109	Sheraz Ahmad	sheraz.ahmad@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	74	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000262	t	100	Senior Manager	\N	f
110	Muhammad Hamid	hamidflow.@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000889	t	138	Ac Technician	\N	f
111	Kumail Arif	kumail.arif@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000287	t	113	Assistant	\N	f
112	Muhammad Yaqoob Chohan	yaqoobchohanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000301	t	137	Caretaker	\N	f
113	Muhammad Owais Raza	owais.raza@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000284	t	137	Deputy Manager	\N	f
114	Chanzeb	chanzebflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000348	t	152	Driver	\N	f
115	Muhammad Aslam	muhammadaslamflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000303	t	138	Electrician	\N	f
116	Abdul Rehman	abdurrehman@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000314	t	137	Executive	\N	f
122	Syed Wasi Hassan	syedwasihassan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000292	t	\N	\N	\N	f
165	Muhammad Fashi Ullah Khan	it.support@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	79	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000368	t	168	Executive	\N	f
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
138	Kamran	kamran.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000726	t	137	Supervisor	\N	f
139	Anwar	anwar.manzoor@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000763	t	113	Sweeper	\N	f
140	Ashfaq Gill	Ashfaqgillflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000628	t	113	Sweeper	\N	f
141	Imran Ayoub	imranayoub@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000304	t	113	Sweeper	\N	f
142	Imran Pervez	imranpervezflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000313	t	113	Sweeper	\N	f
143	Johnson	johnsonjozafflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000291	t	113	Sweeper	\N	f
144	Johnson	johnson@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000353	t	175	Sweeper	\N	f
145	Kalsey Dona	kalseydona@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000340	t	113	Sweeper	\N	f
146	Kashif	Kashiflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000550	t	113	Sweeper	\N	f
147	Munir Bashir	munirbashirflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000293	t	113	Sweeper	\N	f
137	Syed Rameez Hussain	rameez.hussain@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000371	t	153	Senior Manager	\N	f
149	Sehoon Joseph	sehoon.joseph@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000764	t	113	Sweeper	\N	f
151	Muhammad Saqib	muhammadsaqib@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000300	t	138	Worker	\N	f
152	Muhammad Shahid Siddiqui	ss@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	76	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000357	t	100	Head Of Department	\N	f
153	Farhan Saghir	farhan.saghir@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	77	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000822	t	153	Head Of Department	\N	f
158	Zia ul Hassan	zia@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	78	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000364	t	39	Deputy Manager	\N	f
159	Amna Khan	amna.khan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	78	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000363	t	39	Executive	\N	f
160	Talha Bashir	talhabashir@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	78	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000362	t	39	Rider	\N	f
123	Huraira Khan	huraira.khan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	75	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000306	t	137	Officer	\N	f
161	Muhammad Asad Sheikh	import.doc@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	78	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000528	t	39	Senior Executive	\N	f
167	Muhammad Yahya Ajmal	yahyaajmalflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	79	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000657	t	168	Junior Assistant	\N	f
169	Shahzad Riaz	shahzadriaz@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	80	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000013	t	153	Manager	\N	f
170	Mohsin Ahmed Chohan	mohsin.chohan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	81	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000373	t	100	Officer	\N	f
171	Naveed Ahmed	naveedahmed@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	81	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000372	t	100	Rider	\N	f
172	Mohammad Farhan	mohammad.farhan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	81	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000375	t	100	Senior Executive	\N	f
166	Muhammad Hamza Khan	mhamzakhan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	220	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000641	t	100	Executive	\N	f
168	Dilawar Farrukh Rauf	farrukh.rauf@um.com.pk	$2b$10$gk1VOWj0v9wqlDtKtgIiCOASN9z035oi0IBXrdC5I16NujPLendEG	1	79	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000365	f	100	Senior Manager	2026-06-23 18:36:40.905745+05	f
162	Faraz	faraz.hanif@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	220	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000366	t	100	Assistant Manager	\N	f
164	Bilal Ahmed	bilal.ahmed@um.com.pk	$2b$10$s6sw3btsPnKjDnf4rv1sNO93ZER6LT97YBzFZZkut0c3nHmQrlZ/i	1	220	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000369	f	100	Deputy Manager	2026-06-22 16:25:28.14001+05	f
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
154	Muhammad Rasheed	rasheed.hr@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	77	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000359	t	155	Junior Assistant	\N	f
189	Shiraz	shiraz.silas@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	83	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000826	t	187	Officer	\N	f
190	Muhammad Raheel Abbasi	muhammad.raheel@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	83	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000398	t	186	Senior Executive	\N	f
191	Abdul Qayoom	abdulqayoomflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000718	t	194	Caretaker	\N	f
192	Mehtab Ali	mehtabaliflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000288	t	194	Caretaker	\N	f
193	Hunain Ali	hunain.ali@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000025	t	194	Coordinator	\N	f
194	Muhammad Sami Khan	sami.khan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000131	t	20	Manager	\N	f
195	Miraal Javed	miraalflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000693	t	194	Officer	\N	f
155	Adnan Najeeb	adnan.hr@um.com.pk	$2b$10$62.fkQdGI0Kggd8c/n9XW.2gX2IETobw373/aYKG3fFiOdZKoUXh2	1	77	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000358	f	153	Manager	2026-06-20 12:25:27.399177+05	f
196	Naima Mukhtar	Naimaflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000698	t	194	Officer	\N	f
197	Khizer Ur Rehman Khan Ghori	khizerflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	84	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000796	t	194	Senior Officer	\N	f
198	Muhammad Sohail	pa.im@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	85	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000401	t	100	Assistant to Director	\N	f
199	Muhammad Shamim Azim	azim@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	85	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000400	t	100	Senior Liaison Officer	\N	f
200	Sarfaraz Ahmed Khan	sarfaraz.ahmed@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	86	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000409	t	153	Manager	\N	f
274	Atta Ur Rehman 	it.support@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	79	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100079	t	264	IT Officer	\N	f
20	Abdul Wasay Malik	wasaymalik@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	52	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000011	t	153	Deputy Business Unit Head	\N	f
201	Fazal ur Rehman Khan	pkg.store@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	86	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000408	t	200	Supervisor	\N	f
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
223	Hamza Ali Khan	hamza.khan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	90	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000492	t	224	Assistant Manager	\N	f
224	Ammar Malik	boviteam@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	90	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000490	t	153	Business Unit Head	\N	f
225	Muhammad Aziz Ur Rehman	cod.la@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	90	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000493	t	226	Deputy Manager	\N	f
226	Muhammad Waqas Saleem	waqas.saleem@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	90	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000491	t	224	Manager	\N	f
227	Sufyan Malik	cod.la2@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	90	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000494	t	226	Officer	\N	f
228	Syed Muzammil Ali	muzammilflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000852	t	76	Officer	\N	f
229	Abdul Muqeet	abdulflow.@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000742	t	76	Worker	\N	f
230	Abdul Wahab	abdul.wahabflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	91	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000854	t	76	Worker	\N	f
260	Waqar Ahmed Abbasi	wqr.abbasi@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	210	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100033	t	273	Senior Business Manager	\N	f
261	Saima Khalil	saimasaima008763@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100041	t	248	Import Officer	\N	f
86	Khalid Gulab	khalid@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	69	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000128	t	62	Assistant Manager	\N	f
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
25	Sheikh Shahbaz Akhtar	shahbaz.akhtar@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	55	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000018	t	38	Assistant Manager	\N	f
66	Owais Najam	owais.najam@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	67	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000115	t	68	Assistant Manager	\N	f
247	Fareed Ahmed Soomro	cod.la3@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	95	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000797	t	226	Deputy Manager	\N	f
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
348	Maheen Asif	maheen@matrixpharma.com.pk	$2b$10$Q/UV5uckOj10D0jkjoEZouIe.jKp2qKanEA0jApjLSQWSPh.uKmFi	2	215	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100203	f	301	Quality Assurance Officer	2026-06-20 13:38:03.814343+05	f
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
68	Masood Ahmed	masood.ahmed@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	67	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000113	t	71	Manager	\N	f
69	Hafeez Ur Rehman	hafeezurrehmanflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	67	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000111	t	71	Recovery Officer	\N	f
70	Muhammad Umair	umair.flow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	67	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000892	t	76	Recovery Officer	\N	f
72	Abdul Jabbar Khan	abdul.jabbar@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	68	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000121	t	76	Assistant	\N	f
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
156	Azhan Ahmed Qureshi	azhan.hr@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	77	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000734	t	155	Senior Executive	\N	f
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
239	Ghalib Akhter Saleemi	ghalib.akhter@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	92	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000495	t	224	Assistant Manager	\N	f
240	Faisal Shahab	faisal.shahab@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	93	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000513	t	226	Deputy Manager	\N	f
241	Muhammad Saqib Shamim	saqib.shamim@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	93	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000516	t	226	Executive	\N	f
242	Hammad Ali	hammadali@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	93	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000902	t	226	Officer	\N	f
243	Irfan Baloch	irfan.baloch@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	94	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000053	t	226	Supervisor	\N	f
244	Muhammad Ramiz Hussain	muhammadramizhussainflow@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	94	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000519	t	46	Worker	\N	f
245	Sabir Khan	sabirkhan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	94	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000517	t	76	Worker	\N	f
312	Saima Maraj	saimamaraj@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100143	t	299	Documentation Incharge	\N	f
313	Tariq Ali Abbasi	tariqabbasi@mp.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	214	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100144	t	299	Sr Operator Liquid Manufacturing	\N	f
246	Sherin Khan	sherinkhan@um.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	94	0	t	2026-06-15 13:05:18.748213+05	\N	\N	10000518	t	46	Worker	\N	f
368	Adnan Zahid 	zahidadnan650@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	79	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100224	t	264	IT Support Officer	\N	f
367	Muhammad Zain Siddiqui	zain.siddiqui@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100223	t	318	Deputy Manager QC	\N	f
359	Muhammad Seemab Tariq 	seemab.tariq@matrixpharma.com.pk	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	1	201	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100214	t	318	Assistant Manager Quality Control	\N	f
349	Fahad 	fahad11@gmail.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	2	207	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100204	t	334	Site Assistant	\N	f
249	Josephine Khurram	hr@matrixpharma.com.pk	$2b$10$0Mijp4sN6BoHf04RFnBhuuTUQCHslDMPo6OiEc8c.Uep18i0bN4B.	1	200	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100003	f	248	Human Resource Manager	2026-06-22 09:45:35.633751+05	f
257	Muhammad Musab Ahmed	hrso@matrixpharma.com.pk	$2b$10$u5T9FG.a8B1Wc0Btv3c3XOtRXwpOYRh2pb1mtbGteOGUNk6DcAWHG	1	200	1	t	2026-06-15 13:05:25.698127+05	\N	\N	100025	f	248	Deputy Manager HR	2026-06-23 08:12:35.176079+05	f
394	Liaquat Ali Malik	ummalik2@yahoo.com	$2b$10$.hDG7BIFnsStYfXU7x2beuuafWsEtNLtkFF2uLcbAXRDG8ZHh.Aqe	0	50	1	t	2026-06-15 13:05:25.698127+05	\N	\N	300005	t	\N	Director	\N	t
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

SELECT pg_catalog.setval('public.notifications_id_seq', 882, true);


--
-- Name: sub_ticket_departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sub_ticket_departments_id_seq', 1, false);


--
-- Name: ticket_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ticket_comments_id_seq', 22, true);


--
-- Name: ticket_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ticket_logs_id_seq', 99, true);


--
-- Name: ticket_number_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ticket_number_seq', 10, true);


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tickets_id_seq', 19, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 395, true);


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

\unrestrict bv2Hc6hdQea8xH0DvmnuvuAIPPfqRSIXLUrPB7baO2AoEKtzWXpW8wN086RSsYg

