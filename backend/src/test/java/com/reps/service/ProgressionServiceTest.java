package com.reps.service;

import com.reps.dto.response.ProgressionSuggestionResponse;
import com.reps.dto.response.ProgressionTrendResponse;
import com.reps.entity.ExerciseSet;
import com.reps.entity.SessionExercise;
import com.reps.entity.WorkoutSession;
import com.reps.enums.SuggestionType;
import com.reps.enums.TrendDirection;
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
        void firesWhenOnlyTheTopSetHitsRepsMax() {
            // The first set is the freshest — topping the range there is the
            // trigger, rather than waiting weeks for the later sets to catch up.
            var s = eval(List.of(snap("60", 10, 9, 8)), 6, 10, 3, false);
            assertNotNull(s);
            assertEquals(SuggestionType.INCREASE_WEIGHT, s.getType());
        }

        @Test
        void doesNotFireWhenNoSetReachesRepsMax() {
            assertNull(eval(List.of(snap("60", 9, 9, 9)), 6, 10, 3, false));
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

        @Test
        void oneImprovingSetVetoesTheDeload() {
            // Set 2 is climbing even though the session total falls — that is a
            // shifting effort distribution, not a regression.
            var history = List.of(
                    snap("60", 9, 9, 9),
                    snap("60", 8, 9, 8),
                    snap("60", 7, 10, 7));
            assertNull(eval(history, 6, 12, 3, false));
        }

        @Test
        void firesWhenEverySetSlidesSetForSet() {
            var history = List.of(
                    snap("60", 9, 9, 9),
                    snap("60", 8, 9, 8),
                    snap("60", 7, 8, 7));
            var s = eval(history, 6, 12, 3, false);
            assertNotNull(s);
            assertEquals(SuggestionType.DELOAD, s.getType());
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
            // repsMax 12 keeps R1 out of the way — this is about the plateau rule
            var history = List.of(
                    snap("60", 8, 8, 8),
                    snap("60", 9, 8, 8),
                    snap("60", 9, 9, 9),
                    snap("60", 10, 9, 9));
            assertNull(eval(history, 6, 12, 3, false));
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

    // ── Week-to-week trend ────────────────────────────────────────────────

    @Nested
    @DisplayName("trend — how the last two completed sessions compare")
    class Trend {

        @Test
        void needsTwoSessionsToCompare() {
            assertNull(service.trend(List.of(snap("60", 8, 8, 8))));
            assertNull(service.trend(List.of()));
        }

        @Test
        void repsUpAtTheSameWeightIsProgress() {
            var t = service.trend(List.of(snap("60", 8, 8, 8), snap("60", 10, 9, 8)));
            assertNotNull(t);
            assertEquals(TrendDirection.UP, t.getDirection());
            assertEquals("Progressing", t.getHeadline());
            assertEquals(3, t.getTotalRepsDelta());
            // Reads like a sentence, listing only the sets that moved
            assertEquals("You increased reps on set 1 by 2, and set 2 by 1 at 60 kg. Keep this up.",
                    t.getMessage());
        }

        @Test
        void identicalSessionIsMaintaining() {
            var t = service.trend(List.of(snap("60", 8, 8, 8), snap("60", 8, 8, 8)));
            assertNotNull(t);
            assertEquals(TrendDirection.FLAT, t.getDirection());
            assertEquals(0, t.getTotalRepsDelta());
        }

        @Test
        void repsDownAtTheSameWeightIsRegression() {
            var t = service.trend(List.of(snap("60", 9, 9, 8), snap("60", 8, 8, 8)));
            assertNotNull(t);
            assertEquals(TrendDirection.DOWN, t.getDirection());
            assertEquals(-2, t.getTotalRepsDelta());
        }

        @Test
        void addingWeightStillCountsWhenRepsDipSlightly() {
            // 62.5 kg × 9 out-lifts 60 kg × 10 on estimated 1RM
            var t = service.trend(List.of(snap("60", 10, 10, 10), snap("62.5", 9, 9, 9)));
            assertNotNull(t);
            assertEquals(TrendDirection.UP, t.getDirection());
            assertTrue(t.getTotalRepsDelta() < 0);
            assertEquals(0, new BigDecimal("2.50").compareTo(t.getWeightDeltaKg()));
        }

        @Test
        void addingWeightDoesNotExcuseACollapse() {
            var t = service.trend(List.of(snap("60", 10, 10, 10), snap("62.5", 5, 5, 5)));
            assertNotNull(t);
            assertEquals(TrendDirection.DOWN, t.getDirection());
        }

        @Test
        void droppingWeightAtTheSameRepsIsRegression() {
            var t = service.trend(List.of(snap("60", 8, 8, 8), snap("55", 8, 8, 8)));
            assertNotNull(t);
            assertEquals(TrendDirection.DOWN, t.getDirection());
            // …and the wording must not claim reps fell, because they did not
            assertFalse(t.getMessage().contains("reps came down"));
        }

        @Test
        void comparesOnlyTheSetNumbersLoggedInBothSessions() {
            // A 4th set was added this time — it has no counterpart, so it is
            // left out rather than counted as a gain.
            var t = service.trend(List.of(snap("60", 8, 8, 8), snap("60", 8, 9, 8, 7)));
            assertNotNull(t);
            assertEquals(3, t.getSets().size());
            assertEquals(1, t.getTotalRepsDelta());
        }

        @Test
        void bodyweightComparisonFallsBackToReps() {
            var t = service.trend(List.of(snap(null, 12, 12), snap(null, 14, 13)));
            assertNotNull(t);
            assertEquals(TrendDirection.UP, t.getDirection());
            assertFalse(t.getMessage().contains("kg"));
        }

        @Test
        void setDeltasCarryBothSidesOfTheComparison() {
            var t = service.trend(List.of(snap("60", 8, 8), snap("60", 10, 8)));
            assertNotNull(t);
            ProgressionTrendResponse.SetDelta first = t.getSets().get(0);
            assertEquals(1, first.getSetNumber());
            assertEquals(8, first.getPreviousReps());
            assertEquals(10, first.getReps());
            assertEquals(2, first.getRepsDelta());
        }
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
