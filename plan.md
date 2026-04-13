# BLOCKIQx Development Plan (Laravel Custom Backend)

This plan outlines the development of the BLOCKIQx platform, focusing on a custom Laravel backend to handle the Community App, Outreach Workflow, and Admin Command Center.

## ✅ Milestone 1: Core System (MVP Foundation)
**Goal:** Build working backend + basic admin + outreach workflow.

- [x] **Laravel Backend Setup:** API + Database configuration.
- [x] **Authentication System:**
    - [x] User and Staff Login/Logout APIs.
    - [x] Role-based access control (RBAC) implementation (Spatie).
- [x] **Case/Incident Module:**
    - [x] Create report (Community/Guest).
    - [x] Assign report to staff (Admin).
    - [x] Update report status (Staff).
- [x] **Admin Dashboard:**
    - [x] Web views for Reports, Users, and Staff management.
    - [x] Basic overview analytics.
- [x] **Outreach Worker Panel:**
    - [x] Mobile APIs for assigned reports and status updates.
    - [x] Web-based panel for staff reports.

## ✅ Milestone 2: Smart Operations Layer
**Goal:** Improve usability + introduce real-time + structured workflows.

- [x] **Real-time Updates:** Case status and assignments (Events/Broadcasting).
- [x] **Geo-location Support:** Store and track incident GPS coordinates (latitude/longitude).
- [x] **Notification System:** Alerts for outreach workers (Database/Mail notifications).
- [x] **Workflow Automation:** Auto-assignment based on location (ReportObserver).
- [x] **Improved Dashboard:** Web views updated with dynamic data and analytics.

## 🟦 Milestone 3: Public + Scale Features
**Goal:** Add community side + prepare for funding & scaling.

- [x] **Community Reporting API:** Support for email/phone and anonymous reporting.
- [x] **Media Upload:** Support for multiple images/videos in reports.
- [x] **Incident Categorization:** Categories and concern levels (High, Medium, Low).
- [x] **Reporting & Analytics:** Dynamic dashboards and analytics methods implemented.
- [x] **Multi-organization Support:** Organization model and multi-tenancy foundation (organization_id).
