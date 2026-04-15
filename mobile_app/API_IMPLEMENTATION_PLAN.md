# BLOCKIQx Mobile App — API Implementation Plan

> **Last audited:** April 2026  
> **Legend:** ✅ Done · ⚠️ Implemented with bug · ❌ Missing

---

## Summary

| # | Method | Endpoint | Status | Screen |
|---|--------|----------|--------|--------|
| 1 | POST | `/api/login` | ✅ Done | `login_screen.dart` |
| 2 | POST | `/api/staff/login` | ✅ Done | `staff_login_screen.dart` |
| 3 | POST | `/api/logout` | ✅ Done | Home + Staff dashboard |
| 4 | POST | `/api/reports` | ⚠️ Bug | `submit_report_screen.dart` |
| 5 | GET  | `/api/reports/nearby` | ✅ Done | `nearby_resources_screen.dart` |
| 6 | GET  | `/api/staff/reports` | ✅ Done | `staff_dashboard_screen.dart` |
| 7 | GET  | `/api/staff/reports/{id}` | ⚠️ Bug | `report_detail_screen.dart` |
| 8 | PUT  | `/api/staff/reports/{id}` | ✅ Done | `report_detail_screen.dart` |
| 9 | GET  | `/api/admin/analytics/map-view` | ❌ Missing | Not built (admin only) |

---

## Detailed Breakdown

---

### 1. POST `/api/login` ✅ DONE

**Purpose:** Authenticate a community user, receive Sanctum token.

| Layer | File | Status |
|-------|------|--------|
| Service | `lib/services/api_service.dart` → `login()` | ✅ |
| Provider | `lib/providers/auth_provider.dart` → `loginUser()` | ✅ |
| Screen | `lib/screens/auth/login_screen.dart` | ✅ |

**Request sent:**
```json
{ "email": "user@example.com", "password": "password" }
```

**Response handled:**
- `data['token']` → stored in `AuthProvider._token` + `SharedPreferences`
- `data['user']` → parsed into `User` model
- `AuthMode.user` set in provider

**No issues found.**

---

### 2. POST `/api/staff/login` ✅ DONE

**Purpose:** Authenticate a staff member, receive Sanctum token.

| Layer | File | Status |
|-------|------|--------|
| Service | `lib/services/api_service.dart` → `staffLogin()` | ✅ |
| Provider | `lib/providers/auth_provider.dart` → `loginStaff()` | ✅ |
| Screen | `lib/screens/auth/staff_login_screen.dart` | ✅ |

**Request sent:**
```json
{ "email": "staff@blockiqx.com", "password": "password" }
```

**Response handled:**
- `data['token']` → stored in `AuthProvider._token`
- `data['staff']` → parsed into `Staff` model
- `AuthMode.staff` set — routes to `StaffDashboardScreen`

**No issues found.**

---

### 3. POST `/api/logout` ✅ DONE

**Purpose:** Revoke the Sanctum token on the server.

| Layer | File | Status |
|-------|------|--------|
| Service | `lib/services/api_service.dart` → `logout()` | ✅ |
| Provider | `lib/providers/auth_provider.dart` → `logout()` | ✅ |
| Screen (user) | `lib/screens/community/home_screen.dart` | ✅ |
| Screen (staff) | `lib/screens/staff/staff_dashboard_screen.dart` | ✅ |

**Behaviour:**
- Sends `Authorization: Bearer <token>` header
- On success or failure, clears token + user/staff from memory and `SharedPreferences`
- Navigates back to `RoleSelectScreen`

**No issues found.**

---

### 4. POST `/api/reports` ⚠️ BUG — NEEDS FIX

**Purpose:** Submit a new incident report. Works for both authenticated users and guests.

| Layer | File | Status |
|-------|------|--------|
| Service | `lib/services/api_service.dart` → `submitReport()` | ✅ |
| Screen | `lib/screens/community/submit_report_screen.dart` | ⚠️ Bug |

