package com.team.waitless_backend.controller;

import com.team.waitless_backend.model.QueueEntry;
import com.team.waitless_backend.repository.QueueEntryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/queueentries")
@CrossOrigin(origins = "*")
public class QueueEntryController {

    @Autowired
    private QueueEntryRepository queueEntryRepository;

    @GetMapping
    public List<QueueEntry> getAllEntries() {
        return queueEntryRepository.findAll();
    }

    @GetMapping("/queue/{queueId}")
    public List<QueueEntry> getEntriesByQueue(@PathVariable Long queueId) {
        return queueEntryRepository.findByQueueId(queueId);
    }

    @PostMapping
    public QueueEntry joinQueue(@RequestBody QueueEntry entry) {
        entry.setJoinedAt(LocalDateTime.now());
        entry.setStatus("WAITING");
        return queueEntryRepository.save(entry);
    }

    @PutMapping("/{id}/serve")
    public QueueEntry markAsServed(@PathVariable Long id) {
        QueueEntry entry = queueEntryRepository.findById(id).orElseThrow();
        entry.setStatus("SERVED");
        return queueEntryRepository.save(entry);
    }
}
