# Contributing to Neko Music

Thank you for considering contributing to Neko Music. This project is open-source and welcomes pull requests, bug reports, and enhancements.

---

## Code of Conduct

All contributors and participants are expected to adhere to the standards outlined in [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

---

## Development Workflow

1. **Check Existing Issues**

   Before beginning work, check the issue tracker to ensure the feature or bug is not already being addressed.

2. **Fork and Branch**

   Fork the repository and create a dedicated branch from `main`:

   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-description
   ```

3. **Follow Local Setup Steps**

   Refer to [SETUP.md](SETUP.md) for environment configuration, dependency installation, and code generation commands.

4. **Code Quality and Formatting**

   Ensure your code conforms to the project lint rules defined in `analysis_options.yaml`:

   ```bash
   flutter analyze
   ```

   Format your Dart files before committing:

   ```bash
   dart format .
   ```

5. **Commit Message Guidelines**

   Write clear, concise commit messages following standard conventions:
   - `feat: add custom equalizer preset storage`
   - `fix: resolve playback pause on incoming phone call`
   - `docs: update setup instructions for Android 14`
   - `refactor: optimize track metadata caching layer`

6. **Submitting a Pull Request**

   - Push your branch to your fork.
   - Open a Pull Request targeting the `main` branch.
   - Provide a clear summary of changes, rationale, and any manual verification performed.

---

## License Agreement

By contributing to Neko Music, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).

