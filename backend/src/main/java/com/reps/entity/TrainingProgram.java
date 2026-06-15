package com.reps.entity;

import com.reps.enums.CardioType;
import com.reps.enums.FitnessLevel;
import com.reps.enums.TrainingGoal;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "training_programs")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class TrainingProgram {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(nullable = false, length = 150)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private FitnessLevel fitnessLevel;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TrainingGoal goal;

    @Column(nullable = false)
    private Integer strengthDaysPerWeek;

    @Column(nullable = false)
    private Integer cardioDaysPerWeek;

    @Enumerated(EnumType.STRING)
    private CardioType cardioType;

    /** Whether this is the currently active program for the user. */
    @Column(nullable = false)
    @Builder.Default
    private Boolean active = true;

    @CreationTimestamp
    @Column(updatable = false)
    private Instant createdAt;

    @OneToMany(mappedBy = "program", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("dayIndex ASC")
    @Builder.Default
    private List<WorkoutTemplate> workoutTemplates = new ArrayList<>();
}
