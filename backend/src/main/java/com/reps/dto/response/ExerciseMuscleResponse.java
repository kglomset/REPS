package com.reps.dto.response;

import com.reps.enums.MuscleRole;
import lombok.Builder;
import lombok.Data;

@Data @Builder
public class ExerciseMuscleResponse {
    private Long muscleGroupId;
    private String muscleGroupName;
    private MuscleRole role;
}
