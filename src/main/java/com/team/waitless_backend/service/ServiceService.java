package com.team.waitless_backend.service;

import com.team.waitless_backend.dto.CreateServiceRequest;
import com.team.waitless_backend.dto.ServiceResponse;
import com.team.waitless_backend.repository.QueueEntryRepository;
import com.team.waitless_backend.repository.ServiceRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ServiceService {

    private final ServiceRepository serviceRepository;
    private final QueueEntryRepository queueEntryRepository;

    public ServiceService(ServiceRepository serviceRepository,
                          QueueEntryRepository queueEntryRepository) {
        this.serviceRepository = serviceRepository;
        this.queueEntryRepository = queueEntryRepository;
    }

    // ================= GET SERVICES =================

    public List<ServiceResponse> getServicesByProvider(Long providerId) {

        List<com.team.waitless_backend.model.Service> services =
                serviceRepository.findByProviderIdOrderByCreatedAtDesc(providerId);

        return services.stream().map(service -> {

            Double avgWaitingTime =
                    queueEntryRepository
                            .findAverageWaitingTimeByServiceId(service.getId());

            if (avgWaitingTime == null) {
                avgWaitingTime = 0.0;
            }

            return new ServiceResponse(service, avgWaitingTime);

        }).collect(Collectors.toList());
    }

    // ================= CREATE SERVICE =================

    public ServiceResponse createService(CreateServiceRequest request) {

        if (request.getMaxCapacity() != null &&
                request.getMaxCapacity() <= 0) {
            throw new IllegalArgumentException("Max capacity must be positive");
        }

        com.team.waitless_backend.model.Service service =
                new com.team.waitless_backend.model.Service();

        service.setProviderId(request.getProviderId());
        service.setName(request.getName());
        service.setDescription(request.getDescription());
        service.setMaxCapacity(request.getMaxCapacity());
        service.setIsActive(true);

        com.team.waitless_backend.model.Service saved =
                serviceRepository.save(service);

        return new ServiceResponse(saved, 0.0);
    }

    // ================= UPDATE STATUS =================

    public void updateStatus(Long id, Boolean isActive) {

        com.team.waitless_backend.model.Service service =
                serviceRepository.findById(id)
                        .orElseThrow(() ->
                                new RuntimeException("Service not found with id: " + id));

        service.setIsActive(isActive);

        serviceRepository.save(service);
    }
}