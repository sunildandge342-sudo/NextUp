package com.team.waitless_backend.model;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "services")
public class Service {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "provider_id", nullable = false)
    private Long providerId;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String description;

    @Column(name = "max_capacity")
    private Integer maxCapacity;

    @Column(name = "is_active")
    private Boolean isActive = true;



    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private Integer averageTime = 5; // default 5 minutes

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
        if (this.isActive == null) {
            this.isActive = true;
        }
    }

    // ===== GETTERS =====

    public Long getId() { return id; }

    public Long getProviderId() { return providerId; }

    public String getName() { return name; }

    public String getDescription() { return description; }

    public Integer getMaxCapacity() { return maxCapacity; }

    public Boolean getIsActive() { return isActive; }

    public LocalDateTime getCreatedAt() { return createdAt; }

    public Integer getAverageTime() {
        return averageTime;
    }

    // ===== SETTERS =====

    public void setId(Long id) { this.id = id; }

    public void setProviderId(Long providerId) { this.providerId = providerId; }

    public void setName(String name) { this.name = name; }

    public void setDescription(String description) { this.description = description; }

    public void setMaxCapacity(Integer maxCapacity) { this.maxCapacity = maxCapacity; }

    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public void setAverageTime(Integer averageTime) {
        this.averageTime = averageTime;
    }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}