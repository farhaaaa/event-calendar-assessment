/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.event.calendar.service;

import com.event.calendar.entity.Event;
import com.event.calendar.entity.EventSlot;
import com.event.calendar.repository.EventRepository;
import com.event.calendar.repository.EventSlotRepository;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 * @author Farha Mansuri
 */
@Service
@RequiredArgsConstructor
public class EventService {

    private final EventRepository eventRepository;
    private final EventSlotRepository slotRepository;

    @Transactional
    public Event createEvent(Event event) {

        validatePeriod(event); // Validate event date is in between 1 month only
        validateDuration(event); // Validate duration is for 30 minutes to 5 hours

        // Save master event
        Event savedEvent = eventRepository.save(event);

        // Generate slots (we implement this next)
        List<EventSlot> slots = generateSlots(savedEvent);

        // Save slots
        slotRepository.saveAll(slots);

        return savedEvent;
    }

    private void validatePeriod(Event event) {
        long days = ChronoUnit.DAYS.between(event.getStartDate(), event.getEndDate()) + 1;

        if (days < 1 || days > 31) {
            throw new RuntimeException("Event period must be between 1 day and 1 month");
        }
    }

    private void validateDuration(Event event) {
        long minutes = ChronoUnit.MINUTES.between(event.getStartTime(), event.getEndTime());

        if (minutes < 30 || minutes > 300 || minutes % 30 != 0) {
            throw new RuntimeException("Duration must be between 30 minutes and 5 hours in 30-min intervals");
        }
    }

    private List<EventSlot> generateSlots(Event event) {

        List<EventSlot> slots = new ArrayList<>();

        LocalDate current = event.getStartDate();
        LocalDate end = event.getEndDate();

        // If all days selected (Sun–Sat = 127), no split needed
        if (event.getDowValue() == 127) {
            EventSlot slot = new EventSlot();
            slot.setEvent(event);
            slot.setSlotStartDate(event.getStartDate());
            slot.setSlotEndDate(event.getEndDate());
            slot.setStartTime(event.getStartTime());
            slot.setEndTime(event.getEndTime());
            slot.setDowValue(event.getDowValue());

            slots.add(slot);
            return slots;
        }

        while (!current.isAfter(end)) {

            // Check if current day is selected
            if (isDaySelected(current.getDayOfWeek(), event.getDowValue())) {

                LocalDate slotStart = current;

                // Move forward while consecutive selected days exist
                while (!current.isAfter(end)
                        && isDaySelected(current.getDayOfWeek(), event.getDowValue())) {
                    current = current.plusDays(1);
                }

                LocalDate slotEnd = current.minusDays(1);

                EventSlot slot = new EventSlot();
                slot.setEvent(event);
                slot.setSlotStartDate(slotStart);
                slot.setSlotEndDate(slotEnd);
                slot.setStartTime(event.getStartTime());
                slot.setEndTime(event.getEndTime());
                slot.setDowValue(event.getDowValue());

                slots.add(slot);

            } else {
                current = current.plusDays(1);
            }
        }

        return slots;
    }

    private boolean isDaySelected(DayOfWeek day, int dowValue) {

        int bit = 0;

        switch (day) {
            case SUNDAY:
                bit = 1;
                break;
            case MONDAY:
                bit = 2;
                break;
            case TUESDAY:
                bit = 4;
                break;
            case WEDNESDAY:
                bit = 8;
                break;
            case THURSDAY:
                bit = 16;
                break;
            case FRIDAY:
                bit = 32;
                break;
            case SATURDAY:
                bit = 64;
                break;
        }

        return (dowValue & bit) != 0;
    }
}
