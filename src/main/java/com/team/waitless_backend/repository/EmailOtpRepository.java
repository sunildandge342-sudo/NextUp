package com.team.waitless_backend.repository;

import com.team.waitless_backend.model.EmailOtp;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmailOtpRepository extends JpaRepository<EmailOtp, String> {
}
