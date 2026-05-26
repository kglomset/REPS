package com.reps.dto.response;

import com.reps.enums.CardioType;
import com.reps.enums.FitnessLevel;
import com.reps.enums.TrainingGoal;
import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.List;

@Data @Builder
public class ProgramResponse {
    private Long id;
    private String name;
    private FitnessLevel fitnessLevel;
    private TrainingGoal goal;
    private Integer strengthDaysPerWeek;
    private Integer cardioDaysPerWeek;
    private CardioType cardioType;
    private Boolean active;
    private Instant createdAt;
    private List<WorkoutTemplateResponse> workoutTemplates;
}
