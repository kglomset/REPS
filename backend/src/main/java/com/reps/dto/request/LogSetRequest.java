package com.reps.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class LogSetRequest {
    private BigDecimal weightKg;
    @NotNull @Min(0) private Integer reps;
    @Min(1) @Max(10) private Integer rpe;
    private Integer restSeconds;
}
