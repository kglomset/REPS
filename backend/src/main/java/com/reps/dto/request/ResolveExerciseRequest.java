package com.reps.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * Step two/three of the exercise picker, submitted once the user has chosen a
 * movement and (optionally) equipment, a curated variation chip, and whether
 * it's performed unilaterally. The backend finds the matching {@code
 * exercises} row or creates it on the fly - the full (movement x equipment x
 * variation) space is never pre-seeded.
 */
@Data
public class ResolveExerciseRequest {

    @NotNull
    private Long movementId;

    /** Null for the handful of movements with no equipment (e.g. Ab Wheel Roll Out). */
    private Long equipmentId;

    /**
     * One of the movement's curated variation chips - "Seated", "Cuffed",
     * "45 Degree". Not validated against that list server-side (equipment
     * and variation are both suggestions, not constraints), but the picker
     * no longer offers free text. Blank/null is treated as none.
     */
    private String variation;

    /**
     * Whether the "Unilateral" toggle was on - only offered by the picker
     * when the chosen movement+equipment's {@code canBeUnilateral} is true.
     * Folded into the resolved variation text/display name as "Unilateral"
     * or "Unilateral, &lt;variation&gt;", the same convention already used
     * for historical exercises like "Dumbbell Row (Unilateral)" - this is
     * what makes the toggle part of exercise identity rather than just
     * metadata: "Dumbbell Row" and "Dumbbell Row (Unilateral)" resolve to two
     * different exercise rows with separate logged history.
     */
    private Boolean unilateral;
}
