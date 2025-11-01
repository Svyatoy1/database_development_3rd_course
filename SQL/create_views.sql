--
-- PostgreSQL database dump
--

\restrict ItKosuWCnIxb1JvBD3VxOLhHEi5ErbC2mwlsZGbuLbkpe151xiZXZWCvde0NQnz

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2025-11-01 11:37:49

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
-- TOC entry 253 (class 1259 OID 16829)
-- Name: v_athletes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_athletes AS
 SELECT athlete_id,
    first_name,
    last_name,
    birth_date,
    gender
   FROM public.athlete
  WHERE (is_deleted = false);


ALTER VIEW public.v_athletes OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 16833)
-- Name: v_events; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_events AS
 SELECT event_id,
    name AS event_name,
    start_date AS event_date,
    location_id
   FROM public.event
  WHERE (is_deleted = false);


ALTER VIEW public.v_events OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 16837)
-- Name: v_results; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_results AS
 SELECT result_id,
    athlete_id,
    match_id AS event_id,
    points,
    "position"
   FROM public.result;


ALTER VIEW public.v_results OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 16807)
-- Name: view_team_ranking; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_team_ranking AS
 SELECT t.team_id,
    t.name AS team_name,
    count(DISTINCT r.match_id) AS total_matches,
    round(avg(r.points), 2) AS avg_points,
    min(r."position") AS best_position
   FROM ((((public.team t
     JOIN public.teamathlete ta ON ((t.team_id = ta.team_id)))
     JOIN public.athlete a ON ((ta.athlete_id = a.athlete_id)))
     JOIN public.result r ON ((a.athlete_id = r.athlete_id)))
     JOIN public.match m ON ((r.match_id = m.match_id)))
  GROUP BY t.team_id, t.name
  ORDER BY (round(avg(r.points), 2)) DESC;


ALTER VIEW public.view_team_ranking OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 16801)
-- Name: view_upcoming_matches; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_upcoming_matches AS
 SELECT m.match_id,
    e.name AS event_name,
    s.name AS sport_name,
    l.name AS location_name,
    l.address AS location_address,
    m.match_date,
    concat(j.first_name, ' ', j.last_name) AS judge_name
   FROM ((((public.match m
     JOIN public.event e ON ((m.event_id = e.event_id)))
     LEFT JOIN public.sport s ON ((e.sport_id = s.sport_id)))
     LEFT JOIN public.location l ON ((m.location_id = l.location_id)))
     LEFT JOIN public.judge j ON ((m.judge_id = j.judge_id)))
  WHERE (m.match_date > now())
  ORDER BY m.match_date;


ALTER VIEW public.view_upcoming_matches OWNER TO postgres;

-- Completed on 2025-11-01 11:37:49

--
-- PostgreSQL database dump complete
--

\unrestrict ItKosuWCnIxb1JvBD3VxOLhHEi5ErbC2mwlsZGbuLbkpe151xiZXZWCvde0NQnz

