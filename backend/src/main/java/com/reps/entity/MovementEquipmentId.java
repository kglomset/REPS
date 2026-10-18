package com.reps.entity;

import jakarta.persistence.Embeddable;
import lombok.*;

import java.io.Serializable;
import java.util.Objects;

/** Composite key for {@link MovementEquipmentOption} - (movement_id, equipment_id). */
@Embeddable
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class MovementEquipmentId implements Serializable {

    private Long movementId;
    private Long equipmentId;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof MovementEquipmentId that)) return false;
        return Objects.equals(movementId, that.movementId) && Objects.equals(equipmentId, that.equipmentId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(movementId, equipmentId);
    }
}
