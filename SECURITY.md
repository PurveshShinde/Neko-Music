# Security Policy

## Supported Versions

The following table lists which releases of **Neko Music** actively receive security and maintenance updates:

| Version Line | Supported | Notes |
| :--- | :--- | :--- |
| **0.0.x** | **Yes** | Current active release branch (Kotlin native rebuild) |
| < 0.0.1 | No | Legacy versions |

---

## Reporting a Vulnerability

We take the security of Neko Music and our users seriously. If you discover a potential vulnerability, we appreciate your efforts in practicing responsible disclosure:

1. **Do not disclose the vulnerability in public GitHub issues, discussions, or social channels.**
2. Reach out directly to the maintainer via GitHub: [@PurveshShinde](https://github.com/PurveshShinde).
3. Provide a detailed summary including:
   - Specific component or module affected (`:app`, `:playback`, `:usbaudio`, etc.).
   - Exact steps or proof-of-concept code to reproduce the issue.
   - Potential impact or attack vectors.
4. Allow reasonable time for the maintainer to review, triage, and deploy an official security patch before any public disclosure.

---

## Upstream & Third-Party Dependencies

Neko Music relies on trusted, standard Android and Kotlin ecosystem libraries:
- **Audio Decoding & Streaming**: AndroidX Media3 ExoPlayer (`androidx.media3`).
- **Data Persistence**: AndroidX Room SQLite ORM with KSP symbol processing.
- **Native USB Audio**: Custom C++20 driver compiled with Android NDK and CMake.
- **Network Serialization**: Kotlinx Serialization and Google Protocol Buffers.

Security advisories affecting upstream libraries will be triaged and addressed promptly through version updates.
