package com.reps.entity;

import com.reps.enums.MovementPattern;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.List;

/**
 * A specific (movement, equipment, variation) combination a workout actually
 * logs against - "Barbell Squat", "Smith Machine Squat (Seated)". This is
 * the "exercise" row {@code workout_template_exercises} / {@code
 * session_exercises} point at, so every one of these ids carries real
 * history: it is never safe to delete or repoint one casually.
 *
 * Muscle mapping, compound/isolation classification, description/cues/image
 * all live on {@link #movement} instead of here, since none of them change
 * with equipment - the getters below delegate there so the rest of the
 * codebase (which reads {@code exercise.getMuscles()} /
 * {@code .getMovementPattern()} etc.) didn't need to change when this split
 * happened.
 */
@Entity
@Table(name = "exercises")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Exercise {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Cached display name, e.g. "Barbell Squat" - see ExerciseService.buildDisplayName. */
    @Column(nullable = false, length = 150)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "movement_id")
    private Movement movement;

    /** Null only for the handful of movements with no equipment at all (e.g. Ab Wheel Roll Out). */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipment_id")
    private Equipment equipment;

    /** Free-text detail - "Seated", "Cuffed", "45 Degree". Not a fixed enum. */
    @Column(length = 100)
    private String variation;

    /** Whether this is a custom user-created variant (null = global). */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by_user_id")
    private User createdBy;

    @CreationTimestamp
    @Column(updatable = false)
    private Instant createdAt;

    // ── Delegated to the movement - equipment doesn't change any of these ──

    public List<ExerciseMuscle> getMuscles() {
        return movement.getMuscles();
    }

    public MovementPattern getMovementPattern() {
        return movement.getMovementPattern();
    }

    public String getDescription() {
        return movement.getDescription();
    }

    public String getCues() {
        return movement.getCues();
    }

    public String getImageUrl() {
        return movement.getImageUrl();
    }
}
