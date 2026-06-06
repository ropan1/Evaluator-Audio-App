// AUTO GENERATED FILE, DO NOT EDIT.
import 'dart:ffi' as ffi;

class MicFfiBindings {
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) _lookup;

  MicFfiBindings(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  MicFfiBindings.fromLookup(
    ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) lookup,
  ) : _lookup = lookup;

  int init_mic() {
    return _init_mic();
  }

  late final _init_micPtr = _lookup<ffi.NativeFunction<ffi.Int Function()>>('init_mic');
  late final _init_mic = _init_micPtr.asFunction<int Function()>();

  double get_amplitude() {
    return _get_amplitude();
  }

  late final _get_amplitudePtr = _lookup<ffi.NativeFunction<ffi.Float Function()>>('get_amplitude');
  late final _get_amplitude = _get_amplitudePtr.asFunction<double Function()>();

  void stop_mic() {
    return _stop_mic();
  }

  late final _stop_micPtr = _lookup<ffi.NativeFunction<ffi.Void Function()>>('stop_mic');
  late final _stop_mic = _stop_micPtr.asFunction<void Function()>();
}