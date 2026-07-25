-- Widen fixed rep targets into goal-based ranges.
--
-- Custom-built programs previously stored reps_min = reps_max (a single rep
-- target), which left double-progression no range to grow reps into — so
-- hitting the target on all sets jumped straight to a weight increase. Convert
-- any program-linked template exercise whose min equals max into the goal's
-- rep range (hypertrophy 8-12, strength 3-6), matching the auto-generator.
UPDATE workout_template_exercises te
SET reps_min = CASE WHEN p.goal = 'STRENGTH' THEN 3 ELSE 8 END,
    reps_max = CASE WHEN p.goal = 'STRENGTH' THEN 6 ELSE 12 END
FROM workout_templates t
JOIN training_programs p ON p.id = t.program_id
WHERE te.template_id = t.id
  AND te.reps_min IS NOT NULL
  AND te.reps_max IS NOT NULL
  AND te.reps_min = te.reps_max;
