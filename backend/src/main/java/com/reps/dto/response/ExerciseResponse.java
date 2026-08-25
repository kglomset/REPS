package com.reps.dto.response;

import com.reps.enums.MovementPattern;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data @Builder
public class ExerciseResponse {
    private Long id;
    private String name;
    private String description;
    private String cues;
    private String imageUrl;
    private List<ExerciseMuscleResponse> muscles;
    /** COMPOUND or ISOLATION — drives rep ranges and myo-rep eligibility. */
    private MovementPattern movementPattern;
}
