package com.team.waitless_backend.service;


import com.team.waitless_backend.model.QueueEntry;
import com.team.waitless_backend.repository.QueueEntryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class QueueEntryService {

    @Autowired
    private QueueEntryRepository queueEntryRepository;

    public List<QueueEntry> getAll() {
        return queueEntryRepository.findAll();
    }

    public List<QueueEntry> getByQueue(Long queueId) {
        return queueEntryRepository.findByQueueId(queueId);
    }

    public QueueEntry joinQueue(QueueEntry entry) {
        entry.setJoinedAt(LocalDateTime.now());
        entry.setStatus("WAITING");
        return queueEntryRepository.save(entry);
    }

    public QueueEntry markAsServed(Long id) {
        QueueEntry entry = queueEntryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Entry not found"));
        entry.setStatus("SERVED");
        return queueEntryRepository.save(entry);
    }
}
