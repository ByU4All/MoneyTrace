# MoneyTrace Mobile App

> **Version**: v0.2.0 (Flutter)
> **Created**: February 13, 2026
> **Last Updated**: March 3, 2026
> **Status**: Built and deployed to device

---

## Overview

MoneyTrace mobile is a native Android app built with **Flutter + Dart**, using **Drift** (SQLite) for local storage and **Riverpod** for state management. It is a full rewrite of the Python/FastAPI PWA into a standalone mobile app. All data stays on-device — no cloud sync.

---

## Decision History

### Framework Choice

Initially evaluated 4 options:

| Option | Verdict |
|--------|---------|
| React Native + SQLite | Good ecosystem, requires JS rewrite |
| Capacitor (wrap PWA) | Fastest but WebView limitations |
| Kivy (keep Python) | Non-native feel, large APK |
| BeeWare/Toga | Immature ecosystem |

**Chose Flutter** — best native performance, strong typing with Dart, excellent SQLite support via Drift, single codebase for Android/iOS.

### Theme Choice

Adopted **Nothing OS design language** (March 2026) to match the target device (Nothing Phone 3a):

| Element | Implementation |
|---------|---------------|
| Background | AMOLED true black (`#000000`) |
| Cards | No elevation, 1px `white@8%` border |
| Buttons | Pill-shaped (borderRadius: 24) |
| Inputs | Outline border, no fill |
| Typography | Space Grotesk (Google Fonts) |
| Accent | Nothing red (`#D72638`) |
| Status colors | Muted/desaturated for AMOLED |

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.27.4 (Dart 3.6.2) |
| Database | Drift 2.x (SQLite via sqlite3_flutter_libs) |
| State Management | Riverpod 2.x |
| Typography | Google Fonts (Space Grotesk) |
| File I/O | path_provider, file_picker |
| Sharing | share_plus |
| IDs | uuid v4 |

---

## Project Structure

```
mobile/
├── lib/
│   ├── main.dart              # App entry point
│   ├── core/                  # Pure business logic (ported from Python)
│   │   ├── engine.dart        # Budget/balance calculations
│   │   ├── budget.dart        # Budget reset & carry-over
│   │   └── events.dart        # Enums: EventType, AccountType, etc.
│   ├── data/                  # Persistence layer
│   │   ├── database.dart      # Drift database + tables
│   │   ├── database.g.dart    # Generated Drift code
│   │   └── daos/              # Data access objects
│   ├── providers/             # Riverpod state providers
│   ├── screens/               # UI screens
│   │   ├── dashboard_screen.dart
│   │   ├── accounts_screen.dart
│   │   ├── add_event_screen.dart
│   │   ├── recurring_screen.dart
│   │   ├── loans_screen.dart
│   │   ├── credit_cards_screen.dart
│   │   ├── friends_screen.dart
│   │   ├── history_screen.dart
│   │   └── settings_screen.dart
│   ├── theme/                 # Centralized theming
│   │   ├── colors.dart        # Nothing OS color palette
│   │   └── app_theme.dart     # Full ThemeData config
│   └── widgets/               # Shared UI components
├── android/                   # Android project (v2 embedding)
│   ├── app/build.gradle       # AGP 8.7.0, Java 17, NDK 27
│   ├── settings.gradle        # Kotlin 2.0.21
│   └── gradle/wrapper/        # Gradle 8.12
├── web/                       # Web target (optional)
├── pubspec.yaml               # Dependencies
├── README.md
└── INSTALLATION.md            # Setup guides (web, Android)
```

---

## Build & Deploy

### Prerequisites

- Flutter SDK 3.27.4+
- Android SDK with platform-tools, platforms;android-34, build-tools;34.0.0
- Java 17 or 21 (Java 25 is NOT compatible with Gradle)
- NDK 27.0.12077973 (required by plugins)

### Build Commands

```bash
cd mobile

# Install dependencies
flutter pub get

# Generate Drift database code (after schema changes)
dart run build_runner build --delete-conflicting-outputs

# Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk (25.5MB)

# Install to connected device
flutter install

# Run in debug mode with hot reload
flutter run
```

