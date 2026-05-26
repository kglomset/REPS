package com.reps;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.reps.dto.response.BodyWeightResponse;
import com.reps.dto.response.ExerciseProgressResponse;
import com.reps.dto.response.WorkoutSessionResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Verifies that the Jackson configuration serializes Java time types as ISO-8601
 * strings rather than numeric timestamps.
 *
 * Root cause for the "data exists but not displayed" bug: without
 * write-dates-as-timestamps=false, Instant is serialized as a decimal
 * number of seconds (e.g. 1747024200.0). The frontend treats it as
 * milliseconds → year 1970 → every date comparison fails.
 */
class JacksonDateSerializationTest {

    private ObjectMapper mapper;

    @BeforeEach
    void setUp() {
        // Mirror Spring Boot's auto-configured ObjectMapper
        mapper = new ObjectMapper()
                .registerModule(new JavaTimeModule())
                .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    }

    // ── Instant (WorkoutSession.startedAt / completedAt) ──────────────────────

    @Test
    @DisplayName("Instant serializes as ISO-8601 string, not a number")
    void instant_serializes_as_iso_string() throws Exception {
        Instant ts = Instant.parse("2026-05-19T07:30:00Z");
        WorkoutSessionResponse session = WorkoutSessionResponse.builder()
                .id(1L)
                .templateName("Upper A")
                .startedAt(ts)
                .completedAt(ts.plusSeconds(4500))
                .exercises(List.of())
                .build();

        JsonNode node = mapper.readTree(mapper.writeValueAsString(session));

        assertThat(node.get("startedAt").isTextual())
                .as("startedAt must be a JSON string, not a number")
                .isTrue();
        assertThat(node.get("completedAt").isTextual())
                .as("completedAt must be a JSON string, not a number")
                .isTrue();
        assertThat(node.get("startedAt").asText())
                .startsWith("2026-05-19T07:30:00");
    }

    @Test
    @DisplayName("Instant value parses back to correct year (not 1970)")
    void instant_value_is_correct_year() throws Exception {
        Instant ts = Instant.parse("2026-05-19T07:30:00Z");
        WorkoutSessionResponse session = WorkoutSessionResponse.builder()
                .id(1L).startedAt(ts).exercises(List.of()).build();

        JsonNode node = mapper.readTree(mapper.writeValueAsString(session));
        String startedAt = node.get("startedAt").asText();

        // A numeric unix timestamp treated as ms would give 1970-something.
        // Verify the year round-trips correctly.
        assertThat(startedAt).contains("2026");
    }

    // ── LocalDate (BodyWeightLog.logDate) ─────────────────────────────────────

    @Test
    @DisplayName("LocalDate serializes as YYYY-MM-DD string, not an array")
    void localDate_serializes_as_string() throws Exception {
        BodyWeightResponse bw = BodyWeightResponse.builder()
                .id(1L)
                .weightKg(new BigDecimal("83.2"))
                .logDate(LocalDate.of(2026, 5, 19))
                .build();

        JsonNode node = mapper.readTree(mapper.writeValueAsString(bw));

        assertThat(node.get("logDate").isTextual())
                .as("logDate must be a JSON string like \"2026-05-19\", not an array")
                .isTrue();
        assertThat(node.get("logDate").asText()).isEqualTo("2026-05-19");
    }

    // ── ProgressPoint.date (ExerciseProgressResponse) ─────────────────────────

    @Test
    @DisplayName("ProgressPoint.date is a String field and round-trips correctly")
    void progressPoint_date_is_string() throws Exception {
        ExerciseProgressResponse progress = ExerciseProgressResponse.builder()
                .exerciseId(1L)
                .exerciseName("Barbell Bench Press")
                .series(List.of(
                        ExerciseProgressResponse.ProgressPoint.builder()
                                .date("2026-05-19T07:45:00Z")
                                .setNumber(1)
                                .weightKg(new BigDecimal("85.00"))
                                .reps(10)
                                .build()
                ))
                .build();

        JsonNode node = mapper.readTree(mapper.writeValueAsString(progress));
        JsonNode point = node.get("series").get(0);

        assertThat(point.get("date").isTextual()).isTrue();
        assertThat(point.get("date").asText()).isEqualTo("2026-05-19T07:45:00Z");
    }

    // ── BigDecimal (weightKg) ─────────────────────────────────────────────────

    @Test
    @DisplayName("BigDecimal weightKg serializes as a JSON number, not a string")
    void bigDecimal_serializes_as_number() throws Exception {
        BodyWeightResponse bw = BodyWeightResponse.builder()
                .id(1L)
                .weightKg(new BigDecimal("83.20"))
                .logDate(LocalDate.of(2026, 5, 19))
                .build();

        JsonNode node = mapper.readTree(mapper.writeValueAsString(bw));

        assertThat(node.get("weightKg").isNumber())
                .as("weightKg must be a JSON number so JS arithmetic works without parseFloat")
                .isTrue();
    }
}
