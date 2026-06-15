-- ============================================================
-- V4: Dev seed data — admin account + ABAB program + 12w history
-- ============================================================

DO $$
DECLARE
    admin_id         BIGINT;
    program_id       BIGINT;
    tmpl_upper_a     BIGINT;
    tmpl_lower_a     BIGINT;
    tmpl_upper_b     BIGINT;
    tmpl_lower_b     BIGINT;
    ex_id            BIGINT;
    sess_id          BIGINT;
    se_id            BIGINT;
BEGIN

    -- ── Admin user ──────────────────────────────────────────────────────
    IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@reps.dev') THEN
        INSERT INTO users (email, password_hash, name, fitness_level)
            VALUES ('admin@reps.dev',
                    '$2b$10$pskCf6O11SrxytYZ3AQHeutf0hHKZjZ4xWyCtfbwmhFNbipfcWMVC',
                    'Admin', 'INTERMEDIATE')
            RETURNING id INTO admin_id;
    ELSE
        SELECT id INTO admin_id FROM users WHERE email = 'admin@reps.dev';
    END IF;

    -- ── Body weight logs ────────────────────────────────────────────────
    DELETE FROM body_weight_logs WHERE user_id = admin_id;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-02-16') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-02-17') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-02-19') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-02-20') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-02-23') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-02-24') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-02-26') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-02-27') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-02') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-03') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-05') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-03-06') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-03-09') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-03-10') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-12') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-13') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-16') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-17') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-19') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-20') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-03-23') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-03-24') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-03-26') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-27') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-30') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-31') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-04-02') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-04-03') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-04-06') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-04-07') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-04-09') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-04-10') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-04-13') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-04-14') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-04-16') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-04-17') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-04-20') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-04-21') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-04-23') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-04-24') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-04-27') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-04-28') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-04-30') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-05-01') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-05-04') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-05-05') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-05-07') ON CONFLICT DO NOTHING;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-05-08') ON CONFLICT DO NOTHING;

    -- ── ABAB Program ───────────────────────────────────────────────────
    IF NOT EXISTS (SELECT 1 FROM training_programs WHERE user_id = admin_id AND name = 'ABAB Upper/Lower') THEN
        INSERT INTO training_programs (user_id, name, fitness_level, goal, strength_days_per_week, cardio_days_per_week, active)
            VALUES (admin_id, 'ABAB Upper/Lower', 'INTERMEDIATE', 'HYPERTROPHY', 4, 0, TRUE)
            RETURNING id INTO program_id;

        INSERT INTO workout_templates (program_id, name, day_index)
            VALUES (program_id, 'Upper A', 0) RETURNING id INTO tmpl_upper_a;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 1, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 2, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 3, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 4, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 5, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 6, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;

        INSERT INTO workout_templates (program_id, name, day_index)
            VALUES (program_id, 'Lower A', 1) RETURNING id INTO tmpl_lower_a;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_a, ex_id, 1, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_a, ex_id, 2, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_a, ex_id, 3, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_a, ex_id, 4, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_a, ex_id, 5, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;

        INSERT INTO workout_templates (program_id, name, day_index)
            VALUES (program_id, 'Upper B', 3) RETURNING id INTO tmpl_upper_b;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 1, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 2, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 3, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 4, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 5, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 6, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;

        INSERT INTO workout_templates (program_id, name, day_index)
            VALUES (program_id, 'Lower B', 4) RETURNING id INTO tmpl_lower_b;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_b, ex_id, 1, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_b, ex_id, 2, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_b, ex_id, 3, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_b, ex_id, 4, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_b, ex_id, 5, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;

        -- ── 12 weeks of session history ─────────────────────────────────
        -- Week 1 Mon Feb 16
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_a, '2026-02-16 07:30:00+00', '2026-02-16 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 80.00, 10, '2026-02-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 80.00, 9, '2026-02-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 80.00, 8, '2026-02-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 55.00, 10, '2026-02-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 55.00, 9, '2026-02-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 55.00, 8, '2026-02-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 67.50, 10, '2026-02-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 67.50, 9, '2026-02-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 67.50, 8, '2026-02-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 65.00, 10, '2026-02-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 65.00, 9, '2026-02-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 65.00, 8, '2026-02-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 35.00, 10, '2026-02-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 35.00, 9, '2026-02-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 35.00, 8, '2026-02-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 30.00, 10, '2026-02-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 30.00, 9, '2026-02-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 30.00, 8, '2026-02-16 08:45:00+00');
        END IF;

        -- Week 1 Tue Feb 17
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_a, '2026-02-17 07:30:00+00', '2026-02-17 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 100.00, 10, '2026-02-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 100.00, 9, '2026-02-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 100.00, 8, '2026-02-17 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 80.00, 10, '2026-02-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 80.00, 9, '2026-02-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 80.00, 8, '2026-02-17 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 120.00, 10, '2026-02-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 120.00, 9, '2026-02-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 120.00, 8, '2026-02-17 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 45.00, 10, '2026-02-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 45.00, 9, '2026-02-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 45.00, 8, '2026-02-17 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 60.00, 10, '2026-02-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 60.00, 9, '2026-02-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 60.00, 8, '2026-02-17 08:45:00+00');
        END IF;

        -- Week 1 Thu Feb 19
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_b, '2026-02-19 07:30:00+00', '2026-02-19 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 30.00, 10, '2026-02-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 30.00, 9, '2026-02-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 30.00, 8, '2026-02-19 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 10, '2026-02-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 9, '2026-02-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 8, '2026-02-19 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 70.00, 10, '2026-02-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 70.00, 9, '2026-02-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 70.00, 8, '2026-02-19 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 10, '2026-02-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 9, '2026-02-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 8, '2026-02-19 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 12.50, 10, '2026-02-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 12.50, 9, '2026-02-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 12.50, 8, '2026-02-19 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 25.00, 10, '2026-02-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 25.00, 9, '2026-02-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 25.00, 8, '2026-02-19 08:45:00+00');
        END IF;

        -- Week 1 Fri Feb 20
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_b, '2026-02-20 07:30:00+00', '2026-02-20 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 120.00, 10, '2026-02-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 120.00, 9, '2026-02-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 120.00, 8, '2026-02-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 20.00, 10, '2026-02-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 20.00, 9, '2026-02-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 20.00, 8, '2026-02-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 120.00, 10, '2026-02-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 120.00, 9, '2026-02-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 120.00, 8, '2026-02-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 50.00, 10, '2026-02-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 50.00, 9, '2026-02-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 50.00, 8, '2026-02-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 45.00, 10, '2026-02-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 45.00, 9, '2026-02-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 45.00, 8, '2026-02-20 08:45:00+00');
        END IF;

        -- Week 2 Mon Feb 23
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_a, '2026-02-23 07:30:00+00', '2026-02-23 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 80.00, 11, '2026-02-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 80.00, 10, '2026-02-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 80.00, 9, '2026-02-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 55.00, 11, '2026-02-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 55.00, 10, '2026-02-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 55.00, 9, '2026-02-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 67.50, 11, '2026-02-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 67.50, 10, '2026-02-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 67.50, 9, '2026-02-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 65.00, 11, '2026-02-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 65.00, 10, '2026-02-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 65.00, 9, '2026-02-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 35.00, 11, '2026-02-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 35.00, 10, '2026-02-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 35.00, 9, '2026-02-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 30.00, 11, '2026-02-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 30.00, 10, '2026-02-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 30.00, 9, '2026-02-23 08:45:00+00');
        END IF;

        -- Week 2 Tue Feb 24
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_a, '2026-02-24 07:30:00+00', '2026-02-24 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 100.00, 11, '2026-02-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 100.00, 10, '2026-02-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 100.00, 9, '2026-02-24 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 80.00, 11, '2026-02-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 80.00, 10, '2026-02-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 80.00, 9, '2026-02-24 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 120.00, 11, '2026-02-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 120.00, 10, '2026-02-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 120.00, 9, '2026-02-24 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 45.00, 11, '2026-02-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 45.00, 10, '2026-02-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 45.00, 9, '2026-02-24 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 60.00, 11, '2026-02-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 60.00, 10, '2026-02-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 60.00, 9, '2026-02-24 08:45:00+00');
        END IF;

        -- Week 2 Thu Feb 26
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_b, '2026-02-26 07:30:00+00', '2026-02-26 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 30.00, 11, '2026-02-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 30.00, 10, '2026-02-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 30.00, 9, '2026-02-26 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 11, '2026-02-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 10, '2026-02-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 9, '2026-02-26 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 70.00, 11, '2026-02-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 70.00, 10, '2026-02-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 70.00, 9, '2026-02-26 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 11, '2026-02-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 10, '2026-02-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 9, '2026-02-26 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 12.50, 11, '2026-02-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 12.50, 10, '2026-02-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 12.50, 9, '2026-02-26 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 25.00, 11, '2026-02-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 25.00, 10, '2026-02-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 25.00, 9, '2026-02-26 08:45:00+00');
        END IF;

        -- Week 2 Fri Feb 27
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_b, '2026-02-27 07:30:00+00', '2026-02-27 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 120.00, 11, '2026-02-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 120.00, 10, '2026-02-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 120.00, 9, '2026-02-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 20.00, 11, '2026-02-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 20.00, 10, '2026-02-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 20.00, 9, '2026-02-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 120.00, 11, '2026-02-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 120.00, 10, '2026-02-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 120.00, 9, '2026-02-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 50.00, 11, '2026-02-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 50.00, 10, '2026-02-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 50.00, 9, '2026-02-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 45.00, 11, '2026-02-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 45.00, 10, '2026-02-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 45.00, 9, '2026-02-27 08:45:00+00');
        END IF;

        -- Week 3 Mon Mar 02
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_a, '2026-03-02 07:30:00+00', '2026-03-02 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 80.00, 12, '2026-03-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 80.00, 11, '2026-03-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 80.00, 10, '2026-03-02 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 55.00, 12, '2026-03-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 55.00, 11, '2026-03-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 55.00, 10, '2026-03-02 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 67.50, 12, '2026-03-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 67.50, 11, '2026-03-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 67.50, 10, '2026-03-02 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 65.00, 12, '2026-03-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 65.00, 11, '2026-03-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 65.00, 10, '2026-03-02 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 35.00, 12, '2026-03-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 35.00, 11, '2026-03-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 35.00, 10, '2026-03-02 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 30.00, 12, '2026-03-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 30.00, 11, '2026-03-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 30.00, 10, '2026-03-02 08:45:00+00');
        END IF;

        -- Week 3 Tue Mar 03
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_a, '2026-03-03 07:30:00+00', '2026-03-03 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 100.00, 12, '2026-03-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 100.00, 11, '2026-03-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 100.00, 10, '2026-03-03 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 80.00, 12, '2026-03-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 80.00, 11, '2026-03-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 80.00, 10, '2026-03-03 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 120.00, 12, '2026-03-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 120.00, 11, '2026-03-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 120.00, 10, '2026-03-03 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 45.00, 12, '2026-03-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 45.00, 11, '2026-03-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 45.00, 10, '2026-03-03 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 60.00, 12, '2026-03-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 60.00, 11, '2026-03-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 60.00, 10, '2026-03-03 08:45:00+00');
        END IF;

        -- Week 3 Thu Mar 05
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_b, '2026-03-05 07:30:00+00', '2026-03-05 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 30.00, 12, '2026-03-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 30.00, 11, '2026-03-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 30.00, 10, '2026-03-05 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 12, '2026-03-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 11, '2026-03-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 10, '2026-03-05 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 70.00, 12, '2026-03-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 70.00, 11, '2026-03-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 70.00, 10, '2026-03-05 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 12, '2026-03-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 11, '2026-03-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 10, '2026-03-05 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 12.50, 12, '2026-03-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 12.50, 11, '2026-03-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 12.50, 10, '2026-03-05 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 25.00, 12, '2026-03-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 25.00, 11, '2026-03-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 25.00, 10, '2026-03-05 08:45:00+00');
        END IF;

        -- Week 3 Fri Mar 06
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_b, '2026-03-06 07:30:00+00', '2026-03-06 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 120.00, 12, '2026-03-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 120.00, 11, '2026-03-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 120.00, 10, '2026-03-06 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 20.00, 12, '2026-03-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 20.00, 11, '2026-03-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 20.00, 10, '2026-03-06 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 120.00, 12, '2026-03-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 120.00, 11, '2026-03-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 120.00, 10, '2026-03-06 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 50.00, 12, '2026-03-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 50.00, 11, '2026-03-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 50.00, 10, '2026-03-06 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 45.00, 12, '2026-03-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 45.00, 11, '2026-03-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 45.00, 10, '2026-03-06 08:45:00+00');
        END IF;

        -- Week 4 Mon Mar 09
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_a, '2026-03-09 07:30:00+00', '2026-03-09 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 80.00, 10, '2026-03-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 80.00, 9, '2026-03-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 80.00, 8, '2026-03-09 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 55.00, 10, '2026-03-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 55.00, 9, '2026-03-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 55.00, 8, '2026-03-09 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 67.50, 10, '2026-03-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 67.50, 9, '2026-03-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 67.50, 8, '2026-03-09 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 65.00, 10, '2026-03-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 65.00, 9, '2026-03-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 65.00, 8, '2026-03-09 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 35.00, 10, '2026-03-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 35.00, 9, '2026-03-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 35.00, 8, '2026-03-09 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 30.00, 10, '2026-03-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 30.00, 9, '2026-03-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 30.00, 8, '2026-03-09 08:45:00+00');
        END IF;

        -- Week 4 Tue Mar 10
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_a, '2026-03-10 07:30:00+00', '2026-03-10 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 100.00, 10, '2026-03-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 100.00, 9, '2026-03-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 100.00, 8, '2026-03-10 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 80.00, 10, '2026-03-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 80.00, 9, '2026-03-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 80.00, 8, '2026-03-10 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 120.00, 10, '2026-03-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 120.00, 9, '2026-03-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 120.00, 8, '2026-03-10 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 45.00, 10, '2026-03-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 45.00, 9, '2026-03-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 45.00, 8, '2026-03-10 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 60.00, 10, '2026-03-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 60.00, 9, '2026-03-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 60.00, 8, '2026-03-10 08:45:00+00');
        END IF;

        -- Week 4 Thu Mar 12
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_b, '2026-03-12 07:30:00+00', '2026-03-12 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 30.00, 10, '2026-03-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 30.00, 9, '2026-03-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 30.00, 8, '2026-03-12 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 10, '2026-03-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 9, '2026-03-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 8, '2026-03-12 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 70.00, 10, '2026-03-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 70.00, 9, '2026-03-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 70.00, 8, '2026-03-12 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 10, '2026-03-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 9, '2026-03-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 8, '2026-03-12 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 12.50, 10, '2026-03-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 12.50, 9, '2026-03-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 12.50, 8, '2026-03-12 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 25.00, 10, '2026-03-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 25.00, 9, '2026-03-12 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 25.00, 8, '2026-03-12 08:45:00+00');
        END IF;

        -- Week 4 Fri Mar 13
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_b, '2026-03-13 07:30:00+00', '2026-03-13 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 120.00, 10, '2026-03-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 120.00, 9, '2026-03-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 120.00, 8, '2026-03-13 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 20.00, 10, '2026-03-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 20.00, 9, '2026-03-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 20.00, 8, '2026-03-13 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 120.00, 10, '2026-03-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 120.00, 9, '2026-03-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 120.00, 8, '2026-03-13 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 50.00, 10, '2026-03-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 50.00, 9, '2026-03-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 50.00, 8, '2026-03-13 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 45.00, 10, '2026-03-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 45.00, 9, '2026-03-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 45.00, 8, '2026-03-13 08:45:00+00');
        END IF;

        -- Week 5 Mon Mar 16
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_a, '2026-03-16 07:30:00+00', '2026-03-16 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 82.50, 10, '2026-03-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 82.50, 9, '2026-03-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 82.50, 8, '2026-03-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 56.25, 10, '2026-03-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 56.25, 9, '2026-03-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 56.25, 8, '2026-03-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 68.75, 10, '2026-03-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 68.75, 9, '2026-03-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 68.75, 8, '2026-03-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 66.25, 10, '2026-03-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 66.25, 9, '2026-03-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 66.25, 8, '2026-03-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 36.25, 10, '2026-03-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 36.25, 9, '2026-03-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 36.25, 8, '2026-03-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 10, '2026-03-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 9, '2026-03-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 8, '2026-03-16 08:45:00+00');
        END IF;

        -- Week 5 Tue Mar 17
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_a, '2026-03-17 07:30:00+00', '2026-03-17 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 102.50, 10, '2026-03-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 102.50, 9, '2026-03-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 102.50, 8, '2026-03-17 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 82.50, 10, '2026-03-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 82.50, 9, '2026-03-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 82.50, 8, '2026-03-17 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 122.50, 10, '2026-03-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 122.50, 9, '2026-03-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 122.50, 8, '2026-03-17 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 46.25, 10, '2026-03-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 46.25, 9, '2026-03-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 46.25, 8, '2026-03-17 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 61.25, 10, '2026-03-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 61.25, 9, '2026-03-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 61.25, 8, '2026-03-17 08:45:00+00');
        END IF;

        -- Week 5 Thu Mar 19
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_b, '2026-03-19 07:30:00+00', '2026-03-19 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 10, '2026-03-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 9, '2026-03-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 8, '2026-03-19 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 10, '2026-03-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 9, '2026-03-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 8, '2026-03-19 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 71.25, 10, '2026-03-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 71.25, 9, '2026-03-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 71.25, 8, '2026-03-19 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 10, '2026-03-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 9, '2026-03-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 8, '2026-03-19 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 12.50, 10, '2026-03-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 12.50, 9, '2026-03-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 12.50, 8, '2026-03-19 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 25.00, 10, '2026-03-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 25.00, 9, '2026-03-19 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 25.00, 8, '2026-03-19 08:45:00+00');
        END IF;

        -- Week 5 Fri Mar 20
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_b, '2026-03-20 07:30:00+00', '2026-03-20 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 122.50, 10, '2026-03-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 122.50, 9, '2026-03-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 122.50, 8, '2026-03-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 20.00, 10, '2026-03-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 20.00, 9, '2026-03-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 20.00, 8, '2026-03-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 122.50, 10, '2026-03-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 122.50, 9, '2026-03-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 122.50, 8, '2026-03-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 51.25, 10, '2026-03-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 51.25, 9, '2026-03-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 51.25, 8, '2026-03-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 46.25, 10, '2026-03-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 46.25, 9, '2026-03-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 46.25, 8, '2026-03-20 08:45:00+00');
        END IF;

        -- Week 6 Mon Mar 23
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_a, '2026-03-23 07:30:00+00', '2026-03-23 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 82.50, 11, '2026-03-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 82.50, 10, '2026-03-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 82.50, 9, '2026-03-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 56.25, 11, '2026-03-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 56.25, 10, '2026-03-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 56.25, 9, '2026-03-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 68.75, 11, '2026-03-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 68.75, 10, '2026-03-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 68.75, 9, '2026-03-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 66.25, 11, '2026-03-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 66.25, 10, '2026-03-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 66.25, 9, '2026-03-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 36.25, 11, '2026-03-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 36.25, 10, '2026-03-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 36.25, 9, '2026-03-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 11, '2026-03-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 10, '2026-03-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 9, '2026-03-23 08:45:00+00');
        END IF;

        -- Week 6 Tue Mar 24
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_a, '2026-03-24 07:30:00+00', '2026-03-24 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 102.50, 11, '2026-03-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 102.50, 10, '2026-03-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 102.50, 9, '2026-03-24 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 82.50, 11, '2026-03-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 82.50, 10, '2026-03-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 82.50, 9, '2026-03-24 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 122.50, 11, '2026-03-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 122.50, 10, '2026-03-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 122.50, 9, '2026-03-24 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 46.25, 11, '2026-03-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 46.25, 10, '2026-03-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 46.25, 9, '2026-03-24 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 61.25, 11, '2026-03-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 61.25, 10, '2026-03-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 61.25, 9, '2026-03-24 08:45:00+00');
        END IF;

        -- Week 6 Thu Mar 26
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_b, '2026-03-26 07:30:00+00', '2026-03-26 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 11, '2026-03-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 10, '2026-03-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 9, '2026-03-26 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 11, '2026-03-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 10, '2026-03-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 9, '2026-03-26 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 71.25, 11, '2026-03-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 71.25, 10, '2026-03-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 71.25, 9, '2026-03-26 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 11, '2026-03-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 10, '2026-03-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 9, '2026-03-26 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 12.50, 11, '2026-03-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 12.50, 10, '2026-03-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 12.50, 9, '2026-03-26 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 25.00, 11, '2026-03-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 25.00, 10, '2026-03-26 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 25.00, 9, '2026-03-26 08:45:00+00');
        END IF;

        -- Week 6 Fri Mar 27
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_b, '2026-03-27 07:30:00+00', '2026-03-27 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 122.50, 11, '2026-03-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 122.50, 10, '2026-03-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 122.50, 9, '2026-03-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 20.00, 11, '2026-03-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 20.00, 10, '2026-03-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 20.00, 9, '2026-03-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 122.50, 11, '2026-03-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 122.50, 10, '2026-03-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 122.50, 9, '2026-03-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 51.25, 11, '2026-03-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 51.25, 10, '2026-03-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 51.25, 9, '2026-03-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 46.25, 11, '2026-03-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 46.25, 10, '2026-03-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 46.25, 9, '2026-03-27 08:45:00+00');
        END IF;

        -- Week 7 Mon Mar 30
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_a, '2026-03-30 07:30:00+00', '2026-03-30 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 82.50, 12, '2026-03-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 82.50, 11, '2026-03-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 82.50, 10, '2026-03-30 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 56.25, 12, '2026-03-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 56.25, 11, '2026-03-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 56.25, 10, '2026-03-30 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 68.75, 12, '2026-03-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 68.75, 11, '2026-03-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 68.75, 10, '2026-03-30 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 66.25, 12, '2026-03-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 66.25, 11, '2026-03-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 66.25, 10, '2026-03-30 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 36.25, 12, '2026-03-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 36.25, 11, '2026-03-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 36.25, 10, '2026-03-30 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 12, '2026-03-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 11, '2026-03-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 10, '2026-03-30 08:45:00+00');
        END IF;

        -- Week 7 Tue Mar 31
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_a, '2026-03-31 07:30:00+00', '2026-03-31 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 102.50, 12, '2026-03-31 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 102.50, 11, '2026-03-31 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 102.50, 10, '2026-03-31 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 82.50, 12, '2026-03-31 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 82.50, 11, '2026-03-31 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 82.50, 10, '2026-03-31 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 122.50, 12, '2026-03-31 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 122.50, 11, '2026-03-31 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 122.50, 10, '2026-03-31 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 46.25, 12, '2026-03-31 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 46.25, 11, '2026-03-31 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 46.25, 10, '2026-03-31 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 61.25, 12, '2026-03-31 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 61.25, 11, '2026-03-31 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 61.25, 10, '2026-03-31 08:45:00+00');
        END IF;

        -- Week 7 Thu Apr 02
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_b, '2026-04-02 07:30:00+00', '2026-04-02 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 12, '2026-04-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 11, '2026-04-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 10, '2026-04-02 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 12, '2026-04-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 11, '2026-04-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 10, '2026-04-02 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 71.25, 12, '2026-04-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 71.25, 11, '2026-04-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 71.25, 10, '2026-04-02 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 12, '2026-04-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 11, '2026-04-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 10, '2026-04-02 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 12.50, 12, '2026-04-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 12.50, 11, '2026-04-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 12.50, 10, '2026-04-02 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 25.00, 12, '2026-04-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 25.00, 11, '2026-04-02 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 25.00, 10, '2026-04-02 08:45:00+00');
        END IF;

        -- Week 7 Fri Apr 03
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_b, '2026-04-03 07:30:00+00', '2026-04-03 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 122.50, 12, '2026-04-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 122.50, 11, '2026-04-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 122.50, 10, '2026-04-03 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 20.00, 12, '2026-04-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 20.00, 11, '2026-04-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 20.00, 10, '2026-04-03 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 122.50, 12, '2026-04-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 122.50, 11, '2026-04-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 122.50, 10, '2026-04-03 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 51.25, 12, '2026-04-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 51.25, 11, '2026-04-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 51.25, 10, '2026-04-03 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 46.25, 12, '2026-04-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 46.25, 11, '2026-04-03 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 46.25, 10, '2026-04-03 08:45:00+00');
        END IF;

        -- Week 8 Mon Apr 06
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_a, '2026-04-06 07:30:00+00', '2026-04-06 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 82.50, 10, '2026-04-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 82.50, 9, '2026-04-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 82.50, 8, '2026-04-06 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 56.25, 10, '2026-04-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 56.25, 9, '2026-04-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 56.25, 8, '2026-04-06 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 68.75, 10, '2026-04-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 68.75, 9, '2026-04-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 68.75, 8, '2026-04-06 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 66.25, 10, '2026-04-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 66.25, 9, '2026-04-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 66.25, 8, '2026-04-06 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 36.25, 10, '2026-04-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 36.25, 9, '2026-04-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 36.25, 8, '2026-04-06 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 10, '2026-04-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 9, '2026-04-06 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 8, '2026-04-06 08:45:00+00');
        END IF;

        -- Week 8 Tue Apr 07
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_a, '2026-04-07 07:30:00+00', '2026-04-07 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 102.50, 10, '2026-04-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 102.50, 9, '2026-04-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 102.50, 8, '2026-04-07 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 82.50, 10, '2026-04-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 82.50, 9, '2026-04-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 82.50, 8, '2026-04-07 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 122.50, 10, '2026-04-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 122.50, 9, '2026-04-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 122.50, 8, '2026-04-07 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 46.25, 10, '2026-04-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 46.25, 9, '2026-04-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 46.25, 8, '2026-04-07 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 61.25, 10, '2026-04-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 61.25, 9, '2026-04-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 61.25, 8, '2026-04-07 08:45:00+00');
        END IF;

        -- Week 8 Thu Apr 09
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_b, '2026-04-09 07:30:00+00', '2026-04-09 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 10, '2026-04-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 9, '2026-04-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 8, '2026-04-09 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 10, '2026-04-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 9, '2026-04-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 8, '2026-04-09 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 71.25, 10, '2026-04-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 71.25, 9, '2026-04-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 71.25, 8, '2026-04-09 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 10, '2026-04-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 9, '2026-04-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 8, '2026-04-09 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 12.50, 10, '2026-04-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 12.50, 9, '2026-04-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 12.50, 8, '2026-04-09 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 25.00, 10, '2026-04-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 25.00, 9, '2026-04-09 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 25.00, 8, '2026-04-09 08:45:00+00');
        END IF;

        -- Week 8 Fri Apr 10
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_b, '2026-04-10 07:30:00+00', '2026-04-10 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 122.50, 10, '2026-04-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 122.50, 9, '2026-04-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 122.50, 8, '2026-04-10 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 20.00, 10, '2026-04-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 20.00, 9, '2026-04-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 20.00, 8, '2026-04-10 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 122.50, 10, '2026-04-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 122.50, 9, '2026-04-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 122.50, 8, '2026-04-10 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 51.25, 10, '2026-04-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 51.25, 9, '2026-04-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 51.25, 8, '2026-04-10 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 46.25, 10, '2026-04-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 46.25, 9, '2026-04-10 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 46.25, 8, '2026-04-10 08:45:00+00');
        END IF;

        -- Week 9 Mon Apr 13
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_a, '2026-04-13 07:30:00+00', '2026-04-13 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 83.75, 10, '2026-04-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 83.75, 9, '2026-04-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 83.75, 8, '2026-04-13 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 57.50, 10, '2026-04-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 57.50, 9, '2026-04-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 57.50, 8, '2026-04-13 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 71.25, 10, '2026-04-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 71.25, 9, '2026-04-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 71.25, 8, '2026-04-13 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 68.75, 10, '2026-04-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 68.75, 9, '2026-04-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 68.75, 8, '2026-04-13 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 36.25, 10, '2026-04-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 36.25, 9, '2026-04-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 36.25, 8, '2026-04-13 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 10, '2026-04-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 9, '2026-04-13 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 8, '2026-04-13 08:45:00+00');
        END IF;

        -- Week 9 Tue Apr 14
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_a, '2026-04-14 07:30:00+00', '2026-04-14 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 105.00, 10, '2026-04-14 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 105.00, 9, '2026-04-14 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 105.00, 8, '2026-04-14 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 83.75, 10, '2026-04-14 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 83.75, 9, '2026-04-14 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 83.75, 8, '2026-04-14 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 126.25, 10, '2026-04-14 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 126.25, 9, '2026-04-14 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 126.25, 8, '2026-04-14 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 47.50, 10, '2026-04-14 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 47.50, 9, '2026-04-14 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 47.50, 8, '2026-04-14 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 62.50, 10, '2026-04-14 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 62.50, 9, '2026-04-14 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 62.50, 8, '2026-04-14 08:45:00+00');
        END IF;

        -- Week 9 Thu Apr 16
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_b, '2026-04-16 07:30:00+00', '2026-04-16 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 10, '2026-04-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 9, '2026-04-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 8, '2026-04-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 10, '2026-04-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 9, '2026-04-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 8, '2026-04-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 73.75, 10, '2026-04-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 73.75, 9, '2026-04-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 73.75, 8, '2026-04-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 10, '2026-04-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 9, '2026-04-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 8, '2026-04-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 12.50, 10, '2026-04-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 12.50, 9, '2026-04-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 12.50, 8, '2026-04-16 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 26.25, 10, '2026-04-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 26.25, 9, '2026-04-16 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 26.25, 8, '2026-04-16 08:45:00+00');
        END IF;

        -- Week 9 Fri Apr 17
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_b, '2026-04-17 07:30:00+00', '2026-04-17 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 126.25, 10, '2026-04-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 126.25, 9, '2026-04-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 126.25, 8, '2026-04-17 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 21.25, 10, '2026-04-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 21.25, 9, '2026-04-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 21.25, 8, '2026-04-17 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 126.25, 10, '2026-04-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 126.25, 9, '2026-04-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 126.25, 8, '2026-04-17 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 52.50, 10, '2026-04-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 52.50, 9, '2026-04-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 52.50, 8, '2026-04-17 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 47.50, 10, '2026-04-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 47.50, 9, '2026-04-17 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 47.50, 8, '2026-04-17 08:45:00+00');
        END IF;

        -- Week 10 Mon Apr 20
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_a, '2026-04-20 07:30:00+00', '2026-04-20 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 83.75, 11, '2026-04-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 83.75, 10, '2026-04-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 83.75, 9, '2026-04-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 57.50, 11, '2026-04-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 57.50, 10, '2026-04-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 57.50, 9, '2026-04-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 71.25, 11, '2026-04-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 71.25, 10, '2026-04-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 71.25, 9, '2026-04-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 68.75, 11, '2026-04-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 68.75, 10, '2026-04-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 68.75, 9, '2026-04-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 36.25, 11, '2026-04-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 36.25, 10, '2026-04-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 36.25, 9, '2026-04-20 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 11, '2026-04-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 10, '2026-04-20 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 9, '2026-04-20 08:45:00+00');
        END IF;

        -- Week 10 Tue Apr 21
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_a, '2026-04-21 07:30:00+00', '2026-04-21 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 105.00, 11, '2026-04-21 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 105.00, 10, '2026-04-21 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 105.00, 9, '2026-04-21 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 83.75, 11, '2026-04-21 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 83.75, 10, '2026-04-21 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 83.75, 9, '2026-04-21 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 126.25, 11, '2026-04-21 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 126.25, 10, '2026-04-21 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 126.25, 9, '2026-04-21 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 47.50, 11, '2026-04-21 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 47.50, 10, '2026-04-21 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 47.50, 9, '2026-04-21 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 62.50, 11, '2026-04-21 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 62.50, 10, '2026-04-21 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 62.50, 9, '2026-04-21 08:45:00+00');
        END IF;

        -- Week 10 Thu Apr 23
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_b, '2026-04-23 07:30:00+00', '2026-04-23 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 11, '2026-04-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 10, '2026-04-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 9, '2026-04-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 11, '2026-04-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 10, '2026-04-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 9, '2026-04-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 73.75, 11, '2026-04-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 73.75, 10, '2026-04-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 73.75, 9, '2026-04-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 11, '2026-04-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 10, '2026-04-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 9, '2026-04-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 12.50, 11, '2026-04-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 12.50, 10, '2026-04-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 12.50, 9, '2026-04-23 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 26.25, 11, '2026-04-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 26.25, 10, '2026-04-23 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 26.25, 9, '2026-04-23 08:45:00+00');
        END IF;

        -- Week 10 Fri Apr 24
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_b, '2026-04-24 07:30:00+00', '2026-04-24 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 126.25, 11, '2026-04-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 126.25, 10, '2026-04-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 126.25, 9, '2026-04-24 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 21.25, 11, '2026-04-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 21.25, 10, '2026-04-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 21.25, 9, '2026-04-24 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 126.25, 11, '2026-04-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 126.25, 10, '2026-04-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 126.25, 9, '2026-04-24 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 52.50, 11, '2026-04-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 52.50, 10, '2026-04-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 52.50, 9, '2026-04-24 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 47.50, 11, '2026-04-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 47.50, 10, '2026-04-24 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 47.50, 9, '2026-04-24 08:45:00+00');
        END IF;

        -- Week 11 Mon Apr 27
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_a, '2026-04-27 07:30:00+00', '2026-04-27 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 83.75, 12, '2026-04-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 83.75, 11, '2026-04-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 83.75, 10, '2026-04-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 57.50, 12, '2026-04-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 57.50, 11, '2026-04-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 57.50, 10, '2026-04-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 71.25, 12, '2026-04-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 71.25, 11, '2026-04-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 71.25, 10, '2026-04-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 68.75, 12, '2026-04-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 68.75, 11, '2026-04-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 68.75, 10, '2026-04-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 36.25, 12, '2026-04-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 36.25, 11, '2026-04-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 36.25, 10, '2026-04-27 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 12, '2026-04-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 11, '2026-04-27 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 10, '2026-04-27 08:45:00+00');
        END IF;

        -- Week 11 Tue Apr 28
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_a, '2026-04-28 07:30:00+00', '2026-04-28 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 105.00, 12, '2026-04-28 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 105.00, 11, '2026-04-28 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 105.00, 10, '2026-04-28 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 83.75, 12, '2026-04-28 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 83.75, 11, '2026-04-28 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 83.75, 10, '2026-04-28 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 126.25, 12, '2026-04-28 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 126.25, 11, '2026-04-28 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 126.25, 10, '2026-04-28 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 47.50, 12, '2026-04-28 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 47.50, 11, '2026-04-28 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 47.50, 10, '2026-04-28 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 62.50, 12, '2026-04-28 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 62.50, 11, '2026-04-28 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 62.50, 10, '2026-04-28 08:45:00+00');
        END IF;

        -- Week 11 Thu Apr 30
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_b, '2026-04-30 07:30:00+00', '2026-04-30 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 12, '2026-04-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 11, '2026-04-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 10, '2026-04-30 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 12, '2026-04-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 11, '2026-04-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 10, '2026-04-30 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 73.75, 12, '2026-04-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 73.75, 11, '2026-04-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 73.75, 10, '2026-04-30 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 12, '2026-04-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 11, '2026-04-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 10, '2026-04-30 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 12.50, 12, '2026-04-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 12.50, 11, '2026-04-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 12.50, 10, '2026-04-30 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 26.25, 12, '2026-04-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 26.25, 11, '2026-04-30 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 26.25, 10, '2026-04-30 08:45:00+00');
        END IF;

        -- Week 11 Fri May 01
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_b, '2026-05-01 07:30:00+00', '2026-05-01 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 126.25, 12, '2026-05-01 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 126.25, 11, '2026-05-01 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 126.25, 10, '2026-05-01 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 21.25, 12, '2026-05-01 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 21.25, 11, '2026-05-01 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 21.25, 10, '2026-05-01 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 126.25, 12, '2026-05-01 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 126.25, 11, '2026-05-01 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 126.25, 10, '2026-05-01 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 52.50, 12, '2026-05-01 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 52.50, 11, '2026-05-01 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 52.50, 10, '2026-05-01 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 47.50, 12, '2026-05-01 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 47.50, 11, '2026-05-01 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 47.50, 10, '2026-05-01 08:45:00+00');
        END IF;

        -- Week 12 Mon May 04
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_a, '2026-05-04 07:30:00+00', '2026-05-04 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 83.75, 10, '2026-05-04 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 83.75, 9, '2026-05-04 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 83.75, 8, '2026-05-04 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Overhead Press (Barbell)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 57.50, 10, '2026-05-04 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 57.50, 9, '2026-05-04 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 57.50, 8, '2026-05-04 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Seated Cable Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 71.25, 10, '2026-05-04 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 71.25, 9, '2026-05-04 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 71.25, 8, '2026-05-04 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lat Pulldown' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 68.75, 10, '2026-05-04 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 68.75, 9, '2026-05-04 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 68.75, 8, '2026-05-04 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Triceps Pushdown (Cable)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 36.25, 10, '2026-05-04 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 36.25, 9, '2026-05-04 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 36.25, 8, '2026-05-04 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Curl' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 10, '2026-05-04 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 9, '2026-05-04 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 8, '2026-05-04 08:45:00+00');
        END IF;

        -- Week 12 Tue May 05
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_a, '2026-05-05 07:30:00+00', '2026-05-05 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Back Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 105.00, 10, '2026-05-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 105.00, 9, '2026-05-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 105.00, 8, '2026-05-05 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 83.75, 10, '2026-05-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 83.75, 9, '2026-05-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 83.75, 8, '2026-05-05 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 126.25, 10, '2026-05-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 126.25, 9, '2026-05-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 126.25, 8, '2026-05-05 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 47.50, 10, '2026-05-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 47.50, 9, '2026-05-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 47.50, 8, '2026-05-05 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Calf Raise (Standing)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 62.50, 10, '2026-05-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 62.50, 9, '2026-05-05 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 62.50, 8, '2026-05-05 08:45:00+00');
        END IF;

        -- Week 12 Thu May 07
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_upper_b, '2026-05-07 07:30:00+00', '2026-05-07 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Dumbbell Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 31.25, 10, '2026-05-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 31.25, 9, '2026-05-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 31.25, 8, '2026-05-07 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dips (Chest-Focused)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 10, '2026-05-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 9, '2026-05-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 8, '2026-05-07 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Row' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 73.75, 10, '2026-05-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 73.75, 9, '2026-05-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 73.75, 8, '2026-05-07 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull-Up / Chin-Up' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, NULL, 10, '2026-05-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, NULL, 9, '2026-05-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, NULL, 8, '2026-05-07 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Lateral Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 12.50, 10, '2026-05-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 12.50, 9, '2026-05-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 12.50, 8, '2026-05-07 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Face Pull' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 26.25, 10, '2026-05-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 26.25, 9, '2026-05-07 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 26.25, 8, '2026-05-07 08:45:00+00');
        END IF;

        -- Week 12 Fri May 08
        INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
            VALUES (admin_id, tmpl_lower_b, '2026-05-08 07:30:00+00', '2026-05-08 08:45:00+00')
            RETURNING id INTO sess_id;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Conventional Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 126.25, 10, '2026-05-08 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 126.25, 9, '2026-05-08 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 126.25, 8, '2026-05-08 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 21.25, 10, '2026-05-08 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 21.25, 9, '2026-05-08 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 21.25, 8, '2026-05-08 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 126.25, 10, '2026-05-08 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 126.25, 9, '2026-05-08 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 126.25, 8, '2026-05-08 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Extension (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 52.50, 10, '2026-05-08 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 52.50, 9, '2026-05-08 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 52.50, 8, '2026-05-08 08:45:00+00');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl (Machine)' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
                VALUES (sess_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 1, 47.50, 10, '2026-05-08 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 2, 47.50, 9, '2026-05-08 08:45:00+00');
            INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, completed_at)
                VALUES (se_id, 3, 47.50, 8, '2026-05-08 08:45:00+00');
        END IF;

    END IF;
END $$;
