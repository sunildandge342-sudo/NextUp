package com.team.waitless_backend.service;
import com.team.waitless_backend.dto.QueueEntryResponseDTO;
import com.team.waitless_backend.dto.QueueResponse;
import com.team.waitless_backend.model.QueueEntry;
import com.team.waitless_backend.model.QueueStatus;
import com.team.waitless_backend.repository.QueueEntryRepository;
import com.team.waitless_backend.repository.ServiceRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
@Service
public class QueueEntryService {
    @Autowired
    private QueueEntryRepository queueEntryRepository;
    @Autowired
    private ServiceRepository serviceRepository;   // ✅ ADDED
    @Transactional
    public QueueResponse callNext(Long serviceId) {

        // 🔥 Fetch service to get isActive
        com.team.waitless_backend.model.Service service =
                serviceRepository.findById(serviceId)
                        .orElseThrow(() -> new RuntimeException("Service not found"));

        // STEP 1 — Complete currently serving (if exists)
        Optional<QueueEntry> servingOpt =
                queueEntryRepository.findByServiceIdAndStatus(
                        serviceId,
                        QueueStatus.SERVING
                );

        if (servingOpt.isPresent()) {
            QueueEntry current = servingOpt.get();

            current.setStatus(QueueStatus.SERVED);
            current.setServedAt(LocalDateTime.now());

            // Optional: calculate waiting time
            if (current.getJoinedAt() != null) {
                long minutes =
                        java.time.Duration.between(
                                current.getJoinedAt(),
                                current.getServedAt()
                        ).toMinutes();

                current.setWaitingTimeMinutes((int) minutes);
            }

            queueEntryRepository.save(current);
        }

        // STEP 2 — Get next waiting entry
        Optional<QueueEntry> waitingOpt =
                queueEntryRepository
                        .findFirstByServiceIdAndStatusOrderByJoinedAtAsc(
                                serviceId,
                                QueueStatus.WAITING
                        );

        QueueEntryResponseDTO currentlyServingDTO = null;

        if (waitingOpt.isPresent()) {

            QueueEntry newServing = waitingOpt.get();

            newServing.setStatus(QueueStatus.SERVING);

            // IMPORTANT: Do NOT set servedAt here
            // servedAt is for completion only
            // This was logically wrong earlier
            // newServing.setServedAt(LocalDateTime.now()); ❌ REMOVE THIS

            queueEntryRepository.save(newServing);

            currentlyServingDTO = mapToDTO(newServing);
        }

        // STEP 3 — Get updated waiting list
        List<QueueEntry> waitingEntities =
                queueEntryRepository
                        .findAllByServiceIdAndStatusOrderByJoinedAtAsc(
                                serviceId,
                                QueueStatus.WAITING
                        );

        List<QueueEntryResponseDTO> waitingDTOs =
                waitingEntities.stream()
                        .map(this::mapToDTO)
                        .toList();

        // ✅ Return queue + correct active status
        return new QueueResponse(
                currentlyServingDTO,
                waitingDTOs,
                service.getIsActive()
        );
    }

    @Transactional
    public void cancelToken(Long queueEntryId, Long userId) {

        // STEP 1 — Find queue entry
        QueueEntry entry = queueEntryRepository.findById(queueEntryId)
                .orElseThrow(() -> new RuntimeException("Token not found"));

        // STEP 2 — Security check (user can cancel only their own token)
        if (!entry.getUser().getId().equals(userId)) {
            throw new RuntimeException("Unauthorized token cancellation");
        }

        // STEP 3 — Prevent cancelling if already serving
        if (entry.getStatus() == QueueStatus.SERVING) {
            throw new RuntimeException("Cannot cancel while service is being processed");
        }

        // STEP 4 — Prevent cancelling served tokens
        if (entry.getStatus() == QueueStatus.SERVED) {
            throw new RuntimeException("Token already served");
        }

        // STEP 5 — Delete entry
        queueEntryRepository.delete(entry);
    }

    private QueueEntryResponseDTO mapToDTO(QueueEntry entry) {
        return new QueueEntryResponseDTO(
                entry.getId(),                 // queueEntryId
                entry.getUser().getId(),       // userId  ✅ ADDED
                Math.toIntExact(entry.getTokenNumber()),
                entry.getUser().getName(),
                entry.getStatus(),
                entry.getServedAt());
    }
}