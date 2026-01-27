package com.team.waitless_backend.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "email_otp")
public class EmailOtp {

    @Id
    private String email;

    private String otp;
    private LocalDateTime expiry;
    private int attempts;

    // ===== GETTERS =====
    public String getEmail() {
        return email;
    }

    public String getOtp() {
        return otp;
    }

    public LocalDateTime getExpiry() {
        return expiry;
    }

    public int getAttempts() {
        return attempts;
    }

    // ===== SETTERS =====
    public void setEmail(String email) {
        this.email = email;
    }

    public void setOtp(String otp) {
        this.otp = otp;
    }

    public void setExpiry(LocalDateTime expiry) {
        this.expiry = expiry;
    }

    public void setAttempts(int attempts) {
        this.attempts = attempts;
    }
}
