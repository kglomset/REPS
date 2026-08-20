package com.reps.service;

import com.reps.dto.response.ProgramInsightResponse;
import com.reps.dto.response.ExerciseTrendResponse;
import com.reps.dto.response.ProgressionSuggestionResponse;
import com.reps.dto.response.ProgressionSuggestionResponse.ExerciseSummary;
import com.reps.dto.response.ProgressionTrendResponse;
import com.reps.dto.response.ProgressionTrendResponse.SetDelta;
import com.reps.entity.Exercise;
import com.reps.entity.ExerciseMuscle;
import com.reps.entity.ExerciseSet;
import com.reps.entity.TrainingProgram;
import com.reps.entity.WorkoutSession;
import com.reps.enums.MuscleRole;
import com.reps.enums.SuggestionType;
import com.reps.enums.TrendDirection;
import com.reps.repository.ExerciseRepository;
import com.reps.repository.ExerciseSetRepository;
import com.reps.repository.TrainingProgramRepository;
import com.reps.repository.WorkoutSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Double-progression rule engine.
 *
 * Principle: one progression variable at a time, reps before weight.
 * The default path — adding reps within the repsMin–repsMax range — needs no
 * suggestion; the engine only speaks up when reps are maxed out
 * (INCREASE_WEIGHT), regressing (DELOAD), or flat (SWAP_EXERCISE).
 * Set count is program design and is never suggested.
 *
 * Rules are evaluated in priority order; first match wins:
 *   R1 INCREASE_WEIGHT — the best working set in the latest session reached
 *                        repsMax (typically the first, freshest set); the
 *                        later sets follow at the new load.
 *   R2 DELOAD          — matched set numbers sliding across 3 sessions at the
 *                        same weight, with no individual set improving.
 *   R3 SWAP_EXERCISE   — 4 sessions flat at the same weight, e1RM not rising.
 *
 * Separately from the rules, {@link #trend(List)} reports how the last two
 * completed sessions compare (UP / FLAT / DOWN) — descriptive only, shown as
 * an arrow on the exercise tile.
 *
 * All thresholds live in the constants below (design doc §8).
 */
@Service
@RequiredArgsConstructor
public class ProgressionService {

    // ── Thresholds (design doc §8) ────────────────────────────────────────
    static final int HISTORY_WINDOW = 6;
    static final int MIN_SNAPSHOTS_DELOAD = 3;
    static final int PLATEAU_WINDOW = 4;
    static final BigDecimal DELOAD_FACTOR = new BigDecimal("0.90");
    static final BigDecimal UPPER_INCREMENT = new BigDecimal("2.5");
    static final BigDecimal LOWER_INCREMENT = new BigDecimal("5");
    static final BigDecimal PLATE_STEP = new BigDecimal("2.5");
    static final BigDecimal MICRO_STEP = new BigDecimal("1.25");
    static final BigDecimal LIGHT_WEIGHT_CUTOFF = new BigDecimal("20");
    static final int RPE_GATE = 9;
    static final int FALLBACK_REPS_MIN = 6;
    static final int FALLBACK_REPS_MAX = 12;
    static final double PROGRAM_STALL_RATIO = 0.60;
    static final double PROGRAM_WARN_RATIO = 0.30;
    static final int PROGRAM_AGE_WEEKS = 10;
    static final double PROGRAM_AGE_MIN_SESSIONS_PER_WEEK = 2.0;
    static final int SWAP_ALTERNATIVES = 3;
    /** e1RM dead-band for the trend arrow when the working weight changed (1 %). */
    static final BigDecimal E1RM_TOLERANCE = new BigDecimal("0.01");

    /** Primary-muscle slugs that qualify as lower-body compound territory (+5 kg jumps). */
    private static final Set<String> LOWER_BODY_SLUGS = Set.of("quads", "hamstrings", "glutes");

    private final ExerciseSetRepository setRepo;
    private final ExerciseRepository exerciseRepo;
    private final TrainingProgramRepository programRepo;
    private final WorkoutSessionRepository sessionRepo;

    // ── Public API ────────────────────────────────────────────────────────

    /**
     * Compute the progression suggestion for one exercise, or null if the
     * user should simply keep progressing reps within the range.
     */
    public ProgressionSuggestionResponse suggestFor(Long userId, Exercise exercise,
                                                    Integer repsMin, Integer repsMax,
                                                    Integer targetSets) {
        return analyse(userId, exercise, repsMin, repsMax, targetSets, true).suggestion();
    }

    /**
     * Suggestion *and* week-to-week trend for one exercise, from a single read
     * of its history. Callers that render an exercise tile want both, and the
     * history query is the expensive part.
     *
     * @param includeSuggestion false for completed sessions, where a "do this
     *                          next" suggestion is meaningless but the trend
     *                          (how the session that just ended compared with
     *                          the one before) still is.
     */
    public ExerciseProgression analyse(Long userId, Exercise exercise,
                                       Integer repsMin, Integer repsMax, Integer targetSets,
                                       boolean includeSuggestion) {
        List<Snapshot> snapshots = toSnapshots(
                setRepo.findHistoryForUserAndExercise(userId, exercise.getId()));

        ProgressionSuggestionResponse suggestion = null;
        if (includeSuggestion) {
            suggestion = evaluate(snapshots, repsMin, repsMax, targetSets,
                    isLowerBodyCompound(exercise));
            if (suggestion != null && suggestion.getType() == SuggestionType.SWAP_EXERCISE) {
                suggestion.setAlternatives(findAlternatives(userId, exercise));
            }
        }
        return new ExerciseProgression(suggestion, trend(snapshots));
    }

    /** What the UI needs for one exercise tile. */
    public record ExerciseProgression(ProgressionSuggestionResponse suggestion,
                                      ProgressionTrendResponse trend) {
    }

    /**
     * Week-to-week trend for every exercise the user has completed history for,
     * in one query — backs the Progress tab's exercise list.
     */
    @Transactional(readOnly = true)
    public List<ExerciseTrendResponse> trendsForUser(Long userId) {
        Map<Long, List<ExerciseSet>> byExercise = setRepo.findCompletedHistoryForUser(userId)
                .stream()
                .collect(Collectors.groupingBy(
                        s -> s.getSessionExercise().getExercise().getId(),
                        LinkedHashMap::new, Collectors.toList()));

        List<ExerciseTrendResponse> result = new ArrayList<>();
        byExercise.forEach((exerciseId, sets) -> {
            ProgressionTrendResponse trend = trend(toSnapshots(sets));
            if (trend == null) return; // nothing to compare against yet
            result.add(ExerciseTrendResponse.builder()
                    .exerciseId(exerciseId)
                    .exerciseName(sets.get(0).getSessionExercise().getExercise().getName())
                    .trend(trend)
                    .build());
        });
        return result;
    }

    /** Program-level insight (design doc R4): is the active program stale? */
    @Transactional(readOnly = true)
    public ProgramInsightResponse programInsight(Long userId) {
        Optional<TrainingProgram> activeOpt = programRepo.findByUserIdAndActiveTrue(userId);
        if (activeOpt.isEmpty()) {
            return ProgramInsightResponse.builder()
                    .status(ProgramInsightResponse.Status.NO_ACTIVE_PROGRAM)
                    .message("No active program.")
                    .stalledExercises(List.of())
                    .build();
        }
        TrainingProgram program = activeOpt.get();

        // Distinct exercises across the program's templates (keep each one's repsMin)
        Map<Long, Exercise> exercises = new LinkedHashMap<>();
        Map<Long, Integer> repsMinByExercise = new HashMap<>();
        program.getWorkoutTemplates().forEach(t -> t.getExercises().forEach(te -> {
            exercises.putIfAbsent(te.getExercise().getId(), te.getExercise());
            if (te.getRepsMin() != null) {
                repsMinByExercise.putIfAbsent(te.getExercise().getId(), te.getRepsMin());
            }
        }));

        List<ExerciseSummary> stalled = new ArrayList<>();
        int evaluated = 0;
        for (Exercise ex : exercises.values()) {
            List<Snapshot> snaps = toSnapshots(setRepo.findHistoryForUserAndExercise(userId, ex.getId()));
            if (snaps.size() < MIN_SNAPSHOTS_DELOAD) continue; // not enough data to call it
            evaluated++;
            int min = repsMinByExercise.getOrDefault(ex.getId(), FALLBACK_REPS_MIN);
            List<Snapshot> window = lastN(snaps, HISTORY_WINDOW);
            if (isRegressing(window, min) || isPlateaued(window)) {
                stalled.add(new ExerciseSummary(ex.getId(), ex.getName()));
            }
        }

        Instant createdAt = program.getCreatedAt() != null ? program.getCreatedAt() : Instant.now();
        int weeksActive = (int) (Duration.between(createdAt, Instant.now()).toDays() / 7);
        long sessionsLogged = sessionRepo
                .findByUserIdAndStartedAtBetween(userId, createdAt, Instant.now()).stream()
                .filter(s -> s.getCompletedAt() != null)
                .count();
        double sessionsPerWeek = weeksActive > 0 ? (double) sessionsLogged / weeksActive : 0;

        double stallRatio = evaluated > 0 ? (double) stalled.size() / evaluated : 0;
        boolean ageTrigger = weeksActive >= PROGRAM_AGE_WEEKS
                && sessionsPerWeek >= PROGRAM_AGE_MIN_SESSIONS_PER_WEEK;

        ProgramInsightResponse.Status status;
        String message;
        if (stallRatio >= PROGRAM_STALL_RATIO || ageTrigger) {
            status = ProgramInsightResponse.Status.CHANGE_RECOMMENDED;
            message = stallRatio >= PROGRAM_STALL_RATIO
                    ? "Most lifts have stalled — consider starting a new block."
                    : "This program has run " + weeksActive + " weeks — consider a new block.";
        } else if (stallRatio >= PROGRAM_WARN_RATIO) {
            status = ProgramInsightResponse.Status.STALLING;
            message = "Some lifts are stalling. Keep an eye on the flagged exercises.";
        } else {
            status = ProgramInsightResponse.Status.OK;
            message = "Progression looks healthy.";
        }

        return ProgramInsightResponse.builder()
                .status(status)
                .message(message)
                .weeksActive(weeksActive)
                .stalledExercises(stalled)
                .build();
    }

    // ── Rule engine (pure; package-private for unit tests) ───────────────

    /**
     * Evaluate R1–R3 over snapshots (chronological, oldest first).
     * Returns null when no rule fires — the default "keep adding reps" path.
     */
    ProgressionSuggestionResponse evaluate(List<Snapshot> snapshots,
                                           Integer repsMin, Integer repsMax,
                                           Integer targetSets, boolean lowerBodyCompound) {
        if (snapshots.isEmpty()) return null;

        int min = repsMin != null ? repsMin : FALLBACK_REPS_MIN;
        int max = repsMax != null ? repsMax : FALLBACK_REPS_MAX;
        List<Snapshot> window = lastN(snapshots, HISTORY_WINDOW);
        Snapshot latest = window.get(window.size() - 1);

        // R1 — INCREASE_WEIGHT (only when the TOP of the rep range is reached on
        // every working set; below that, the default path is "add reps")
        if (toppedOut(latest, max, targetSets)) {
            return increaseWeightSuggestion(latest, min, max, lowerBodyCompound);
        }

        if (window.size() >= MIN_SNAPSHOTS_DELOAD) {
            // R2 — DELOAD
            if (isRegressing(window, min)) {
                return deloadSuggestion(latest);
            }
            // R3 — SWAP_EXERCISE
            if (window.size() >= PLATEAU_WINDOW && isPlateaued(window)) {
                return ProgressionSuggestionResponse.builder()
                        .type(SuggestionType.SWAP_EXERCISE)
                        .message("No change in " + PLATEAU_WINDOW
                                + " sessions at " + formatKg(latest.workingWeight())
                                + " kg — a variation could break the plateau.")
                        .build();
            }
        }
        return null;
    }

    /**
     * R1: the best working set in the latest snapshot reached repsMax.
     *
     * Reaching the top of the range on any working set — in practice the first,
     * freshest one — is the trigger. Waiting for every set to top out stalls
     * the load for weeks while the later sets catch up, which is exactly the
     * "reps go up, weight never does" pattern this is meant to break.
     */
    private boolean toppedOut(Snapshot latest, int repsMax, Integer targetSets) {
        List<Integer> reps = latest.workingSetReps();
        if (reps.isEmpty()) return false;
        // A half-logged session is not evidence — still require a full set count.
        if (targetSets != null && reps.size() < targetSets) return false;
        if (reps.stream().noneMatch(r -> r >= repsMax)) return false;
        // RPE gate: only applies when RPE was logged
        return latest.avgRpe() == null || latest.avgRpe() <= RPE_GATE;
    }

    /**
     * R2: the same set numbers sliding across the last 3 sessions at the SAME
     * working weight — a real cross-session decline.
     *
     * Compared set to set rather than on session totals, for two reasons: an
     * added or dropped set would otherwise fake a decline, and a set that is
     * actually improving should veto the deload even if the total dipped. Reps
     * naturally taper *within* a session (set 1 = 8, set 2 = 7 near failure),
     * so only the same set number across sessions is comparable.
     *
     * (repsMin is retained for signature stability / future rules but
     * intentionally unused here.)
     */
    boolean isRegressing(List<Snapshot> window, int repsMin) {
        List<Snapshot> last3 = lastN(window, MIN_SNAPSHOTS_DELOAD);
        if (last3.size() < MIN_SNAPSHOTS_DELOAD || !sameWorkingWeight(last3)) return false;

        List<Integer> common = commonSetNumbers(last3);
        if (common.isEmpty()) return false;

        // No individual set may have improved anywhere in the window…
        for (int setNumber : common) {
            List<Integer> reps = last3.stream().map(sn -> sn.repsForSet(setNumber)).toList();
            for (int i = 1; i < reps.size(); i++) {
                if (reps.get(i) > reps.get(i - 1)) return false;
            }
        }
        // …and the matched-set total has to fall every session.
        List<Integer> totals = last3.stream().map(sn -> {
            int total = 0;
            for (int setNumber : common) total += sn.repsForSet(setNumber);
            return total;
        }).toList();
        return strictlyDecreasing(totals);
    }

    /** Set numbers logged in every snapshot of the window, ascending. */
    private static List<Integer> commonSetNumbers(List<Snapshot> snaps) {
        Set<Integer> common = new TreeSet<>(snaps.get(0).setNumbers());
        for (Snapshot snapshot : snaps) common.retainAll(snapshot.setNumbers());
        return List.copyOf(common);
    }

    /** R3: last 4 snapshots — same weight, total reps flat (±1), e1RM not rising. */
    boolean isPlateaued(List<Snapshot> window) {
        List<Snapshot> last4 = lastN(window, PLATEAU_WINDOW);
        if (last4.size() < PLATEAU_WINDOW || !sameWorkingWeight(last4)) return false;

        IntSummaryStatistics repStats = last4.stream()
                .mapToInt(Snapshot::totalReps).summaryStatistics();
        if (repStats.getMax() - repStats.getMin() > 1) return false;

        BigDecimal first = last4.get(0).bestE1Rm();
        BigDecimal last = last4.get(last4.size() - 1).bestE1Rm();
        return first != null && last != null && last.compareTo(first) <= 0;
    }

    private ProgressionSuggestionResponse increaseWeightSuggestion(Snapshot latest, int repsMin, int repsMax,
                                                                   boolean lowerBodyCompound) {
        BigDecimal weight = latest.workingWeight();
        int best = latest.workingSetReps().stream().mapToInt(Integer::intValue).max().orElse(repsMax);
        String hit = "Hit " + best + " reps (top of the " + repsMin + "–" + repsMax + " range)";

        if (weight == null || weight.signum() <= 0) {
            // Bodyweight: informational only — no target weight to pre-fill
            return ProgressionSuggestionResponse.builder()
                    .type(SuggestionType.INCREASE_WEIGHT)
                    .message(hit + " — add external weight or a harder variation, then rebuild from "
                            + repsMin + " reps.")
                    .build();
        }

        BigDecimal suggested = weight.add(increment(weight, lowerBodyCompound))
                .setScale(2, RoundingMode.HALF_UP);
        return ProgressionSuggestionResponse.builder()
                .type(SuggestionType.INCREASE_WEIGHT)
                .message(hit + " at " + formatKg(weight) + " kg — go up to " + formatKg(suggested)
                        + " kg and start back at " + repsMin + " reps.")
                .suggestedWeightKg(suggested)
                .build();
    }

    private ProgressionSuggestionResponse deloadSuggestion(Snapshot latest) {
        BigDecimal weight = latest.workingWeight();
        ProgressionSuggestionResponse.ProgressionSuggestionResponseBuilder b =
                ProgressionSuggestionResponse.builder().type(SuggestionType.DELOAD);

        if (weight == null || weight.signum() <= 0) {
            return b.message("Reps are slipping — take an easier session and rebuild.").build();
        }
        BigDecimal step = weight.compareTo(LIGHT_WEIGHT_CUTOFF) < 0 ? MICRO_STEP : PLATE_STEP;
        BigDecimal suggested = roundToStep(weight.multiply(DELOAD_FACTOR), step);
        return b.message("Reps are slipping at " + formatKg(weight)
                        + " kg — drop to " + formatKg(suggested) + " kg and rebuild.")
                .suggestedWeightKg(suggested)
                .build();
    }

    /**
     * Load increment: +5 kg lower-body compound, +2.5 kg otherwise.
     * Below 20 kg (dumbbell/isolation territory) cap at +10 % of the
     * working weight, rounded to 1.25 kg micro-steps (minimum one step).
     */
    BigDecimal increment(BigDecimal weight, boolean lowerBodyCompound) {
        if (weight.compareTo(LIGHT_WEIGHT_CUTOFF) < 0) {
            BigDecimal tenPercent = roundToStep(weight.multiply(new BigDecimal("0.10")), MICRO_STEP);
            BigDecimal capped = tenPercent.min(UPPER_INCREMENT);
            return capped.max(MICRO_STEP);
        }
        return lowerBodyCompound ? LOWER_INCREMENT : UPPER_INCREMENT;
    }

    // ── Trend: how the last two completed sessions compare ────────────────

    /**
     * Compare the two most recent completed sessions for one exercise.
     *
     * Same working weight → the set-by-set rep change decides, which is the
     * common case and the one worth celebrating: reps climbing week to week is
     * progress even though the load never moved.
     *
     * Weight changed → estimated 1RM decides, with a 1 % dead-band, so trading
     * a couple of reps for extra load still reads as progress rather than a
     * regression.
     *
     * Returns null when there is nothing to compare against yet (first time
     * doing the exercise), or when the two sessions share no set numbers.
     */
    ProgressionTrendResponse trend(List<Snapshot> snapshots) {
        if (snapshots.size() < 2) return null;
        Snapshot previous = snapshots.get(snapshots.size() - 2);
        Snapshot latest = snapshots.get(snapshots.size() - 1);

        // Only set numbers logged in both sessions are comparable.
        List<SetDelta> deltas = new ArrayList<>();
        for (int setNumber : latest.setNumbers()) {
            Integer before = previous.repsForSet(setNumber);
            Integer now = latest.repsForSet(setNumber);
            if (before == null || now == null) continue;
            deltas.add(new SetDelta(setNumber, before, now, now - before));
        }
        if (deltas.isEmpty()) return null;

        int repsDelta = deltas.stream().mapToInt(SetDelta::getRepsDelta).sum();
        BigDecimal weightDelta = latest.workingWeight()
                .subtract(previous.workingWeight())
                .setScale(2, RoundingMode.HALF_UP);
        TrendDirection direction = trendDirection(weightDelta, repsDelta, previous, latest);

        return ProgressionTrendResponse.builder()
                .direction(direction)
                .headline(headline(direction))
                .message(trendMessage(direction, weightDelta, repsDelta, deltas, latest))
                .weightDeltaKg(weightDelta)
                .totalRepsDelta(repsDelta)
                .previousDate(previous.date())
                .latestDate(latest.date())
                .sets(deltas)
                .build();
    }

    private TrendDirection trendDirection(BigDecimal weightDelta, int repsDelta,
                                          Snapshot previous, Snapshot latest) {
        if (weightDelta.signum() == 0) return byReps(repsDelta);

        BigDecimal before = previous.bestE1Rm();
        BigDecimal now = latest.bestE1Rm();
        // Bodyweight on either side — no load to trade against, so reps decide.
        if (before == null || now == null || before.signum() <= 0) return byReps(repsDelta);

        BigDecimal tolerance = before.multiply(E1RM_TOLERANCE);
        BigDecimal diff = now.subtract(before);
        if (diff.compareTo(tolerance) > 0) return TrendDirection.UP;
        if (diff.compareTo(tolerance.negate()) < 0) return TrendDirection.DOWN;
        return TrendDirection.FLAT;
    }

    private static TrendDirection byReps(int repsDelta) {
        if (repsDelta > 0) return TrendDirection.UP;
        if (repsDelta < 0) return TrendDirection.DOWN;
        return TrendDirection.FLAT;
    }

    private static String headline(TrendDirection direction) {
        return switch (direction) {
            case UP -> "Progressing";
            case FLAT -> "Maintaining";
            case DOWN -> "Regressing";
        };
    }

    /** Short, plain-language explanation of the arrow. */
    private String trendMessage(TrendDirection direction, BigDecimal weightDelta, int repsDelta,
                                List<SetDelta> deltas, Snapshot latest) {
        List<SetDelta> gains = deltas.stream().filter(d -> d.getRepsDelta() > 0).toList();
        List<SetDelta> losses = deltas.stream().filter(d -> d.getRepsDelta() < 0).toList();
        boolean bodyweight = latest.workingWeight().signum() <= 0;
        String at = bodyweight ? "" : " at " + formatKg(latest.workingWeight()) + " kg";

        if (weightDelta.signum() > 0) {
            String added = "You added " + formatKg(weightDelta.abs()) + " kg";
            if (repsDelta > 0) {
                return added + " and still increased reps on " + join(gains) + ". Strong session.";
            }
            if (repsDelta == 0) {
                return added + " and held every rep" + at + ". Strong session.";
            }
            String easedOff = added + ", so reps eased off on " + join(losses) + ". ";
            return switch (direction) {
                case DOWN -> added + " but reps fell on " + join(losses)
                        + " — further than the extra load accounts for."
                        + " Stay at this weight until they come back.";
                case FLAT -> easedOff + "An even trade — same estimated 1RM as last time.";
                case UP -> easedOff + "That is the trade, and you came out ahead.";
            };
        }

        if (weightDelta.signum() < 0) {
            String dropped = "You dropped " + formatKg(weightDelta.abs()) + " kg";
            if (direction == TrendDirection.UP) {
                return dropped + " but pushed the reps up on " + join(gains) + ". Rebuild from here.";
            }
            if (direction == TrendDirection.FLAT) {
                return dropped + " and held about the same reps. Work back up to your old load.";
            }
            return dropped + (losses.isEmpty()
                    ? " without gaining reps, so your estimated 1RM is down."
                    : " and the reps came down too on " + join(losses) + ".")
                    + " Take an easier week, then rebuild.";
        }

        // Same working weight — reps tell the whole story.
        return switch (direction) {
            case UP -> "You increased reps on " + join(gains) + at + "."
                    + (losses.isEmpty()
                        ? " Keep this up."
                        : " Down on " + join(losses) + ", but net +" + repsDelta + ". Keep this up.");
            case FLAT -> gains.isEmpty() && losses.isEmpty()
                    ? "Same reps as last time" + at + " — matched set for set. One extra rep anywhere moves you forward."
                    : "Reps evened out" + at + " — up on " + join(gains) + ", down on " + join(losses)
                        + ". Aim for a net gain next time.";
            case DOWN -> "Reps came down on " + join(losses) + at + "."
                    + (gains.isEmpty()
                        ? " Match last session before adding load."
                        : " Up on " + join(gains) + ", but net " + repsDelta + ". Match last session before adding load.");
        };
    }

    /** "set 1 by 2, and set 2 by 1" — the rep change is always stated as a magnitude. */
    private static String join(List<SetDelta> deltas) {
        List<String> parts = deltas.stream()
                .map(d -> "set " + d.getSetNumber() + " by " + Math.abs(d.getRepsDelta()))
                .toList();
        if (parts.isEmpty()) return "no sets";
        if (parts.size() == 1) return parts.get(0);
        return String.join(", ", parts.subList(0, parts.size() - 1))
                + ", and " + parts.get(parts.size() - 1);
    }

    // ── Snapshot grouping ─────────────────────────────────────────────────

    /**
     * Group an exercise's set history (ordered by session start, then set
     * number — as returned by findHistoryForUserAndExercise) into one
     * snapshot per completed session.
     */
    List<Snapshot> toSnapshots(List<ExerciseSet> history) {
        // LinkedHashMap preserves chronological session order
        Map<Long, List<ExerciseSet>> bySession = history.stream()
                .filter(s -> s.getReps() != null)
                .collect(Collectors.groupingBy(
                        s -> s.getSessionExercise().getSession().getId(),
                        LinkedHashMap::new, Collectors.toList()));

        return bySession.values().stream().map(this::toSnapshot).toList();
    }

    private Snapshot toSnapshot(List<ExerciseSet> sets) {
        WorkoutSession session = sets.get(0).getSessionExercise() != null
                ? sets.get(0).getSessionExercise().getSession() : null;

        // Working weight = modal weight (most common), robust to a lighter first set.
        // Null weights (bodyweight) are treated as 0 for grouping.
        Map<BigDecimal, Long> counts = sets.stream().collect(Collectors.groupingBy(
                s -> normalize(s.getWeightKg()), Collectors.counting()));
        BigDecimal workingWeight = counts.entrySet().stream()
                .max(Comparator
                        .comparingLong((Map.Entry<BigDecimal, Long> e) -> e.getValue())
                        .thenComparing(Map.Entry::getKey))
                .map(Map.Entry::getKey)
                .orElse(BigDecimal.ZERO);

        List<ExerciseSet> workingSets = sets.stream()
                .filter(s -> normalize(s.getWeightKg()).compareTo(workingWeight) == 0)
                .toList();

        List<Integer> reps = workingSets.stream().map(ExerciseSet::getReps).toList();
        int totalReps = reps.stream().mapToInt(Integer::intValue).sum();

        OptionalDouble avgRpe = workingSets.stream()
                .filter(s -> s.getRpe() != null)
                .mapToInt(ExerciseSet::getRpe)
                .average();

        BigDecimal bestE1Rm = workingSets.stream()
                .map(s -> epley(normalize(s.getWeightKg()), s.getReps()))
                .filter(Objects::nonNull)
                .max(Comparator.naturalOrder())
                .orElse(null);

        // Set-numbered entries: the trend and the deload rule compare set 2 with
        // set 2, never set 2 with set 3.
        List<SetEntry> entries = workingSets.stream()
                .filter(x -> x.getSetNumber() != null)
                .map(x -> new SetEntry(x.getSetNumber(), x.getReps()))
                .sorted(Comparator.comparingInt(SetEntry::setNumber))
                .toList();

        return new Snapshot(
                session != null ? session.getId() : null,
                session != null ? session.getStartedAt() : null,
                workingWeight, reps, entries, totalReps,
                avgRpe.isPresent() ? avgRpe.getAsDouble() : null, bestE1Rm);
    }

    /** One working set inside a snapshot, keyed by its set number. */
    record SetEntry(int setNumber, int reps) {
    }

    /** One completed session's performance on one exercise. */
    record Snapshot(Long sessionId, Instant date,
                    BigDecimal workingWeight, List<Integer> workingSetReps,
                    List<SetEntry> setEntries,
                    int totalReps, Double avgRpe, BigDecimal bestE1Rm) {

        /** Convenience for tests and callers that don't care which session it was. */
        Snapshot(BigDecimal workingWeight, List<Integer> workingSetReps,
                 int totalReps, Double avgRpe, BigDecimal bestE1Rm) {
            this(null, null, workingWeight, workingSetReps,
                    numberSequentially(workingSetReps), totalReps, avgRpe, bestE1Rm);
        }

        /** Set numbers logged at the working weight, ascending. */
        List<Integer> setNumbers() {
            return setEntries.stream().map(SetEntry::setNumber).toList();
        }

        /** Reps for one set number, or null when that set wasn't logged here. */
        Integer repsForSet(int setNumber) {
            return setEntries.stream()
                    .filter(e -> e.setNumber() == setNumber)
                    .map(SetEntry::reps)
                    .findFirst()
                    .orElse(null);
        }

        private static List<SetEntry> numberSequentially(List<Integer> reps) {
            List<SetEntry> entries = new ArrayList<>();
            for (int i = 0; i < reps.size(); i++) entries.add(new SetEntry(i + 1, reps.get(i)));
            return List.copyOf(entries);
        }
    }

    // ── Swap alternatives ─────────────────────────────────────────────────

    /**
     * Up to 3 exercises sharing the current exercise's PRIMARY muscle group,
     * excluding the exercise itself. Library order (id) keeps results stable.
     */
    private List<ExerciseSummary> findAlternatives(Long userId, Exercise exercise) {
        Set<Long> primaryGroups = primaryMuscleGroupIds(exercise);
        if (primaryGroups.isEmpty()) return List.of();

        return exerciseRepo.findAllAvailableForUser(userId).stream()
                .filter(e -> !e.getId().equals(exercise.getId()))
                .filter(e -> primaryMuscleGroupIds(e).stream().anyMatch(primaryGroups::contains))
                .sorted(Comparator.comparing(Exercise::getId))
                .limit(SWAP_ALTERNATIVES)
                .map(e -> new ExerciseSummary(e.getId(), e.getName()))
                .toList();
    }

    private Set<Long> primaryMuscleGroupIds(Exercise exercise) {
        return exercise.getMuscles().stream()
                .filter(m -> m.getRole() == MuscleRole.PRIMARY)
                .map(m -> m.getMuscleGroup().getId())
                .collect(Collectors.toSet());
    }

    private boolean isLowerBodyCompound(Exercise exercise) {
        return exercise.getMuscles().stream()
                .filter(m -> m.getRole() == MuscleRole.PRIMARY)
                .map(ExerciseMuscle::getMuscleGroup)
                .anyMatch(g -> LOWER_BODY_SLUGS.contains(g.getSlug()));
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    private static <T> List<T> lastN(List<T> list, int n) {
        return list.size() <= n ? list : list.subList(list.size() - n, list.size());
    }

    private static boolean sameWorkingWeight(List<Snapshot> snaps) {
        BigDecimal first = snaps.get(0).workingWeight();
        return snaps.stream().allMatch(s -> s.workingWeight().compareTo(first) == 0);
    }

    private static boolean strictlyDecreasing(List<Integer> values) {
        for (int i = 1; i < values.size(); i++) {
            if (values.get(i) >= values.get(i - 1)) return false;
        }
        return true;
    }

    private static BigDecimal normalize(BigDecimal weight) {
        return weight == null ? BigDecimal.ZERO : weight.stripTrailingZeros();
    }

    /** Epley: w × (1 + reps/30). Null for missing/zero input. */
    private static BigDecimal epley(BigDecimal weight, Integer reps) {
        if (weight == null || weight.signum() <= 0 || reps == null || reps == 0) return null;
        return weight.multiply(BigDecimal.ONE.add(
                        BigDecimal.valueOf(reps).divide(BigDecimal.valueOf(30), 4, RoundingMode.HALF_UP)))
                .setScale(2, RoundingMode.HALF_UP);
    }

    /** Round to the nearest step, returned with plain scale 2 (avoids scientific notation in JSON). */
    static BigDecimal roundToStep(BigDecimal value, BigDecimal step) {
        return value.divide(step, 0, RoundingMode.HALF_UP).multiply(step)
                .setScale(2, RoundingMode.HALF_UP);
    }

    private static String formatKg(BigDecimal weight) {
        return weight == null ? "0" : weight.stripTrailingZeros().toPlainString();
    }
}
