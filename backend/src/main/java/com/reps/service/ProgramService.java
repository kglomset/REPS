package com.reps.service;

import com.reps.dto.request.CreateProgramRequest;
import com.reps.dto.request.UpdateProgramStructureRequest;
import com.reps.dto.response.*;
import com.reps.entity.*;
import com.reps.enums.FitnessLevel;
import com.reps.enums.TrainingGoal;
import com.reps.enums.TrainingMethod;
import com.reps.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
public class ProgramService {

    private final TrainingProgramRepository programRepo;
    private final WorkoutTemplateRepository templateRepo;
    private final WorkoutSessionRepository sessionRepo;
    private final UserRepository userRepo;
    private final ExerciseRepository exerciseRepo;
    private final MuscleGroupRepository muscleGroupRepo;

    // ── Volume guidelines (sets per muscle group per week) ──────────────────
    private static final Map<FitnessLevel, int[]> VOLUME_RANGE = Map.of(
            FitnessLevel.BEGINNER,     new int[]{6,  10},
            FitnessLevel.INTERMEDIATE, new int[]{10, 14},
            FitnessLevel.ADVANCED,     new int[]{14, 20}
    );

    @Transactional
    public ProgramResponse createProgram(Long userId, CreateProgramRequest req) {
        User user = userRepo.findById(userId)
                .orElseThrow(() -> new NoSuchElementException("User not found"));

        // Deactivate existing active program
        programRepo.findByUserIdAndActiveTrue(userId)
                .ifPresent(p -> { p.setActive(false); programRepo.save(p); });

        TrainingProgram program = TrainingProgram.builder()
                .user(user)
                .name(req.getName())
                .fitnessLevel(req.getFitnessLevel())
                .goal(req.getGoal())
                .strengthDaysPerWeek(req.getStrengthDaysPerWeek())
                .cardioDaysPerWeek(req.getCardioDaysPerWeek())
                .cardioType(req.getCardioType())
                .active(true)
                .build();

        if (req.getDays() != null && !req.getDays().isEmpty()) {
            buildCustomTemplates(program, req);
        } else {
            generateWorkoutTemplates(program, req);
        }
        return toResponse(programRepo.save(program));
    }

