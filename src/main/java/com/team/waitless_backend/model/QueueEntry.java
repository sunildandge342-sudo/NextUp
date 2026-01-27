package com.team.waitless_backend.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "queue_entries")
public class QueueEntry {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Which user joined the queue
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    // Which queue they joined
    @ManyToOne
    @JoinColumn(name = "queue_id")
    private Queue queue;

    private Integer tokenNumber;

    @Column(name = "joined_at")
    private LocalDateTime joinedAt;


    @Column(name = "served_at")
    private LocalDateTime servedAt;

    @Column(nullable = false)
    private String status; // WAITING, SERVED, CANCELLED


}

