--
-- PostgreSQL database dump
--

\restrict fuaWk4Rkv3YLDI5dII8Ujl4z8LgZbZoP06yIrt0boLg0Lr4DpAiboDkGdAziv93

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2025-11-01 11:01:17

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
-- TOC entry 5135 (class 1262 OID 16530)
-- Name: SportsEventsDB; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "SportsEventsDB" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';


ALTER DATABASE "SportsEventsDB" OWNER TO postgres;

\unrestrict fuaWk4Rkv3YLDI5dII8Ujl4z8LgZbZoP06yIrt0boLg0Lr4DpAiboDkGdAziv93
\connect "SportsEventsDB"
\restrict fuaWk4Rkv3YLDI5dII8Ujl4z8LgZbZoP06yIrt0boLg0Lr4DpAiboDkGdAziv93

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
-- TOC entry 258 (class 1255 OID 16800)
-- Name: fn_get_athlete_stats(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_athlete_stats(p_athlete_id integer) RETURNS TABLE(athlete_id integer, total_matches bigint, avg_points numeric, best_position integer, last_match_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.athlete_id,
        COUNT(r.match_id) AS total_matches,
        COALESCE(AVG(r.points), 0) AS avg_points,
        MIN(r.position) AS best_position,
        MAX(m.match_date) AS last_match_date
    FROM result r
    JOIN match m ON r.match_id = m.match_id
    WHERE r.athlete_id = p_athlete_id
    GROUP BY r.athlete_id;
END;
$$;


ALTER FUNCTION public.fn_get_athlete_stats(p_athlete_id integer) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 16851)
-- Name: sp_add_athlete(character varying, character varying, date, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_add_athlete(IN p_first_name character varying, IN p_last_name character varying, IN p_birth_date date, IN p_gender character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO athlete(first_name, last_name, birth_date, gender, is_deleted, last_modified_by, last_modified)
    VALUES (p_first_name, p_last_name, p_birth_date, p_gender, FALSE, 1, NOW());
END;
$$;


ALTER PROCEDURE public.sp_add_athlete(IN p_first_name character varying, IN p_last_name character varying, IN p_birth_date date, IN p_gender character varying) OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 16852)
-- Name: sp_add_event(character varying, date, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_add_event(IN p_name character varying, IN p_start_date date, IN p_location_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO event(name, start_date, location_id, is_deleted, last_modified_by, last_modified)
    VALUES (p_name, p_start_date, p_location_id, FALSE, 1, NOW());
END;
$$;


ALTER PROCEDURE public.sp_add_event(IN p_name character varying, IN p_start_date date, IN p_location_id integer) OWNER TO postgres;

--
-- TOC entry 276 (class 1255 OID 16848)
-- Name: sp_add_result(integer, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_add_result(IN p_athlete_id integer, IN p_match_id integer, IN p_points integer, IN p_position integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO result(athlete_id, match_id, points, position)
    VALUES (p_athlete_id, p_match_id, p_points, p_position);
END;
$$;


ALTER PROCEDURE public.sp_add_result(IN p_athlete_id integer, IN p_match_id integer, IN p_points integer, IN p_position integer) OWNER TO postgres;

--
-- TOC entry 275 (class 1255 OID 16798)
-- Name: sp_add_result(integer, integer, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_add_result(IN p_match_id integer, IN p_athlete_id integer, IN p_points integer, IN p_position integer, IN p_user_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_exists_match INT;
    v_exists_athlete INT;
    v_new_id INT;
BEGIN
    -- Перевірка існування матчу
    SELECT COUNT(*) INTO v_exists_match FROM match WHERE match_id = p_match_id;
    IF v_exists_match = 0 THEN
        RAISE EXCEPTION 'Матч із match_id = % не знайдено', p_match_id;
    END IF;

    -- Перевірка існування спортсмена
    SELECT COUNT(*) INTO v_exists_athlete FROM athlete WHERE athlete_id = p_athlete_id;
    IF v_exists_athlete = 0 THEN
        RAISE EXCEPTION 'Спортсмен із athlete_id = % не знайдений', p_athlete_id;
    END IF;

    -- Додавання результату
    INSERT INTO result (match_id, athlete_id, points, position)
    VALUES (p_match_id, p_athlete_id, p_points, p_position)
    RETURNING result_id INTO v_new_id;

    -- Запис у журнал аудиту
    INSERT INTO auditlog (user_id, entity_name, entity_id, action, change_time)
    VALUES (p_user_id, 'Result', v_new_id, 'INSERT', NOW());
END;
$$;


ALTER PROCEDURE public.sp_add_result(IN p_match_id integer, IN p_athlete_id integer, IN p_points integer, IN p_position integer, IN p_user_id integer) OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 16793)
-- Name: sp_soft_delete_athlete(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_soft_delete_athlete(IN p_athlete_id integer, IN p_user_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- оновлюємо стан is_deleted та audit-поля
    UPDATE athlete
    SET 
        is_deleted = TRUE,
        last_modified = NOW(),
        last_modified_by = p_user_id
    WHERE athlete_id = p_athlete_id;

    -- записуємо лог у AuditLog
    INSERT INTO auditlog (user_id, entity_name, entity_id, action, change_time)
    VALUES (p_user_id, 'Athlete', p_athlete_id, 'SOFT_DELETE', NOW());
END;
$$;


ALTER PROCEDURE public.sp_soft_delete_athlete(IN p_athlete_id integer, IN p_user_id integer) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 16822)
-- Name: sp_update_athlete(integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_update_athlete(IN p_id integer, IN p_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE athlete
    SET first_name = p_name,
        last_modified = NOW(),
        last_modified_by = 1
    WHERE athlete_id = p_id;

    INSERT INTO auditlog (user_id, entity_name, entity_id, action, change_time)
    VALUES (1, 'Athlete', p_id, 'UPDATE', NOW());
END;
$$;


ALTER PROCEDURE public.sp_update_athlete(IN p_id integer, IN p_name character varying) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 16796)
-- Name: sp_update_event(integer, character varying, integer, integer, integer, date, date, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_update_event(IN p_event_id integer, IN p_name character varying, IN p_sport_id integer, IN p_event_type_id integer, IN p_location_id integer, IN p_start_date date, IN p_end_date date, IN p_user_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Оновлення даних у таблиці Event
    UPDATE event
    SET 
        name = COALESCE(p_name, name),
        sport_id = COALESCE(p_sport_id, sport_id),
        event_type_id = COALESCE(p_event_type_id, event_type_id),
        location_id = COALESCE(p_location_id, location_id),
        start_date = COALESCE(p_start_date, start_date),
        end_date = COALESCE(p_end_date, end_date),
        last_modified = NOW(),
        last_modified_by = p_user_id
    WHERE event_id = p_event_id;

    -- Запис у журнал аудиту
    INSERT INTO auditlog (user_id, entity_name, entity_id, action, change_time)
    VALUES (p_user_id, 'Event', p_event_id, 'UPDATE', NOW());
END;
$$;


ALTER PROCEDURE public.sp_update_event(IN p_event_id integer, IN p_name character varying, IN p_sport_id integer, IN p_event_type_id integer, IN p_location_id integer, IN p_start_date date, IN p_end_date date, IN p_user_id integer) OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 16815)
-- Name: trg_athlete_audit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_athlete_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO auditlog (user_id, entity_name, entity_id, action, change_time)
    VALUES (NEW.last_modified_by, 'Athlete', NEW.athlete_id, 'UPDATE', NOW());
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_athlete_audit() OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 16794)
-- Name: trg_athlete_soft_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_athlete_soft_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- замість фактичного видалення — позначаємо як видаленого
    UPDATE athlete
    SET 
        is_deleted = TRUE,
        last_modified = NOW()
    WHERE athlete_id = OLD.athlete_id;

    -- записуємо лог
    INSERT INTO auditlog (user_id, entity_name, entity_id, action, change_time)
    VALUES (OLD.last_modified_by, 'Athlete', OLD.athlete_id, 'SOFT_DELETE_TRIGGER', NOW());

    RETURN NULL; -- скасовує фізичне видалення
END;
$$;


ALTER FUNCTION public.trg_athlete_soft_delete() OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 16813)
-- Name: trg_event_audit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_event_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO auditlog (user_id, entity_name, entity_id, action, change_time)
    VALUES (NEW.last_modified_by, 'Event', NEW.event_id, 'UPDATE', NOW());
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_event_audit() OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 16817)
-- Name: trg_team_audit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_team_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO auditlog (user_id, entity_name, entity_id, action, change_time)
    VALUES (NEW.last_modified_by, 'Team', NEW.team_id, 'UPDATE', NOW());
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_team_audit() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 16551)
-- Name: User; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."User" (
    user_id integer NOT NULL,
    username character varying(50) NOT NULL,
    role character varying(20),
    email character varying(100)
);


ALTER TABLE public."User" OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16550)
-- Name: User_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."User_user_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."User_user_id_seq" OWNER TO postgres;

--
-- TOC entry 5136 (class 0 OID 0)
-- Dependencies: 221
-- Name: User_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."User_user_id_seq" OWNED BY public."User".user_id;


--
-- TOC entry 232 (class 1259 OID 16609)
-- Name: athlete; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.athlete (
    athlete_id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    birth_date date,
    gender character varying(10),
    is_deleted boolean DEFAULT false,
    last_modified timestamp without time zone DEFAULT now(),
    last_modified_by integer
);


ALTER TABLE public.athlete OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16608)
-- Name: athlete_athlete_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.athlete_athlete_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.athlete_athlete_id_seq OWNER TO postgres;

--
-- TOC entry 5137 (class 0 OID 0)
-- Dependencies: 231
-- Name: athlete_athlete_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.athlete_athlete_id_seq OWNED BY public.athlete.athlete_id;


--
-- TOC entry 250 (class 1259 OID 16775)
-- Name: auditlog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditlog (
    log_id integer NOT NULL,
    user_id integer,
    entity_name character varying(100),
    entity_id integer,
    action character varying(20),
    change_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.auditlog OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 16774)
-- Name: auditlog_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auditlog_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auditlog_log_id_seq OWNER TO postgres;

--
-- TOC entry 5138 (class 0 OID 0)
-- Dependencies: 249
-- Name: auditlog_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auditlog_log_id_seq OWNED BY public.auditlog.log_id;


--
-- TOC entry 228 (class 1259 OID 16578)
-- Name: coach; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coach (
    coach_id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    experience_years integer
);


ALTER TABLE public.coach OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16577)
-- Name: coach_coach_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.coach_coach_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.coach_coach_id_seq OWNER TO postgres;

--
-- TOC entry 5139 (class 0 OID 0)
-- Dependencies: 227
-- Name: coach_coach_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.coach_coach_id_seq OWNED BY public.coach.coach_id;


--
-- TOC entry 237 (class 1259 OID 16651)
-- Name: event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event (
    event_id integer NOT NULL,
    name character varying(150) NOT NULL,
    sport_id integer,
    event_type_id integer,
    location_id integer,
    start_date date,
    end_date date,
    is_deleted boolean DEFAULT false,
    last_modified timestamp without time zone DEFAULT now(),
    last_modified_by integer
);


ALTER TABLE public.event OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16650)
-- Name: event_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.event_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.event_event_id_seq OWNER TO postgres;

--
-- TOC entry 5140 (class 0 OID 0)
-- Dependencies: 236
-- Name: event_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.event_event_id_seq OWNED BY public.event.event_id;


--
-- TOC entry 248 (class 1259 OID 16757)
-- Name: eventsponsor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.eventsponsor (
    event_id integer NOT NULL,
    sponsor_id integer NOT NULL,
    contribution numeric(10,2)
);


ALTER TABLE public.eventsponsor OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16560)
-- Name: eventtype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.eventtype (
    event_type_id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.eventtype OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16559)
-- Name: eventtype_event_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.eventtype_event_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.eventtype_event_type_id_seq OWNER TO postgres;

--
-- TOC entry 5141 (class 0 OID 0)
-- Dependencies: 223
-- Name: eventtype_event_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.eventtype_event_type_id_seq OWNED BY public.eventtype.event_type_id;


--
-- TOC entry 235 (class 1259 OID 16643)
-- Name: judge; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.judge (
    judge_id integer NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    category character varying(30)
);


ALTER TABLE public.judge OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16642)
-- Name: judge_judge_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.judge_judge_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.judge_judge_id_seq OWNER TO postgres;

