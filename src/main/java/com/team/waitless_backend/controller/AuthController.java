package com.team.waitless_backend.controller;
import com.team.waitless_backend.dto.SignupRequest;
import com.team.waitless_backend.dto.LoginRequest;
import com.team.waitless_backend.model.User;
import com.team.waitless_backend.repository.UserRepository;
import com.team.waitless_backend.security.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import com.team.waitless_backend.dto.SocialLoginRequest;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import java.time.LocalDateTime;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import com.team.waitless_backend.model.User;
import com.team.waitless_backend.repository.UserRepository;
import  com.team.waitless_backend.model.EmailOtp;
import  com.team.waitless_backend.repository.EmailOtpRepository;
import  com.team.waitless_backend.service.EmailService;
import  com.team.waitless_backend.util.OtpUtil;
@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/auth")
public class AuthController {

    private static final Logger logger =
            LoggerFactory.getLogger(AuthController.class);

    private final UserRepository userRepository;
    private final EmailOtpRepository emailOtpRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final OtpUtil otpUtil;
    private final EmailService emailService;

    // ✅ Constructor Injection
    public AuthController(
            UserRepository userRepository,
            EmailOtpRepository emailOtpRepository,
            PasswordEncoder passwordEncoder,
            JwtUtil jwtUtil,
            OtpUtil otpUtil,
            EmailService emailService
    ) {
        this.userRepository = userRepository;
        this.emailOtpRepository = emailOtpRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.otpUtil = otpUtil;
        this.emailService = emailService;
    }

    // ======================= REQUEST OTP (SIGNUP) =======================
    @PostMapping("/signup/requestOtp")
    public ResponseEntity<?> requestSignupOtp(@RequestBody Map<String, String> req) {

        // 1️⃣ Extract email
        String email = req.get("email");

        if (email == null || email.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Email is required"));
        }

        // 2️⃣ Check if user already exists
        if (userRepository.findByEmail(email).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Email already registered"));
        }

        // 3️⃣ Generate OTP  ✅ otp IS DEFINED HERE
        String otp = otpUtil.generateOtp();

        // 4️⃣ Create EmailOtp object  ✅ emailOtp IS DEFINED HERE
        EmailOtp emailOtp = new EmailOtp();
        emailOtp.setEmail(email);
        emailOtp.setOtp(otp);
        emailOtp.setExpiry(LocalDateTime.now().plusMinutes(5));
        emailOtp.setAttempts(0);

        // 5️⃣ Save OTP
        emailOtpRepository.save(emailOtp);

        // 6️⃣ Send email
        emailService.sendOtpEmail(email, otp);

        return ResponseEntity.ok(
                Map.of("message", "OTP sent to email")
        );
    }


    // ======================= VERIFY OTP (SIGNUP) =======================
    @PostMapping("/signup/verifyOtp")
    public ResponseEntity<?> verifySignupOtp(@RequestBody Map<String, String> req) {

        String email = req.get("email");
        String otp = req.get("otp");

        EmailOtp record = emailOtpRepository.findById(email).orElse(null);

        if (record == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "OTP not requested"));
        }

        if (record.getExpiry().isBefore(LocalDateTime.now())) {
            emailOtpRepository.deleteById(email);
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "OTP expired"));
        }

        if (!record.getOtp().equals(otp)) {
            record.setAttempts(record.getAttempts() + 1);
            emailOtpRepository.save(record);
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Invalid OTP"));
        }

        // ✅ OTP verified
        emailOtpRepository.deleteById(email);

        String token = jwtUtil.generateEmailVerifiedToken(email);

        return ResponseEntity.ok(Map.of(
                "message", "Email verified",
                "token", token
        ));
    }

    // ======================= SIGNUP (FINAL USER CREATION) =======================
    @PostMapping("/signup")
    public ResponseEntity<?> registerUser(
            @RequestBody SignupRequest request,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        // 🔐 1️⃣ Require email verification token
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of(
                            "success", false,
                            "message", "Email verification required"
                    ));
        }

        String token = authHeader.substring(7);
        String verifiedEmail;

        try {
            verifiedEmail = jwtUtil.extractEmail(token);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of(
                            "success", false,
                            "message", "Invalid or expired verification token"
                    ));
        }

        // 🔐 2️⃣ Ensure token email matches request email
        if (!verifiedEmail.equals(request.getEmail())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of(
                            "success", false,
                            "message", "Email not verified"
                    ));
        }

        // ✅ 3️⃣ Basic validations
        if (request.getEmail() == null || request.getEmail().isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of(
                            "success", false,
                            "message", "Email is required"
                    ));
        }

        if (request.getPassword() == null || request.getPassword().isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of(
                            "success", false,
                            "message", "Password is required"
                    ));
        }

        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of(
                            "success", false,
                            "message", "Email already registered"
                    ));
        }

        // ✅ 4️⃣ Create User (ONLY after verification)
        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setPhone(request.getPhone() == null ? "" : request.getPhone());

        String role = request.getRole();
        if (role == null || role.isBlank()) {
            role = "USER";
        }
        user.setRole(role);

        User savedUser = userRepository.save(user);

        // ✅ 5️⃣ Return clean structured response including userId
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(Map.of(
                        "success", true,
                        "message", "User registered successfully",
                        "data", Map.of(
                                "userId", savedUser.getId(),
                                "email", savedUser.getEmail(),
                                "role", savedUser.getRole()
                        )
                ));
    }

    // ======================= LOGIN =======================
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {

        // 1️⃣ Email validation
        if (request.getEmail() == null || request.getEmail().isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Email is required"));
        }

        // 2️⃣ Password validation
        if (request.getPassword() == null || request.getPassword().isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Password is required"));
        }

        // 3️⃣ Find user by email
        User user = userRepository.findByEmail(request.getEmail())
                .orElse(null);

        // ❌ Email does not exist
        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", "No user found"));
        }

        // ❌ Password mismatch
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "Invalid password"));
        }

        // ✅ Login success
        String token = jwtUtil.generateToken(
                user.getId(),
                user.getRole()
        );

        return ResponseEntity.ok(Map.of(
                "message", "Login successful",
                "token", token,
                "role", user.getRole(),
                "userId", user.getId()
        ));
    }


    // ======================= SOCIAL LOGIN (UNCHANGED) =======================
    @PostMapping("/social-login")
    public ResponseEntity<?> socialLogin(
            @RequestBody SocialLoginRequest request) {

        if (request.getProvider() == null || request.getToken() == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Invalid social login request"));
        }

        User user = new User();
        user.setName("Social User");
        user.setEmail("social_" + System.currentTimeMillis() + "@temp.com");
        user.setRole("USER");

        user = userRepository.save(user);

        String jwt = jwtUtil.generateToken(
                user.getId(),
                user.getRole()
        );

        return ResponseEntity.ok(Map.of(
                "token", jwt,
                "role", user.getRole(),
                "userId", user.getId()
        ));
    }
}



