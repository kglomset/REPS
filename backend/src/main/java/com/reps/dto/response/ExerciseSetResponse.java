package com.reps.dto.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;

@Data @Builder
public class ExerciseSetResponse {
    private Long id;
    private Integer setNumber;
    private BigDecimal weightKg;
    private Integer reps;
    private Integer rpe;
    private Integer restSeconds;
    private Instant completedAt;
}
