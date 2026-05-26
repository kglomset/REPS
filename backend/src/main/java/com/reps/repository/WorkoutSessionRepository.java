package com.reps.repository;

import com.reps.entity.WorkoutSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

public interface WorkoutSessionRepository extends JpaRepository<WorkoutSession, Long> {

    List<WorkoutSession> findByUserIdOrderByStartedAtDesc(Long userId);

    @Query("SELECT s FROM WorkoutSession s LEFT JOIN FETCH s.exercises e " +
           "LEFT JOIN FETCH e.sets LEFT JOIN FETCH e.exercise " +
           "WHERE s.id = :id AND s.user.id = :userId")
    Optional<WorkoutSession> findByIdAndUserIdWithDetails(Long id, Long userId);

    List<WorkoutSession> findByUserIdAndStartedAtBetween(Long userId, Instant from, Instant to);

    @Query("SELECT s FROM WorkoutSession s WHERE s.user.id = :userId AND s.template.id = :templateId " +
           "AND s.completedAt IS NOT NULL ORDER BY s.startedAt DESC")
    List<WorkoutSession> findCompletedByUserAndTemplate(Long userId, Long templateId);
}
