package com.reps.enums;

/**
 * Week-to-week direction for one exercise, computed by comparing the two most
 * recent completed sessions set by set. Purely descriptive — unlike
 * {@link SuggestionType} it never asks the user to change anything.
 */
public enum TrendDirection {
    /** Better than last time: more reps at the same load, or a higher estimated 1RM. */
    UP,
    /** Held the line — same reps at the same load (within a 1 % e1RM dead-band). */
    FLAT,
    /** Worse than last time. */
    DOWN
}
