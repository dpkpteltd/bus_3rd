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
- **AI nonsense (optional)** — never-repeating gags, an "Ask the Uncle" chatbot, a "Roast my
  commute" forecast, and a personalized Give Up certificate. See **AI integration** below.

Settings persist locally via `shared_preferences`.

## AI integration (optional, opt-in)
The app ships **fully offline by default** — no backend, no accounts, no analytics, no location.
An optional online mode adds AI-generated comedy, powered by **MiniMax** behind a **Supabase
Edge Function**:

- **Three-layer fallback** (`lib/services/ai/`): live AI → on-device template generator →
  the original static lists, so the app never breaks offline.
- **No key in the app.** A stateless **Supabase Edge Function** (`supabase/functions/ai/`) holds
  the MiniMax API key and exposes one endpoint with four actions
  (`gags`, `uncle`, `roast`, `certificate`). The app authenticates with the publishable
  Supabase **anon key**; the MiniMax key never leaves the function's secrets.
- **Opt-in.** Online mode is **off by default**, gated behind a settings toggle
  (*About → Online jokes*). When off, nothing leaves the device.

Deploy the function + set the MiniMax secret (see `supabase/README.md`), then run with your
project wired in:
```bash
flutter run \
  --dart-define=BUS3RD_SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=BUS3RD_SUPABASE_ANON_KEY=<your anon key>
```
With no `--dart-define`, the toggle is hidden and the app behaves exactly as the offline original.

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
- [ ] **Data collection declaration depends on whether you ship online AI mode:**
      - **Offline only** (don't compile in `BUS3RD_SUPABASE_URL`): declare **"Data Not Collected"** as before.
      - **With online AI mode:** typed text is sent to a third party (your Supabase Edge Function →
        MiniMax) to generate jokes. Declare it accordingly — Play Console *Data safety* and App Store Connect
        *App Privacy* should list "User content" used for **App functionality**, not linked to identity,
        not used for tracking. Update your hosted privacy policy to match `kPrivacyStatement`.
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
