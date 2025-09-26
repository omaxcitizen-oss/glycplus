import 'package:flutter/material.dart';
import 'package:myapp/services/ai_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AIService _aiService = AIService(projectId: 'glycplus'); // Utilisation du bon Project ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panneau d\'administration'),
      ),
      body: const Center(
        child: Text('Bienvenue dans le panneau d\'administration.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSummarizeDialog(context),
        tooltip: 'Interagir avec l\'IA',
        child: const Icon(Icons.psychology_alt),
      ),
    );
  }

  void _showSummarizeDialog(BuildContext context) {
    final TextEditingController promptController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Interagir avec l\'IA'),
          content: TextField(
            controller: promptController,
            decoration: const InputDecoration(hintText: "Posez une question à l'IA"),
            maxLines: 5,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Envoyer'),
              onPressed: () async {
                final result = await _aiService.sendPrompt(promptController.text);
                if (!mounted) return;
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                _showResultDialog(context, result);
              },
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Réponse de l\'IA'),
          content: SingleChildScrollView(
            child: Text(result),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
