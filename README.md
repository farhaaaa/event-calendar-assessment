# Event Calendar Application

This project is a Spring Boot web application developed as part of an assessment.

It allows users to create events with validation rules, automatic slot splitting,
pagination, and delete functionality.

---

## Features

- Create events with:
  - Event Name
  - Date Range
  - Start Time / End Time
  - Day of Week selection
- Binary Day-of-Week calculation
- Automatic splitting of event slots based on selected days
- Validation rules:
  - Event period must be between 1 day and 1 month
  - Duration must be between 30 minutes and 5 hours
  - Duration must be in 30-minute intervals
- Pagination (10 rows per page)
- Delete slot functionality
- Success and validation banners

---

## Tech Stack

- Java 8
- Spring Boot 2.7
- JSP + JavaScript
- MS SQL Server
- Maven

---

## How to Run

### 1. Database Setup

Create a database in SQL Server (example: `event_calendar_db`).

Update credentials in:

src/main/resources/application.properties

Example:

spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=event_calendar_db  
spring.datasource.username=YOUR_USERNAME  
spring.datasource.password=YOUR_PASSWORD  

---

### 2. Run Application

From project root:

mvn spring-boot:run

Or run the main class from IDE.

---

### 3. Open Browser

http://localhost:8080/

---

## Notes

- Pagination implemented using Spring Data Pageable.
- Slot splitting logic supports weekdays, weekends, or custom combinations.
- Validation enforced both in UI and backend.
