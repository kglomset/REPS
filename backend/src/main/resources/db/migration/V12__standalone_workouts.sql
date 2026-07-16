-- Standalone workout sessions: workout templates that are not part of a program
-- and are not scheduled on any calendar day. They are started like a normal
-- workout and logged/tracked as any other session.

-- Templates belonging to a standalone workout have no owning program, so
-- program_id must be nullable and the template needs its own user reference.
ALTER TABLE workout_templates ALTER COLUMN program_id DROP NOT NULL;

ALTER TABLE workout_templates
    ADD COLUMN standalone BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE workout_templates
    ADD COLUMN user_id BIGINT REFERENCES users(id) ON DELETE CASCADE;

-- day_index is meaningless for standalone templates; allow NULL for them.
ALTER TABLE workout_templates ALTER COLUMN day_index DROP NOT NULL;

CREATE INDEX idx_workout_templates_standalone_user
    ON workout_templates(user_id) WHERE standalone = TRUE;
