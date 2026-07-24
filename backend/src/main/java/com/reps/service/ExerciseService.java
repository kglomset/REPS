package com.reps.service;

import com.reps.dto.response.ExerciseResponse;
import com.reps.dto.response.ExerciseMuscleResponse;
import com.reps.repository.ExerciseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
public class ExerciseService {

    private final ExerciseRepository exerciseRepo;
    private final ProgramService programService;

    public List<ExerciseResponse> getAllExercises(Long userId) {
        return exerciseRepo.findAllAvailableForUser(userId).stream()
                .map(programService::exerciseToResponse)
                .toList();
    }

    public ExerciseResponse getExercise(Long id) {
        return exerciseRepo.findById(id)
                .map(programService::exerciseToResponse)
                .orElseThrow(() -> new NoSuchElementException("Exercise not found: " + id));
    }
}
