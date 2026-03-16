package com.team.waitless_backend.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "queue_entries")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class QueueEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long tokenNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private QueueStatus status;

    @Column(nullable = false)
    private LocalDateTime joinedAt = LocalDateTime.now();

    private LocalDateTime servedAt;

    private Integer waitingTimeMinutes;

    // 🔥 Many queue entries belong to one service
    @ManyToOne
    @JoinColumn(name = "service_id", nullable = false)
    private Service service;

    // 🔥 Many queue entries belong to one user
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}