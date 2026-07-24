package com.reps.service;

import com.reps.dto.request.CreateStandaloneRequest;
import com.reps.dto.request.LogSetRequest;
import com.reps.dto.request.StartSessionRequest;
import com.reps.dto.response.*;
import com.reps.entity.*;
import com.reps.enums.TrainingMethod;
import com.reps.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;

@Service
@RequiredArgsConstructor
public class WorkoutService {

    private final WorkoutSessionRepository sessionRepo;
    private final TrainingProgramRepository programRepo;
    private final WorkoutTemplateRepository templateRepo;
    private final ExerciseRepository exerciseRepo;
    private final UserRepository userRepo;
    private final ExerciseSetRepository setRepo;
    private final ProgramService programService;
    private final ProgressionService progressionService;

    @Transactional
    public WorkoutSessionResponse startSession(Long userId, StartSessionRequest req) {
        User user = userRepo.getReferenceById(userId);
        WorkoutTemplate template = templateRepo.findByIdWithExercises(req.getTemplateId())
                .orElseThrow(() -> new NoSuchElementException("Template not found"));

        // Ownership: program templates resolve owner via the program;
        // standalone templates own their user directly.
        Long ownerId = template.getProgram() != null
                ? template.getProgram().getUser().getId()
                : (template.getUser() != null ? template.getUser().getId() : null);
        if (ownerId == null || !ownerId.equals(userId)) {
            throw new NoSuchElementException("Template not found");
        }

        WorkoutSession session = WorkoutSession.builder()
                .user(user)
                .template(template)
                .startedAt(Instant.now())
                .build();

        // Mirror exercises from template into session
        for (WorkoutTemplateExercise te : template.getExercises()) {
            session.getExercises().add(SessionExercise.builder()
                    .session(session)
                    .exercise(te.getExercise())
                    .exerciseOrder(te.getExerciseOrder())
                    .trainingMethod(te.getTrainingMethod())
                    .supersetGroupId(te.getSupersetGroupId())
                    .build());
        }
        return toResponse(sessionRepo.save(session));
    }

    // ── Standalone workouts ───────────────────────────────────────────────────

    /**
     * Create a standalone workout template — a session not tied to a program or
     * any calendar day. It is started and logged like any other workout.
     */
    @Transactional
    public WorkoutTemplateResponse createStandalone(Long userId, CreateStandaloneRequest req) {
        User user = userRepo.getReferenceById(userId);
        WorkoutTemplate template = WorkoutTemplate.builder()
                .user(user)
                .standalone(true)
                .name(req.getName() != null && !req.getName().isBlank()
                        ? req.getName().trim() : "Workout")
                .dayIndex(null)
                .build();

        List<CreateStandaloneRequest.Ex> exs =
                req.getExercises() != null ? req.getExercises() : List.of();
        int order = 0;
        for (CreateStandaloneRequest.Ex ex : exs) {
            if (ex.getExerciseId() == null) continue;
            Exercise exercise = exerciseRepo.findById(ex.getExerciseId()).orElse(null);
            if (exercise == null) continue;
            int reps = ex.getReps() != null ? ex.getReps() : 10;
            template.getExercises().add(WorkoutTemplateExercise.builder()
                    .template(template)
                    .exercise(exercise)
                    .exerciseOrder(order++)
                    .sets(ex.getSets() != null ? ex.getSets() : 3)
                    .repsMin(reps)
                    .repsMax(reps)
                    .restSeconds(120)
                    .trainingMethod(ex.getTrainingMethod() != null
                            ? TrainingMethod.valueOf(ex.getTrainingMethod())
                            : TrainingMethod.STRAIGHT_SETS)
                    .supersetGroupId(ex.getSupersetGroupId() != null
                            && !ex.getSupersetGroupId().isBlank()
                            ? ex.getSupersetGroupId() : null)
                    .build());
        }
        return programService.templateToResponse(templateRepo.save(template));
    }

    public List<WorkoutTemplateResponse> getStandaloneTemplates(Long userId) {
        return templateRepo.findStandaloneByUser(userId).stream()
                .map(programService::templateToResponse)
                .toList();
    }

    @Transactional
    public void deleteStandalone(Long userId, Long templateId) {
        WorkoutTemplate template = templateRepo.findByIdWithExercises(templateId)
                .orElseThrow(() -> new NoSuchElementException("Workout not found"));
        if (!Boolean.TRUE.equals(template.getStandalone())
                || template.getUser() == null
                || !template.getUser().getId().equals(userId)) {
            throw new NoSuchElementException("Workout not found");
        }
        // Detach any completed sessions so their history is preserved.
        for (WorkoutSession s : sessionRepo.findByTemplateId(templateId)) {
            s.setTemplate(null);
            sessionRepo.save(s);
        }
        templateRepo.delete(template);
    }

