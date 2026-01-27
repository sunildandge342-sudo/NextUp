package com.team.waitless_backend.controller;

import com.team.waitless_backend.model.Feedback;
import com.team.waitless_backend.repository.FeedbackRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/feedbacks")
@CrossOrigin(origins = "*")
public class FeedbackController {

    @Autowired
    private FeedbackRepository feedbackRepository;

    @GetMapping
    public List<Feedback> getAllFeedback() {
        return feedbackRepository.findAll();
    }

    @GetMapping("/queue/{queueId}")
    public List<Feedback> getFeedbackByQueue(@PathVariable Long queueId) {
        return feedbackRepository.findByQueueId(queueId);
    }

    @PostMapping
    public Feedback createFeedback(@RequestBody Feedback feedback) {
        feedback.setCreatedAt(LocalDateTime.now());
        return feedbackRepository.save(feedback);
    }
}
