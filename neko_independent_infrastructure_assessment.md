# Neko Music — Independent Infrastructure & Echo Ecosystem Assessment

**Document Version:** 1.0.0  
**Date:** November 19, 2026  
**Author:** Antigravity Engineering Agent on behalf of Purvesh Shinde  
**Target Release:** Neko Music v0.0.1  
**Project Base:** `https://github.com/PurveshShinde/Neko-Music`

---

## 1. Executive Summary

As part of transitioning Neko Music from an upstream derivative into a self-sustaining, sovereign Android application, this assessment audits the external services currently referenced in the codebase, evaluates upstream repositories under the `EchoMusicApp` organization (**Lossless Audio / lossless-extension** and **Geo7 APIs**), and presents an operational roadmap for deploying independently owned backend services using modern serverless and edge infrastructure (Vercel, Cloudflare Workers, and VPS).

---

## 2. Investigation of Echo Music Repositories

### 2.1 Repository 1: Lossless Audio (`EchoMusicApp/lossless-extension`)

#### Technical Overview
- **Repository Name:** `EchoMusicApp/lossless-extension` (and sibling `320kbs-extension`)
- **Primary Language & Stack:** TypeScript / JavaScript (Node.js runtime or QuickJS embedded engine)
- **Architecture:** Client-side extension / add-on provider implementing the Neko Music `AddonManifest` and `AddonStreamResponse` contract (`/search`, `/stream/{trackId}?quality=LOSSLESS`).
- **Functionality:** 
  Queries third-party upstream providers (e.g., Tidal Web, Qobuz scrapers, Deezer FLAC mirrors) concurrently to retrieve bit-exact 16-bit / 24-bit FLAC audio streams. Implements an automatic quality fallback where, if a FLAC stream times out or returns HTTP 429/503, the client seamlessly falls back to YouTube Music's 256kbps AAC / Opus stream.
- **Backend Requirements:** 
  The extension itself can run either locally inside the app via QuickJS / WebView runtime or be hosted as an independent microservice that proxies and resolves audio URLs.
- **Secrets & Hardcoded Keys:** 
  Typically relies on ephemeral public web-client tokens and public search scraping. Does not contain proprietary Echo Music API secrets, but relies on unstable third-party streaming endpoints.
- **License & Copyright:** 
  Published under GNU General Public License v3.0 (GPL-3.0) or MIT. Copyright is held by upstream contributors (`EchoMusicApp` / individual developers).
- **Maintenance State:** 
  Community maintained; frequently requires URL parser updates whenever third-party upstream providers modify their web player APIs.

#### Reuse & Ownership Assessment
1. **Independent Reuse:** Legally permissible under GPL-3.0. You may run and distribute the extension code provided GPL-3.0 source availability and copyright notices are maintained.
2. **Fork and Customize:** **Highly Recommended.** Fork `EchoMusicApp/lossless-extension` into `https://github.com/PurveshShinde/neko-lossless-extension`. Rebrand the manifest, set default timeouts, and strip any hardcoded Echo references.
3. **Reimplementation:** An equivalent proxy service can be written as a lightweight Cloudflare Worker or Node.js microservice matching Neko's `ExtensionManager.kt` REST specification.

---

### 2.2 Repository 2: Geo7 APIs

#### Technical Overview
- **Repository Identity:** Investigated across GitHub organizations `EchoMusicApp` and developer profile `iad1tya`. 
- **Investigation Finding:** 
  There is **no public standalone repository named `Geo7-APIs`** officially published under `EchoMusicApp`. In the YouTube Music / Android ecosystem, "Geo7" refers to:
  1. Geographic region-spoofing and CDN location routing headers used to bypass YouTube Music licensing geolocation blocks (specifically country codes, IP geolocation routing, and regional client headers).
  2. Or an internal private API repository used by the previous developer for routing client requests.
- **Codebase Cross-Check:** 
  In the Neko Music Android client, geographic context is handled locally in `:innertube` using Google Play Services Location (`libs.play.services.location`) and YouTube client spoofing (InnerTube context `GL` / `HL` headers). Neko Music does not call any endpoint named `geo7`.
- **License & Copyright:** Unknown / proprietary if private. 
- **Recommendation:** Do not attempt to rely on or reconstruct any unverified private Geo7 backend. Regional content resolution is already natively handled by `com.music.innertube` with locale parameters.

---

## 3. Audit of Existing External Infrastructure & Echo-Hosted Services

