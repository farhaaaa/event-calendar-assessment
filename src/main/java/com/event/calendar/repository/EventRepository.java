/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.event.calendar.repository;

import com.event.calendar.entity.Event;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 *
 * @author Farha Mansuri
 */
public interface EventRepository extends JpaRepository<Event, Long>{
    
}
