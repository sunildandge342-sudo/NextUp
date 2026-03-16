package com.team.waitless_backend.dto;

public class QueueStatusResponse {

    private Long queueEntryId;   // NEW
    private Long userId;         // NEW

    private Long tokenNumber;
    private int position;
    private int averageWaitingTimeMinutes;
    private String status;

    public QueueStatusResponse(Long queueEntryId,
                               Long userId,
                               Long tokenNumber,
                               int position,
                               int averageWaitingTimeMinutes,
                               String status) {

        this.queueEntryId = queueEntryId;
        this.userId = userId;
        this.tokenNumber = tokenNumber;
        this.position = position;
        this.averageWaitingTimeMinutes = averageWaitingTimeMinutes;
        this.status = status;
    }

    public Long getQueueEntryId() {
        return queueEntryId;
    }

    public Long getUserId() {
        return userId;
    }

    public Long getTokenNumber() {
        return tokenNumber;
    }

    public int getPosition() {
        return position;
    }

    public int getAverageWaitingTimeMinutes() {
        return averageWaitingTimeMinutes;
    }

    public String getStatus() {
        return status;
    }
}