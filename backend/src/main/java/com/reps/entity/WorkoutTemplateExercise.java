package com.reps.entity;

import com.reps.enums.TrainingMethod;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "workout_template_exercises")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class WorkoutTemplateExercise {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "template_id")
    private WorkoutTemplate template;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "exercise_id")
    private Exercise exercise;

    @Column(nullable = false)
    private Integer exerciseOrder;

    @Column(nullable = false)
    private Integer sets;

    private Integer repsMin;

    private Integer repsMax;

    /** Target rest in seconds */
    private Integer restSeconds;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private TrainingMethod trainingMethod = TrainingMethod.STRAIGHT_SETS;

    /**
     * Groups exercises into a superset / triset.
     * Null means no grouping. Matching values on the same template = grouped.
     */
    private String supersetGroupId;
}
