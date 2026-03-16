package com.team.waitless_backend.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private long expiration;

    // ======================= COMMON =======================
    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    // ======================= LOGIN JWT (UNCHANGED) =======================
    public String generateToken(Long userId, String role) {
        return Jwts.builder()
                .setSubject(String.valueOf(userId))
                .claim("role", role)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public Long extractUserId(String token) {
        Claims claims = extractAllClaims(token);
        return Long.parseLong(claims.getSubject());
    }

    public boolean isTokenValid(String token) {
        try {
            extractAllClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    // ======================= SIGNUP EMAIL VERIFICATION =======================

    // 🔐 Token used ONLY after OTP verification
    public String generateEmailVerifiedToken(String email) {
        return Jwts.builder()
                .setSubject(email)
                .claim("purpose", "SIGNUP")
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + (5 * 60 * 1000))) // 5 minutes
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    // 🔍 Extract email from signup token
    public String extractEmail(String token) {
        return extractAllClaims(token).getSubject();
    }

    // 🔒 Optional: ensure token is for signup only
    public boolean isSignupToken(String token) {
        Claims claims = extractAllClaims(token);
        return "SIGNUP".equals(claims.get("purpose"));
    }
}

