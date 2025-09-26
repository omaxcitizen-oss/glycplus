
import 'package:flutter/material.dart';
import 'package:myapp/services/ai_service.dart';

class AIExampleScreen extends StatefulWidget {
  const AIExampleScreen({super.key});

  @override
  State<AIExampleScreen> createState() => _AIExampleScreenState();
}

class _AIExampleScreenState extends State<AIExampleScreen> {
  final TextEditingController _promptController = TextEditingController();
  String _response = "";
  bool _isLoading = false;

  late final AIService _aiService;

  @override
  void initState() {
    super.initState();
    // Assurez-vous de remplacer 'diabetic-helper-51411' par votre ID de projet Firebase.
    _aiService = AIService(projectId: 'diabetic-helper-51411');
  }

  Future<void> _generateContent() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = "";
    });

    try {
      final response = await _aiService.sendPrompt(_promptController.text);
      setState(() {
        _response = response;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Enter your prompt',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _generateContent(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateContent,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Get Response'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Response:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_response.isEmpty && !_isLoading ? 'AI response will appear here.' : _response),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
