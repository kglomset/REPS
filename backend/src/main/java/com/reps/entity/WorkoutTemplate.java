package com.reps.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

/**
 * A named workout day within a training program (e.g. "Upper A", "Push Day").
 * dayIndex = 0-based week position (0=Monday … 6=Sunday).
 */
@Entity
@Table(name = "workout_templates")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class WorkoutTemplate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "program_id")
    private TrainingProgram program;

    @Column(nullable = false, length = 100)
    private String name;

    /** 0 = Monday … 6 = Sunday */
    @Column(nullable = false)
    private Integer dayIndex;

    @OneToMany(mappedBy = "template", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("exerciseOrder ASC")
    @Builder.Default
    private List<WorkoutTemplateExercise> exercises = new ArrayList<>();
}
