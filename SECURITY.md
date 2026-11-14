# Security Policy

## Supported Versions

The following table lists which releases of Neko Music currently receive security updates:

| Version | Supported          |
| :------ | :----------------- |
| 1.0.x   | Yes                |
| < 1.0.0 | No                 |

## Reporting a Vulnerability

If you discover a security vulnerability in Neko Music, please report it responsibly:

1. **Do not create a public issue** on GitHub for sensitive security concerns.
2. Contact the maintainer directly via GitHub or email: [Purvesh Shinde](https://github.com/PurveshShinde).
3. Include detailed steps to reproduce the issue, along with proof of concept if applicable.
4. Allow reasonable time for the maintainer to review and deploy a patch before public disclosure.

## Third-Party Dependencies

Neko Music relies on third-party libraries for audio decoding (`media_kit` / `libmpv`), streaming extraction (`flutter_new_pipe_extractor`, `youtube_explode_dart`), and metadata scripting (`hetu_script`). Vulnerabilities identified within upstream dependencies will be patched via dependency updates as soon as upstream fixes are released.

