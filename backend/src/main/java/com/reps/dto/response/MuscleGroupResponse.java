package com.reps.dto.response;

import lombok.Builder;
import lombok.Data;

@Data @Builder
public class MuscleGroupResponse {
    private Long id;
    private String name;
    private String slug;
}
