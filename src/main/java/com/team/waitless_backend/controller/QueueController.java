package com.team.waitless_backend.controller;

import java.util.List;

import com.team.waitless_backend.dto.*;
import com.team.waitless_backend.model.QueueEntry;
import com.team.waitless_backend.repository.QueueEntryRepository;
import com.team.waitless_backend.service.QueueEntryService;
import com.team.waitless_backend.service.TokenService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/queue")
@CrossOrigin(origins = "*")
public class QueueController {

    private final TokenService tokenService;
    private final QueueEntryRepository queueEntryRepository;

    // ✅ Constructor Injection (Best Practice)
    public QueueController(TokenService tokenService,
                           QueueEntryRepository queueEntryRepository) {
        this.tokenService = tokenService;
        this.queueEntryRepository = queueEntryRepository;
    }

    // ================= USER STATUS =================

    @GetMapping("/status")
    public QueueStatusResponse getStatus(
            @RequestParam Long userId,
            @RequestParam Long serviceId
    ) {
        return tokenService.getUserQueueStatus(userId, serviceId);
    }


    @PostMapping("/join")
    public JoinQueueResponse joinQueue(@RequestBody JoinQueueRequest request) {
        return tokenService.joinQueue(request);
    }

    // ================= USER ACTIVE QUEUES =================

    @GetMapping("/user/{userId}")
    public List<UserQueueResponse> getUserQueues(
            @PathVariable Long userId) {
        return tokenService.getUserActiveQueues(userId);
    }

    // ================= SERVICE QUEUE (FOR PROVIDER SCREEN) =================

    @GetMapping("/{serviceId}")
    public QueueResponse getQueue(@PathVariable Long serviceId) {
        return tokenService.getQueueForService(serviceId);
    }

    @Autowired
    private QueueEntryService queueEntryService;

    @PostMapping("/{serviceId}/call-next")
    public ResponseEntity<QueueResponse> callNext(@PathVariable Long serviceId) {
        return ResponseEntity.ok(
                queueEntryService.callNext(serviceId)
        );
    }

    // ================= CANCEL TOKEN =================

    @DeleteMapping("/cancel/{queueEntryId}")
    public ResponseEntity<String> cancelToken(
            @PathVariable Long queueEntryId,
            @RequestParam Long userId
    ) {
        queueEntryService.cancelToken(queueEntryId, userId);
        return ResponseEntity.ok("Token cancelled successfully");
    }
}
