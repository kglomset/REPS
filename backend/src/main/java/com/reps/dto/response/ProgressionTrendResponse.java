package com.reps.dto.response;

import com.reps.enums.TrendDirection;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

/**
 * How this exercise went compared with the session before it. Surfaced as an
 * arrow on the exercise tile; the fields below back the detail sheet.
 */
@Data
@Builder
public class ProgressionTrendResponse {

    private TrendDirection direction;

    /** Short sheet title: "Progressing" / "Maintaining" / "Regressing". */
    private String headline;

    /**
     * One or two plain sentences, e.g. "You increased reps on set 1 by 2, and
     * set 2 by 1 at 60 kg. Keep this up."
     */
    private String message;

    /** Working-weight change vs the previous session (may be negative or zero). */
    private BigDecimal weightDeltaKg;

    /** Net rep change across the sets logged in both sessions. */
    private Integer totalRepsDelta;

    /** Start times of the two compared sessions. */
    private Instant previousDate;
    private Instant latestDate;

    /** Per-set breakdown, restricted to set numbers present in both sessions. */
    private List<SetDelta> sets;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SetDelta {
        private int setNumber;
        private int previousReps;
        private int reps;
        private int repsDelta;
    }
}
