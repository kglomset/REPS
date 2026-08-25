package com.reps.service;

import com.reps.dto.request.ProgramDraftRequest;
import com.reps.dto.response.ProgramDraftResponse;
import com.reps.dto.response.SplitOptionResponse;
import com.reps.entity.Exercise;
import com.reps.entity.ExerciseMuscle;
import com.reps.enums.MovementPattern;
import com.reps.enums.MuscleRole;
import com.reps.enums.SplitDayType;
import com.reps.enums.TrainingGoal;
import com.reps.enums.TrainingMethod;
import com.reps.repository.ExerciseRepository;
import com.reps.repository.MuscleGroupRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Set;

/**
 * Builds a proposed program from the four things the guided builder asks for:
 * goal, weekly sets per muscle group, training days per week, and split.
 *
 * Everything here is a proposal — nothing is persisted. The client renders the
 * draft, the user edits it, and only then does it become a create request.
 *
 * Design doc: docs/program-builder-design.md
 */
@Service
@RequiredArgsConstructor
public class ProgramBuilderService {

    // ── Prescription ──────────────────────────────────────────────────────
    // "Stronger" means more sets, fewer reps, longer rests and a heavy compound
    // bias. "Bigger & stronger" spreads reps across the 4–12 band and moves
    // faster between sets.

    static final int STRENGTH_SETS_PER_EXERCISE = 4;
    static final int HYPERTROPHY_SETS_PER_EXERCISE = 3;

    /** A myo-reps entry is one activation set plus five clusters. */
    static final int MYOREPS_SETS = 6;
    /** …and counts as three sets of volume, matching the app's volume guide. */
    static final int MYOREPS_COUNTED_SETS = 3;

    /** A muscle within this many sets of its target is considered served. */
    static final double TOLERANCE = 1.0;
    /** Below this much genuinely useful work, adding another exercise is noise. */
    static final double MIN_USEFUL = 0.5;
    static final double SECONDARY_CREDIT = 0.5;

    static final double WASTE_PENALTY = 1.0;
    static final double UNCOVERED_BONUS = 2.0;
    static final double REPEAT_PENALTY = 1.5;
    static final double SAME_FAMILY_PENALTY = 2.5;
    static final double STRENGTH_COMPOUND_BONUS = 2.0;
    static final double HYPERTROPHY_COMPOUND_BONUS = 1.25;

    static final int MAX_EXERCISES_STRENGTH = 7;
    static final int MAX_EXERCISES_HYPERTROPHY = 9;
    static final int MAX_EXERCISES_PER_MUSCLE = 3;

    /** Session-time model: warm-up, work per set, and the cost of a myo-rep cluster. */
    static final int WARMUP_SECONDS = 360;
    static final int SECONDS_PER_SET = 40;
    static final int MYOREPS_CLUSTER_SECONDS = 5 * 35;

    private final ExerciseRepository exerciseRepo;
    private final MuscleGroupRepository muscleGroupRepo;

    // ── Split catalogue ───────────────────────────────────────────────────

    /** A named sequence of training days. */
    record Split(String id, String name, List<SplitDayType> dayTypes) {
    }

