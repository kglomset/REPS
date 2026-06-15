-- V9: Seed workout history and body weight logs for admin@reps.dev
DO $$
DECLARE
    admin_id    BIGINT;
    tmpl_id     BIGINT;
    session_id  BIGINT;
    se_id       BIGINT;
    ex_id       BIGINT;
BEGIN
    SELECT id INTO admin_id FROM users WHERE email = 'admin@reps.dev';
    IF admin_id IS NULL THEN RETURN; END IF;

    DELETE FROM workout_sessions  WHERE user_id = admin_id;
    DELETE FROM body_weight_logs  WHERE user_id = admin_id;

    -- 2026-02-23 Upper A (session 1)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-02-23 08:00:00+00', '2026-02-23 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 80.0, 9, 7, '2026-02-23 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 80.0, 8, 8, '2026-02-23 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 80.0, 7, 9, '2026-02-23 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 80.0, 7, 9, '2026-02-23 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 7, 7, '2026-02-23 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 6, 8, '2026-02-23 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 5, 9, '2026-02-23 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 5, 9, '2026-02-23 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 50.0, 9, 7, '2026-02-23 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 50.0, 8, 8, '2026-02-23 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 50.0, 7, 9, '2026-02-23 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 70.0, 9, 7, '2026-02-23 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 70.0, 8, 8, '2026-02-23 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 70.0, 8, 9, '2026-02-23 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 10, 14, 7, '2026-02-23 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 10, 13, 8, '2026-02-23 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 10, 12, 9, '2026-02-23 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 35.0, 11, 7, '2026-02-23 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 35.0, 10, 8, '2026-02-23 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 35.0, 9, 9, '2026-02-23 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 30.0, 11, 7, '2026-02-23 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 30.0, 10, 8, '2026-02-23 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 30.0, 9, 9, '2026-02-23 09:23:00+00');
    END IF;

    -- 2026-02-24 Lower A (session 1)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-02-24 08:00:00+00', '2026-02-24 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Squat';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 100, 7, 7, '2026-02-24 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 100, 6, 8, '2026-02-24 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 100, 5, 9, '2026-02-24 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 100, 5, 9, '2026-02-24 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 80, 9, 7, '2026-02-24 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 80, 8, 8, '2026-02-24 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 80, 7, 9, '2026-02-24 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 120, 11, 7, '2026-02-24 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 120, 10, 8, '2026-02-24 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 120, 9, 9, '2026-02-24 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 50, 14, 7, '2026-02-24 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 50, 13, 8, '2026-02-24 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 50, 11, 9, '2026-02-24 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 40, 11, 7, '2026-02-24 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 40, 10, 8, '2026-02-24 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 40, 9, 9, '2026-02-24 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 80, 14, 7, '2026-02-24 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 80, 13, 8, '2026-02-24 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 80, 12, 9, '2026-02-24 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 80, 11, 9, '2026-02-24 09:12:00+00');
    END IF;

    -- 2026-02-26 Upper B (session 1)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-02-26 08:00:00+00', '2026-02-26 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 70.0, 9, 7, '2026-02-26 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 70.0, 8, 8, '2026-02-26 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 70.0, 7, 9, '2026-02-26 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 70.0, 7, 9, '2026-02-26 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Chins';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 7, 7, '2026-02-26 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 6, 8, '2026-02-26 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 5, 9, '2026-02-26 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 5, 9, '2026-02-26 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 22, 9, 7, '2026-02-26 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 22, 8, 8, '2026-02-26 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 22, 7, 9, '2026-02-26 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 32, 9, 7, '2026-02-26 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 32, 8, 8, '2026-02-26 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 32, 8, 9, '2026-02-26 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 8, 14, 7, '2026-02-26 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 8, 13, 8, '2026-02-26 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 8, 12, 9, '2026-02-26 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 14, 11, 7, '2026-02-26 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 14, 10, 8, '2026-02-26 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 14, 9, 9, '2026-02-26 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 22, 11, 7, '2026-02-26 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 22, 10, 8, '2026-02-26 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 22, 9, 9, '2026-02-26 09:23:00+00');
    END IF;

    -- 2026-02-27 Lower B (session 1)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-02-27 08:00:00+00', '2026-02-27 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 120, 4, 7, '2026-02-27 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 120, 4, 8, '2026-02-27 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 120, 3, 9, '2026-02-27 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 120, 3, 9, '2026-02-27 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 20, 9, 7, '2026-02-27 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 20, 8, 8, '2026-02-27 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 20, 7, 9, '2026-02-27 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 42, 11, 7, '2026-02-27 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 42, 10, 8, '2026-02-27 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 42, 9, 9, '2026-02-27 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 80, 11, 7, '2026-02-27 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 80, 10, 8, '2026-02-27 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 80, 9, 9, '2026-02-27 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 50, 14, 7, '2026-02-27 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 50, 13, 8, '2026-02-27 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 50, 11, 9, '2026-02-27 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 50, 14, 7, '2026-02-27 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 50, 13, 8, '2026-02-27 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 50, 12, 9, '2026-02-27 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 50, 11, 9, '2026-02-27 09:12:00+00');
    END IF;

    -- 2026-03-02 Upper A (session 2)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-02 08:00:00+00', '2026-03-02 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 80.0, 10, 7, '2026-03-02 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 80.0, 9, 8, '2026-03-02 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 80.0, 8, 9, '2026-03-02 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 80.0, 8, 9, '2026-03-02 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 8, 7, '2026-03-02 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 7, 8, '2026-03-02 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 6, 9, '2026-03-02 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 6, 9, '2026-03-02 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 50.0, 10, 7, '2026-03-02 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 50.0, 9, 8, '2026-03-02 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 50.0, 8, 9, '2026-03-02 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 70.0, 10, 7, '2026-03-02 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 70.0, 9, 8, '2026-03-02 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 70.0, 9, 9, '2026-03-02 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 10, 15, 7, '2026-03-02 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 10, 14, 8, '2026-03-02 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 10, 13, 9, '2026-03-02 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 35.0, 12, 7, '2026-03-02 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 35.0, 11, 8, '2026-03-02 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 35.0, 10, 9, '2026-03-02 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 30.0, 12, 7, '2026-03-02 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 30.0, 11, 8, '2026-03-02 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 30.0, 10, 9, '2026-03-02 09:23:00+00');
    END IF;

    -- 2026-03-03 Lower A (session 2)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-03 08:00:00+00', '2026-03-03 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Squat';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 100, 8, 7, '2026-03-03 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 100, 7, 8, '2026-03-03 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 100, 6, 9, '2026-03-03 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 100, 6, 9, '2026-03-03 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 80, 10, 7, '2026-03-03 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 80, 9, 8, '2026-03-03 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 80, 8, 9, '2026-03-03 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 120, 12, 7, '2026-03-03 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 120, 11, 8, '2026-03-03 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 120, 10, 9, '2026-03-03 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 50, 15, 7, '2026-03-03 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 50, 14, 8, '2026-03-03 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 50, 12, 9, '2026-03-03 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 40, 12, 7, '2026-03-03 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 40, 11, 8, '2026-03-03 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 40, 10, 9, '2026-03-03 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 80, 15, 7, '2026-03-03 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 80, 14, 8, '2026-03-03 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 80, 13, 9, '2026-03-03 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 80, 12, 9, '2026-03-03 09:12:00+00');
    END IF;

    -- 2026-03-05 Upper B (session 2)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-05 08:00:00+00', '2026-03-05 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 70.0, 10, 7, '2026-03-05 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 70.0, 9, 8, '2026-03-05 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 70.0, 8, 9, '2026-03-05 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 70.0, 8, 9, '2026-03-05 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Chins';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 8, 7, '2026-03-05 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 7, 8, '2026-03-05 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 6, 9, '2026-03-05 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 6, 9, '2026-03-05 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 22, 10, 7, '2026-03-05 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 22, 9, 8, '2026-03-05 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 22, 8, 9, '2026-03-05 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 32, 10, 7, '2026-03-05 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 32, 9, 8, '2026-03-05 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 32, 9, 9, '2026-03-05 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 8, 15, 7, '2026-03-05 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 8, 14, 8, '2026-03-05 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 8, 13, 9, '2026-03-05 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 14, 12, 7, '2026-03-05 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 14, 11, 8, '2026-03-05 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 14, 10, 9, '2026-03-05 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 22, 12, 7, '2026-03-05 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 22, 11, 8, '2026-03-05 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 22, 10, 9, '2026-03-05 09:23:00+00');
    END IF;

    -- 2026-03-06 Lower B (session 2)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-06 08:00:00+00', '2026-03-06 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 120, 5, 7, '2026-03-06 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 120, 5, 8, '2026-03-06 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 120, 4, 9, '2026-03-06 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 120, 4, 9, '2026-03-06 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 20, 10, 7, '2026-03-06 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 20, 9, 8, '2026-03-06 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 20, 8, 9, '2026-03-06 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 42, 12, 7, '2026-03-06 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 42, 11, 8, '2026-03-06 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 42, 10, 9, '2026-03-06 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 80, 12, 7, '2026-03-06 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 80, 11, 8, '2026-03-06 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 80, 10, 9, '2026-03-06 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 50, 15, 7, '2026-03-06 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 50, 14, 8, '2026-03-06 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 50, 12, 9, '2026-03-06 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 50, 15, 7, '2026-03-06 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 50, 14, 8, '2026-03-06 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 50, 13, 9, '2026-03-06 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 50, 12, 9, '2026-03-06 09:12:00+00');
    END IF;

    -- 2026-03-09 Upper A (session 3)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-09 08:00:00+00', '2026-03-09 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 82.5, 11, 7, '2026-03-09 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 82.5, 10, 8, '2026-03-09 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 82.5, 9, 9, '2026-03-09 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 82.5, 9, 9, '2026-03-09 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 9, 7, '2026-03-09 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 8, 8, '2026-03-09 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 7, 9, '2026-03-09 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 7, 9, '2026-03-09 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 52.5, 11, 7, '2026-03-09 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 52.5, 10, 8, '2026-03-09 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 52.5, 9, 9, '2026-03-09 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 72.5, 11, 7, '2026-03-09 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 72.5, 10, 8, '2026-03-09 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 72.5, 10, 9, '2026-03-09 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 10, 16, 7, '2026-03-09 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 10, 15, 8, '2026-03-09 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 10, 14, 9, '2026-03-09 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 35.0, 13, 7, '2026-03-09 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 35.0, 12, 8, '2026-03-09 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 35.0, 11, 9, '2026-03-09 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 30.0, 13, 7, '2026-03-09 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 30.0, 12, 8, '2026-03-09 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 30.0, 11, 9, '2026-03-09 09:23:00+00');
    END IF;

    -- 2026-03-10 Lower A (session 3)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-10 08:00:00+00', '2026-03-10 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Squat';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 105, 9, 7, '2026-03-10 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 105, 8, 8, '2026-03-10 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 105, 7, 9, '2026-03-10 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 105, 7, 9, '2026-03-10 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 85, 11, 7, '2026-03-10 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 85, 10, 8, '2026-03-10 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 85, 9, 9, '2026-03-10 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 130, 13, 7, '2026-03-10 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 130, 12, 8, '2026-03-10 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 130, 11, 9, '2026-03-10 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 55, 16, 7, '2026-03-10 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 55, 15, 8, '2026-03-10 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 55, 13, 9, '2026-03-10 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 45, 13, 7, '2026-03-10 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 45, 12, 8, '2026-03-10 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 45, 11, 9, '2026-03-10 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 90, 16, 7, '2026-03-10 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 90, 15, 8, '2026-03-10 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 90, 14, 9, '2026-03-10 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 90, 13, 9, '2026-03-10 09:12:00+00');
    END IF;

    -- 2026-03-12 Upper B (session 3)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-12 08:00:00+00', '2026-03-12 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 72.5, 11, 7, '2026-03-12 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 72.5, 10, 8, '2026-03-12 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 72.5, 9, 9, '2026-03-12 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 72.5, 9, 9, '2026-03-12 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Chins';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 9, 7, '2026-03-12 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 8, 8, '2026-03-12 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 7, 9, '2026-03-12 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 7, 9, '2026-03-12 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 24, 11, 7, '2026-03-12 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 24, 10, 8, '2026-03-12 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 24, 9, 9, '2026-03-12 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 34, 11, 7, '2026-03-12 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 34, 10, 8, '2026-03-12 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 34, 10, 9, '2026-03-12 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 8, 16, 7, '2026-03-12 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 8, 15, 8, '2026-03-12 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 8, 14, 9, '2026-03-12 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 14, 13, 7, '2026-03-12 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 14, 12, 8, '2026-03-12 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 14, 11, 9, '2026-03-12 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 22, 13, 7, '2026-03-12 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 22, 12, 8, '2026-03-12 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 22, 11, 9, '2026-03-12 09:23:00+00');
    END IF;

    -- 2026-03-13 Lower B (session 3)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-13 08:00:00+00', '2026-03-13 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 125, 6, 7, '2026-03-13 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 125, 6, 8, '2026-03-13 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 125, 5, 9, '2026-03-13 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 125, 5, 9, '2026-03-13 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 22, 11, 7, '2026-03-13 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 22, 10, 8, '2026-03-13 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 22, 9, 9, '2026-03-13 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 47, 13, 7, '2026-03-13 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 47, 12, 8, '2026-03-13 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 47, 11, 9, '2026-03-13 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 85, 13, 7, '2026-03-13 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 85, 12, 8, '2026-03-13 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 85, 11, 9, '2026-03-13 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 55, 16, 7, '2026-03-13 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 55, 15, 8, '2026-03-13 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 55, 13, 9, '2026-03-13 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 55, 16, 7, '2026-03-13 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 55, 15, 8, '2026-03-13 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 55, 14, 9, '2026-03-13 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 55, 13, 9, '2026-03-13 09:12:00+00');
    END IF;

    -- 2026-03-16 Upper A (session 4)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-16 08:00:00+00', '2026-03-16 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 82.5, 9, 7, '2026-03-16 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 82.5, 8, 8, '2026-03-16 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 82.5, 7, 9, '2026-03-16 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 82.5, 7, 9, '2026-03-16 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 7, 7, '2026-03-16 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 6, 8, '2026-03-16 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 5, 9, '2026-03-16 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 5, 9, '2026-03-16 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 52.5, 9, 7, '2026-03-16 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 52.5, 8, 8, '2026-03-16 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 52.5, 7, 9, '2026-03-16 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 72.5, 9, 7, '2026-03-16 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 72.5, 8, 8, '2026-03-16 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 72.5, 8, 9, '2026-03-16 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 11, 14, 7, '2026-03-16 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 11, 13, 8, '2026-03-16 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 11, 12, 9, '2026-03-16 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 37.5, 11, 7, '2026-03-16 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 37.5, 10, 8, '2026-03-16 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 37.5, 9, 9, '2026-03-16 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 32.5, 11, 7, '2026-03-16 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 32.5, 10, 8, '2026-03-16 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 32.5, 9, 9, '2026-03-16 09:23:00+00');
    END IF;

    -- 2026-03-17 Lower A (session 4)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-17 08:00:00+00', '2026-03-17 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Squat';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 105, 7, 7, '2026-03-17 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 105, 6, 8, '2026-03-17 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 105, 5, 9, '2026-03-17 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 105, 5, 9, '2026-03-17 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 85, 9, 7, '2026-03-17 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 85, 8, 8, '2026-03-17 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 85, 7, 9, '2026-03-17 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 130, 11, 7, '2026-03-17 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 130, 10, 8, '2026-03-17 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 130, 9, 9, '2026-03-17 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 55, 14, 7, '2026-03-17 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 55, 13, 8, '2026-03-17 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 55, 11, 9, '2026-03-17 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 45, 11, 7, '2026-03-17 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 45, 10, 8, '2026-03-17 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 45, 9, 9, '2026-03-17 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 90, 14, 7, '2026-03-17 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 90, 13, 8, '2026-03-17 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 90, 12, 9, '2026-03-17 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 90, 11, 9, '2026-03-17 09:12:00+00');
    END IF;

    -- 2026-03-19 Upper B (session 4)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-19 08:00:00+00', '2026-03-19 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 72.5, 9, 7, '2026-03-19 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 72.5, 8, 8, '2026-03-19 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 72.5, 7, 9, '2026-03-19 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 72.5, 7, 9, '2026-03-19 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Chins';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 7, 7, '2026-03-19 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 6, 8, '2026-03-19 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 5, 9, '2026-03-19 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 5, 9, '2026-03-19 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 24, 9, 7, '2026-03-19 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 24, 8, 8, '2026-03-19 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 24, 7, 9, '2026-03-19 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 34, 9, 7, '2026-03-19 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 34, 8, 8, '2026-03-19 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 34, 8, 9, '2026-03-19 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 9, 14, 7, '2026-03-19 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 9, 13, 8, '2026-03-19 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 9, 12, 9, '2026-03-19 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 16, 11, 7, '2026-03-19 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 16, 10, 8, '2026-03-19 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 16, 9, 9, '2026-03-19 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 24, 11, 7, '2026-03-19 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 24, 10, 8, '2026-03-19 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 24, 9, 9, '2026-03-19 09:23:00+00');
    END IF;

    -- 2026-03-20 Lower B (session 4)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-20 08:00:00+00', '2026-03-20 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 125, 4, 7, '2026-03-20 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 125, 4, 8, '2026-03-20 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 125, 3, 9, '2026-03-20 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 125, 3, 9, '2026-03-20 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 22, 9, 7, '2026-03-20 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 22, 8, 8, '2026-03-20 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 22, 7, 9, '2026-03-20 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 47, 11, 7, '2026-03-20 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 47, 10, 8, '2026-03-20 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 47, 9, 9, '2026-03-20 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 85, 11, 7, '2026-03-20 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 85, 10, 8, '2026-03-20 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 85, 9, 9, '2026-03-20 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 55, 14, 7, '2026-03-20 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 55, 13, 8, '2026-03-20 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 55, 11, 9, '2026-03-20 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 55, 14, 7, '2026-03-20 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 55, 13, 8, '2026-03-20 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 55, 12, 9, '2026-03-20 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 55, 11, 9, '2026-03-20 09:12:00+00');
    END IF;

    -- 2026-03-23 Upper A (session 5)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-23 08:00:00+00', '2026-03-23 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 85.0, 10, 7, '2026-03-23 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 85.0, 9, 8, '2026-03-23 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 85.0, 8, 9, '2026-03-23 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 85.0, 8, 9, '2026-03-23 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 8, 7, '2026-03-23 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 7, 8, '2026-03-23 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 6, 9, '2026-03-23 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 6, 9, '2026-03-23 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 55.0, 10, 7, '2026-03-23 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 55.0, 9, 8, '2026-03-23 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 55.0, 8, 9, '2026-03-23 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 75.0, 10, 7, '2026-03-23 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 75.0, 9, 8, '2026-03-23 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 75.0, 9, 9, '2026-03-23 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 11, 15, 7, '2026-03-23 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 11, 14, 8, '2026-03-23 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 11, 13, 9, '2026-03-23 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 37.5, 12, 7, '2026-03-23 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 37.5, 11, 8, '2026-03-23 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 37.5, 10, 9, '2026-03-23 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 32.5, 12, 7, '2026-03-23 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 32.5, 11, 8, '2026-03-23 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 32.5, 10, 9, '2026-03-23 09:23:00+00');
    END IF;

    -- 2026-03-24 Lower A (session 5)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-24 08:00:00+00', '2026-03-24 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Squat';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 110, 8, 7, '2026-03-24 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 110, 7, 8, '2026-03-24 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 110, 6, 9, '2026-03-24 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 110, 6, 9, '2026-03-24 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 90, 10, 7, '2026-03-24 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 90, 9, 8, '2026-03-24 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 90, 8, 9, '2026-03-24 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 140, 12, 7, '2026-03-24 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 140, 11, 8, '2026-03-24 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 140, 10, 9, '2026-03-24 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 60, 15, 7, '2026-03-24 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 60, 14, 8, '2026-03-24 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 60, 12, 9, '2026-03-24 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 50, 12, 7, '2026-03-24 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 50, 11, 8, '2026-03-24 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 50, 10, 9, '2026-03-24 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 100, 15, 7, '2026-03-24 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 100, 14, 8, '2026-03-24 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 100, 13, 9, '2026-03-24 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 100, 12, 9, '2026-03-24 09:12:00+00');
    END IF;

    -- 2026-03-26 Upper B (session 5)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-26 08:00:00+00', '2026-03-26 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 75.0, 10, 7, '2026-03-26 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 75.0, 9, 8, '2026-03-26 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 75.0, 8, 9, '2026-03-26 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 75.0, 8, 9, '2026-03-26 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Chins';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 8, 7, '2026-03-26 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 7, 8, '2026-03-26 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 6, 9, '2026-03-26 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 6, 9, '2026-03-26 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 26, 10, 7, '2026-03-26 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 26, 9, 8, '2026-03-26 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 26, 8, 9, '2026-03-26 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 36, 10, 7, '2026-03-26 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 36, 9, 8, '2026-03-26 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 36, 9, 9, '2026-03-26 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 9, 15, 7, '2026-03-26 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 9, 14, 8, '2026-03-26 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 9, 13, 9, '2026-03-26 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 16, 12, 7, '2026-03-26 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 16, 11, 8, '2026-03-26 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 16, 10, 9, '2026-03-26 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 24, 12, 7, '2026-03-26 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 24, 11, 8, '2026-03-26 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 24, 10, 9, '2026-03-26 09:23:00+00');
    END IF;

    -- 2026-03-27 Lower B (session 5)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-27 08:00:00+00', '2026-03-27 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 130, 5, 7, '2026-03-27 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 130, 5, 8, '2026-03-27 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 130, 4, 9, '2026-03-27 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 130, 4, 9, '2026-03-27 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 24, 10, 7, '2026-03-27 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 24, 9, 8, '2026-03-27 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 24, 8, 9, '2026-03-27 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 52, 12, 7, '2026-03-27 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 52, 11, 8, '2026-03-27 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 52, 10, 9, '2026-03-27 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 90, 12, 7, '2026-03-27 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 90, 11, 8, '2026-03-27 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 90, 10, 9, '2026-03-27 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 60, 15, 7, '2026-03-27 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 60, 14, 8, '2026-03-27 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 60, 12, 9, '2026-03-27 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 60, 15, 7, '2026-03-27 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 60, 14, 8, '2026-03-27 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 60, 13, 9, '2026-03-27 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 60, 12, 9, '2026-03-27 09:12:00+00');
    END IF;

    -- 2026-03-30 Upper A (session 6)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-30 08:00:00+00', '2026-03-30 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 85.0, 11, 7, '2026-03-30 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 85.0, 10, 8, '2026-03-30 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 85.0, 9, 9, '2026-03-30 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 85.0, 9, 9, '2026-03-30 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 9, 7, '2026-03-30 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 8, 8, '2026-03-30 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 7, 9, '2026-03-30 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 7, 9, '2026-03-30 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 55.0, 11, 7, '2026-03-30 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 55.0, 10, 8, '2026-03-30 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 55.0, 9, 9, '2026-03-30 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 75.0, 11, 7, '2026-03-30 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 75.0, 10, 8, '2026-03-30 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 75.0, 10, 9, '2026-03-30 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 11, 16, 7, '2026-03-30 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 11, 15, 8, '2026-03-30 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 11, 14, 9, '2026-03-30 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 37.5, 13, 7, '2026-03-30 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 37.5, 12, 8, '2026-03-30 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 37.5, 11, 9, '2026-03-30 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 32.5, 13, 7, '2026-03-30 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 32.5, 12, 8, '2026-03-30 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 32.5, 11, 9, '2026-03-30 09:23:00+00');
    END IF;

    -- 2026-03-31 Lower A (session 6)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-03-31 08:00:00+00', '2026-03-31 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Squat';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 110, 9, 7, '2026-03-31 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 110, 8, 8, '2026-03-31 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 110, 7, 9, '2026-03-31 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 110, 7, 9, '2026-03-31 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 90, 11, 7, '2026-03-31 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 90, 10, 8, '2026-03-31 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 90, 9, 9, '2026-03-31 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 140, 13, 7, '2026-03-31 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 140, 12, 8, '2026-03-31 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 140, 11, 9, '2026-03-31 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 60, 16, 7, '2026-03-31 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 60, 15, 8, '2026-03-31 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 60, 13, 9, '2026-03-31 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 50, 13, 7, '2026-03-31 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 50, 12, 8, '2026-03-31 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 50, 11, 9, '2026-03-31 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 100, 16, 7, '2026-03-31 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 100, 15, 8, '2026-03-31 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 100, 14, 9, '2026-03-31 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 100, 13, 9, '2026-03-31 09:12:00+00');
    END IF;

    -- 2026-04-02 Upper B (session 6)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-02 08:00:00+00', '2026-04-02 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 75.0, 11, 7, '2026-04-02 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 75.0, 10, 8, '2026-04-02 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 75.0, 9, 9, '2026-04-02 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 75.0, 9, 9, '2026-04-02 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Chins';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 9, 7, '2026-04-02 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 8, 8, '2026-04-02 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 7, 9, '2026-04-02 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 7, 9, '2026-04-02 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 26, 11, 7, '2026-04-02 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 26, 10, 8, '2026-04-02 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 26, 9, 9, '2026-04-02 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 36, 11, 7, '2026-04-02 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 36, 10, 8, '2026-04-02 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 36, 10, 9, '2026-04-02 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 9, 16, 7, '2026-04-02 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 9, 15, 8, '2026-04-02 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 9, 14, 9, '2026-04-02 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 16, 13, 7, '2026-04-02 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 16, 12, 8, '2026-04-02 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 16, 11, 9, '2026-04-02 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 24, 13, 7, '2026-04-02 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 24, 12, 8, '2026-04-02 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 24, 11, 9, '2026-04-02 09:23:00+00');
    END IF;

    -- 2026-04-03 Lower B (session 6)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-03 08:00:00+00', '2026-04-03 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 130, 6, 7, '2026-04-03 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 130, 6, 8, '2026-04-03 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 130, 5, 9, '2026-04-03 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 130, 5, 9, '2026-04-03 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 24, 11, 7, '2026-04-03 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 24, 10, 8, '2026-04-03 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 24, 9, 9, '2026-04-03 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 52, 13, 7, '2026-04-03 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 52, 12, 8, '2026-04-03 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 52, 11, 9, '2026-04-03 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 90, 13, 7, '2026-04-03 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 90, 12, 8, '2026-04-03 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 90, 11, 9, '2026-04-03 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 60, 16, 7, '2026-04-03 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 60, 15, 8, '2026-04-03 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 60, 13, 9, '2026-04-03 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 60, 16, 7, '2026-04-03 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 60, 15, 8, '2026-04-03 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 60, 14, 9, '2026-04-03 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 60, 13, 9, '2026-04-03 09:12:00+00');
    END IF;

    -- 2026-04-06 Upper A (session 7)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-06 08:00:00+00', '2026-04-06 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 87.5, 9, 7, '2026-04-06 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 87.5, 8, 8, '2026-04-06 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 87.5, 7, 9, '2026-04-06 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 87.5, 7, 9, '2026-04-06 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 7, 7, '2026-04-06 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 6, 8, '2026-04-06 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 5, 9, '2026-04-06 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 5, 9, '2026-04-06 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 57.5, 9, 7, '2026-04-06 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 57.5, 8, 8, '2026-04-06 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 57.5, 7, 9, '2026-04-06 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 77.5, 9, 7, '2026-04-06 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 77.5, 8, 8, '2026-04-06 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 77.5, 8, 9, '2026-04-06 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 12, 14, 7, '2026-04-06 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 12, 13, 8, '2026-04-06 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 12, 12, 9, '2026-04-06 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 40.0, 11, 7, '2026-04-06 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 40.0, 10, 8, '2026-04-06 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 40.0, 9, 9, '2026-04-06 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 35.0, 11, 7, '2026-04-06 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 35.0, 10, 8, '2026-04-06 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 35.0, 9, 9, '2026-04-06 09:23:00+00');
    END IF;

    -- 2026-04-07 Lower A (session 7)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-07 08:00:00+00', '2026-04-07 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Squat';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 115, 7, 7, '2026-04-07 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 115, 6, 8, '2026-04-07 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 115, 5, 9, '2026-04-07 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 115, 5, 9, '2026-04-07 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 95, 9, 7, '2026-04-07 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 95, 8, 8, '2026-04-07 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 95, 7, 9, '2026-04-07 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 150, 11, 7, '2026-04-07 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 150, 10, 8, '2026-04-07 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 150, 9, 9, '2026-04-07 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 65, 14, 7, '2026-04-07 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 65, 13, 8, '2026-04-07 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 65, 11, 9, '2026-04-07 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 55, 11, 7, '2026-04-07 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 55, 10, 8, '2026-04-07 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 55, 9, 9, '2026-04-07 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 110, 14, 7, '2026-04-07 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 110, 13, 8, '2026-04-07 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 110, 12, 9, '2026-04-07 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 110, 11, 9, '2026-04-07 09:12:00+00');
    END IF;

    -- 2026-04-09 Upper B (session 7)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-09 08:00:00+00', '2026-04-09 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 77.5, 9, 7, '2026-04-09 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 77.5, 8, 8, '2026-04-09 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 77.5, 7, 9, '2026-04-09 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 77.5, 7, 9, '2026-04-09 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Chins';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 7, 7, '2026-04-09 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 6, 8, '2026-04-09 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 5, 9, '2026-04-09 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 5, 9, '2026-04-09 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 28, 9, 7, '2026-04-09 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 28, 8, 8, '2026-04-09 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 28, 7, 9, '2026-04-09 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 38, 9, 7, '2026-04-09 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 38, 8, 8, '2026-04-09 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 38, 8, 9, '2026-04-09 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 10, 14, 7, '2026-04-09 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 10, 13, 8, '2026-04-09 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 10, 12, 9, '2026-04-09 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 18, 11, 7, '2026-04-09 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 18, 10, 8, '2026-04-09 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 18, 9, 9, '2026-04-09 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 26, 11, 7, '2026-04-09 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 26, 10, 8, '2026-04-09 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 26, 9, 9, '2026-04-09 09:23:00+00');
    END IF;

    -- 2026-04-10 Lower B (session 7)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-10 08:00:00+00', '2026-04-10 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 135, 4, 7, '2026-04-10 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 135, 4, 8, '2026-04-10 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 135, 3, 9, '2026-04-10 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 135, 3, 9, '2026-04-10 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 26, 9, 7, '2026-04-10 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 26, 8, 8, '2026-04-10 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 26, 7, 9, '2026-04-10 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 57, 11, 7, '2026-04-10 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 57, 10, 8, '2026-04-10 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 57, 9, 9, '2026-04-10 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 95, 11, 7, '2026-04-10 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 95, 10, 8, '2026-04-10 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 95, 9, 9, '2026-04-10 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 65, 14, 7, '2026-04-10 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 65, 13, 8, '2026-04-10 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 65, 11, 9, '2026-04-10 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 65, 14, 7, '2026-04-10 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 65, 13, 8, '2026-04-10 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 65, 12, 9, '2026-04-10 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 65, 11, 9, '2026-04-10 09:12:00+00');
    END IF;

    -- 2026-04-13 Upper A (session 8)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-13 08:00:00+00', '2026-04-13 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 87.5, 10, 7, '2026-04-13 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 87.5, 9, 8, '2026-04-13 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 87.5, 8, 9, '2026-04-13 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 87.5, 8, 9, '2026-04-13 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 8, 7, '2026-04-13 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 7, 8, '2026-04-13 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 6, 9, '2026-04-13 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 6, 9, '2026-04-13 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 57.5, 10, 7, '2026-04-13 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 57.5, 9, 8, '2026-04-13 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 57.5, 8, 9, '2026-04-13 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 77.5, 10, 7, '2026-04-13 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 77.5, 9, 8, '2026-04-13 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 77.5, 9, 9, '2026-04-13 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 12, 15, 7, '2026-04-13 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 12, 14, 8, '2026-04-13 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 12, 13, 9, '2026-04-13 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 40.0, 12, 7, '2026-04-13 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 40.0, 11, 8, '2026-04-13 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 40.0, 10, 9, '2026-04-13 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 35.0, 12, 7, '2026-04-13 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 35.0, 11, 8, '2026-04-13 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 35.0, 10, 9, '2026-04-13 09:23:00+00');
    END IF;

    -- 2026-04-14 Lower A (session 8)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-14 08:00:00+00', '2026-04-14 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Squat';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 115, 8, 7, '2026-04-14 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 115, 7, 8, '2026-04-14 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 115, 6, 9, '2026-04-14 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 115, 6, 9, '2026-04-14 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 95, 10, 7, '2026-04-14 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 95, 9, 8, '2026-04-14 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 95, 8, 9, '2026-04-14 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 150, 12, 7, '2026-04-14 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 150, 11, 8, '2026-04-14 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 150, 10, 9, '2026-04-14 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 65, 15, 7, '2026-04-14 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 65, 14, 8, '2026-04-14 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 65, 12, 9, '2026-04-14 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 55, 12, 7, '2026-04-14 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 55, 11, 8, '2026-04-14 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 55, 10, 9, '2026-04-14 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 110, 15, 7, '2026-04-14 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 110, 14, 8, '2026-04-14 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 110, 13, 9, '2026-04-14 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 110, 12, 9, '2026-04-14 09:12:00+00');
    END IF;

    -- 2026-04-16 Upper B (session 8)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-16 08:00:00+00', '2026-04-16 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 77.5, 10, 7, '2026-04-16 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 77.5, 9, 8, '2026-04-16 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 77.5, 8, 9, '2026-04-16 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 77.5, 8, 9, '2026-04-16 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Chins';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 8, 7, '2026-04-16 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 7, 8, '2026-04-16 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 6, 9, '2026-04-16 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 6, 9, '2026-04-16 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 28, 10, 7, '2026-04-16 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 28, 9, 8, '2026-04-16 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 28, 8, 9, '2026-04-16 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 38, 10, 7, '2026-04-16 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 38, 9, 8, '2026-04-16 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 38, 9, 9, '2026-04-16 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 10, 15, 7, '2026-04-16 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 10, 14, 8, '2026-04-16 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 10, 13, 9, '2026-04-16 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 18, 12, 7, '2026-04-16 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 18, 11, 8, '2026-04-16 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 18, 10, 9, '2026-04-16 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 26, 12, 7, '2026-04-16 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 26, 11, 8, '2026-04-16 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 26, 10, 9, '2026-04-16 09:23:00+00');
    END IF;

    -- 2026-04-17 Lower B (session 8)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-17 08:00:00+00', '2026-04-17 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 135, 5, 7, '2026-04-17 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 135, 5, 8, '2026-04-17 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 135, 4, 9, '2026-04-17 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 135, 4, 9, '2026-04-17 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 26, 10, 7, '2026-04-17 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 26, 9, 8, '2026-04-17 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 26, 8, 9, '2026-04-17 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 57, 12, 7, '2026-04-17 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 57, 11, 8, '2026-04-17 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 57, 10, 9, '2026-04-17 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 95, 12, 7, '2026-04-17 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 95, 11, 8, '2026-04-17 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 95, 10, 9, '2026-04-17 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 65, 15, 7, '2026-04-17 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 65, 14, 8, '2026-04-17 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 65, 12, 9, '2026-04-17 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 65, 15, 7, '2026-04-17 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 65, 14, 8, '2026-04-17 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 65, 13, 9, '2026-04-17 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 65, 12, 9, '2026-04-17 09:12:00+00');
    END IF;

    -- 2026-04-20 Upper A (session 9)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-20 08:00:00+00', '2026-04-20 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 90.0, 11, 7, '2026-04-20 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 90.0, 10, 8, '2026-04-20 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 90.0, 9, 9, '2026-04-20 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 90.0, 9, 9, '2026-04-20 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 9, 7, '2026-04-20 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 8, 8, '2026-04-20 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 7, 9, '2026-04-20 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 7, 9, '2026-04-20 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 60.0, 11, 7, '2026-04-20 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 60.0, 10, 8, '2026-04-20 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 60.0, 9, 9, '2026-04-20 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 80.0, 11, 7, '2026-04-20 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 80.0, 10, 8, '2026-04-20 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 80.0, 10, 9, '2026-04-20 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 12, 16, 7, '2026-04-20 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 12, 15, 8, '2026-04-20 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 12, 14, 9, '2026-04-20 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 40.0, 13, 7, '2026-04-20 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 40.0, 12, 8, '2026-04-20 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 40.0, 11, 9, '2026-04-20 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 35.0, 13, 7, '2026-04-20 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 35.0, 12, 8, '2026-04-20 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 35.0, 11, 9, '2026-04-20 09:23:00+00');
    END IF;

    -- 2026-04-21 Lower A (session 9)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-21 08:00:00+00', '2026-04-21 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Squat';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 120, 9, 7, '2026-04-21 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 120, 8, 8, '2026-04-21 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 120, 7, 9, '2026-04-21 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 120, 7, 9, '2026-04-21 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 100, 11, 7, '2026-04-21 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 100, 10, 8, '2026-04-21 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 100, 9, 9, '2026-04-21 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 160, 13, 7, '2026-04-21 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 160, 12, 8, '2026-04-21 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 160, 11, 9, '2026-04-21 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 70, 16, 7, '2026-04-21 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 70, 15, 8, '2026-04-21 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 70, 13, 9, '2026-04-21 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 60, 13, 7, '2026-04-21 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 60, 12, 8, '2026-04-21 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 60, 11, 9, '2026-04-21 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 120, 16, 7, '2026-04-21 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 120, 15, 8, '2026-04-21 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 120, 14, 9, '2026-04-21 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 120, 13, 9, '2026-04-21 09:12:00+00');
    END IF;

    -- 2026-04-23 Upper B (session 9)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-23 08:00:00+00', '2026-04-23 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 80.0, 11, 7, '2026-04-23 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 80.0, 10, 8, '2026-04-23 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 80.0, 9, 9, '2026-04-23 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 80.0, 9, 9, '2026-04-23 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Chins';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 9, 7, '2026-04-23 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 8, 8, '2026-04-23 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 7, 9, '2026-04-23 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 7, 9, '2026-04-23 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 30, 11, 7, '2026-04-23 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 30, 10, 8, '2026-04-23 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 30, 9, 9, '2026-04-23 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 40, 11, 7, '2026-04-23 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 40, 10, 8, '2026-04-23 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 40, 10, 9, '2026-04-23 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 10, 16, 7, '2026-04-23 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 10, 15, 8, '2026-04-23 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 10, 14, 9, '2026-04-23 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 18, 13, 7, '2026-04-23 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 18, 12, 8, '2026-04-23 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 18, 11, 9, '2026-04-23 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 26, 13, 7, '2026-04-23 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 26, 12, 8, '2026-04-23 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 26, 11, 9, '2026-04-23 09:23:00+00');
    END IF;

    -- 2026-04-24 Lower B (session 9)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-24 08:00:00+00', '2026-04-24 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 140, 6, 7, '2026-04-24 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 140, 6, 8, '2026-04-24 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 140, 5, 9, '2026-04-24 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 140, 5, 9, '2026-04-24 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 28, 11, 7, '2026-04-24 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 28, 10, 8, '2026-04-24 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 28, 9, 9, '2026-04-24 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 62, 13, 7, '2026-04-24 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 62, 12, 8, '2026-04-24 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 62, 11, 9, '2026-04-24 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 100, 13, 7, '2026-04-24 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 100, 12, 8, '2026-04-24 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 100, 11, 9, '2026-04-24 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 70, 16, 7, '2026-04-24 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 70, 15, 8, '2026-04-24 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 70, 13, 9, '2026-04-24 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 70, 16, 7, '2026-04-24 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 70, 15, 8, '2026-04-24 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 70, 14, 9, '2026-04-24 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 70, 13, 9, '2026-04-24 09:12:00+00');
    END IF;

    -- 2026-04-27 Upper A (session 10)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-27 08:00:00+00', '2026-04-27 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 90.0, 9, 7, '2026-04-27 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 90.0, 8, 8, '2026-04-27 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 90.0, 7, 9, '2026-04-27 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 90.0, 7, 9, '2026-04-27 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 7, 7, '2026-04-27 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 6, 8, '2026-04-27 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 5, 9, '2026-04-27 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 5, 9, '2026-04-27 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 60.0, 9, 7, '2026-04-27 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 60.0, 8, 8, '2026-04-27 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 60.0, 7, 9, '2026-04-27 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 80.0, 9, 7, '2026-04-27 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 80.0, 8, 8, '2026-04-27 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 80.0, 8, 9, '2026-04-27 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 13, 14, 7, '2026-04-27 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 13, 13, 8, '2026-04-27 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 13, 12, 9, '2026-04-27 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 42.5, 11, 7, '2026-04-27 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 42.5, 10, 8, '2026-04-27 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 42.5, 9, 9, '2026-04-27 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 37.5, 11, 7, '2026-04-27 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 37.5, 10, 8, '2026-04-27 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 37.5, 9, 9, '2026-04-27 09:23:00+00');
    END IF;

    -- 2026-04-28 Lower A (session 10)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-28 08:00:00+00', '2026-04-28 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Squat';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 120, 7, 7, '2026-04-28 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 120, 6, 8, '2026-04-28 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 120, 5, 9, '2026-04-28 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 120, 5, 9, '2026-04-28 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 100, 9, 7, '2026-04-28 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 100, 8, 8, '2026-04-28 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 100, 7, 9, '2026-04-28 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 160, 11, 7, '2026-04-28 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 160, 10, 8, '2026-04-28 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 160, 9, 9, '2026-04-28 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 70, 14, 7, '2026-04-28 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 70, 13, 8, '2026-04-28 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 70, 11, 9, '2026-04-28 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 60, 11, 7, '2026-04-28 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 60, 10, 8, '2026-04-28 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 60, 9, 9, '2026-04-28 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 120, 14, 7, '2026-04-28 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 120, 13, 8, '2026-04-28 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 120, 12, 9, '2026-04-28 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 120, 11, 9, '2026-04-28 09:12:00+00');
    END IF;

    -- 2026-04-30 Upper B (session 10)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-04-30 08:00:00+00', '2026-04-30 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 80.0, 9, 7, '2026-04-30 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 80.0, 8, 8, '2026-04-30 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 80.0, 7, 9, '2026-04-30 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 80.0, 7, 9, '2026-04-30 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Chins';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 7, 7, '2026-04-30 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 6, 8, '2026-04-30 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 5, 9, '2026-04-30 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 5, 9, '2026-04-30 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 30, 9, 7, '2026-04-30 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 30, 8, 8, '2026-04-30 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 30, 7, 9, '2026-04-30 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 40, 9, 7, '2026-04-30 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 40, 8, 8, '2026-04-30 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 40, 8, 9, '2026-04-30 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 11, 14, 7, '2026-04-30 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 11, 13, 8, '2026-04-30 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 11, 12, 9, '2026-04-30 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 20, 11, 7, '2026-04-30 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 20, 10, 8, '2026-04-30 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 20, 9, 9, '2026-04-30 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 28, 11, 7, '2026-04-30 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 28, 10, 8, '2026-04-30 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 28, 9, 9, '2026-04-30 09:23:00+00');
    END IF;

    -- 2026-05-01 Lower B (session 10)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-05-01 08:00:00+00', '2026-05-01 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 140, 4, 7, '2026-05-01 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 140, 4, 8, '2026-05-01 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 140, 3, 9, '2026-05-01 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 140, 3, 9, '2026-05-01 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 28, 9, 7, '2026-05-01 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 28, 8, 8, '2026-05-01 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 28, 7, 9, '2026-05-01 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 62, 11, 7, '2026-05-01 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 62, 10, 8, '2026-05-01 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 62, 9, 9, '2026-05-01 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 100, 11, 7, '2026-05-01 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 100, 10, 8, '2026-05-01 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 100, 9, 9, '2026-05-01 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 70, 14, 7, '2026-05-01 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 70, 13, 8, '2026-05-01 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 70, 11, 9, '2026-05-01 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 70, 14, 7, '2026-05-01 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 70, 13, 8, '2026-05-01 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 70, 12, 9, '2026-05-01 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 70, 11, 9, '2026-05-01 09:12:00+00');
    END IF;

    -- 2026-05-04 Upper A (session 11)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-05-04 08:00:00+00', '2026-05-04 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 92.5, 10, 7, '2026-05-04 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 92.5, 9, 8, '2026-05-04 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 92.5, 8, 9, '2026-05-04 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 92.5, 8, 9, '2026-05-04 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 8, 7, '2026-05-04 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 7, 8, '2026-05-04 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 6, 9, '2026-05-04 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 6, 9, '2026-05-04 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 62.5, 10, 7, '2026-05-04 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 62.5, 9, 8, '2026-05-04 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 62.5, 8, 9, '2026-05-04 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 82.5, 10, 7, '2026-05-04 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 82.5, 9, 8, '2026-05-04 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 82.5, 9, 9, '2026-05-04 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 13, 15, 7, '2026-05-04 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 13, 14, 8, '2026-05-04 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 13, 13, 9, '2026-05-04 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 42.5, 12, 7, '2026-05-04 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 42.5, 11, 8, '2026-05-04 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 42.5, 10, 9, '2026-05-04 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 37.5, 12, 7, '2026-05-04 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 37.5, 11, 8, '2026-05-04 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 37.5, 10, 9, '2026-05-04 09:23:00+00');
    END IF;

    -- 2026-05-05 Lower A (session 11)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-05-05 08:00:00+00', '2026-05-05 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Squat';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 125, 8, 7, '2026-05-05 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 125, 7, 8, '2026-05-05 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 125, 6, 9, '2026-05-05 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 125, 6, 9, '2026-05-05 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 105, 10, 7, '2026-05-05 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 105, 9, 8, '2026-05-05 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 105, 8, 9, '2026-05-05 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 170, 12, 7, '2026-05-05 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 170, 11, 8, '2026-05-05 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 170, 10, 9, '2026-05-05 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 75, 15, 7, '2026-05-05 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 75, 14, 8, '2026-05-05 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 75, 12, 9, '2026-05-05 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 65, 12, 7, '2026-05-05 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 65, 11, 8, '2026-05-05 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 65, 10, 9, '2026-05-05 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 130, 15, 7, '2026-05-05 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 130, 14, 8, '2026-05-05 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 130, 13, 9, '2026-05-05 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 130, 12, 9, '2026-05-05 09:12:00+00');
    END IF;

    -- 2026-05-07 Upper B (session 11)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-05-07 08:00:00+00', '2026-05-07 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 82.5, 10, 7, '2026-05-07 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 82.5, 9, 8, '2026-05-07 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 82.5, 8, 9, '2026-05-07 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 82.5, 8, 9, '2026-05-07 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Chins';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 8, 7, '2026-05-07 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 7, 8, '2026-05-07 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 6, 9, '2026-05-07 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 6, 9, '2026-05-07 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 32, 10, 7, '2026-05-07 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 32, 9, 8, '2026-05-07 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 32, 8, 9, '2026-05-07 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 42, 10, 7, '2026-05-07 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 42, 9, 8, '2026-05-07 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 42, 9, 9, '2026-05-07 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 11, 15, 7, '2026-05-07 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 11, 14, 8, '2026-05-07 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 11, 13, 9, '2026-05-07 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 20, 12, 7, '2026-05-07 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 20, 11, 8, '2026-05-07 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 20, 10, 9, '2026-05-07 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 28, 12, 7, '2026-05-07 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 28, 11, 8, '2026-05-07 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 28, 10, 9, '2026-05-07 09:23:00+00');
    END IF;

    -- 2026-05-08 Lower B (session 11)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-05-08 08:00:00+00', '2026-05-08 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 145, 5, 7, '2026-05-08 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 145, 5, 8, '2026-05-08 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 145, 4, 9, '2026-05-08 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 145, 4, 9, '2026-05-08 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 30, 10, 7, '2026-05-08 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 30, 9, 8, '2026-05-08 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 30, 8, 9, '2026-05-08 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 67, 12, 7, '2026-05-08 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 67, 11, 8, '2026-05-08 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 67, 10, 9, '2026-05-08 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 105, 12, 7, '2026-05-08 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 105, 11, 8, '2026-05-08 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 105, 10, 9, '2026-05-08 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 75, 15, 7, '2026-05-08 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 75, 14, 8, '2026-05-08 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 75, 12, 9, '2026-05-08 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 75, 15, 7, '2026-05-08 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 75, 14, 8, '2026-05-08 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 75, 13, 9, '2026-05-08 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 75, 12, 9, '2026-05-08 09:12:00+00');
    END IF;

    -- 2026-05-11 Upper A (session 12)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-05-11 08:00:00+00', '2026-05-11 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 92.5, 11, 7, '2026-05-11 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 92.5, 10, 8, '2026-05-11 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 92.5, 9, 9, '2026-05-11 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 92.5, 9, 9, '2026-05-11 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 9, 7, '2026-05-11 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 8, 8, '2026-05-11 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 7, 9, '2026-05-11 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 7, 9, '2026-05-11 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 62.5, 11, 7, '2026-05-11 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 62.5, 10, 8, '2026-05-11 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 62.5, 9, 9, '2026-05-11 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 82.5, 11, 7, '2026-05-11 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 82.5, 10, 8, '2026-05-11 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 82.5, 10, 9, '2026-05-11 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 13, 16, 7, '2026-05-11 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 13, 15, 8, '2026-05-11 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 13, 14, 9, '2026-05-11 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 42.5, 13, 7, '2026-05-11 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 42.5, 12, 8, '2026-05-11 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 42.5, 11, 9, '2026-05-11 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 37.5, 13, 7, '2026-05-11 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 37.5, 12, 8, '2026-05-11 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 37.5, 11, 9, '2026-05-11 09:23:00+00');
    END IF;

    -- 2026-05-12 Lower A (session 12)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower A';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-05-12 08:00:00+00', '2026-05-12 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Squat';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 125, 9, 7, '2026-05-12 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 125, 8, 8, '2026-05-12 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 125, 7, 9, '2026-05-12 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 125, 7, 9, '2026-05-12 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 105, 11, 7, '2026-05-12 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 105, 10, 8, '2026-05-12 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 105, 9, 9, '2026-05-12 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 170, 13, 7, '2026-05-12 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 170, 12, 8, '2026-05-12 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 170, 11, 9, '2026-05-12 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 75, 16, 7, '2026-05-12 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 75, 15, 8, '2026-05-12 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 75, 13, 9, '2026-05-12 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 65, 13, 7, '2026-05-12 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 65, 12, 8, '2026-05-12 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 65, 11, 9, '2026-05-12 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 130, 16, 7, '2026-05-12 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 130, 15, 8, '2026-05-12 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 130, 14, 9, '2026-05-12 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 130, 13, 9, '2026-05-12 09:12:00+00');
    END IF;

    -- 2026-05-14 Upper B (session 12)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Upper B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-05-14 08:00:00+00', '2026-05-14 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 82.5, 11, 7, '2026-05-14 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 82.5, 10, 8, '2026-05-14 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 82.5, 9, 9, '2026-05-14 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 82.5, 9, 9, '2026-05-14 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Chins';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 0, 9, 7, '2026-05-14 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 0, 8, 8, '2026-05-14 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 0, 7, 9, '2026-05-14 08:25:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 0, 7, 9, '2026-05-14 08:28:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 32, 11, 7, '2026-05-14 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 32, 10, 8, '2026-05-14 08:36:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 32, 9, 9, '2026-05-14 08:39:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 42, 11, 7, '2026-05-14 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 42, 10, 8, '2026-05-14 08:47:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 42, 10, 9, '2026-05-14 08:50:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 11, 16, 7, '2026-05-14 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 11, 15, 8, '2026-05-14 08:58:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 11, 14, 9, '2026-05-14 09:01:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 20, 13, 7, '2026-05-14 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 20, 12, 8, '2026-05-14 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 20, 11, 9, '2026-05-14 09:12:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 7, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 28, 13, 7, '2026-05-14 09:17:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 28, 12, 8, '2026-05-14 09:20:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 28, 11, 9, '2026-05-14 09:23:00+00');
    END IF;

    -- 2026-05-15 Lower B (session 12)
    SELECT wt.id INTO tmpl_id FROM workout_templates wt
        JOIN training_programs tp ON wt.program_id = tp.id
        WHERE tp.user_id = admin_id AND wt.name = 'Lower B';
    INSERT INTO workout_sessions (user_id, template_id, started_at, completed_at)
        VALUES (admin_id, tmpl_id, '2026-05-15 08:00:00+00', '2026-05-15 09:15:00+00')
        RETURNING id INTO session_id;

    SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 1, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 145, 6, 7, '2026-05-15 08:05:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 145, 6, 8, '2026-05-15 08:08:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 145, 5, 9, '2026-05-15 08:11:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 145, 5, 9, '2026-05-15 08:14:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 2, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 30, 11, 7, '2026-05-15 08:19:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 30, 10, 8, '2026-05-15 08:22:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 30, 9, 9, '2026-05-15 08:25:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 3, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 67, 13, 7, '2026-05-15 08:30:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 67, 12, 8, '2026-05-15 08:33:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 67, 11, 9, '2026-05-15 08:36:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 4, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 105, 13, 7, '2026-05-15 08:41:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 105, 12, 8, '2026-05-15 08:44:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 105, 11, 9, '2026-05-15 08:47:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 5, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 75, 16, 7, '2026-05-15 08:52:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 75, 15, 8, '2026-05-15 08:55:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 75, 13, 9, '2026-05-15 08:58:00+00');
    END IF;
    SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise';
    IF ex_id IS NOT NULL THEN
        INSERT INTO session_exercises (session_id, exercise_id, exercise_order, training_method)
            VALUES (session_id, ex_id, 6, 'STRAIGHT_SETS') RETURNING id INTO se_id;
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 1, 75, 16, 7, '2026-05-15 09:03:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 2, 75, 15, 8, '2026-05-15 09:06:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 3, 75, 14, 9, '2026-05-15 09:09:00+00');
        INSERT INTO exercise_sets (session_exercise_id, set_number, weight_kg, reps, rpe, completed_at)
            VALUES (se_id, 4, 75, 13, 9, '2026-05-15 09:12:00+00');
    END IF;

    -- Body weight logs
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.5, '2026-02-24');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.4, '2026-02-26');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.3, '2026-02-28');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.3, '2026-03-03');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.2, '2026-03-05');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.2, '2026-03-07');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.1, '2026-03-10');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-12');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 84.0, '2026-03-14');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.9, '2026-03-17');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.8, '2026-03-19');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.7, '2026-03-21');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.6, '2026-03-24');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.5, '2026-03-26');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.5, '2026-03-28');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.4, '2026-03-31');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.3, '2026-04-02');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.3, '2026-04-04');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.3, '2026-04-07');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.3, '2026-04-09');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.2, '2026-04-11');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.2, '2026-04-14');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.1, '2026-04-16');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.1, '2026-04-18');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 83.0, '2026-04-21');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 82.9, '2026-04-23');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 82.8, '2026-04-25');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 82.7, '2026-04-28');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 82.7, '2026-04-30');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 82.6, '2026-05-02');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 82.6, '2026-05-05');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 82.6, '2026-05-07');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 82.5, '2026-05-09');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 82.5, '2026-05-12');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 82.4, '2026-05-14');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
        VALUES (admin_id, 82.3, '2026-05-16');

END $$;