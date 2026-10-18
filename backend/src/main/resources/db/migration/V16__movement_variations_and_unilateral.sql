-- ============================================================
-- V16: Movement variations (curated, no free text) + can_be_unilateral
-- ============================================================

-- ── 1. Retire 'Lateral Raise Unilateral' and 'Unilateral Row' ──
--    Repoint their live exercise rows onto the base movement,
--    fold 'Unilateral' into the variation/name so they stay
--    distinct, separately-trackable exercises from the bilateral
--    version (no logged history gets merged across two different lifts).
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Lateral Raise'), variation = 'Unilateral', name = 'Cable Lateral Raise (Unilateral)' WHERE name = 'Cable Lateral Raise Unilateral';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Lateral Raise'), variation = 'Unilateral, Cuffed', name = 'Cable Lateral Raise (Unilateral, Cuffed)' WHERE name = 'Cable Lateral Raise Unilateral (Cuffed)';
UPDATE exercises SET movement_id = (SELECT id FROM movements WHERE name = 'Row'), variation = 'Unilateral', name = 'Dumbbell Row (Unilateral)' WHERE name = 'Dumbbell Unilateral Row';

-- Defensive check mirroring V15's pattern: confirm the 3 repoints above
-- (and nothing else) still reference the 3 movements about to be dropped.
DO $$
DECLARE
    stray INTEGER;
BEGIN
    SELECT COUNT(*) INTO stray FROM exercises e
      JOIN movements m ON m.id = e.movement_id
      WHERE m.name IN ('Lateral Raise Unilateral', 'Unilateral Row', 'Hip Thrust Single Leg');
    IF stray > 0 THEN
        RAISE EXCEPTION '% exercises still reference a movement about to be dropped', stray;
    END IF;
END $$;

-- Row inherits 'dumbbell' from the merged Unilateral Row (Row's own sheet
-- equipment list is cable/machine only; dumbbell is live history being folded in).
INSERT INTO movement_equipment (movement_id, equipment_id)
SELECT (SELECT id FROM movements WHERE name = 'Row'), (SELECT id FROM equipment WHERE slug = 'dumbbell')
WHERE NOT EXISTS (
    SELECT 1 FROM movement_equipment me
    JOIN movements mv ON mv.id = me.movement_id
    JOIN equipment eq ON eq.id = me.equipment_id
    WHERE mv.name = 'Row' AND eq.slug = 'dumbbell'
);

DELETE FROM exercise_muscles WHERE movement_id IN (SELECT id FROM movements WHERE name IN ('Lateral Raise Unilateral', 'Unilateral Row', 'Hip Thrust Single Leg'));
DELETE FROM movement_equipment WHERE movement_id IN (SELECT id FROM movements WHERE name IN ('Lateral Raise Unilateral', 'Unilateral Row', 'Hip Thrust Single Leg'));
DELETE FROM movements WHERE name IN ('Lateral Raise Unilateral', 'Unilateral Row', 'Hip Thrust Single Leg');

-- ── 2. Curated variations per movement (replaces the free-text field) ──
CREATE TABLE movement_variations (
    movement_id BIGINT NOT NULL REFERENCES movements(id) ON DELETE CASCADE,
    variation   VARCHAR(100) NOT NULL,
    sort_order  INTEGER NOT NULL,
    PRIMARY KEY (movement_id, variation)
);

