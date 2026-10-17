package com.reps.entity;

import com.reps.enums.MuscleRole;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "exercise_muscles")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ExerciseMuscle {

    @EmbeddedId
    private ExerciseMuscleId id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("movementId")
    @JoinColumn(name = "movement_id")
    private Movement movement;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("muscleGroupId")
    @JoinColumn(name = "muscle_group_id")
    private MuscleGroup muscleGroup;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MuscleRole role;
}
