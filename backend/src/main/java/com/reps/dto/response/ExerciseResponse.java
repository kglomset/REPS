package com.reps.dto.response;

import com.reps.enums.MovementPattern;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data @Builder
public class ExerciseResponse {
    private Long id;
    /** Cached display name, e.g. "Barbell Squat". */
    private String name;
    private String description;
    private String cues;
    private String imageUrl;
    private List<ExerciseMuscleResponse> muscles;
    /** COMPOUND or ISOLATION — drives rep ranges and myo-rep eligibility. */
    private MovementPattern movementPattern;

    // ── Movement/equipment split ──
    private Long movementId;
    private String movementName;
    private Long equipmentId;
    private String equipmentName;
    /** Free-text detail — "Seated", "Cuffed", "45 Degree". Null if none. */
    private String variation;
}
