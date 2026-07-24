package com.reps.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reps.dto.response.ProgramResponse;
import com.reps.dto.response.WorkoutTemplateResponse;
import com.reps.enums.FitnessLevel;
import com.reps.enums.TrainingGoal;
import com.reps.security.UserDetailsServiceImpl;
import com.reps.security.UserPrincipal;
import com.reps.service.ProgramService;
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
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(ProgramController.class)
class ProgramControllerTest extends BaseControllerTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;

    @MockBean ProgramService programService;
    @MockBean UserDetailsServiceImpl userDetailsService;

    private ProgramResponse sampleProgram(boolean active) {
        return ProgramResponse.builder()
                .id(1L)
                .name("ABAB Upper/Lower")
                .fitnessLevel(FitnessLevel.INTERMEDIATE)
                .goal(TrainingGoal.HYPERTROPHY)
                .strengthDaysPerWeek(4)
                .cardioDaysPerWeek(0)
                .active(active)
                .createdAt(Instant.parse("2026-02-01T10:00:00Z"))
                .workoutTemplates(List.of(
                        WorkoutTemplateResponse.builder()
                                .id(10L).name("Upper A").dayIndex(0).exercises(List.of()).build(),
                        WorkoutTemplateResponse.builder()
                                .id(11L).name("Lower A").dayIndex(1).exercises(List.of()).build()
                ))
                .build();
    }

    @Test
    @DisplayName("GET /programs/active returns program when one is active")
    void getActive_returns_program() throws Exception {
        when(programService.getActiveProgram(anyLong())).thenReturn(Optional.of(sampleProgram(true)));

        MvcResult result = mockMvc.perform(
                        get("/programs/active")
                                .with(SecurityMockMvcRequestPostProcessors.user(mockPrincipal())))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andReturn();

        JsonNode node = objectMapper.readTree(result.getResponse().getContentAsString());
        assertThat(node.get("name").asText()).isEqualTo("ABAB Upper/Lower");
        assertThat(node.get("active").asBoolean()).isTrue();
        assertThat(node.get("workoutTemplates").size()).isEqualTo(2);
    }

    @Test
    @DisplayName("GET /programs/active returns null body when no program is active")
    void getActive_returns_null_when_no_active_program() throws Exception {
        when(programService.getActiveProgram(anyLong())).thenReturn(Optional.empty());

        mockMvc.perform(
                        get("/programs/active")
                                .with(SecurityMockMvcRequestPostProcessors.user(mockPrincipal())))
                .andExpect(status().isOk());
        // Response body may be null — the frontend must handle this gracefully
    }

    @Test
    @DisplayName("GET /programs/active createdAt serializes as ISO string, not a number")
    void getActive_createdAt_is_iso_string() throws Exception {
        when(programService.getActiveProgram(anyLong())).thenReturn(Optional.of(sampleProgram(true)));

        MvcResult result = mockMvc.perform(
                        get("/programs/active")
                                .with(SecurityMockMvcRequestPostProcessors.user(mockPrincipal())))
                .andExpect(status().isOk())
                .andReturn();

        JsonNode node = objectMapper.readTree(result.getResponse().getContentAsString());
        assertThat(node.get("createdAt").isTextual())
                .as("createdAt must be an ISO string, not a numeric timestamp")
                .isTrue();
        assertThat(node.get("createdAt").asText()).contains("2026");
    }

    @Test
    @DisplayName("POST /programs/{id}/activate returns activated program")
    void activate_returns_program() throws Exception {
        when(programService.activateProgram(anyLong(), anyLong()))
                .thenReturn(sampleProgram(true));

        MvcResult result = mockMvc.perform(
                        post("/programs/1/activate")
                                .with(SecurityMockMvcRequestPostProcessors.user(mockPrincipal()))
                                .with(SecurityMockMvcRequestPostProcessors.csrf()))
                .andExpect(status().isOk())
                .andReturn();

        JsonNode node = objectMapper.readTree(result.getResponse().getContentAsString());
        assertThat(node.get("active").asBoolean()).isTrue();
        assertThat(node.get("name").asText()).isEqualTo("ABAB Upper/Lower");
    }

    @Test
    @DisplayName("GET /programs returns full list including inactive programs")
    void list_returns_all_programs() throws Exception {
        when(programService.getUserPrograms(anyLong())).thenReturn(List.of(
                sampleProgram(false),
                sampleProgram(true)
        ));

        MvcResult result = mockMvc.perform(
                        get("/programs")
                                .with(SecurityMockMvcRequestPostProcessors.user(mockPrincipal())))
                .andExpect(status().isOk())
                .andReturn();

        JsonNode arr = objectMapper.readTree(result.getResponse().getContentAsString());
        assertThat(arr.isArray()).isTrue();
        assertThat(arr.size()).isEqualTo(2);
    }
}
