# NativeGo — Mobile App Source Code

A location-based platform connecting tourists with verified local people in
Nairobi, Kenya. Built with Flutter (Dart) following the object-oriented
design in Chapter 4 of the project documentation.

## What is implemented

- **Authentication & roles** — tourist / local provider registration and
  login, plus a seeded administrator account. Role-based home screens.
- **Provider discovery** — map (OpenStreetMap) with provider markers plus a
  searchable list, service-category filters, distance display.
- **Provider profiles** — bio, services, languages, hourly rate, aggregate
  rating, reviews, and a report button.
- **Service requests** — tourist sends a request; provider accepts/declines;
  status lifecycle pending → accepted → in progress → completed/cancelled
  with a progress timeline.
- **Messaging** — per-request chat between tourist and provider.
- **Reviews & reports** — 1–5 star reviews after completed services;
  user reports go to the administrator.
- **Admin panel** — provider verification queue (approve/reject), user list,
  reports handling, platform statistics.
- **Provider tools** — profile setup, service selection, availability toggle,
  verification document submission.

## Running the app

1. Install the Flutter SDK (>= 3.32): https://docs.flutter.dev/get-started/install
2. `cd app`
3. `flutter pub get`
4. `flutter run` (device/emulator) or `flutter build web` for a browser demo.

## Demo accounts (mock data — no backend needed)

| Role     | Email                  | Password |
|----------|------------------------|----------|
| Tourist  | tourist@demo.co.ke     | demo123  |
| Provider | david@demo.co.ke       | demo123  |
| Provider | faith@demo.co.ke       | demo123  |
| Admin    | admin@nativego.co.ke   | admin123 |

New accounts can also be registered from the login screen (choose
"Local provider" to exercise the verification flow: submit documents, then
log in as admin to approve).

## Notes for the project documentation

- The data layer (`lib/data/mock_repository.dart`) is an in-memory
  implementation whose API mirrors the Firestore collections
  (`users`, `providerProfiles`, `serviceRequests`, `messages`, `reviews`,
  `reports`), so switching to the Firebase backend from Chapter 3 requires
  no UI changes.
- The prototype map uses OpenStreetMap tiles via `flutter_map` (no API key
  needed); production uses the Google Maps Platform SDK per Chapter 3.
- `flutter analyze` is clean and `flutter test` passes (widget smoke test).

## Project structure

```
app/
  lib/
    main.dart            — app entry
    models/models.dart   — User, ProviderProfile, ServiceRequest,
                           ChatMessage, Review, Report
    data/mock_repository.dart — in-memory backend (singleton store)
    screens/             — splash, auth, tourist_home, provider_profile,
                           request_form, my_requests, chat_screen,
                           review_screen, provider_dashboard,
                           provider_setup, admin_panel
    widgets/common.dart  — status chips, star rating, shared widgets
  test/widget_test.dart  — launch smoke test
```
