<h1 align="center">Neko 🎵</h1>

<p align="center">
  <strong>A sleek, free, open-source Spotify alternative built with Flutter.</strong><br>
  <em>Built on top of the awesome <a href="https://github.com/KRTirtho/spotube">Spotube</a> backend architecture.</em>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"></a>
  <a href="https://github.com/PurveshShinde/Neko-Music/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="License"></a>
</p>

<p align="center">
  <img src="https://forthebadge.com/images/badges/built-with-love.svg" alt="Built with Love">
  <img src="https://forthebadge.com/images/badges/open-source.svg" alt="Open Source">
</p>

---

## ✨ Features

- 🚫 **No Ads**: Enjoy ad-free uninterrupted music streaming.
- 🖤 **True AMOLED Dark Mode**: Beautiful, pure-black UI with glassmorphism touches designed to save battery and look stunning.
- 🎧 **High Quality Playback**: Powered by `media_kit` (libmpv) for fast, responsive, and cross-platform native audio playback.
- 🔌 **Plugin Architecture**: Leverages Hetu Script to load Spotify metadata plugins on the fly (heavily inspired by Spotube).
- 📥 **Offline Downloads**: Download tracks directly to your device and listen to your "Downloaded Songs" playlist offline.
- 📱 **Native OS Integration**: Full support for Android background playback, lock screen media controls, and headset media buttons via `audio_service`.
- 🔍 **YouTube Extraction**: Streams audio efficiently using `youtube_explode_dart` and `flutter_new_pipe_extractor`.

## 📸 Screenshots

> 🖼️ *Tip: Add some screenshots of your beautiful UI here!*
> 
> <details>
> <summary>Click to expand</summary>
> 
> *(Replace the URLs below with actual image paths once you have screenshots)*
> ```html
> <img src="https://via.placeholder.com/300x600.png?text=Home+Screen" width="250" />
> <img src="https://via.placeholder.com/300x600.png?text=Player+Screen" width="250" />
> ```
> </details>

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.8.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/PurveshShinde/Neko-Music.git
   cd Neko-Music
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Assets (Icons & Splash Screen):**
   ```bash
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

Neko is built using a modern Flutter stack:
- **UI**: Material 3, Dynamic colors, Glassmorphism, and explicit AMOLED themes.
- **State Management**: Scoped models / custom `AppState` for lightweight, fast reactivity.
- **Audio Engine**: `media_kit` + `audio_service`.
- **Backend Data**: Spotify endpoints via Hetu scripts (`plugin_manager_service.dart`), mapped to YouTube audio streams.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Contributors

<a href="https://github.com/PurveshShinde/Neko-Music/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=PurveshShinde/Neko-Music" alt="Contributors" />
</a>

*Made with [contrib.rocks](https://contrib.rocks).*

## 📝 License

This project is open-source and available under the [MIT License](LICENSE).

*Note: This project's backend architecture is heavily based on [Spotube](https://github.com/KRTirtho/spotube), which is licensed under the BSD-4-Clause License.*
