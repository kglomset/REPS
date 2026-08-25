package com.reps.entity;

import com.reps.enums.MovementPattern;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "exercises")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Exercise {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(columnDefinition = "TEXT")
    private String cues;

    @Column(length = 512)
    private String imageUrl;

    /**
     * Multi-joint or single-joint. Curated per exercise in V14 — it cannot be
     * inferred from the muscle mapping. Drives rep/rest prescription, the
     * compound bias when building a program, and myo-rep eligibility.
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private MovementPattern movementPattern = MovementPattern.ISOLATION;

    /** Whether this is a custom user-created exercise (null = global). */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by_user_id")
    private User createdBy;

    @CreationTimestamp
    @Column(updatable = false)
    private Instant createdAt;

    @OneToMany(mappedBy = "exercise", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @Builder.Default
    private List<ExerciseMuscle> muscles = new ArrayList<>();
}
