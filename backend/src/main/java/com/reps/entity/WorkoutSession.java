package com.reps.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import org.hibernate.annotations.BatchSize;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * A completed or in-progress workout instance, linked to a template.
 */
@Entity
@Table(name = "workout_sessions")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class WorkoutSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "template_id")
    private WorkoutTemplate template;

    @Column(nullable = false)
    private Instant startedAt;

    private Instant completedAt;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @CreationTimestamp
    @Column(updatable = false)
    private Instant createdAt;

    @OneToMany(mappedBy = "session", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("exerciseOrder ASC")
    @BatchSize(size = 20)
    @Builder.Defa