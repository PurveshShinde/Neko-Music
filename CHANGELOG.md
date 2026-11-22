# Changelog

All notable changes to **Neko Music** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
