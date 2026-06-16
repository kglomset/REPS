-- ============================================================
-- V9: Add obliques muscle group (missed in V2) and re-map
--     exercises that reference it in V8 (silently no-op'd
--     because the slug didn't exist yet).
-- ============================================================

-- 1. Add the missing muscle group
INSERT INTO muscle_groups (name, slug)
VALUES ('Obliques', 'obliques')
ON CONFLICT (slug) DO NOTHING;

-- 2. Re-insert exercise_muscle rows that reference obliques
--    (these were skipped in V8 because obliques didn't exist)

-- Rotation Cable  → obliques PRIMARY
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'PRIMARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Rotation Cable' AND mg.slug = 'obliques'
  AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Bent Over Rotation Cable → obliques PRIMARY
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'PRIMARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Bent Over Rotation Cable' AND mg.slug = 'obliques'
  AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Side Extensions 45 Degree → obliques PRIMARY
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'PRIMARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Side Extensions 45 Degree' AND mg.slug = 'obliques'
  AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Bosu Crunch → obliques SECONDARY
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'SECONDARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Bosu Crunch' AND mg.slug = 'obliques'
  AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Cable Crunch → obliques SECONDARY
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'SECONDARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Cable Crunch' AND mg.slug = 'obliques'
  AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Leg Raise → obliques SECONDARY
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'SECONDARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Leg Raise' AND mg.slug = 'obliques'
  AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Ab Wheel Roll Out → obliques SECONDARY
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'SECONDARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Ab Wheel Roll Out' AND mg.slug = 'obliques'
  AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Incline Knee Raise → obliques SECONDARY
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'SECONDARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Incline Knee Raise' AND mg.slug = 'obliques'
  AND e.created_by IS NULL
ON CONFLICT DO NOTHING;

-- Hanging Knee Raise → obliques SECONDARY
INSERT INTO exercise_muscles (exercise_id, muscle_group_id, role)
SELECT e.id, mg.id, 'SECONDARY'
FROM exercises e, muscle_groups mg
WHERE e.name = 'Hanging Knee Raise' AND mg.slug = 'obliques'
  AND e.created_by IS NULL
ON CONFLICT DO NOTHING;
