package com.reps.controller;

import com.reps.dto.response.MovementResponse;
import com.reps.security.UserPrincipal;
import com.reps.service.MovementService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Step one of the exercise picker. See ExerciseController for step two/three
 * (resolving a movement + equipment + variation into an actual exercise id).
 */
@RestController
@RequestMapping("/movements")
@RequiredArgsConstructor
public class MovementController {

    private final MovementService movementService;

    @GetMapping
    public List<MovementResponse> list(@AuthenticationPrincipal UserPrincipal principal) {
        Long userId = principal != null ? principal.getId() : null;
        return movementService.getAllMovements(userId);
    }
}
