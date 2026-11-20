# Credits, Lineage & Third-Party Licences

**Neko Music** is built upon the collective innovation of the open-source Android music streaming and audio engineering community. We believe in strict compliance with the **GNU General Public License v3.0 (GPL-3.0)** and full transparency regarding the lineage of our codebase.

---

## 1. Upstream Project Lineage

Neko Music is a sovereign fork derived from **Echo Music**, inheriting foundations established by **InnerTune** and **ViMusic**:

```
vfsfitvnm/ViMusic (GPL-3.0)
       │
       ▼
z-huang/InnerTune (GPL-3.0)
       │
       ▼
EchoMusicApp/Echo-Music (GPL-3.0)
       │
       ▼
PurveshShinde/Neko-Music (GPL-3.0)
```

| Project | Author(s) / Maintainers | Repository | Licence | Contribution to Neko Music |
| :--- | :--- | :--- | :---: | :--- |
| **Echo Music** | Aditya (`iad1tya`) & Contributors | [EchoMusicApp/Echo-Music](https://github.com/EchoMusicApp/Echo-Music) | GPL-3.0 | Immediate upstream codebase, player enhancements, multi-source lyrics integrations, and UI base. |
| **InnerTune** | Zion Huang (`z-huang`) | [z-huang/InnerTune](https://github.com/z-huang/InnerTune) | GPL-3.0 | Foundational architecture, InnerTube client implementation, database schema patterns, and initial translations. |
| **ViMusic** | `vfsfitvnm` | [vfsfitvnm/ViMusic](https://github.com/vfsfitvnm/ViMusic) | GPL-3.0 | Pioneer open-source YouTube Music client architecture and core playback streaming models. |

---

## 2. Component Contributors & Specialized Subsystems

### 2.1 Spotify Integration
- **Primary Contributor:** **Chartreux Westia** (`© Chartreux Westia — github.com/koiverse`)
- **Licence:** GNU General Public License v3.0 (GPL-3.0)
- **Scope:** 18 source files in `app/src/main/kotlin/com/music/neko/spotify/` and `spotifyimport/` implement the Spotube/Sonic-Liberation GraphQL reverse-engineered Spotify Web API client.
- **Mandatory Notice:** Retained verbatim in all 18 source files per GPL-3.0 Section 4 and Section 5:
  ```kotlin
  /*
   * EchoMusic (2026)
   * © Chartreux Westia — github.com/koiverse
   * GPL-3.0 License | Contributors: see git history
   * Do not remove or alter this notice. - Per GPL-3.0 Section 4 & Section 5
   */
  ```

### 2.2 Metrolist
- **Contributors:** Metrolist Community
- **Licence:** GPL-3.0
- **Scope:** Home screen AppWidget implementations (`AdaptiveQueueWidgetService.kt`, `EchoAdaptiveWidgetReceiver.kt`, `TurntableWidgetReceiver.kt`, etc.), `LastFMSettingsScreen.kt`, and audio playback helper utilities (`Fix403.kt`, `YTPlayerUtils.kt`).

### 2.3 Vivi Music
- **Contributors:** Vivi Music Project Contributors
- **Licence:** GPL-3.0
- **Scope:** Dynamic theme components (`ColorPicker.kt`, `FloatingNavBar.kt`, `FontSelectionScreen.kt`) and listening analytics ViewModels (`DetailedListeningHistoryViewModel.kt`, `ListeningSummaryViewModel.kt`).

### 2.4 Lossless Audio Extension
- **Author:** **Silly Kat**
- **Repository:** [EchoMusicApp/lossless-extension](https://github.com/EchoMusicApp/lossless-extension)
- **Licence:** GNU General Public License v3.0 (GPL-3.0)
- **Scope:** Client-side addon manifest and stream resolver for lossless audio fallback.

---

## 3. Vendored Open-Source Components

The following components are embedded directly in source to maintain binary compatibility with Jetpack Compose:

| Component | Author / Copyright Holder | Source Repository | Licence | Purpose |
| :--- | :--- | :--- | :---: | :--- |
| **Backdrop Shaders** | Copyright © 2025 Kyant | [Kyant0/backdrop](https://github.com/Kyant0/backdrop) | **Apache-2.0** | AGSL hardware-accelerated frosted glass blur shaders (`Shaders.kt`). |
| **Floating Tab Bar** | Elyes Mansour | [elyesmansour/compose-floating-tab-bar](https://github.com/elyesmansour/compose-floating-tab-bar) | **Apache-2.0** | Animated floating navigation tab bar (`FloatingTabBar.kt`). |
| **BBH Bartle Font** | Studio Drama & BBH Project Authors | [Studio-DRAMA/BBH](https://github.com/Studio-DRAMA/BBH) | **OFL-1.1** | Display typeface licensed under SIL Open Font License v1.1 (`bbh_bartle_regular.ttf`). |

---

## 4. Key Open-Source Dependencies

Neko Music relies on prominent open-source libraries:

| Library | Maintainer / Project | Licence | Usage |
| :--- | :--- | :---: | :--- |
| **AndroidX Media3** | Google LLC | Apache-2.0 | ExoPlayer core audio engine, queue management, and MediaSession. |
| **Jetpack Compose** | Google LLC / Android Open Source Project | Apache-2.0 | Modern declarative UI framework and Material 3 design components. |
| **Room Persistence** | Google LLC | Apache-2.0 | SQLite local database management with schema auto-migrations. |
| **Coil** | Coil Contributors | Apache-2.0 | Asynchronous image loading for high-resolution album artwork. |
| **Ktor Client** | JetBrains s.r.o. | Apache-2.0 | Asynchronous HTTP client for lyrics and metadata APIs. |
| **Kotlinx Serialization**| JetBrains s.r.o. | Apache-2.0 | High-performance JSON and binary payload parsing. |
| **Dokar QuickJS** | Dokar | MIT | Embedded JavaScript runtime for audio stream extraction. |
| **NewPipe Extractor** | Team NewPipe | GPL-3.0 | Media stream parsing and YouTube format extraction. |

---

## 5. Public APIs & Community Services

Neko Music connects directly to public third-party and community services. We express our gratitude to the operators of these public APIs:

- **YouTube Music / InnerTube:** Audio streaming and metadata resolution.
- **LRCLIB (`lrclib.net`):** Open-source community synchronized lyrics database.
- **KuGou (`kugou.com`):** CJK time-synced lyrics and translation provider.
- **Apple Music / ShazamKit:** Music video canvas loops and microphone audio fingerprinting.
- **SponsorBlock (`sponsor.ajay.app`):** Community-driven skipping of non-music sponsored segments.
- **Return YouTube Dislike (`returnyoutubedislikeapi.com`):** Restored public like/dislike ratios.
- **Last.fm:** Scrobbling API and listening profile tracking.

---

## 6. Neko Music Contributions & Governance

- **Maintainer:** [Purvesh Shinde](https://github.com/PurveshShinde)
- **Neko-Specific Work:** UI redesign (Liquid Glass, 4-section About screen, Welcome onboarding), complete decoupling from upstream update infrastructure, standalone GitHub Releases update pipeline, brand asset modernization, build optimizations, and continuous code quality audits.
- **Licence:** All original modifications and contributions in Neko Music are licensed under the **GNU General Public License v3.0**.
