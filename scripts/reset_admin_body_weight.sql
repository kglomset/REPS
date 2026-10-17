-- ============================================================
-- Reset + seed body-weight logs for the admin user.
-- Run directly against the database (NOT a Flyway migration):
--   psql "$DATABASE_URL" -f scripts/reset_admin_body_weight.sql
--
-- Deletes all body-weight logs for admin@reps.dev, then inserts:
--   * 45 daily logs   2026-05-25 .. 2026-07-08 (newest value listed first
--     by the user; stored oldest-to-newest here)
--   * 12 Mon/Wed/Sat logs continuing backwards from 2026-05-23
-- ============================================================
BEGIN;

DELETE FROM body_weight_logs
 WHERE user_id = (SELECT id FROM users WHERE email = 'admin@reps.dev');

INSERT INTO body_weight_logs (user_id, weight_kg, log_date)
SELECT u.id, v.weight_kg, v.log_date::date
  FROM users u,
       (VALUES
        ('2026-04-27', 94.7),
        ('2026-04-29', 94.5),
        ('2026-05-02', 94.3),
        ('2026-05-04', 94.4),
        ('2026-05-06', 94.2),
        ('2026-05-09', 94.1),
        ('2026-05-11', 93.9),
        ('2026-05-13', 94.0),
        ('2026-05-16', 93.8),
        ('2026-05-18', 93.9),
        ('2026-05-20', 93.8),
        ('2026-05-23', 93.7),
        ('2026-05-25', 93.5),
        ('2026-05-26', 93.4),
        ('2026-05-27', 93.4),
        ('2026-05-28', 93.2),
        ('2026-05-29', 92.9),
        ('2026-05-30', 93.1),
        ('2026-05-31', 92.9),
        ('2026-06-01', 92.7),
        ('2026-06-02', 92.5),
        ('2026-06-03', 92.4),
        ('2026-06-04', 92.1),
        ('2026-06-05', 92.0),
        ('2026-06-06', 91.8),
        ('2026-06-07', 91.6),
        ('2026-06-08', 91.7),
        ('2026-06-09', 90.9),
        ('2026-06-10', 91.2),
        ('2026-06-11', 91.6),
        ('2026-06-12', 91.7),
        ('2026-06-13', 91.1),
        ('2026-06-14', 91.1),
        ('2026-06-15', 91.2),
        ('2026-06-16', 91.3),
        ('2026-06-17', 90.9),
        ('2026-06-18', 90.3),
        ('2026-06-19', 90.6),
        ('2026-06-20', 90.3),
        ('2026-06-21', 90.8),
        ('2026-06-22', 90.5),
        ('2026-06-23', 90.6),
        ('2026-06-24', 90.9),
        ('2026-06-25', 90.6),
        ('2026-06-26', 90.5),
        ('2026-06-27', 90.1),
        ('2026-06-28', 90.3),
        ('2026-06-29', 89.9),
        ('2026-06-30', 89.9),
        ('2026-07-01', 90.3),
        ('2026-07-02', 90.5),
        ('2026-07-03', 89.8),
        ('2026-07-04', 89.6),
        ('2026-07-05', 90.0),
        ('2026-07-06', 90.2),
        ('2026-07-07', 89.3),
        ('2026-07-08', 89.8)
       ) AS v(log_date, weight_kg)
 WHERE u.email = 'admin@reps.dev'
ON CONFLICT (user_id, log_date) DO UPDATE SET weight_kg = EXCLUDED.weight_kg;

COMMIT;

-- Sanity check: expect 57 rows, 2026-04-27 .. 2026-07-08
SELECT COUNT(*) AS rows, MIN(log_date) AS oldest, MAX(log_date) AS newest
  FROM body_weight_logs
 WHERE user_id = (SELECT id FROM users WHERE email = 'admin@reps.dev');
