# BLOCKIQx Platform Development Plan

This document outlines the development plan for the BLOCKIQx platform.

## Phase 1: Project Setup and Initial Scaffolding

1.  **Create `plan.md`:** Outline the development plan.
2.  **Initialize Laravel Project:** Set up a new Laravel project. (Already done)
3.  **Configure Database:** Set up the database connection.

## Phase 2: Community Reporting System

1.  **User Authentication:**
    *   Create User model and migration (already exists).
    *   Implement API authentication using Laravel Sanctum.
2.  **Report Model and Migration:**
    *   Create `Report` model with fields: `email`, `phone_number`, `incident_type`, `description`, `location`, `media_path`, `status`, `user_id` (nullable for guest), `is_anonymous`.
    *   Create migration for the `reports` table.
3.  **API Endpoints for Reporting:**
    *   `POST /api/reports`: Create a new report (for guests and logged-in users).
    *   `GET /api/reports/nearby`: Get nearby help/support resources (for logged-in users).

## Phase 3: Outreach Mobile Application Backend

1.  **Staff Authentication:**
    *   Create `Staff` model and migration.
    *   Implement API authentication for staff users.
2.  **API Endpoints for Staff:**
    *   `GET /api/staff/reports`: Get assigned reports for the logged-in staff member.
    *   `GET /api/staff/reports/{report}`: Get details of a specific report.
    *   `PUT /api/staff/reports/{report}`: Update the status of a report (`In Progress`, `Completed`, `Arrived at location`, `Work started`).
    *   `POST /api/staff/reports/{report}/notes`: Add field notes to a report.
    *   `POST /api/staff/reports/{report}/media`: Upload additional media for a report.

## Phase 4: Admin Dashboard Backend

1.  **Admin Authentication:**
    *   Create an admin user role or a separate admin model/guard.
2.  **API Endpoints for Report Management:**
    *   `GET /api/admin/reports`: Get all reports with filtering options (date, area, incident type, status).
    *   `POST /api/admin/reports/{report}/assign`: Assign a report to a staff member.
3.  **API Endpoints for Analytics:**
    *   `GET /api/admin/analytics/reports-overview`: Get total reports and reports by date.
    *   `GET /api/admin/analytics/area-insights`: Get report counts by area.
    *   `GET /api/admin/analytics/map-view`: Get report locations for map display.
    *   `GET /api/admin/analytics/outreach-performance`: Get outreach member performance stats.
4.  **API Endpoints for User Management:**
    *   `GET /api/admin/users`: Get all community users.
    *   `POST /api/admin/users`: Create a new community user.
    *   `GET /api/admin/staff`: Get all outreach members.
    *   `POST /api/admin/staff`: Create a new outreach member.

## Phase 5: Implementation

This phase involves writing the code for the features outlined above. I will start with Phase 2 after you approve this plan.