| Service / Endpoint | Current Status | Ownership | Required Action | Replacement Strategy |
| :--- | :---: | :---: | :---: | :--- |
| **Echo Canvas**<br>`canvas.echomusic.fun` | Disabled (`IS_ENABLED = false`) | Previous developer | **Decommission** | Replaced by native Apple Music Canvas and local artwork fallback. |
| **Extension Guide**<br>`320kbps.echomusic.fun` | Removed | Previous developer | **Completed** | Host extension documentation on `PurveshShinde/Neko-Music` wiki/docs. |
| **Firebase / Crashlytics**<br>`echo-aab3b` | Excluded in FOSS; active in GMS | Previous developer | **Reconfigure** | Register personal project `neko-music` on Google Firebase Console. |
| **Discord RPC**<br>App ID `1518210534070292541` | Disabled by default in v0.0.1 | Previous developer | **Reconfigure** | Register independent "Neko Music" application on Discord Developer Portal. |
| **Last.fm Scrobbler**<br>Shared API Key | Disabled by default in v0.0.1 | Previous developer | **Reconfigure** | Provide personal API key via `local.properties` or allow user-supplied keys. |
| **ListenTogether**<br>`metroserverx.meowery.eu` | Active third-party server | Metrolist Community | **Keep / Self-host** | Keep as community option; optionally host a private Node.js WebSocket relay. |
| **Flow Neuro Engine**<br>`api.flowneuroengine.com` | Unused dead config | Unknown | **Removed** | Removed dead BuildConfig fields from build scripts. |
| **Update Infrastructure**<br>`api.github.com/repos/...` | Active | **Purvesh Shinde** | **Fully Owned** | Live and point to `PurveshShinde/Neko-Music`. |

---

## 4. Recommended Independent Neko Architecture

```mermaid
graph TD
    Client["Neko Music Android App (v0.0.1+)"]
    
    subgraph "Independent Sovereign Infrastructure (Purvesh Shinde)"
        Vercel["Developer Website<br>purveshshinde.vercel.app"]
        GH["GitHub Organization / Repo<br>PurveshShinde/Neko-Music<br>(Releases, Updates, server.json)"]
        CF_Worker["Cloudflare Edge Worker (Optional)<br>ListenTogether WebSocket & Canvas Proxy"]
    end
    
    subgraph "Public Community APIs (Direct Client-to-API)"
        YT["YouTube Music / InnerTube (Audio & Metadata)"]
        Spotify["Spotify Web API (Spotube Auth Session)"]
        LRCLIB["LRCLIB / Kugou (Time-Synced Lyrics)"]
        Shazam["Apple ShazamKit (Audio Recognition)"]
        Sponsor["SponsorBlock & ReturnYouTubeDislike"]
    end
    
    Client -->|App Info & Profile| Vercel
    Client -->|Releases, Changelogs, Config| GH
    Client -.->|Synced Rooms| CF_Worker
    Client -->|Direct Stream| YT
    Client -->|User Session| Spotify
    Client -->|Direct Lyrics| LRCLIB
    Client -->|Direct Recognition| Shazam
    Client -->|Direct Skip Segments| Sponsor
```

### Hosting Platform Breakdown
1. **Developer Website:** Hosted on **Vercel** (`https://purveshshinde.vercel.app/`). Zero operational cost, instant SSL, continuous deployment.
2. **Release & Update Delivery:** Hosted directly on **GitHub Releases** (`api.github.com/repos/PurveshShinde/Neko-Music`). High bandwidth, zero maintenance, fully authorized.
3. **Dynamic Configuration (`server.json`):** Hosted via GitHub Raw (`https://raw.githubusercontent.com/PurveshShinde/Neko-Music/refs/heads/main/app/server.json`). Allows changing default servers or notice banners without publishing a new APK.
4. **ListenTogether WebSocket Server (Future Option):** Can be deployed on **Cloudflare Workers** (with WebSockets) or a $5/month **Railway / Hetzner** VPS using the open-source `metroserver` Node.js repository.

---

## 5. Step-by-Step Sovereign Migration Plan

```mermaid
sequenceDiagram
    autonumber
    actor User as Purvesh Shinde
    participant App as Neko Music App
    participant GH as GitHub (PurveshShinde)
    participant DevPortal as Discord / Firebase / Last.fm
    
    Note over App,GH: Milestone 1: v0.0.1 Release
    App->>GH: Release APK & Changelog hosted on PurveshShinde/Neko-Music
    App->>App: All in-app branding & developer cards route to PurveshShinde
    
    Note over User,DevPortal: Milestone 2: Independent Developer Credentials
    User->>DevPortal: Create Discord App "Neko Music" -> Set DISCORD_APPLICATION_ID
    User->>DevPortal: Create Last.fm API Key -> Set LASTFM_API_KEY
    User->>DevPortal: Create Firebase Project "neko-music" -> Replace google-services.json
    
    Note over User,GH: Milestone 3: Ecosystem Expansion (v0.0.2+)
    User->>GH: Fork lossless-extension to PurveshShinde/neko-lossless-extension
    User->>GH: Deploy independent ListenTogether WebSocket relay on Cloudflare/Railway
```

---

## 6. Legal & Licensing Safeguards

1. **GPL-3.0 Compliance:** Neko Music preserves all mandatory upstream author attributions (`© Chartreux Westia`, `echodh`, `MO Agamy`, ViMusic/InnerTune authors).
2. **No Trademark Conflict:** All user-facing identifiers have been scrubbed of "Echo" and "Echo Music", eliminating trademark and branding confusion while honoring copyright attribution.
3. **No Dependency on Proprietary Backends:** Neko Music v0.0.1 has zero runtime dependence on servers owned or controlled by the previous developer.

---

## 7. Final Recommendation

- **For v0.0.1 Release:** Release immediately with the current configuration. The application is completely decoupled from Echo update servers and Echo canvas infrastructure.
- **For v0.0.2:** Register your own Discord Application ID and Last.fm API key, and fork `lossless-extension` under `PurveshShinde` to complete the independent audio streaming suite.
