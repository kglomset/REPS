-- ============================================================
-- Delete ALL workout/exercise data for the admin user.
-- Run directly against the database at a convenient time
-- (NOT a Flyway migration):
--   psql "$DATABASE_URL" -f scripts/delete_admin_workout_data.sql
--
-- Deletes workout_sessions for admin@reps.dev; session_exercises and
-- exercise_sets are removed automatically via ON DELETE CASCADE.
-- Programs, templates, and the exercise library are left untouched.
-- ============================================================
BEGIN;

DELETE FROM workout_sessions
 WHERE user_id = (SELECT id FROM users WHERE email = 'admin@reps.dev') AND started_at < '2026-05-30 08:00:00.000000 +00:00'
;

COMMIT;