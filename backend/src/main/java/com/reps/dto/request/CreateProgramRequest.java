package com.reps.dto.request;

import com.reps.enums.CardioType;
import com.reps.enums.FitnessLevel;
import com.reps.enums.TrainingGoal;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.util.List;

@Data
public class CreateProgramRequest {
    @NotBlank private String name;
    @NotNull private FitnessLevel fitnessLevel;
    @NotNull private TrainingGoal goal;
    // One full-body day a week is a legitimate program; the old @Min(2) also
    // rejected structures the DIY day picker happily let you build.
    @NotNull @Min(1) @Max(6) private Integer strengthDaysPerWeek;
    @NotNull @Min(0) @Max(5) private Integer cardioDaysPerWeek;
    private CardioType cardioType;

    /** Weekly set target per muscle group the program was built around. */
    @Min(3) @Max(35) private Integer weeklySetsPerMuscle;

    /**
     * Optional custom-built structure. When provided (e.g. from the
     * "Build from Scratch" flow) the program is built from exactly these days
     * and exercises instead of an auto-generated split.
     */
    private List<Day> days;

    @Data
    public static class Day {
        private String name;
        private Integer dayIndex;
        private List<Ex> exercises;
    }

    @Data
    public static class Ex {
        private Long exerciseId;
        private Integer sets;
        /** Legacy single rep target, kept for older clients; unused when a range is sent. */
        private Integer reps;
        /**
         * Per-exercise prescription from the guided builder — compounds get a
         * lower range and longer rest than isolations. Missing values fall back
         * to the goal-wide range.
         */
        private Integer repsMin;
        private Integer repsMax;
        private Integer restSeconds;
        private String trainingMethod;
        private String supersetGroupId;
    }
}