    @Transactional
    public ExerciseSetResponse logSet(Long userId, Long sessionId,
                                      Long sessionExerciseId, LogSetRequest req) {
        WorkoutSession session = sessionRepo.findByIdAndUserIdWithDetails(sessionId, userId)
                .orElseThrow(() -> new NoSuchElementException("Session not found"));

        SessionExercise sessionExercise = session.getExercises().stream()
                .filter(se -> se.getId().equals(sessionExerciseId))
                .findFirst()
                .orElseThrow(() -> new NoSuchElementException("Exercise not in session"));

        // Use caller-supplied set number (upsert) or auto-increment
        int targetSet = req.getSetNumber() != null
                ? req.getSetNumber()
                : sessionExercise.getSets().size() + 1;

        // Upsert: update existing set if one with this number already exists
        ExerciseSet set = sessionExercise.getSets().stream()
                .filter(s -> s.getSetNumber() == targetSet)
                .findFirst()
                .orElse(null);

        if (set != null) {
            set.setWeightKg(req.getWeightKg());
            set.setReps(req.getReps());
            set.setRpe(req.getRpe());
            set.setRestSeconds(req.getRestSeconds());
        } else {
            set = ExerciseSet.builder()
                    .sessionExercise(sessionExercise)
                    .setNumber(targetSet)
                    .weightKg(req.getWeightKg())
                    .reps(req.getReps())
                    .rpe(req.getRpe())
                    .restSeconds(req.getRestSeconds())
                    .build();
            sessionExercise.getSets().add(set);
        }
        sessionRepo.save(session);

        return ExerciseSetResponse.builder()
                .id(set.getId())
                .setNumber(set.getSetNumber())
                .weightKg(set.getWeightKg())
                .reps(set.getReps())
                .rpe(set.getRpe())
                .restSeconds(set.getRestSeconds())
                .completedAt(set.getCompletedAt())
                .build();
    }

    @Transactional
    public WorkoutSessionResponse completeSession(Long userId, Long sessionId, String notes) {
        WorkoutSession session = sessionRepo.findByIdAndUserIdWithDetails(sessionId, userId)
                .orElseThrow(() -> new NoSuchElementException("Session not found"));
        session.setCompletedAt(Instant.now());
        session.setNotes(notes);
        return toResponse(sessionRepo.save(session));
    }

    public WorkoutSessionResponse getSession(Long userId, Long sessionId) {
        return sessionRepo.findByIdAndUserIdWithDetails(sessionId, userId)
                .map(this::toResponse)
                .orElseThrow(() -> new NoSuchElementException("Session not found"));
    }

    @Transactional
    public void cancelSession(Long userId, Long sessionId) {
        WorkoutSession session = sessionRepo.findByIdAndUserIdWithDetails(sessionId, userId)
                .orElseThrow(() -> new NoSuchElementException("Session not found"));
        sessionRepo.delete(session);
    }

    /** Persist structural changes (sets count, rest, superset, training method) back to the template. */
    @Transactional
    public void updateTemplateExercise(Long userId, Long templateExerciseId,
                                       Integer sets, Integer restSeconds,
                                       String trainingMethod, String supersetGroupId) {
        // Find the template exercise and verify ownership via its program
        programRepo.findAll().stream()
                .filter(p -> p.getUser().getId().equals(userId))
                .flatMap(p -> p.getWorkoutTemplates().stream())
                .flatMap(t -> t.getExercises().stream())
                .filter(te -> te.getId().equals(templateExerciseId))
                .findFirst()
                .ifPresent(te -> {
                    if (sets != null)           te.setSets(sets);
                    if (restSeconds != null)    te.setRestSeconds(restSeconds);
                    if (trainingMethod != null) te.setTrainingMethod(
                            com.reps.enums.TrainingMethod.valueOf(trainingMethod));
                    if (supersetGroupId != null) te.setSupersetGroupId(
                            supersetGroupId.isEmpty() ? null : supersetGroupId);
                });
    }

    public List<WorkoutSessionResponse> getUserSessions(Long userId) {
        return sessionRepo.findByUserIdOrderByStartedAtDesc(userId).stream()
                .map(s -> WorkoutSessionResponse.builder()
                        .id(s.getId())
                        .templateId(s.getTemplate() != null ? s.getTemplate().getId() : null)
                        .templateName(s.getTemplate() != null ? s.getTemplate().getName() : null)
                        .startedAt(s.getStartedAt())
                        .completedAt(s.getCompletedAt())
                        .exercises(List.of())
                        .build())
                .toList();
    }

    /** Update a workout template's scheduled day and/or name. */
    @Transactional
    public void updateTemplate(Long userId, Long templateId, Integer dayIndex, String name) {
        programRepo.findAll().stream()
                .filter(p -> p.getUser().getId().equals(userId))
                .flatMap(p -> p.getWorkoutTemplates().stream())
                .filter(t -> t.getId().equals(templateId))
                .findFirst()
                .ifPresent(t -> {
                    if (dayIndex != null) t.setDayIndex(dayIndex);
                    if (name != null && !name.isBlank()) t.setName(name.trim());
                });
    }

