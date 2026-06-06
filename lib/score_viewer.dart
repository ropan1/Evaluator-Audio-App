import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ScoreViewer extends StatefulWidget {
  final String? meiContent;
  final String? assetPath;

  const ScoreViewer({super.key, this.meiContent, this.assetPath});

  @override
  State<ScoreViewer> createState() => _ScoreViewerState();
}

class _ScoreViewerState extends State<ScoreViewer> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isVerovioReady = false;
  String? _errorMessage;
  String? _selectedNoteId;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF121212))
      ..addJavaScriptChannel(
        'VerovioChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebResourceError: \${error.description}');
            setState(() {
              _errorMessage = error.description;
              _isLoading = false;
            });
          },
        ),
      );

    await _controller.loadFlutterAsset('assets/verovio_viewer.html');
  }

  void _handleMessage(String message) {
    debugPrint('VerovioChannel message: $message');
    if (message == 'READY') {
      setState(() => _isVerovioReady = true);
      _loadMeiIfProvided();
    } else if (message.startsWith('ERROR:')) {
      setState(() {
        _errorMessage = message.substring(6);
      });
    } else if (message.startsWith('SELECTED:')) {
      setState(() {
        _selectedNoteId = message.substring(9);
      });
    }
  }

  Future<void> _loadMeiIfProvided() async {
    if (!_isVerovioReady) return;

    String? meiData;

    if (widget.meiContent != null) {
      meiData = widget.meiContent;
    } else if (widget.assetPath != null) {
      try {
        meiData = await rootBundle.loadString(widget.assetPath!);
      } catch (e) {
        debugPrint('Error loading MEI from asset: $e');
      }
    }

    if (meiData != null && mounted) {
      await _controller.runJavaScript('renderMusic(`$meiData`)');
    }
  }

  void _nextNote() {
    if (_isVerovioReady) {
      _controller.runJavaScript('nextNote()');
    }
  }

  void _prevNote() {
    if (_isVerovioReady) {
      _controller.runJavaScript('prevNote()');
    }
  }

  void _markSharp() {
    if (_isVerovioReady) {
      _controller.runJavaScript('markSharp()');
    }
  }

  void _markFlat() {
    if (_isVerovioReady) {
      _controller.runJavaScript('markFlat()');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_isLoading || !_isVerovioReady)
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading Verovio...'),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        if (_isVerovioReady && _errorMessage == null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filledTonal(
                            onPressed: _prevNote,
                            icon: const Icon(Icons.skip_previous),
                            tooltip: 'Previous Note',
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedNoteId != null
                                ? _selectedNoteId!
                                : 'Tap a note',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: _nextNote,
                            icon: const Icon(Icons.skip_next),
                            tooltip: 'Next Note',
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _markFlat,
                            icon: const Text('♭', style: TextStyle(fontSize: 18, color: Colors.lightBlue)),
                            label: const Text('Flat'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _markSharp,
                            icon: const Text('♯', style: TextStyle(fontSize: 18, color: Color(0xFFDAA520))), // goldenrod
                            label: const Text('Sharp'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class InteractiveScoreViewer extends StatelessWidget {
  final String? meiContent;
  final String? assetPath;

  const InteractiveScoreViewer({super.key, this.meiContent, this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Viewer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ScoreViewer(meiContent: meiContent, assetPath: assetPath),
    );
  }
}
