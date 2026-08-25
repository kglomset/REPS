package com.reps.dto.response;

import com.reps.enums.MovementPattern;
import com.reps.enums.TrainingMethod;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * A proposed program that has not been saved. The client renders it, lets the
 * user change anything, and only then POSTs /programs.
 */
@Data
@Builder
public class ProgramDraftResponse {

    private String splitId;
    private String splitName;
    private List<Day> days;

    /** Planned vs asked-for weekly sets, so the UI can be honest about shortfalls. */
    private List<MuscleVolume> weeklyVolume;

    /** Longest session in the week, in minutes — the cost of the volume chosen. */
    private int longestSessionMinutes;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Day {
        private String name;
        /** 0 = Monday … 6 = Sunday. */
        private Integer dayIndex;
        private String dayType;
        private int estimatedMinutes;
        private List<Exercise> exercises;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Exercise {
        private Long exerciseId;
        private String name;
        private MovementPattern movementPattern;
        private int sets;
        private int repsMin;
        private int repsMax;
        private int restSeconds;
        private TrainingMethod trainingMethod;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MuscleVolume {
        private Long muscleGroupId;
        private String name;
        private String slug;
        private int targetSets;
        /** Counting myo-reps as 3 sets, and secondary muscles as half a set. */
        private double plannedSets;
    }
}
