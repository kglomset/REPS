package com.reps.controller;

import com.reps.dto.request.LogSetRequest;
import com.reps.dto.request.StartSessionRequest;
import com.reps.dto.response.ExerciseSetResponse;
import com.reps.dto.response.WorkoutSessionResponse;
import com.reps.security.UserPrincipal;
import com.reps.service.WorkoutService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/workouts")
@RequiredArgsConstructor
public class WorkoutController {

    private final WorkoutService workoutService;

    @PostMapping("/sessions")
    @ResponseStatus(HttpStatus.CREATED)
    public WorkoutSessionResponse start(@AuthenticationPrincipal UserPrincipal principal,
                                        @Valid @RequestBody StartSessionRequest req) {
        return workoutService.startSession(principal.getId(), req);
    }

    @GetMapping("/sessions")
    public List<WorkoutSessionResponse> list(@AuthenticationPrincipal UserPrincipal principal) {
        return workoutService.getUserSessions(principal.getId());
    }

    @GetMapping("/sessions/{id}")
    public WorkoutSessionResponse get(@AuthenticationPrincipal UserPrincipal principal,
                                      @PathVariable Long id) {
        return workoutService.getSession(principal.getId(), id);
    }

    @PostMapping("/sessions/{sessionId}/complete")
    public WorkoutSessionResponse complete(@AuthenticationPrincipal UserPrincipal principal,
                                           @PathVariable Long sessionId,
                                           @RequestBody(required = false) Map<String, String> body) {
        String notes = body != null ? body.get("notes") : null;
        return workoutService.completeSession(principal.getId(), sessionId, notes);
    }

    @DeleteMapping("/sessions/{sessionId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void cancel(@AuthenticationPrincipal UserPrincipal principal,
                       @PathVariable Long sessionId) {
        workoutService.cancelSession(principal.getId(), sessionId);
    }

    @PostMapping("/sessions/{sessionId}/exercises/{exerciseId}/sets")
    @ResponseStatus(HttpStatus.CREATED)
    public ExerciseSetResponse logSet(@AuthenticationPrincipal UserPrincipal principal,
                                      @PathVariable Long sessionId,
                                      @PathVariable Long exerciseId,
                                      @Valid @RequestBody LogSetRequest req) {
        return workoutService.logSet(principal.getId(), sessionId, exerciseId, req);
    }

    /** Persist structural workout changes (sets, rest, superset, method) back to the template. */
    @PatchMapping("/templates/exercises/{templateExerciseId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void updateTemplateExercise(@AuthenticationPrincipal UserPrincipal principal,
                                       @PathVariable Long templateExerciseId,
                                       @RequestBody Map<String, Object> body) {
        workoutService.updateTemplateExercise(
                principal.getId(),
                templateExerciseId,
                body.get("sets") != null ? ((Number) body.get("sets")).intValue() : null,
                body.get("restSeconds") != null ? ((Number) body.get("restSeconds")).intValue() : null,
                body.get("trainingMethod") != null ? (String) body.get("trainingMethod") : null,
                body.get("supersetGroupId") != null ? (String) body.get("supersetGroupId") : null
        );
    }
}