    /**
     * Builds templates directly from a user-supplied structure (Build from
     * Scratch), preserving each exercise's sets/reps/method and superset group.
     */
    private void buildCustomTemplates(TrainingProgram program, CreateProgramRequest req) {
        int defaultRest = program.getGoal() == TrainingGoal.STRENGTH ? 240 : 120;
        List<WorkoutTemplate> templates = new ArrayList<>();
        int fallbackDay = 0;

        for (CreateProgramRequest.Day day : req.getDays()) {
            WorkoutTemplate template = WorkoutTemplate.builder()
                    .program(program)
                    .name(day.getName() != null && !day.getName().isBlank()
                            ? day.getName().trim() : "Day " + (fallbackDay + 1))
                    .dayIndex(day.getDayIndex() != null ? day.getDayIndex() : fallbackDay)
                    .build();
            fallbackDay++;

            List<CreateProgramRequest.Ex> exs =
                    day.getExercises() != null ? day.getExercises() : List.of();
            int order = 0;
            for (CreateProgramRequest.Ex ex : exs) {
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
                        .restSeconds(defaultRest)
                        .trainingMethod(ex.getTrainingMethod() != null
                                ? TrainingMethod.valueOf(ex.getTrainingMethod())
                                : TrainingMethod.STRAIGHT_SETS)
                        .supersetGroupId(ex.getSupersetGroupId() != null
                                && !ex.getSupersetGroupId().isBlank()
                                ? ex.getSupersetGroupId() : null)
                        .build());
            }
            templates.add(template);
        }
        program.setWorkoutTemplates(templates);
    }

    public List<ProgramResponse> getUserPrograms(Long userId) {
        return programRepo.findByUserId(userId).stream()
                .map(this::toResponseSummary)
                .toList();
    }

    public ProgramResponse getProgram(Long userId, Long programId) {
        return toResponse(loadProgramWithDetails(userId, programId));
    }

    public Optional<ProgramResponse> getActiveProgram(Long userId) {
        return programRepo.findByUserIdAndActiveTrue(userId).map(this::toResponse);
    }

    @Transactional
    public void deactivateProgram(Long userId, Long programId) {
        TrainingProgram target = loadProgramWithDetails(userId, programId);
        target.setActive(false);
        programRepo.save(target);
    }

    @Transactional
    public void updateProgram(Long userId, Long programId, String name) {
        TrainingProgram target = loadProgramWithDetails(userId, programId);
        if (name != null && !name.isBlank()) target.setName(name.trim());
        programRepo.save(target);
    }

    /**
     * Edit an existing program's structure in place. Templates are matched by
     * id and have their exercise lists rebuilt; days without a templateId are
     * created, and days omitted from the payload are removed (their completed
     * sessions are detached first so history stays intact).
     */
    @Transactional
    public ProgramResponse updateProgramStructure(Long userId, Long programId,
                                                  UpdateProgramStructureRequest req) {
        TrainingProgram program = loadProgramWithDetails(userId, programId);

        if (req.getName() != null && !req.getName().isBlank()) {
            program.setName(req.getName().trim());
        }

        int defaultRest = program.getGoal() == TrainingGoal.STRENGTH ? 240 : 120;

        if (req.getDays() != null) {
            Set<Long> keptTemplateIds = new HashSet<>();
            for (UpdateProgramStructureRequest.Day day : req.getDays()) {
                WorkoutTemplate template;
                if (day.getTemplateId() != null) {
                    template = program.getWorkoutTemplates().stream()
                            .filter(t -> t.getId().equals(day.getTemplateId()))
                            .findFirst().orElse(null);
                    if (template == null) continue;
                    keptTemplateIds.add(day.getTemplateId());
                } else {
                    // New training day toggled on in the editor
                    template = WorkoutTemplate.builder()
                            .program(program)
                            .name(day.getName() != null && !day.getName().isBlank()
                                    ? day.getName().trim() : "Workout")
                            .dayIndex(day.getDayIndex())
                            .build();
                    program.getWorkoutTemplates().add(template);
                }

                if (day.getName() != null && !day.getName().isBlank()) {
                    template.setName(day.getName().trim());
                }
                if (day.getDayIndex() != null) {
                    template.setDayIndex(day.getDayIndex());
                }

                template.getExercises().clear();
                List<UpdateProgramStructureRequest.Ex> exs =
                        day.getExercises() != null ? day.getExercises() : List.of();
                int order = 0;
                for (UpdateProgramStructureRequest.Ex ex : exs) {
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
                            .restSeconds(defaultRest)
                            .trainingMethod(ex.getTrainingMethod() != null
                                    ? TrainingMethod.valueOf(ex.getTrainingMethod())
                                    : TrainingMethod.STRAIGHT_SETS)
                            .supersetGroupId(ex.getSupersetGroupId() != null
                                    && !ex.getSupersetGroupId().isBlank()
                                    ? ex.getSupersetGroupId() : null)
                            .build());
                }
            }

            // Training days toggled off in the editor: detach their completed
            // sessions (history is kept, template link set to null) and remove
            // the template (orphanRemoval deletes it).
            List<WorkoutTemplate> removed = program.getWorkoutTemplates().stream()
                    .filter(t -> t.getId() != null && !keptTemplateIds.contains(t.getId()))
                    .toList();
            for (WorkoutTemplate t : removed) {
                for (WorkoutSession s : sessionRepo.findByTemplateId(t.getId())) {
                    s.setTemplate(null);
                    sessionRepo.save(s);
                }
                program.getWorkoutTemplates().remove(t);
            }
        }

        return toResponse(programRepo.save(program));
    }

    @Transactional
    public ProgramResponse activateProgram(Long userId, Long programId) {
        TrainingProgram target = loadProgramWithDetails(userId, programId);

        // Already active — nothing to do (idempotent toggle)
        if (Boolean.TRUE.equals(target.getActive())) {
            return toResponse(target);
        }

        // Single-active-program rule: deactivate every other program first and
        // flush, so the deactivations hit the DB before the activation does.
        programRepo.findByUserId(userId).forEach(p -> {
            if (!p.getId().equals(programId) && Boolean.TRUE.equals(p.getActive())) {
                p.setActive(false);
                programRepo.save(p);
            }
        });
        programRepo.flush();

        target.setActive(true);
        return toResponse(programRepo.save(target));
    }

    // ── Program generation ───────────────────────────────────────────────────

    /**
     * Generates workout templates based on fitness level, goal, and training days.
     * Uses a Push/Pull/Legs or Upper/Lower split depending on days per week.
     */
    private void generateWorkoutTemplates(TrainingProgram program, CreateProgramRequest req) {
        int days = req.getStrengthDaysPerWeek();
        List<WorkoutTemplate> templates = new ArrayList<>();

        List<String> dayNames = switch (days) {
            case 2 -> List.of("Full Body A", "Full Body B");
            case 3 -> List.of("Push", "Pull", "Legs");
            case 4 -> List.of("Upper A", "Lower A", "Upper B", "Lower B");
            case 5 -> List.of("Push", "Pull", "Legs", "Upper", "Lower");
            case 6 -> List.of("Push A", "Pull A", "Legs A", "Push B", "Pull B", "Legs B");
            default -> List.of("Full Body A", "Full Body B");
        };

        int[] targetReps = repRange(req.getGoal());
        // Hypertrophy default rest is 2 minutes (120s); strength uses longer rests.
        int targetRestSeconds = req.getGoal() == TrainingGoal.STRENGTH ? 240 : 120;
        int setsPerExercise = req.getGoal() == TrainingGoal.STRENGTH ? 4 : 3;

        // Distribute training days across the week (Mon=0, skip weekends for >4 days)
        int[] dayIndices = spreadDays(days);

        for (int i = 0; i < dayNames.size(); i++) {
            WorkoutTemplate template = WorkoutTemplate.builder()
                    .program(program)
                    .name(dayNames.get(i))
                    .dayIndex(dayIndices[i])
                    .build();

            // Attach placeholder exercises based on split day type
            List<Long> exerciseIds = selectExercisesForDay(dayNames.get(i), req.getFitnessLevel());
            int order = 0;
            for (Long exerciseId : exerciseIds) {
                exerciseRepo.findById(exerciseId).ifPresent(ex -> {
                    template.getExercises().add(WorkoutTemplateExercise.builder()
                            .template(template)
                            .exercise(ex)
                            .exerciseOrder(template.getExercises().size())
                            .sets(setsPerExercise)
                            .repsMin(targetReps[0])
                            .repsMax(targetReps[1])
                            .restSeconds(targetRestSeconds)
                            .trainingMethod(TrainingMethod.STRAIGHT_SETS)
                            .build());
                });
            }
            templates.add(template);
        }
        program.setWorkoutTemplates(templates);
    }

    private int[] repRange(TrainingGoal goal) {
        return goal == TrainingGoal.STRENGTH ? new int[]{3, 6} : new int[]{8, 12};
    }

    private int[] spreadDays(int count) {
        // Spread evenly across Mon-Sun with built-in rest
        return switch (count) {
            case 2 -> new int[]{0, 3};
            case 3 -> new int[]{0, 2, 4};
            case 4 -> new int[]{0, 1, 3, 4};
            case 5 -> new int[]{0, 1, 2, 4, 5};
            case 6 -> new int[]{0, 1, 2, 3, 4, 5};
            default -> new int[]{0, 3};
        };
    }

    /**
     * Returns exercise IDs seeded in V3 migration, selected for the day type.
     * Falls back to first N available if seeds not yet loaded.
     */
    private List<Long> selectExercisesForDay(String dayName, FitnessLevel level) {
        String lower = dayName.toLowerCase();
        if (lower.contains("full body")) {
            return exerciseRepo.findByCreatedByIsNull().stream()
                    .limit(level == FitnessLevel.BEGINNER ? 4 : 6)
                    .map(Exercise::getId)
                    .toList();
        } else if (lower.contains("push")) {
            // "shoulders" slug doesn't exist; use the actual delt slugs
            return exercisesByMuscles(
                    List.of("chest", "front-delts", "side-delts", "triceps"),
                    level == FitnessLevel.BEGINNER ? 3 : 5);
        } else if (lower.contains("pull")) {
            // "back" slug doesn't exist; use actual back-muscle slugs
            return exercisesByMuscles(
                    List.of("lats", "upper-back", "traps", "biceps", "rear-delts"),
                    level == FitnessLevel.BEGINNER ? 3 : 5);
        } else if (lower.contains("legs") || lower.contains("lower")) {
            return exercisesByMuscles(
                    List.of("quads", "hamstrings", "glutes", "calves"),
                    level == FitnessLevel.BEGINNER ? 3 : 5);
        } else if (lower.contains("upper")) {
            return exercisesByMuscles(
                    List.of("chest", "lats", "upper-back", "traps",
                            "front-delts", "side-delts"),
                    level == FitnessLevel.BEGINNER ? 3 : 5);
        }
        return exerciseRepo.findByCreatedByIsNull().stream().limit(4).map(Exercise::getId).toList();
    }

    private List<Long> exercisesByMuscles(List<String> slugs, int limit) {
        return exerciseRepo.findByCreatedByIsNull().stream()
                .filter(e -> e.getMuscles().stream()
                        .anyMatch(m -> slugs.contains(m.getMuscleGroup().getSlug())))
                .limit(limit)
                .map(Exercise::getId)
                .toList();
    }

    /**
     * Two-query load: program + templates, then template exercises. Both Lists
     * are Hibernate "bags", so they cannot be fetch-joined in a single query
     * (MultipleBagFetchException — used to surface as a 409 on toggling).
     * The second query initialises the collections of the already-managed
     * template instances in the same persistence context.
     */
    private TrainingProgram loadProgramWithDetails(Long userId, Long programId) {
        TrainingProgram program = programRepo.findByIdAndUserIdWithDetails(programId, userId)
                .orElseThrow(() -> new NoSuchElementException("Program not found"));
        templateRepo.findByProgramIdWithExercises(programId);
        return program;
    }

    // ── Mappers ──────────────────────────────────────────────────────────────

    ProgramResponse toResponse(TrainingProgram p) {
        return ProgramResponse.builder()
                .id(p.getId())
                .name(p.getName())
                .fitnessLevel(p.getFitnessLevel())
                .goal(p.getGoal())
                .strengthDaysPerWeek(p.getStrengthDaysPerWeek())
                .cardioDaysPerWeek(p.getCardioDaysPerWeek())
                .cardioType(p.getCardioType())
                .active(p.getActive())
                .createdAt(p.getCreatedAt())
                .workoutTemplates(p.getWorkoutTemplates().stream()
                        .map(this::templateToResponse)
                        .toList())
                .build();
    }

    ProgramResponse toResponseSummary(TrainingProgram p) {
        return ProgramResponse.builder()
                .id(p.getId()).name(p.getName())
                .fitnessLevel(p.getFitnessLevel()).goal(p.getGoal())
                .strengthDaysPerWeek(p.getStrengthDaysPerWeek())
                .cardioDaysPerWeek(p.getCardioDaysPerWeek())
                .cardioType(p.getCardioType())
                .active(p.getActive()).createdAt(p.getCreatedAt())
                .workoutTemplates(List.of())
                .build();
    }

    WorkoutTemplateResponse templateToResponse(WorkoutTemplate t) {
        return WorkoutTemplateResponse.builder()
                .id(t.getId()).name(t.getName()).dayIndex(t.getDayIndex())
                .exercises(t.getExercises().stream().map(this::templateExToResponse).toList())
                .build();
    }

    WorkoutTemplateExerciseResponse templateExToResponse(WorkoutTemplateExercise te) {
        return WorkoutTemplateExerciseResponse.builder()
                .id(te.getId())
                .exercise(exerciseToResponse(te.getExercise()))
                .exerciseOrder(te.getExerciseOrder())
                .sets(te.getSets())
                .repsMin(te.getRepsMin())
                .repsMax(te.getRepsMax())
                .restSeconds(te.getRestSeconds())
                .trainingMethod(te.getTrainingMethod())
                .supersetGroupId(te.getSupersetGroupId())
                .build();
    }

    ExerciseResponse exerciseToResponse(Exercise e) {
        return ExerciseResponse.builder()
                .id(e.getId()).name(e.getName())
                .description(e.getDescription()).cues(e.getCues())
                .imageUrl(e.getImageUrl())
                .muscles(e.getMuscles().stream()
                        .map(m -> ExerciseMuscleResponse.builder()
                                .muscleGroupId(m.getMuscleGroup().getId())
                                .muscleGroupName(m.getMuscleGroup().getName())
                                .role(m.getRole()).build())
                        .toList())
                .build();
    }
}
