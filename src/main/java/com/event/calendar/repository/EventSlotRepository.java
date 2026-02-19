/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.event.calendar.repository;

import com.event.calendar.entity.EventSlot;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 *
 * @author Farha Mansuri
 */
public interface EventSlotRepository extends JpaRepository<EventSlot, Long> {

    Page<EventSlot> findByEvent_NameContainingIgnoreCase(String name, Pageable pageable);
}
