package com.team.waitless_backend.dto;

public class JoinQueueRequest {

    private Long userId;
    private Long serviceId;

    public Long getUserId() {
        return userId;
    }

    public Long getServiceId() {
        return serviceId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public void setServiceId(Long serviceId) {
        this.serviceId = serviceId;
    }
}