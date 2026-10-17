package com.reps.service;

import com.reps.dto.response.ProgramDraftResponse;
import com.reps.dto.response.SplitOptionResponse;
import com.reps.entity.Exercise;
import com.reps.entity.Movement;
import com.reps.enums.MuscleRole;
import com.reps.enums.SplitDayType;
import com.reps.enums.TrainingGoal;
import com.reps.enums.TrainingMethod;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for the parts of the program builder that need no repositories:
 * the split catalogue and ranking, the prescription table, movement families,
 * volume credit and the session-time model.
 */
class ProgramBuilderServiceTest {

    private final ProgramBuilderService service = new ProgramBuilderService(null, null);

    // ── Split catalogue ───────────────────────────────────────────────────

    @Nested
    @DisplayName("splits — one list per frequency, twice-a-week options first")
    class Splits {

        @Test
        void everyFrequencyFromOneToSixHasAtLeastOneSplit() {
            for (int days = 1; days <= 6; days++) {
                List<SplitOptionResponse> options = service.splitsFor(days);
                assertFalse(options.isEmpty(), days + " days has no split");
                for (SplitOptionResponse option : options) {
                    assertEquals(days, option.getDayNames().size(),
                            option.getName() + " should have " + days + " days");
                }
            }
        }

        @Test
        void splitsHittingEveryMuscleTwiceComeFirst() {
            for (int days = 1; days <= 6; days++) {
                List<SplitOptionResponse> options = service.splitsFor(days);
                boolean seenBelowTwo = false;
                for (SplitOptionResponse option : options) {
                    if (option.getMinWeeklyFrequency() < 2) seenBelowTwo = true;
                    else assertFalse(seenBelowTwo,
                            option.getName() + " ranked below a once-a-week split");
                }
            }
        }

        @Test
        void upperLowerTwiceHitsEveryMuscleTwiceAWeek() {
            assertEquals(2, ProgramBuilderService.minWeeklyFrequency(List.of(
                    SplitDayType.UPPER, SplitDayType.LOWER,
                    SplitDayType.UPPER, SplitDayType.LOWER)));
        }

        @Test
        void upperLowerOnceOnlyHitsEveryMuscleOnce() {
            assertEquals(1, ProgramBuilderService.minWeeklyFrequency(
                    List.of(SplitDayType.UPPER, SplitDayType.LOWER)));
        }

        @Test
        void pushPullLegsLeavesEveryMuscleAtOnceAWeek() {
            assertEquals(1, ProgramBuilderService.minWeeklyFrequency(
                    List.of(SplitDayType.PUSH, SplitDayType.PULL, SplitDayType.LEGS)));
        }

        @Test
        void unknownFrequencyIsRejected() {
            assertThrows(RuntimeException.class, () -> service.splitsFor(7));
        }
    }

    // ── Default weekday layout ────────────────────────────────────────────

    @Nested
    @DisplayName("day layout — rest days land where recovery wants them")
    class DayLayout {

        @Test
        void fullBodySessionsAreNeverBackToBack() {
            for (int days = 1; days <= 4; days++) {
                List<SplitDayType> allFullBody = java.util.Collections.nCopies(
                        days, SplitDayType.FULL_BODY);
                List<Integer> layout = ProgramBuilderService.defaultDayIndices(allFullBody);
                for (int i = 1; i < layout.size(); i++) {
                    assertTrue(layout.get(i) - layout.get(i - 1) >= 2,
                            days + " full-body days landed on consecutive weekdays: " + layout);
                }
            }
        }

        @Test
        void fourFullBodyDaysSpreadAcrossTheWholeWeek() {
            assertEquals(List.of(0, 2, 4, 6), ProgramBuilderService.defaultDayIndices(
                    java.util.Collections.nCopies(4, SplitDayType.FULL_BODY)));
        }

        @Test
        void aRepeatedCycleGetsARestDayBetweenRounds() {
            // Upper / Lower twice: Mon, Tue — rest — Thu, Fri
            assertEquals(List.of(0, 1, 3, 4), ProgramBuilderService.defaultDayIndices(List.of(
                    SplitDayType.UPPER, SplitDayType.LOWER,
                    SplitDayType.UPPER, SplitDayType.LOWER)));

            // Push / Pull / Legs twice: Mon–Wed — rest — Fri–Sun
            assertEquals(List.of(0, 1, 2, 4, 5, 6), ProgramBuilderService.defaultDayIndices(List.of(
                    SplitDayType.PUSH, SplitDayType.PULL, SplitDayType.LEGS,
                    SplitDayType.PUSH, SplitDayType.PULL, SplitDayType.LEGS)));
        }

        @Test
        void cycleLengthFindsTheRepeatingUnit() {
            assertEquals(1, ProgramBuilderService.cycleLength(
                    java.util.Collections.nCopies(3, SplitDayType.FULL_BODY)));
            assertEquals(2, ProgramBuilderService.cycleLength(List.of(
                    SplitDayType.UPPER, SplitDayType.LOWER,
                    SplitDayType.UPPER, SplitDayType.LOWER)));
            // A single pass never repeats, so the whole thing is the cycle
            assertEquals(3, ProgramBuilderService.cycleLength(List.of(
                    SplitDayType.PUSH, SplitDayType.PULL, SplitDayType.LEGS)));
        }

