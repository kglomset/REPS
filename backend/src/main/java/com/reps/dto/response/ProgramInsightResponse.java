package com.reps.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;

/**
 * Program-level progression insight for the active program: are enough lifts
 * stalled (or has the block run long enough) that a program change is due?
 */
@Data
@Builder
public class ProgramInsightResponse {

    public enum Status { OK, STALLING, CHANGE_RECOMMENDED, NO_ACTIVE_PROGRAM }

    private Status status;
    private String message;
    private Integer weeksActive;
    private List<ProgressionSuggestionResponse.ExerciseSummary> stalledExercises;
}