INSERT INTO movement_variations (movement_id, variation, sort_order)
SELECT mv.id, v.variation, v.sort_order
FROM (VALUES
    ('Back Extensions', '45 Degree', 0),
    ('Back Extensions', 'Horizontal', 1),
    ('Backward Lunge', 'Deficit', 0),
    ('Bent Over Rows', 'Narrow Grip', 0),
    ('Bent Over Rows', 'Wide Grip', 1),
    ('Bulgarian Split Squat', 'Deficit', 0),
    ('Calf Holds', 'Standing', 0),
    ('Calf Holds', 'Seated', 1),
    ('Calf Holds', 'Bent Legged', 2),
    ('Calf Raise', 'Standing', 0),
    ('Calf Raise', 'Seated', 1),
    ('Calf Raise', 'Stiff Legged', 2),
    ('Calf Raise', 'Bent Legged', 3),
    ('Crunch', 'Bosu', 0),
    ('Crunch', 'Kneeling', 1),
    ('Deadlift', 'Deficit', 0),
    ('Knee Raise', 'Hanging', 0),
    ('Knee Raise', 'Lying', 1),
    ('Knee Raise', 'Incline', 2),
    ('Lateral Raise', 'Cuffed', 0),
    ('Lateral Raise', 'Lying', 1),
    ('Lateral Raise', '65 Degree', 2),
    ('Leg Curl', 'Seated', 0),
    ('Leg Curl', 'Lying', 1),
    ('Leg Curl', 'Standing', 2),
    ('Leg Press', '45 Degree', 0),
    ('Leg Press', 'Horizontal', 1),
    ('Leg Raise', 'Hanging', 0),
    ('Leg Raise', 'Lying', 1),
    ('Leg Raise', 'Incline', 2),
    ('Pull Down', 'Narrow Grip', 0),
    ('Pull Down', 'Neutral Grip', 1),
    ('Pull Down', 'Supinated Grip', 2),
    ('Pull Up', 'Narrow Grip', 0),
    ('Pull Up', 'Neutral Grip', 1),
    ('Romanian Deadlift', 'Deficit', 0),
    ('Rotation', 'Bent Over', 0),
    ('Rotation', 'High To Low', 1),
    ('Rotation', 'Low To High', 2),
    ('Row', 'Narrow Grip', 0),
    ('Row', 'Neutral Grip', 1),
    ('Row', 'Wide Grip', 2),
    ('Shoulder Press', 'Seated', 0),
    ('Shoulder Press', 'Standing', 1),
    ('Side Extensions', 'Standing', 0),
    ('Side Extensions', '45 Degree', 1),
    ('Squat', 'High Bar', 0),
    ('Squat', 'Low Bar', 1),
    ('Stiff Legged Deadlift', 'Deficit', 0),
    ('Tricep Press', 'Lying', 0),
    ('Tricep Press Overhead', 'Seated', 0),
    ('Tricep Press Overhead', 'Standing', 1),
    ('Tricep Press Overhead', 'Kneeling', 2),
    ('Tricep Pushdown', 'Rope', 0)
) AS v(movement_name, variation, sort_order)
JOIN movements mv ON mv.name = v.movement_name;

