<p align="center">
  <img src="assets/icon.png" alt="Neko Music Icon" width="128" height="128" />
</p>

<h1 align="center">Neko Music</h1>

<p align="center">
  A sleek, ad-free, open-source music streaming client built with Flutter.<br>
  Engineered with high-fidelity native playback, AMOLED dark mode, and dynamic plugin architecture.
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=flat&logo=dart&logoColor=white" alt="Dart"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat" alt="MIT License"></a>
  <a href="https://github.com/KRTirtho/spotube"><img src="https://img.shields.io/badge/Architecture-Spotube%20Inspired-00A86B.svg?style=flat" alt="Spotube Architecture"></a>
</p>

<p align="center">
  <a href="#features">Features</a> &bull;
  <a href="SETUP.md">Setup &amp; Run</a> &bull;
  <a href="#architecture">Architecture</a> &bull;
  <a href="DESIGN.md">Design</a> &bull;
  <a href="CONTRIBUTING.md">Contributing</a> &bull;
  <a href="LICENSE">License</a>
</p>

---

## Overview

Neko Music is a fast, lightweight, and modern music streaming application built for Android and desktop platforms using Flutter. It is designed around user autonomy, offering an ad-free listening experience with pure pitch-black AMOLED theming, glassmorphic UI components, and real-time color extraction from album artwork.

The application leverages Hetu Script plugins (inspired by the Spotube backend architecture) to dynamically query track metadata, while routing audio streaming through local extractors and rendering via a high-performance native `media_kit` (libmpv) audio engine.

For complete setup, compilation, and troubleshooting instructions, refer to **[SETUP.md](SETUP.md)**.

---

## Documentation

The project documentation is organized across dedicated files:

| Document | Description |
| :--- | :--- |
| **[SETUP.md](SETUP.md)** | Step-by-step guide for prerequisites, development runs, and release builds |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | Guidelines for issues, code formatting, and pull requests |
| **[DESIGN.md](DESIGN.md)** | AMOLED styling, Liquid Glass components, and UI design principles |
| **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** | Contributor Covenant community behavioral standards |
| **[SECURITY.md](SECURITY.md)** | Vulnerability disclosure policy and supported versions |
| **[PRIVACY_POLICY.md](PRIVACY_POLICY.md)** | Data handling policies, zero-telemetry guarantee, and local storage |
| **[LICENSE](LICENSE)** | Full MIT License legal terms and third-party attributions |

---

## Features

- **Ad-Free Playback**: Stream without interruptions, sponsored banners, or promotional audio injections.
- **True AMOLED Dark Mode**: High-contrast, pure-black interface (`#000000`) optimized for OLED power savings.
- **Liquid Glass Aesthetic**: Glassmorphism elements, frosted blur sheets, and optional vintage film grain overlay.
- **Dynamic Palette Tinting**: Adaptive accent colors dynamically extracted from currently playing album art.
- **Native Audio Engine**: Low-latency, hardware-accelerated playback powered by `media_kit` (libmpv).
- **Dynamic Plugin Subsystem**: Hetu Script bytecode engine for dynamic Spotify metadata querying.
- **OS Media Integration**: Background execution, lock screen controls, and hardware media keys via `audio_service`.
- **Offline Storage**: Download tracks locally to an offline library with customizable storage locations.
- **Listen Together**: Synchronized group listening sessions.

---

## Architecture

Neko Music separates application concerns into clean, modular layers:

| Layer | Implementation | Responsibility |
| :--- | :--- | :--- |
| **UI & Theming** | Flutter Material 3, `palette_generator`, Google Fonts | Adaptive UI layouts, glassmorphic sheets, dynamic styling |
| **State Management** | Scoped Models / Custom `AppState` | Reactive playback state, user settings, cached collections |
| **Audio Pipeline** | `media_kit` (libmpv), `audio_service` | Cross-platform audio decoding, lock screen media integration |
| **Plugin Engine** | Hetu Script (`hetu_script`, `hetu_spotube_plugin`) | Sandboxed bytecode execution for Spotify API scrapers |
| **Audio Extraction** | `flutter_new_pipe_extractor`, `youtube_explode_dart` | Stream resolution and fallback audio extraction |
| **Data Persistence** | `shared_preferences`, `path_provider` | Local cache, favorites, playlists, and downloaded tracks |

---

## Quick Start

For full platform requirements (Android SDK, Linux MPV libraries, Windows C++ tools), consult **[SETUP.md](SETUP.md)**.

```bash
# Clone the repository
git clone https://github.com/PurveshShinde/Neko-Music.git
cd Neko-Music

# Install dependencies
flutter pub get

# Generate launcher icons and splash screens
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# Run on a connected device
flutter run
```

---

## Project Structure

```
neko-music/
├── android/                   # Native Android configuration and Gradle setup
├── assets/                    # Application icons, graphics, and static assets
│   ├── icon.png               # Primary cat application icon
│   └── icon_resized.png       # Splash screen branding asset
├── lib/
│   ├── models/                # Track, playlist, and album data models
│   ├── screens/               # Main pages, settings, player views, and navigation
│   ├── services/              # Audio controllers, downloaders, and extractor services
│   ├── state/                 # Application-wide reactive state management
│   ├── theme/                 # AMOLED themes, color palettes, and typography
│   ├── widgets/               # Reusable UI components, sheets, and mini players
│   ├── app.dart               # Root MaterialApp configuration
│   └── main.dart              # Application entry point and engine initialization
├── CODE_OF_CONDUCT.md         # Contributor Covenant community guidelines
├── CONTRIBUTING.md            # Guidelines for open-source contributions
├── DESIGN.md                  # Design language, tokens, and theme architecture
├── LICENSE                    # MIT License text
├── PRIVACY_POLICY.md          # User privacy policy and telemetry notice
├── README.md                  # Main project overview and documentation index
├── SECURITY.md                # Vulnerability reporting and security policy
├── SETUP.md                   # Environment setup, execution, and release build guide
└── pubspec.yaml               # Flutter package configuration and dependencies
```

---

## Contributing

Contributions of all types are welcome. Please read **[CONTRIBUTING.md](CONTRIBUTING.md)** before opening issues or submitting pull requests.

All participants are expected to adhere to our **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)**.

---

## Authors and Acknowledgments

- **Purvesh Shinde** - Creator and maintainer - [GitHub Profile](https://github.com/PurveshShinde)
- **Spotube** - Architectural foundation and Hetu plugin model ([Spotube Repository](https://github.com/KRTirtho/spotube))
- **media_kit** - High-performance cross-platform audio player engine ([media_kit](https://github.com/media-kit/media-kit))
- **Hetu Script** - Embedded lightweight scripting language for Dart ([Hetu](https://github.com/hetu-community/hetu))

---

## License

This project is licensed under the **[MIT License](LICENSE)**.

See the full **[LICENSE](LICENSE)** file for complete terms.

*Note: The metadata and plugin architecture is inspired by and based upon [Spotube](https://github.com/KRTirtho/spotube), which is distributed under the BSD-4-Clause License.*
