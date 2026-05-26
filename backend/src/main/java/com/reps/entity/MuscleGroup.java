package com.reps.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "muscle_groups")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MuscleGroup {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 100)
    private String name;

    @Column(nullable = false, unique = true, length = 50)
    private String slug;

    @OneToMany(mappedBy = "muscleGroup", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<ExerciseMuscle> exerciseMuscles = new ArrayList<>();
}
