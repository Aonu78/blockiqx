# BLOCKIQx Flutter Mobile App

A Flutter mobile application for the BLOCKIQx Incident Reporting & Management Platform.

## Features

### Community Users
- Login with email/password or continue as Guest
- Submit incident reports with:
  - Incident type selection (12 categories)
  - Full description
  - Location (manual entry or GPS auto-detect)
  - Photo/video media attachments (up to 5 files)
  - Anonymous submission option
- View nearby help/support resources

### Staff / Outreach Workers
- Dedicated staff login
- Dashboard with report statistics (Total, Pending, In Progress, Completed)
- Filter reports by status
- View full report details
- Update report status with one tap:
  - `In Progress`
  - `Arrived at location` (captures GPS coordinates)
  - `Work started`
  - `Completed` (captures GPS coordinates)

## Setup

### 1. Prerequisites
- Flutter SDK 3.0+
- Android Studio / Xcode
- Dart SDK

### 2. Configure the API URL

Edit `lib/config/api_config.dart` and update `baseUrl`:

```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:5000/api';
```

Replace `YOUR_SERVER_IP` with your server's IP address or domain.

**For local development:**
- Android emulator: `http://10.0.2.2:5000/api`
- Physical device: `http://YOUR_LOCAL_IP:5000/api`
- Production: `https://your-domain.replit.app/api`

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

```bash
# Android
flutter run

# iOS
flutter run --target lib/main.dart
```

## Project Structure

```
lib/
├── main.dart                   # App entry point & router
├── config/
│   └── api_config.dart         # API base URL and endpoints
├── models/
│   ├── user.dart               # Community user model
│   ├── staff.dart              # Staff member model
│   └── report.dart             # Incident report model
├── services/
│   └── api_service.dart        # HTTP API calls
├── providers/
│   └── auth_provider.dart      # Auth state management
├── screens/
│   ├── auth/
│   │   ├── role_select_screen.dart    # Initial role selection
│   │   ├── login_screen.dart          # Community user login
│   │   └── staff_login_screen.dart    # Staff login
│   ├── community/
│   │   ├── home_screen.dart           # Community home/dashboard
│   │   ├── submit_report_screen.dart  # Submit new report
│   │   └── nearby_resources_screen.dart # Nearby help resources
│   └── staff/
│       ├── staff_dashboard_screen.dart # Staff report list
│       └── report_detail_screen.dart   # Report detail + status update
└── widgets/
    ├── report_card.dart         # Reusable report card
    └── status_badge.dart        # Status & concern level badges
```

## Default Test Credentials

- **Admin User:** `admin@blockiqx.com` / `password`
- **Staff User:** `staff@blockiqx.com` / `password`

## Permissions Required

### Android
- `INTERNET` — API calls
- `ACCESS_FINE_LOCATION` — GPS for reports
- `CAMERA` — Photo capture
- `READ_EXTERNAL_STORAGE` — Media selection

### iOS
- Location When In Use
- Camera
- Photo Library
