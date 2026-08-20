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

        // Retrospective logging: if a (non-future) date is supplied, anchor the
        // session to noon that day so it lands on the right calendar day.
        Instant startedAt = Instant.now();
        if (req.getDate() != null && !req.getDate().isAfter(java.time.LocalDate.now())) {
            startedAt = req.getDate().atTime(12, 0)
                    .atZone(java.time.ZoneId.systemDefault()).toInstant();
        }

        WorkoutSession session = WorkoutSession.builder()
                .user(user)
                .template(template)
                .startedAt(startedAt)
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

    /**
     * Replace one exercise in an active session with a different one — this
     * session only, the program template is untouched. Any sets already logged
     * for the old movement are discarded (they don't apply to the new one).
     */
    @Transactional
    public WorkoutSessionResponse swapSessionExercise(Long userId, Long sessionId,
                                                      Long sessionExerciseId, Long newExerciseId) {
        WorkoutSession session = sessionRepo.findByIdAndUserIdWithDetails(sessionId, userId)
                .orElseThrow(() -> new NoSuchElementException("Session not found"));
        SessionExercise se = session.getExercises().stream()
                .filter(x -> x.getId().equals(sessionExerciseId))
                .findFirst()
                .orElseThrow(() -> new NoSuchElementException("Exercise not in session"));
        Exercise newExercise = exerciseRepo.findById(newExerciseId)
                .orElseThrow(() -> new NoSuchElementException("Exercise not found"));

        se.setExercise(newExercise);
        se.getSets().clear(); // orphanRemoval deletes the old movement's sets
        return toResponse(sessionRepo.save(session));
    }

    /**
     * Add an exercise to an active session — this session only, the program
     * template is untouched. It lands at the end of the list.
     */
    @Transactional
    public WorkoutSessionResponse addSessionExercise(Long userId, Long sessionId,
                                                     Long exerciseId, String trainingMethod) {
        WorkoutSession session = sessionRepo.findByIdAndUserIdWithDetails(sessionId, userId)
                .orElseThrow(() -> new NoSuchElementException("Session not found"));
        Exercise exercise = exerciseRepo.findById(exerciseId)
                .orElseThrow(() -> new NoSuchElementException("Exercise not found"));

        int nextOrder = session.getExercises().stream()
                .map(SessionExercise::getExerciseOrder)
                .filter(Objects::nonNull)
                .max(Integer::compareTo)
                .map(o -> o + 1)
                .orElse(0);

        TrainingMethod method = TrainingMethod.STRAIGHT_SETS;
        if (trainingMethod != null && !trainingMethod.isBlank()) {
            try {
                method = TrainingMethod.valueOf(trainingMethod);
            } catch (IllegalArgumentException ignored) {
                // unknown method — keep the straight-sets default
            }
        }

        session.getExercises().add(SessionExercise.builder()
                .session(session)
                .exercise(exercise)
                .exerciseOrder(nextOrder)
                .trainingMethod(method)
                .build());
        return toResponse(sessionRepo.save(session));
    }

    /**
     * Remove one exercise (and any sets logged for it) from an active session.
     * This session only — the program template keeps the exercise.
     */
    @Transactional
    public WorkoutSessionResponse removeSessionExercise(Long userId, Long sessionId,
                                                        Long sessionExerciseId) {
        WorkoutSession session = sessionRepo.findByIdAndUserIdWithDetails(sessionId, userId)
                .orElseThrow(() -> new NoSuchElementException("Session not found"));
        boolean removed = session.getExercises()
                .removeIf(x -> x.getId().equals(sessionExerciseId)); // orphanRemoval deletes it
        if (!removed) throw new NoSuchElementException("Exercise not in session");

        // Deliberately leave a gap in exerciseOrder: the remaining slots keep
        // their position, so swapped exercises still resolve the right template
        // programming. @OrderBy sorts fine with gaps.
        return toResponse(sessionRepo.save(session));
    }

    @Transactional
    public WorkoutSessionResponse completeSession(Long userId, Long sessionId, String notes) {
        WorkoutSession session = sessionRepo.findByIdAndUserIdWithDetails(sessionId, userId)
                .orElseThrow(() -> new NoSuchElementException("Session not found"));
        // For a backdated (retrospective) session, "now" would produce a
        // multi-day duration; use a nominal 1h instead so stats stay sane.
        Instant now = Instant.now();
        Instant started = session.getStartedAt();
        boolean sameDay = started != null
                && started.atZone(java.time.ZoneId.systemDefault()).toLocalDate()
                        .equals(now.atZone(java.time.ZoneId.systemDefault()).toLocalDate());
        session.setCompletedAt(sameDay ? now : started.plusSeconds(3600));
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
            var templateExercises = session.getTemplate().getExercises();
            var match = templateExercises.stream()
                    .filter(te -> te.getExercise().getId().equals(se.getExercise().getId()))
                    .findFirst();
            // After an in-session swap the new movement is no longer part of the
            // template, so fall back to the slot at the same position: it still
            // carries this slot's programming (set count / rep range / rest).
            if (match.isEmpty() && se.getExerciseOrder() != null) {
                match = templateExercises.stream()
                        .filter(te -> se.getExerciseOrder().equals(te.getExerciseOrder()))
                        .findFirst();
            }
            if (match.isPresent()) {
                targetSets  = match.get().getSets();
                repsMin     = match.get().getRepsMin();
                repsMax     = match.get().getRepsMax();
                restSeconds = match.get().getRestSeconds();
            }
        }

        // Progression: a "do this next" suggestion only makes sense while the
        // session is active, but the week-to-week trend arrow is computed either
        // way — on a finished session it compares what was just logged with the
        // session before it, which is what the summary screen shows.
        var progression = progressionService.analyse(
                session.getUser().getId(), se.getExercise(), repsMin, repsMax, targetSets,
                session.getCompletedAt() == null);
        ProgressionSuggestionResponse suggestion = progression.suggestion();

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
                .trend(progression.trend())
                .build();
    }

    /**
     * The sets logged for this exercise in the user's most recent *completed*
     * session that included it — used to pre-fill the "Prev" column. Scoped to
     * the exercise (not the template), so it still works after the program is
     * edited/regenerated or when the same lift appears in a different workout.
     */
    private List<ExerciseSetResponse> getPreviousSets(WorkoutSession current, SessionExercise se) {
        List<ExerciseSet> history = setRepo.findHistoryForUserAndExercise(
                current.getUser().getId(), se.getExercise().getId());
        if (history.isEmpty()) return List.of();

        // history is ordered by session start ASC — group by session, keep the
        // most recent one (excluding the current, in-progress session).
        Map<Long, List<ExerciseSet>> bySession = new LinkedHashMap<>();
        for (ExerciseSet s : history) {
            Long sid = s.getSessionExercise().getSession().getId();
            if (sid.equals(current.getId())) continue;
            bySession.computeIfAbsent(sid, k -> new ArrayList<>()).add(s);
        }
        if (bySession.isEmpty()) return List.of();

        List<ExerciseSet> lastSessionSets = null;
        for (List<ExerciseSet> sets : bySession.values()) lastSessionSets = sets; // last = most recent
        return lastSessionSets.stream()
                .sorted(Comparator.comparing(ExerciseSet::getSetNumber))
                .map(this::toSetResponse)
                .toList();
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
