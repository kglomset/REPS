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

    /**
     * Owning program. Null for standalone workout sessions, which belong to a
     * user directly (see {@link #user}) and are not scheduled on any day.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "program_id")
    private TrainingProgram program;

    /**
     * Direct owner for standalone templates (program is null). Program-owned
     * templates leave this null and resolve their owner through the program.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    /** True for a standalone workout not tied to a program or calendar day. */
    @Column(nullable = false)
    @Builder.Default
    private Boolean standalone = false;

    @Column(nullable = false, length = 100)
    private String name;

    /** 0 = Monday … 6 = Sunday. Null for standalone templates. */
    private Integer dayIndex;

    @OneToMany(mappedBy = "template", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("exerciseOrder ASC")
    @Builder.Default
    private List<WorkoutTemplateExercise> exercises = new ArrayList<>();
}
