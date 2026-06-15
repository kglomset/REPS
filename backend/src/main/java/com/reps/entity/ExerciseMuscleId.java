package com.reps.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.*;

import java.io.Serializable;

@Embeddable
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @EqualsAndHashCode
public class ExerciseMuscleId implements Serializable {

    @Column(name = "exercise_id")
    private Long exerciseId;

    @Column(name = "muscle_group_id")
    private Long muscleGroupId;
}
