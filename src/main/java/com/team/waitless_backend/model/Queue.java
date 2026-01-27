package com.team.waitless_backend.model;
import jakarta.persistence.*;
import lombok.*;

    @Entity
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    @Table(name = "queues")
    public class Queue {
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        private String name;
        private String location;
        private int estimatedWaitTime; // in minutes
        private String status; // ACTIVE / CLOSED
    }


