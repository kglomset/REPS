package com.reps.entity;

import com.reps.enums.MuscleRole;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "exercise_muscles",
       uniqueConstraints = @UniqueConstraint(columnNames = {"exercise_id", "muscle_group_id"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ExerciseMuscle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "exercise_id")
    private Exercise exercise;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "muscle_group_id")
    private MuscleGroup muscleGroup;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MuscleRole role;
}
