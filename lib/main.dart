import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'score_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verovio Score Viewer',
      theme: ThemeData.dark(useMaterial3: true),
      home: const ScoreSelectionPage(),
    );
  }
}

class ScoreSelectionPage extends StatefulWidget {
  const ScoreSelectionPage({super.key});

  @override
  State<ScoreSelectionPage> createState() => _ScoreSelectionPageState();
}

class _ScoreSelectionPageState extends State<ScoreSelectionPage> {
  bool _isLoading = false;

  Future<void> _pickAndLoadScore() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? file = await openFile();

      if (file != null) {
        final content = await file.readAsString();

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InteractiveScoreViewer(meiContent: content),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading file: \$e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verovio Score Viewer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 24),
            const Text(
              'Interactive Score Viewer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Using Verovio & WebView',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InteractiveScoreViewer(
                      assetPath: 'assets/sample_mei/simple_melody.mei',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Open Sample Score'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickAndLoadScore,
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: const Text('Upload Custom Score'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
