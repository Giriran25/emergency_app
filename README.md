# SERO - Smart Emergency Response Orchestrator

SERO is a role-based Flutter emergency response platform that connects citizens, ambulance drivers, traffic controllers, and admins in one coordinated workflow. It combines real-time updates, map-based situational awareness, and Firebase-backed data synchronization to reduce response friction during critical incidents.

## Key Capabilities

- Role-based authentication and access control (Citizen, Driver, Traffic Controller, Admin).
- Citizen emergency workflow with:
  - Emergency category selection.
  - Live location detection and reverse geocoding.
  - SOS trigger with incident metadata.
  - In-app live tracking UI for dispatch visibility.
- Driver operations dashboard with:
  - Real-time incoming emergency alerts.
  - Accept/pickup/complete emergency state transitions.
  - Tactical mission card and map context.
- Traffic controller interface for corridor clearance workflow.
- Admin panel UI for system-level visibility (current implementation includes static showcase widgets and can be connected to live collections).

## Tech Stack

- Flutter (Dart)
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Google Maps Flutter
- Geolocator + Geocoding

## Project Architecture

The codebase is organized by feature and role:

- `lib/main.dart`: App bootstrap and Firebase initialization.
- `lib/screens/auth/`: Registration and login flows.
- `lib/screens/citizen/`: Citizen home, triage, emergency type, profile, and tracking screens.
- `lib/screens/driver/`: Driver mission and response management screen.
- `lib/screens/traffic_controller/`: Traffic coordination dashboard.
- `lib/screens/admin/`: Admin operations UI.
- `lib/services/`: Firebase auth and Firestore service layer.
- `lib/core/`: Shared constants and theme primitives.
- `lib/widgets/`: Reusable UI components.

## Firestore Data Model (Current App Usage)

Primary collections used in the current implementation:

- `users`
  - `uid`, `name`, `email`, `phone`, `role`, `age`, `bloodGroup`, `emergencyContact`, timestamps
- `emergency_alerts`
  - `citizenId`, `citizenName`, `citizenBlood`, `locationName`, `type`, `status`, `driverId`, `driverName`, `eta`, `timestamp`
- `emergencies` (service-layer support)
  - `userId`, `userName`, `location`, `type`, `status`, timestamps

## Prerequisites

- Flutter SDK (stable channel)
- Dart SDK (compatible with Flutter)
- Android Studio or VS Code with Flutter tooling
- Firebase project configured for your target platforms
- Google Maps API key configured for Android/iOS (and web if used)

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/Giriran25/emergency_app.git
cd emergency_app
```

2. Install dependencies:

```bash
flutter pub get
```

3. Configure Firebase:

- Ensure Firebase app registrations exist for Android/iOS/Web as needed.
- Verify platform files are present and valid:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist` (if iOS build is required)
- Re-run FlutterFire CLI if you need to regenerate options:

```bash
flutterfire configure
```

4. Configure Maps keys:

- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/AppDelegate.swift` and/or `ios/Runner/Info.plist`

5. Run the app:

```bash
flutter run
```

## Current Status Notes

- Multiple screens are production-style UI prototypes and already wired to Firebase in key flows.
- Some files are placeholders for future domain expansion (for example, selected model/router/widget files).
- `main.dart` currently starts at registration for onboarding-first testing.

## Security and Production Readiness

- Review and rotate any exposed API keys before production release.
- Add strict Firebase Authentication and Firestore security rules.
- Add server-side validation for emergency lifecycle transitions.
- Add monitoring, analytics, and incident audit trails.

## Roadmap Suggestions

- Full backend orchestration for dispatch prioritization.
- Push notifications for all roles.
- Offline support and retry queue for weak network regions.
- End-to-end test suite for emergency state transitions.

## Contributing

Open source contributions are welcome.

If you want to contribute:

1. Fork the repository.
2. Create a feature branch.
3. Commit your changes with clear messages.
4. Open a pull request with context, screenshots, and test notes.

Please keep changes focused and include relevant tests where possible.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for full text.
