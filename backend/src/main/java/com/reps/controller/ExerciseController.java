package com.reps.controller;

import com.reps.dto.request.ResolveExerciseRequest;
import com.reps.dto.response.ExerciseResponse;
import com.reps.security.UserPrincipal;
import com.reps.service.ExerciseService;
import jakarta.validation.Valid;
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

    /**
     * Step two/three of the exercise picker (after GET /movements for step
     * one): resolves a movement + equipment + optional variation to an
     * exercise id, creating that variant if it doesn't exist yet.
     */
    @PostMapping("/resolve")
    public ExerciseResponse resolve(@Valid @RequestBody ResolveExerciseRequest req) {
        return exerciseService.resolveVariant(req);
    }
}
