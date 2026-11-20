# Privacy Policy

**Last Updated:** November 2026

**Neko Music** is built upon the foundational principles of privacy, autonomy, and transparency. This document details how data is handled across the application.

---

## 1. Zero Telemetry & Tracking Guarantee (FOSS Variant)

- **FOSS Distribution (Default)**: The standard open-source FOSS release contains **zero tracking libraries, advertisement SDKs, usage analytics, or commercial telemetry frameworks**.
- **GMS Distribution (Optional)**: If you choose to build or install the Google Mobile Services (GMS) variant, it integrates Google Play Services (such as Google Cast for media streaming and Google Location Services for local weather AI recommendation context) and Google Firebase Analytics to support standard Play Store crash and usage diagnostics.
- **No User Profiling**: We do not record or sell your personal listening habits, search history, IP addresses, or device identifiers.
- **No Account Required**: The application operates fully without requiring user accounts or third-party registrations.

---

## 2. Network Activity & External Requests

Neko Music communicates directly with external web services solely to fulfill user-initiated playback and discovery actions:

- **YouTube Music (InnerTube API)**: Streams audio data, fetches search results, playlists, albums, and artist metadata directly from public endpoints.
- **Lyrics Providers**: Queries public community endpoints (such as LRCLIB, KuGou, BetterLyrics, and SimpMusic) to fetch synchronized and plain-text lyrics for active tracks.
- **ShazamKit Audio Recognition**: When you tap the microphone button to identify a playing song, an audio fingerprint is computed locally on your device and queried against Shazam's recognition service. No ambient audio recordings are ever stored or retained.
- **Listen Together Sessions**: Real-time group listening sessions transmit synchronization state (current track, timestamp, play/pause) over encrypted WebSockets to the selected Listen Together server.
- **AI Translation & Weather Context (Optional)**: If you configure a third-party AI translation provider (e.g., OpenRouter, DeepL, Mistral), lyric translation prompts are sent directly to that provider using your personal API key. In GMS builds, coarse/fine location coordinates may be used locally to query ambient weather conditions for contextual playlists.

> [!NOTE]
> All network requests originate directly from your device to the respective service. Neko Music maintains no intermediate proxy servers that intercept, log, or inspect your traffic.

---

## 3. Local Storage & Device Data

All persistent application data is stored strictly within the app's secure private sandbox on your local device:

- **SQLite Database (`InternalDatabase`)**: Stores local playlists, favorite tracks, cached search history, and listening history.
- **Preferences DataStore**: Stores your personalized UI settings, equalizer presets, and audio configuration.
- **ExoPlayer Media Cache**: Stores cached audio segments to enable smooth playback and reduce repetitive network bandwidth.
- **Downloaded Audio Files**: Files you explicitly download are saved to your device's local audio directory.

This data never leaves your device unless you explicitly initiate a database backup export or enable system-level cloud backups.

---

## 4. Permissions Requested

Neko Music requests only runtime permissions essential for music playback, device integration, and user-initiated features:

| Permission | Category | Justification |
| :--- | :---: | :--- |
| `INTERNET` | Core Network | Required to stream music, download album artwork, and fetch synchronized lyrics. |
| `ACCESS_NETWORK_STATE` | Core Network | Detects network connectivity (Wi-Fi vs. cellular) to honor your configured audio streaming quality. |
| `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Playback Engine | Required by Android to maintain continuous audio playback and notification controls when the screen is off or multitasking. |
| `POST_NOTIFICATIONS` | System UI | Displays the system media player notification with playback controls, timeline scrubbers, and track details. |
| `READ_MEDIA_AUDIO` / `READ_EXTERNAL_STORAGE` | Local Library | Allows scanning, indexing, and playing local audio tracks stored on your device's storage. |
| `RECORD_AUDIO` & `FOREGROUND_SERVICE_MICROPHONE` *(Optional)* | Song Recognition | Used exclusively when you tap the "Identify Song" (ShazamKit) button to compute an audio fingerprint. Granted on demand at runtime. |
| `BLUETOOTH_CONNECT`, `BLUETOOTH`, `BLUETOOTH_ADMIN` *(Optional)* | Audio Output | Detects connected Bluetooth headphones and external DACs to automatically apply device-specific equalizer presets. |
| `ACCESS_COARSE_LOCATION` & `ACCESS_FINE_LOCATION` *(GMS Flavor Only)* | AI Context | In GMS builds, optionally accessed to detect ambient local weather conditions for time/weather-aware smart recommendations. Never logged or transmitted to third parties. |
| `WRITE_SETTINGS` | Ringtone Setting | Used strictly when you explicitly select "Set as Ringtone" or notification sound for a local audio file. |
| `REQUEST_INSTALL_PACKAGES` | In-App Updates | Used exclusively to prompt the user to install newly downloaded APK releases when using direct GitHub Releases distribution. |
| `RECEIVE_BOOT_COMPLETED` & `WAKE_LOCK` | Service Reliability | Allows the audio service and background tasks (such as periodic episode checks) to run reliably without premature process termination. |

---

## 5. Contact & Questions

If you have questions, concerns, or feedback regarding this Privacy Policy, please open an issue or start a discussion on our official repository:  
[https://github.com/PurveshShinde/Neko-Music](https://github.com/PurveshShinde/Neko-Music)