    private static final Map<Integer, List<Split>> SPLITS = Map.of(
            1, List.of(
                    new Split("FB1", "Full body", List.of(SplitDayType.FULL_BODY))),
            2, List.of(
                    new Split("FB2", "Full body ×2",
                            List.of(SplitDayType.FULL_BODY, SplitDayType.FULL_BODY)),
                    new Split("UL2", "Upper / Lower",
                            List.of(SplitDayType.UPPER, SplitDayType.LOWER))),
            3, List.of(
                    new Split("FB3", "Full body ×3", List.of(
                            SplitDayType.FULL_BODY, SplitDayType.FULL_BODY, SplitDayType.FULL_BODY)),
                    new Split("ULF3", "Upper / Lower / Full body", List.of(
                            SplitDayType.UPPER, SplitDayType.LOWER, SplitDayType.FULL_BODY)),
                    new Split("PPL3", "Push / Pull / Legs", List.of(
                            SplitDayType.PUSH, SplitDayType.PULL, SplitDayType.LEGS)),
                    new Split("CBSAL3", "Chest+Back / Shoulders+Arms / Legs", List.of(
                            SplitDayType.CHEST_BACK, SplitDayType.SHOULDERS_ARMS, SplitDayType.LEGS))),
            4, List.of(
                    new Split("FB4", "Full body ×4", List.of(
                            SplitDayType.FULL_BODY, SplitDayType.FULL_BODY,
                            SplitDayType.FULL_BODY, SplitDayType.FULL_BODY)),
                    new Split("PPLF4", "Push / Pull / Legs / Full body", List.of(
                            SplitDayType.PUSH, SplitDayType.PULL, SplitDayType.LEGS,
                            SplitDayType.FULL_BODY)),
                    new Split("UL4", "Upper / Lower ×2", List.of(
                            SplitDayType.UPPER, SplitDayType.LOWER,
                            SplitDayType.UPPER, SplitDayType.LOWER))),
            5, List.of(
                    new Split("PPLUL5", "Push / Pull / Legs / Upper / Lower", List.of(
                            SplitDayType.PUSH, SplitDayType.PULL, SplitDayType.LEGS,
                            SplitDayType.UPPER, SplitDayType.LOWER)),
                    new Split("BRO5", "Chest / Back / Legs / Arms / Shoulders", List.of(
                            SplitDayType.CHEST, SplitDayType.BACK, SplitDayType.LEGS,
                            SplitDayType.ARMS, SplitDayType.SHOULDERS))),
            6, List.of(
                    new Split("ULF6", "Upper / Lower / Full ×2", List.of(
                            SplitDayType.UPPER, SplitDayType.LOWER, SplitDayType.FULL_BODY,
                            SplitDayType.UPPER, SplitDayType.LOWER, SplitDayType.FULL_BODY)),
                    new Split("PPL6", "Push / Pull / Legs ×2", List.of(
                            SplitDayType.PUSH, SplitDayType.PULL, SplitDayType.LEGS,
                            SplitDayType.PUSH, SplitDayType.PULL, SplitDayType.LEGS)),
                    new Split("CBSAL6", "Chest+Back / Shoulders+Arms / Legs ×2", List.of(
                            SplitDayType.CHEST_BACK, SplitDayType.SHOULDERS_ARMS, SplitDayType.LEGS,
                            SplitDayType.CHEST_BACK, SplitDayType.SHOULDERS_ARMS, SplitDayType.LEGS))));

    /** Which weekdays a program of N days lands on (0 = Monday). */
    private static final Map<Integer, List<Integer>> DAY_INDICES = Map.of(
            1, List.of(0),
            2, List.of(0, 3),
            3, List.of(0, 2, 4),
            4, List.of(0, 1, 3, 4),
            5, List.of(0, 1, 2, 4, 5),
            6, List.of(0, 1, 2, 3, 4, 5));

    /**
     * Splits available for a given number of training days, best first.
     *
     * Ranking is derived, not hard-coded: a split whose least-trained muscle is
     * hit twice a week or more sorts ahead of one that trains something only
     * once. The sort is stable, so within each band the catalogue order stands.
     */
    public List<SplitOptionResponse> splitsFor(int daysPerWeek) {
        return splitCatalogue(daysPerWeek).stream()
                .map(s -> SplitOptionResponse.builder()
                        .id(s.id())
                        .name(s.name())
                        .dayNames(s.dayTypes().stream().map(SplitDayType::getLabel).toList())
                        .minWeeklyFrequency(minWeeklyFrequency(s.dayTypes()))
                        .build())
                .toList();
    }

    private List<Split> splitCatalogue(int daysPerWeek) {
        List<Split> options = SPLITS.get(daysPerWeek);
        if (options == null) throw new NoSuchElementException("No splits for " + daysPerWeek + " days");
        return options.stream()
                .sorted(Comparator.comparingInt(s -> minWeeklyFrequency(s.dayTypes()) >= 2 ? 0 : 1))
                .toList();
    }

    /** How often the least-trained muscle group in this split is hit per week. */
    static int minWeeklyFrequency(List<SplitDayType> dayTypes) {
        Map<String, Integer> frequency = weeklyFrequency(dayTypes);
        return frequency.values().stream().mapToInt(Integer::intValue).min().orElse(0);
    }

    /** Per-muscle count of how many days in the split include it. */
    static Map<String, Integer> weeklyFrequency(List<SplitDayType> dayTypes) {
        Map<String, Integer> frequency = new LinkedHashMap<>();
        for (SplitDayType type : dayTypes) {
            for (String slug : type.getMuscleSlugs()) {
                frequency.merge(slug, 1, Integer::sum);
            }
        }
        return frequency;
    }

