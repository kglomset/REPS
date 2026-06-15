package com.reps.service;

import com.reps.dto.request.BodyWeightRequest;
import com.reps.dto.response.BodyWeightResponse;
import com.reps.dto.response.ExerciseProgressResponse;
import com.reps.entity.BodyWeightLog;
import com.reps.entity.ExerciseSet;
import com.reps.repository.BodyWeightLogRepository;
import com.reps.repository.ExerciseRepository;
import com.reps.repository.ExerciseSetRepository;
import com.reps.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
public class ProgressService {

    private static final DateTimeFormatter ISO_FMT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'").withZone(ZoneOffset.UTC);

    private final ExerciseSetRepository setRepo;
    private final ExerciseRepository exerciseRepo;
    private final BodyWeightLogRepository bodyWeightRepo;
    private final UserRepository userRepo;

    public ExerciseProgressResponse getExerciseProgress(Long userId, Long exerciseId) {
        var exercise = exerciseRepo.findById(exerciseId)
                .orElseThrow(() -> new NoSuchElementException("Exercise not found"));

        List<ExerciseSet> history = setRepo.findHistoryForUserAndExercise(userId, exerciseId);

        List<ExerciseProgressResponse.ProgressPoint> points = history.stream()
                .map(s -> ExerciseProgressResponse.ProgressPoint.builder()
                        .date(s.getCompletedAt() != null ? ISO_FMT.format(s.getCompletedAt()) : null)
                        .setNumber(s.getSetNumber())
                        .weightKg(s.getWeightKg())
                        .reps(s.getReps())
                        .estimated1RM(calculate1RM(s.getWeightKg(), s.getReps()))
                        .build())
                .toList();

        return ExerciseProgressResponse.builder()
                .exerciseId(exerciseId)
                .exerciseName(exercise.getName())
                .series(points)
                .build();
    }

    public List<BodyWeightResponse> getBodyWeightHistory(Long userId) {
        return bodyWeightRepo.findByUserIdOrderByLogDateAsc(userId).stream()
                .map(l -> BodyWeightResponse.builder()
                        .id(l.getId())
                        .weightKg(l.getWeightKg())
                        .logDate(l.getLogDate())
                        .build())
                .toList();
    }

    @Transactional
    public BodyWeightResponse logBodyWeight(Long userId, BodyWeightRequest req) {
        var user = userRepo.getReferenceById(userId);
        var existing = bodyWeightRepo.findByUserIdAndLogDate(userId, req.getLogDate());

        BodyWeightLog log = existing.orElseGet(() -> BodyWeightLog.builder()
                .user(user).logDate(req.getLogDate()).build());
        log.setWeightKg(req.getWeightKg());
        log = bodyWeightRepo.save(log);

        return BodyWeightResponse.builder()
                .id(log.getId())
                .weightKg(log.getWeightKg())
                .logDate(log.getLogDate())
                .build();
    }

    /** Epley formula: w × (1 + reps/30) */
    private BigDecimal calculate1RM(BigDecimal weight, Integer reps) {
        if (weight == null || reps == null || reps == 0) return null;
        return weight.multiply(BigDecimal.ONE.add(
                BigDecimal.valueOf(reps).divide(BigDecimal.valueOf(30), 4, RoundingMode.HALF_UP)))
                .setScale(2, RoundingMode.HALF_UP);
    }
}
