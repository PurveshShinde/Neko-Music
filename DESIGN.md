# Design Architecture and Guidelines

This document outlines the visual language, theme architecture, and UI design principles implemented across Neko Music.

---

## Design Principles

1. **AMOLED-First Aesthetics**:
   The primary visual foundation is pure pitch black (`#000000`). This conserves battery on OLED/AMOLED displays and produces maximum visual contrast for album artwork.

2. **Liquid Glass & Glassmorphism**:
   Secondary layers (such as mini-players, bottom sheets, navigation capsules, and speed-dial grids) utilize subtle glassmorphic blur effects (`BackdropFilter`) combined with semi-transparent dark tints.

3. **Artwork-Driven Dynamic Accentuation**:
   Color accents dynamically adapt to the currently playing track. Album artwork is analyzed at runtime using `palette_generator` to extract dominant and vibrant colors that tint playback controls, progress bars, and glowing background ambiences.

4. **Clutter-Free Minimalism**:
   Every visual component serves an immediate playback or navigation function. Distracting animations and unnecessary chrome are omitted to maintain focus on the audio experience.

---

## Color System

| Token | Hex Value | Usage |
| :--- | :--- | :--- |
| `background` | `#000000` | Primary scaffold background across all screens |
| `surface` | `#121212` | Card backgrounds, elevated sheets, and dialogs |
| `surfaceContainer` | `#1A1A1A` | Secondary container layers and input fields |
| `textPrimary` | `#FFFFFF` | Track titles, headers, and primary actions |
| `textSecondary` | `#A0A0A0` | Artist names, durations, and secondary labels |
| `accentDefault` | `#1DB954` | Default accent color prior to dynamic artwork tinting |

---

## Typography

Neko Music utilizes clean sans-serif typography via `google_fonts` configured in `lib/theme/neko_theme.dart`:
- **Headings**: Medium to bold weights with tight letter spacing for modern presentation.
- **Body & Subtitles**: Regular weight with high legibility across varied device densities.
- **Player Timers**: Monospaced tabular numerals to prevent layout shifting during track progression.

---

## Key UI Components

- **Bottom Navigation Capsule**: A floating, pill-shaped navigation container with frosted glass blur (`lib/widgets/bottom_nav_capsule.dart`).
- **Liquid Glass Mini Player**: Persistent audio control bar positioned above the navigation capsule with smooth transition animations into the full player (`lib/widgets/liquid_glass_container.dart`).
- **Dynamic Background Ambience**: Subtle radial blur gradients derived from active track artwork (`lib/widgets/dynamic_app_background.dart`).
- **Vintage Noise Overlay**: Optional tactile film grain overlay for nostalgic visual texture (`lib/widgets/vintage_noise_overlay.dart`).

