package com.reps.service;

import com.reps.dto.response.ProgramDraftResponse;
import com.reps.dto.response.SplitOptionResponse;
import com.reps.enums.MuscleRole;
import com.reps.enums.SplitDayType;
import com.reps.enums.TrainingGoal;
import com.reps.enums.TrainingMethod;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.util.List;

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

        @Test
        void equipmentVariantsShareAFamily() {
            assertEquals(ProgramBuilderService.movementFamily("Incline Chest Press Dumbbell"),
                    ProgramBuilderService.movementFamily("Incline Chest Press Barbell"));
            assertEquals(ProgramBuilderService.movementFamily("Sitting Calf Raise"),
                    ProgramBuilderService.movementFamily("Standing Calf Raise"));
            assertEquals(ProgramBuilderService.movementFamily("Upright Row Cable"),
                    ProgramBuilderService.movementFamily("Upright Row Smith"));
        }

        @Test
        void genuinelyDifferentMovementsDoNot() {
            assertNotEquals(ProgramBuilderService.movementFamily("Chest Press Dumbbell"),
                    ProgramBuilderService.movementFamily("Incline Chest Press Dumbbell"));
            assertNotEquals(ProgramBuilderService.movementFamily("Pull Up Wide Grip"),
                    ProgramBuilderService.movementFamily("Pull Down Wide Grip"));
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
