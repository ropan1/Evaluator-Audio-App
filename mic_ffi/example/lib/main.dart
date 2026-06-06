import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mic_ffi/mic_ffi.dart' as mic_ffi;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _amplitude = 0;
  bool _running = false;
  Timer? _pollTimer;

  void _start() {
    final int result = mic_ffi.initMic();
    if (result != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start microphone (code $result)')),
      );
      return;
    }
    _pollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() => _amplitude = mic_ffi.getAmplitude());
    });
    setState(() => _running = true);
  }

  void _stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
    mic_ffi.stopMic();
    setState(() {
      _running = false;
      _amplitude = 0;
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    if (_running) {
      mic_ffi.stopMic();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('mic_ffi example')),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This captures microphone input through FFI using miniaudio, '
                  'shipped as source and built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  'amplitude (RMS) = ${_amplitude.toStringAsFixed(4)}',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                ElevatedButton(
                  onPressed: _running ? _stop : _start,
                  child: Text(_running ? 'Stop' : 'Start'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
