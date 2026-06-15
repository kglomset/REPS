-- ============================================================
-- V8: Replace exercise library and reseed admin sample data
-- ============================================================
DO $$
DECLARE
    admin_id       BIGINT;
    program_id     BIGINT;
    tmpl_upper_a   BIGINT;
    tmpl_lower_a   BIGINT;
    tmpl_upper_b   BIGINT;
    tmpl_lower_b   BIGINT;
    ex_id          BIGINT;
BEGIN

    -- ── 1. Add Obliques muscle group ─────────────────────────────────
    INSERT INTO muscle_groups (name, slug)
        VALUES ('Obliques', 'obliques')
        ON CONFLICT (slug) DO NOTHING;

    -- ── 2. Wipe admin@reps.dev workout & session data ────────────────
    SELECT id INTO admin_id FROM users WHERE email = 'admin@reps.dev';
    IF admin_id IS NOT NULL THEN
        DELETE FROM workout_sessions WHERE user_id = admin_id;
        DELETE FROM training_programs WHERE user_id = admin_id;
        DELETE FROM body_weight_logs  WHERE user_id = admin_id;
    END IF;

    -- ── 3. Wipe all exercises (cascades exercise_muscles) ────────────
    --    workout_template_exercises and session_exercises are already
    --    gone via the cascade above.
    DELETE FROM exercises;

    -- ── 4. Insert exercises and muscle mappings ──────────────────────
    INSERT INTO exercises (name) VALUES ('Squat') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Front Squat') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Forward Lunge Barbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Forward Lunge Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Backward Lunge Barbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Backward Lunge Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Walking Lunge Barbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Walking Lunge Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Bulgarian Split Squat Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Bulgarian Split Squat Barbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Machine Leg Press') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Leg extension') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';

    INSERT INTO exercises (name) VALUES ('Sissy Squat') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';

    INSERT INTO exercises (name) VALUES ('Box Step Up') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'quads';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Nordic Hamstring') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Back Extensions') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'hamstrings';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'lower-back';

    INSERT INTO exercises (name) VALUES ('GHR') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'hamstrings';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'lower-back';

    INSERT INTO exercises (name) VALUES ('Leg Curl Sitting') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Leg Curl Prone') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Leg Curl TRX') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'hamstrings';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'glutes';

    INSERT INTO exercises (name) VALUES ('Deadlift') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'hamstrings';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lower-back';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'quads';

    INSERT INTO exercises (name) VALUES ('Stiff Legged Deadlift') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'hamstrings';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lower-back';

    INSERT INTO exercises (name) VALUES ('Romanian Deadlift') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'hamstrings';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lower-back';

    INSERT INTO exercises (name) VALUES ('Good Mornings') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'hamstrings';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lower-back';

    INSERT INTO exercises (name) VALUES ('Hip Thrust Bardbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Hip Abductor Machine') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';

    INSERT INTO exercises (name) VALUES ('Hip Thrust Machine') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'glutes';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'hamstrings';

    INSERT INTO exercises (name) VALUES ('Shoulder Press Barbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'side-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'traps';

    INSERT INTO exercises (name) VALUES ('Shoulder Press Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'side-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'traps';

    INSERT INTO exercises (name) VALUES ('Front Raise') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'side-delts';

    INSERT INTO exercises (name) VALUES ('Shoulder Press Smith') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'side-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'traps';

    INSERT INTO exercises (name) VALUES ('Upright Row Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'side-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'rear-delts';

    INSERT INTO exercises (name) VALUES ('Upright Row Barbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'side-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'rear-delts';

    INSERT INTO exercises (name) VALUES ('Upright Row Smith') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'side-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'rear-delts';

    INSERT INTO exercises (name) VALUES ('Lateral Raise Cable Unilateral with Cuff') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'side-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'rear-delts';

    INSERT INTO exercises (name) VALUES ('Lateral Raise Cable Unilateral') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'side-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'rear-delts';

    INSERT INTO exercises (name) VALUES ('Lateral Raise Cable Bilateral') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'side-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'rear-delts';

    INSERT INTO exercises (name) VALUES ('Upright Row Cable') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'side-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'rear-delts';

    INSERT INTO exercises (name) VALUES ('Lateral Raise Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'side-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'rear-delts';

    INSERT INTO exercises (name) VALUES ('Supine Lateral Raise Cable Bilateral') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'side-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'rear-delts';

    INSERT INTO exercises (name) VALUES ('Reverse Fly Cable') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'rear-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'upper-back';

    INSERT INTO exercises (name) VALUES ('Reverse Fly Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'rear-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'upper-back';

    INSERT INTO exercises (name) VALUES ('Facepull Cable') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'rear-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'upper-back';

    INSERT INTO exercises (name) VALUES ('Reverse Pec Dec') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'rear-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'upper-back';

    INSERT INTO exercises (name) VALUES ('Bench Press') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Chest Press Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Incline Chest Press Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Incline Chest Press Barbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Bench Press Smith') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';

    INSERT INTO exercises (name) VALUES ('Incline Chest Press Smith') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Dips') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'triceps';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';

    INSERT INTO exercises (name) VALUES ('Pec Dec') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';

    INSERT INTO exercises (name) VALUES ('Cable Fly') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';

    INSERT INTO exercises (name) VALUES ('Push Up') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Push Up with Weight') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Chest Press Machine') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Incline Chest Press Machine') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'front-delts';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Decline Chest Press Machine') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Dumbbell Fly') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'chest';

    INSERT INTO exercises (name) VALUES ('Pull Up Wide Grip') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Pull Up Narrow Grip') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'upper-back';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Pull Up Neutral Grip') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'upper-back';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Chins') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'biceps';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'upper-back';

    INSERT INTO exercises (name) VALUES ('Pull Down Wide Grip') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Pull Down Narrow Grip') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'upper-back';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Pull Down Neutral Grip') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'biceps';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'upper-back';

    INSERT INTO exercises (name) VALUES ('Cable Pull Over') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';

    INSERT INTO exercises (name) VALUES ('Pendlay Rows') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'upper-back';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Barbell Bent Over Rows') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'upper-back';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Dumbbell Row Unilateral') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'upper-back';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Dumbbell Bent Over Rows') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'upper-back';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Wide Grip Machine Row') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'upper-back';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Narrow Grip Machine Row') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'upper-back';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Narrow Grip Cable Row') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'upper-back';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Wide Grip Cable Row') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'lats';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'upper-back';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Barbell Shrugs') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'traps';

    INSERT INTO exercises (name) VALUES ('Dumbbell Shrugs') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'traps';

    INSERT INTO exercises (name) VALUES ('Tricep Press Dumbbell Supine') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Tricep Press Overhead Cable') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Tricep Pushdown Cable with Rope') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Tricep Pushdown Cable') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Tricep Pushdown Cable Unilateral') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Tricep Press Overhead Cable Unilateral') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('JM Press Smith') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'triceps';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';

    INSERT INTO exercises (name) VALUES ('Skull Chrushers') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'triceps';

    INSERT INTO exercises (name) VALUES ('Narrow Grip Bench Press') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'triceps';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'front-delts';

    INSERT INTO exercises (name) VALUES ('Bicep Curl EZ Bar') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Incline Bicep Curl Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Bicep Curl Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Bicep Curl Barbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Bicep Curl Cable') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Preacher Curl EZ Bar') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Preacher Curl Dumbbell') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Bicep Curl Cable Unilateral') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'biceps';

    INSERT INTO exercises (name) VALUES ('Bosu Crunch') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'abs';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'obliques';

    INSERT INTO exercises (name) VALUES ('Cable Crunch') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'abs';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'obliques';

    INSERT INTO exercises (name) VALUES ('Leg Raise') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'abs';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'obliques';

    INSERT INTO exercises (name) VALUES ('Ab Wheel Roll Out') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'abs';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'obliques';

    INSERT INTO exercises (name) VALUES ('Rotation Cable') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'obliques';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'abs';

    INSERT INTO exercises (name) VALUES ('Bent Over Rotation Cable') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'obliques';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'abs';

    INSERT INTO exercises (name) VALUES ('Incline Knee Raise') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'abs';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'obliques';

    INSERT INTO exercises (name) VALUES ('Hanging Knee Raise') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'abs';
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'SECONDARY' FROM muscle_groups WHERE slug = 'obliques';

    INSERT INTO exercises (name) VALUES ('Side Extensions 45 Degree') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'obliques';

    INSERT INTO exercises (name) VALUES ('Sitting Calf Raise') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'calves';

    INSERT INTO exercises (name) VALUES ('Standing Calf Raise') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'calves';

    INSERT INTO exercises (name) VALUES ('Stiff Legged Calf Raise') RETURNING id INTO ex_id;
    INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
        SELECT ex_id, id, 'PRIMARY' FROM muscle_groups WHERE slug = 'calves';

    -- ── 5. Seed admin@reps.dev sample program (Upper/Lower split) ────
    IF admin_id IS NOT NULL THEN
        INSERT INTO training_programs (user_id, name, fitness_level, goal, strength_days_per_week, cardio_days_per_week, active)
            VALUES (admin_id, 'Upper/Lower Hypertrophy', 'INTERMEDIATE', 'HYPERTROPHY', 4, 1, TRUE)
            RETURNING id INTO program_id;

        INSERT INTO workout_templates (program_id, name, day_index)
            VALUES (program_id, 'Upper A', 0) RETURNING id INTO tmpl_upper_a;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bench Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 1, 4, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Pull Up Wide Grip' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 2, 4, 6, 10, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Barbell' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 3, 3, 8, 12, 90, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Barbell Bent Over Rows' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 4, 3, 8, 12, 90, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Lateral Raise Dumbbell' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 5, 3, 12, 20, 60, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bicep Curl Barbell' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 6, 3, 10, 15, 60, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Pushdown Cable' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_a, ex_id, 7, 3, 10, 15, 60, 'STRAIGHT_SETS');
        END IF;

        INSERT INTO workout_templates (program_id, name, day_index)
            VALUES (program_id, 'Lower A', 1) RETURNING id INTO tmpl_lower_a;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Squat' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_a, ex_id, 1, 4, 6, 10, 180, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Romanian Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_a, ex_id, 2, 3, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Machine Leg Press' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_a, ex_id, 3, 3, 10, 15, 90, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_a, ex_id, 4, 3, 12, 20, 60, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Prone' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_a, ex_id, 5, 3, 10, 15, 60, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Standing Calf Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_a, ex_id, 6, 4, 10, 20, 60, 'STRAIGHT_SETS');
        END IF;

        INSERT INTO workout_templates (program_id, name, day_index)
            VALUES (program_id, 'Upper B', 3) RETURNING id INTO tmpl_upper_b;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Chest Press Barbell' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 1, 4, 8, 12, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Chins' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 2, 4, 6, 10, 120, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Shoulder Press Dumbbell' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 3, 3, 8, 12, 90, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Dumbbell Row Unilateral' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 4, 3, 8, 12, 90, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Reverse Fly Dumbbell' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 5, 3, 12, 20, 60, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Incline Bicep Curl Dumbbell' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 6, 3, 10, 15, 60, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Tricep Press Dumbbell Supine' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_upper_b, ex_id, 7, 3, 10, 15, 60, 'STRAIGHT_SETS');
        END IF;

        INSERT INTO workout_templates (program_id, name, day_index)
            VALUES (program_id, 'Lower B', 4) RETURNING id INTO tmpl_lower_b;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Deadlift' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_b, ex_id, 1, 4, 4, 6, 180, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Bulgarian Split Squat Dumbbell' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_b, ex_id, 2, 3, 8, 12, 90, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg Curl Sitting' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_b, ex_id, 3, 3, 10, 15, 60, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Hip Thrust Bardbell' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_b, ex_id, 4, 3, 10, 15, 90, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Leg extension' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_b, ex_id, 5, 3, 12, 20, 60, 'STRAIGHT_SETS');
        END IF;
        SELECT id INTO ex_id FROM exercises WHERE name = 'Sitting Calf Raise' LIMIT 1;
        IF ex_id IS NOT NULL THEN
            INSERT INTO workout_template_exercises
                (template_id, exercise_id, exercise_order, sets, reps_min, reps_max, rest_seconds, training_method)
                VALUES (tmpl_lower_b, ex_id, 6, 4, 10, 20, 60, 'STRAIGHT_SETS');
        END IF;

    END IF; -- admin_id IS NOT NULL

END $$;