
import 'dart:async';
import 'package:firebase_ai/firebase_ai.dart';

class AIService {
  final FirebaseVertexAI _vertexAI;

  // Private constructor
  AIService._(this._vertexAI);

  // Singleton instance
  static AIService? _instance;

  // Factory constructor to provide a single instance
  factory AIService() {
    if (_instance == null) {
      final vertexAI = FirebaseVertexAI.instance;
      _instance = AIService._(vertexAI);
    }
    return _instance!;
  }

  // Example: Generate text from a prompt
  Future<String> generateText(String prompt) async {
    try {
      final model = _vertexAI.generativeModel(model: 'gemini-1.5-flash');
      final response = await model.generateContent([Content.text(prompt)]);

      return response.text ?? 'No response from the model.';
    } catch (e) {
      print('Error generating text: $e');
      return 'Error: Could not get a response from the AI model.';
    }
  }

  // Example: Generate text from a multimodal prompt (text and image)
  // The image should be passed as bytes (Uint8List)
  /*
  Future<String> analyzeImage(String promptText, Uint8List imageData) async {
    try {
      final model = _vertexAI.generativeModel(model: 'gemini-1.5-flash-vision-preview');
      final content = Content.multi([
        TextPart(promptText),
        DataPart('image/jpeg', imageData), // Assuming JPEG format
      ]);

      final response = await model.generateContent([content]);
      return response.text ?? 'No response from the model.';
    } catch (e) {
      print('Error analyzing image: $e');
      return 'Error: Could not analyze the image.';
    }
  }
  */
}
