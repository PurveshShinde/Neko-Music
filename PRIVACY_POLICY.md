# Privacy Policy

**Last Updated:** November 2026

Neko Music is designed with privacy and user autonomy as core principles. This policy explains how data is handled by the application.

---

## 1. Zero Telemetry and Tracking

- Neko Music does not collect, store, or transmit any personal telemetry, usage metrics, device identifiers, or analytics data.
- The application does not contain third-party ad networks, trackers, or commercial telemetry SDKs.

## 2. Network Requests

To provide search, metadata, and audio streaming capabilities, Neko Music communicates directly with external services:
- **Spotify Public Endpoints / Scrapers**: Used to fetch track, album, and playlist metadata.
- **YouTube Audio Streams**: Used to stream and download audio tracks via local extractors (`youtube_explode_dart` and `flutter_new_pipe_extractor`).

All network requests are made directly from your device to the respective endpoints. No intermediary servers operated by Neko Music intercept or log your streaming activity.

## 3. Local Storage

The following data is stored strictly on your local device:
- Application preferences and settings (e.g., audio quality, theme selection).
- Locally cached search queries and playlists.
- Audio files downloaded to your device storage via the download service.

This data never leaves your device unless you explicitly export or back up your local files.

## 4. Permissions

Neko Music requests only the permissions necessary for media playback and optional local file downloads:
- **Internet**: Required to stream music and resolve metadata.
- **Foreground Service & Notification**: Required to maintain background playback and show media controls.
- **Storage**: Required only if you choose to download tracks to your device storage.

## 5. Contact

If you have questions regarding this Privacy Policy, please open an issue or reach out via [GitHub](https://github.com/PurveshShinde/Neko-Music).

