# evaluator_audio_app

A Flutter app that renders interactive music notation. MEI score data is
rendered to SVG by the [Verovio](https://www.verovio.org/) JS/WASM toolkit
running inside a WebView; Flutter drives it and reflects selection/navigation
state in native UI.

## Platform support

**This project targets Android only.** It is developed and tested against
Android (including `android-x64`, e.g. Waydroid). iOS, web, desktop, and other
Flutter targets are not supported or maintained — don't expect them to build or
run.

## Getting Started

New to Flutter? Install the SDK and set up an Android toolchain first:

- [Install Flutter](https://docs.flutter.dev/get-started/install)
- [Set up Android development](https://docs.flutter.dev/get-started/install/linux/android)
- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Verify your setup detects an Android device or emulator:

```bash
flutter doctor       # check the Android toolchain is ready
flutter devices      # confirm an Android device/emulator is connected
```

## Running the app

```bash
flutter pub get      # resolve dependencies
flutter run          # run on the connected Android device/emulator
```

To produce a debug build for an `android-x64` target (such as Waydroid):

```bash
flutter build apk --debug --target-platform android-x64
```

## Development

```bash
dart analyze         # analyze the app (must be clean)
dart format lib/     # format Dart sources
flutter test         # run all tests
```

See [CLAUDE.md](CLAUDE.md) for architecture notes (the WebView ↔ Dart bridge,
Verovio runtime assets, and the Android toolchain constraints).
