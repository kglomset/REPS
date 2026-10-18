package com.reps.entity;

import com.reps.enums.MovementPattern;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * The exercise identity — "Squat", "Bench Press" — independent of what
 * equipment it is performed on. Owns the muscle mapping and the
 * compound/isolation classification, since neither changes with equipment.
 *
 * {@link Exercise} is the (movement, equipment, variation) combination a
 * workout actually logs against — e.g. "Barbell Squat" and "Smith Machine
 * Squat" are two different Exercise rows pointing at this one Movement.
 */
@Entity
@Table(name = "movements")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Movement {

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
     * Multi-joint or single-joint. Drives rep/rest prescription, the compound
     * bias when building a program, and myo-rep eligibility.
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private MovementPattern movementPattern = MovementPattern.ISOLATION;

    /** Whether this is a custom user-created movement (null = global). */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by_user_id")
    private User createdBy;

    @CreationTimestamp
    @Column(updatable = false)
    private Instant createdAt;

    @OneToMany(mappedBy = "movement", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @Builder.Default
    private List<ExerciseMuscle> muscles = new ArrayList<>();

    /**
     * Which equipment the exercise picker offers for this movement (step two,
     * after the movement itself is picked in step one), each carrying its own
     * {@code canBeUnilateral} flag. Not an exhaustive enum of "valid"
     * equipment — picking something outside this list still works (see
     * {@code ExerciseService.resolveVariant}), it just won't be suggested as
     * a chip.
     *
     * This is its own EAGER collection, loaded via its own per-movement
     * select - like {@code muscles}, it must never be join-fetched together
     * with another List-typed ("bag") collection in the same query, or
     * Hibernate re-appends rows once per sibling in the cross product (see
     * MovementRepository's query comment for the full story).
     */
    @OneToMany(mappedBy = "movement", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @Builder.Default
    private List<MovementEquipmentOption> equipmentOptions = new ArrayList<>();

    /**
     * Curated variation chips the picker offers for this movement (e.g.
     * "Narrow Grip", "Wide Grip" for Row) - replaces what used to be a free
     * text field on the exercise. Movements with none simply hide the
     * variation section, same as a movement with no equipment options today.
     *
     * Also its own EAGER collection for the same reason as equipmentOptions
     * above - never join-fetched alongside another bag.
     */
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "movement_variations", joinColumns = @JoinColumn(name = "movement_id"))
    @OrderColumn(name = "sort_order")
    @Column(name = "variation", nullable = false, length = 100)
    @Builder.Default
    private List<String> variations = new ArrayList<>();
}
