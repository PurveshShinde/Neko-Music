# Contributing to Neko Music

Thank you for your interest in contributing to **Neko Music**! We welcome contributions from developers of all experience levels—whether fixing bugs, improving documentation, designing UI components, or optimizing audio pipelines.

---

## Code of Conduct

All contributors, maintainers, and community participants are expected to adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). Please treat everyone with respect and empathy.

---

## Development Workflow

### 1. Check Existing Issues
Before beginning work on a new feature or substantial bugfix, check the [Issues](https://github.com/PurveshShinde/Neko-Music/issues) tab to verify if the topic is already being discussed or actively worked on. If not, consider opening an issue first to discuss your proposal.

### 2. Fork and Branch
Fork the repository and create a dedicated branch from `main`:

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

### 3. Setup Your Environment
Follow the setup guide in [SETUP.md](SETUP.md) to configure your Android SDK, NDK, and `local.properties`.

### 4. Coding Standards

#### Kotlin & Jetpack Compose Guidelines
- **Modern Kotlin**: Write idiomatic Kotlin (favor immutable `val`, coroutine flows, and Kotlin serialization).
- **Compose Best Practices**:
  - Keep Composables stateless where feasible; hoist state into ViewModels.
  - Use `remember` and `derivedStateOf` appropriately to prevent unnecessary recompositions.
  - Follow Compose naming conventions (PascalCase for `@Composable` functions returning `Unit`).
- **Clean Architecture & Separation of Concerns**:
  - UI logic belongs in `:app`.
  - Audio playback pipelines belong in `:playback`.
  - Database entities and DAO migrations belong in `:core`.
  - Pure domain contracts belong in `:domain`.
  - Native audio drivers belong in `:usbaudio` and `:audio-dsp`.

### 5. Formatting & Verification

Before committing, verify that your code compiles cleanly and passes all test suites:

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

### 6. Commit Message Conventions

Write clear, descriptive commit messages adhering to standard semantic commit conventions:
- `feat: add custom EQ band preset export`
- `fix: resolve Bit-Perfect USB audio buffer underrun`
- `docs: update setup guide for NDK 28`
- `refactor: optimize lyrics synchronizer scroll performance`

---

## Submitting a Pull Request (PR)

1. Push your branch to your GitHub fork:
   ```bash
   git push origin feature/your-feature-name
   ```
2. Open a Pull Request targeting the `main` branch.
3. Provide a clear description of:
   - What changed and why.
   - Screenshots or screen recordings for UI-related changes.
   - Any manual testing steps performed.
4. Respond to feedback or requested changes during the code review process.

Thank you for helping make Neko Music better for everyone! 🎧
