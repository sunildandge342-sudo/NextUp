package com.team.waitless_backend.controller;

import com.team.waitless_backend.repository.QueueEntryRepository;
import com.team.waitless_backend.repository.FeedbackRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;
import java.util.*;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "*")
public class DashboardController {

    @Autowired
    private QueueEntryRepository queueRepo;

    @Autowired
    private FeedbackRepository feedbackRepo;

    @GetMapping
    public Map<String, Object> getDashboardData() {
        Map<String, Object> dashboard = new HashMap<>();

        var allEntries = queueRepo.findAll();
        long servedCount = allEntries.stream()
                .filter(q -> "SERVED".equalsIgnoreCase(q.getStatus()))
                .count();

        double avgWait = allEntries.stream()
                .filter(q -> q.getServedAt() != null && q.getJoinedAt() != null)
                .mapToDouble(q -> Duration.between(q.getJoinedAt(), q.getServedAt()).toMinutes())
                .average().orElse(0);

        double avgRating = feedbackRepo.findAll().stream()
                .mapToInt(f -> f.getRating())
                .average().orElse(0);

        dashboard.put("totalServed", servedCount);
        dashboard.put("avgWaitTime", avgWait);
        dashboard.put("avgRating", avgRating);
        dashboard.put("activeQueues", queueRepo.count());

        return dashboard;
    }
}
