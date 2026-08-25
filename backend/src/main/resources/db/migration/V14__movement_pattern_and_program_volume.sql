-- V14 - movement pattern on exercises + the program's weekly volume target.
--
-- Compound vs isolation cannot be derived from exercise_muscles: 'Bench Press'
-- carries exactly one PRIMARY muscle (chest), the same as 'Lateral Raise
-- Dumbbell', so a "2+ primary muscles = compound" rule mislabels every
-- horizontal press, push-up and narrow-grip pull-up. The classification below is
-- curated by name against the V8 library (mind the 'Hip Thrust Bardbell' typo and
-- the lowercase 'Leg extension' - those names are the join key).
--
-- Multi-joint = compound, single-joint = isolation, with two judgement calls:
-- hip thrusts and hinges (RDL / SLDL / good mornings) count as compound because
-- they are loaded and programmed like main lifts, and face pulls count as
-- isolation because they are accessory work and a good myo-rep candidate.

ALTER TABLE exercises
    ADD COLUMN movement_pattern VARCHAR(20) NOT NULL DEFAULT 'ISOLATION';

UPDATE exercises SET movement_pattern = 'COMPOUND' WHERE name IN (
    'Squat', 'Front Squat', 'Machine Leg Press',
    'Box Step Up', 'Forward Lunge Barbell', 'Forward Lunge Dumbbell',
    'Backward Lunge Barbell', 'Backward Lunge Dumbbell', 'Walking Lunge Barbell',
    'Walking Lunge Dumbbell', 'Bulgarian Split Squat Dumbbell', 'Bulgarian Split Squat Barbell',
    'Deadlift', 'Stiff Legged Deadlift', 'Romanian Deadlift',
    'Good Mornings', 'GHR', 'Hip Thrust Bardbell',
    'Hip Thrust Machine', 'Shoulder Press Barbell', 'Shoulder Press Dumbbell',
    'Shoulder Press Smith', 'Upright Row Barbell', 'Upright Row Dumbbell',
    'Upright Row Smith', 'Upright Row Cable', 'Bench Press',
    'Bench Press Smith', 'Chest Press Dumbbell', 'Chest Press Machine',
    'Incline Chest Press Barbell', 'Incline Chest Press Dumbbell', 'Incline Chest Press Smith',
    'Incline Chest Press Machine', 'Decline Chest Press Machine', 'Dips',
    'Push Up', 'Push Up with Weight', 'Pull Up Wide Grip',
    'Pull Up Narrow Grip', 'Pull Up Neutral Grip', 'Chins',
    'Pull Down Wide Grip', 'Pull Down Narrow Grip', 'Pull Down Neutral Grip',
    'Pendlay Rows', 'Barbell Bent Over Rows', 'Dumbbell Bent Over Rows',
    'Dumbbell Row Unilateral', 'Wide Grip Machine Row', 'Narrow Grip Machine Row',
    'Narrow Grip Cable Row', 'Wide Grip Cable Row', 'Narrow Grip Bench Press',
    'JM Press Smith'
);

-- User-created exercises default to ISOLATION; the app lets them be reclassified.

-- The guided program builder asks for a weekly set target per muscle group and
-- allocates exercises against it. Keeping the number lets a program be re-opened
-- and re-balanced later instead of only surviving as a fitness_level bucket.
ALTER TABLE training_programs
    ADD COLUMN weekly_sets_per_muscle INTEGER;

UPDATE training_programs SET weekly_sets_per_muscle = CASE fitness_level
    WHEN 'BEGINNER'     THEN 8
    WHEN 'INTERMEDIATE' THEN 12
    WHEN 'ADVANCED'     THEN 18
    ELSE 12
END;
