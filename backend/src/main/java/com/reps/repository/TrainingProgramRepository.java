package com.reps.repository;

import com.reps.entity.TrainingProgram;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Optional;

public interface TrainingProgramRepository extends JpaRepository<TrainingProgram, Long> {
    List<TrainingProgram> findByUserId(Long userId);

    @Query("SELECT p FROM TrainingProgram p LEFT JOIN FETCH p.workoutTemplates t " +
           "LEFT JOIN FETCH t.exercises e LEFT JOIN FETCH e.exercise " +
           "WHERE p.id = :id AND p.user.id = :userId")
    Optional<TrainingProgram> findByIdAndUserIdWithDetails(Long id, Long userId);

    Optional<TrainingProgram> findByUserIdAndActiveTrue(Long userId);
}
