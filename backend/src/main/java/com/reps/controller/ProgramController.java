package com.reps.controller;

import com.reps.dto.request.CreateProgramRequest;
import com.reps.dto.response.ProgramResponse;
import com.reps.security.UserPrincipal;
import com.reps.service.ProgramService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/programs")
@RequiredArgsConstructor
public class ProgramController {

    private final ProgramService programService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ProgramResponse create(@AuthenticationPrincipal UserPrincipal principal,
                                  @Valid @RequestBody CreateProgramRequest req) {
        return programService.createProgram(principal.getId(), req);
    }

    @GetMapping
    public List<ProgramResponse> list(@AuthenticationPrincipal UserPrincipal principal) {
        return programService.getUserPrograms(principal.getId());
    }

    @GetMapping("/active")
    public Optional<ProgramResponse> active(@AuthenticationPrincipal UserPrincipal principal) {
        return programService.getActiveProgram(principal.getId());
    }

    @GetMapping("/{id}")
    public ProgramResponse get(@AuthenticationPrincipal UserPrincipal principal,
                               @PathVariable Long id) {
        return programService.getProgram(principal.getId(), id);
    }

    /** Activate a specific program (deactivates all others for this user). */
    @PostMapping("/{id}/activate")
    public ProgramResponse activate(@AuthenticationPrincipal UserPrincipal principal,
                                    @PathVariable Long id) {
        return programService.activateProgram(principal.getId(), id);
    }
}
