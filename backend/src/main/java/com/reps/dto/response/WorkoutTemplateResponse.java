package com.reps.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data @Builder
public class WorkoutTemplateResponse {
    private Long id;
    private String name;
    private Integer dayIndex;
    private List<WorkoutTemplateExerciseResponse> exercises;
}
