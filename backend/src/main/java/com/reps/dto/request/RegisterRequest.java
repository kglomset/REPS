package com.reps.dto.request;

import com.reps.enums.FitnessLevel;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank @Email private String email;
    @NotBlank @Size(min = 8) private String password;
    @NotBlank private String name;
    @NotNull private FitnessLevel fitnessLevel;
}