--
-- TOC entry 5142 (class 0 OID 0)
-- Dependencies: 234
-- Name: judge_judge_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.judge_judge_id_seq OWNED BY public.judge.judge_id;


--
-- TOC entry 226 (class 1259 OID 16569)
-- Name: location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.location (
    location_id integer NOT NULL,
    name character varying(100) NOT NULL,
    address character varying(200),
    capacity integer
);


ALTER TABLE public.location OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16568)
-- Name: location_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.location_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.location_location_id_seq OWNER TO postgres;

--
-- TOC entry 5143 (class 0 OID 0)
-- Dependencies: 225
-- Name: location_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.location_location_id_seq OWNED BY public.location.location_id;


--
-- TOC entry 239 (class 1259 OID 16682)
-- Name: match; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match (
    match_id integer NOT NULL,
    event_id integer,
    location_id integer,
    match_date timestamp without time zone,
    judge_id integer
);


ALTER TABLE public.match OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 16681)
-- Name: match_match_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.match_match_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.match_match_id_seq OWNER TO postgres;

--
-- TOC entry 5144 (class 0 OID 0)
-- Dependencies: 238
-- Name: match_match_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.match_match_id_seq OWNED BY public.match.match_id;


--
-- TOC entry 241 (class 1259 OID 16705)
-- Name: result; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.result (
    result_id integer NOT NULL,
    match_id integer,
    athlete_id integer,
    points integer,
    "position" integer
);


