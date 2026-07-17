package com.reps.dto.response;

import com.reps.enums.SuggestionType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

/**
 * A progression suggestion for one exercise, computed from completed-session
 * history. Advisory only — nothing changes until the user applies it.
 */
@Data
@Builder
public class ProgressionSuggestionResponse {

    private SuggestionType type;

    /** Human-readable reason, e.g. "Hit 3×10 at 60 kg last session". */
    private String message;

    /**
     * Target weight for INCREASE_WEIGHT / DELOAD. Null for bodyweight
     * exercises (suggestion is informational-only) and for SWAP_EXERCISE.
     */
    private BigDecimal suggestedWeightKg;

    /** Swap candidates for SWAP_EXERCISE (same primary muscle group). */
    private List<ExerciseSummary> alternatives;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ExerciseSummary {
        private Long id;
        private String name;
    }
}
