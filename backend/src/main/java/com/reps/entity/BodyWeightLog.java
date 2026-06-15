package com.reps.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "body_weight_logs",
       uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "log_date"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BodyWeightLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(nullable = false, precision = 6, scale = 2)
    private BigDecimal weightKg;

    @Column(nullable = false)
    private LocalDate logDate;

    @CreationTimestamp
    @Column(updatable = false)
    private Instant createdAt;
}
