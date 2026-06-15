package com.reps.controller;

import com.reps.dto.response.ExerciseResponse;
import com.reps.security.UserPrincipal;
import com.reps.service.ExerciseService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/exercises")
@RequiredArgsConstructor
public class ExerciseController {

    private final ExerciseService exerciseService;

    @GetMapping
    public List<ExerciseResponse> list(@AuthenticationPrincipal UserPrincipal principal) {
        Long userId = principal != null ? principal.getId() : null;
        return exerciseService.getAllExercises(userId);
    }

    @GetMapping("/{id}")
    public ExerciseResponse get(@PathVariable Long id) {
        return exerciseService.getExercise(id);
    }
}
