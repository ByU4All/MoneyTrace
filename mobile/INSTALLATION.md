# MoneyTrace Flutter — Installation Guide

## Table of Contents
1. [Common Setup](#1-common-setup)
2. [Web Target (Fedora + Vivaldi)](#2-web-target-fedora--vivaldi)
3. [Android Target (Build on Desktop)](#3-android-target-build-on-desktop)
4. [Troubleshooting](#4-troubleshooting)

---

## 1. Common Setup

### Install Flutter SDK

```bash
mkdir -p ~/develop && cd ~/develop
curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.4-stable.tar.xz
tar xf flutter_linux_3.27.4-stable.tar.xz
rm flutter_linux_3.27.4-stable.tar.xz
```

Add to `~/.bashrc`:
```bash
export PATH="$HOME/develop/flutter/bin:$PATH"
```

Verify:
```bash
source ~/.bashrc
flutter --version
```

### Install Dependencies & Generate Code

```bash
cd mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## 2. Web Target (Fedora + Vivaldi)

### System Prerequisites

```bash
sudo dnf install git clang cmake ninja-build pkg-config gtk3-devel
```

### Set Vivaldi as Browser

Flutter looks for Chrome by default. Vivaldi is Chromium-based, so point Flutter at it:

```bash
echo 'export CHROME_EXECUTABLE=/usr/bin/vivaldi' >> ~/.bashrc
source ~/.bashrc
```

### Enable Web Platform

```bash
cd mobile
flutter create --platforms web .
```

### Add sql.js for Drift (Web Database)

Add this script tag to `web/index.html` **before** the `flutter.js` script:
```html
<script defer src="https://cdn.jsdelivr.net/npm/sql.js@1.8.0/dist/sql-wasm.js"></script>
```

Download the WASM file:
```bash
curl -Lo web/sql-wasm.wasm https://cdn.jsdelivr.net/npm/sql.js@1.8.0/dist/sql-wasm.wasm
```

### Run

```bash
flutter run -d chrome
```

Or headless web server:
```bash
flutter run -d web-server --web-port 8080
# Open http://localhost:8080
```

---

## 3. Android Target (Build on Desktop)

### Install Java 21

Gradle does **not** support Java 25. Java 17 or 21 is required.

```bash
# Fedora
sudo dnf install java-21-openjdk-devel

# Tell Flutter to use Java 21
flutter config --jdk-dir=/usr/lib/jvm/java-21-openjdk
```

### Install Android SDK (without Android Studio)

```bash
mkdir -p ~/Android/Sdk/cmdline-tools
cd ~/Android/Sdk/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-11076708_latest.zip
mv cmdline-tools latest
```

Add to `~/.bashrc`:
```bash
export ANDROID_HOME=~/Android/Sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH
```

Install SDK components:
```bash
source ~/.bashrc
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
sdkmanager --licenses
flutter config --android-sdk ~/Android/Sdk
```

### Install ADB (for device deployment)

```bash
# Fedora
sudo dnf install android-tools
```

### Verify Setup

```bash
flutter doctor
```

Expected: Flutter, Android toolchain, and Chrome should all show green checkmarks.

### Connect Device

1. Enable **Developer Options** on your Android phone (tap Build Number 7 times)
2. Enable **USB Debugging** in Developer Options
3. Connect phone via USB cable
4. Approve the debugging prompt on the phone

Verify:
```bash
adb devices       # Should list your device
flutter devices   # Should show your phone
```

### Build & Install

```bash
cd mobile

# Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Install directly to connected device
flutter install
```

### Share APK with Others

The release APK can be shared directly:
- Located at: `mobile/build/app/outputs/flutter-apk/app-release.apk`
- Share via WhatsApp, Telegram, Google Drive, etc.
- Recipients must enable "Install from unknown sources" on their phone

---

## 4. Troubleshooting

### "Unsupported class file major version 69"
Your Java version (25) is too new. Install and configure Java 21:
```bash
sudo dnf install java-21-openjdk-devel
flutter config --jdk-dir=/usr/lib/jvm/java-21-openjdk
```

### "Build failed due to use of deleted Android v1 embedding"
The Android project needs regeneration:
```bash
cd mobile
rm -rf android
flutter create --platforms=android .
```
Then update `android/settings.gradle` (AGP 8.7.0, Kotlin 2.0.21), `android/app/build.gradle` (NDK 27.0.12077973, Java 17 target), and `android/gradle/wrapper/gradle-wrapper.properties` (Gradle 8.12).

### "NDK version mismatch" warning
Set in `android/app/build.gradle` under the `android` block:
```gradle
ndkVersion = "27.0.12077973"
```

### `flutter devices` doesn't show phone (but `adb devices` does)
The Android SDK is incomplete. Flutter needs the full SDK, not just adb:
```bash
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
flutter config --android-sdk ~/Android/Sdk
```

### `flutter install` installs to Chrome
Flutter defaults to Chrome when the phone isn't detected. Fix the Android SDK setup (see above), then:
```bash
flutter install -d <device-id>    # use ID from `adb devices`
```

### `database.g.dart` not found
Run Drift code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### "Chrome not found"
Set `CHROME_EXECUTABLE` to your Chromium-based browser:
```bash
export CHROME_EXECUTABLE=/usr/bin/vivaldi
```

### sql.js errors on web
Ensure both the `<script>` tag in `web/index.html` and the `sql-wasm.wasm` file in `web/` are present.
