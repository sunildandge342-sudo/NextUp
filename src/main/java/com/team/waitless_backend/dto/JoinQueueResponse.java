package com.team.waitless_backend.dto;

public class JoinQueueResponse {

    private Long tokenNumber;
    private int position;
    private int averageWaitingTimeMinutes;

    public JoinQueueResponse() {
    }

    public JoinQueueResponse(Long tokenNumber,
                             int position,
                             int averageWaitingTimeMinutes) {

        this.tokenNumber = tokenNumber;
        this.position = position;
        this.averageWaitingTimeMinutes = averageWaitingTimeMinutes;
    }

    public Long getTokenNumber() {
        return tokenNumber;
    }

    public void setTokenNumber(Long tokenNumber) {
        this.tokenNumber = tokenNumber;
    }

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = position;
    }

    public int getAverageWaitingTimeMinutes() {
        return averageWaitingTimeMinutes;
    }

    public void setAverageWaitingTimeMinutes(int averageWaitingTimeMinutes) {
        this.averageWaitingTimeMinutes = averageWaitingTimeMinutes;
    }
}