ALTER TABLE public.result OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 16704)
-- Name: result_result_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.result_result_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.result_result_id_seq OWNER TO postgres;

--
-- TOC entry 5145 (class 0 OID 0)
-- Dependencies: 240
-- Name: result_result_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.result_result_id_seq OWNED BY public.result.result_id;


--
-- TOC entry 243 (class 1259 OID 16723)
-- Name: spectator; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.spectator (
    spectator_id integer NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    email character varying(100)
);


ALTER TABLE public.spectator OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 16722)
-- Name: spectator_spectator_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.spectator_spectator_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.spectator_spectator_id_seq OWNER TO postgres;

--
-- TOC entry 5146 (class 0 OID 0)
-- Dependencies: 242
-- Name: spectator_spectator_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.spectator_spectator_id_seq OWNED BY public.spectator.spectator_id;


--
-- TOC entry 247 (class 1259 OID 16750)
-- Name: sponsor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sponsor (
    sponsor_id integer NOT NULL,
    name character varying(100),
    contact_person character varying(100)
);


ALTER TABLE public.sponsor OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 16749)
-- Name: sponsor_sponsor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sponsor_sponsor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sponsor_sponsor_id_seq OWNER TO postgres;

--
-- TOC entry 5147 (class 0 OID 0)
-- Dependencies: 246
-- Name: sponsor_sponsor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sponsor_sponsor_id_seq OWNED BY public.sponsor.sponsor_id;


