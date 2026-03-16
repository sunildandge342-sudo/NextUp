package com.team.waitless_backend.controller;

import com.team.waitless_backend.dto.JoinQueueRequest;
import com.team.waitless_backend.dto.JoinQueueResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.team.waitless_backend.service.TokenService;
@RestController
@RequestMapping("/api/token")
public class TokenController {

    @Autowired
    private TokenService tokenService;

    @PostMapping("/join")
    public ResponseEntity<JoinQueueResponse> joinQueue(
            @RequestBody JoinQueueRequest request) {

        JoinQueueResponse response = tokenService.joinQueue(request);

        return ResponseEntity.ok(response);
    }
}