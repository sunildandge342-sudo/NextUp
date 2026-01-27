package com.team.waitless_backend.dto;


public class SocialLoginRequest {

    private String provider;
    private String token;

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}