--
-- TOC entry 220 (class 1259 OID 16532)
-- Name: sport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sport (
    sport_id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.sport OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16531)
-- Name: sport_sport_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sport_sport_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sport_sport_id_seq OWNER TO postgres;

--
-- TOC entry 5148 (class 0 OID 0)
-- Dependencies: 219
-- Name: sport_sport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sport_sport_id_seq OWNED BY public.sport.sport_id;


--
-- TOC entry 230 (class 1259 OID 16588)
-- Name: team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team (
    team_id integer NOT NULL,
    name character varying(100) NOT NULL,
    coach_id integer,
    founded_year integer,
    is_deleted boolean DEFAULT false,
    last_modified timestamp without time zone DEFAULT now(),
    last_modified_by integer
);


ALTER TABLE public.team OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16587)
-- Name: team_team_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.team_team_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.team_team_id_seq OWNER TO postgres;

--
-- TOC entry 5149 (class 0 OID 0)
-- Dependencies: 229
-- Name: team_team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.team_team_id_seq OWNED BY public.team.team_id;


--
-- TOC entry 233 (class 1259 OID 16625)
-- Name: teamathlete; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teamathlete (
    team_id integer NOT NULL,
    athlete_id integer NOT NULL
);


ALTER TABLE public.teamathlete OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 16731)
-- Name: ticket; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ticket (
    ticket_id integer NOT NULL,
    event_id integer,
    spectator_id integer,
    seat_number character varying(10),
    price numeric(8,2),
    purchase_date timestamp without time zone DEFAULT now()
);


ALTER TABLE public.ticket OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 16730)
-- Name: ticket_ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ticket_ticket_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ticket_ticket_id_seq OWNER TO postgres;

--
-- TOC entry 5150 (class 0 OID 0)
-- Dependencies: 244
-- Name: ticket_ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ticket_ticket_id_seq OWNED BY public.ticket.ticket_id;


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

--
-- TOC entry 4866 (class 2604 OID 16554)
-- Name: User user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User" ALTER COLUMN user_id SET DEFAULT nextval('public."User_user_id_seq"'::regclass);


--
-- TOC entry 4873 (class 2604 OID 16612)
-- Name: athlete athlete_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.athlete ALTER COLUMN athlete_id SET DEFAULT nextval('public.athlete_athlete_id_seq'::regclass);


--
-- TOC entry 4886 (class 2604 OID 16778)
-- Name: auditlog log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditlog ALTER COLUMN log_id SET DEFAULT nextval('public.auditlog_log_id_seq'::regclass);


--
-- TOC entry 4869 (class 2604 OID 16581)
-- Name: coach coach_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coach ALTER COLUMN coach_id SET DEFAULT nextval('public.coach_coach_id_seq'::regclass);


--
-- TOC entry 4877 (class 2604 OID 16654)
-- Name: event event_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event ALTER COLUMN event_id SET DEFAULT nextval('public.event_event_id_seq'::regclass);


--
-- TOC entry 4867 (class 2604 OID 16563)
-- Name: eventtype event_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eventtype ALTER COLUMN event_type_id SET DEFAULT nextval('public.eventtype_event_type_id_seq'::regclass);


--
-- TOC entry 4876 (class 2604 OID 16646)
-- Name: judge judge_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.judge ALTER COLUMN judge_id SET DEFAULT nextval('public.judge_judge_id_seq'::regclass);


--
-- TOC entry 4868 (class 2604 OID 16572)
-- Name: location location_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location ALTER COLUMN location_id SET DEFAULT nextval('public.location_location_id_seq'::regclass);


--
-- TOC entry 4880 (class 2604 OID 16685)
-- Name: match match_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match ALTER COLUMN match_id SET DEFAULT nextval('public.match_match_id_seq'::regclass);


--
-- TOC entry 4881 (class 2604 OID 16708)
-- Name: result result_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result ALTER COLUMN result_id SET DEFAULT nextval('public.result_result_id_seq'::regclass);


--
-- TOC entry 4882 (class 2604 OID 16726)
-- Name: spectator spectator_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spectator ALTER COLUMN spectator_id SET DEFAULT nextval('public.spectator_spectator_id_seq'::regclass);


