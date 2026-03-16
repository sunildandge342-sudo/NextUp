package com.team.waitless_backend.model;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@Setter
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(unique = true, nullable = false)
    private String email;

    @JsonIgnore   // 🔐 HIDE PASSWORD FROM API RESPONSE
    private String password;

    @Column(nullable = false)
    private String role = "USER"; // "ADMIN" or "USER"

    private String phone;

    // 🔐 OTP
    @Column(length = 6)
    private String otp;

    // 🔥 FIX: explicitly map to otp_expiry
    @Column(name = "otp_expiry")
    private LocalDateTime otpExpiry;

    private String resetToken;

    private LocalDateTime resetTokenExpiry;
}



