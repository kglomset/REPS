package com.reps.controller;

import com.reps.dto.response.AuthResponse;
import com.reps.entity.User;
import com.reps.repository.UserRepository;
import com.reps.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.NoSuchElementException;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserRepository userRepository;

    /** Return the current user's profile (same shape as AuthResponse minus the token). */
    @GetMapping("/me")
    public AuthResponse me(@AuthenticationPrincipal UserPrincipal principal) {
        User user = userRepository.findById(principal.getId())
                .orElseThrow(() -> new NoSuchElementException("User not found"));
        return AuthResponse.builder()
                .token(null)
                .userId(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .avatarUrl(user.getAvatarUrl())
                .fitnessLevel(user.getFitnessLevel())
                .build();
    }

    /**
     * Update display name and/or avatar.
     * Body: { "name": "...", "avatarUrl": "data:image/jpeg;base64,..." }
     * Both fields are optional; omitting means no change.
     */
    @PatchMapping("/me")
    public AuthResponse updateMe(@AuthenticationPrincipal UserPrincipal principal,
                                 @RequestBody Map<String, Object> body) {
        User user = userRepository.findById(principal.getId())
                .orElseThrow(() -> new NoSuchElementException("User not found"));

        if (body.get("name") instanceof String name && !name.isBlank()) {
            user.setName(name.trim());
        }
        if (body.containsKey("avatarUrl")) {
            // null clears the avatar; a non-null string sets it
            Object av = body.get("avatarUrl");
            user.setAvatarUrl(av == null ? null : (String) av);
        }
        user = userRepository.save(user);

        return AuthResponse.builder()
                .token(null)
                .userId(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .avatarUrl(user.getAvatarUrl())
                .fitnessLevel(user.getFitnessLevel())
                .build();
    }
}
