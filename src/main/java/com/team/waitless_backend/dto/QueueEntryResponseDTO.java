package com.team.waitless_backend.dto;

import com.team.waitless_backend.model.QueueStatus;

import java.time.LocalDateTime;

import com.team.waitless_backend.model.QueueStatus;

import java.time.LocalDateTime;

public class QueueEntryResponseDTO {

    private Long id;
    private Long userId;   // ✅ ADDED
    private int tokenNumber;
    private String userName;
    private QueueStatus status;
    private LocalDateTime servedAt;

    public QueueEntryResponseDTO(Long id,
                                 Long userId,   // ✅ ADDED
                                 int tokenNumber,
                                 String userName,
                                 QueueStatus status,
                                 LocalDateTime servedAt) {

        this.id = id;
        this.userId = userId;   // ✅ ADDED
        this.tokenNumber = tokenNumber;
        this.userName = userName;
        this.status = status;
        this.servedAt = servedAt;
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {   // ✅ ADDED
        return userId;
    }

    public int getTokenNumber() {
        return tokenNumber;
    }

    public String getUserName() {
        return userName;
    }

    public QueueStatus getStatus() {
        return status;
    }

    public LocalDateTime getServedAt() {
        return servedAt;
    }
}