    /** Reorder exercises within a template. exerciseIds = new ordered list of WorkoutTemplateExercise IDs. */
    @Transactional
    public void reorderTemplateExercises(Long userId, Long templateId, List<Long> exerciseIds) {
        programRepo.findAll().stream()
                .filter(p -> p.getUser().getId().equals(userId))
                .flatMap(p -> p.getWorkoutTemplates().stream())
                .filter(t -> t.getId().equals(templateId))
                .findFirst()
                .ifPresent(t -> {
                    for (int i = 0; i < exerciseIds.size(); i++) {
                        final int order = i;
                        final Long exId = exerciseIds.get(i);
                        t.getExercises().stream()
                                .filter(te -> te.getId().equals(exId))
                                .findFirst()
                                .ifPresent(te -> te.setExerciseOrder(order));
                    }
                });
    }

    /** Reorder exercises within a live session. exerciseIds = new ordered list of SessionExercise IDs. */
    @Transactional
    public void reorderSessionExercises(Long userId, Long sessionId, List<Long> exerciseIds) {
        WorkoutSession session = sessionRepo.findByIdAndUserIdWithDetails(sessionId, userId)
                .orElseThrow(() -> new NoSuchElementException("Session not found"));
        for (int i = 0; i < exerciseIds.size(); i++) {
            final int order = i;
            final Long exId = exerciseIds.get(i);
            session.getExercises().stream()
                    .filter(se -> se.getId().equals(exId))
                    .findFirst()
                    .ifPresent(se -> se.setExerciseOrder(order));
        }
        sessionRepo.save(session);
    }

    // ── Mappers ──────────────────────────────────────────────────────────────

    private WorkoutSessionResponse toResponse(WorkoutSession s) {
        return WorkoutSessionResponse.builder()
                .id(s.getId())
                .templateId(s.getTemplate() != null ? s.getTemplate().getId() : null)
                .templateName(s.getTemplate() != null ? s.getTemplate().getName() : null)
                .startedAt(s.getStartedAt())
                .completedAt(s.getCompletedAt())
                .notes(s.getNotes())
                .exercises(s.getExercises().stream().map(se -> toSessionExResponse(s, se)).toList())
                .build();
    }

    private SessionExerciseResponse toSessionExResponse(WorkoutSession session, SessionExercise se) {
        List<ExerciseSetResponse> prevSets = getPreviousSets(session, se);

        // Pull template targets so the UI can pre-populate rows
        Integer targetSets = 3;
        Integer repsMin = null, repsMax = null, restSeconds = null;
        if (session.getTemplate() != null) {
            var match = session.getTemplate().getExercises().stream()
                    .filter(te -> te.getExercise().getId().equals(se.getExercise().getId()))
                    .findFirst();
            if (match.isPresent()) {
                targetSets  = match.get().getSets();
                repsMin     = match.get().getRepsMin();
                repsMax     = match.get().getRepsMax();
                restSeconds = match.get().getRestSeconds();
            }
        }

        // Progression suggestion — only meaningful while the session is active
        ProgressionSuggestionResponse suggestion = null;
        if (session.getCompletedAt() == null) {
            suggestion = progressionService.suggestFor(
                    session.getUser().getId(), se.getExercise(), repsMin, repsMax, targetSets);
        }

        return SessionExerciseResponse.builder()
                .id(se.getId())
                .exercise(programService.exerciseToResponse(se.getExercise()))
                .exerciseOrder(se.getExerciseOrder())
                .trainingMethod(se.getTrainingMethod())
                .supersetGroupId(se.getSupersetGroupId())
                .targetSets(targetSets)
                .repsMin(repsMin)
                .repsMax(repsMax)
                .restSeconds(restSeconds)
                .sets(se.getSets().stream().map(this::toSetResponse).toList())
                .previousSets(prevSets)
                .suggestion(suggestion)
                .build();
    }

    private List<ExerciseSetResponse> getPreviousSets(WorkoutSession current, SessionExercise se) {
        if (current.getTemplate() == null) return List.of();
        List<WorkoutSession> previous = sessionRepo.findCompletedByUserAndTemplate(
                current.getUser().getId(), current.getTemplate().getId());

        return previous.stream()
                .filter(s -> !s.getId().equals(current.getId()))
                .findFirst()
                .map(prev -> prev.getExercises().stream()
                        .filter(prevEx -> prevEx.getExercise().getId().equals(se.getExercise().getId()))
                        .findFirst()
                        .map(prevEx -> prevEx.getSets().stream().map(this::toSetResponse).toList())
                        .orElse(List.of()))
                .orElse(List.of());
    }

    private ExerciseSetResponse toSetResponse(ExerciseSet set) {
        return ExerciseSetResponse.builder()
                .id(set.getId())
                .setNumber(set.getSetNumber())
                .weightKg(set.getWeightKg())
                .reps(set.getReps())
                .rpe(set.getRpe())
                .restSeconds(set.getRestSeconds())
                .completedAt(set.getCompletedAt())
                .build();
    }
}
