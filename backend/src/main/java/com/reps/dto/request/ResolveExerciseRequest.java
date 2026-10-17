package com.reps.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * Step two/three of the exercise picker, submitted once the user has chosen a
 * movement and (optionally) equipment and a variation detail. The backend
 * finds the matching {@code exercises} row or creates it on the fly - the
 * full (movement x equipment x variation) space is never pre-seeded, since
 * variation is free text.
 */
@Data
public class ResolveExerciseRequest {

    @NotNull
    private Long movementId;

    /** Null for the handful of movements with no equipment (e.g. Ab Wheel Roll Out). */
    private Long equipmentId;

    /** Free-text detail - "Seated", "Cuffed", "45 Degree". Blank is treated as none. */
    private String variation;
}
