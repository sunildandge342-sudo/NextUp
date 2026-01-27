package com.team.waitless_backend.repository;

import com.team.waitless_backend.model.QueueEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QueueEntryRepository extends JpaRepository<QueueEntry, Long> {
    List<QueueEntry> findByQueueId(Long queueId);
    List<QueueEntry> findByUserId(Long userId);
}

