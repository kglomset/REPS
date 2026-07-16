package com.reps.repository;

import com.reps.entity.WorkoutTemplate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface WorkoutTemplateRepository extends JpaRepository<WorkoutTemplate, Long> {

    /** Fetch a single template with its exercises eagerly loaded. */
    @Query("SELECT DISTINCT t FROM WorkoutTemplate t " +
           "LEFT JOIN FETCH t.exercises e LEFT JOIN FETCH e.exercise " +
           "WHERE t.id = :id")
    Optional<WorkoutTemplate> findByIdWithExercises(Long id);

    /** All standalone templates owned by a user, newest first, with exercises. */
    @Query("SELECT DISTINCT t FROM WorkoutTemplate t " +
           "LEFT JOIN FETCH t.exercises e LEFT JOIN FETCH e.exercise " +
           "WHERE t.standalone = true AND t.user.id = :userId " +
           "ORDER BY t.id DESC")
    List<WorkoutTemplate> findStandaloneByUser(Long userId);
}
