<h1 align="center">Neko 🎵</h1>

<p align="center">
  <strong>A sleek, free, open-source Spotify alternative built with Flutter.</strong>
</p>

## ✨ Features

- 🚫 **No Ads**: Enjoy ad-free uninterrupted music streaming.
- 🖤 **True AMOLED Dark Mode**: Beautiful, pure-black UI with glassmorphism touches designed to save battery and look stunning.
- 🎧 **High Quality Playback**: Powered by `media_kit` (libmpv) for fast, responsive, and cross-platform native audio playback.
- 🔌 **Plugin Architecture**: Leverages Hetu Script to load Spotify metadata plugins on the fly (heavily inspired by Spotube).
- 📥 **Offline Downloads**: Download tracks directly to your device and listen to your "Downloaded Songs" playlist offline.
- 📱 **Native OS Integration**: Full support for Android background playback, lock screen media controls, and headset media buttons via `audio_service`.
- 🔍 **YouTube Extraction**: Streams audio efficiently using `youtube_explode_dart` and `flutter_new_pipe_extractor`.

## 📸 Screenshots

*(Add screenshots here)*

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.8.0 or higher)
- Dart SDK

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/neko.git
   cd neko
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

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page].

## 📝 License

This project is open-source and free to use.