-- ── 3. can_be_unilateral per (movement, equipment) ──
--    Sheet value, except: barbell + a movement whose PRIMARY muscle is
--    tricep, bicep, back/lats, or a delt head (shoulders) is forced false.
ALTER TABLE movement_equipment ADD COLUMN can_be_unilateral BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE movement_equipment me
SET can_be_unilateral = v.can_be_unilateral
FROM (VALUES
    ('Back Extensions', 'bodyweight', TRUE),
    ('Back Extensions', 'weighted', TRUE),
    ('Backward Lunge', 'barbell', FALSE),
    ('Backward Lunge', 'dumbbell', FALSE),
    ('Bench Press', 'barbell', FALSE),
    ('Bench Press', 'smith-machine', FALSE),
    ('Bent Over Rows', 'barbell', FALSE),
    ('Bent Over Rows', 'dumbbell', TRUE),
    ('Bicep Curl', 'barbell', FALSE),
    ('Bicep Curl', 'cable', TRUE),
    ('Bicep Curl', 'dumbbell', TRUE),
    ('Bicep Curl', 'ez-bar', TRUE),
    ('Bicep Curl', 'keiser', TRUE),
    ('Bicep Curl', 'machine', TRUE),
    ('Bulgarian Split Squat', 'barbell', FALSE),
    ('Bulgarian Split Squat', 'dumbbell', FALSE),
    ('Bulgarian Split Squat', 'smith-machine', FALSE),
    ('Cable Pull Over', 'cable', FALSE),
    ('Calf Holds', 'barbell', TRUE),
    ('Calf Holds', 'bodyweight', TRUE),
    ('Calf Holds', 'dumbbell', TRUE),
    ('Calf Holds', 'keiser', TRUE),
    ('Calf Holds', 'machine', TRUE),
    ('Calf Holds', 'smith-machine', TRUE),
    ('Calf Raise', 'barbell', TRUE),
    ('Calf Raise', 'bodyweight', TRUE),
    ('Calf Raise', 'dumbbell', TRUE),
    ('Calf Raise', 'keiser', TRUE),
    ('Calf Raise', 'machine', TRUE),
    ('Calf Raise', 'smith-machine', TRUE),
    ('Chest Press', 'dumbbell', FALSE),
    ('Chest Press', 'machine', FALSE),
    ('Chins', 'bodyweight', FALSE),
    ('Chins', 'weighted', FALSE),
    ('Crunch', 'bodyweight', FALSE),
    ('Crunch', 'cable', FALSE),
    ('Crunch', 'weighted', FALSE),
    ('Deadlift', 'barbell', FALSE),
    ('Deadlift', 'keiser', FALSE),
    ('Deadlift', 'smith-machine', FALSE),
    ('Decline Chest Press', 'barbell', FALSE),
    ('Decline Chest Press', 'dumbbell', FALSE),
    ('Decline Chest Press', 'machine', FALSE),
    ('Decline Chest Press', 'smith-machine', FALSE),
    ('Dips', 'bodyweight', FALSE),
    ('Dips', 'machine', FALSE),
    ('Dips', 'weighted', FALSE),
    ('Facepull', 'cable', FALSE),
    ('Facepull', 'keiser', FALSE),
    ('Facepull', 'machine', FALSE),
    ('Fly', 'cable', FALSE),
    ('Fly', 'dumbbell', FALSE),
    ('Fly', 'keiser', FALSE),
    ('Fly', 'machine', FALSE),
    ('Forward Lunge', 'barbell', FALSE),
    ('Forward Lunge', 'dumbbell', FALSE),
    ('Front Raise', 'barbell', FALSE),
    ('Front Raise', 'cable', TRUE),
    ('Front Raise', 'dumbbell', TRUE),
    ('Front Squat', 'barbell', FALSE),
    ('Front Squat', 'dumbbell', FALSE),
    ('Front Squat', 'smith-machine', FALSE),
    ('GHR', 'bodyweight', FALSE),
    ('GHR', 'weighted', FALSE),
    ('Goblet Squat', 'dumbbell', FALSE),
    ('Goblet Squat', 'kettlebell', FALSE),
    ('Good Mornings', 'barbell', TRUE),
    ('Good Mornings', 'smith-machine', TRUE),
    ('Hack Squat', 'machine', FALSE),
    ('Hack Squat', 'smith-machine', FALSE),
    ('Hip Abductor', 'machine', FALSE),
    ('Hip Thrust', 'barbell', FALSE),
    ('Hip Thrust', 'bodyweight', FALSE),
    ('Hip Thrust', 'dumbbell', FALSE),
    ('Hip Thrust', 'machine', FALSE),
    ('Hip Thrust', 'smith-machine', FALSE),
    ('Incline Bicep Curl', 'cable', TRUE),
    ('Incline Bicep Curl', 'dumbbell', TRUE),
    ('Incline Bicep Curl', 'keiser', TRUE),
    ('Incline Chest Press', 'barbell', FALSE),
    ('Incline Chest Press', 'dumbbell', FALSE),
    ('Incline Chest Press', 'machine', FALSE),
    ('Incline Chest Press', 'smith-machine', FALSE),
    ('JM Press', 'barbell', FALSE),
    ('JM Press', 'dumbbell', TRUE),
    ('JM Press', 'smith-machine', TRUE),
    ('Knee Raise', 'bodyweight', FALSE),
    ('Knee Raise', 'weighted', FALSE),
    ('Lateral Raise', 'cable', TRUE),
    ('Lateral Raise', 'dumbbell', TRUE),
    ('Lateral Raise', 'machine', TRUE),
    ('Leg Curl', 'machine', TRUE),
    ('Leg Curl', 'trx', TRUE),
    ('Leg Extension', 'keiser', TRUE),
    ('Leg Extension', 'machine', TRUE),
    ('Leg Press', 'keiser', TRUE),
    ('Leg Press', 'machine', TRUE),
    ('Leg Raise', 'bodyweight', FALSE),
    ('Leg Raise', 'weighted', FALSE),
    ('Narrow Grip Bench Press', 'barbell', FALSE),
    ('Narrow Grip Bench Press', 'smith-machine', FALSE),
    ('Nordic Hamstring', 'bodyweight', FALSE),
    ('Preacher Curl', 'barbell', FALSE),
    ('Preacher Curl', 'cable', TRUE),
    ('Preacher Curl', 'dumbbell', TRUE),
    ('Preacher Curl', 'ez-bar', TRUE),
    ('Preacher Curl', 'machine', TRUE),
    ('Pull Down', 'cable', TRUE),
    ('Pull Down', 'machine', TRUE),
    ('Pull Down Wide Grip', 'cable', FALSE),
    ('Pull Down Wide Grip', 'machine', FALSE),
    ('Pull Up', 'bodyweight', FALSE),
    ('Pull Up', 'weighted', FALSE),
    ('Pull Up Wide Grip', 'bodyweight', FALSE),
    ('Pull Up Wide Grip', 'weighted', FALSE),
    ('Push Up', 'bodyweight', FALSE),
    ('Push Up', 'weighted', FALSE),
    ('Reverse Fly', 'cable', TRUE),
    ('Reverse Fly', 'dumbbell', TRUE),
    ('Reverse Fly', 'machine', TRUE),
    ('Reverse Nordics', 'bodyweight', FALSE),
    ('Reverse Nordics', 'dumbbell', FALSE),
    ('Reverse Nordics', 'weighted', FALSE),
    ('Romanian Deadlift', 'barbell', TRUE),
    ('Romanian Deadlift', 'dumbbell', TRUE),
    ('Romanian Deadlift', 'keiser', TRUE),
    ('Romanian Deadlift', 'smith-machine', TRUE),
    ('Rotation', 'cable', FALSE),
    ('Rotation', 'machine', FALSE),
    ('Row', 'cable', TRUE),
    ('Row', 'dumbbell', TRUE),
    ('Row', 'machine', TRUE),
    ('Shoulder Press', 'barbell', FALSE),
    ('Shoulder Press', 'dumbbell', TRUE),
    ('Shoulder Press', 'machine', TRUE),
    ('Shoulder Press', 'smith-machine', TRUE),
    ('Shrugs', 'barbell', TRUE),
    ('Shrugs', 'dumbbell', TRUE),
    ('Shrugs', 'machine', TRUE),
    ('Shrugs', 'smith-machine', TRUE),
    ('Side Extensions', 'cable', FALSE),
    ('Side Extensions', 'dumbbell', FALSE),
    ('Side Extensions', 'kettlebell', FALSE),
    ('Sissy Squat', 'bodyweight', FALSE),
    ('Split Squat', 'barbell', FALSE),
    ('Split Squat', 'dumbbell', FALSE),
    ('Split Squat', 'smith-machine', FALSE),
    ('Squat', 'barbell', FALSE),
    ('Squat', 'bodyweight', FALSE),
    ('Squat', 'smith-machine', FALSE),
    ('Step Down', 'barbell', FALSE),
    ('Step Down', 'bodyweight', FALSE),
    ('Step Down', 'dumbbell', FALSE),
    ('Step Down', 'kettlebell', FALSE),
    ('Step Up', 'barbell', FALSE),
    ('Step Up', 'bodyweight', FALSE),
    ('Step Up', 'dumbbell', FALSE),
    ('Step Up', 'kettlebell', FALSE),
    ('Stiff Legged Deadlift', 'barbell', TRUE),
    ('Stiff Legged Deadlift', 'dumbbell', TRUE),
    ('Stiff Legged Deadlift', 'keiser', TRUE),
    ('Stiff Legged Deadlift', 'smith-machine', TRUE),
    ('Tricep Press', 'barbell', FALSE),
    ('Tricep Press', 'cable', FALSE),
    ('Tricep Press', 'dumbbell', FALSE),
    ('Tricep Press', 'ez-bar', FALSE),
    ('Tricep Press', 'machine', FALSE),
    ('Tricep Press Overhead', 'cable', FALSE),
    ('Tricep Press Overhead', 'dumbbell', FALSE),
    ('Tricep Press Overhead', 'ez-bar', FALSE),
    ('Tricep Press Overhead', 'keiser', FALSE),
    ('Tricep Pushdown', 'cable', TRUE),
    ('Tricep Pushdown', 'keiser', TRUE),
    ('Upright Row', 'barbell', FALSE),
    ('Upright Row', 'cable', TRUE),
    ('Upright Row', 'dumbbell', TRUE),
    ('Upright Row', 'smith-machine', TRUE),
    ('Walking Lunge', 'barbell', FALSE),
    ('Walking Lunge', 'dumbbell', FALSE)
) AS v(movement_name, equipment_slug, can_be_unilateral)
JOIN movements mv ON mv.name = v.movement_name
JOIN equipment eq ON eq.slug = v.equipment_slug
WHERE me.movement_id = mv.id AND me.equipment_id = eq.id;

-- Sanity: every movement_equipment row should have been set by the UPDATE
-- above (one VALUES row per live (movement, equipment) pair). A mismatch
-- means the sheet and the live movement_equipment table have drifted.
DO $$
DECLARE
    missing INTEGER;
BEGIN
    SELECT COUNT(*) INTO missing FROM movement_equipment;
    IF missing != 179 THEN
        RAISE EXCEPTION 'expected 179 movement_equipment rows, found %', missing;
    END IF;
END $$;
