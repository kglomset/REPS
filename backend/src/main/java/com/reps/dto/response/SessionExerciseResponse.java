package com.reps.dto.response;

import com.reps.enums.TrainingMethod;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data @Builder
public class SessionExerciseResponse {
    private Long id;
    private ExerciseResponse exercise;
    private Integer exerciseOrder;
    private TrainingMethod trainingMethod;
    private String supersetGroupId;
    /** Template targets (used to pre-populate set rows in the UI). */
    private Integer targetSets;
    private Integer repsMin;
    private Integer repsMax;
    private Integer restSeconds;
    private List<ExerciseSetResponse> sets;
    /** Last session's sets for this exercise — shown as guidance. */
    private List<ExerciseSetResponse> previousSets;
    /** Progression suggestion (null = keep doing what you're doing). Only computed for active sessions. */
    private ProgressionSuggestionResponse suggestion;
    /**
     * How this exercise went last session compared with the one before it
     * (arrow up / neutral / down). Null until there are two sessions to
     * compare. Recomputed whenever the session is loaded — starting a workout
     * is what refreshes it.
     */
    private ProgressionTrendResponse trend;
}
