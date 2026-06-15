-- ============================================================
-- V7: Replace surrogate PK on exercise_muscles with composite PK
--     (exercise_id, muscle_group_id) is already unique — the id
--     column is redundant and is dropped.
-- ============================================================

ALTER TABLE exercise_muscles DROP CONSTRAINT exercise_muscles_pkey;
ALTER TABLE exercise_muscles DROP COLUMN id;
ALTER TABLE exercise_muscles ADD PRIMARY KEY (exercise_id, muscle_group_id);
