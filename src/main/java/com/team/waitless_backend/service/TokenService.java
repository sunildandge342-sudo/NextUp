package com.team.waitless_backend.service;

import com.team.waitless_backend.dto.JoinQueueRequest;
import com.team.waitless_backend.dto.JoinQueueResponse;
import com.team.waitless_backend.dto.QueueEntryResponseDTO;
import com.team.waitless_backend.dto.QueueResponse;
import com.team.waitless_backend.dto.QueueStatusResponse;
import com.team.waitless_backend.dto.UserQueueResponse;

import com.team.waitless_backend.model.QueueEntry;
import com.team.waitless_backend.model.QueueStatus;
import com.team.waitless_backend.model.User;
import com.team.waitless_backend.repository.QueueEntryRepository;
import com.team.waitless_backend.repository.ServiceRepository;
import com.team.waitless_backend.repository.UserRepository;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;



import org.springframework.transaction.annotation.Transactional;


@Service
public class TokenService {

    private final QueueEntryRepository queueEntryRepository;
    private final ServiceRepository serviceRepository;
    private final UserRepository userRepository;

    public TokenService(QueueEntryRepository queueEntryRepository,
                        ServiceRepository serviceRepository,
                        UserRepository userRepository) {
        this.queueEntryRepository = queueEntryRepository;
        this.serviceRepository = serviceRepository;
        this.userRepository = userRepository;
    }

    // ================= CALCULATE POSITION =================

    public int calculatePosition(QueueEntry entry) {

        long countBefore =
                queueEntryRepository.countByServiceAndStatusAndTokenNumberLessThan(
                        entry.getService(),
                        QueueStatus.WAITING,
                        entry.getTokenNumber()
                );

        return (int) countBefore + 1;
    }

    // ================= GET AVERAGE WAITING TIME =================

    private int getAverageTime(com.team.waitless_backend.model.Service service) {

        Double avg =
                queueEntryRepository.findAverageWaitingTimeByServiceId(service.getId());

        // If no historical data OR unrealistic value
        if (avg == null || avg <= 0 || avg > 60) {

            // Use service-level default if available
            if (service.getAverageTime() != null && service.getAverageTime() > 0) {
                return service.getAverageTime();
            }

            // Safe fallback
            return 5;
        }

        return (int) Math.round(avg);
    }

    // ================= JOIN QUEUE =================

    @Transactional
    public JoinQueueResponse joinQueue(JoinQueueRequest request) {

        com.team.waitless_backend.model.Service service =
                serviceRepository.findById(request.getServiceId())
                        .orElseThrow(() -> new RuntimeException("Service not found"));

        if (!service.getIsActive()) {
            throw new RuntimeException("Service is not active");
        }

        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        boolean alreadyExists =
                queueEntryRepository.existsByUserAndServiceAndStatus(
                        user, service, QueueStatus.WAITING);

        if (alreadyExists) {
            throw new RuntimeException("User already in queue");
        }

        long waitingCount =
                queueEntryRepository.countByServiceAndStatus(
                        service, QueueStatus.WAITING);

        Long nextTokenNumber =
                queueEntryRepository.findTopByServiceOrderByTokenNumberDesc(service)
                        .map(q -> q.getTokenNumber() + 1)
                        .orElse(1L);

        // 🔥 FIXED: Use real average instead of multiplying
        int averageWaitingTime = getAverageTime(service);

        QueueEntry entry = new QueueEntry();
        entry.setService(service);
        entry.setUser(user);
        entry.setTokenNumber(nextTokenNumber);
        entry.setStatus(QueueStatus.WAITING);
        entry.setJoinedAt(LocalDateTime.now());

        queueEntryRepository.save(entry);

        return new JoinQueueResponse(
                nextTokenNumber,
                (int) waitingCount + 1,
                averageWaitingTime
        );
    }

    // ================= GET USER QUEUE STATUS =================

    public QueueStatusResponse getUserQueueStatus(Long userId, Long serviceId) {

        com.team.waitless_backend.model.Service service =
                serviceRepository.findById(serviceId)
                        .orElseThrow(() -> new RuntimeException("Service not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        QueueEntry entry =
                queueEntryRepository
                        .findByUserAndServiceAndStatusIn(
                                user,
                                service,
                                List.of(QueueStatus.WAITING, QueueStatus.SERVING)
                        )
                        .orElseThrow(() -> new RuntimeException("User not in queue"));

        // If currently serving
        if (entry.getStatus() == QueueStatus.SERVING) {
            return new QueueStatusResponse(
                    entry.getId(),
                    entry.getUser().getId(),
                    entry.getTokenNumber(),
                    0,
                    0,
                    "SERVING"
            );
        }

        int position = calculatePosition(entry);

        // 🔥 FIXED
        int averageWaitingTime = getAverageTime(service);

        return new QueueStatusResponse(
                entry.getId(),
                entry.getUser().getId(),
                entry.getTokenNumber(),
                position,
                averageWaitingTime,
                "WAITING"
        );
    }

    // ================= GET USER ACTIVE QUEUES =================

    public List<UserQueueResponse> getUserActiveQueues(Long userId) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<QueueEntry> entries =
                queueEntryRepository.findByUserAndStatusIn(
                        user,
                        List.of(QueueStatus.WAITING, QueueStatus.SERVING)
                );

        return entries.stream().map(entry -> {

            com.team.waitless_backend.model.Service service = entry.getService();

            int position = 0;
            int averageWaitingTime = 0;

            if (entry.getStatus() == QueueStatus.WAITING) {

                position = calculatePosition(entry);

                // 🔥 FIXED
                averageWaitingTime = getAverageTime(service);

            } else if (entry.getStatus() == QueueStatus.SERVING) {

                position = 0;
                averageWaitingTime = 0;
            }

            return new UserQueueResponse(
                    entry.getId(),
                    entry.getUser().getId(),
                    service.getId(),
                    service.getName(),
                    entry.getTokenNumber(),
                    position,
                    averageWaitingTime,
                    entry.getStatus().name()
            );

        }).toList();
    }

    // ================= GET FULL QUEUE FOR PROVIDER =================

    public QueueResponse getQueueForService(Long serviceId) {

        com.team.waitless_backend.model.Service service =
                serviceRepository.findById(serviceId)
                        .orElseThrow(() -> new RuntimeException("Service not found"));

        Optional<QueueEntry> servingOpt =
                queueEntryRepository.findByServiceIdAndStatus(
                        serviceId,
                        QueueStatus.SERVING
                );

        QueueEntryResponseDTO currentlyServingDTO = null;

        if (servingOpt.isPresent()) {
            currentlyServingDTO = mapToDTO(servingOpt.get());
        }

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

        return new QueueResponse(
                currentlyServingDTO,
                waitingDTOs,
                service.getIsActive()
        );
    }

    private QueueEntryResponseDTO mapToDTO(QueueEntry entry) {
        return new QueueEntryResponseDTO(
                entry.getId(),
                entry.getUser().getId(),
                Math.toIntExact(entry.getTokenNumber()),
                entry.getUser().getName(),
                entry.getStatus(),
                entry.getServedAt()
        );
    }
}