package com.reps.dto.response;

import com.reps.enums.TrainingMethod;
import lombok.Builder;
import lombok.Data;

@Data @Builder
public class WorkoutTemplateExerciseResponse {
    private Long id;
    private ExerciseResponse exercise;
    private Integer exerciseOrder;
    private Integer sets;
    private Integer repsMin;
    private Integer repsMax;
    private Integer restSeconds;
    private TrainingMethod trainingMethod;
    private String supersetGroupId;
}
