-- ============================================================
-- V9: Add obliques muscle group (missed in V2) and re-map
--     exercises that reference it in V8 (silently no-op'd
--     because the slug didn't exist yet).
-- ============================================================

-- 1. Add the missing muscle group
INSERT INTO muscle_groups (name, slug)
VALUES ('Obliques', 'obliques')
ON CONFLICT (slug) DO NOTHING;

-- 2. Re-insert exercise_muscle rows that reference obliques.
--    Name filter alone is sufficient — these are all seeded exercises.

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'PRIMARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Rotation Cable' AND mg.slug = 'obliques'
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'PRIMARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Bent Over Rotation Cable' AND mg.slug = 'obliques'
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'PRIMARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Side Extensions 45 Degree' AND mg.slug = 'obliques'
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'SECONDARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Bosu Crunch' AND mg.slug = 'obliques'
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'SECONDARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Cable Crunch' AND mg.slug = 'obliques'
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'SECONDARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Leg Raise' AND mg.slug = 'obliques'
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'SECONDARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Ab Wheel Roll Out' AND mg.slug = 'obliques'
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'SECONDARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Incline Knee Raise' AND mg.slug = 'obliques'
ON CONFLICT DO NOTHING;

INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'SECONDARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Hanging Knee Raise' AND mg.slug = 'obliques'
ON CONFLICT DO NOTHING;
