--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3
-- Dumped by pg_dump version 15.3

-- Started on 2025-05-21 10:32:19

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
-- TOC entry 227 (class 1255 OID 105438)
-- Name: clientphone(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.clientphone() RETURNS text
    LANGUAGE sql
    AS $$
select email from clients
$$;


ALTER FUNCTION public.clientphone() OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 105484)
-- Name: log_client_changes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_client_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO Clients_Audit(operation, client_id, changed_by, new_data)
        VALUES ('INSERT', NEW.client_id, current_user, to_jsonb(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO Clients_Audit(operation, client_id, changed_by, old_data, new_data)
        VALUES ('UPDATE', NEW.client_id, current_user, to_jsonb(OLD), to_jsonb(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO Clients_Audit(operation, client_id, changed_by, old_data)
        VALUES ('DELETE', OLD.client_id, current_user, to_jsonb(OLD));
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.log_client_changes() OWNER TO postgres;

--
-- TOC entry 229 (class 1255 OID 105448)
-- Name: soldsale(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.soldsale() RETURNS text
    LANGUAGE sql
    AS $$
select saledate from soldtrips
$$;


ALTER FUNCTION public.soldsale() OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 105447)
-- Name: toursdate(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.toursdate() RETURNS text
    LANGUAGE sql
    AS $$
select descrition from tours
$$;


ALTER FUNCTION public.toursdate() OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 105470)
-- Name: update_tour_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_tour_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Обновляем статус тура на 'Продан' при добавлении в SoldTrips
    UPDATE Tours
    SET status = 'Sold'
    WHERE tour_id = NEW.tour_id;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_tour_status() OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 105472)
-- Name: validate_employee_commission(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_employee_commission() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    tour_price DECIMAL(10,2);
    max_commission DECIMAL(10,2);
BEGIN
    -- Получаем цену тура
    SELECT price INTO tour_price
    FROM Tours
    WHERE tour_id = NEW.tour_id;
    
    -- Рассчитываем максимально допустимую комиссию (10% от цены тура)
    max_commission := tour_price * 0.1;
    
    -- Проверяем, что комиссия не превышает допустимый предел
    IF NEW.commission > max_commission THEN
        RAISE EXCEPTION 'Комиссия сотрудника не может превышать 10%% от стоимости тура (Максимум: %)', max_commission;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validate_employee_commission() OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 105468)
-- Name: validate_sale_date(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_sale_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    tour_start_date DATE;
BEGIN
    -- Получаем дату начала тура
    SELECT start_date INTO tour_start_date
    FROM Tours
    WHERE tour_id = NEW.tour_id;
    
    -- Проверяем, что продажа оформлена не позднее чем за 3 дня до начала тура
    IF NEW.sale_date > (tour_start_date - INTERVAL '3 days') THEN
        RAISE EXCEPTION 'Продажа тура должна быть оформлена минимум за 3 дня до его начала';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validate_sale_date() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 221 (class 1259 OID 80807)
-- Name: empoyees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.empoyees (
    id_employees integer NOT NULL,
    "FullName" character varying(255) NOT NULL,
    "Position" character varying(100) NOT NULL,
    "Email" character varying(100) NOT NULL
);


ALTER TABLE public.empoyees OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 80806)
-- Name: Empoyees_id_employees_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Empoyees_id_employees_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Empoyees_id_employees_seq" OWNER TO postgres;

--
-- TOC entry 3394 (class 0 OID 0)
-- Dependencies: 220
-- Name: Empoyees_id_employees_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Empoyees_id_employees_seq" OWNED BY public.empoyees.id_employees;


--
-- TOC entry 223 (class 1259 OID 80814)
-- Name: salesoperations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salesoperations (
    id_operation integer NOT NULL,
    "OperationDate" date NOT NULL,
    "Note" text NOT NULL,
    id_sold_trip integer,
    id_employee integer
);


ALTER TABLE public.salesoperations OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 80813)
-- Name: SalesOperations_id_operation_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."SalesOperations_id_operation_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."SalesOperations_id_operation_seq" OWNER TO postgres;

--
-- TOC entry 3395 (class 0 OID 0)
-- Dependencies: 222
-- Name: SalesOperations_id_operation_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."SalesOperations_id_operation_seq" OWNED BY public.salesoperations.id_operation;


--
-- TOC entry 219 (class 1259 OID 80800)
-- Name: soldtrips; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.soldtrips (
    id_sold_trip integer NOT NULL,
    saledate date NOT NULL,
    "TotalCost" integer NOT NULL,
    "PaymentsValue" character varying(50) NOT NULL,
    id_client integer,
    id_tour integer
);


ALTER TABLE public.soldtrips OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 80799)
-- Name: Soldtrips_id_sold_trip_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Soldtrips_id_sold_trip_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Soldtrips_id_sold_trip_seq" OWNER TO postgres;

--
-- TOC entry 3396 (class 0 OID 0)
-- Dependencies: 218
-- Name: Soldtrips_id_sold_trip_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Soldtrips_id_sold_trip_seq" OWNED BY public.soldtrips.id_sold_trip;


--
-- TOC entry 217 (class 1259 OID 80791)
-- Name: tours; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tours (
    id_tour integer NOT NULL,
    descrition text NOT NULL,
    startdate date NOT NULL,
    "EndDate" date NOT NULL
);


ALTER TABLE public.tours OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 80790)
-- Name: Tours_id_tour_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Tours_id_tour_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Tours_id_tour_seq" OWNER TO postgres;

