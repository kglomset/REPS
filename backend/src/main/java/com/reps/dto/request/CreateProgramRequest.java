package com.reps.dto.request;

import com.reps.enums.CardioType;
import com.reps.enums.FitnessLevel;
import com.reps.enums.TrainingGoal;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class CreateProgramRequest {
    @NotBlank private String name;
    @NotNull private FitnessLevel fitnessLevel;
    @NotNull private TrainingGoal goal;
    @NotNull @Min(2) @Max(6) private Integer strengthDaysPerWeek;
    @NotNull @Min(0) @Max(5) private Integer cardioDaysPerWeek;
    private CardioType cardioType;
}
