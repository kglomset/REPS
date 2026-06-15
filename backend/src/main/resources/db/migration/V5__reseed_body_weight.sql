-- V5: Re-seed body weight logs for admin (Tue/Fri/Sun, 3 months)
DO $$
DECLARE v_user_id BIGINT;
BEGIN
  SELECT id INTO v_user_id FROM users WHERE email = 'admin@reps.dev';
  IF v_user_id IS NOT NULL THEN
    DELETE FROM body_weight_logs WHERE user_id = v_user_id;
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 84.1, '2026-02-22');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.7, '2026-02-24');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.8, '2026-02-27');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.8, '2026-03-01');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 84.1, '2026-03-03');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 84.0, '2026-03-06');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 84.1, '2026-03-08');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.6, '2026-03-10');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.8, '2026-03-13');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.5, '2026-03-15');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.6, '2026-03-17');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.8, '2026-03-20');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.5, '2026-03-22');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.6, '2026-03-24');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.8, '2026-03-27');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.7, '2026-03-29');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.5, '2026-03-31');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.7, '2026-04-03');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.8, '2026-04-05');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.3, '2026-04-07');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.8, '2026-04-10');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.7, '2026-04-12');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.5, '2026-04-14');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.3, '2026-04-17');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.8, '2026-04-19');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.4, '2026-04-21');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.2, '2026-04-24');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.2, '2026-04-26');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.6, '2026-04-28');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.5, '2026-05-01');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.6, '2026-05-03');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.5, '2026-05-05');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.4, '2026-05-08');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.6, '2026-05-10');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.2, '2026-05-12');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.3, '2026-05-15');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.5, '2026-05-17');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.3, '2026-05-19');
    INSERT INTO body_weight_logs (user_id, weight_kg, log_date) VALUES (v_user_id, 83.4, '2026-05-22');
  END IF;
END $$;