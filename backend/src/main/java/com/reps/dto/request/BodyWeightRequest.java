package com.reps.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class BodyWeightRequest {
    @NotNull @Positive private BigDecimal weightKg;
    @NotNull private LocalDate logDate;
}
