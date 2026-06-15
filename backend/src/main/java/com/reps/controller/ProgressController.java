package com.reps.controller;

import com.reps.dto.request.BodyWeightRequest;
import com.reps.dto.response.BodyWeightResponse;
import com.reps.dto.response.ExerciseProgressResponse;
import com.reps.security.UserPrincipal;
import com.reps.service.ProgressService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/progress")
@RequiredArgsConstructor
public class ProgressController {

    private final ProgressService progressService;

    @GetMapping("/exercises/{exerciseId}")
    public ExerciseProgressResponse exerciseProgress(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long exerciseId) {
        return progressService.getExerciseProgress(principal.getId(), exerciseId);
    }

    @GetMapping("/body-weight")
    public List<BodyWeightResponse> bodyWeightHistory(
            @AuthenticationPrincipal UserPrincipal principal) {
        return progressService.getBodyWeightHistory(principal.getId());
    }

    @PostMapping("/body-weight")
    @ResponseStatus(HttpStatus.CREATED)
    public BodyWeightResponse logBodyWeight(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody BodyWeightRequest req) {
        return progressService.logBodyWeight(principal.getId(), req);
    }
}
