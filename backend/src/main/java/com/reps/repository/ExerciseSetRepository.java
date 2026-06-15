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
}
