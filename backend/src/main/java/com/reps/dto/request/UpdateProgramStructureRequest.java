package com.reps.dto.request;

import lombok.Data;

import java.util.List;

/**
 * Payload for editing an existing program's structure in place
 * (swap/add/remove exercises, adjust sets/reps/method) without
 * recreating templates that completed sessions may reference.
 */
@Data
public class UpdateProgramStructureRequest {
    private String name;
    private List<Day> days;

    @Data
    public static class Day {
        private Long templateId;
        private String name;
        private List<Ex> exercises;
    }

    @Data
    public static class Ex {
        private Long exerciseId;
        private Integer sets;
        private Integer reps;
        private String trainingMethod;
    }
}
