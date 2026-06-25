# MoneyTrace Mobile (Flutter)

Native Android finance tracker built with Flutter. Nothing OS-inspired dark theme with AMOLED black, red accent, and Space Grotesk typography.

## Quick Start

```bash
cd mobile

# Install dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# Run on connected device
flutter run

# Build release APK
flutter build apk --release

# Install to device
flutter install
```

## Requirements

- Flutter 3.27.4+
- Android SDK (platform-tools, platforms;android-34, build-tools;34.0.0)
- Java 17 or 21 (**not** Java 25 — incompatible with Gradle)
- NDK 27.0.12077973

## Architecture

```
lib/
├── core/          # Pure business logic (no I/O)
├── data/          # Drift database, tables, DAOs
├── providers/     # Riverpod state management
├── screens/       # All app screens
├── theme/         # Centralized Nothing OS theme
│   ├── colors.dart    # Color palette
│   └── app_theme.dart # ThemeData + Space Grotesk
└── widgets/       # Shared components
```

## Theme

Nothing OS design language:
- **AMOLED black** background (`#000000`)
- **Red accent** (`#D72638`) — Nothing's signature color
- **Border-based cards** — no elevation, subtle `white@8%` border
- **Pill buttons** — borderRadius: 24
- **Outline inputs** — no fill, 1px border
- **Space Grotesk** — geometric sans-serif via Google Fonts

Theme is fully centralized in `lib/theme/`. All screens reference `AppColors.*` by name — changing theme requires editing only `colors.dart` and `app_theme.dart`.

## Key Dependencies

| Package | Purpose |
|---------|---------|
| drift | SQLite ORM |
| sqlite3_flutter_libs | Native SQLite |
| flutter_riverpod | State management |
| google_fonts | Space Grotesk typography |
| intl | Date/currency formatting |
| uuid | UUID v4 generation |
| file_picker | Import/export |
| share_plus | Share data |

## Android Build Configuration

| Setting | Value |
|---------|-------|
| AGP | 8.7.0 |
| Kotlin | 2.0.21 |
| Gradle | 8.12 |
| Java target | 17 |
| NDK | 27.0.12077973 |
| Min SDK | Flutter default |
| Compile SDK | Flutter default |

## See Also

- [INSTALLATION.md](./INSTALLATION.md) — Detailed setup for web and Android targets
- [../MOBILE_APP.md](../MOBILE_APP.md) — Full project documentation, decision history, troubleshooting
