# Changelog

All notable changes to **Neko Music** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.0.3] - 2026-11-23

Major performance and storage optimization release reducing APK installation footprint by over 35%, restoring dynamic discovery feed search, and refining audio-only streaming architecture.

### Added
- **Dynamic Search & Discovery Feed:** Restored Echo Music style dynamic search feed displaying live Apple Music Top 100 charts, trending artists, and community albums.
- **Optimized Locale Target:** Focused resource packaging on primary supported languages (`en`, `hi`, `ja`), stripping 54 unused localization tables.
- **Normalized Mockup Showcase:** Updated repository and README screenshot suite with pixel-aligned 526x1067 mockups highlighting Material You and Apple player styles.

### Changed
- **Significant Storage Reduction:** Decreased arm64 APK binary size from 47.7 MB to 30.9 MB (-35.2% / -16.8 MB savings) and universal APK from 78.2 MB to 61.4 MB (-21.5% savings).
- **Streamlined Player Pill:** Cleaned playback mode selector to toggle between `Song` and `Music Flow` modes.
- **Fluid Navigation Physics:** Enhanced bottom dock navigation with elastic stretch-and-settle animation and softened `tween(300)` screen transitions.

### Removed
- **Video Podcast Architecture:** Completely removed legacy video podcast components (`PodcastVideoProvider.kt`, `PodcastVideoScreen.kt`, and video routing) to establish an ad-free, pure-audio music engine.
- **Kuromoji Romaji Dictionary:** Decoupled heavy uncompressed Kuromoji IPADIC dictionary JAR (~16 MB) while maintaining full support for synchronized English, Hindi, and native Japanese lyrics.
- **Static Search Categories:** Purged over 300 lines of hardcoded static category cards in favor of real-time trending InnerTube data.
- **Unused Assets:** Removed over 6 MB of obsolete repository assets (including 3 MB `LMEB.gif`, legacy badges, and deprecated screenshots).

---

## [0.0.2] - 2026-11-22

Integration of lightweight Spotify authentication and session infrastructure derived from Vivi Music, paired with GPL-3.0 attribution integrity and version maintenance.

### Added
- **Vivi Music Spotify Integration:** Lightweight GraphQL and web-session-based Spotify integration (`Spotify.kt`, `SpotifyAuth.kt`, `SpotifyLoginScreen.kt`, `SpotifySessionManager.kt`, `SpotifyCanvasProvider.kt`, `SpotifySession.kt`).
- **WebView Session Authentication:** In-app secure web login capturing session credentials (`sp_dc`, `sp_key`) with automated token refresh and expiration handling.
- **Spotify Canvas Support:** Canvas video artwork provider decoding background visual clips via Spotify's protobuf service.
- **Dual Attribution & Legal Compliance:** Preserved verbatim Chartreux Westia copyright notice alongside Vivi Music Project Contributors notice in `Spotify.kt`, standardized GPL-3.0 headers across all Spotify integration files, and expanded `CREDITS.md` documentation scope.

### Changed
- **Spotify Architecture Overhaul:** Replaced legacy Spotube client dependencies with modern Ktor-based GraphQL and REST endpoints.
- **Dynamic Client User-Agent Alignment:** Replaced static version strings in `ListenBrainzManager` and `JellyfinApiService` with dynamic `BuildConfig.VERSION_NAME`.

---

## [0.0.1] - 2026-11-22

Initial sovereign release of **Neko Music**, establishing an independent brand identity, updated UI visual language, and decoupled release infrastructure derived from Echo Music.

### Added
- **Neko Brand Identity:** High-resolution 512x512 Neko Cat icon with pink headphones across application launch icons, notifications, Quick Settings tiles, and placeholder art.
- **Redesigned About Screen:** Clean 4-section visual hierarchy (`Developer` → `Project` → `Support` → `Community`) with clickable links to the developer's GitHub profile and Vercel website.
- **About Screen Easter Egg:** 3D card-flip interaction displaying developer attribution and GitHub avatar upon tapping the app logo.
- **Welcome Onboarding Dialog:** Streamlined first-launch dialog clearly separating developer information from the project repository, featuring a direct "Star Neko Music" button.
- **Centralized Update Configuration (`NekoUpdateConfig.kt`):** Fully decoupled update system routing to `PurveshShinde/Neko-Music` on GitHub Releases with semantic version comparison.
- **Credits & Lineage Documentation ([`CREDITS.md`](CREDITS.md)):** Detailed technical attribution documenting inherited foundations from Echo Music, InnerTune, ViMusic, Vivi Music (Spotify integration), and Metrolist.

### Changed
- **Localized Branding:** Rebranded 291 strings across 31 `echo_strings.xml` locale files, 51 `discord_information` translations, and 7 `updater_strings.xml` files to Neko Music and developer Purvesh Shinde.
- **Settings Screen Update Indicator:** Guarded update badges so false "Update" alerts do not appear when no newer release is published on the official repository.
- **Update Settings Copy:** Replaced legacy ad-redirect copy with accurate information pointing to official GitHub Releases.
- **Build Performance:** Optimized Gradle build configuration (`gradle-9.8.2` and AGP `8.9.1`) with incremental Kotlin compilation.

### Fixed
- **Stale Update State Bug:** Added automatic clearing of `update_available` SharedPreferences on app version change to eliminate residual update prompts from previous installations.
- **Missing XML Default Resource Warnings:** Cleaned up orphaned French string references that caused resource merger warnings during release packaging.
- **Playlist Placeholder Rendering:** Resolved placeholder skeleton UI fallback to use Neko Cat assets instead of legacy artwork.

### Removed
- **Flow Neuroengine Dead Configuration:** Removed unused `FLOW_NEURO_BASE_URL` and `FLOW_NEURO_API_KEY` properties and BuildConfig fields.
- **Legacy Drawables:** Deleted obsolete, unreferenced `support_echo.xml` and `license_echo.xml` files.

### Upstream Foundations (Inherited)
- High-fidelity streaming from YouTube Music via InnerTube client.
- Spotube/Sonic-Liberation GraphQL Spotify authentication, library browsing, and playlist import.
- Bit-Perfect USB DAC audio output driver (`:usbaudio`) bypassing Android OS 48 kHz resampler.
- Multi-provider synchronized lyrics engine (LRCLIB, KuGou, BetterLyrics, SimpMusic).
- Parametric equalizer and 10-band DSP audio processor.
- True AMOLED pitch-black dark mode with Liquid Glass blur effects.
