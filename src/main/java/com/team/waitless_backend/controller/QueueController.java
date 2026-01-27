package com.team.waitless_backend.controller;


import com.team.waitless_backend.model.Queue;
import com.team.waitless_backend.repository.QueueRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/queues")
@CrossOrigin(origins = "*")
public class QueueController {

    @Autowired
    private QueueRepository queueRepository;

    @GetMapping
    public List<Queue> getAllQueues() {
        return queueRepository.findAll();
    }

    @PostMapping
    public Queue createQueue(@RequestBody Queue queue) {
        return queueRepository.save(queue);
    }

    @DeleteMapping("/{id}")
    public void deleteQueue(@PathVariable Long id) {
        queueRepository.deleteById(id);
    }
}
