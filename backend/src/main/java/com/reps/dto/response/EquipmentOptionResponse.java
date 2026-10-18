package com.reps.dto.response;

import lombok.Builder;
import lombok.Data;

/**
 * One equipment chip the picker offers for a movement, plus whether that
 * specific (movement, equipment) pair can be logged as unilateral - drives
 * whether the "Unilateral" toggle is shown once this equipment is picked.
 */
@Data @Builder
public class EquipmentOptionResponse {
    private Long id;
    private String name;
    private String slug;
    private boolean canBeUnilateral;
}
