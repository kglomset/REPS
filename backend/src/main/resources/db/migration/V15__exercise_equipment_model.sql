-- ============================================================
-- V15: Exercise/equipment model split
-- ============================================================
--
-- Exercises used to carry their equipment baked into the name
-- ('Shoulder Press Smith', 'Shoulder Press Barbell', ...), so every new
-- equipment variant meant re-entering the same agonist/synergist mapping.
--
-- This splits that into three concerns:
--   movements  - the exercise identity ('Squat'); owns the muscle mapping
--                and compound/isolation classification
--   equipment  - 'Barbell', 'Smith Machine', 'Dumbbell', ...
--   exercises  - becomes the (movement, equipment, variation) VARIANT that
--                workout_template_exercises / session_exercises actually
--                reference. Existing rows are updated IN PLACE (same id),
--                so every historical FK keeps pointing at a valid row with
--                no remapping needed - this is what preserves the admin
--                user's logged history across the restructure.
--
-- Two of the 106 live exercises are remapped to equipment the live name
-- does not literally say, because that is what is actually trained on:
--   'Machine Leg Press'      -> Leg Press      + Keiser
--   'Stiff Legged Deadlift'  -> Stiff Legged Deadlift + Keiser
--
-- Generated + validated offline (uniqueness of every (movement, equipment,
-- variation) triple, every old name accounted for exactly once, every
-- muscle/equipment token resolvable) before being written here.

-- ── 1. New tables ─────────────────────────────────────────────────
CREATE TABLE equipment (
    id   BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(50)  NOT NULL UNIQUE
);

