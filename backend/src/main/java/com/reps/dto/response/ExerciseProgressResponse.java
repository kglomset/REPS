package com.reps.dto.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data @Builder
public class ExerciseProgressResponse {
    private Long exerciseId;
    private String exerciseName;
    private List<ProgressPoint> series;

    @Data @Builder
    public static class ProgressPoint {
        /** ISO-8601 date string, e.g. "2026-05-19T07:45:00Z" */
        private String date;
        private Integer setNumber;
        private BigDecimal weightKg;
        private Integer reps;
        /** Estimated 1RM using Epley formula: w * (1 + r/30) */
        private BigDecimal estimated1RM;
    }
}
