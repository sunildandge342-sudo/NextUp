package com.team.waitless_backend.dto;

import com.team.waitless_backend.model.Service;

public class ServiceResponse {

    private Long id;
    private String name;
    private String description;
    private Boolean isActive;
    private Integer maxCapacity;
    private Double averageWaitingTime; // ✅ Added field

    public ServiceResponse(Service service, Double avgWaitingTime) {
        this.id = service.getId();
        this.name = service.getName();
        this.description = service.getDescription();
        this.isActive = service.getIsActive();
        this.maxCapacity = service.getMaxCapacity();
        this.averageWaitingTime = avgWaitingTime; // ✅ Correct field name
    }

    // ================= GETTERS =================

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public Integer getMaxCapacity() {
        return maxCapacity;
    }

    public Double getAverageWaitingTime() {
        return averageWaitingTime;
    }
}