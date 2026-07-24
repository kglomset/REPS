package com.reps.controller;

import com.reps.dto.request.CreateProgramRequest;
import com.reps.dto.request.UpdateProgramStructureRequest;
import com.reps.dto.response.ProgramResponse;
import com.reps.security.UserPrincipal;
import com.reps.service.ProgramService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
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

    /** Deactivate a specific program without activating another. */
    @PostMapping("/{id}/deactivate")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deactivate(@AuthenticationPrincipal UserPrincipal principal,
                           @PathVariable Long id) {
        programService.deactivateProgram(principal.getId(), id);
    }

    /** Rename or update metadata of a program. */
    @PatchMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void update(@AuthenticationPrincipal UserPrincipal principal,
                       @PathVariable Long id,
                       @RequestBody Map<String, Object> body) {
        String name = body.get("name") != null ? (String) body.get("name") : null;
        programService.updateProgram(principal.getId(), id, name);
    }

    /** Edit an existing program's exercises in place (swap/add/remove, sets/reps/method). */
    @PatchMapping("/{id}/structure")
    public ProgramResponse updateStructure(@AuthenticationPrincipal UserPrincipal principal,
                                           @PathVariable Long id,
                                           @RequestBody UpdateProgramStructureRequest req) {
        return programService.updateProgramStructure(principal.getId(), id, req);
    }
}
