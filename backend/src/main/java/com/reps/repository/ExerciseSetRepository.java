package com.reps.repository;

import com.reps.entity.ExerciseSet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface ExerciseSetRepository extends JpaRepository<ExerciseSet, Long> {

    @Query("SELECT es FROM ExerciseSet es " +
           "JOIN es.sessionExercise se JOIN se.session s " +
           "WHERE se.exercise.id = :exerciseId AND s.user.id = :userId " +
           "AND s.completedAt IS NOT NULL " +
           "ORDER BY s.startedAt ASC, es.setNumber ASC")
    List<ExerciseSet> findHistoryForUserAndExercise(Long userId, Long exerciseId);

    /**
     * Every completed set the user has logged, ordered so it can be grouped by
     * exercise and then by session — one query behind the Progress tab's trend
     * arrows, instead of one per exercise.
     */
    @Query("SELECT es FROM ExerciseSet es " +
           "JOIN FETCH es.sessionExercise se " +
           "JOIN FETCH se.exercise e " +
           "JOIN FETCH se.session s " +
           "WHERE s.user.id = :userId AND s.completedAt IS NOT NULL " +
           "ORDER BY e.id ASC, s.startedAt ASC, es.setNumber ASC")
    List<ExerciseSet> findCompletedHistoryForUser(Long userId);
}
