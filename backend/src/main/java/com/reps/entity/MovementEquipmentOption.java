package com.reps.entity;

import jakarta.persistence.*;
import lombok.*;

/**
 * One equipment option the exercise picker offers for a movement (step two,
 * after the movement itself is picked in step one) - replaces the plain
 * movement&lt;-&gt;equipment many-to-many now that each pair also carries its
 * own {@code canBeUnilateral} flag (e.g. Barbell Bicep Curl can't be done
 * unilaterally, Dumbbell Bicep Curl can).
 *
 * Still not an exhaustive enum of "valid" equipment for a movement - picking
 * something outside this list still works (see
 * {@code ExerciseService.resolveVariant}), it just won't be suggested as a
 * chip.
 */
@Entity
@Table(name = "movement_equipment")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MovementEquipmentOption {

    @EmbeddedId
    private MovementEquipmentId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("movementId")
    @JoinColumn(name = "movement_id")
    private Movement movement;

    /**
     * Eager: every place that reads a movement's equipment options wants the
     * equipment's name/slug too, and this is a to-one off a row already
     * loaded by its own per-movement select (see Movement.equipmentOptions) -
     * no bag-duplication risk, same reasoning as muscles -> muscleGroup.
     */
    @ManyToOne(fetch = FetchType.EAGER)
    @MapsId("equipmentId")
    @JoinColumn(name = "equipment_id")
    private Equipment equipment;

    /**
     * Whether this specific (movement, equipment) pair can be logged as a
     * unilateral (one side at a time) variant. Equipment-specific because
     * e.g. a barbell exercise working the tricep/bicep/lats/delts can't be
     * done one arm at a time the way a dumbbell or cable version can - see
     * the override rule documented in V16's migration.
     */
    @Column(name = "can_be_unilateral", nullable = false)
    @Builder.Default
    private boolean canBeUnilateral = false;
}
