-- ============================================================
-- V2: Seed muscle groups
-- ============================================================
INSERT INTO muscle_groups (name, slug) VALUES
    ('Chest',           'chest'),
    ('Upper Back',      'upper-back'),
    ('Lats',            'lats'),
    ('Rear Delts',      'rear-delts'),
    ('Front Delts',     'front-delts'),
    ('Side Delts',      'side-delts'),
    ('Biceps',          'biceps'),
    ('Triceps',         'triceps'),
    ('Forearms',        'forearms'),
    ('Quadriceps',      'quads'),
    ('Hamstrings',      'hamstrings'),
    ('Glutes',          'glutes'),
    ('Calves',          'calves'),
    ('Abdominals',      'abs'),
    ('Lower Back',      'lower-back'),
    ('Traps',           'traps'),
    ('Shoulders',       'shoulders')
ON CONFLICT (slug) DO NOTHING;
