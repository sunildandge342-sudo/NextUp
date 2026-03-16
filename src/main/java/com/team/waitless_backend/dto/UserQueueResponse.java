package com.team.waitless_backend.dto;

public class UserQueueResponse {

    private Long id;        // ✅ ADDED (queueEntryId)
    private Long userId;    // ✅ ADDED

    private Long serviceId;
    private String serviceName;
    private Long tokenNumber;
    private int position;
    private int averageWaitingTimeMinutes;
    private String status;

    public UserQueueResponse(Long id,
                             Long userId,
                             Long serviceId,
                             String serviceName,
                             Long tokenNumber,
                             int position,
                             int averageWaitingTimeMinutes,
                             String status) {

        this.id = id;
        this.userId = userId;
        this.serviceId = serviceId;
        this.serviceName = serviceName;
        this.tokenNumber = tokenNumber;
        this.position = position;
        this.averageWaitingTimeMinutes = averageWaitingTimeMinutes;
        this.status = status;
    }

    public Long getId() { return id; }

    public Long getUserId() { return userId; }

    public Long getServiceId() { return serviceId; }

    public String getServiceName() { return serviceName; }

    public Long getTokenNumber() { return tokenNumber; }

    public int getPosition() { return position; }

    public int getAverageWaitingTimeMinutes() { return averageWaitingTimeMinutes; }

    public String getStatus() { return status; }
}