package com.team.waitless_backend.dto;

public class SignupRequest {

    private String name;
    private String email;
    private String password;
    private String phone;
    private String role; // ✅ ADD THIS

    // getters & setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    // ✅ ADD ONLY THESE METHODS
    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
}

