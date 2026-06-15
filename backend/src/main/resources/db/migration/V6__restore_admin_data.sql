-- ============================================================
-- V6: Restore admin dev data
--   • Re-activates the ABAB Upper/Lower program
--   • Deactivates any other programs for admin
--   • Deletes any dangling incomplete sessions
--   • Adds body weight logs May 19-23 2026
--   • Adds this-week and last-week completed sessions
-- ============================================================

DO $$
DECLARE
    admin_id     BIGINT;
    prog_id      BIGINT;
    tmpl_ua      BIGINT;
    tmpl_la      BIGINT;
    tmpl_ub      BIGINT;
    tmpl_lb      BIGINT;
    sess_id      BIGINT;
    se_id        BIGINT;
    ex_id        BIGINT;
BEGIN
    -- ── Admin user ───────────────────────────────────────────────────────────
    SELECT id INTO admin_id FROM users WHERE email = 'admin@reps.dev';
    IF admin_id IS NULL THEN RETURN; END IF;

    -- ── Re-activate ABAB program, deactivate all others ──────────────────────
    UPDATE training_programs SET active = FALSE WHERE user_id = admin_id;
    UPDATE training_programs
       SET active = TRUE
     WHERE user_id = admin_id AND name = 'ABAB Upper/Lower';
    SELECT id INTO prog_id
      FROM training_programs
     WHERE user_id = admin_id AND name = 'ABAB Upper/Lower'
     LIMIT 1;

    IF prog_id IS NULL THEN RETURN; END IF;

    -- Grab template IDs
    SELECT id INTO tmpl_ua FROM workout_templates WHERE program_id = prog_id AND name = 'Upper A' LIMIT 1;
    SELECT id INTO tmpl_la FROM workout_templates WHERE program_id = prog_id AND name = 'Lower A' LIMIT 1;
    SELECT id INTO tmpl_ub FROM workout_templates WHERE program_id = prog_id AND name = 'Upper B' LIMIT 1;
    SELECT id INTO tmpl_lb FROM workout_templates WHERE program_id = prog_id AND name = 'Lower B' LIMIT 1;

    -- ── Remove any incomplete (dangling) sessions ────────────────────────────
    DELETE FROM workout_sessions
     WHERE user_id = admin_id AND completed_at IS NULL;

    -- ── Body weight logs: add any missing entries up to today ────────────────
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (admin_id, 83.2, '2026-05-19') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (admin_id, 83.1, '2026-05-21') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (admin_id, 83.3, '2026-05-23') ON CONFLICT DO NOTHING;

    -- ── Helper: insert one Upper-A session ───────────────────────────────────
    -- Skips gracefully if template or exercises don't exist

    -- ── Last week: Mon May 12 – Upper A ─────────────────────────────────────
    IF tmpl_ua IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM workout_sessions WHERE user_id = admin_id
          AND started_at::date = '2026-05-12') THEN
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_ua, '2026-05-12 07:30:00+00', '2026-05-12 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 85.00, 10, '2026-05-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 85.00,  9, '2026-05-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 85.00,  8, '2026-05-12 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 57.50, 10, '2026-05-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 57.50,  9, '2026-05-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 57.50,  8, '2026-05-12 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 70.00, 10, '2026-05-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 70.00,  9, '2026-05-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 70.00,  9, '2026-05-12 08:45:00+00');
        END IF;
    END IF;

    -- ── Last week: Tue May 13 – Lower A ─────────────────────────────────────
    IF tmpl_la IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM workout_sessions WHERE user_id = admin_id
          AND started_at::date = '2026-05-13') THEN
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_la, '2026-05-13 07:30:00+00', '2026-05-13 08:50:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 105.00, 10, '2026-05-13 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 105.00,  9, '2026-05-13 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 105.00,  8, '2026-05-13 08:50:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 90.00, 10, '2026-05-13 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 90.00,  9, '2026-05-13 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 90.00,  8, '2026-05-13 08:50:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 150.00, 10, '2026-05-13 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 150.00,  9, '2026-05-13 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 150.00,  8, '2026-05-13 08:50:00+00');
        END IF;
    END IF;

    -- ── Last week: Thu May 15 – Upper B ─────────────────────────────────────
    IF tmpl_ub IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM workout_sessions WHERE user_id = admin_id
          AND started_at::date = '2026-05-15') THEN
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_ub, '2026-05-15 07:30:00+00', '2026-05-15 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 32.50, 10, '2026-05-15 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 32.50,  9, '2026-05-15 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 32.50,  8, '2026-05-15 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 72.50, 10, '2026-05-15 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 72.50,  9, '2026-05-15 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 72.50,  8, '2026-05-15 08:45:00+00');
        END IF;
    END IF;

    -- ── This week: Mon May 19 – Upper A ──────────────────────────────────────
    IF tmpl_ua IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM workout_sessions WHERE user_id = admin_id
          AND started_at::date = '2026-05-19') THEN
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_ua, '2026-05-19 07:30:00+00', '2026-05-19 08:50:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 85.00, 10, '2026-05-19 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 85.00, 10, '2026-05-19 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 85.00,  9, '2026-05-19 08:50:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 57.50, 10, '2026-05-19 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 57.50, 10, '2026-05-19 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 57.50,  8, '2026-05-19 08:50:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 72.50, 10, '2026-05-19 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 72.50, 10, '2026-05-19 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 72.50,  9, '2026-05-19 08:50:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 67.50, 10, '2026-05-19 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 67.50, 10, '2026-05-19 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 67.50,  9, '2026-05-19 08:50:00+00');
        END IF;
    END IF;

    -- ── This week: Tue May 20 – Lower A ──────────────────────────────────────
    IF tmpl_la IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM workout_sessions WHERE user_id = admin_id
          AND started_at::date = '2026-05-20') THEN
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_la, '2026-05-20 07:30:00+00', '2026-05-20 08:55:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 107.50, 10, '2026-05-20 08:55:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 107.50,  9, '2026-05-20 08:55:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 107.50,  9, '2026-05-20 08:55:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 92.50, 10, '2026-05-20 08:55:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 92.50,  9, '2026-05-20 08:55:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 92.50,  8, '2026-05-20 08:55:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 155.00, 10, '2026-05-20 08:55:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 155.00, 10, '2026-05-20 08:55:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 155.00,  9, '2026-05-20 08:55:00+00');
        END IF;
    END IF;

    -- ── This week: Thu May 22 – Upper B ──────────────────────────────────────
    IF tmpl_ub IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM workout_sessions WHERE user_id = admin_id
          AND started_at::date = '2026-05-22') THEN
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_ub, '2026-05-22 07:30:00+00', '2026-05-22 08:50:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 34.00, 10, '2026-05-22 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 34.00,  9, '2026-05-22 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 34.00,  8, '2026-05-22 08:50:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 72.50, 10, '2026-05-22 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 72.50, 10, '2026-05-22 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 72.50,  9, '2026-05-22 08:50:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 1, 67.50, 10, '2026-05-22 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 2, 67.50, 10, '2026-05-22 08:50:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at) VALUES (se_id, 3, 67.50,  9, '2026-05-22 08:50:00+00');
        END IF;
    END IF;

END $$;
