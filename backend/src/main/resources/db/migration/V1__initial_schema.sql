-- ============================================================
-- V1: Initial schema
-- ============================================================

CREATE TABLE users (
    id              BIGSERIAL PRIMARY KEY,
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    name            VARCHAR(100) NOT NULL,
    fitness_level   VARCHAR(20)  NOT NULL CHECK (fitness_level IN ('BEGINNER','INTERMEDIATE','ADVANCED')),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE muscle_groups (
    id   BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(50)  NOT NULL UNIQUE
);

CREATE TABLE exercises (
    id                  BIGSERIAL PRIMARY KEY,
    name                VARCHAR(150) NOT NULL,
    description         TEXT,
    cues                TEXT,
    image_url           VARCHAR(512),
    created_by_user_id  BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE exercise_muscles (
    id              BIGSERIAL PRIMARY KEY,
    exercise_id     BIGINT NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    muscle_group_id BIGINT NOT NULL REFERENCES muscle_groups(id) ON DELETE CASCADE,
    role            VARCHAR(20) NOT NULL CHECK (role IN ('PRIMARY','SECONDARY')),
    UNIQUE (exercise_id, muscle_group_id)
);

CREATE TABLE training_programs (
    id                      BIGSERIAL PRIMARY KEY,
    user_id                 BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name                    VARCHAR(150) NOT NULL,
    fitness_level           VARCHAR(20)  NOT NULL,
    goal                    VARCHAR(20)  NOT NULL CHECK (goal IN ('HYPERTROPHY','STRENGTH')),
    strength_days_per_week  INT NOT NULL,
    cardio_days_per_week    INT NOT NULL DEFAULT 0,
    cardio_type             VARCHAR(20),
    active                  BOOLEAN NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE workout_templates (
    id          BIGSERIAL PRIMARY KEY,
    program_id  BIGINT NOT NULL REFERENCES training_programs(id) ON DELETE CASCADE,
    name        VARCHAR(100) NOT NULL,
    day_index   INT NOT NULL  -- 0=Mon … 6=Sun
);

CREATE TABLE workout_template_exercises (
    id                BIGSERIAL PRIMARY KEY,
    template_id       BIGINT NOT NULL REFERENCES workout_templates(id) ON DELETE CASCADE,
    exercise_id       BIGINT NOT NULL REFERENCES exercises(id),
    exercise_order    INT NOT NULL,
    sets              INT NOT NULL DEFAULT 3,
    reps_min          INT,
    reps_max          INT,
    rest_seconds      INT,
    training_method   VARCHAR(20) NOT NULL DEFAULT 'STRAIGHT_SETS'
                      CHECK (training_method IN ('STRAIGHT_SETS','MYOREPS','SUPERSET','TRISET','DROP_SET')),
    superset_group_id VARCHAR(50)
);

CREATE TABLE workout_sessions (
    id           BIGSERIAL PRIMARY KEY,
    user_id      BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    template_id  BIGINT REFERENCES workout_templates(id) ON DELETE SET NULL,
    started_at   TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    notes        TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE session_exercises (
    id                BIGSERIAL PRIMARY KEY,
    session_id        BIGINT NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
    exercise_id       BIGINT NOT NULL REFERENCES exercises(id),
    exercise_order    INT NOT NULL,
    training_method   VARCHAR(20) NOT NULL DEFAULT 'STRAIGHT_SETS',
    superset_group_id VARCHAR(50)
);

CREATE TABLE exercise_sets (
    id                    BIGSERIAL PRIMARY KEY,
    session_exercise_id   BIGINT NOT NULL REFERENCES session_exercises(id) ON DELETE CASCADE,
    set_number            INT NOT NULL,
    weight_kg             NUMERIC(6,2),
    reps                  INT NOT NULL,
    rpe                   INT CHECK (rpe BETWEEN 1 AND 10),
    rest_seconds          INT,
    completed_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE body_weight_logs (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    weight_kg   NUMERIC(6,2) NOT NULL,
    log_date    DATE NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, log_date)
);

-- Indexes
CREATE INDEX idx_exercise_sets_session_exercise ON exercise_sets(session_exercise_id);
CREATE INDEX idx_session_exercises_session ON session_exercises(session_id);
CREATE INDEX idx_workout_sessions_user ON workout_sessions(user_id);
CREATE INDEX idx_workout_sessions_template ON workout_sessions(template_id);
CREATE INDEX idx_body_weight_logs_user ON body_weight_logs(user_id, log_date);
CREATE INDEX idx_training_programs_user ON training_programs(user_id);