CREATE TABLE movements (
    id                  BIGSERIAL PRIMARY KEY,
    name                VARCHAR(150) NOT NULL,
    description         TEXT,
    cues                TEXT,
    image_url           VARCHAR(512),
    movement_pattern    VARCHAR(20) NOT NULL DEFAULT 'ISOLATION',
    created_by_user_id  BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE movement_equipment (
    movement_id  BIGINT NOT NULL REFERENCES movements(id) ON DELETE CASCADE,
    equipment_id BIGINT NOT NULL REFERENCES equipment(id) ON DELETE CASCADE,
    PRIMARY KEY (movement_id, equipment_id)
);

-- ── 2. Equipment catalogue ───────────────────────────────────────
INSERT INTO equipment (name, slug) VALUES ('Barbell', 'barbell'), ('Bodyweight', 'bodyweight'), ('Cable', 'cable'), ('Dumbbell', 'dumbbell'), ('EZ Bar', 'ez-bar'), ('Keiser', 'keiser'), ('Kettlebell', 'kettlebell'), ('Machine', 'machine'), ('Smith Machine', 'smith-machine'), ('TRX', 'trx'), ('Weighted', 'weighted');

-- ── 3. Movements (the 66 exercise identities) ───────────────────
INSERT INTO movements (name, movement_pattern) VALUES
    ('Ab Wheel Roll Out', 'ISOLATION'),
    ('Back Extensions', 'ISOLATION'),
    ('Backward Lunge', 'COMPOUND'),
    ('Bench Press', 'COMPOUND'),
    ('Bent Over Rows', 'COMPOUND'),
    ('Bicep Curl', 'ISOLATION'),
    ('Bulgarian Split Squat', 'COMPOUND'),
    ('Cable Pull Over', 'ISOLATION'),
    ('Calf Holds', 'ISOLATION'),
    ('Calf Raise', 'ISOLATION'),
    ('Chest Press', 'COMPOUND'),
    ('Chins', 'COMPOUND'),
    ('Crunch', 'ISOLATION'),
    ('Deadlift', 'COMPOUND'),
    ('Decline Chest Press', 'COMPOUND'),
    ('Dips', 'COMPOUND'),
    ('Facepull', 'ISOLATION'),
    ('Fly', 'ISOLATION'),
    ('Forward Lunge', 'COMPOUND'),
    ('Front Raise', 'ISOLATION'),
    ('Front Squat', 'COMPOUND'),
    ('GHR', 'COMPOUND'),
    ('Goblet Squat', 'COMPOUND'),
    ('Good Mornings', 'COMPOUND'),
    ('Hack Squat', 'COMPOUND'),
    ('Hip Abductor', 'ISOLATION'),
    ('Hip Thrust', 'COMPOUND'),
    ('Hip Thrust Single Leg', 'COMPOUND'),
    ('Incline Bicep Curl', 'ISOLATION'),
    ('Incline Chest Press', 'COMPOUND'),
    ('JM Press', 'COMPOUND'),
    ('Knee Raise', 'ISOLATION'),
    ('Lateral Raise', 'ISOLATION'),
    ('Lateral Raise Unilateral', 'ISOLATION'),
    ('Leg Curl', 'ISOLATION'),
    ('Leg Extension', 'ISOLATION'),
    ('Leg Press', 'COMPOUND'),
    ('Leg Raise', 'ISOLATION'),
    ('Narrow Grip Bench Press', 'COMPOUND'),
    ('Nordic Hamstring', 'ISOLATION'),
    ('Preacher Curl', 'ISOLATION'),
    ('Pull Down', 'COMPOUND'),
    ('Pull Down Wide Grip', 'COMPOUND'),
    ('Pull Up', 'COMPOUND'),
    ('Pull Up Wide Grip', 'COMPOUND'),
    ('Push Up', 'COMPOUND'),
    ('Reverse Fly', 'ISOLATION'),
    ('Reverse Nordics', 'ISOLATION'),
    ('Romanian Deadlift', 'COMPOUND'),
    ('Rotation', 'ISOLATION'),
    ('Row', 'COMPOUND'),
    ('Shoulder Press', 'COMPOUND'),
    ('Shrugs', 'ISOLATION'),
    ('Side Extensions', 'ISOLATION'),
    ('Sissy Squat', 'ISOLATION'),
    ('Split Squat', 'COMPOUND'),
    ('Squat', 'COMPOUND'),
    ('Step Down', 'COMPOUND'),
    ('Step Up', 'COMPOUND'),
    ('Stiff Legged Deadlift', 'COMPOUND'),
    ('Tricep Press', 'ISOLATION'),
    ('Tricep Press Overhead', 'ISOLATION'),
    ('Tricep Pushdown', 'ISOLATION'),
    ('Unilateral Row', 'COMPOUND'),
    ('Upright Row', 'COMPOUND'),
    ('Walking Lunge', 'COMPOUND');

-- ── 3b. exercise_muscles moves from per-variant to per-movement ──
--      Old rows are duplicated once per equipment variant (e.g. 'Shoulder
--      Press Barbell'/'...Dumbbell'/'...Smith' each carry their own identical
--      muscle rows) - pure catalogue metadata, no user history, safe to clear
--      and reinsert once per movement from the sheet.
DELETE FROM exercise_muscles;

DO $$
DECLARE
    fk_name TEXT;
BEGIN
    SELECT con.conname INTO fk_name
    FROM pg_constraint con
    JOIN pg_class rel ON rel.oid = con.conrelid
    WHERE rel.relname = 'exercise_muscles'
      AND con.contype = 'f'
      AND con.conname LIKE '%exercise_id%';
    IF fk_name IS NOT NULL THEN
        EXECUTE format('ALTER TABLE exercise_muscles DROP CONSTRAINT %I', fk_name);
    END IF;
END $$;

ALTER TABLE exercise_muscles RENAME COLUMN exercise_id TO movement_id;
ALTER TABLE exercise_muscles
    ADD CONSTRAINT exercise_muscles_movement_id_fkey
    FOREIGN KEY (movement_id) REFERENCES movements(id) ON DELETE CASCADE;

-- ── 4. Muscle mapping per movement (agonist = PRIMARY, synergist = SECONDARY) ──
INSERT INTO exercise_muscles (movement_id, muscle_group_id, role)
SELECT mv.id, mg.id, v.role
FROM (VALUES
    ('Ab Wheel Roll Out', 'abs', 'PRIMARY'),
    ('Ab Wheel Roll Out', 'obliques', 'SECONDARY'),
    ('Back Extensions', 'hamstrings', 'PRIMARY'),
    ('Back Extensions', 'glutes', 'PRIMARY'),
    ('Back Extensions', 'lower-back', 'SECONDARY'),
    ('Backward Lunge', 'quads', 'PRIMARY'),
    ('Backward Lunge', 'glutes', 'PRIMARY'),
    ('Backward Lunge', 'hamstrings', 'SECONDARY'),
    ('Bench Press', 'chest', 'PRIMARY'),
    ('Bench Press', 'front-delts', 'SECONDARY'),
    ('Bench Press', 'triceps', 'SECONDARY'),
    ('Bent Over Rows', 'lats', 'PRIMARY'),
    ('Bent Over Rows', 'upper-back', 'PRIMARY'),
    ('Bent Over Rows', 'biceps', 'SECONDARY'),
    ('Bicep Curl', 'biceps', 'PRIMARY'),
    ('Bulgarian Split Squat', 'quads', 'PRIMARY'),
    ('Bulgarian Split Squat', 'glutes', 'PRIMARY'),
    ('Bulgarian Split Squat', 'hamstrings', 'SECONDARY'),
    ('Cable Pull Over', 'lats', 'PRIMARY'),
    ('Calf Holds', 'calves', 'PRIMARY'),
    ('Calf Raise', 'calves', 'PRIMARY'),
    ('Chest Press', 'chest', 'PRIMARY'),
    ('Chest Press', 'front-delts', 'SECONDARY'),
    ('Chest Press', 'triceps', 'SECONDARY'),
    ('Chins', 'lats', 'PRIMARY'),
    ('Chins', 'biceps', 'PRIMARY'),
    ('Chins', 'upper-back', 'SECONDARY'),
    ('Crunch', 'abs', 'PRIMARY'),
    ('Crunch', 'obliques', 'SECONDARY'),
    ('Deadlift', 'hamstrings', 'PRIMARY'),
    ('Deadlift', 'glutes', 'PRIMARY'),
    ('Deadlift', 'lower-back', 'PRIMARY'),
    ('Deadlift', 'quads', 'SECONDARY'),
    ('Decline Chest Press', 'chest', 'PRIMARY'),
    ('Decline Chest Press', 'triceps', 'SECONDARY'),
    ('Dips', 'chest', 'PRIMARY'),
    ('Dips', 'triceps', 'PRIMARY'),
    ('Dips', 'front-delts', 'SECONDARY'),
    ('Facepull', 'rear-delts', 'PRIMARY'),
    ('Facepull', 'upper-back', 'SECONDARY'),
    ('Fly', 'chest', 'PRIMARY'),
    ('Forward Lunge', 'quads', 'PRIMARY'),
    ('Forward Lunge', 'glutes', 'PRIMARY'),
    ('Forward Lunge', 'hamstrings', 'SECONDARY'),
    ('Front Raise', 'front-delts', 'PRIMARY'),
    ('Front Raise', 'side-delts', 'SECONDARY'),
    ('Front Squat', 'quads', 'PRIMARY'),
    ('Front Squat', 'glutes', 'PRIMARY'),
    ('Front Squat', 'hamstrings', 'SECONDARY'),
    ('GHR', 'hamstrings', 'PRIMARY'),
    ('GHR', 'glutes', 'PRIMARY'),
    ('GHR', 'lower-back', 'SECONDARY'),
    ('Goblet Squat', 'quads', 'PRIMARY'),
    ('Goblet Squat', 'glutes', 'PRIMARY'),
    ('Goblet Squat', 'hamstrings', 'SECONDARY'),
    ('Good Mornings', 'hamstrings', 'PRIMARY'),
    ('Good Mornings', 'glutes', 'PRIMARY'),
    ('Good Mornings', 'lower-back', 'PRIMARY'),
    ('Hack Squat', 'quads', 'PRIMARY'),
    ('Hack Squat', 'glutes', 'PRIMARY'),
    ('Hack Squat', 'hamstrings', 'SECONDARY'),
    ('Hip Abductor', 'glutes', 'PRIMARY'),
    ('Hip Thrust', 'glutes', 'PRIMARY'),
    ('Hip Thrust', 'hamstrings', 'SECONDARY'),
    ('Hip Thrust Single Leg', 'glutes', 'PRIMARY'),
    ('Hip Thrust Single Leg', 'hamstrings', 'SECONDARY'),
    ('Incline Bicep Curl', 'biceps', 'PRIMARY'),
    ('Incline Chest Press', 'chest', 'PRIMARY'),
    ('Incline Chest Press', 'front-delts', 'PRIMARY'),
    ('Incline Chest Press', 'triceps', 'SECONDARY'),
    ('JM Press', 'triceps', 'PRIMARY'),
    ('JM Press', 'front-delts', 'SECONDARY'),
    ('Knee Raise', 'abs', 'PRIMARY'),
    ('Knee Raise', 'obliques', 'SECONDARY'),
    ('Lateral Raise', 'side-delts', 'PRIMARY'),
    ('Lateral Raise', 'front-delts', 'SECONDARY'),
    ('Lateral Raise', 'rear-delts', 'SECONDARY'),
    ('Lateral Raise Unilateral', 'side-delts', 'PRIMARY'),
    ('Lateral Raise Unilateral', 'front-delts', 'SECONDARY'),
    ('Lateral Raise Unilateral', 'rear-delts', 'SECONDARY'),
    ('Leg Curl', 'hamstrings', 'PRIMARY'),
    ('Leg Extension', 'quads', 'PRIMARY'),
    ('Leg Press', 'quads', 'PRIMARY'),
    ('Leg Press', 'glutes', 'PRIMARY'),
    ('Leg Press', 'hamstrings', 'SECONDARY'),
    ('Leg Raise', 'abs', 'PRIMARY'),
    ('Leg Raise', 'obliques', 'SECONDARY'),
    ('Narrow Grip Bench Press', 'triceps', 'PRIMARY'),
    ('Narrow Grip Bench Press', 'front-delts', 'SECONDARY'),
    ('Nordic Hamstring', 'hamstrings', 'PRIMARY'),
    ('Preacher Curl', 'biceps', 'PRIMARY'),
    ('Pull Down', 'lats', 'PRIMARY'),
    ('Pull Down', 'upper-back', 'SECONDARY'),
    ('Pull Down', 'biceps', 'SECONDARY'),
    ('Pull Down Wide Grip', 'lats', 'PRIMARY'),
    ('Pull Down Wide Grip', 'biceps', 'SECONDARY'),
    ('Pull Down Wide Grip', 'rear-delts', 'SECONDARY'),
    ('Pull Up', 'lats', 'PRIMARY'),
    ('Pull Up', 'upper-back', 'SECONDARY'),
    ('Pull Up', 'biceps', 'SECONDARY'),
    ('Pull Up Wide Grip', 'lats', 'PRIMARY'),
    ('Pull Up Wide Grip', 'biceps', 'SECONDARY'),
    ('Pull Up Wide Grip', 'rear-delts', 'SECONDARY'),
    ('Push Up', 'chest', 'PRIMARY'),
    ('Push Up', 'front-delts', 'SECONDARY'),
    ('Push Up', 'triceps', 'SECONDARY'),
    ('Reverse Fly', 'rear-delts', 'PRIMARY'),
    ('Reverse Fly', 'upper-back', 'SECONDARY'),
    ('Reverse Nordics', 'quads', 'PRIMARY'),
    ('Romanian Deadlift', 'hamstrings', 'PRIMARY'),
    ('Romanian Deadlift', 'glutes', 'PRIMARY'),
    ('Romanian Deadlift', 'lower-back', 'PRIMARY'),
    ('Rotation', 'obliques', 'PRIMARY'),
    ('Rotation', 'abs', 'SECONDARY'),
    ('Row', 'lats', 'PRIMARY'),
    ('Row', 'upper-back', 'PRIMARY'),
    ('Row', 'biceps', 'SECONDARY'),
    ('Shoulder Press', 'front-delts', 'PRIMARY'),
    ('Shoulder Press', 'side-delts', 'PRIMARY'),
    ('Shoulder Press', 'triceps', 'SECONDARY'),
    ('Shoulder Press', 'traps', 'SECONDARY'),
    ('Shrugs', 'traps', 'PRIMARY'),
    ('Side Extensions', 'obliques', 'PRIMARY'),
    ('Sissy Squat', 'quads', 'PRIMARY'),
    ('Split Squat', 'quads', 'PRIMARY'),
    ('Split Squat', 'glutes', 'PRIMARY'),
    ('Split Squat', 'hamstrings', 'SECONDARY'),
    ('Squat', 'quads', 'PRIMARY'),
    ('Squat', 'glutes', 'PRIMARY'),
    ('Squat', 'hamstrings', 'SECONDARY'),
    ('Step Down', 'quads', 'PRIMARY'),
    ('Step Down', 'glutes', 'PRIMARY'),
    ('Step Down', 'hamstrings', 'SECONDARY'),
    ('Step Up', 'quads', 'PRIMARY'),
    ('Step Up', 'glutes', 'PRIMARY'),
    ('Step Up', 'hamstrings', 'SECONDARY'),
    ('Stiff Legged Deadlift', 'hamstrings', 'PRIMARY'),
    ('Stiff Legged Deadlift', 'glutes', 'PRIMARY'),
    ('Stiff Legged Deadlift', 'lower-back', 'PRIMARY'),
    ('Tricep Press', 'triceps', 'PRIMARY'),
    ('Tricep Press Overhead', 'triceps', 'PRIMARY'),
    ('Tricep Pushdown', 'triceps', 'PRIMARY'),
    ('Unilateral Row', 'lats', 'PRIMARY'),
    ('Unilateral Row', 'upper-back', 'PRIMARY'),
    ('Unilateral Row', 'biceps', 'SECONDARY'),
    ('Upright Row', 'side-delts', 'PRIMARY'),
    ('Upright Row', 'front-delts', 'SECONDARY'),
    ('Upright Row', 'rear-delts', 'SECONDARY'),
    ('Walking Lunge', 'quads', 'PRIMARY'),
    ('Walking Lunge', 'glutes', 'PRIMARY'),
    ('Walking Lunge', 'hamstrings', 'SECONDARY')
) AS v(movement_name, muscle_slug, role)
JOIN movements mv ON mv.name = v.movement_name
JOIN muscle_groups mg ON mg.slug = v.muscle_slug;

-- ── 5. Which equipment options the picker offers per movement ───
--    (the sheet's list, extended with equipment live history actually uses)
INSERT INTO movement_equipment (movement_id, equipment_id)
SELECT mv.id, eq.id
FROM (VALUES
    ('Back Extensions', 'bodyweight'),
    ('Back Extensions', 'weighted'),
    ('Backward Lunge', 'barbell'),
    ('Backward Lunge', 'dumbbell'),
    ('Bench Press', 'barbell'),
    ('Bench Press', 'smith-machine'),
    ('Bent Over Rows', 'barbell'),
    ('Bent Over Rows', 'dumbbell'),
    ('Bicep Curl', 'barbell'),
    ('Bicep Curl', 'cable'),
    ('Bicep Curl', 'dumbbell'),
    ('Bicep Curl', 'ez-bar'),
    ('Bicep Curl', 'keiser'),
    ('Bicep Curl', 'machine'),
    ('Bulgarian Split Squat', 'barbell'),
    ('Bulgarian Split Squat', 'dumbbell'),
    ('Bulgarian Split Squat', 'smith-machine'),
    ('Cable Pull Over', 'cable'),
    ('Calf Holds', 'barbell'),
    ('Calf Holds', 'bodyweight'),
    ('Calf Holds', 'dumbbell'),
    ('Calf Holds', 'keiser'),
    ('Calf Holds', 'machine'),
    ('Calf Holds', 'smith-machine'),
    ('Calf Raise', 'barbell'),
    ('Calf Raise', 'bodyweight'),
    ('Calf Raise', 'dumbbell'),
    ('Calf Raise', 'keiser'),
    ('Calf Raise', 'machine'),
    ('Calf Raise', 'smith-machine'),
    ('Chest Press', 'dumbbell'),
    ('Chest Press', 'machine'),
    ('Chins', 'bodyweight'),
    ('Chins', 'weighted'),
    ('Crunch', 'bodyweight'),
    ('Crunch', 'cable'),
    ('Crunch', 'weighted'),
    ('Deadlift', 'barbell'),
    ('Deadlift', 'keiser'),
    ('Deadlift', 'smith-machine'),
    ('Decline Chest Press', 'barbell'),
    ('Decline Chest Press', 'dumbbell'),
    ('Decline Chest Press', 'machine'),
    ('Decline Chest Press', 'smith-machine'),
    ('Dips', 'bodyweight'),
    ('Dips', 'machine'),
    ('Dips', 'weighted'),
    ('Facepull', 'cable'),
    ('Facepull', 'keiser'),
    ('Facepull', 'machine'),
    ('Fly', 'cable'),
    ('Fly', 'dumbbell'),
    ('Fly', 'keiser'),
    ('Fly', 'machine'),
    ('Forward Lunge', 'barbell'),
    ('Forward Lunge', 'dumbbell'),
    ('Front Raise', 'barbell'),
    ('Front Raise', 'cable'),
    ('Front Raise', 'dumbbell'),
    ('Front Squat', 'barbell'),
    ('Front Squat', 'dumbbell'),
    ('Front Squat', 'smith-machine'),
    ('GHR', 'bodyweight'),
    ('GHR', 'weighted'),
    ('Goblet Squat', 'dumbbell'),
    ('Goblet Squat', 'kettlebell'),
    ('Good Mornings', 'barbell'),
    ('Good Mornings', 'smith-machine'),
    ('Hack Squat', 'machine'),
    ('Hack Squat', 'smith-machine'),
    ('Hip Abductor', 'machine'),
    ('Hip Thrust', 'barbell'),
    ('Hip Thrust', 'bodyweight'),
    ('Hip Thrust', 'dumbbell'),
    ('Hip Thrust', 'machine'),
    ('Hip Thrust', 'smith-machine'),
    ('Hip Thrust Single Leg', 'barbell'),
    ('Hip Thrust Single Leg', 'bodyweight'),
    ('Hip Thrust Single Leg', 'dumbbell'),
    ('Hip Thrust Single Leg', 'machine'),
    ('Hip Thrust Single Leg', 'smith-machine'),
    ('Incline Bicep Curl', 'cable'),
    ('Incline Bicep Curl', 'dumbbell'),
    ('Incline Bicep Curl', 'keiser'),
    ('Incline Chest Press', 'barbell'),
    ('Incline Chest Press', 'dumbbell'),
    ('Incline Chest Press', 'machine'),
    ('Incline Chest Press', 'smith-machine'),
    ('JM Press', 'barbell'),
    ('JM Press', 'dumbbell'),
    ('JM Press', 'smith-machine'),
    ('Knee Raise', 'bodyweight'),
    ('Knee Raise', 'weighted'),
    ('Lateral Raise', 'cable'),
    ('Lateral Raise', 'dumbbell'),
    ('Lateral Raise', 'machine'),
    ('Lateral Raise Unilateral', 'cable'),
    ('Lateral Raise Unilateral', 'dumbbell'),
    ('Leg Curl', 'machine'),
    ('Leg Curl', 'trx'),
    ('Leg Extension', 'keiser'),
    ('Leg Extension', 'machine'),
    ('Leg Press', 'keiser'),
    ('Leg Press', 'machine'),
    ('Leg Raise', 'bodyweight'),
    ('Leg Raise', 'weighted'),
    ('Narrow Grip Bench Press', 'barbell'),
    ('Narrow Grip Bench Press', 'smith-machine'),
    ('Nordic Hamstring', 'bodyweight'),
    ('Preacher Curl', 'barbell'),
    ('Preacher Curl', 'cable'),
    ('Preacher Curl', 'dumbbell'),
    ('Preacher Curl', 'ez-bar'),
    ('Preacher Curl', 'machine'),
    ('Pull Down', 'cable'),
    ('Pull Down', 'machine'),
    ('Pull Down Wide Grip', 'cable'),
    ('Pull Down Wide Grip', 'machine'),
    ('Pull Up', 'bodyweight'),
    ('Pull Up', 'weighted'),
    ('Pull Up Wide Grip', 'bodyweight'),
    ('Pull Up Wide Grip', 'weighted'),
    ('Push Up', 'bodyweight'),
    ('Push Up', 'weighted'),
    ('Reverse Fly', 'cable'),
    ('Reverse Fly', 'dumbbell'),
    ('Reverse Fly', 'machine'),
    ('Reverse Nordics', 'bodyweight'),
    ('Reverse Nordics', 'dumbbell'),
    ('Reverse Nordics', 'weighted'),
    ('Romanian Deadlift', 'barbell'),
    ('Romanian Deadlift', 'dumbbell'),
    ('Romanian Deadlift', 'keiser'),
    ('Romanian Deadlift', 'smith-machine'),
    ('Rotation', 'cable'),
    ('Rotation', 'machine'),
    ('Row', 'cable'),
    ('Row', 'machine'),
    ('Shoulder Press', 'barbell'),
    ('Shoulder Press', 'dumbbell'),
    ('Shoulder Press', 'machine'),
    ('Shoulder Press', 'smith-machine'),
    ('Shrugs', 'barbell'),
    ('Shrugs', 'dumbbell'),
    ('Shrugs', 'machine'),
    ('Shrugs', 'smith-machine'),
    ('Side Extensions', 'cable'),
    ('Side Extensions', 'dumbbell'),
    ('Side Extensions', 'kettlebell'),
    ('Sissy Squat', 'bodyweight'),
    ('Split Squat', 'barbell'),
    ('Split Squat', 'dumbbell'),
    ('Split Squat', 'smith-machine'),
    ('Squat', 'barbell'),
    ('Squat', 'bodyweight'),
    ('Squat', 'smith-machine'),
    ('Step Down', 'barbell'),
    ('Step Down', 'bodyweight'),
    ('Step Down', 'dumbbell'),
    ('Step Down', 'kettlebell'),
    ('Step Up', 'barbell'),
    ('Step Up', 'bodyweight'),
    ('Step Up', 'dumbbell'),
    ('Step Up', 'kettlebell'),
    ('Stiff Legged Deadlift', 'barbell'),
    ('Stiff Legged Deadlift', 'dumbbell'),
    ('Stiff Legged Deadlift', 'keiser'),
    ('Stiff Legged Deadlift', 'smith-machine'),
    ('Tricep Press', 'barbell'),
    ('Tricep Press', 'cable'),
    ('Tricep Press', 'dumbbell'),
    ('Tricep Press', 'ez-bar'),
    ('Tricep Press', 'machine'),
    ('Tricep Press Overhead', 'cable'),
    ('Tricep Press Overhead', 'dumbbell'),
    ('Tricep Press Overhead', 'ez-bar'),
    ('Tricep Press Overhead', 'keiser'),
    ('Tricep Pushdown', 'cable'),
    ('Tricep Pushdown', 'keiser'),
    ('Unilateral Row', 'dumbbell'),
    ('Unilateral Row', 'machine'),
    ('Upright Row', 'barbell'),
    ('Upright Row', 'cable'),
    ('Upright Row', 'dumbbell'),
    ('Upright Row', 'smith-machine'),
    ('Walking Lunge', 'barbell'),
    ('Walking Lunge', 'dumbbell')
) AS v(movement_name, equipment_slug)
JOIN movements mv ON mv.name = v.movement_name
JOIN equipment eq ON eq.slug = v.equipment_slug;

-- ── 6. exercises becomes the (movement, equipment, variation) variant ──
ALTER TABLE exercises
    ADD COLUMN movement_id  BIGINT REFERENCES movements(id),
    ADD COLUMN equipment_id BIGINT REFERENCES equipment(id),
    ADD COLUMN variation    VARCHAR(100);

-- Retrofit every live exercise row IN PLACE (same id -> no FK remapping
-- needed for workout_template_exercises / session_exercises history).
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Ab Wheel Roll Out'), equipment_id = NULL, variation = NULL, name = 'Ab Wheel Roll Out' WHERE name = 'Ab Wheel Roll Out';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Back Extensions'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = NULL, name = 'Bodyweight Back Extensions' WHERE name = 'Back Extensions';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Backward Lunge'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Backward Lunge' WHERE name = 'Backward Lunge Barbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Backward Lunge'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Backward Lunge' WHERE name = 'Backward Lunge Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Bent Over Rows'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Bent Over Rows' WHERE name = 'Barbell Bent Over Rows';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Shrugs'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Shrugs' WHERE name = 'Barbell Shrugs';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Bench Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Bench Press' WHERE name = 'Bench Press';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Bench Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'smith-machine'), variation = NULL, name = 'Smith Machine Bench Press' WHERE name = 'Bench Press Smith';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Rotation'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = 'Bent Over', name = 'Cable Rotation (Bent Over)' WHERE name = 'Bent Over Rotation Cable';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Bicep Curl'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Bicep Curl' WHERE name = 'Bicep Curl Barbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Bicep Curl'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Bicep Curl' WHERE name = 'Bicep Curl Cable';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Bicep Curl'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = 'Unilateral', name = 'Cable Bicep Curl (Unilateral)' WHERE name = 'Bicep Curl Cable Unilateral';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Bicep Curl'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Bicep Curl' WHERE name = 'Bicep Curl Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Bicep Curl'), equipment_id = (SELECT id FROM equipment WHERE slug = 'ez-bar'), variation = NULL, name = 'EZ Bar Bicep Curl' WHERE name = 'Bicep Curl EZ Bar';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Crunch'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = 'Bosu', name = 'Bodyweight Crunch (Bosu)' WHERE name = 'Bosu Crunch';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Step Up'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = 'Box', name = 'Bodyweight Step Up (Box)' WHERE name = 'Box Step Up';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Bulgarian Split Squat'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Bulgarian Split Squat' WHERE name = 'Bulgarian Split Squat Barbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Bulgarian Split Squat'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Bulgarian Split Squat' WHERE name = 'Bulgarian Split Squat Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Crunch'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Crunch' WHERE name = 'Cable Crunch';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Fly'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Fly' WHERE name = 'Cable Fly';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Cable Pull Over'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Pull Over' WHERE name = 'Cable Pull Over';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Chest Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Chest Press' WHERE name = 'Chest Press Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Chest Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = NULL, name = 'Machine Chest Press' WHERE name = 'Chest Press Machine';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Chins'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = NULL, name = 'Bodyweight Chins' WHERE name = 'Chins';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Deadlift'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Deadlift' WHERE name = 'Deadlift';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Decline Chest Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = NULL, name = 'Machine Decline Chest Press' WHERE name = 'Decline Chest Press Machine';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Dips'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = NULL, name = 'Bodyweight Dips' WHERE name = 'Dips';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Bent Over Rows'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Bent Over Rows' WHERE name = 'Dumbbell Bent Over Rows';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Fly'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Fly' WHERE name = 'Dumbbell Fly';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Unilateral Row'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Unilateral Row' WHERE name = 'Dumbbell Row Unilateral';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Shrugs'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Shrugs' WHERE name = 'Dumbbell Shrugs';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Facepull'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Facepull' WHERE name = 'Facepull Cable';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Forward Lunge'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Forward Lunge' WHERE name = 'Forward Lunge Barbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Forward Lunge'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Forward Lunge' WHERE name = 'Forward Lunge Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Front Raise'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Front Raise' WHERE name = 'Front Raise';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Front Squat'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Front Squat' WHERE name = 'Front Squat';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'GHR'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = NULL, name = 'Bodyweight GHR' WHERE name = 'GHR';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Good Mornings'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Good Mornings' WHERE name = 'Good Mornings';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Knee Raise'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = 'Hanging', name = 'Bodyweight Knee Raise (Hanging)' WHERE name = 'Hanging Knee Raise';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Hip Abductor'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = NULL, name = 'Machine Hip Abductor' WHERE name = 'Hip Abductor Machine';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Hip Thrust'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Hip Thrust' WHERE name = 'Hip Thrust Bardbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Hip Thrust'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = NULL, name = 'Machine Hip Thrust' WHERE name = 'Hip Thrust Machine';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Incline Bicep Curl'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Incline Bicep Curl' WHERE name = 'Incline Bicep Curl Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Incline Chest Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Incline Chest Press' WHERE name = 'Incline Chest Press Barbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Incline Chest Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Incline Chest Press' WHERE name = 'Incline Chest Press Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Incline Chest Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = NULL, name = 'Machine Incline Chest Press' WHERE name = 'Incline Chest Press Machine';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Incline Chest Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'smith-machine'), variation = NULL, name = 'Smith Machine Incline Chest Press' WHERE name = 'Incline Chest Press Smith';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Knee Raise'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = 'Incline', name = 'Bodyweight Knee Raise (Incline)' WHERE name = 'Incline Knee Raise';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'JM Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'smith-machine'), variation = NULL, name = 'Smith Machine JM Press' WHERE name = 'JM Press Smith';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Lateral Raise'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Lateral Raise' WHERE name = 'Lateral Raise Cable Bilateral';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Lateral Raise Unilateral'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Lateral Raise Unilateral' WHERE name = 'Lateral Raise Cable Unilateral';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Lateral Raise Unilateral'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = 'Cuffed', name = 'Cable Lateral Raise Unilateral (Cuffed)' WHERE name = 'Lateral Raise Cable Unilateral with Cuff';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Lateral Raise'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Lateral Raise' WHERE name = 'Lateral Raise Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Leg Curl'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = 'Prone', name = 'Machine Leg Curl (Prone)' WHERE name = 'Leg Curl Prone';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Leg Curl'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = 'Sitting', name = 'Machine Leg Curl (Sitting)' WHERE name = 'Leg Curl Sitting';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Leg Curl'), equipment_id = (SELECT id FROM equipment WHERE slug = 'trx'), variation = NULL, name = 'TRX Leg Curl' WHERE name = 'Leg Curl TRX';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Leg Extension'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = NULL, name = 'Machine Leg Extension' WHERE name = 'Leg Extension';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Leg Raise'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = NULL, name = 'Bodyweight Leg Raise' WHERE name = 'Leg Raise';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Leg Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'keiser'), variation = NULL, name = 'Keiser Leg Press' WHERE name = 'Machine Leg Press';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Narrow Grip Bench Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Narrow Grip Bench Press' WHERE name = 'Narrow Grip Bench Press';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Row'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = 'Narrow Grip', name = 'Cable Row (Narrow Grip)' WHERE name = 'Narrow Grip Cable Row';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Row'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = 'Narrow Grip', name = 'Machine Row (Narrow Grip)' WHERE name = 'Narrow Grip Machine Row';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Nordic Hamstring'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = NULL, name = 'Bodyweight Nordic Hamstring' WHERE name = 'Nordic Hamstring';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Fly'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = NULL, name = 'Machine Fly' WHERE name = 'Pec Dec';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Bent Over Rows'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = 'Pendlay', name = 'Barbell Bent Over Rows (Pendlay)' WHERE name = 'Pendlay Rows';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Preacher Curl'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Preacher Curl' WHERE name = 'Preacher Curl Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Preacher Curl'), equipment_id = (SELECT id FROM equipment WHERE slug = 'ez-bar'), variation = NULL, name = 'EZ Bar Preacher Curl' WHERE name = 'Preacher Curl EZ Bar';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Pull Down'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = 'Narrow Grip', name = 'Cable Pull Down (Narrow Grip)' WHERE name = 'Pull Down Narrow Grip';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Pull Down'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = 'Neutral Grip', name = 'Cable Pull Down (Neutral Grip)' WHERE name = 'Pull Down Neutral Grip';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Pull Down Wide Grip'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Pull Down Wide Grip' WHERE name = 'Pull Down Wide Grip';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Pull Up'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = 'Narrow Grip', name = 'Bodyweight Pull Up (Narrow Grip)' WHERE name = 'Pull Up Narrow Grip';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Pull Up'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = 'Neutral Grip', name = 'Bodyweight Pull Up (Neutral Grip)' WHERE name = 'Pull Up Neutral Grip';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Pull Up Wide Grip'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = NULL, name = 'Bodyweight Pull Up Wide Grip' WHERE name = 'Pull Up Wide Grip';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Push Up'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = NULL, name = 'Bodyweight Push Up' WHERE name = 'Push Up';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Push Up'), equipment_id = (SELECT id FROM equipment WHERE slug = 'weighted'), variation = NULL, name = 'Weighted Push Up' WHERE name = 'Push Up with Weight';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Reverse Fly'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Reverse Fly' WHERE name = 'Reverse Fly Cable';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Reverse Fly'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Reverse Fly' WHERE name = 'Reverse Fly Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Reverse Fly'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = NULL, name = 'Machine Reverse Fly' WHERE name = 'Reverse Pec Dec';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Romanian Deadlift'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Romanian Deadlift' WHERE name = 'Romanian Deadlift';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Rotation'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Rotation' WHERE name = 'Rotation Cable';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Shoulder Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Shoulder Press' WHERE name = 'Shoulder Press Barbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Shoulder Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Shoulder Press' WHERE name = 'Shoulder Press Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Shoulder Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'smith-machine'), variation = NULL, name = 'Smith Machine Shoulder Press' WHERE name = 'Shoulder Press Smith';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Side Extensions'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = '45 Degree', name = 'Dumbbell Side Extensions (45 Degree)' WHERE name = 'Side Extensions 45 Degree';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Sissy Squat'), equipment_id = (SELECT id FROM equipment WHERE slug = 'bodyweight'), variation = NULL, name = 'Bodyweight Sissy Squat' WHERE name = 'Sissy Squat';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Calf Raise'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = 'Seated', name = 'Machine Calf Raise (Seated)' WHERE name = 'Sitting Calf Raise';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Tricep Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'ez-bar'), variation = 'Lying', name = 'EZ Bar Tricep Press (Lying)' WHERE name = 'Skull Chrushers';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Squat'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Squat' WHERE name = 'Squat';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Calf Raise'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = 'Standing', name = 'Machine Calf Raise (Standing)' WHERE name = 'Standing Calf Raise';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Calf Raise'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = 'Stiff Legged', name = 'Machine Calf Raise (Stiff Legged)' WHERE name = 'Stiff Legged Calf Raise';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Stiff Legged Deadlift'), equipment_id = (SELECT id FROM equipment WHERE slug = 'keiser'), variation = NULL, name = 'Keiser Stiff Legged Deadlift' WHERE name = 'Stiff Legged Deadlift';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Lateral Raise'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = 'Lying', name = 'Cable Lateral Raise (Lying)' WHERE name = 'Supine Lateral Raise Cable Bilateral';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Tricep Press'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = 'Lying', name = 'Dumbbell Tricep Press (Lying)' WHERE name = 'Tricep Press Dumbbell Supine';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Tricep Press Overhead'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Tricep Press Overhead' WHERE name = 'Tricep Press Overhead Cable';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Tricep Press Overhead'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = 'Unilateral', name = 'Cable Tricep Press Overhead (Unilateral)' WHERE name = 'Tricep Press Overhead Cable Unilateral';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Tricep Pushdown'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Tricep Pushdown' WHERE name = 'Tricep Pushdown Cable';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Tricep Pushdown'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = 'Unilateral', name = 'Cable Tricep Pushdown (Unilateral)' WHERE name = 'Tricep Pushdown Cable Unilateral';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Tricep Pushdown'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = 'Rope', name = 'Cable Tricep Pushdown (Rope)' WHERE name = 'Tricep Pushdown Cable with Rope';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Upright Row'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Upright Row' WHERE name = 'Upright Row Barbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Upright Row'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = NULL, name = 'Cable Upright Row' WHERE name = 'Upright Row Cable';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Upright Row'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Upright Row' WHERE name = 'Upright Row Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Upright Row'), equipment_id = (SELECT id FROM equipment WHERE slug = 'smith-machine'), variation = NULL, name = 'Smith Machine Upright Row' WHERE name = 'Upright Row Smith';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Walking Lunge'), equipment_id = (SELECT id FROM equipment WHERE slug = 'barbell'), variation = NULL, name = 'Barbell Walking Lunge' WHERE name = 'Walking Lunge Barbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Walking Lunge'), equipment_id = (SELECT id FROM equipment WHERE slug = 'dumbbell'), variation = NULL, name = 'Dumbbell Walking Lunge' WHERE name = 'Walking Lunge Dumbbell';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Row'), equipment_id = (SELECT id FROM equipment WHERE slug = 'cable'), variation = 'Wide Grip', name = 'Cable Row (Wide Grip)' WHERE name = 'Wide Grip Cable Row';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Row'), equipment_id = (SELECT id FROM equipment WHERE slug = 'machine'), variation = 'Wide Grip', name = 'Machine Row (Wide Grip)' WHERE name = 'Wide Grip Machine Row';

-- Every live row must have resolved to a movement - otherwise a template or
-- session still has history pointing at an exercise with no identity.
DO $$
DECLARE
    unresolved INTEGER;
BEGIN
    SELECT COUNT(*) INTO unresolved FROM exercises WHERE movement_id IS NULL;
    IF unresolved > 0 THEN
        RAISE EXCEPTION '% exercises did not resolve to a movement', unresolved;
    END IF;
END $$;

ALTER TABLE exercises ALTER COLUMN movement_id SET NOT NULL;
ALTER TABLE exercises DROP COLUMN movement_pattern;

-- Description/cues/image live on the movement now (equipment-agnostic);
-- no live row had ever populated them on the exercise, so nothing to carry over.
ALTER TABLE exercises DROP COLUMN description;
ALTER TABLE exercises DROP COLUMN cues;
ALTER TABLE exercises DROP COLUMN image_url;

