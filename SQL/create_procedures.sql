-- Запис у журнал аудиту
    INSERT INTO auditlog (user_id, entity_name, entity_id, action, change_time)
    VALUES (p_user_id, 'Result', v_new_id, 'INSERT', NOW());
END;
$procedure$
"
"CREATE OR REPLACE PROCEDURE public.sp_add_result(IN p_athlete_id integer, IN p_match_id integer, IN p_points integer, IN p_position integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO result(athlete_id, match_id, points, position)
    VALUES (p_athlete_id, p_match_id, p_points, p_position);
END;
$procedure$
"
"CREATE OR REPLACE PROCEDURE public.sp_add_athlete(IN p_first_name character varying, IN p_last_name character varying, IN p_birth_date date, IN p_gender character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO athlete(first_name, last_name, birth_date, gender, is_deleted, last_modified_by, last_modified)
    VALUES (p_first_name, p_last_name, p_birth_date, p_gender, FALSE, 1, NOW());
END;
$procedure$
"
"CREATE OR REPLACE PROCEDURE public.sp_add_event(IN p_name character varying, IN p_start_date date, IN p_location_id integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO event(name, start_date, location_id, is_deleted, last_modified_by, last_modified)
    VALUES (p_name, p_start_date, p_location_id, FALSE, 1, NOW());
END;
$procedure$
"