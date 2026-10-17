package com.reps.repository;

import com.reps.entity.Movement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface MovementRepository extends JpaRepository<Movement, Long> {

    @Query("SELECT DISTINCT m FROM Movement m " +
           "LEFT JOIN FETCH m.muscles em LEFT JOIN FETCH em.muscleGroup " +
           "LEFT JOIN FETCH m.equipmentOptions " +
           "WHERE m.createdBy IS NULL OR m.createdBy.id = :userId")
    List<Movement> findAllAvailableForUser(Long userId);

    Optional<Movement> findByNameIgnoreCase(String name);
}
