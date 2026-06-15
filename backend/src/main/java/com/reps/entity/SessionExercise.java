package com.reps.entity;

import com.reps.enums.TrainingMethod;
import jakarta.persistence.*;
import lombok.*;

import org.hibernate.annotations.BatchSize;

import java.util.ArrayList;
import java.util.List;

/**
 * One exercise entry within a workout session.
 */
@Entity
@Table(name = "session_exercises")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SessionExercise {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "session_id")
    private WorkoutSession session;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "exercise_id")
    private Exercise exercise;

    @Column(nullable = false)
    private Integer exerciseOrder;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private TrainingMethod trainingMethod = TrainingMethod.STRAIGHT_SETS;

    /** Superset / triset grouping within the session. */
    private String supersetGroupId;

    @OneToMany(mappedBy = "sessionExercise", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("setNumber ASC")
    @BatchSize(size = 30)
    @Bui