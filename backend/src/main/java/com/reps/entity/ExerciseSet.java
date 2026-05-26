package com.reps.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * One logged set within a session exercise.
 */
@Entity
@Table(name = "exercise_sets")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ExerciseSet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "session_exercise_id")
    private SessionExercise sessionExercise;

    @Column(nullable = false)
    private Integer setNumber;

    /** Weight lifted in kg (can be null for bodyweight exercises). */
    @Column(precision = 6, scale = 2)
    private BigDecimal weightKg;

    @Column(nullable = false)
    private Integer reps;

    /** Rate of perceived exertion 1-10. */
    private Integer rpe;

    /** Actual rest taken after this set, in seconds. */
    private Integer restSeconds;

    @CreationTimestamp
    @Column(updatable = false)
    private Instant completedAt;
}
