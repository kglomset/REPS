package com.reps.repository;

import com.reps.entity.BodyWeightLog;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface BodyWeightLogRepository extends JpaRepository<BodyWeightLog, Long> {
    List<BodyWeightLog> findByUserIdOrderByLogDateAsc(Long userId);
    Optional<BodyWeightLog> findByUserIdAndLogDate(Long userId, LocalDate logDate);
}