--
-- TOC entry 4885 (class 2604 OID 16753)
-- Name: sponsor sponsor_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsor ALTER COLUMN sponsor_id SET DEFAULT nextval('public.sponsor_sponsor_id_seq'::regclass);


--
-- TOC entry 4865 (class 2604 OID 16535)
-- Name: sport sport_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sport ALTER COLUMN sport_id SET DEFAULT nextval('public.sport_sport_id_seq'::regclass);


--
-- TOC entry 4870 (class 2604 OID 16591)
-- Name: team team_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team ALTER COLUMN team_id SET DEFAULT nextval('public.team_team_id_seq'::regclass);


--
-- TOC entry 4883 (class 2604 OID 16734)
-- Name: ticket ticket_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket ALTER COLUMN ticket_id SET DEFAULT nextval('public.ticket_ticket_id_seq'::regclass);


--
-- TOC entry 5101 (class 0 OID 16551)
-- Dependencies: 222
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."User" (user_id, username, role, email) FROM stdin;
1	admin	manager	admin@example.com
\.


--
-- TOC entry 5111 (class 0 OID 16609)
-- Dependencies: 232
-- Data for Name: athlete; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.athlete (athlete_id, first_name, last_name, birth_date, gender, is_deleted, last_modified, last_modified_by) FROM stdin;
3	Usain	Bolt	1986-08-21	M	f	2025-10-30 19:53:56.755046	1
4	Oleh	Shevchenko	1995-04-02	M	f	2025-10-30 20:17:03.165148	1
5	Andriy	Koval	1997-08-11	M	f	2025-10-30 20:17:03.165148	1
6	Dmytro	Bondar	1998-09-23	M	f	2025-10-30 20:17:03.165148	1
7	Denys	Petrenko	1994-09-18	M	f	2025-10-30 20:29:10.074808	1
2	Michael	Jordan	1985-02-17	M	t	2025-10-30 20:29:10.074808	1
8	John	Smith	2000-05-15	Male	f	2025-10-30 21:50:23.666861	1
10	John	Smith	2000-05-15	Male	f	2025-10-30 21:53:33.13909	1
11	John	Smith	2000-05-15	Male	f	2025-10-30 21:54:52.318264	1
1	John Updated	Shevchenko-upd	1990-01-01	F	t	2025-10-30 21:54:52.327678	1
12	John	Doe	1998-05-12	M	f	2025-10-31 00:17:09.162909	1
13	John	Doe	1998-05-12	M	f	2025-10-31 00:32:29.408425	1
14	John	Doe	1998-05-12	M	f	2025-10-31 00:46:29.097763	1
15	John	Doe	1998-05-12	M	f	2025-10-31 00:50:30.071398	1
\.


--
-- TOC entry 5129 (class 0 OID 16775)
-- Dependencies: 250
-- Data for Name: auditlog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auditlog (log_id, user_id, entity_name, entity_id, action, change_time) FROM stdin;
1	1	Athlete	1	SOFT_DELETE	2025-10-30 19:19:38.19006
2	1	Event	1	UPDATE	2025-10-30 19:29:49.295203
3	1	Athlete	2	INSERT	2025-10-30 19:34:47.875568
4	1	Result	1	INSERT	2025-10-30 19:54:09.163318
5	1	Event	1	UPDATE	2025-10-30 20:19:41.794687
6	1	Athlete	1	UPDATE	2025-10-30 20:22:41.033614
7	1	Team	1	UPDATE	2025-10-30 20:22:41.033614
8	1	Event	1	UPDATE	2025-10-30 20:29:10.074808
9	1	Athlete	1	UPDATE	2025-10-30 20:29:10.074808
10	1	Team	2	UPDATE	2025-10-30 20:29:10.074808
11	1	Athlete	7	INSERT	2025-10-30 20:29:10.074808
12	1	Athlete	2	UPDATE	2025-10-30 20:29:10.074808
13	1	Athlete	2	SOFT_DELETE	2025-10-30 20:29:10.074808
14	1	Athlete	8	INSERT	2025-10-30 21:50:23.666861
15	1	Athlete	10	INSERT	2025-10-30 21:53:33.13909
16	1	Athlete	11	INSERT	2025-10-30 21:54:52.318264
17	1	Athlete	1	UPDATE	2025-10-30 21:54:52.327678
18	1	Athlete	1	UPDATE	2025-10-30 21:54:52.327678
\.


--
-- TOC entry 5107 (class 0 OID 16578)
-- Dependencies: 228
-- Data for Name: coach; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.coach (coach_id, first_name, last_name, experience_years) FROM stdin;
\.


