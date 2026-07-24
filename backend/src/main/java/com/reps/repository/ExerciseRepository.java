package com.reps.repository;

import com.reps.entity.Exercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface ExerciseRepository extends JpaRepository<Exercise, Long> {

    @Query("SELECT DISTINCT e FROM Exercise e LEFT JOIN FETCH e.muscles m LEFT JOIN FETCH m.muscleGroup " +
           "WHERE e.createdBy IS NULL OR e.createdBy.id = :userId")
    List<Exercise> findAllAvailableForUser(Long userId);

    List<Exercise> findByCreatedByIsNull();
}
