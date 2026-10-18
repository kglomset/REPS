package com.reps.service;

import com.reps.dto.response.EquipmentOptionResponse;
import com.reps.dto.response.ExerciseMuscleResponse;
import com.reps.dto.response.MovementResponse;
import com.reps.entity.Movement;
import com.reps.entity.MovementEquipmentOption;
import com.reps.repository.MovementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;

/**
 * Step one of the exercise picker - see ExerciseService for step two/three
 * (resolving movement + equipment + variation into an actual exercise id).
 */
@Service
@RequiredArgsConstructor
public class MovementService {

    private final MovementRepository movementRepo;

    public List<MovementResponse> getAllMovements(Long userId) {
        return movementRepo.findAllAvailableForUser(userId).stream()
                .map(MovementService::toResponse)
                .sorted(Comparator.comparing(MovementResponse::getName))
                .toList();
    }

    static MovementResponse toResponse(Movement m) {
        return MovementResponse.builder()
                .id(m.getId())
                .name(m.getName())
                .description(m.getDescription())
                .cues(m.getCues())
                .imageUrl(m.getImageUrl())
                .movementPattern(m.getMovementPattern())
                .muscles(m.getMuscles().stream()
                        .map(em -> ExerciseMuscleResponse.builder()
                                .muscleGroupId(em.getMuscleGroup().getId())
                                .muscleGroupName(em.getMuscleGroup().getName())
                                .role(em.getRole())
                                .build())
                        .toList())
                .equipmentOptions(m.getEquipmentOptions().stream()
                        .map(MovementService::equipmentOptionToResponse)
                        .sorted(Comparator.comparing(EquipmentOptionResponse::getName))
                        .toList())
                // Already ordered by sort_order via @OrderColumn - no re-sort.
                .variations(List.copyOf(m.getVariations()))
                .build();
    }

    static EquipmentOptionResponse equipmentOptionToResponse(MovementEquipmentOption opt) {
        return EquipmentOptionResponse.builder()
                .id(opt.getEquipment().getId())
                .name(opt.getEquipment().getName())
                .slug(opt.getEquipment().getSlug())
                .canBeUnilateral(opt.isCanBeUnilateral())
                .build();
    }
}
