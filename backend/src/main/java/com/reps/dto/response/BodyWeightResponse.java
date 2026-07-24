package com.reps.dto.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data @Builder
public class BodyWeightResponse {
    private Long id;
    private BigDecimal weightKg;
    private LocalDate logDate;
}
