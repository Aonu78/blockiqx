# BLOCKIQx Models Schema Documentation

This document outlines the schema and relevant details for each model in the BLOCKIQx platform.

## User Model

Represents a community user.

*   **Table:** `users`
*   **Traits:** `HasApiTokens`, `HasFactory`, `Notifiable`, `HasRoles`
*   **Fields:**
    *   `id` (BigInt, Primary Key, Auto-increment)
    *   `name` (String)
    *   `email` (String, Unique)
    *   `email_verified_at` (Timestamp, Nullable)
    *   `password` (String)
    *   `remember_token` (String, Nullable)
    *   `created_at` (Timestamp)
    *   `updated_at` (Timestamp)
*   **Relationships:**
    *   `hasMany(Report::class)` (Reports submitted by the user)
*   **Roles:** Can be assigned roles via Spatie's `HasRoles` trait.

---

## Staff Model

Represents an outreach worker or staff member.

*   **Table:** `staff`
*   **Traits:** `HasApiTokens`, `HasFactory`, `Notifiable`, `HasRoles`
*   **Fields:**
    *   `id` (BigInt, Primary Key, Auto-increment)
    *   `name` (String)
    *   `email` (String, Unique)
    *   `email_verified_at` (Timestamp, Nullable)
    *   `password` (String)
    *   `remember_token` (String, Nullable)
    *   `organization_id` (BigInt, Foreign Key to `organizations.id`, Nullable)
    *   `location` (String, Nullable) - Descriptive location text.
    *   `latitude` (Decimal, Nullable) - Staff's current or default location.
    *   `longitude` (Decimal, Nullable) - Staff's current or default location.
    *   `created_at` (Timestamp)
    *   `updated_at` (Timestamp)
*   **Relationships:**
    *   `belongsTo(Organization::class)` (The organization the staff member belongs to)
    *   `hasMany(Report::class, 'assigned_to')` (Reports assigned to this staff member)
*   **Roles:** Can be assigned roles via Spatie's `HasRoles` trait (e.g., 'staff').

---

## Report Model

Represents an incident report submitted by users or guests.

*   **Table:** `reports`
*   **Traits:** `HasFactory`
*   **Fields:**
    *   `id` (BigInt, Primary Key, Auto-increment)
    *   `email` (String, Nullable) - For guest reports
    *   `phone_number` (String, Nullable) - For guest reports
    *   `incident_type` (String)
    *   `description` (Text)
    *   `location` (String)
    *   `latitude` (Decimal, Nullable) - Initial report location.
    *   `longitude` (Decimal, Nullable) - Initial report location.
    *   `category` (String, Nullable)
    *   `concern_level` (Enum: 'Low', 'Medium', 'High', Default: 'Low')
    *   `media_paths` (JSON, Nullable) - Array of file paths for media uploads.
    *   `status` (String, Default: 'pending') - e.g., 'Pending', 'In Progress', 'Completed'.
    *   `user_id` (BigInt, Foreign Key to `users.id`, Nullable) - For authenticated user reports.
    *   `organization_id` (BigInt, Foreign Key to `organizations.id`, Nullable)
    *   `assigned_to` (BigInt, Foreign Key to `staff.id`, Nullable)
    *   `resolved_at_latitude` (Decimal, Nullable) - Coordinates captured when staff resolves the report.
    *   `resolved_at_longitude` (Decimal, Nullable) - Coordinates captured when staff resolves the report.
    *   `is_anonymous` (Boolean, Default: false)
    *   `notes` (JSON, Nullable) - Array of objects: `{user_id: int, note: string, timestamp: datetime}`.
    *   `created_at` (Timestamp)
    *   `updated_at` (Timestamp)
*   **Relationships:**
    *   `belongsTo(User::class)` (The user who submitted the report, if authenticated)
    *   `belongsTo(Organization::class)` (The organization the report belongs to)
    *   `belongsTo(Staff::class, 'assigned_to')` (The staff member assigned to the report)

---

## Organization Model

Represents an organization associated with staff and reports.

*   **Table:** `organizations`
*   **Traits:** `HasFactory`
*   **Fields:**
    *   `id` (BigInt, Primary Key, Auto-increment)
    *   `name` (String)
    *   `description` (Text, Nullable)
    *   `created_at` (Timestamp)
    *   `updated_at` (Timestamp)
*   **Relationships:**
    *   `hasMany(Staff::class)` (Staff members belonging to this organization)
    *   `hasMany(Report::class)` (Reports associated with this organization)

---

## Role Model (Spatie Permission)

Represents roles within the application.

*   **Table:** `roles`
*   **Fields:**
    *   `id` (BigInt, Primary Key, Auto-increment)
    *   `name` (String, Unique) - Role name (e.g., 'admin', 'staff', 'super-admin')
    *   `guard_name` (String, Default: 'web') - Guard associated with the role.
    *   `created_at` (Timestamp)
    *   `updated_at` (Timestamp)

---

## Permission Model (Spatie Permission)

Represents permissions within the application.

*   **Table:** `permissions`
*   **Fields:**
    *   `id` (BigInt, Primary Key, Auto-increment)
    *   `name` (String, Unique) - Permission name (e.g., 'manage reports', 'update status')
    *   `guard_name` (String, Default: 'web') - Guard associated with the permission.
    *   `created_at` (Timestamp)
    *   `updated_at` (Timestamp)
