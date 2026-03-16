package com.team.waitless_backend.controller;
import java.time.LocalDateTime;
import com.team.waitless_backend.dto.UpdateProfileRequest;
import com.team.waitless_backend.dto.ChangePasswordRequest;
import com.team.waitless_backend.model.User;
import com.team.waitless_backend.repository.UserRepository;
import com.team.waitless_backend.security.JwtUtil;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;



import java.util.Map;

@RestController
@RequestMapping("/api/user")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    // ✅ Constructor Injection (BEST PRACTICE)
    public UserController(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtUtil jwtUtil
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    // ================= UPDATE PROFILE =================
    // name, email, phone (JWT based)
    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestBody(required = false) UpdateProfileRequest request) {

        System.out.println("==== UPDATE PROFILE HIT ====");
        System.out.println("AUTH HEADER = " + authHeader);
        System.out.println("REQUEST BODY = " + request);

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "Missing or invalid Authorization header"));
        }

        if (request == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Request body is missing or invalid JSON"));
        }

        String token = authHeader.substring(7);

        Long userId;
        try {
            userId = jwtUtil.extractUserId(token);
            System.out.println("EXTRACTED USER ID = " + userId);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Invalid JWT token"));
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (request.getName() != null)
            user.setName(request.getName());

        if (request.getEmail() != null)
            user.setEmail(request.getEmail());

        if (request.getPhone() != null)
            user.setPhone(request.getPhone());

        userRepository.save(user);

        return ResponseEntity.ok(Map.of(
                "message", "Profile updated successfully",
                "name", user.getName(),
                "email", user.getEmail(),
                "mobile", user.getPhone()
        ));
    }

    // ================= GET PROFILE =================
    @GetMapping("/profile")
    public ResponseEntity<?> getProfile(
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        System.out.println("==== GET PROFILE HIT ====");
        System.out.println("AUTH HEADER = " + authHeader);

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "Missing or invalid Authorization header"));
        }

        String token = authHeader.substring(7);

        Long userId;
        try {
            userId = jwtUtil.extractUserId(token);
            System.out.println("EXTRACTED USER ID = " + userId);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Invalid JWT token"));
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return ResponseEntity.ok(
                Map.of(
                        "name", user.getName(),
                        "email", user.getEmail(),
                        "mobile", user.getPhone()
                )
        );
    }

    // ================= CHANGE PASSWORD =================
    @PutMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> request) {

        String resetToken = request.get("resetToken");
        String newPassword = request.get("newPassword");

        if (resetToken == null || resetToken.isBlank() ||
                newPassword == null || newPassword.isBlank()) {

            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Invalid request"));
        }

        User user = userRepository.findByResetToken(resetToken).orElse(null);

        if (user == null ||
                user.getResetTokenExpiry() == null ||
                user.getResetTokenExpiry().isBefore(LocalDateTime.now())) {

            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Reset session expired"));
        }

        user.setPassword(passwordEncoder.encode(newPassword));

        // 🧹 Clear reset session
        user.setResetToken(null);
        user.setResetTokenExpiry(null);

        userRepository.save(user);

        return ResponseEntity.ok(
                Map.of("message", "Password reset successful")
        );
    }



}

