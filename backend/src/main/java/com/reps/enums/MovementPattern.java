package com.reps.enums;

/**
 * Multi-joint vs single-joint. Curated per exercise in migration V14 because it
 * cannot be inferred from exercise_muscles: 'Bench Press' carries exactly one
 * PRIMARY muscle, the same as 'Lateral Raise Dumbbell'.
 *
 * Drives three things in the program builder: the rep range and rest a movement
 * is prescribed, how strongly it is favoured when filling a training day, and
 * whether it is eligible for myo-reps.
 */
public enum MovementPattern {
    COMPOUND,
    ISOLATION
}
