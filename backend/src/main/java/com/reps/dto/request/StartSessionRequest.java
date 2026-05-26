package com.reps.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class StartSessionRequest {
    @NotNull private Long templateId;
}
