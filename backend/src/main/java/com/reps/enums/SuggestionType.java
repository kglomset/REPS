package com.reps.enums;

/**
 * Progression suggestion types surfaced on exercise tiles during an active
 * session. One suggestion at most per exercise; each changes exactly one
 * progression variable (weight OR exercise — never sets, which are program
 * design, and never several variables at once).
 */
public enum SuggestionType {
    /** Rep range topped out on all working sets → add load. */
    INCREASE_WEIGHT,
    /** Performance regressing → reduce load and rebuild. */
    DELOAD,
    /** Plateaued (flat, not regressing) → rotate to a variation. */
    SWAP_EXERCISE
}