--
-- TOC entry 5116 (class 0 OID 16651)
-- Dependencies: 237
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event (event_id, name, sport_id, event_type_id, location_id, start_date, end_date, is_deleted, last_modified, last_modified_by) FROM stdin;
2	Kyiv Open Cup	1	\N	\N	2025-05-01	2025-05-07	f	2025-10-30 19:29:32.318955	1
3	Kyiv Open Cup 2025	1	\N	1	2025-05-01	2025-05-07	f	2025-10-30 20:06:05.793687	1
4	Kyiv Basketball Fest	2	\N	2	2025-06-01	2025-06-03	f	2025-10-30 20:06:05.793687	1
5	Tennis Grand Challenge	3	\N	3	2025-07-10	2025-07-12	f	2025-10-30 20:06:05.793687	1
1	Test Event 1	1	\N	\N	2025-05-10	2025-05-17	f	2025-10-30 19:29:49.295203	1
6	Summer Cup	\N	\N	2	2025-06-01	\N	f	2025-10-31 00:19:15.689233	1
7	Summer Cup	\N	\N	2	2025-06-01	\N	f	2025-10-31 00:50:30.079738	1
\.


--
-- TOC entry 5127 (class 0 OID 16757)
-- Dependencies: 248
-- Data for Name: eventsponsor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.eventsponsor (event_id, sponsor_id, contribution) FROM stdin;
\.


--
-- TOC entry 5103 (class 0 OID 16560)
-- Dependencies: 224
-- Data for Name: eventtype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.eventtype (event_type_id, name) FROM stdin;
\.


--
-- TOC entry 5114 (class 0 OID 16643)
-- Dependencies: 235
-- Data for Name: judge; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.judge (judge_id, first_name, last_name, category) FROM stdin;
1	John	Doe	International
2	Emily	Stone	National
3	Alex	Brown	Regional
\.


--
-- TOC entry 5105 (class 0 OID 16569)
-- Dependencies: 226
-- Data for Name: location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.location (location_id, name, address, capacity) FROM stdin;
1	Olympic Stadium	Kyiv, Velyka Vasylkivska 55	70000
2	Palace of Sports	Kyiv, Sportyvna Square 1	5000
3	Tennis Center	Kyiv, Parkova Rd 10	2000
\.


--
-- TOC entry 5118 (class 0 OID 16682)
-- Dependencies: 239
-- Data for Name: match; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.match (match_id, event_id, location_id, match_date, judge_id) FROM stdin;
1	1	\N	2025-05-10 15:00:00	\N
2	1	1	2025-05-10 15:00:00	1
3	1	1	2025-05-12 17:00:00	2
4	2	2	2025-06-02 19:00:00	3
5	3	3	2025-07-11 14:30:00	1
6	1	1	2026-03-05 15:00:00	1
7	2	2	2026-04-10 18:00:00	2
\.


--
-- TOC entry 5120 (class 0 OID 16705)
-- Dependencies: 241
-- Data for Name: result; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.result (result_id, match_id, athlete_id, points, "position") FROM stdin;
1	1	1	95	1
2	5	1	90	1
3	5	2	88	2
4	6	3	93	1
5	1	1	100	1
6	1	1	95	1
7	1	1	95	1
\.


--
-- TOC entry 5122 (class 0 OID 16723)
-- Dependencies: 243
-- Data for Name: spectator; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spectator (spectator_id, first_name, last_name, email) FROM stdin;
\.


--
-- TOC entry 5126 (class 0 OID 16750)
-- Dependencies: 247
-- Data for Name: sponsor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sponsor (sponsor_id, name, contact_person) FROM stdin;
\.


--
-- TOC entry 5099 (class 0 OID 16532)
-- Dependencies: 220
-- Data for Name: sport; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sport (sport_id, name) FROM stdin;
1	Football
2	Basketball
3	Tennis
4	Football
5	Basketball
6	Tennis
7	Football
8	Basketball
9	Tennis
\.


--
-- TOC entry 5109 (class 0 OID 16588)
-- Dependencies: 230
-- Data for Name: team; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team (team_id, name, coach_id, founded_year, is_deleted, last_modified, last_modified_by) FROM stdin;
1	Dynamo Kyiv Updated	\N	1927	f	2025-10-30 20:17:03.165148	1
2	Shakhtar Donetsk	\N	2026	f	2025-10-30 20:17:03.165148	1
\.


--
-- TOC entry 5112 (class 0 OID 16625)
-- Dependencies: 233
-- Data for Name: teamathlete; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teamathlete (team_id, athlete_id) FROM stdin;
1	1
1	2
2	3
\.


--
-- TOC entry 5124 (class 0 OID 16731)
-- Dependencies: 245
-- Data for Name: ticket; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ticket (ticket_id, event_id, spectator_id, seat_number, price, purchase_date) FROM stdin;
\.


--
-- TOC entry 5151 (class 0 OID 0)
-- Dependencies: 221
-- Name: User_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."User_user_id_seq"', 1, true);


--
-- TOC entry 5152 (class 0 OID 0)
-- Dependencies: 231
-- Name: athlete_athlete_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.athlete_athlete_id_seq', 15, true);


--
-- TOC entry 5153 (class 0 OID 0)
-- Dependencies: 249
-- Name: auditlog_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auditlog_log_id_seq', 18, true);


