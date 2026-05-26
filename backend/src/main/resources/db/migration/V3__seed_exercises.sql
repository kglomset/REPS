-- ============================================================
-- V3: Seed exercise database
-- Primary muscle  → role = 'PRIMARY'  (1 set = 1 set toward volume)
-- Secondary muscle→ role = 'SECONDARY' (1 set = 0.5 sets toward volume)
-- ============================================================

-- Helper: insert exercise + return id
DO $$
DECLARE
    -- muscle group IDs
    mg_chest        BIGINT; mg_upper_back BIGINT; mg_lats    BIGINT;
    mg_rear_delts   BIGINT; mg_front_delts BIGINT; mg_side_delts BIGINT;
    mg_biceps       BIGINT; mg_triceps BIGINT; mg_forearms BIGINT;
    mg_quads        BIGINT; mg_hamstrings BIGINT; mg_glutes  BIGINT;
    mg_calves       BIGINT; mg_abs BIGINT; mg_lower_back BIGINT;
    mg_traps        BIGINT; mg_shoulders BIGINT;

    -- exercise IDs
    e_id            BIGINT;
BEGIN
    -- Load muscle group IDs
    SELECT id INTO mg_chest        FROM muscle_groups WHERE slug='chest';
    SELECT id INTO mg_upper_back   FROM muscle_groups WHERE slug='upper-back';
    SELECT id INTO mg_lats         FROM muscle_groups WHERE slug='lats';
    SELECT id INTO mg_rear_delts   FROM muscle_groups WHERE slug='rear-delts';
    SELECT id INTO mg_front_delts  FROM muscle_groups WHERE slug='front-delts';
    SELECT id INTO mg_side_delts   FROM muscle_groups WHERE slug='side-delts';
    SELECT id INTO mg_biceps       FROM muscle_groups WHERE slug='biceps';
    SELECT id INTO mg_triceps      FROM muscle_groups WHERE slug='triceps';
    SELECT id INTO mg_forearms     FROM muscle_groups WHERE slug='forearms';
    SELECT id INTO mg_quads        FROM muscle_groups WHERE slug='quads';
    SELECT id INTO mg_hamstrings   FROM muscle_groups WHERE slug='hamstrings';
    SELECT id INTO mg_glutes       FROM muscle_groups WHERE slug='glutes';
    SELECT id INTO mg_calves       FROM muscle_groups WHERE slug='calves';
    SELECT id INTO mg_abs          FROM muscle_groups WHERE slug='abs';
    SELECT id INTO mg_lower_back   FROM muscle_groups WHERE slug='lower-back';
    SELECT id INTO mg_traps        FROM muscle_groups WHERE slug='traps';
    SELECT id INTO mg_shoulders    FROM muscle_groups WHERE slug='shoulders';

    -- ── CHEST ──────────────────────────────────────────────────────────────

    INSERT INTO exercises (name, description, cues) VALUES (
        'Barbell Bench Press',
        'The king of chest exercises. Lie on a flat bench, grip the bar slightly wider than shoulder-width, and press from chest to lockout.',
        'Retract scapulae and plant them into the bench. Drive feet into the floor. Touch mid-chest. Bar path should arc slightly toward your face on the way up.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_chest, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_front_delts, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_triceps, 'SECONDARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Incline Dumbbell Press',
        'Set bench to 30-45°. Promotes upper-chest development.',
        'Keep elbows at ~60° from torso. Lower dumbbells to chest level. Press explosively, touch at top without locking out elbows.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_chest, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_front_delts, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_triceps, 'SECONDARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Cable Fly / Pec Deck',
        'Isolation movement for the chest. Great for stretch and peak contraction.',
        'Keep a slight bend in elbows throughout. Focus on squeezing pecs together at the midpoint. Control the eccentric.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_chest, 'PRIMARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Dips (Chest-Focused)',
        'Forward lean emphasises chest over triceps. Use parallel bars.',
        'Lean torso ~30° forward. Go to 90° elbow bend or beyond if shoulders allow. Control descent.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_chest, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_triceps, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_front_delts, 'SECONDARY');

    -- ── BACK ───────────────────────────────────────────────────────────────

    INSERT INTO exercises (name, description, cues) VALUES (
        'Barbell Row',
        'Compound horizontal pull. Hinge at hips, pull bar to lower chest/upper abs.',
        'Maintain neutral spine. Pull with elbows, not hands. Squeeze upper back at the top. Controlled eccentric.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_upper_back, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_lats, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_biceps, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_rear_delts, 'SECONDARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Pull-Up / Chin-Up',
        'Bodyweight vertical pull. Chin-up (supinated) hits biceps more; pull-up (pronated) hits lats more.',
        'Start from a dead hang. Pull chest to bar. Avoid kipping. Control the descent over 2-3 seconds.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_lats, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_upper_back, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_biceps, 'SECONDARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Lat Pulldown',
        'Cable-based vertical pull. Good lat isolation, easier to load than pull-ups.',
        'Grip just outside shoulder-width. Lean back slightly. Pull bar to upper chest. Stretch lats fully at the top.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_lats, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_biceps, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_upper_back, 'SECONDARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Seated Cable Row',
        'Horizontal pull with constant tension. Great for mid-back thickness.',
        'Sit tall, chest out. Pull handle to lower sternum. Squeeze scapulae together at end. Do not round back on return.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_upper_back, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_lats, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_biceps, 'SECONDARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Face Pull',
        'Rear delt and external-rotation focused cable exercise. Essential for shoulder health.',
        'Set cable at face height. Use rope attachment. Pull to forehead, flare elbows outward. Squeeze rear delts.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_rear_delts, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_traps, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_upper_back, 'SECONDARY');

    -- ── SHOULDERS ──────────────────────────────────────────────────────────

    INSERT INTO exercises (name, description, cues) VALUES (
        'Overhead Press (Barbell)',
        'Standing or seated barbell press overhead. Builds front and side delts + traps.',
        'Grip slightly outside shoulder-width. Bar starts at clavicle. Press straight up, lock out arms. Avoid excessive back arch.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_front_delts, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_side_delts, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_triceps, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_traps, 'SECONDARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Dumbbell Lateral Raise',
        'Isolation for side delts. Key for shoulder width.',
        'Slight forward lean. Lead with elbows. Raise to just above shoulder height. Slow eccentric (3 sec down).'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_side_delts, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_front_delts, 'SECONDARY');

    -- ── ARMS ───────────────────────────────────────────────────────────────

    INSERT INTO exercises (name, description, cues) VALUES (
        'Barbell Curl',
        'Classic biceps compound movement.',
        'Keep elbows pinned at sides. Full range of motion. Squeeze hard at top. Do not swing.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_biceps, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_forearms, 'SECONDARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Incline Dumbbell Curl',
        'Bicep curl with full stretch at bottom. High bicep involvement.',
        'Set bench to 60°. Let arms hang behind body for max stretch. Curl, squeeze at top.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_biceps, 'PRIMARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Triceps Pushdown (Cable)',
        'Isolation for triceps. Use rope or bar attachment.',
        'Keep elbows at sides. Full extension at bottom. Control the return. Do not flare elbows.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_triceps, 'PRIMARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Skull Crushers (EZ Bar)',
        'Overhead elbow extension. Excellent tricep long-head stretch.',
        'Lower bar toward forehead or behind head. Keep upper arms vertical. Full lockout at top.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_triceps, 'PRIMARY');

    -- ── LEGS ───────────────────────────────────────────────────────────────

    INSERT INTO exercises (name, description, cues) VALUES (
        'Barbell Back Squat',
        'Foundational compound leg movement. High quad and glute involvement.',
        'Bar on traps (high-bar) or rear delts (low-bar). Hip-width stance. Break parallel. Knees track over toes. Chest up.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_quads, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_glutes, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_hamstrings, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_lower_back, 'SECONDARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Romanian Deadlift',
        'Hip-hinge pattern emphasising hamstrings and glutes with a long stretch.',
        'Neutral spine throughout. Push hips back, let bar drag down shins. Feel deep hamstring stretch. Drive hips forward to return.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_hamstrings, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_glutes, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_lower_back, 'SECONDARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Leg Press',
        'Machine quad/glute compound. Allows heavy loading with less spinal stress.',
        'Feet shoulder-width or wider on platform. Lower until hips just begin to round. Press through full range.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_quads, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_glutes, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_hamstrings, 'SECONDARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Leg Curl (Machine)',
        'Hamstring isolation. Can be performed seated or lying.',
        'Keep hips pressed into pad. Full range of motion. Squeeze at peak contraction. Slow eccentric.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_hamstrings, 'PRIMARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Leg Extension (Machine)',
        'Quad isolation. Excellent for finishing quads after compound work.',
        'Sit upright. Full extension at top, pause briefly. Control eccentric. Do not hyperextend knee.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_quads, 'PRIMARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Hip Thrust (Barbell)',
        'Best glute exercise for peak contraction under load.',
        'Upper back on bench, bar over hips. Drive hips to full extension. Squeeze glutes hard at top. Chin tucked.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_glutes, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_hamstrings, 'SECONDARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Calf Raise (Standing)',
        'Calf isolation. Can be done on machine or with dumbbells on a step.',
        'Full range of motion—stretch at bottom, squeeze at top. Single-leg for added difficulty.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_calves, 'PRIMARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Bulgarian Split Squat',
        'Unilateral quad and glute builder. Excellent for addressing imbalances.',
        'Rear foot elevated on bench. Front foot far enough forward to keep shin vertical at bottom. Descend until rear knee near floor.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_quads, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_glutes, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_hamstrings, 'SECONDARY');

    -- ── COMPOUND / FULL BODY ───────────────────────────────────────────────

    INSERT INTO exercises (name, description, cues) VALUES (
        'Conventional Deadlift',
        'Full-body compound movement. Targets posterior chain heavily.',
        'Bar over mid-foot. Hinge hips back, grip bar. Legs and hips drive simultaneously. Lock out at top. Control descent.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_hamstrings, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_glutes, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_lower_back, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_upper_back, 'SECONDARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_traps, 'SECONDARY');

    -- ── CORE ───────────────────────────────────────────────────────────────

    INSERT INTO exercises (name, description, cues) VALUES (
        'Cable Crunch',
        'Weighted ab exercise with constant cable tension.',
        'Kneel facing cable. Pull from neck, not hands. Round spine as you crunch. Do not pull with arms.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_abs, 'PRIMARY');

    INSERT INTO exercises (name, description, cues) VALUES (
        'Plank',
        'Isometric core stability exercise.',
        'Straight line from head to heels. Engage abs and glutes. Do not let hips sag or rise.'
    ) RETURNING id INTO e_id;
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_abs, 'PRIMARY');
    INSERT INTO exercise_muscles VALUES (DEFAULT, e_id, mg_lower_back, 'SECONDARY');

END $$;
