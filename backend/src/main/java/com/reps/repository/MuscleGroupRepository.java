package com.reps.repository;

import com.reps.entity.MuscleGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface MuscleGroupRepository extends JpaRepository<MuscleGroup, Long> {
    Optional<MuscleGroup> findBySlug(String slug);
}
