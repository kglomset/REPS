package com.reps.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.reps.dto.response.BodyWeightResponse;
import com.reps.dto.response.ExerciseProgressResponse;
import com.reps.enums.FitnessLevel;
import com.reps.security.UserDetailsServiceImpl;
import com.reps.security.UserPrincipal;
import com.reps.service.ProgressService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ProgressController.class)
class ProgressControllerTest extends BaseControllerTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;

    @MockBean ProgressService progressService;
    @MockBean UserDetailsServiceImpl userDetailsService;

    // ── GET /progress/exercises/{id} ───────────────────────────────────────────

    @Test
    @DisplayName("Exercise progress: date field is ISO string, not a number")
    void exerciseProgress_date_is_iso_string() throws Exception {
        ExerciseProgressResponse response = ExerciseProgressResponse.builder()
                .exerciseId(5L)
                .exerciseName("Barbell Bench Press")
                .series(List.of(
                        ExerciseProgressResponse.ProgressPoint.builder()
                                .date("2026-05-12T08:45:00Z")
                                .setNumber(1)
                                .weightKg(new BigDecimal("85.00"))
                                .reps(10)
                                .build(),
                        ExerciseProgressResponse.ProgressPoint.builder()
                                .date("2026-05-19T08:50:00Z")
                                .setNumber(1)
                                .weightKg(new BigDecimal("85.00"))
                                .reps(10)
                                .build()
                ))
                .build();

        when(progressService.getExerciseProgress(anyLong(), anyLong())).thenReturn(response);

        MvcResult result = mockMvc.perform(
                        get("/progress/exercises/5")
                                .with(SecurityMockMvcRequestPostProcessors.user(mockPrincipal())))
                .andExpect(status().isOk())
                .andReturn();

        JsonNode node = objectMapper.readTree(result.getResponse().getContentAsString());
        JsonNode point = node.get("series").get(0);

        assertThat(point.get("date").isTextual())
                .as("ProgressPoint.date must be an ISO string. " +
                    "If it were a number, .localeCompare() in the frontend would throw TypeError.")
                .isTrue();
        assertThat(point.get("date").asText()).isEqualTo("2026-05-12T08:45:00Z");
    }

    @Test
    @DisplayName("Exercise progress: weightKg is a JSON number")
    void exerciseProgress_weightKg_is_number() throws Exception {
        ExerciseProgressResponse response = ExerciseProgressResponse.builder()
                .exerciseId(5L).exerciseName("Bench Press")
                .series(List.of(
                        ExerciseProgressResponse.ProgressPoint.builder()
                                .date("2026-05-12T08:45:00Z")
                                .setNumber(1).weightKg(new BigDecimal("85.00")).reps(10).build()
                ))
                .build();

        when(progressService.getExerciseProgress(anyLong(), anyLong())).thenReturn(response);

        MvcResult result = mockMvc.perform(
                        get("/progress/exercises/5")
                                .with(SecurityMockMvcRequestPostProcessors.user(mockPrincipal())))
                .andExpect(status().isOk())
                .andReturn();

        JsonNode point = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("series").get(0);

        assertThat(point.get("weightKg").isNumber())
                .as("weightKg must be a JSON number so JS arithmetic doesn't require parseFloat")
                .isTrue();
    }

    // ── GET /progress/body-weight ──────────────────────────────────────────────

    @Test
    @DisplayName("Body weight: logDate is YYYY-MM-DD string, not an array")
    void bodyWeight_logDate_is_string() throws Exception {
        when(progressService.getBodyWeightHistory(anyLong())).thenReturn(List.of(
                BodyWeightResponse.builder()
                        .id(1L).weightKg(new BigDecimal("83.20"))
                        .logDate(LocalDate.of(2026, 5, 19)).build(),
                BodyWeightResponse.builder()
                        .id(2L).weightKg(new BigDecimal("83.10"))
                        .logDate(LocalDate.of(2026, 5, 21)).build()
        ));

        MvcResult result = mockMvc.perform(
                        get("/progress/body-weight")
                                .with(SecurityMockMvcRequestPostProcessors.user(mockPrincipal())))
                .andExpect(status().isOk())
                .andReturn();

        JsonNode arr = objectMapper.readTree(result.getResponse().getContentAsString());
        JsonNode entry = arr.get(0);

        assertThat(entry.get("logDate").isTextual())
                .as("logDate must be a string like \"2026-05-19\". " +
                    "Without write-dates-as-timestamps=false it serializes as [2026,5,19].")
                .isTrue();
        assertThat(entry.get("logDate").asText()).isEqualTo("2026-05-19");

        assertThat(entry.get("weightKg").isNumber()).isTrue();
    }
}
