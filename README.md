# EMPOWER-TENS

Flutter mobile app (Android/iOS) for the EMPOWER‑TENS project.

## Getting Started

### Prerequisites

- Flutter SDK installed and on your PATH
- Xcode (for iOS builds)
- Android Studio or Android SDK (for Android builds)

### Install Dependencies

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Test

```bash
flutter test
```

## Project Structure

- lib/ — app source (entry point: `main.dart`)
- test/ — widget and unit tests
- android/ — Android host project
- ios/ — iOS host project

## Notes

This repository includes a `_codeql_detected_source_root` folder, which is a CodeQL analysis artifact used by static analysis tooling to identify a source root during scans. It is not part of the app runtime and can be ignored for development.
