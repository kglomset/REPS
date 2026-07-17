package com.reps.service;

import com.reps.dto.response.ProgressionSuggestionResponse;
import com.reps.entity.ExerciseSet;
import com.reps.entity.SessionExercise;
import com.reps.entity.WorkoutSession;
import com.reps.enums.SuggestionType;
import com.reps.service.ProgressionService.Snapshot;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Pure unit tests for the double-progression rule engine (design doc §4).
 * No Spring context: evaluate()/toSnapshots() never touch repositories.
 */
class ProgressionServiceTest {

    private final ProgressionService service = new ProgressionService(null, null, null, null);

    // ── Helpers ───────────────────────────────────────────────────────────

    /** Snapshot with the given working weight and per-set reps (no RPE). */
    private static Snapshot snap(String weight, int... reps) {
        return snap(weight, null, reps);
    }

    private static Snapshot snap(String weight, Double avgRpe, int... reps) {
        BigDecimal w = weight == null ? BigDecimal.ZERO : new BigDecimal(weight);
        List<Integer> repList = Arrays.stream(reps).boxed().toList();
        int total = Arrays.stream(reps).sum();
        BigDecimal bestE1Rm = null;
        if (w.signum() > 0 && reps.length > 0) {
            int bestReps = Arrays.stream(reps).max().orElse(0);
            bestE1Rm = w.multiply(BigDecimal.ONE.add(
                            BigDecimal.valueOf(bestReps).divide(BigDecimal.valueOf(30), 4, RoundingMode.HALF_UP)))
                    .setScale(2, RoundingMode.HALF_UP);
        }
        return new Snapshot(w.stripTrailingZeros(), repList, total, avgRpe, bestE1Rm);
    }

    private ProgressionSuggestionResponse eval(List<Snapshot> snaps, int repsMin, int repsMax,
                                               Integer targetSets, boolean lowerBody) {
        return service.evaluate(snaps, repsMin, repsMax, targetSets, lowerBody);
    }

    // ── R1: INCREASE_WEIGHT ───────────────────────────────────────────────

    @Nested
    @DisplayName("R1 — increase weight when the rep range is topped out")
    class IncreaseWeight {

        @Test
        void firesWhenAllSetsHitRepsMax() {
            var s = eval(List.of(snap("60", 10, 10, 10)), 6, 10, 3, false);
            assertNotNull(s);
            assertEquals(SuggestionType.INCREASE_WEIGHT, s.getType());
            assertEquals(0, new BigDecimal("62.50").compareTo(s.getSuggestedWeightKg()));
        }

        @Test
        void lowerBodyCompoundJumpsFiveKg() {
            var s = eval(List.of(snap("100", 10, 10, 10)), 6, 10, 3, true);
            assertNotNull(s);
            assertEquals(0, new BigDecimal("105.00").compareTo(s.getSuggestedWeightKg()));
        }

        @Test
        void doesNotFireWhenAnySetBelowRepsMax() {
            assertNull(eval(List.of(snap("60", 10, 10, 9)), 6, 10, 3, false));
        }

        @Test
        void doesNotFireWhenFewerSetsThanTarget() {
            assertNull(eval(List.of(snap("60", 10, 10)), 6, 10, 3, false));
        }

        @Test
        void rpeGateSuppressesSuggestion() {
            assertNull(eval(List.of(snap("60", 9.5, 10, 10, 10)), 6, 10, 3, false));
        }

        @Test
        void lightWeightCapsIncrementAtTenPercentMicroSteps() {
            // 10 % of 15 kg = 1.5 → rounded to 1.25 micro-step → 16.25
            var s = eval(List.of(snap("15", 10, 10, 10)), 6, 10, 3, false);
            assertNotNull(s);
            assertEquals(0, new BigDecimal("16.25").compareTo(s.getSuggestedWeightKg()));
        }

        @Test
        void bodyweightExerciseGetsMessageOnlySuggestion() {
            var s = eval(List.of(snap(null, 10, 10, 10)), 6, 10, 3, false);
            assertNotNull(s);
            assertEquals(SuggestionType.INCREASE_WEIGHT, s.getType());
            assertNull(s.getSuggestedWeightKg());
        }

        @Test
        void fallbackRepRangeAppliesWhenTemplateHasNone() {
            // Fallback range is 6–10 — 3×10 tops it out
            var s = service.evaluate(List.of(snap("60", 10, 10, 10)), null, null, 3, false);
            assertNotNull(s);
            assertEquals(SuggestionType.INCREASE_WEIGHT, s.getType());
        }
    }

    // ── R2: DELOAD ────────────────────────────────────────────────────────

    @Nested
    @DisplayName("R2 — deload when performance regresses")
    class Deload {

        @Test
        void firesWhenRepsFallAcrossThreeSessionsAtSameWeight() {
            var history = List.of(
                    snap("60", 10, 10, 10),  // topped out here…
                    snap("60", 9, 10, 9),    // …then slid back
                    snap("60", 9, 9, 8));
            var s = eval(history, 6, 10, 3, false);
            assertNotNull(s);
            assertEquals(SuggestionType.DELOAD, s.getType());
            // 90 % of 60 = 54 → rounded to plate step 2.5 → 55.00
            assertEquals(0, new BigDecimal("55.00").compareTo(s.getSuggestedWeightKg()));
        }

