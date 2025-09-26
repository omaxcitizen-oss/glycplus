import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';
import '../services/csv_export_service.dart';

class AnalysisReportsScreen extends StatelessWidget {
  const AnalysisReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final firestoreService = Provider.of<FirestoreService>(context);
    final csvExportService = Provider.of<CsvExportService>(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse & Rapports'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Exportez vos données de santé au format CSV pour les partager avec votre médecin ou pour une analyse plus approfondie.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Exporter en CSV'),
              onPressed: () async {
                if (user != null) {
                  final timelineItems = await firestoreService.getTimelineStream(user.uid).first;
                  final path = await csvExportService.exportTimelineToCsv(timelineItems);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Fichier CSV sauvegardé ici : $path')),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Veuillez vous connecter pour exporter vos données.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
