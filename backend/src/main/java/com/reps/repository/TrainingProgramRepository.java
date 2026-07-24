package com.reps.repository;

import com.reps.entity.TrainingProgram;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface TrainingProgramRepository extends JpaRepository<TrainingProgram, Long> {
    List<TrainingProgram> findByUserId(Long userId);

    /**
     * Fetches the program with its templates. Template exercises are loaded by
     * a second query ({@link WorkoutTemplateRepository#findByProgramIdWithExercises})
     * — Hibernate cannot fetch-join two List "bags" (workoutTemplates AND
     * exercises) in one query without a MultipleBagFetchException.
     */
    @Query("SELECT DISTINCT p FROM TrainingProgram p LEFT JOIN FETCH p.workoutTemplates " +
           "WHERE p.id = :id AND p.user.id = :userId")
    Optional<TrainingProgram> findByIdAndUserIdWithDetails(Long id, Long userId);

    Optional<TrainingProgram> findByUserIdAndActiveTrue(Long userId);
}