        @Test
        void firesWhenHalfTheSetsMissRepsMin() {
            var history = List.of(
                    snap("60", 8, 8, 8),
                    snap("60", 8, 7, 8),
                    snap("60", 5, 5, 8)); // 2 of 3 sets below repsMin=6
            var s = eval(history, 6, 10, 3, false);
            assertNotNull(s);
            assertEquals(SuggestionType.DELOAD, s.getType());
        }

        @Test
        void needsThreeSnapshots() {
            var history = List.of(snap("60", 8, 8, 8), snap("60", 5, 5, 5));
            assertNull(eval(history, 6, 10, 3, false));
        }

        @Test
        void doesNotFireWhenWeightChangedBetweenSessions() {
            var history = List.of(
                    snap("55", 10, 10, 10),
                    snap("60", 9, 9, 9),   // heavier — fewer reps is expected
                    snap("60", 8, 9, 9));
            var s = eval(history, 6, 10, 3, false);
            assertTrue(s == null || s.getType() != SuggestionType.DELOAD);
        }
    }

    // ── R3: SWAP_EXERCISE ─────────────────────────────────────────────────

    @Nested
    @DisplayName("R3 — swap exercise on a flat plateau")
    class Swap {

        @Test
        void firesAfterFourFlatSessions() {
            var history = List.of(
                    snap("60", 8, 8, 8),
                    snap("60", 8, 8, 8),
                    snap("60", 8, 8, 8),
                    snap("60", 8, 8, 8));
            var s = eval(history, 6, 10, 3, false);
            assertNotNull(s);
            assertEquals(SuggestionType.SWAP_EXERCISE, s.getType());
        }

        @Test
        void toleratesOneRepOfNoise() {
            var history = List.of(
                    snap("60", 8, 8, 8),
                    snap("60", 8, 8, 9),  // 25 total — within ±1
                    snap("60", 8, 8, 8),
                    snap("60", 8, 8, 8));
            var s = eval(history, 6, 10, 3, false);
            assertNotNull(s);
            assertEquals(SuggestionType.SWAP_EXERCISE, s.getType());
        }

        @Test
        void doesNotFireWhenRepsAreClimbing() {
            var history = List.of(
                    snap("60", 8, 8, 8),
                    snap("60", 9, 8, 8),
                    snap("60", 9, 9, 9),
                    snap("60", 10, 9, 9));
            assertNull(eval(history, 6, 10, 3, false));
        }

        @Test
        void needsFourSnapshots() {
            var history = List.of(
                    snap("60", 8, 8, 8),
                    snap("60", 8, 8, 8),
                    snap("60", 8, 8, 8));
            assertNull(eval(history, 6, 10, 3, false));
        }
    }

    // ── Defaults & guards ─────────────────────────────────────────────────

    @Test
    void emptyHistoryYieldsNoSuggestion() {
        assertNull(eval(List.of(), 6, 10, 3, false));
    }

    @Test
    void normalRepProgressionYieldsNoSuggestion() {
        // The default path: adding reps inside the range needs no badge
        var history = List.of(
                snap("60", 7, 7, 6),
                snap("60", 8, 7, 7),
                snap("60", 8, 8, 8));
        assertNull(eval(history, 6, 10, 3, false));
    }

    // ── Snapshot grouping from entity history ─────────────────────────────

    @Nested
    @DisplayName("toSnapshots — grouping raw set history into per-session snapshots")
    class Snapshots {

        private ExerciseSet set(WorkoutSession session, int setNumber, String weight, int reps) {
            SessionExercise se = SessionExercise.builder().session(session).build();
            return ExerciseSet.builder()
                    .sessionExercise(se)
                    .setNumber(setNumber)
                    .weightKg(weight == null ? null : new BigDecimal(weight))
                    .reps(reps)
                    .build();
        }

        private WorkoutSession session(long id) {
            return WorkoutSession.builder().id(id).build();
        }

        @Test
        void groupsBySessionPreservingOrder() {
            var s1 = session(1);
            var s2 = session(2);
            var history = List.of(
                    set(s1, 1, "60", 8), set(s1, 2, "60", 8),
                    set(s2, 1, "60", 9), set(s2, 2, "60", 9));

            List<Snapshot> snaps = service.toSnapshots(history);
            assertEquals(2, snaps.size());
            assertEquals(16, snaps.get(0).totalReps());
            assertEquals(18, snaps.get(1).totalReps());
        }

        @Test
        void modalWeightIgnoresWarmupSet() {
            var s1 = session(1);
            var history = new ArrayList<ExerciseSet>();
            history.add(set(s1, 1, "20", 12));  // warm-up
            history.add(set(s1, 2, "60", 10));
            history.add(set(s1, 3, "60", 10));
            history.add(set(s1, 4, "60", 10));

            List<Snapshot> snaps = service.toSnapshots(history);
            assertEquals(1, snaps.size());
            assertEquals(0, new BigDecimal("60").compareTo(snaps.get(0).workingWeight()));
            assertEquals(List.of(10, 10, 10), snaps.get(0).workingSetReps());

            // And R1 fires off the working sets alone
            var suggestion = service.evaluate(snaps, 6, 10, 3, false);
            assertNotNull(suggestion);
            assertEquals(SuggestionType.INCREASE_WEIGHT, suggestion.getType());
        }

        @Test
        void nullWeightsGroupAsBodyweight() {
            var s1 = session(1);
            var history = List.of(set(s1, 1, null, 12), set(s1, 2, null, 12));
            List<Snapshot> snaps = service.toSnapshots(history);
            assertEquals(1, snaps.size());
            assertEquals(0, BigDecimal.ZERO.compareTo(snaps.get(0).workingWeight()));
        }
    }
}
