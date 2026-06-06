import 'dart:ffi';
import 'dart:io';

import 'mic_ffi_bindings_generated.dart';

/// Starts microphone capture.
///
/// Returns `0` on success, or a negative value on failure (`-1` if the audio
/// device could not be initialized, `-2` if it could not be started). Calling
/// this while capture is already running is a no-op that returns `0`.
int initMic() => _bindings.init_mic();

/// The current microphone amplitude as an RMS value over the latest audio frame.
///
/// This is a very short-lived native call, so it is safe to invoke on the main
/// isolate (for example from a polling timer). Returns `0.0` while capture is
/// stopped.
double getAmplitude() => _bindings.get_amplitude();

/// Stops microphone capture and releases the audio device.
void stopMic() => _bindings.stop_mic();

const String _libName = 'mic_ffi';

/// The dynamic library in which the symbols for [MicFfiBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final MicFfiBindings _bindings = MicFfiBindings(_dylib);
