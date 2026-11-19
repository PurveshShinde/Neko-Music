# Contributing to Neko Music

Thank you for your interest in contributing to **Neko Music**! We welcome contributions from developers, designers, translators, and documentation writers of all experience levels—whether fixing bugs, improving translations, optimizing audio pipelines, or refining UI components.

---

## Code of Conduct

All contributors, maintainers, and community participants are expected to adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). Please treat everyone with respect, empathy, and constructive collaboration.

---

## Licensing & Intellectual Property Rules

Neko Music is distributed under the **GNU General Public License v3.0 (GPL-3.0)**. To protect the project, users, and all contributors, the following licensing rules apply to all submissions:

1. **Licence Compatibility:**
   All contributed code, documentation, scripts, and assets must be licensed under terms compatible with GPL-3.0 (e.g., GPL-3.0, Apache-2.0, MIT, BSD).
2. **Right to Contribute:**
   You must have the legal right to submit the code or assets you contribute. By submitting a pull request, you represent that you are the original author or have the necessary rights to release the work under GPL-3.0.
3. **No Proprietary Code:**
   Do not submit copied proprietary, closed-source, or copyrighted code from non-permissive or incompatible sources.
4. **Preservation of Existing Notices:**
   Existing third-party copyright headers, license notices, and author attributions (such as Chartreux Westia's Spotify notices, Metrolist credits, or InnerTune/ViMusic notices) must be preserved intact in any file you modify. Under GPL-3.0 Section 5, you may add your own copyright notice to files you substantially modify, but you may not alter or remove prior copyright notices.
5. **Copyright Retention:**
   Submitting a contribution does not transfer your copyright ownership to Neko Music or any individual maintainer. You retain copyright to your original work while licensing it under GPL-3.0.
6. **No CLA Required:**
   Neko Music does not require a formal Contributor Licence Agreement (CLA) or Developer Certificate of Origin (DCO). Open-source contributions submitted via GitHub Pull Requests are accepted under standard inbound/outbound GPL-3.0 terms.

---

## Development Workflow

### 1. Check Existing Issues & Discussions
Before starting work on a substantial feature or refactor, check the [Issues](https://github.com/PurveshShinde/Neko-Music/issues) tab to see if the topic is already being discussed. If not, open an issue first to discuss your proposal with the maintainer.

### 2. Fork and Create a Feature Branch
Fork the repository and create a dedicated branch from `main`:

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### 3. Setup Your Environment
Follow the setup guide in [SETUP.md](SETUP.md) to configure your Android SDK, NDK, and `local.properties`.

---

## Coding Standards

### Kotlin & Jetpack Compose
- **Modern Kotlin**: Write idiomatic Kotlin (favor immutable `val`, coroutine flows, and Kotlin serialization).
- **Compose Best Practices**:
  - Keep Composables stateless where feasible; hoist state into ViewModels.
  - Use `remember` and `derivedStateOf` to prevent unnecessary recompositions.
  - Follow standard Compose naming conventions (PascalCase for `@Composable` functions returning `Unit`).
- **Clean Architecture & Module Separation**:
  - UI screens and ViewModels belong in `:app`.
  - Audio playback pipelines belong in `:playback`.
  - Database entities and DAO migrations belong in `:core`.
  - Pure domain contracts belong in `:domain`.
  - Native audio drivers belong in `:usbaudio` and `:audio-dsp`.

---

## Verification & Testing

Before committing, verify that your changes compile cleanly and pass all test suites:

```bash
# 1. Run unit tests across all modules
./gradlew test

# 2. Run Android lint checks
./gradlew lint

# 3. Assemble debug APK to verify full compilation
./gradlew assembleArm64FossDebug

# (On Windows PowerShell, use .\gradlew.bat)
```

In Android Studio, format your code with **Code $\rightarrow$ Reformat Code** (`Ctrl + Alt + L` / `Cmd + Option + L`).

---

## Commit Message Conventions

Write clear, descriptive commit messages adhering to standard semantic commit conventions:
- `feat: add custom EQ band preset export`
- `fix: resolve Bit-Perfect USB audio buffer underrun`
- `docs: update setup guide for NDK 28`
- `refactor: optimize lyrics synchronizer scroll performance`
- `chore: update dependencies`

---

## Submitting a Pull Request (PR)

1. Push your branch to your GitHub fork:
   ```bash
   git push origin feature/your-feature-name
   ```
2. Open a Pull Request targeting the `main` branch.
3. Fill out the pull request template completely:
   - What changed and why.
   - Screenshots or screen recordings for UI modifications.
   - Any manual testing steps performed.
4. Respond to feedback or requested changes during code review.

Thank you for helping make Neko Music better for everyone! 🎧
