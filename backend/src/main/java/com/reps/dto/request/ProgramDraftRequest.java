package com.reps.dto.request;

import com.reps.enums.TrainingGoal;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/** Everything the guided builder collects before it can propose a program. */
@Data
public class ProgramDraftRequest {

    @NotNull
    private TrainingGoal goal;

    /** Weekly set target per muscle group — the volume slider. */
    @NotNull @Min(3) @Max(35)
    private Integer weeklySetsPerMuscle;

    @NotNull @Min(1) @Max(6)
    private Integer daysPerWeek;

    /** Split id from GET /programs/splits; null falls back to the top-ranked one. */
    private String splitId;

    /** Propose myo-reps on accessory work to keep sessions shorter. */
    private boolean recommendMyoreps;
}
