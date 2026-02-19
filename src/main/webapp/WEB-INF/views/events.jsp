<%-- 
    Document   : events
    Created on : Feb 19, 2026, 11:57:07 AM
    Author     : Farha Mansuri
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
    <head>
        <title>Event Calendar</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 40px;
                background: #f5f6fa;
            }

            h2 {
                color: #2c3e50;
                margin-bottom: 10px;
            }

            .card {
                background: white;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
                margin-bottom: 25px;
            }

            .form-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 15px 25px;
            }

            label {
                font-size: 13px;
                color: #555;
            }

            input, select {
                padding: 8px;
                margin-top: 4px;
                width: 100%;
                border: 1px solid #ccc;
                border-radius: 4px;
            }

            button {
                background: #3498db;
                color: white;
                border: none;
                padding: 8px 14px;
                border-radius: 4px;
                cursor: pointer;
                margin-top: 10px;
            }

            button:hover {
                background: #2980b9;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 10px;
            }

            th {
                background: #3498db;
                color: white;
                padding: 10px;
            }

            td {
                padding: 8px;
                border-bottom: 1px solid #eee;
                text-align: center;
            }

            tr:hover {
                background: #f2f6ff;
            }

            .dow-group {
                grid-column: span 2;
            }

            .dow-options {
                display: flex;
                flex-wrap: wrap;
                gap: 12px 18px;
                margin-top: 6px;
            }

            .dow-options label {
                font-size: 14px;
                background: #f3f6fb;
                padding: 5px 10px;
                border-radius: 4px;
                cursor: pointer;
            }

            .dow-options input {
                margin-right: 4px;
            }

            .error {
                color: #e74c3c;
                font-size: 12px;
                margin-top: 4px;
            }

            .input-error {
                border: 1px solid #e74c3c !important;
            }

            .banner {
                display: none;
                padding: 10px 15px;
                margin-bottom: 15px;
                border-radius: 5px;
                font-weight: bold;
            }

            .banner.success {
                background: #d4edda;
                color: #155724;
            }

            .banner.error {
                background: #f8d7da;
                color: #721c24;
            }

        </style>

        <script>
            let currentPage = 0;
            let totalPages = 0;
            let searchText = "";
            let sortValue = "slotStartDate,asc";

            function showBanner(message, type = "success") {

                const banner = document.getElementById("banner");

                banner.innerText = message;
                banner.className = "banner " + type;
                banner.style.display = "block";

                setTimeout(() => {
                    banner.style.display = "none";
                }, 3000);
            }

            function calculateDOW() {
                let value = 0;
                document.querySelectorAll('.dow:checked').forEach(cb => {
                    value += parseInt(cb.value);
                });
                return value;
            }
            async function saveEvent() {

                document.querySelectorAll(".error").forEach(e => e.innerText = "");
                document.querySelectorAll("input, select").forEach(i => i.classList.remove("input-error"));

                const name = document.getElementById("name").value.trim();
                const startDate = document.getElementById("startDate").value;
                const endDate = document.getElementById("endDate").value;
                const startTime = document.getElementById("startTime").value;
                const endTime = document.getElementById("endTime").value;
                const dow = calculateDOW();

                let hasError = false;

                if (!name) {
                    document.getElementById("nameError").innerText = "Please enter event name";
                    document.getElementById("name").classList.add("input-error");
                    hasError = true;
                }

                if (!startDate) {
                    document.getElementById("startDateError").innerText = "Please select start date";
                    document.getElementById("startDate").classList.add("input-error");
                    hasError = true;
                }

                if (!endDate) {
                    document.getElementById("endDateError").innerText = "Please select end date";
                    document.getElementById("endDate").classList.add("input-error");
                    hasError = true;
                }

                if (!startTime) {
                    document.getElementById("startTimeError").innerText = "Please select start time";
                    document.getElementById("startTime").classList.add("input-error");
                    hasError = true;
                }

                if (!endTime) {
                    document.getElementById("endTimeError").innerText = "Please select end time";
                    document.getElementById("endTime").classList.add("input-error");
                    hasError = true;
                }

                if (dow === 0) {
                    document.getElementById("dowError").innerText = "Please select at least one day";
                    hasError = true;
                }

                if (hasError)
                    return;

                const event = {name, startDate, endDate, startTime, endTime, dowValue: dow};

                const response = await fetch('/api/events', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(event)
                });

                if (!response.ok) {
                    const msg = await response.text();
                    alert(msg);
                    return;
                }
                clearForm();
                loadSlots(0);
                showBanner("Event added successfully");
            }

            function formatDOW(value) {
                const days = [];
                if (value & 2)
                    days.push("M");
                if (value & 4)
                    days.push("T");
                if (value & 8)
                    days.push("W");
                if (value & 16)
                    days.push("T");
                if (value & 32)
                    days.push("F");
                if (value & 64)
                    days.push("S");
                if (value & 1)
                    days.push("S");
                return days.join(" ");
            }

            async function loadSlots(page) {

                // If page not provided, use currentPage
                if (page === undefined || page === null) {
                    page = currentPage;
                }

                const response = await fetch('/api/events/slots?page=' + page +
                        '&size=10&search=' + searchText +
                        '&sort=' + sortValue);


                const data = await response.json();

                currentPage = data.number;
                totalPages = data.totalPages;

                const table = document.getElementById("slots");
                table.innerHTML = "";

                data.content.forEach(slot => {

                    const tr = document.createElement("tr");

                    tr.innerHTML =
                            "<td>" + (slot.eventName || "Event") + "</td>" +
                            "<td>" + slot.slotStartDate + "</td>" +
                            "<td>" + slot.slotEndDate + "</td>" +
                            "<td>" + slot.startTime + "</td>" +
                            "<td>" + slot.endTime + "</td>" +
                            "<td>" + formatDOW(slot.dowValue) + "</td>" +
                            "<td><button class='delete-btn' data-id='" + slot.id + "'>Delete</button></td>";

                    table.appendChild(tr);
                });

                document.getElementById("pageInfo").innerText =
                        "Page " + (currentPage + 1) + " of " + totalPages;
            }

            function nextPage() {
                if (currentPage < totalPages - 1) {
                    loadSlots(currentPage + 1);
                }
            }

            function prevPage() {
                if (currentPage > 0) {
                    loadSlots(currentPage - 1);
                }
            }

            async function deleteSlot(id) {
                await fetch("/api/events/slots/delete/" + id, {
                    method: "POST"
                });
                loadSlots(0);
                showBanner("Slot deleted successfully");
            }

            window.onload = function () {
                loadSlots(0);
            };
            loadSlots(0);

            function clearForm() {

                document.getElementById("name").value = "";
                document.getElementById("startDate").value = "";
                document.getElementById("endDate").value = "";
                document.getElementById("startTime").value = "";
                document.getElementById("endTime").value = "";

                document.querySelectorAll('.dow').forEach(cb => cb.checked = false);

                document.querySelectorAll(".error").forEach(e => e.innerText = "");
                document.querySelectorAll("input").forEach(i => i.classList.remove("input-error"));
            }

            document.addEventListener("click", function (e) {
                if (e.target.classList.contains("delete-btn")) {
                    const id = e.target.getAttribute("data-id");
                    deleteSlot(id);
                }
            });

            function searchSlots() {
                searchText = document.getElementById("searchBox").value;
                currentPage = 0;
                loadSlots(0);
            }

            function changeSort() {
                sortValue = document.getElementById("sortSelect").value;
                loadSlots(0);
            }

        </script>
    </head>

    <body>
        <div id="banner" class="banner"></div>

        <div class="card">
            <h2>Create Event</h2>

            <div class="form-grid">

                <div>
                    <label>Event Name</label>
                    <input id="name">
                    <div class="error" id="nameError"></div>
                </div>

                <div>
                    <label>Start Date</label>
                    <input type="date" id="startDate">
                    <div class="error" id="startDateError"></div>
                </div>

                <div>
                    <label>End Date</label>
                    <input type="date" id="endDate">
                    <div class="error" id="endDateError"></div>
                </div>

                <div>
                    <label>Start Time</label>
                    <input type="time" id="startTime">
                    <div class="error" id="startTimeError"></div>
                </div>

                <div>
                    <label>End Time</label>
                    <input type="time" id="endTime">
                    <div class="error" id="endTimeError"></div>
                </div>
                <div class="dow-group">
                    <label>Day Of Week</label>

                    <div class="dow-options">
                        <label><input type="checkbox" class="dow" value="1"> Sun</label>
                        <label><input type="checkbox" class="dow" value="2"> Mon</label>
                        <label><input type="checkbox" class="dow" value="4"> Tue</label>
                        <label><input type="checkbox" class="dow" value="8"> Wed</label>
                        <label><input type="checkbox" class="dow" value="16"> Thu</label>
                        <label><input type="checkbox" class="dow" value="32"> Fri</label>
                        <label><input type="checkbox" class="dow" value="64"> Sat</label>
                    </div>
                    <div class="error" id="dowError"></div>
                </div>
            </div>

            <button onclick="saveEvent()">Save Event</button>
        </div>

        <div class="card">
            <h2>Event Slots</h2>
            <div style="margin-bottom:10px;">
                <input id="searchBox" placeholder="Search by event name">
                <button onclick="searchSlots()">Search</button>
                <select id="sortSelect" onchange="changeSort()">
                    <option value="slotStartDate,asc">Start Date ↑</option>
                    <option value="slotStartDate,desc">Start Date ↓</option>
                    <option value="event.name,asc">Name ↑</option>
                    <option value="event.name,desc">Name ↓</option>
                </select>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Start</th>
                        <th>End</th>
                        <th>Start Time</th>
                        <th>End Time</th>
                        <th>DOW</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="slots"></tbody>
            </table>

            <div style="margin-top:10px;">
                <button onclick="prevPage()">Previous</button>
                <span id="pageInfo"></span>
                <button onclick="nextPage()">Next</button>
            </div>
        </div>

    </body>
</html>

