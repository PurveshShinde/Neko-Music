# Setting Up and Running Neko Music

This document provides setup instructions for configuring your development environment, installing dependencies, executing the application across platforms, and compiling release binaries.

For general project information, architectural overview, and feature highlights, refer to [README.md](README.md).

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Asset and Code Generation](#asset-and-code-generation)
- [Running in Development](#running-in-development)
- [Building for Release](#building-for-release)
- [Permissions and Platform Configuration](#permissions-and-platform-configuration)
- [Troubleshooting](#troubleshooting)
- [Related Documents](#related-documents)

---

## Prerequisites

Ensure your system meets the requirements below before attempting to build or run Neko Music:

### General Requirements

- **Flutter SDK**: Version 3.8.0 or higher. Verify installation via `flutter --version`.
- **Dart SDK**: Included with Flutter.
- **Git**: Required for package retrieval and version control.

### Platform-Specific Tooling

#### Android

- **Android Studio** or **Android Command Line Tools** with Android SDK platform tools.
- **Android SDK Platform**: API Level 34 (compileSdk / targetSdk) with minimum supported API level 21 (Android 5.0).
- **Java Development Kit (JDK)**: JDK 17 (required for Gradle and Kotlin compilation).
- A connected physical Android device with USB debugging enabled, or an Android Virtual Device (AVD).

#### Linux

- **MPV Developer Libraries**: Required by `media_kit` for native audio rendering:
  ```bash
  sudo apt-get update
  sudo apt-get install -y libmpv-dev mpv libgtk-3-dev pkg-config cmake ninja-build clang
  ```

#### Windows

- **Visual Studio 2022**: Installed with the "Desktop development with C++" workload.

#### macOS

- **Xcode**: Version 14.0 or higher with command-line tools.
- **CocoaPods**: Installed via `sudo gem install cocoapods` or Homebrew.

---

## Initial Setup

1. **Clone the Repository**

   ```bash
   git clone https://github.com/PurveshShinde/Neko-Music.git
   cd Neko-Music
   ```

2. **Retrieve Dependencies**

   Fetch all Flutter packages and Git submodules declared in `pubspec.yaml`:

   ```bash
   flutter pub get
   ```

3. **Verify Environment Configuration**

   Check that all development toolchains are functional:

   ```bash
   flutter doctor -v
   ```

---

## Asset and Code Generation

Before running the application for the first time, generate launcher icons and native splash screens:

1. **Generate Launcher Icons**

   ```bash
   dart run flutter_launcher_icons
   ```

2. **Generate Native Splash Screen**

   ```bash
   dart run flutter_native_splash:create
   ```

---

## Running in Development

1. **List Connected Devices**

   Verify that your target emulator, device, or desktop runner is detected:

   ```bash
   flutter devices
   ```

2. **Start the Application**

   Run on the default connected device:

   ```bash
   flutter run
   ```

   Run on a specific device by ID:

   ```bash
   flutter run -d <DEVICE_ID>
   ```

3. **Development Controls**

   While the Flutter debug session is active in your terminal:
   - Press `r` to trigger Hot Reload.
   - Press `R` to trigger Hot Restart.
   - Press `v` to open Flutter DevTools.
   - Press `q` to terminate the session.

---

## Building for Release

### Android Release Builds

1. **Universal Release APK**

   Produces a single universal APK containing all supported architectures:

   ```bash
   flutter build apk --release
   ```

   Output path:
   `build/app/outputs/flutter-apk/app-release.apk`

2. **Split-Per-ABI APKs (Recommended for Distribution)**

   Produces separate APKs optimized for specific CPU architectures (`arm64-v8a`, `armeabi-v7a`, `x86_64`):

   ```bash
   flutter build apk --release --split-per-abi
   ```

   Output path:
   `build/app/outputs/flutter-apk/app-<abi>-release.apk`

3. **Android App Bundle (Google Play)**

   ```bash
   flutter build appbundle --release
   ```

   Output path:
   `build/app/outputs/bundle/release/app-release.aab`

### Desktop Release Builds

- **Windows**:
  ```bash
  flutter build windows --release
  ```
  Output path: `build/windows/runner/Release/`

- **Linux**:
  ```bash
  flutter build linux --release
  ```
  Output path: `build/linux/x64/release/bundle/`

- **macOS**:
  ```bash
  flutter build macos --release
  ```
  Output path: `build/macos/Build/Products/Release/`

---

## Permissions and Platform Configuration

Neko Music relies on background execution, lock screen integration, and storage access.

### Android Permissions (Declared in `AndroidManifest.xml`)

- `android.permission.INTERNET`: Required for metadata queries and audio stream extraction.
- `android.permission.FOREGROUND_SERVICE` and `FOREGROUND_SERVICE_MEDIA_PLAYBACK`: Required for continuous background playback and notification controls.
- `android.permission.POST_NOTIFICATIONS`: Required on Android 13+ (API 33+) to post media controls to the notification drawer.
- `android.permission.WAKE_LOCK`: Keeps CPU active while audio playback is in progress.
- `android.permission.READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE`: Used on Android 12 and below for saving downloaded audio files.

---

## Troubleshooting

### Issue: NewPipeExtractor Downloader Null Pointer Exception

- **Cause**: The NewPipe extractor requires initialization before making extractor queries.
- **Resolution**: `NewPipeExtractor.init()` is executed during `main()` in `lib/main.dart`. Ensure execution originates from the standard entry point.

### Issue: Java Version Mismatch During Gradle Build

- **Cause**: The Android Gradle Plugin requires JDK 17. Older Java versions cause compilation failures.
- **Resolution**: Confirm your active Java version with `java -version` and point `JAVA_HOME` to JDK 17.

### Issue: Missing MPV Libraries on Linux

- **Cause**: `media_kit` requires native `libmpv` headers on Linux desktop targets.
- **Resolution**: Run `sudo apt-get install libmpv-dev mpv` and verify installation with `mpv --version`.

### Issue: Background Playback Killed by Device

- **Cause**: Aggressive vendor battery managers terminate foreground services.
- **Resolution**: Disable battery optimization for Neko Music in system settings on test hardware.

---

## Related Documents

- [README.md](README.md) - Project overview and architecture.
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution process and standards.
- [DESIGN.md](DESIGN.md) - UI design language and theme architecture.
- [LICENSE](LICENSE) - MIT License terms and conditions.

