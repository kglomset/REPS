package com.reps.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class StartSessionRequest {
    @NotNull private Long templateId;

    /** Optional: backdate the session to this date for retrospective logging. */
    private LocalDate date;
}
