package com.team.waitless_backend.controller;

import com.team.waitless_backend.dto.CreateServiceRequest;
import com.team.waitless_backend.dto.ServiceResponse;
import com.team.waitless_backend.dto.ServiceStatusRequest;   // IMPORTANT IMPORT
import com.team.waitless_backend.service.ServiceService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/services")
@CrossOrigin(origins = "*")
public class ServiceController {

    private final ServiceService serviceService;

    public ServiceController(ServiceService serviceService) {
        this.serviceService = serviceService;
    }

    // ================= CREATE SERVICE =================

    @PostMapping
    public ResponseEntity<ServiceResponse> createService(
            @Valid @RequestBody CreateServiceRequest request) {

        ServiceResponse response =
                serviceService.createService(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

    // ================= UPDATE SERVICE STATUS =================

    @PatchMapping("/{id}/status")
    public ResponseEntity<?> updateServiceStatus(
            @PathVariable Long id,
            @RequestBody ServiceStatusRequest request) {

        if (request.getIsActive() == null) {
            return ResponseEntity
                    .badRequest()
                    .body("isActive field is required");
        }

        serviceService.updateStatus(id, request.getIsActive());

        return ResponseEntity.ok().build();
    }

    // ================= GET SERVICES BY PROVIDER =================

    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<ServiceResponse>> getServicesByProvider(
            @PathVariable Long providerId) {

        List<ServiceResponse> services =
                serviceService.getServicesByProvider(providerId);

        return ResponseEntity.ok(services);
    }
}