--
-- TOC entry 3397 (class 0 OID 0)
-- Dependencies: 216
-- Name: Tours_id_tour_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Tours_id_tour_seq" OWNED BY public.tours.id_tour;


--
-- TOC entry 215 (class 1259 OID 80784)
-- Name: clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clients (
    id integer NOT NULL,
    birthdate date NOT NULL,
    phone character varying(20) NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(100) NOT NULL,
    visible boolean DEFAULT true NOT NULL
);


ALTER TABLE public.clients OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 105475)
-- Name: clients_audit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clients_audit (
    audit_id integer NOT NULL,
    operation character varying(10) NOT NULL,
    client_id integer NOT NULL,
    changed_by character varying(100) NOT NULL,
    change_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    old_data jsonb,
    new_data jsonb
);


ALTER TABLE public.clients_audit OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 105474)
-- Name: clients_audit_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clients_audit_audit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clients_audit_audit_id_seq OWNER TO postgres;

--
-- TOC entry 3398 (class 0 OID 0)
-- Dependencies: 225
-- Name: clients_audit_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clients_audit_audit_id_seq OWNED BY public.clients_audit.audit_id;


--
-- TOC entry 214 (class 1259 OID 80783)
-- Name: clients_id_client_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clients_id_client_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clients_id_client_seq OWNER TO postgres;

--
-- TOC entry 3399 (class 0 OID 0)
-- Dependencies: 214
-- Name: clients_id_client_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clients_id_client_seq OWNED BY public.clients.id;


--
-- TOC entry 224 (class 1259 OID 97117)
-- Name: clientsi; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.clientsi AS
 SELECT clients.id,
    clients.*::public.clients AS clients
   FROM public.clients
  WHERE (clients.visible IS TRUE);


ALTER TABLE public.clientsi OWNER TO postgres;

--
-- TOC entry 3209 (class 2604 OID 80787)
-- Name: clients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients ALTER COLUMN id SET DEFAULT nextval('public.clients_id_client_seq'::regclass);


--
-- TOC entry 3215 (class 2604 OID 105478)
-- Name: clients_audit audit_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients_audit ALTER COLUMN audit_id SET DEFAULT nextval('public.clients_audit_audit_id_seq'::regclass);


--
-- TOC entry 3213 (class 2604 OID 80810)
-- Name: empoyees id_employees; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empoyees ALTER COLUMN id_employees SET DEFAULT nextval('public."Empoyees_id_employees_seq"'::regclass);


--
-- TOC entry 3214 (class 2604 OID 80817)
-- Name: salesoperations id_operation; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salesoperations ALTER COLUMN id_operation SET DEFAULT nextval('public."SalesOperations_id_operation_seq"'::regclass);


--
-- TOC entry 3212 (class 2604 OID 80803)
-- Name: soldtrips id_sold_trip; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soldtrips ALTER COLUMN id_sold_trip SET DEFAULT nextval('public."Soldtrips_id_sold_trip_seq"'::regclass);


--
-- TOC entry 3211 (class 2604 OID 80794)
-- Name: tours id_tour; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tours ALTER COLUMN id_tour SET DEFAULT nextval('public."Tours_id_tour_seq"'::regclass);


--
-- TOC entry 3378 (class 0 OID 80784)
-- Dependencies: 215
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clients (id, birthdate, phone, name, email, visible) FROM stdin;
2	2000-03-03	677	Бобрышев Алексей Денисович	mail.ru	t
3	2000-11-27	345	Ефименок Максим Александрович	rambler.ru	t
4	2011-06-09	567	Симоняка Сергей Сергеевич	gmail.com	t
5	2015-12-16	5467	Казаков Денис Денисович	gmail.com	t
6	2004-11-10	2332	Игнатьев Юрий Николаевич	mail.ru	t
\.


--
-- TOC entry 3388 (class 0 OID 105475)
-- Dependencies: 226
-- Data for Name: clients_audit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clients_audit (audit_id, operation, client_id, changed_by, change_time, old_data, new_data) FROM stdin;
\.


--
-- TOC entry 3384 (class 0 OID 80807)
-- Dependencies: 221
-- Data for Name: empoyees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.empoyees (id_employees, "FullName", "Position", "Email") FROM stdin;
2	Ефименок Максим Александрович	22	gmail.com
3	Казаков Денис Денисович	99	rambler.ru
4	Игнатьев Юрий Николаевич	65	email.ru
5	Симоняка Сергей Сергеевич	54	yandex.ru
6	Бобрышев Алексей Денисович	10	gmail.com
\.


