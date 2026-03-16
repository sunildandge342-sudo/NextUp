package com.team.waitless_backend.dto;

import java.util.List;

public class QueueResponse {

    private QueueEntryResponseDTO currentlyServing;
    private List<QueueEntryResponseDTO> waitingList;
    private boolean isActive;   // 👈 NEW FIELD

    public QueueResponse(QueueEntryResponseDTO currentlyServing,
                         List<QueueEntryResponseDTO> waitingList,
                         boolean isActive) {   // 👈 UPDATED CONSTRUCTOR
        this.currentlyServing = currentlyServing;
        this.waitingList = waitingList;
        this.isActive = isActive;
    }

    public QueueEntryResponseDTO getCurrentlyServing() {
        return currentlyServing;
    }

    public List<QueueEntryResponseDTO> getWaitingList() {
        return waitingList;
    }

    public boolean isActive() {   // 👈 GETTER
        return isActive;
    }
}