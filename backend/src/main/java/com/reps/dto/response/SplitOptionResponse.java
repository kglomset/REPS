package com.reps.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/** One split the user can pick for a given number of training days. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SplitOptionResponse {
    private String id;
    /** e.g. "Upper / Lower ×2" */
    private String name;
    /** Day labels in order, e.g. [Upper, Lower, Upper, Lower]. */
    private List<String> dayNames;
    /**
     * How often the *least* frequently trained muscle group is hit per week.
     * 2 or more is the mark of a split worth recommending, and the list is
     * ordered so those come first.
     */
    private int minWeeklyFrequency;
}
