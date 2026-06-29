# Bus 3rd 🚌

A **parody / comedy** bus app. It looks like a transit-arrivals app but everything is
deliberately wrong and silly — absurd arrival times, "chope" (reserve) a seat with a
tissue packet, a "live" map where the bus drives into the sea, and prank notifications.

> **It's a joke.** All timings, routes, stops, seats and notifications are fictional.
> Not affiliated with any real transit operator. Don't use it to catch a real bus.

## Features (the gags)
- **Arrivals board** — live, chaotic countdowns (negative minutes, `420m`, `soon™`, "napping").
- **Chope a seat** — tap empty seats to reserve them; random "aunties" steal seats over time.
- **Live Map™** — a hand-painted (no Google Maps / no API key) map with a wandering bus.
- **Prank notifications** — local-only funny alerts you can trigger from *More → Send a prank now*.

Front-end only: no backend, no accounts, no analytics, no ads, no location. Settings persist
locally via `shared_preferences`.

## Project layout
```
lib/
  main.dart                  # bootstrap: load prefs, init notifications, runApp
  app.dart                   # MaterialApp + bottom-nav shell + first-launch disclaimer
  theme/app_theme.dart       # brand palette (fictional Bus 3rd Transit Co.)
  models/bus_models.dart     # BusStop, BusService, FakeArrival, CrowdLevel
  data/fake_data.dart        # seeded stops/services + gag text generators
  services/
    app_state.dart           # settings/favourites (ChangeNotifier + AppScope)
    arrival_simulator.dart   # Timer-driven chaotic countdowns
    notification_service.dart# flutter_local_notifications wrapper (local only)
  screens/                   # arrivals, stop_detail, chope_seat, fake_map, settings, about
  widgets/                   # arrival_row, crowd_badge, map_painter
```

## Run locally
```bash
flutter pub get
flutter run                # pick an Android emulator/device or iOS simulator (on a Mac)
flutter analyze            # static analysis (clean)
flutter test               # widget + unit smoke tests
```

> **Windows note:** building with plugins needs Developer Mode enabled
> (`start ms-settings:developers`). Not required for `flutter analyze`/`flutter test`.

## App identity
- Display name: **Bus 3rd**
- App / bundle id: `com.deployku.bus3rd` (Android `applicationId`, iOS `PRODUCT_BUNDLE_IDENTIFIER`)
- Version: `1.0.0+1` (in `pubspec.yaml`)

## Store submission checklist
Designed to pass review as an **Entertainment** app (not Navigation/Travel).

- [ ] Replace default launcher icon + splash (e.g. add `flutter_launcher_icons` /
      `flutter_native_splash` with a Bus 3rd icon).
- [ ] Host a privacy policy page and wire its URL into `lib/screens/about_screen.dart`
      (search for the `TODO`). Apple requires a privacy policy URL even though we collect nothing.
- [ ] Store listing copy must say it's a **parody / comedy** app; category = **Entertainment**.
- [ ] Declare **"Data Not Collected"** on both App Store Connect and Play Console.
- [ ] No real operator names/logos/route numbers anywhere (keep the fictional brand).

### Android (buildable on Windows)
```bash
flutter build appbundle           # produces an .aab
```
Create an upload keystore, wire it into `android/app/build.gradle.kts` signing config, then
upload the `.aab` to Google Play Console (start with the Internal Testing track).
Play Console = US$25 one-time.

### iOS (requires macOS + Xcode)
```bash
flutter build ipa
```
Configure signing in Xcode, upload to App Store Connect (Transporter/Xcode), test via
TestFlight, then submit for review. Apple Developer Program = US$99/yr.
