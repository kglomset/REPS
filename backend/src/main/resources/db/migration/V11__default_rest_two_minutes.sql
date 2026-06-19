-- V11: Default rest period for hypertrophy-style work is now 2 minutes.
-- Bump existing template exercises that still use the old 90s default to 120s.
UPDATE workout_template_exercises
SET rest_seconds = 120
WHERE rest_seconds = 90;
