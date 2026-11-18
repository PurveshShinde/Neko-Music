# Privacy Policy

**Last Updated:** November 2026

**Neko Music** is built upon the foundational principles of privacy, autonomy, and transparency. This document details how data is handled across the application.

---

## 1. Zero Telemetry & Tracking Guarantee

- **No Analytics or Trackers**: Neko Music contains zero tracking libraries, advertisement SDKs, usage analytics, or commercial telemetry frameworks.
- **No User Profiling**: We do not record your listening habits, search history, IP addresses, or device identifiers.
- **No Account Required**: The app operates fully without requiring user accounts or registration.

---

## 2. Network Activity & External Requests

Neko Music communicates directly with external web services solely to fulfill user-initiated playback and discovery actions:

- **YouTube Music (InnerTube API)**: Streams audio data, fetches search results, playlists, albums, and artist metadata directly from public endpoints.
- **Lyrics Providers**: Queries public community endpoints (such as LRCLIB, KuGou, BetterLyrics, and SimpMusic) to fetch synchronized and plain-text lyrics for active tracks.
- **ShazamKit Audio Recognition**: When you tap the microphone button to identify a playing song, an audio fingerprint is computed locally on your device and queried against Shazam's recognition service. No ambient audio recordings are ever stored or retained.
- **Listen Together Sessions**: Real-time group listening sessions transmit synchronization state (current track, timestamp, play/pause) over encrypted WebSockets to the selected Listen Together server.
- **AI Translation (Optional)**: If you configure a third-party AI translation provider (e.g., OpenRouter, DeepL, Mistral), lyric translation prompts are sent directly to that provider using your personal API key.

> [!NOTE]
> All network requests originate directly from your device to the respective service. Neko Music maintains no intermediate proxy servers that intercept, log, or inspect your traffic.

---

## 3. Local Storage & Device Data

All persistent application data is stored strictly within the app's secure private sandbox on your local device:

- **SQLite Database (`InternalDatabase`)**: Stores local playlists, favorite tracks, cached search history, and listening history.
- **Preferences DataStore**: Stores your personalized UI settings, equalizer presets, and audio configuration.
- **ExoPlayer Media Cache**: Stores cached audio segments to enable smooth playback and reduce repetitive network bandwidth.
- **Downloaded Audio Files**: Files you explicitly download are saved to your device's local audio directory.

This data never leaves your device unless you explicitly initiate a database backup export.

---

## 4. Permissions Requested

Neko Music requests only the minimum Android runtime permissions essential for music playback:

| Permission | Justification |
| :--- | :--- |
| `INTERNET` | Required to stream music, download album art, and fetch synchronized lyrics. |
| `ACCESS_NETWORK_STATE` | Detects network availability (Wi-Fi vs. cellular) to honor your configured audio quality settings. |
| `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Required by Android to continue playing audio when the screen is turned off or when switching apps. |
| `POST_NOTIFICATIONS` | Displays the system media player notification with playback controls and track details. |
| `RECORD_AUDIO` *(Optional)* | Used strictly when you trigger the "Identify Song" (Shazam) feature. Granted at runtime on demand. |
| `BLUETOOTH_CONNECT` *(Optional)* | Used to detect connected Bluetooth headsets and DACs to apply device-specific equalizer profiles. |

---

## 5. Contact & Questions

If you have questions, concerns, or feedback regarding this Privacy Policy, please open an issue or start a discussion on our official repository:
[https://github.com/PurveshShinde/Neko-Music](https://github.com/PurveshShinde/Neko-Music)
