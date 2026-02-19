/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.event.calendar.controller;

import com.event.calendar.entity.Event;
import com.event.calendar.entity.EventSlot;
import com.event.calendar.repository.EventSlotRepository;
import com.event.calendar.service.EventService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 *
 * @author Farha Mansuri
 */
@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
@CrossOrigin
public class EventController {

    private final EventService eventService;
    private final EventSlotRepository slotRepository;

    @PostMapping
    public Event createEvent(@RequestBody Event event) {
        return eventService.createEvent(event);
    }

    @GetMapping("/slots")
    public Page<EventSlot> getSlots(
            @RequestParam(required = false) String search,
            Pageable pageable) {

        Page<EventSlot> page;

        if (search != null && !search.isEmpty()) {
            page = slotRepository.findByEvent_NameContainingIgnoreCase(search, pageable);
        } else {
            page = slotRepository.findAll(pageable);
        }

        page.getContent().forEach(slot -> {
            if (slot.getEvent() != null) {
                slot.setEventName(slot.getEvent().getName());
            }
        });

        return page;
    }

    @PostMapping("/slots/delete/{id}")
    public void deleteSlot(@PathVariable Long id) {
        slotRepository.deleteById(id);
    }
}
