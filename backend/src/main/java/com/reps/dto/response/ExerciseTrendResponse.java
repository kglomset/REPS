package com.reps.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/** One exercise's week-to-week trend, for the Progress tab's exercise list. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExerciseTrendResponse {
    private Long exerciseId;
    private String exerciseName;
    private ProgressionTrendResponse trend;
}
