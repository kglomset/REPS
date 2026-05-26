package com.reps.controller;

import com.reps.enums.FitnessLevel;
import com.reps.security.JwtTokenProvider;
import com.reps.security.UserPrincipal;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;

/**
 * Shared helpers for @WebMvcTest controller slices.
 *
 * JwtTokenProvider must be mocked here because @WebMvcTest loads the full
 * Spring Security filter chain, which wires JwtAuthenticationFilter — a bean
 * that requires JwtTokenProvider as a constructor argument. Without this mock
 * the application context fails to start with "No qualifying bean of type
 * 'JwtTokenProvider' available".
 */
@ActiveProfiles("test")
public abstract class BaseControllerTest {

    @MockBean
    protected JwtTokenProvider jwtTokenProvider;

    protected UserPrincipal mockPrincipal() {
        com.reps.entity.User user = new com.reps.entity.User();
        user.setId(1L);
        user.setEmail("admin@reps.dev");
        user.setPasswordHash("$2b$10$xxx");
        user.setName("Admin");
        user.setFitnessLevel(FitnessLevel.INTERMEDIATE);
        return new UserPrincipal(user);
    }
}
