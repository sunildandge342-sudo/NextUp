package com.team.waitless_backend.repository;
import com.team.waitless_backend.model.QueueEntry;
import com.team.waitless_backend.model.QueueStatus;
import com.team.waitless_backend.model.Service;
import com.team.waitless_backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;
public interface QueueEntryRepository extends JpaRepository<QueueEntry, Long> {
    // ================= USER VALIDATION =================
    boolean existsByUserAndServiceAndStatus(
            User user,
            Service service,
            QueueStatus status
    );

    Optional<QueueEntry> findByUserAndServiceAndStatus(
            User user,
            Service service,
            QueueStatus status
    );

    Optional<QueueEntry> findByUserAndServiceAndStatusIn(
            User user,
            Service service,
            List<QueueStatus> statuses
    );

    List<QueueEntry> findByUserAndStatus(
            User user,
            QueueStatus status
    );

    List<QueueEntry> findByUserAndStatusIn(
            User user,
            List<QueueStatus> statuses
    );

    // ================= TOKEN / POSITION =================

    Optional<QueueEntry> findTopByServiceOrderByTokenNumberDesc(
            Service service
    );

    long countByServiceAndStatus(
            Service service,
            QueueStatus status
    );

    long countByServiceAndStatusAndTokenNumberLessThan(
            Service service,
            QueueStatus status,
            Long tokenNumber
    );

    // ================= PROVIDER QUEUE LOGIC =================

    Optional<QueueEntry> findFirstByServiceAndStatus(
            Service service,
            QueueStatus status
    );

    List<QueueEntry> findByServiceAndStatusOrderByJoinedAtAsc(
            Service service,
            QueueStatus status
    );

    // ================= CALL-NEXT LOGIC (Using serviceId) =================

    Optional<QueueEntry> findByServiceIdAndStatus(
            Long serviceId,
            QueueStatus status
    );

    Optional<QueueEntry> findFirstByServiceIdAndStatusOrderByJoinedAtAsc(
            Long serviceId,
            QueueStatus status
    );

    List<QueueEntry> findAllByServiceIdAndStatusOrderByJoinedAtAsc(
            Long serviceId,
            QueueStatus status
    );

    // ================= ANALYTICS =================

    @Query("""
           SELECT AVG(q.waitingTimeMinutes)
           FROM QueueEntry q
           WHERE q.service.id = :serviceId
           AND q.status = 'SERVED'
           AND q.waitingTimeMinutes IS NOT NULL
           """)
    Double findAverageWaitingTimeByServiceId(
            @Param("serviceId") Long serviceId
    );

    // ================= CANCEL TOKEN =================

    Optional<QueueEntry> findByIdAndStatusIn(
            Long id,
            List<QueueStatus> statuses
    );

    List<QueueEntry> findByServiceIdAndStatusInOrderByJoinedAtAsc(
            Long serviceId,
            List<QueueStatus> statuses
    );
}

