
import 'package:flutter/material.dart';

class GlucoseManagementScreen extends StatelessWidget {
  const GlucoseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de la Glycémie'),
      ),
      body: const Center(
        child: Text('Écran de gestion de la glycémie'),
      ),
    );
  }
}
