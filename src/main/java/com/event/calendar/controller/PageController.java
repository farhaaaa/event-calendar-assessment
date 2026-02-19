/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.event.calendar.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 *
 * @author Farha Mansuri
 */
@Controller
public class PageController {
    
    @GetMapping("/")
    public String home() {
        return "events";
    }
    
}
