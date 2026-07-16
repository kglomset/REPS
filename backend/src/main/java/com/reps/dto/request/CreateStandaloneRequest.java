package com.reps.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.List;

/**
 * Payload for creating a standalone workout session — a workout that is not
 * part of a program and is not scheduled on any day. Only exercises and their
 * set/rep targets are needed; there is no training volume or day scheduling.
 */
@Data
public class CreateStandaloneRequest {
    @NotBlank private String name;
    private List<Ex> exercises;

    @Data
    public static class Ex {
        private Long exerciseId;
        private Integer sets;
        private Integer reps;
        private String trainingMethod;
        private String supersetGroupId;
    }
}