--
-- TOC entry 5154 (class 0 OID 0)
-- Dependencies: 227
-- Name: coach_coach_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.coach_coach_id_seq', 1, false);


--
-- TOC entry 5155 (class 0 OID 0)
-- Dependencies: 236
-- Name: event_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.event_event_id_seq', 7, true);


--
-- TOC entry 5156 (class 0 OID 0)
-- Dependencies: 223
-- Name: eventtype_event_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.eventtype_event_type_id_seq', 1, false);


--
-- TOC entry 5157 (class 0 OID 0)
-- Dependencies: 234
-- Name: judge_judge_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.judge_judge_id_seq', 3, true);


--
-- TOC entry 5158 (class 0 OID 0)
-- Dependencies: 225
-- Name: location_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.location_location_id_seq', 3, true);


--
-- TOC entry 5159 (class 0 OID 0)
-- Dependencies: 238
-- Name: match_match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.match_match_id_seq', 7, true);


--
-- TOC entry 5160 (class 0 OID 0)
-- Dependencies: 240
-- Name: result_result_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.result_result_id_seq', 7, true);


--
-- TOC entry 5161 (class 0 OID 0)
-- Dependencies: 242
-- Name: spectator_spectator_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.spectator_spectator_id_seq', 1, false);


--
-- TOC entry 5162 (class 0 OID 0)
-- Dependencies: 246
-- Name: sponsor_sponsor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sponsor_sponsor_id_seq', 1, false);


--
-- TOC entry 5163 (class 0 OID 0)
-- Dependencies: 219
-- Name: sport_sport_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sport_sport_id_seq', 9, true);


--
-- TOC entry 5164 (class 0 OID 0)
-- Dependencies: 229
-- Name: team_team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.team_team_id_seq', 2, true);


--
-- TOC entry 5165 (class 0 OID 0)
-- Dependencies: 244
-- Name: ticket_ticket_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ticket_ticket_id_seq', 1, false);


--
-- TOC entry 4891 (class 2606 OID 16558)
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (user_id);


--
-- TOC entry 4901 (class 2606 OID 16619)
-- Name: athlete athlete_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.athlete
    ADD CONSTRAINT athlete_pkey PRIMARY KEY (athlete_id);


--
-- TOC entry 4922 (class 2606 OID 16782)
-- Name: auditlog auditlog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditlog
    ADD CONSTRAINT auditlog_pkey PRIMARY KEY (log_id);


--
-- TOC entry 4897 (class 2606 OID 16586)
-- Name: coach coach_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coach
    ADD CONSTRAINT coach_pkey PRIMARY KEY (coach_id);


--
-- TOC entry 4907 (class 2606 OID 16660)
-- Name: event event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (event_id);


--
-- TOC entry 4920 (class 2606 OID 16763)
-- Name: eventsponsor eventsponsor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eventsponsor
    ADD CONSTRAINT eventsponsor_pkey PRIMARY KEY (event_id, sponsor_id);


--
-- TOC entry 4893 (class 2606 OID 16567)
-- Name: eventtype eventtype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eventtype
    ADD CONSTRAINT eventtype_pkey PRIMARY KEY (event_type_id);


--
-- TOC entry 4905 (class 2606 OID 16649)
-- Name: judge judge_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.judge
    ADD CONSTRAINT judge_pkey PRIMARY KEY (judge_id);


--
-- TOC entry 4895 (class 2606 OID 16576)
-- Name: location location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_pkey PRIMARY KEY (location_id);


--
-- TOC entry 4910 (class 2606 OID 16688)
-- Name: match match_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_pkey PRIMARY KEY (match_id);


--
-- TOC entry 4912 (class 2606 OID 16711)
-- Name: result result_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_pkey PRIMARY KEY (result_id);


--
-- TOC entry 4914 (class 2606 OID 16729)
-- Name: spectator spectator_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.spectator
    ADD CONSTRAINT spectator_pkey PRIMARY KEY (spectator_id);


--
-- TOC entry 4918 (class 2606 OID 16756)
-- Name: sponsor sponsor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sponsor
    ADD CONSTRAINT sponsor_pkey PRIMARY KEY (sponsor_id);


--
-- TOC entry 4889 (class 2606 OID 16539)
-- Name: sport sport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sport
    ADD CONSTRAINT sport_pkey PRIMARY KEY (sport_id);


--
-- TOC entry 4899 (class 2606 OID 16597)
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (team_id);


--
-- TOC entry 4903 (class 2606 OID 16631)
-- Name: teamathlete teamathlete_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamathlete
    ADD CONSTRAINT teamathlete_pkey PRIMARY KEY (team_id, athlete_id);


--
-- TOC entry 4916 (class 2606 OID 16738)
-- Name: ticket ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (ticket_id);


--
-- TOC entry 4908 (class 1259 OID 16788)
-- Name: idx_event_sport; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_event_sport ON public.event USING btree (sport_id);


