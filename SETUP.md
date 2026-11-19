# Setup & Build Instructions

This document provides complete instructions for setting up your development environment and compiling **Neko Music** from source.

---

## Prerequisites

Ensure you have the following installed on your workstation:

1. **Java Development Kit (JDK)**: **JDK 21** (Eclipse Adoptium Temurin 21 or Android Studio embedded JDK).
2. **Android Studio**: Android Studio Ladybug (2024.2.1) or newer recommended.
3. **Android SDK & NDK**:
   - **compileSdk**: `37`
   - **targetSdk**: `36`
   - **minSdk**: `26` (Android 8.0+)
   - **NDK Version**: `28.2.13676358` (installed via Android Studio SDK Manager $\rightarrow$ SDK Tools $\rightarrow$ NDK)
   - **CMake**: `3.22.1` or newer
4. **Git**: Installed and available in your terminal path.

---

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/PurveshShinde/Neko-Music.git
cd Neko-Music
```

### 2. Configure `local.properties`

Create a `local.properties` file in the root directory pointing to your Android SDK and NDK installations:

```bash
# On Linux / macOS
cp local.properties.template local.properties

# On Windows PowerShell
Copy-Item local.properties.template local.properties
```

Edit `local.properties`:

```properties
sdk.dir=C:\\Users\\<your-username>\\AppData\\Local\\Android\\Sdk
# Optional if installed in standard SDK path:
ndk.dir=C:\\Users\\<your-username>\\AppData\\Local\\Android\\Sdk\\ndk\\28.2.13676358
```

---

## Build Variants & Flavors

Neko Music supports two product flavors across different CPU architectures:

| Flavor | Description | Dependencies |
| :--- | :--- | :--- |
| **`foss`** | **100% Free and Open Source**. Excludes proprietary Google libraries. Uses stubs for Google Cast and disables Firebase. Ideal for F-Droid and de-Googled devices. | Pure open-source |
| **`gms`** | Standard build with Google Play Services integration, Google Cast support, and optional Firebase Crashlytics reporting. | Google Play Services |

### Common Build Tasks

#### 1. FOSS Builds (Recommended for local development)

```bash
# Assemble 64-bit ARM debug APK (fastest build for physical devices)
./gradlew assembleArm64FossDebug

# Assemble universal FOSS debug APK (includes all ABIs)
./gradlew assembleUniversalFossDebug

# Windows PowerShell:
.\gradlew.bat assembleArm64FossDebug
```

Output APK will be located at:
`app/build/outputs/apk/arm64Foss/debug/app-arm64-foss-debug.apk`

#### 2. GMS Builds

```bash
# Debug build with Google Play Services & Cast
./gradlew assembleArm64GmsDebug

# Universal GMS debug
./gradlew assembleUniversalGmsDebug
```

---

## Optional Configurations

### 1. Firebase Crashlytics & Analytics (GMS only)

If building the `gms` flavor with your own Firebase project:
1. Create an Android application in the [Firebase Console](https://console.firebase.google.com/) with package name `neko.music.app` (and `neko.music.app.debug`).
2. Download `google-services.json` and place it in the [`app/`](app/) directory.
3. If no `google-services.json` is present or if building the `foss` flavor, Firebase features are automatically disabled by Gradle.

### 2. AI Lyrics Translation API Keys

Neko Music supports real-time translation of foreign language lyrics via LLM providers:
1. Obtain an API key from [OpenRouter](https://openrouter.ai/), [DeepL](https://www.deepl.com/), or [Mistral AI](https://mistral.ai/).
2. In the app, navigate to **Settings $\rightarrow$ AI Settings**.
3. Select your desired provider and paste your API key.

### 3. Release Signing

To sign release builds, specify the signing credentials in your environment variables or in `gradle.properties`:

```properties
KEYSTORE_PATH=/path/to/your/release.keystore
STORE_PASSWORD=your_keystore_password
KEY_ALIAS=your_key_alias
KEY_PASSWORD=your_key_password
```

Then compile:
```bash
./gradlew assembleArm64FossRelease
```

---

## Troubleshooting

### 1. `SDK location not found`
Ensure `local.properties` exists in the repository root and contains an absolute path to your Android SDK using escaped backslashes on Windows (`C:\\Users\\...\\Sdk`).

### 2. Room Auto-Migration Error (`Schema 'x.json' required for migration was not found`)
Historical database schemas are stored in [`core/schemas/neko.music.app.db.InternalDatabase/`](core/schemas/neko.music.app.db.InternalDatabase/). Ensure this directory contains all versioned JSON files (`1.json` through the latest version).

### 3. JNI / NDK CMake Compilation Failures
Verify that NDK `28.2.13676358` and CMake are properly installed in the Android SDK Manager. The USB DAC module (`:usbaudio`) compiles C++20 code via CMake.

### 4. Gradle Daemon Memory / Sockets
If Gradle fails to connect to its daemon on Windows due to sandbox or local socket restrictions, run with `--no-daemon`:
```powershell
.\gradlew.bat assembleArm64FossDebug --no-daemon
```

---

## Code Style & Testing

Before submitting a Pull Request, verify your changes compile and pass tests:

```bash
# Run unit tests across all modules
./gradlew test

# Run Android lint
./gradlew lint
```
