package com.reps.dto.response;

import com.reps.enums.MovementPattern;
import lombok.Builder;
import lombok.Data;

import java.util.List;

/**
 * Step one of the exercise picker: the movement itself, plus the muscle
 * mapping and the equipment options step two should offer. Equipment is a
 * suggestion, not a constraint - {@code POST /exercises/resolve} accepts any
 * equipment id regardless of whether it's listed here.
 */
@Data @Builder
public class MovementResponse {
    private Long id;
    private String name;
    private String description;
    private String cues;
    private String imageUrl;
    private MovementPattern movementPattern;
    private List<ExerciseMuscleResponse> muscles;
    private List<EquipmentResponse> equipmentOptions;
}
