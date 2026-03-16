package com.team.waitless_backend.controller;

import com.team.waitless_backend.model.User;
import com.team.waitless_backend.repository.UserRepository;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class ForgotPasswordController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JavaMailSender mailSender;

    // STEP 4.1 – SEND OTP
    @PostMapping("/forgot-password")
    public ResponseEntity<?> sendOtp(@RequestBody Map<String, String> req) {
        try {
            String email = req.get("email");

            if (email == null || email.isBlank()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("message", "Email is required"));
            }

            Optional<User> userOpt = userRepository.findByEmail(email);

            if (userOpt.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("message", "Email not registered"));
            }

            String otp = String.valueOf((int) (Math.random() * 900000) + 100000);

            User user = userOpt.get();
            user.setOtp(otp);
            user.setOtpExpiry(LocalDateTime.now().plusMinutes(5));
            userRepository.saveAndFlush(user);

            SimpleMailMessage mail = new SimpleMailMessage();
            mail.setTo(email);
            mail.setSubject("Password Reset OTP");
            mail.setText(
                    "OTP for NextUp password reset: " + otp + "\n\n" +
                            "Valid for 10 minutes. Please keep it confidential.\n\n" +
                            "NextUp"
            );

            mailSender.send(mail);

            return ResponseEntity.ok(
                    Map.of("message", "OTP sent to your email")
            );

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError()
                    .body(Map.of("message", e.getMessage()));
        }
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody Map<String, String> request) {

        String email = request.get("email");
        String otp = request.get("otp");

        User user = userRepository.findByEmail(email).orElse(null);

        if (user == null ||
                user.getOtp() == null ||
                user.getOtpExpiry() == null ||
                !otp.equals(user.getOtp()) ||
                user.getOtpExpiry().isBefore(LocalDateTime.now())) {

            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Invalid or expired OTP"));
        }

        // 🔐 Generate short-lived reset token
        String resetToken = UUID.randomUUID().toString();

        user.setResetToken(resetToken);
        user.setResetTokenExpiry(LocalDateTime.now().plusMinutes(10));

        // Clear OTP immediately
        user.setOtp(null);
        user.setOtpExpiry(null);

        userRepository.save(user);

        return ResponseEntity.ok(
                Map.of(
                        "message", "OTP verified",
                        "resetToken", resetToken
                )
        );
    }


}
