# BLOCKIQx API Documentation

This document outlines the available API endpoints for the BLOCKIQx platform.

## Authentication

### User Authentication

*   **POST `/api/login`**
    *   **Description:** Authenticates a community user.
    *   **Request Body:**
        *   `email` (string, required)
        *   `password` (string, required)
    *   **Response:**
        *   `token` (string): Sanctum API token for authentication.
        *   `user` (object): The authenticated user object.

*   **POST `/api/staff/login`**
    *   **Description:** Authenticates a staff member.
    *   **Request Body:**
        *   `email` (string, required)
        *   `password` (string, required)
    *   **Response:**
        *   `token` (string): Sanctum API token for authentication.
        *   `staff` (object): The authenticated staff object.

*   **POST `/api/logout`**
    *   **Description:** Logs out the authenticated user (user or staff). Requires Sanctum token.
    *   **Response:** `message` (string).

## Reports

### Community/Guest Reports

*   **POST `/api/reports`**
    *   **Description:** Creates a new report. Can be submitted by authenticated users or guests.
    *   **Request Body:**
        *   `email` (string, required if not authenticated)
        *   `phone_number` (string, required if not authenticated)
        *   `incident_type` (string, required)
        *   `description` (string, required)
        *   `location` (string, required)
        *   `latitude` (numeric, optional)
        *   `longitude` (numeric, optional)
        *   `media` (file, optional): Multiple files allowed (jpg, jpeg, png, mp4, mov, max 20MB each).
        *   `is_anonymous` (boolean, optional)
    *   **Response:**
        *   `message` (string)
        *   `report_id` (integer)

*   **GET `/api/reports/nearby`**
    *   **Description:** Retrieves nearby help/support resources. Requires authentication.
    *   **Query Parameters:** (Optional, e.g., `?lat=...&lng=...`)
    *   **Response:** Array of resource objects.

### Staff Reports

*   **Requires `auth:sanctum` token for staff.**
*   **GET `/api/staff/reports`**
    *   **Description:** Retrieves all reports assigned to the authenticated staff member.
    *   **Response:** Array of report objects.

*   **GET `/api/staff/reports/{report}`**
    *   **Description:** Retrieves details of a specific report assigned to the authenticated staff member.
    *   **Path Parameters:** `report` (integer, required) - Report ID.
    *   **Response:** Report object.

*   **PUT `/api/staff/reports/{report}`**
    *   **Description:** Updates the status of an assigned report. Captures staff's browser coordinates if status is 'Completed' or 'Arrived at location'.
    *   **Path Parameters:** `report` (integer, required) - Report ID.
    *   **Request Body:**
        *   `status` (string, required): One of 'In Progress', 'Completed', 'Arrived at location', 'Work started'.
        *   `latitude` (numeric, optional): Staff's current latitude (captured if status is 'Completed'/'Arrived at location').
        *   `longitude` (numeric, optional): Staff's current longitude (captured if status is 'Completed'/'Arrived at location').
    *   **Response:**
        *   `message` (string)
        *   `report` (object): Updated report object including `resolved_at_latitude` and `resolved_at_longitude` if captured.

## Admin Panel APIs

*   **Requires `auth:sanctum` token for admin/super-admin.**
*   **GET `/api/admin/analytics/map-view`**
    *   **Description:** Retrieves report coordinates with optional filters (date, status, type, organization) and staff locations.
    *   **Query Parameters:**
        *   `date_from` (date, optional)
        *   `date_to` (date, optional)
        *   `status` (string, optional): Filter by report status.
        *   `incident_type` (string, optional): Filter by incident type.
        *   `organization_id` (integer, optional): Filter by organization.
    *   **Response:**
        *   `reports` (array): Array of report objects including `latitude`, `longitude`, `resolved_at_latitude`, `resolved_at_longitude`.
        *   `staff` (array): Array of staff objects including `latitude`, `longitude` (if available).
