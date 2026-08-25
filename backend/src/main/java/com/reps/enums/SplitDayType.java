package com.reps.enums;

import java.util.List;

/**
 * One kind of training day, and the muscle groups it owns. The program builder
 * composes splits out of these and derives each muscle's weekly frequency by
 * counting how often it appears across the week.
 *
 * Traps, lower back, obliques and forearms are deliberately absent: they are not
 * volume targets, they accrue work as secondary muscles.
 */
public enum SplitDayType {

    FULL_BODY("Full Body", List.of(
            "chest", "lats", "upper-back", "front-delts", "side-delts", "rear-delts",
            "biceps", "triceps", "quads", "hamstrings", "glutes", "calves", "abs")),

    UPPER("Upper", List.of(
            "chest", "lats", "upper-back", "front-delts", "side-delts", "rear-delts",
            "biceps", "triceps")),

    LOWER("Lower", List.of("quads", "hamstrings", "glutes", "calves", "abs")),

    PUSH("Push", List.of("chest", "front-delts", "side-delts", "triceps")),

    PULL("Pull", List.of("lats", "upper-back", "rear-delts", "biceps")),

    LEGS("Legs", List.of("quads", "hamstrings", "glutes", "calves", "abs")),

    CHEST_BACK("Chest & Back", List.of("chest", "lats", "upper-back")),

    SHOULDERS_ARMS("Shoulders & Arms", List.of(
            "front-delts", "side-delts", "rear-delts", "biceps", "triceps")),

    CHEST("Chest", List.of("chest")),

    BACK("Back", List.of("lats", "upper-back")),

    ARMS("Arms", List.of("biceps", "triceps")),

    SHOULDERS("Shoulders", List.of("front-delts", "side-delts", "rear-delts"));

    private final String label;
    private final List<String> muscleSlugs;

    SplitDayType(String label, List<String> muscleSlugs) {
        this.label = label;
        this.muscleSlugs = muscleSlugs;
    }

    public String getLabel() {
        return label;
    }

    public List<String> getMuscleSlugs() {
        return muscleSlugs;
    }
}
