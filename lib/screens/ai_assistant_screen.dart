import 'package:flutter/material.dart';
import 'package:myapp/services/ai_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _promptController = TextEditingController();
  final AIService _aiService =
      AIService(projectId: 'glycplus'); // Utilisation du bon Project ID
  String _response = "";
  bool _isLoading = false;

  Future<void> _generateContent() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = "";
    });

    try {
      final result = await _aiService.sendPrompt(_promptController.text);
      setState(() {
        _response = result;
      });
    } catch (e) {
      setState(() {
        _response = 'Erreur: $e';
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
        title: const Text('Assistant IA'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Posez une question sur la gestion du diabete',
                border: OutlineInputBorder(),
                hintText: 'ex: Quelles sont les causes de l\'hypoglycemie ?',
              ),
              onSubmitted: (_) => _generateContent(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateContent,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12)),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 3, color: Colors.white),
                    )
                  : const Text('Obtenir une reponse',
                      style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Reponse:',
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
                  child: Text(_response.isEmpty && !_isLoading
                      ? 'La reponse de l\'IA apparaitra ici.'
                      : _response),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
