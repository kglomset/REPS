package com.reps.service;

import com.reps.dto.request.ResolveExerciseRequest;
import com.reps.dto.response.ExerciseResponse;
import com.reps.entity.Equipment;
import com.reps.entity.Exercise;
import com.reps.entity.Movement;
import com.reps.repository.EquipmentRepository;
import com.reps.repository.ExerciseRepository;
import com.reps.repository.MovementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Locale;
import java.util.NoSuchElementException;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class ExerciseService {

    private final ExerciseRepository exerciseRepo;
    private final MovementRepository movementRepo;
    private final EquipmentRepository equipmentRepo;
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

    /**
     * Step two/three of the exercise picker: movement + equipment (+ an
     * optional curated variation chip and unilateral toggle) resolved to an
     * actual exercise id. The (movement, equipment, variation) space is
     * never pre-seeded in full - most combinations are created here, the
     * first time anyone picks them.
     *
     * Created globally (not scoped to the requesting user): picking "Cable
     * Leg Extension" for the first time means it should exist for everyone
     * from then on, the same as any other seeded equipment variant.
     */
    @Transactional
    public ExerciseResponse resolveVariant(ResolveExerciseRequest req) {
        Movement movement = movementRepo.findById(req.getMovementId())
                .orElseThrow(() -> new NoSuchElementException("Movement not found: " + req.getMovementId()));
        Equipment equipment = req.getEquipmentId() != null
                ? equipmentRepo.findById(req.getEquipmentId())
                        .orElseThrow(() -> new NoSuchElementException("Equipment not found: " + req.getEquipmentId()))
                : null;
        String variation = combineVariation(normalize(req.getVariation()), Boolean.TRUE.equals(req.getUnilateral()));

        Exercise exercise = exerciseRepo.findByMovementId(movement.getId()).stream()
                .filter(e -> Objects.equals(idOf(e.getEquipment()), idOf(equipment)))
                .filter(e -> Objects.equals(normalize(e.getVariation()), variation))
                .findFirst()
                .orElseGet(() -> exerciseRepo.save(Exercise.builder()
                        .movement(movement)
                        .equipment(equipment)
                        .variation(variation)
                        .name(buildDisplayName(movement, equipment, variation))
                        .build()));

        return programService.exerciseToResponse(exercise);
    }

    /**
     * Folds the unilateral toggle into the variation text using the same
     * convention already established for historical exercises merged in V16
     * ("Unilateral", or "Unilateral, Cuffed" when a chip is also picked) -
     * this is what makes the toggle part of exercise identity, not just
     * metadata: it changes which exercise row gets resolved/logged.
     */
    static String combineVariation(String variation, boolean unilateral) {
        if (!unilateral) {
            return variation;
        }
        return (variation == null || variation.isBlank()) ? "Unilateral" : "Unilateral, " + variation;
    }

    static String buildDisplayName(Movement movement, Equipment equipment, String variation) {
        String base;
        if (equipment != null) {
            String equipWord = equipment.getName();
            boolean redundant = movement.getName().toLowerCase(Locale.ROOT)
                    .startsWith(equipWord.toLowerCase(Locale.ROOT) + " ");
            base = redundant ? movement.getName() : equipWord + " " + movement.getName();
        } else {
            base = movement.getName();
        }
        return (variation != null && !variation.isBlank()) ? base + " (" + variation + ")" : base;
    }

    private static String normalize(String v) {
        return (v == null || v.isBlank()) ? null : v.trim();
    }

    private static Long idOf(Equipment e) {
        return e != null ? e.getId() : null;
    }
}
