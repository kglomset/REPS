package com.reps.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.List;

@Data @Builder
public class WorkoutSessionResponse {
    private Long id;
    private Long templateId;
    private String templateName;
    private Instant startedAt;
    private Instant completedAt;
    private String notes;
    private List<SessionExerciseResponse> exercises;
}
