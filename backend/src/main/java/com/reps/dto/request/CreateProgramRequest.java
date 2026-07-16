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
    @NotNull @Min(2) @Max(6) private Integer strengthDaysPerWeek;
    @NotNull @Min(0) @Max(5) private Integer cardioDaysPerWeek;
    private CardioType cardioType;

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
        private Integer reps;
        private String trainingMethod;
        private String supersetGroupId;
    }
}
