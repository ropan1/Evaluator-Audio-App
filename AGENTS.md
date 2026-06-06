# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## What this is

A Flutter app that renders interactive music notation. MEI score data is rendered to SVG by the [Verovio](https://www.verovio.org/) JS/WASM toolkit running **inside a WebView**; Flutter drives it and reflects selection/navigation state in native UI.

## Commands

```bash
flutter pub get                                   # resolve deps (regenerates plugin registrants)
flutter run                                        # run on the default device
flutter build apk --debug --target-platform android-x64   # x64 build (Waydroid is android-x64)
dart analyze                                        # analyze app + mic_ffi/lib (must be clean)
dart format lib/
flutter test                                        # all tests
flutter test test/widget_test.dart                  # a single test
```

`mic_ffi/` is a **separate package** — run `dart` commands from within it (e.g. `cd mic_ffi && dart analyze`). Regenerate its FFI bindings with `dart run ffigen --config ffigen.yaml`; on this machine that fails with `stddef.h not found` unless clang's resource include dir is on the path — see the `mic-ffi-regen-clang-include` memory for the temp-config workaround. Never hand-edit `mic_ffi/lib/mic_ffi_bindings_generated.dart` (it's tool-generated; "DO NOT EDIT").

## Architecture: the WebView ↔ Dart bridge

This is the core of the app and spans three files: `lib/main.dart`, `lib/score_viewer.dart`, and `assets/verovio_viewer.html`.

- **Entry / file loading** (`lib/main.dart`): `ScoreSelectionPage` offers two paths into `InteractiveScoreViewer` — "Open Sample Score" passes an `assetPath` (`assets/sample_mei/simple_melody.mei`), "Upload Custom Score" uses `file_selector`'s `openFile()` + `XFile.readAsString()` and passes `meiContent`.
- **The host** (`lib/score_viewer.dart`): `ScoreViewer` owns a `WebViewController` that `loadFlutterAsset`s `assets/verovio_viewer.html`. Two directions of communication:
  - **Dart → JS**: `_controller.runJavaScript(...)` invokes JS functions `renderMusic(...)`, `nextNote()`, `prevNote()`, `markSharp()`, `markFlat()`. MEI is injected by string-interpolating it into a `renderMusic(`...`)` template literal.
  - **JS → Dart**: a single JavaScript channel named `VerovioChannel`. JS calls `window.VerovioChannel.postMessage(...)` with **prefix-encoded** strings, parsed by `_handleMessage`:
    - `READY` — the Verovio WASM runtime finished initializing.
    - `ERROR:<message>`
    - `SELECTED:<info>` — describes the tapped/navigated note.
  - **Handshake ordering matters**: Dart must wait for `READY` before injecting MEI (`_loadMeiIfProvided` is gated on `_isVerovioReady`), because the toolkit isn't usable until the WASM runtime is up.
- **The renderer** (`assets/verovio_viewer.html`): loads `verovio-toolkit.js`, creates `new verovio.toolkit()`, renders MEI → SVG into `#verovio-container`, and implements note navigation/selection. Notable behaviors a quick read won't reveal:
  - Navigation is **confined to the current staff + layer** ("part") — `nextNote`/`prevNote` skip notes in other parts.
  - **Accidentals**: Verovio moves accidental attributes into a child `<accid>` element, so reading sharp/flat requires querying that child, not the `.note` element (see `selectNote`).
  - Page layout is computed from the container width each render (`pageWidth`, `scale`) to reflow to the screen; selection draws an SVG highlight `<rect>` behind the note.

## Verovio runtime assets (committed, large, required)

`assets/verovio-toolkit.js` (~11 MB) and `assets/verovio-toolkit-wasm.js` (~7 MB) are the Verovio toolkit and **must** be present — they're declared in `pubspec.yaml` and the app won't build without them. They are **not generated from anything in this repo**; they originate from the `verovio` npm package (re-downloadable). Don't try to regenerate them locally.

## Native audio code (two dormant experiments)

The app's actual audio dependency is the `record` package. Separately, there are two unused native-mic experiments — don't assume either is wired into the running app:
- `mic_ffi/` — a standalone miniaudio FFI plugin (`initMic()`/`getAmplitude()`/`stopMic()`). It is **not** a dependency of the main app (absent from the root `pubspec.yaml`).
- `native/mic_handler.c` + `android/app/CMakeLists.txt` — `android/app/build.gradle.kts` has **no `externalNativeBuild` block**, so this CMake target is never built.

## Android toolchain constraint (do not regress)

On Flutter 3.44.1's blessed Android defaults: **AGP 9.0.1 / Gradle 9.1.0 / Kotlin 2.3.20**. The Built-in Kotlin migration is complete per Flutter's guide (the app no longer applies `kotlin-android`; it uses the top-level `kotlin { compilerOptions { jvmTarget } }` DSL).

**Keep `android.builtInKotlin=false` and `android.newDsl=false` in `android/gradle.properties`.** Setting either to `true` crashes Flutter 3.44.1's Gradle plugin (`NullPointerException`) — Flutter still drives Kotlin via the legacy KGP and has no built-in-Kotlin support yet. The residual AGP-9 deprecation warnings about these flags (and the `record_web` "Skipping assets entry … web" notices) are expected and non-blocking. See the `android-builtin-kotlin-migration` memory.

## Skills

`skills-lock.json` (committed) is the source of truth for project skills. `.agents/skills/` (real content) and `.claude/skills/` (symlinks into it) are gitignored, re-syncable caches — like `node_modules`.
