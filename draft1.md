# Plan: "Bus 3rd" — a parody bus app (Flutter, front-end only)

## Context
The goal is a deliberately-funny ("gag") mobile app that mimics a bus-arrival app but
shows absurd timings, lets you comedically "chope" (reserve) seats, displays a silly
"live" map, and fires prank notifications. It must be **approvable on both the Apple App
Store and Google Play**. The repo is already a freshly-scaffolded **Flutter** app
(default counter template at `lib/main.dart`, bundle id `com.example.bus_3rd`, no extra
dependencies). Flutter is the right call: one codebase ships to both stores.

Decisions confirmed with the user:
- **iOS builds:** user has a Mac (so iOS build/submit is done locally via Xcode).
- **Gags (all four):** fake arrival times, chope-a-seat, fake live map, prank notifications.
- **Branding:** fictional parody operator ("Bus 3rd Transit Co.") — never a real operator.
- **Monetization:** free, no ads (cleanest build + "no data collected" privacy story).

### The real risk: store approval
The hard part of "get it approved" is policy, not code. We design around it from day one:
- **Apple 4.2 Minimum Functionality / 4.3 Spam:** joke apps get rejected when thin. Mitigate
  by shipping several polished, interactive features (the four gags), persistent state, a
  settings screen, and a genuinely fun feel — not a single button.
- **Impersonation / trademark:** never use real transit operator names, logos, colours, or
  route numbers. Use the fictional "Bus 3rd Transit Co." brand everywhere.
- **Don't masquerade as a real utility:** list under **Entertainment** category (not
  Navigation/Travel), and state plainly in-app + in the store description that it's a
  parody/comedy app. This is the single most important framing decision.
- **Privacy:** front-end only, no accounts, no analytics, no location → declare
  "Data Not Collected" on both stores. A hosted **privacy policy URL is still required**
  by Apple even when nothing is collected.

## Approach (front-end only, no backend)
Keep dependencies minimal. All "live" data is faked locally with `Timer`s and seeded data;
no network calls, no API keys, fully offline.

### Dependencies to add (`pubspec.yaml`)
- `flutter_local_notifications` + `timezone` — scheduled prank notifications (local only, no server).
- `shared_preferences` — persist settings, favourite stops, "choped" seats.
- (dev) `flutter_launcher_icons`, `flutter_native_splash` — replace default Flutter icon/splash.
- State: plain Flutter (`ValueNotifier` / `setState`) — no heavy state library needed at this scale.
- **Map is faked** with `CustomPaint` + an animated bus marker over a stylized illustrated
  background. Deliberately avoid `google_maps_flutter` — no API key, no billing, no location
  permission, keeps privacy story clean.

### Proposed structure (replaces the default counter app in `lib/`)
```
lib/
  main.dart                 # runApp + notification init
  app.dart                  # MaterialApp, theme, routes, bottom-nav shell
  theme/app_theme.dart      # fictional brand colours/typography
  models/                   # BusStop, BusService, Arrival, Seat
  data/fake_data.dart       # seeded stops/services + gag generators (absurd times)
  services/
    arrival_simulator.dart  # Timer-driven absurd countdowns
    notification_service.dart # flutter_local_notifications wrapper + permission request
    prefs_service.dart      # shared_preferences wrapper
  screens/
    arrivals_screen.dart    # live board of fake services w/ silly countdowns
    stop_detail_screen.dart # one stop's arrivals + "chope a seat" entry
    chope_seat_screen.dart  # seat grid, tap to chope, comedic confirmation
    fake_map_screen.dart    # CustomPaint faux map, bus driving in circles/into the sea
    settings_screen.dart    # theme toggle, notification toggles, favourites
    about_screen.dart       # PARODY DISCLAIMER + version + privacy link
  widgets/                  # arrival_tile, seat_grid, bus_marker, etc.
```

### Build order
1. **Foundation:** add deps; replace `lib/main.dart` with the app shell + bottom nav; set
   brand theme; change app id from `com.example.bus_3rd` → e.g. `com.deployku.bus3rd`
   (Android `applicationId` in `android/app/build.gradle.kts`; iOS `PRODUCT_BUNDLE_IDENTIFIER`
   via Xcode/`project.pbxproj`); set display name "Bus 3rd".
2. **Gag features:** arrivals board → stop detail → chope seat → fake map → prank
   notifications. Wire persistence (favourites/choped seats/settings) via `prefs_service`.
3. **Approval polish:** app icon + splash (replace defaults); first-launch + About-screen
   **parody disclaimer**; ensure no real-operator references anywhere; write store copy that
   says "parody/entertainment".
4. **Store prep:** publish a simple privacy-policy page (any static host) for the required URL;
   prepare screenshots; set category = Entertainment, age rating, "Data Not Collected".
5. **Build & submit:**
   - Android: create upload keystore → `flutter build appbundle` → Play Console
     (Internal Testing track first). Play Console = $25 one-time.
   - iOS (on Mac): configure signing in Xcode → `flutter build ipa` → upload to App Store
     Connect → TestFlight → submit for review. Apple Developer Program = $99/yr.

## Files to be modified/created
- `pubspec.yaml` — add dependencies + assets/icon config.
- `lib/main.dart` — rewrite (remove counter demo).
- New files under `lib/` per structure above.
- `android/app/build.gradle.kts` — applicationId, signing config.
- iOS project (`ios/Runner.xcodeproj/project.pbxproj` / Xcode) — bundle id, display name,
  notification capability.
- `test/widget_test.dart` — replace the counter test with real smoke tests.
- `README.md` — run/build/submit instructions.

## Verification
- `flutter analyze` clean; `flutter test` passes (replace default counter test).
- `flutter run` on an Android emulator/device: navigate all screens, confirm absurd
  countdowns tick, chope-a-seat works, faux map animates, and a prank notification fires
  (after granting permission).
- On Mac: `flutter run` on iOS Simulator/device for parity.
- Release builds succeed: `flutter build appbundle` and (on Mac) `flutter build ipa`.
- Pre-submission checklist: no real-operator branding; parody disclaimer visible;
  Entertainment category; privacy policy URL live; "Data Not Collected" declared.

## Open follow-ups (later, optional)
- Backend only if you later want shareable/leaderboard/remote gag content — not needed for v1.
- Monetization can be revisited (ads/IAP) after approval; v1 stays free/no-ads.
