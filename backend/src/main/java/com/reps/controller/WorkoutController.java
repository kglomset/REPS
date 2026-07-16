package com.reps.controller;

import com.reps.dto.request.CreateStandaloneRequest;
import com.reps.dto.request.LogSetRequest;
import com.reps.dto.request.StartSessionRequest;
import com.reps.dto.response.ExerciseSetResponse;
import com.reps.dto.response.WorkoutSessionResponse;
import com.reps.dto.response.WorkoutTemplateResponse;
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

    // ── Standalone workouts (not part of a program / calendar) ────────────────

    @PostMapping("/standalone")
    @ResponseStatus(HttpStatus.CREATED)
    public WorkoutTemplateResponse createStandalone(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody CreateStandaloneRequest req) {
        return workoutService.createStandalone(principal.getId(), req);
    }

    @GetMapping("/standalone")
    public List<WorkoutTemplateResponse> listStandalone(
            @AuthenticationPrincipal UserPrincipal principal) {
        return workoutService.getStandaloneTemplates(principal.getId());
    }

    @DeleteMapping("/standalone/{templateId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteStandalone(@AuthenticationPrincipal UserPrincipal principal,
                                 @PathVariable Long templateId) {
        workoutService.deleteStandalone(principal.getId(), templateId);
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

    /** Update a workout template (rename and/or change scheduled day). */
    @PatchMapping("/templates/{templateId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void updateTemplate(@AuthenticationPrincipal UserPrincipal principal,
                               @PathVariable Long templateId,
                               @RequestBody Map<String, Object> body) {
        Integer dayIndex = body.get("dayIndex") != null
                ? ((Number) body.get("dayIndex")).intValue() : null;
        String name = body.get("name") != null ? (String) body.get("name") : null;
        workoutService.updateTemplate(principal.getId(), templateId, dayIndex, name);
    }

    /** Reorder exercises within a workout template. Body: { "exerciseIds": [1,2,3] } */
    @PatchMapping("/templates/{templateId}/reorder")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void reorderTemplateExercises(@AuthenticationPrincipal UserPrincipal principal,
                                         @PathVariable Long templateId,
                                         @RequestBody Map<String, Object> body) {
        @SuppressWarnings("unchecked")
        List<Long> ids = ((List<Number>) body.get("exerciseIds")).stream()
                .map(Number::longValue).toList();
        workoutService.reorderTemplateExercises(principal.getId(), templateId, ids);
    }

    /** Reorder exercises within an active session. Body: { "exerciseIds": [1,2,3] } */
    @PatchMapping("/sessions/{sessionId}/reorder")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void reorderSessionExercises(@AuthenticationPrincipal UserPrincipal principal,
                                        @PathVariable Long sessionId,
                                        @RequestBody Map<String, Object> body) {
        @SuppressWarnings("unchecked")
        List<Long> ids = ((List<Number>) body.get("exerciseIds")).stream()
                .map(Number::longValue).toList();
        workoutService.reorderSessionExercises(principal.getId(), sessionId, ids);
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