        @Test
        void everySplitGetsOneDistinctWeekdayPerSession() {
            for (int days = 1; days <= 6; days++) {
                for (SplitOptionResponse option : service.splitsFor(days)) {
                    List<Integer> layout = option.getRecommendedDayIndices();
                    assertEquals(days, layout.size(), option.getName());
                    assertEquals(days, Set.copyOf(layout).size(),
                            option.getName() + " repeats a weekday: " + layout);
                    assertTrue(layout.stream().allMatch(d -> d >= 0 && d <= 6),
                            option.getName() + " falls outside the week: " + layout);
                    assertEquals(layout.stream().sorted().toList(), layout,
                            option.getName() + " is not in weekday order: " + layout);
                }
            }
        }
    }

    // ── Prescription ──────────────────────────────────────────────────────

    @Nested
    @DisplayName("prescription — goal × movement pattern")
    class Prescription {

        @Test
        void strengthUsesFewerRepsAndLongerRestOnCompounds() {
            int[] p = ProgramBuilderService.prescriptionFor(TrainingGoal.STRENGTH, true);
            assertArrayEquals(new int[]{4, 6, 240}, p);
        }

        @Test
        void hybridGoalSpansFourToTwelveReps() {
            int[] compound = ProgramBuilderService.prescriptionFor(TrainingGoal.HYPERTROPHY, true);
            int[] isolation = ProgramBuilderService.prescriptionFor(TrainingGoal.HYPERTROPHY, false);
            assertTrue(compound[0] >= 4 && isolation[1] <= 12);
            assertTrue(compound[1] <= isolation[0],
                    "compounds should sit below isolations in the rep band");
        }

        @Test
        void strengthPrescribesMoreSetsPerExercise() {
            assertTrue(ProgramBuilderService.setsPerExercise(TrainingGoal.STRENGTH)
                    > ProgramBuilderService.setsPerExercise(TrainingGoal.HYPERTROPHY));
        }
    }

    // ── Movement families ─────────────────────────────────────────────────

    @Nested
    @DisplayName("movement family — equipment variants collapse together")
    class Families {

        /**
         * Equipment lives on the exercise row, not the movement, since the
         * exercise/equipment redesign (docs/exercise-equipment-redesign.md) -
         * two variants "share a family" exactly when they point at the same
         * Movement, whatever equipment or variation each one carries.
         */
        private Exercise variantOf(long movementId, String equipmentHint) {
            Movement movement = Movement.builder().id(movementId).name("M" + movementId).build();
            return Exercise.builder()
                    .movement(movement)
                    .name(equipmentHint + " M" + movementId)
                    .build();
        }

        @Test
        void equipmentVariantsShareAFamily() {
            assertEquals(
                    ProgramBuilderService.movementFamily(variantOf(1, "Dumbbell")),
                    ProgramBuilderService.movementFamily(variantOf(1, "Barbell")));
            assertEquals(
                    ProgramBuilderService.movementFamily(variantOf(2, "Sitting")),
                    ProgramBuilderService.movementFamily(variantOf(2, "Standing")));
            assertEquals(
                    ProgramBuilderService.movementFamily(variantOf(3, "Cable")),
                    ProgramBuilderService.movementFamily(variantOf(3, "Smith")));
        }

        @Test
        void genuinelyDifferentMovementsDoNot() {
            assertNotEquals(
                    ProgramBuilderService.movementFamily(variantOf(4, "Dumbbell")),
                    ProgramBuilderService.movementFamily(variantOf(5, "Dumbbell")));
            assertNotEquals(
                    ProgramBuilderService.movementFamily(variantOf(6, "Bodyweight")),
                    ProgramBuilderService.movementFamily(variantOf(7, "Bodyweight")));
        }
    }

    // ── Volume credit & session time ──────────────────────────────────────

    @Test
    void secondaryMusclesBankHalfASet() {
        assertEquals(3.0, ProgramBuilderService.creditFor(MuscleRole.PRIMARY, 3));
        assertEquals(1.5, ProgramBuilderService.creditFor(MuscleRole.SECONDARY, 3));
    }

    @Test
    void sessionEstimateCountsRestAndWork() {
        // 3 sets × (90 s rest + 40 s work) = 390 s, plus a 360 s warm-up
        var straight = ProgramDraftResponse.Exercise.builder()
                .sets(3).restSeconds(90).trainingMethod(TrainingMethod.STRAIGHT_SETS).build();
        assertEquals(13, ProgramBuilderService.estimateMinutes(List.of(straight)));
    }

    @Test
    void myorepsCostOneSetPlusTheCluster() {
        // A myo-reps entry is written as 6 sets but costs far less than 6 straight
        // ones — that is the whole point of offering it.
        var myo = ProgramDraftResponse.Exercise.builder()
                .sets(6).restSeconds(90).trainingMethod(TrainingMethod.MYOREPS).build();
        var straight = ProgramDraftResponse.Exercise.builder()
                .sets(6).restSeconds(90).trainingMethod(TrainingMethod.STRAIGHT_SETS).build();
        assertTrue(ProgramBuilderService.estimateMinutes(List.of(myo))
                < ProgramBuilderService.estimateMinutes(List.of(straight)));
    }

    @Test
    void everyDayTypeTargetsMusclesTheFullBodyDayAlsoCovers() {
        // The volume report is built from the full-body list, so no other day
        // type may target something outside it.
        for (SplitDayType type : SplitDayType.values()) {
            assertTrue(SplitDayType.FULL_BODY.getMuscleSlugs().containsAll(type.getMuscleSlugs()),
                    type + " targets a muscle group the full-body day does not");
        }
    }
}