--
-- TOC entry 3386 (class 0 OID 80814)
-- Dependencies: 223
-- Data for Name: salesoperations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salesoperations (id_operation, "OperationDate", "Note", id_sold_trip, id_employee) FROM stdin;
3	2007-07-29	хорошо	5	5
4	2004-07-24	не хорошо	4	4
5	2002-03-17	очень не круто	3	3
6	2005-05-16	не круто	2	2
7	2001-02-15	круто	1	1
\.


--
-- TOC entry 3382 (class 0 OID 80800)
-- Dependencies: 219
-- Data for Name: soldtrips; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.soldtrips (id_sold_trip, saledate, "TotalCost", "PaymentsValue", id_client, id_tour) FROM stdin;
7	2008-11-09	4500	рубли	5	5
8	2006-06-06	9999	рубли	4	4
9	2007-03-24	7500	рубли	3	3
10	2005-05-15	15000	рубли	2	2
11	2001-05-10	5000	рубли	1	1
\.


--
-- TOC entry 3380 (class 0 OID 80791)
-- Dependencies: 217
-- Data for Name: tours; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tours (id_tour, descrition, startdate, "EndDate") FROM stdin;
2	понравилось	2025-05-27	2025-06-02
3	не очень	2018-07-22	2018-08-02
4	хорошо	2001-05-12	2001-06-02
5	круто	2001-03-16	2001-06-02
6	ок	2006-06-02	2006-07-02
\.


--
-- TOC entry 3400 (class 0 OID 0)
-- Dependencies: 220
-- Name: Empoyees_id_employees_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Empoyees_id_employees_seq"', 6, true);


--
-- TOC entry 3401 (class 0 OID 0)
-- Dependencies: 222
-- Name: SalesOperations_id_operation_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."SalesOperations_id_operation_seq"', 7, true);


--
-- TOC entry 3402 (class 0 OID 0)
-- Dependencies: 218
-- Name: Soldtrips_id_sold_trip_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Soldtrips_id_sold_trip_seq"', 11, true);


--
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 216
-- Name: Tours_id_tour_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Tours_id_tour_seq"', 6, true);


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 225
-- Name: clients_audit_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clients_audit_audit_id_seq', 1, false);


--
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 214
-- Name: clients_id_client_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clients_id_client_seq', 6, true);


--
-- TOC entry 3224 (class 2606 OID 80812)
-- Name: empoyees Empoyees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empoyees
    ADD CONSTRAINT "Empoyees_pkey" PRIMARY KEY (id_employees);


--
-- TOC entry 3226 (class 2606 OID 80821)
-- Name: salesoperations SalesOperations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salesoperations
    ADD CONSTRAINT "SalesOperations_pkey" PRIMARY KEY (id_operation);


--
-- TOC entry 3222 (class 2606 OID 80805)
-- Name: soldtrips Soldtrips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soldtrips
    ADD CONSTRAINT "Soldtrips_pkey" PRIMARY KEY (id_sold_trip);


--
-- TOC entry 3220 (class 2606 OID 80798)
-- Name: tours Tours_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tours
    ADD CONSTRAINT "Tours_pkey" PRIMARY KEY (id_tour);


--
-- TOC entry 3228 (class 2606 OID 105483)
-- Name: clients_audit clients_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients_audit
    ADD CONSTRAINT clients_audit_pkey PRIMARY KEY (audit_id);


--
-- TOC entry 3218 (class 2606 OID 80789)
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- TOC entry 3376 (class 2618 OID 97121)
-- Name: clients delete_clients; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE delete_clients AS
    ON DELETE TO public.clients DO INSTEAD  UPDATE public.clients SET visible = false
  WHERE (clients.id = old.id);


--
-- TOC entry 3229 (class 2620 OID 105485)
-- Name: clients tr_log_client_changes; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_log_client_changes AFTER INSERT OR DELETE OR UPDATE ON public.clients FOR EACH ROW EXECUTE FUNCTION public.log_client_changes();


--
-- TOC entry 3230 (class 2620 OID 105471)
-- Name: soldtrips tr_update_tour_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_update_tour_status AFTER INSERT ON public.soldtrips FOR EACH ROW EXECUTE FUNCTION public.update_tour_status();


--
-- TOC entry 3231 (class 2620 OID 105473)
-- Name: salesoperations tr_validate_employee_commission; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_validate_employee_commission BEFORE INSERT OR UPDATE ON public.salesoperations FOR EACH ROW EXECUTE FUNCTION public.validate_employee_commission();


--
-- TOC entry 3232 (class 2620 OID 105469)
-- Name: salesoperations tr_validate_sale_date; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_validate_sale_date BEFORE INSERT OR UPDATE ON public.salesoperations FOR EACH ROW EXECUTE FUNCTION public.validate_sale_date();


-- Completed on 2025-05-21 10:32:19

--
-- PostgreSQL database dump complete
--

