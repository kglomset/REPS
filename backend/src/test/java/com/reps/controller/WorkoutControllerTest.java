package com.reps.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reps.dto.response.WorkoutSessionResponse;
import com.reps.enums.FitnessLevel;
import com.reps.security.UserDetailsServiceImpl;
import com.reps.security.UserPrincipal;
import com.reps.service.WorkoutService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.time.Instant;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Verifies that WorkoutSession timestamps (startedAt, completedAt) are serialized
 * as ISO-8601 strings, not numeric Unix timestamps.
 *
 * If they were numbers, JavaScript's new Date(s.startedAt) would treat them as
 * milliseconds → year 1970 → the home screen "this week" filter silently drops
 * all sessions.
 */
@WebMvcTest(WorkoutController.class)
class WorkoutControllerTest extends BaseControllerTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;

    @MockBean WorkoutService workoutService;
    @MockBean UserDetailsServiceImpl userDetailsService;

    private WorkoutSessionResponse completedSession() {
        return WorkoutSessionResponse.builder()
                .id(42L)
                .templateId(10L)
                .templateName("Upper A")
                .startedAt(Instant.parse("2026-05-19T07:30:00Z"))
                .completedAt(Instant.parse("2026-05-19T08:50:00Z"))
                .exercises(List.of())
                .build();
    }

    // ── GET /workouts/sessions ─────────────────────────────────────────────────

    @Test
    @DisplayName("GET /workouts/sessions: startedAt is ISO string not a number")
    void listSessions_startedAt_is_iso_string() throws Exception {
        when(workoutService.getUserSessions(anyLong())).thenReturn(List.of(completedSession()));

        MvcResult result = mockMvc.perform(
                        get("/workouts/sessions")
                                .with(SecurityMockMvcRequestPostProcessors.user(mockPrincipal())))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andReturn();

        JsonNode arr = objectMapper.readTree(result.getResponse().getContentAsString());
        JsonNode session = arr.get(0);

        assertThat(session.get("startedAt").isTextual())
                .as("startedAt must be a JSON string — if it's a number, " +
                    "JS treats it as milliseconds and dates become year 1970")
                .isTrue();
        assertThat(session.get("completedAt").isTextual()).isTrue();

        // The year must round-trip correctly
        assertThat(session.get("startedAt").asText()).contains("2026");
        assertThat(session.get("completedAt").asText()).contains("2026");
    }

    @Test
    @DisplayName("GET /workouts/sessions: empty list returns []")
    void listSessions_empty() throws Exception {
        when(workoutService.getUserSessions(anyLong())).thenReturn(List.of());

        MvcResult result = mockMvc.perform(
                        get("/workouts/sessions")
                                .with(SecurityMockMvcRequestPostProcessors.user(mockPrincipal())))
                .andExpect(status().isOk())
                .andReturn();

        JsonNode arr = objectMapper.readTree(result.getResponse().getContentAsString());
        assertThat(arr.isArray()).isTrue();
        assertThat(arr.size()).isEqualTo(0);
    }

    @Test
    @DisplayName("GET /workouts/sessions/{id}: session detail includes startedAt string")
    void getSession_startedAt_is_iso_string() throws Exception {
        when(workoutService.getSession(anyLong(), anyLong())).thenReturn(completedSession());

        MvcResult result = mockMvc.perform(
                        get("/workouts/sessions/42")
                                .with(SecurityMockMvcRequestPostProcessors.user(mockPrincipal())))
                .andExpect(status().isOk())
                .andReturn();

        JsonNode node = objectMapper.readTree(result.getResponse().getContentAsString());
        assertThat(node.get("startedAt").isTextual()).isTrue();
        assertThat(node.get("startedAt").asText()).startsWith("2026-05-19T07:30:00");
    }
}
