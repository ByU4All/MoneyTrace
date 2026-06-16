# Publishing MoneyTrace to Google Play Store

Step-by-step guide to go from sideloaded APK to Play Store listing.

---

## 1. Pre-flight checklist

Before touching Play Console, fix the build config:

### Change applicationId

The current ID is `com.example.moneytrace` — Google Play rejects `com.example.*` packages.

In `mobile/android/app/build.gradle`, change **both** occurrences:

```groovy
namespace = "com.luke.dev.moneytrace"         // line 9
applicationId = "com.luke.dev.moneytrace"      // line 24
```

Also update the Kotlin package directory to match:

```bash
# Rename directory structure
cd mobile/android/app/src/main/kotlin
mv com/example/moneytrace com/example/moneytrace_old
mkdir -p com/luke/dev/moneytrace
mv com/example/moneytrace_old/MainActivity.kt com/luke/dev/moneytrace/
rm -rf com/example
```

Update the package declaration in `MainActivity.kt`:

```kotlin
package com.luke.dev.moneytrace
```

### Set version

In `mobile/pubspec.yaml`:

```yaml
version: 1.0.0+1    # format: versionName+versionCode
```

- **versionName** (`1.0.0`): shown to users on Play Store
- **versionCode** (`1`): integer, must increment with every upload

---

## 2. Generate release keystore

**Do this once. Back up the keystore and passwords. If you lose them, you can never update the app.**

```bash
keytool -genkey -v \
  -keystore ~/moneytrace-release.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias moneytrace
```

You'll be prompted for:
- **Keystore password** — choose a strong one, save it
- **Key password** — can be same as keystore password
- **Name, org, etc.** — fill in or leave defaults (not shown publicly)

Back up `~/moneytrace-release.jks` somewhere safe (encrypted cloud, USB drive, etc).

---

## 3. Configure signing

### Create `mobile/android/key.properties`

This file is already in `.gitignore` — it will NOT be committed.

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=moneytrace
storeFile=/absolute/path/to/moneytrace-release.jks
```

### Update `mobile/android/app/build.gradle`

Replace the entire file with:

```groovy
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.luke.dev.moneytrace"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.luke.dev.moneytrace"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        release {
            keyAlias = keystoreProperties['keyAlias']
            keyPassword = keystoreProperties['keyPassword']
            storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword = keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.release
        }
    }
}

flutter {
    source = "../.."
}
```

### Verify it builds

```bash
cd mobile
flutter clean
flutter build apk --release
```

If it signs correctly, you'll see `Built build/app/outputs/flutter-apk/app-release.apk`.

---

## 4. Build App Bundle (AAB)

Play Store requires AAB format (not APK):

```bash
cd mobile
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

This is what you upload to Play Console.

---

## 5. Google Play Console setup

### Create developer account

1. Go to [play.google.com/console](https://play.google.com/console)
2. Pay the **$25 one-time fee**
3. Complete identity verification (can take 1-2 days)

### Create app listing

1. **Create app** → name: "MoneyTrace", default language: English, app type: App, free
2. Fill in **Store listing**:
   - Short description (80 chars max): "Track expenses, loans, and budgets — fully offline, INR"
   - Full description: explain features, offline-first, no ads, no tracking
   - **App icon**: 512x512 PNG (use the launcher icon source)
   - **Feature graphic**: 1024x500 PNG (required)
   - **Screenshots**: minimum 2, recommended 4-8 phone screenshots
     - Take from Nothing Phone 3a for authentic look
     - Capture: home/summary, add expense, loans, budget screens
   - Category: Finance
   - Contact email: your email

3. **Content rating**: fill out the IARC questionnaire (takes 5 min, it's a personal finance app — all answers are basically "no")

4. **Privacy policy**: required for apps that handle financial data
   - Host a simple page (GitHub Pages works) stating:
     - All data stored locally on device
     - No data collected, transmitted, or shared
     - No analytics, no ads, no third-party services
   - Enter the URL in Play Console

5. **Target audience**: select 18+ (finance app)

6. **Data safety**: declare that the app:
   - Does NOT collect or share any user data
   - Data stored locally only
   - No account required

---

## 6. Upload and release

### Recommended: start with internal testing

1. Go to **Testing → Internal testing**
2. Create a new release
3. Upload `app-release.aab`
4. Google will sign it with a Play-managed key (opt into **Play App Signing** — this is required and happens automatically)
5. Add your email as a tester
6. Roll out to internal testing
7. Test the install via Play Store link

### Move to production

Once satisfied:

1. Go to **Production → Create new release**
2. Upload the same AAB (or a newer one)
3. Write release notes
4. Submit for review (first review takes 1-7 days)

---

## 7. Future updates

For each update:

1. **Bump version** in `mobile/pubspec.yaml`:
   ```yaml
   version: 1.1.0+2    # increment versionCode, update versionName
   ```
   The `+N` (versionCode) MUST increase with every Play Store upload.

2. **Build new AAB**:
   ```bash
   cd mobile
   flutter build appbundle --release
   ```

3. **Upload** to Play Console → Production → Create new release

4. **Update CHANGELOG.md** with what changed

---

## Quick reference

| Item | Value |
|---|---|
| applicationId | `com.luke.dev.moneytrace` |
| Keystore | `~/moneytrace-release.jks` |
| Key alias | `moneytrace` |
| Signing config | `mobile/android/key.properties` (gitignored) |
| AAB output | `mobile/build/app/outputs/bundle/release/app-release.aab` |
| Play Console | [play.google.com/console](https://play.google.com/console) |

---

## Screenshots with Demo Data

The app includes a built-in demo data seeder for taking Play Store screenshots without exposing personal data.

### Loading demo data

1. Open the app → Settings → Data tab
2. Tap **Load Demo Data** (camera icon, accent-colored button)
3. Confirm in the dialog — this replaces all existing data

### Recommended screenshot order

| # | Screen | What it shows |
|---|--------|---------------|
| 1 | Dashboard | Budget card, category spending breakdown, recent activity |
| 2 | Visual Summary | Donut chart, stats grid |
| 3 | Add Event | Expense form (navigate and fill in a sample) |
| 4 | Loans | Home loan & car loan with progress bars |
| 5 | History | Grouped transactions list |
| 6 | Accounts | Multiple account types (savings, current, cash, UPI, credit cards) |
| 7 | Friends | Mixed balances (owes you / you owe / settled) |
| 8 | Recurring | Active items with next due dates |

### Tips
- Take screenshots on the actual Nothing Phone 3a for authentic look
- Use portrait mode, full screen
- Play Store requires minimum 2 screenshots, recommended 4-8
- Phone screenshots should be 16:9 aspect ratio (1080x1920 or similar)
- After screenshots, restore your real data from a backup or clear demo data

---

## Files that need changes before first publish

| File | Change |
|---|---|
| `mobile/android/app/build.gradle` | applicationId, namespace, signing config |
| `mobile/android/app/src/main/kotlin/.../MainActivity.kt` | package name |
| `mobile/pubspec.yaml` | version to `1.0.0+1` |