**Fields sent (multipart/form-data):**

| Field | Sent? | Notes |
|-------|-------|-------|
| `email` | ✅ | Guest only |
| `phone_number` | ✅ | Guest only |
| `incident_type` | ✅ | Dropdown with 12 types |
| `description` | ✅ | TextFormField |
| `location` | ✅ | Manual text or GPS address |
| `latitude` | ✅ | Optional GPS |
| `longitude` | ✅ | Optional GPS |
| `is_anonymous` | ✅ | Toggle switch |
| `media[]` | ✅ | Up to 5 image files |

**🐛 BUG — Line 125 in `submit_report_screen.dart`:**
```dart
// CURRENT (wrong) — sends "Authorization: Bearer " for guests
token: auth.token ?? '',

// FIXED — passes null so no Authorization header is sent for guests
token: auth.token,
```
The API accepts guest submissions with no auth header. An empty Bearer token header causes a `401 Unauthenticated` error on the server.

**Fix required in:** `lib/screens/community/submit_report_screen.dart` line 125.

---

### 5. GET `/api/reports/nearby` ✅ DONE

**Purpose:** Retrieve nearby help/support resources. Requires authentication.

| Layer | File | Status |
|-------|------|--------|
| Service | `lib/services/api_service.dart` → `getNearbyResources()` | ✅ |
| Screen | `lib/screens/community/nearby_resources_screen.dart` | ✅ |

**Query params sent:**
- `lat` — device GPS latitude (optional)
- `lng` — device GPS longitude (optional)

**Behaviour:**
- Tries to get GPS on screen open
- Falls back gracefully if location permission denied
- Displays results in a scrollable list

**No issues found.**

---

### 6. GET `/api/staff/reports` ✅ DONE

**Purpose:** Fetch all reports assigned to the authenticated staff member.

| Layer | File | Status |
|-------|------|--------|
| Service | `lib/services/api_service.dart` → `getStaffReports()` | ✅ |
| Screen | `lib/screens/staff/staff_dashboard_screen.dart` | ✅ |

**Behaviour:**
- Called on screen mount + pull-to-refresh + on return from detail screen
- Handles both `List` and `{ data: [...] }` / `{ reports: [...] }` response shapes
- Report list filtered client-side by status (All / Pending / In Progress / Completed)
- Stats panel shows counts of each status

**No issues found.**

---

### 7. GET `/api/staff/reports/{id}` ⚠️ BUG — NEEDS FIX

**Purpose:** Fetch the full details of a single report, including notes and all fields.

| Layer | File | Status |
|-------|------|--------|
| Service | `lib/services/api_service.dart` → `getStaffReportDetail()` | ✅ (exists) |
| Screen | `lib/screens/staff/report_detail_screen.dart` | ❌ NEVER CALLED |

**🐛 BUG — `report_detail_screen.dart` initState:**
```dart
// CURRENT (wrong) — uses stale list data, never fetches from API
@override
void initState() {
  super.initState();
  _report = widget.report;  // ← only uses passed-in object
}
```

**What's missing:** A `_fetchDetail()` method that calls `ApiService.getStaffReportDetail()` on screen open so the full report (including `notes`, `resolved_at_latitude`, contact info) is loaded fresh from the server.

**Fix required in:** `lib/screens/staff/report_detail_screen.dart` — add `_fetchDetail()` called in `initState`.

Also, after a successful status update, `result['report']` may not exist if the API returns the report at the top level. Need to handle both:
```dart
// Current (may fail if API returns report at top level)
_report = Report.fromJson(result['report']);

// Fixed — handle both response shapes
final reportJson = result['report'] ?? result;
_report = Report.fromJson(reportJson);
```

---

### 8. PUT `/api/staff/reports/{id}` ✅ DONE

**Purpose:** Update the status of a report. Sends GPS if status is `Completed` or `Arrived at location`.

