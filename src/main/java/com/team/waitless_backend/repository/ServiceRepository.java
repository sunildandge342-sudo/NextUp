package com.team.waitless_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;


import com.team.waitless_backend.model.Service;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ServiceRepository extends JpaRepository<Service, Long> {

    // Get all services for a provider ordered by latest created
    List<Service> findByProviderIdOrderByCreatedAtDesc(Long providerId);

}