--
-- TOC entry 4943 (class 2620 OID 16816)
-- Name: athlete after_athlete_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_athlete_update AFTER UPDATE ON public.athlete FOR EACH ROW EXECUTE FUNCTION public.trg_athlete_audit();


--
-- TOC entry 4945 (class 2620 OID 16814)
-- Name: event after_event_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_event_update AFTER UPDATE ON public.event FOR EACH ROW EXECUTE FUNCTION public.trg_event_audit();


--
-- TOC entry 4942 (class 2620 OID 16818)
-- Name: team after_team_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_team_update AFTER UPDATE ON public.team FOR EACH ROW EXECUTE FUNCTION public.trg_team_audit();


--
-- TOC entry 4944 (class 2620 OID 16795)
-- Name: athlete before_athlete_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_athlete_delete BEFORE DELETE ON public.athlete FOR EACH ROW EXECUTE FUNCTION public.trg_athlete_soft_delete();


--
-- TOC entry 4925 (class 2606 OID 16620)
-- Name: athlete athlete_last_modified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.athlete
    ADD CONSTRAINT athlete_last_modified_by_fkey FOREIGN KEY (last_modified_by) REFERENCES public."User"(user_id);


--
-- TOC entry 4941 (class 2606 OID 16783)
-- Name: auditlog auditlog_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditlog
    ADD CONSTRAINT auditlog_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id);


--
-- TOC entry 4928 (class 2606 OID 16666)
-- Name: event event_event_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_event_type_id_fkey FOREIGN KEY (event_type_id) REFERENCES public.eventtype(event_type_id);


--
-- TOC entry 4929 (class 2606 OID 16676)
-- Name: event event_last_modified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_last_modified_by_fkey FOREIGN KEY (last_modified_by) REFERENCES public."User"(user_id);


--
-- TOC entry 4930 (class 2606 OID 16671)
-- Name: event event_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.location(location_id);


--
-- TOC entry 4931 (class 2606 OID 16661)
-- Name: event event_sport_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_sport_id_fkey FOREIGN KEY (sport_id) REFERENCES public.sport(sport_id);


--
-- TOC entry 4939 (class 2606 OID 16764)
-- Name: eventsponsor eventsponsor_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eventsponsor
    ADD CONSTRAINT eventsponsor_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(event_id) ON DELETE CASCADE;


--
-- TOC entry 4940 (class 2606 OID 16769)
-- Name: eventsponsor eventsponsor_sponsor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eventsponsor
    ADD CONSTRAINT eventsponsor_sponsor_id_fkey FOREIGN KEY (sponsor_id) REFERENCES public.sponsor(sponsor_id) ON DELETE CASCADE;


--
-- TOC entry 4932 (class 2606 OID 16689)
-- Name: match match_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(event_id) ON DELETE CASCADE;


--
-- TOC entry 4933 (class 2606 OID 16699)
-- Name: match match_judge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_judge_id_fkey FOREIGN KEY (judge_id) REFERENCES public.judge(judge_id);


--
-- TOC entry 4934 (class 2606 OID 16694)
-- Name: match match_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.location(location_id);


--
-- TOC entry 4935 (class 2606 OID 16717)
-- Name: result result_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athlete(athlete_id);


--
-- TOC entry 4936 (class 2606 OID 16712)
-- Name: result result_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.result
    ADD CONSTRAINT result_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.match(match_id) ON DELETE CASCADE;


--
-- TOC entry 4923 (class 2606 OID 16598)
-- Name: team team_coach_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_coach_id_fkey FOREIGN KEY (coach_id) REFERENCES public.coach(coach_id) ON DELETE SET NULL;


--
-- TOC entry 4924 (class 2606 OID 16603)
-- Name: team team_last_modified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_last_modified_by_fkey FOREIGN KEY (last_modified_by) REFERENCES public."User"(user_id);


--
-- TOC entry 4926 (class 2606 OID 16637)
-- Name: teamathlete teamathlete_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamathlete
    ADD CONSTRAINT teamathlete_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athlete(athlete_id) ON DELETE CASCADE;


--
-- TOC entry 4927 (class 2606 OID 16632)
-- Name: teamathlete teamathlete_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teamathlete
    ADD CONSTRAINT teamathlete_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(team_id) ON DELETE CASCADE;


--
-- TOC entry 4937 (class 2606 OID 16739)
-- Name: ticket ticket_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(event_id);


--
-- TOC entry 4938 (class 2606 OID 16744)
-- Name: ticket ticket_spectator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_spectator_id_fkey FOREIGN KEY (spectator_id) REFERENCES public.spectator(spectator_id);


-- Completed on 2025-11-01 11:01:17

--
-- PostgreSQL database dump complete
--

\unrestrict fuaWk4Rkv3YLDI5dII8Ujl4z8LgZbZoP06yIrt0boLg0Lr4DpAiboDkGdAziv93