### Java/Gradle Compatibility

| Java Version | Gradle | AGP | Status |
|-------------|--------|-----|--------|
| 25 | Any | Any | NOT supported |
| 21 | 8.12 | 8.7.0 | Working |
| 17 | 8.12 | 8.7.0 | Working |

If using Java 25 on Fedora, install Java 21 and configure Flutter:
```bash
sudo dnf install java-21-openjdk-devel
flutter config --jdk-dir=/usr/lib/jvm/java-21-openjdk
```

### Distribution

**Direct APK sharing** (simplest):
- Share `build/app/outputs/flutter-apk/app-release.apk` via WhatsApp/Telegram/Drive
- Recipients enable "Install from unknown sources"

**GitHub Releases**:
```bash
gh release create v0.2.0 mobile/build/app/outputs/flutter-apk/app-release.apk \
  --title "MoneyTrace v0.2.0" --notes "Nothing OS themed release"
```

**Play Store** (requires additional setup):
1. Google Play Developer account ($25 one-time)
2. Generate release keystore (debug keys won't be accepted)
3. Build AAB: `flutter build appbundle --release`
4. Create store listing with screenshots, privacy policy
5. Submit for review (1-7 days for first app)

---

## Android Project Configuration

Key settings in `android/app/build.gradle`:
- `namespace`: `com.example.moneytrace`
- `compileSdk`: Flutter default
- `ndkVersion`: `27.0.12077973`
- `sourceCompatibility`: Java 17
- `kotlinOptions.jvmTarget`: `17`
- Signed with debug keys (release signing needed for Play Store)

Key settings in `android/settings.gradle`:
- AGP: `8.7.0`
- Kotlin: `2.0.21`
- Gradle: `8.12` (via `gradle-wrapper.properties`)

---

## Theme Architecture

All theming is centralized in 2 files:

1. **`lib/theme/colors.dart`** — `AppColors` class with static const fields
2. **`lib/theme/app_theme.dart`** — `AppTheme` class building `ThemeData`

All screen files reference `AppColors.fieldName`. Field names are stable — changing theme only requires editing these 2 files.

### Nothing OS Color Palette

| Field | Hex | Usage |
|-------|-----|-------|
| `background` | `#000000` | Scaffold, AMOLED black |
| `surface` | `#0D0D0D` | Cards, sheets, dialogs |
| `surfaceLight` | `#1A1A1A` | Chips, avatars |
| `card` | `#0D0D0D` | Card backgrounds |
| `accent` | `#D72638` | Primary action color |
| `accentLight` | `#E8485A` | Hover/lighter variant |
| `primary` | `#1A1A1A` | Neutral dark |
| `primaryLight` | `#2A2A2A` | Secondary buttons |
| `textPrimary` | `#EDEDED` | Main text |
| `textSecondary` | `#8C8C8C` | Subtitles |
| `textMuted` | `#555555` | Hints, placeholders |
| `success` | `#4CAF7D` | Muted sage green |
| `danger` | `#D72638` | Same as accent |
| `warning` | `#D4A843` | Muted amber |
| `info` | `#5B9BD5` | Soft steel blue |

---

## Troubleshooting

### "Unsupported class file major version 69"
Java 25 is too new for Gradle. Use Java 17 or 21:
```bash
flutter config --jdk-dir=/usr/lib/jvm/java-21-openjdk
```

### "Build failed due to use of deleted Android v1 embedding"
Regenerate the Android project:
```bash
cd mobile
rm -rf android
flutter create --platforms=android .
```
Then set NDK, AGP, Kotlin, and Java versions as documented above.

### "NDK version mismatch"
Set in `android/app/build.gradle`:
```gradle
ndkVersion = "27.0.12077973"
```

### `flutter devices` doesn't show phone
Install ADB: `sudo dnf install android-tools`
Check: `adb devices` — approve USB debugging prompt on phone.

### `flutter install` installs to Chrome instead of phone
Flutter can't detect the phone. Ensure Android SDK is fully set up and `flutter doctor` shows the Android toolchain as green.

---

*Last Updated: March 3, 2026*