    // ── Draft generation ──────────────────────────────────────────────────

    /**
     * Propose a program. Each muscle group gets a per-session set target of
     * {@code weeklySets / (times it appears in the split)}; exercises are then
     * picked greedily to fill those targets, crediting every muscle a movement
     * trains — a full set for a primary, half for a secondary — so a bench press
     * pays into chest, front delts and triceps at once.
     */
    @Transactional(readOnly = true)
    public ProgramDraftResponse draft(Long userId, ProgramDraftRequest req) {
        List<Split> catalogue = splitCatalogue(req.getDaysPerWeek());
        Split split = catalogue.stream()
                .filter(s -> s.id().equals(req.getSplitId()))
                .findFirst()
                .orElse(catalogue.get(0)); // no id (or a stale one) → best-ranked

        List<Exercise> library = exerciseRepo.findAllAvailableForUser(userId);
        Map<String, Integer> frequency = weeklyFrequency(split.dayTypes());
        List<Integer> dayIndices = DAY_INDICES.get(req.getDaysPerWeek());

        int setsPerExercise = setsPerExercise(req.getGoal());
        Set<Long> usedInProgram = new HashSet<>();
        Set<String> familiesInProgram = new HashSet<>();
        Map<String, Double> plannedWeekly = new HashMap<>();
        List<ProgramDraftResponse.Day> days = new ArrayList<>();

        for (int i = 0; i < split.dayTypes().size(); i++) {
            SplitDayType type = split.dayTypes().get(i);
            List<ProgramDraftResponse.Exercise> picked = fillDay(
                    type, req, library, frequency, setsPerExercise,
                    usedInProgram, familiesInProgram, plannedWeekly);
            days.add(ProgramDraftResponse.Day.builder()
                    .name(type.getLabel())
                    .dayIndex(dayIndices.get(i))
                    .dayType(type.name())
                    .estimatedMinutes(estimateMinutes(picked))
                    .exercises(picked)
                    .build());
        }

        return ProgramDraftResponse.builder()
                .splitId(split.id())
                .splitName(split.name())
                .days(days)
                .weeklyVolume(volumeReport(plannedWeekly, req.getWeeklySetsPerMuscle()))
                .longestSessionMinutes(days.stream()
                        .mapToInt(ProgramDraftResponse.Day::getEstimatedMinutes).max().orElse(0))
                .build();
    }