| Layer | File | Status |
|-------|------|--------|
| Service | `lib/services/api_service.dart` → `updateReportStatus()` | ✅ |
| Screen | `lib/screens/staff/report_detail_screen.dart` → `_updateStatus()` | ✅ |

**Request sent:**
```json
{
  "status": "Completed",
  "latitude": 51.5074,
  "longitude": -0.1278
}
```

**Valid statuses sent:**
- `In Progress`
- `Arrived at location` → GPS captured ✅
- `Work started`
- `Completed` → GPS captured ✅

**No issues found in the service layer.** See fix needed above for parsing the response.

---

### 9. GET `/api/admin/analytics/map-view` ❌ NOT IMPLEMENTED

**Purpose:** Retrieves all report coordinates + staff locations for the admin heatmap.

| Layer | File | Status |
|-------|------|--------|
| Service | No method in `api_service.dart` | ❌ |
| Screen | No screen exists | ❌ |

**Decision:** This is an **admin-only** endpoint that requires an `admin` or `super-admin` role. The mobile app currently targets **community users** and **staff** only.

**Options:**
- **Option A (Recommended):** Keep as out-of-scope — admins use the web dashboard
- **Option B:** Add an Admin role to the app with a map screen using the `flutter_map` package

---

## Bugs to Fix (Priority Order)

### 🔴 Fix 1 — Guest token bug (submit_report_screen.dart line 125)

```dart
// File: lib/screens/community/submit_report_screen.dart
// Line 125 — Change:
token: auth.token ?? '',
// To:
token: auth.token,
```

**Impact:** Guest report submission always returns `401 Unauthenticated`. Guests cannot submit reports at all.

---

### 🔴 Fix 2 — Detail screen never loads from API (report_detail_screen.dart)

Add `_fetchDetail()` to `initState` and fix the update response parsing:

```dart
// In _ReportDetailScreenState — add these fields:
bool _loadingDetail = true;
String? _loadError;

// Add this method:
Future<void> _fetchDetail() async {
  setState(() { _loadingDetail = true; _loadError = null; });
  final token = context.read<AuthProvider>().token ?? '';
  try {
    final data = await ApiService.getStaffReportDetail(token, _report.id);
    setState(() { _report = Report.fromJson(data); _loadingDetail = false; });
  } catch (e) {
    setState(() { _loadError = e.toString(); _loadingDetail = false; });
  }
}

// Call it in initState:
@override
void initState() {
  super.initState();
  _report = widget.report;
  WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDetail());
}

// Fix the update response parser (line 68):
// Change:
_report = Report.fromJson(result['report']);
// To:
final reportJson = result.containsKey('report') ? result['report'] : result;
_report = Report.fromJson(reportJson);
```

**Impact:** Without this, staff see incomplete/stale data (missing notes, contact info, resolution coordinates).

---

## Files That Need Changes

| File | Fix # | Change needed |
|------|-------|---------------|
| `lib/screens/community/submit_report_screen.dart` | Fix 1 | Change `auth.token ?? ''` → `auth.token` on line 125 |
| `lib/screens/staff/report_detail_screen.dart` | Fix 2 | Add `_fetchDetail()` call + fix response parsing |

---

## Action Items Checklist

- [x] POST `/api/login` — User login
- [x] POST `/api/staff/login` — Staff login
- [x] POST `/api/logout` — Logout (user + staff)
- [x] POST `/api/reports` — Fixed guest token bug (`auth.token ?? ''` → `auth.token`)
- [x] GET `/api/reports/nearby` — Nearby resources
- [x] GET `/api/staff/reports` — Staff report list
- [x] GET `/api/staff/reports/{id}` — Wired up `_fetchDetail()` + loading/error states + fixed response parser
- [x] PUT `/api/staff/reports/{id}` — Update status + GPS capture + fixed `result['report']` parsing
- [ ] GET `/api/admin/analytics/map-view` — Out of scope (admin-only, handled by web dashboard)
