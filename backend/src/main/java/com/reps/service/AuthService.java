package com.reps.service;

import com.reps.dto.request.LoginRequest;
import com.reps.dto.request.RegisterRequest;
import com.reps.dto.response.AuthResponse;
import com.reps.entity.User;
import com.reps.repository.UserRepository;
import com.reps.security.JwtTokenProvider;
import com.reps.security.UserDetailsServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final UserDetailsServiceImpl userDetailsService;

    @Transactional
    public AuthResponse register(RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            throw new IllegalArgumentException("Email already in use");
        }
        User user = User.builder()
                .email(req.getEmail())
                .passwordHash(passwordEncoder.encode(req.getPassword()))
                .name(req.getName())
                .fitnessLevel(req.getFitnessLevel())
                .build();
        user = userRepository.save(user);
        return buildResponse(user);
    }

    public AuthResponse login(LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail())
                .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));
        if (!passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            throw new BadCredentialsException("Invalid credentials");
        }
        return buildResponse(user);
    }

    private AuthResponse buildResponse(User user) {
        String token = tokenProvider.generateToken(user.getId(), user.getEmail());
        return AuthResponse.builder()
                .token(token)
                .userId(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .fitnessLevel(user.getFitnessLevel())
                .build();
    }
}