    /** Greedily fill one training day until every muscle in it is served or the cap is hit. */
    private List<ProgramDraftResponse.Exercise> fillDay(
            SplitDayType type, ProgramDraftRequest req, List<Exercise> library,
            Map<String, Integer> frequency, int setsPerExercise,
            Set<Long> usedInProgram, Set<String> familiesInProgram,
            Map<String, Double> plannedWeekly) {

        Map<String, Double> deficit = new LinkedHashMap<>();
        Map<String, Double> plannedToday = new LinkedHashMap<>();
        for (String slug : type.getMuscleSlugs()) {
            deficit.put(slug, (double) req.getWeeklySetsPerMuscle() / frequency.getOrDefault(slug, 1));
            plannedToday.put(slug, 0.0);
        }

        double totalDeficit = deficit.values().stream().mapToDouble(Double::doubleValue).sum();
        int cap = Math.max(3, Math.min(maxExercisesPerDay(req.getGoal()),
                (int) Math.ceil(totalDeficit / setsPerExercise)));

        List<ProgramDraftResponse.Exercise> picked = new ArrayList<>();
        Map<String, Integer> exercisesPerMuscle = new HashMap<>();
        Set<Long> usedToday = new HashSet<>();
        Set<String> familiesToday = new HashSet<>();

        while (picked.size() < cap && deficit.values().stream().anyMatch(d -> d > TOLERANCE)) {
            Exercise best = null;
            double bestScore = -Double.MAX_VALUE;
            double bestUseful = 0;

            for (Exercise candidate : library) {
                if (usedToday.contains(candidate.getId())) continue;
                if (!servesAnyDeficit(candidate, deficit)) continue;
                if (atMuscleLimit(candidate, deficit, exercisesPerMuscle)) continue;

                double useful = 0;
                double waste = 0;
                for (ExerciseMuscle muscle : candidate.getMuscles()) {
                    String slug = muscle.getMuscleGroup().getSlug();
                    double credit = creditFor(muscle.getRole(), setsPerExercise);
                    double outstanding = deficit.getOrDefault(slug, 0.0);
                    useful += Math.min(Math.max(outstanding, 0), credit);
                    waste += Math.max(0, credit - Math.max(outstanding, 0));
                }

                double score = useful - WASTE_PENALTY * waste;
                if (candidate.getMovementPattern() == MovementPattern.COMPOUND) {
                    score += compoundBonus(req.getGoal());
                }
                // A muscle with nothing on the card yet outranks topping up one
                // that is already served — otherwise the exercise cap can leave a
                // whole muscle group at zero.
                for (ExerciseMuscle muscle : candidate.getMuscles()) {
                    if (muscle.getRole() != MuscleRole.PRIMARY) continue;
                    Double planned = plannedToday.get(muscle.getMuscleGroup().getSlug());
                    if (planned != null && planned == 0.0) score += UNCOVERED_BONUS;
                }
                // Penalties, not bans: calves has exactly one movement family in
                // the whole library, so a hard block would cap it at three sets a
                // session however much volume was asked for.
                String family = movementFamily(candidate.getName());
                if (familiesToday.contains(family)) score -= SAME_FAMILY_PENALTY;
                if (usedInProgram.contains(candidate.getId())) score -= REPEAT_PENALTY;
                if (familiesInProgram.contains(family)) score -= REPEAT_PENALTY / 2;

                if (score > bestScore) {
                    best = candidate;
                    bestScore = score;
                    bestUseful = useful;
                }
            }

            // Stop once nothing left does real work. The test is on useful sets,
            // not the score: the penalties exist to order candidates and must not
            // end the session while a muscle is still short.
            if (best == null || bestUseful <= MIN_USEFUL) break;

            boolean compound = best.getMovementPattern() == MovementPattern.COMPOUND;
            boolean hasStraightSets = picked.stream()
                    .anyMatch(e -> e.getTrainingMethod() == TrainingMethod.STRAIGHT_SETS);
            // Myo-reps go on accessory work only: never a compound, and never the
            // opener, so every session keeps at least one straight-set exercise.
            boolean myoreps = req.isRecommendMyoreps() && hasStraightSets && !compound;

            int sets = myoreps ? MYOREPS_SETS : setsPerExercise;
            double countedSets = myoreps ? MYOREPS_COUNTED_SETS : sets;

            for (ExerciseMuscle muscle : best.getMuscles()) {
                String slug = muscle.getMuscleGroup().getSlug();
                double credit = creditFor(muscle.getRole(), countedSets);
                deficit.computeIfPresent(slug, (k, v) -> v - credit);
                plannedToday.computeIfPresent(slug, (k, v) -> v + credit);
                plannedWeekly.merge(slug, credit, Double::sum);
                if (muscle.getRole() == MuscleRole.PRIMARY) {
                    exercisesPerMuscle.merge(slug, 1, Integer::sum);
                }
            }

            usedToday.add(best.getId());
            usedInProgram.add(best.getId());
            familiesToday.add(movementFamily(best.getName()));
            familiesInProgram.add(movementFamily(best.getName()));

            int[] prescription = prescriptionFor(req.getGoal(), compound);
            picked.add(ProgramDraftResponse.Exercise.builder()
                    .exerciseId(best.getId())
                    .name(best.getName())
                    .movementPattern(best.getMovementPattern())
                    .sets(sets)
                    .repsMin(prescription[0])
                    .repsMax(prescription[1])
                    .restSeconds(prescription[2])
                    .trainingMethod(myoreps ? TrainingMethod.MYOREPS : TrainingMethod.STRAIGHT_SETS)
                    .build());
        }
        return picked;
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    private static boolean servesAnyDeficit(Exercise candidate, Map<String, Double> deficit) {
        return candidate.getMuscles().stream()
                .filter(m -> m.getRole() == MuscleRole.PRIMARY)
                .anyMatch(m -> deficit.containsKey(m.getMuscleGroup().getSlug()));
    }

    private static boolean atMuscleLimit(Exercise candidate, Map<String, Double> deficit,
                                         Map<String, Integer> exercisesPerMuscle) {
        return candidate.getMuscles().stream()
                .filter(m -> m.getRole() == MuscleRole.PRIMARY)
                .map(m -> m.getMuscleGroup().getSlug())
                .filter(deficit::containsKey)
                .anyMatch(slug -> exercisesPerMuscle.getOrDefault(slug, 0) >= MAX_EXERCISES_PER_MUSCLE);
    }

    /** A primary muscle banks the full set; a secondary banks half. */
    static double creditFor(MuscleRole role, double sets) {
        return role == MuscleRole.PRIMARY ? sets : sets * SECONDARY_CREDIT;
    }

    /**
     * Equipment, stance and grip qualifiers. Stripping them collapses an exercise
     * to its movement family, so a session does not prescribe "Incline Chest
     * Press Dumbbell" and "Incline Chest Press Barbell" as if they were two
     * different exercises.
     */
    private static final List<String> QUALIFIERS = List.of(
            "barbell", "bardbell", "dumbbell", "smith", "cable", "machine", "ez bar", "trx",
            "unilateral", "bilateral", "with cuff", "with weight", "supine", "prone",
            "sitting", "standing", "seated", "wide grip", "narrow grip", "neutral grip",
            "stiff legged", "overhead", "incline", "decline", "bosu", "hanging", "roll out");

    static String movementFamily(String name) {
        String family = name.toLowerCase(Locale.ROOT);
        for (String qualifier : QUALIFIERS) {
            family = family.replace(qualifier, " ");
        }
        return family.replaceAll("\\s+", " ").trim();
    }

    static int setsPerExercise(TrainingGoal goal) {
        return goal == TrainingGoal.STRENGTH ? STRENGTH_SETS_PER_EXERCISE : HYPERTROPHY_SETS_PER_EXERCISE;
    }

    private static int maxExercisesPerDay(TrainingGoal goal) {
        return goal == TrainingGoal.STRENGTH ? MAX_EXERCISES_STRENGTH : MAX_EXERCISES_HYPERTROPHY;
    }

    private static double compoundBonus(TrainingGoal goal) {
        return goal == TrainingGoal.STRENGTH ? STRENGTH_COMPOUND_BONUS : HYPERTROPHY_COMPOUND_BONUS;
    }

    /**
     * {repsMin, repsMax, restSeconds} for a goal and movement pattern.
     *
     * Strength gets fewer reps and longer rests; the hybrid goal spreads across
     * the 4–12 band, compounds at the bottom of it and isolations at the top.
     */
    static int[] prescriptionFor(TrainingGoal goal, boolean compound) {
        if (goal == TrainingGoal.STRENGTH) {
            return compound ? new int[]{4, 6, 240} : new int[]{6, 10, 150};
        }
        return compound ? new int[]{5, 8, 180} : new int[]{8, 12, 90};
    }

    /**
     * Rough session length. A straight set costs its rest plus the work itself;
     * a myo-rep entry costs one such set plus the cluster that follows it.
     */
    static int estimateMinutes(List<ProgramDraftResponse.Exercise> exercises) {
        int seconds = WARMUP_SECONDS;
        for (ProgramDraftResponse.Exercise e : exercises) {
            if (e.getTrainingMethod() == TrainingMethod.MYOREPS) {
                seconds += e.getRestSeconds() + SECONDS_PER_SET + MYOREPS_CLUSTER_SECONDS;
            } else {
                seconds += e.getSets() * (e.getRestSeconds() + SECONDS_PER_SET);
            }
        }
        return (int) Math.round(seconds / 60.0);
    }

    /**
     * Planned vs asked-for weekly sets, one row per muscle group the builder
     * targets. The UI needs this to say plainly when a split cannot absorb the
     * volume requested — twenty sets a muscle across two days does not fit, and
     * the honest answer is "add a day or lower the number".
     */
    private List<ProgramDraftResponse.MuscleVolume> volumeReport(
            Map<String, Double> planned, int target) {
        return muscleGroupRepo.findAll().stream()
                .filter(g -> SplitDayType.FULL_BODY.getMuscleSlugs().contains(g.getSlug()))
                .sorted(Comparator.comparingInt(
                        g -> SplitDayType.FULL_BODY.getMuscleSlugs().indexOf(g.getSlug())))
                .map(g -> ProgramDraftResponse.MuscleVolume.builder()
                        .muscleGroupId(g.getId())
                        .name(g.getName())
                        .slug(g.getSlug())
                        .targetSets(target)
                        .plannedSets(Math.round(planned.getOrDefault(g.getSlug(), 0.0) * 10.0) / 10.0)
                        .build())
                .toList();
    }
}
