
import 'package:flutter/material.dart';

class AdviceScreen extends StatelessWidget {
  final double isf;
  final double icr;
  final String glucoseUnit;

  const AdviceScreen({
    super.key,
    required this.isf,
    required this.icr,
    required this.glucoseUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conseils Personnalisés'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildRatioCard(
            context,
            title: 'Facteur de Sensibilité (ISF)',
            value: '${isf.toStringAsFixed(1)} $glucoseUnit/U',
            explanation:
                'Cela signifie qu\'une unité d\'insuline rapide fera baisser votre glycémie d\'environ ${isf.toStringAsFixed(1)} $glucoseUnit.',
            advice:
                'Utilisez ce facteur pour calculer les doses de correction lorsque votre glycémie est au-dessus de votre cible. Par exemple, si vous êtes à ${isf.toStringAsFixed(1)} $glucoseUnit au-dessus de votre cible, 1 unité d\'insuline devrait vous ramener à votre objectif.',
          ),
          const SizedBox(height: 16),
          _buildRatioCard(
            context,
            title: 'Ratio Glucides/Insuline (ICR)',
            value: '${icr.toStringAsFixed(1)} g/U',
            explanation:
                'Cela signifie qu\'une unité d\'insuline rapide peut couvrir environ ${icr.toStringAsFixed(1)} grammes de glucides.',
            advice:
                'Utilisez ce ratio pour calculer la dose d\'insuline nécessaire pour un repas. Pesez ou estimez les glucides de votre repas et divisez par ${icr.toStringAsFixed(1)} pour obtenir la dose de bolus. N\'oubliez pas d\'ajuster en fonction de votre activité physique prévue.',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Clause de non-responsabilité',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Ces calculs et conseils sont basés sur des formules standards et ne remplacent pas l\'avis d\'un professionnel de la santé. Validez toujours ces ratios avec votre médecin ou votre diabétologue. Des ajustements peuvent être nécessaires en fonction de votre style de vie, de votre alimentation et d\'autres facteurs.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildRatioCard(
    BuildContext context, {
    required String title,
    required String value,
    required String explanation,
    required String advice,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                value,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(height: 24),
            Text(
              'Explication',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(explanation),
            const SizedBox(height: 16),
            Text(
              'Conseil d\'utilisation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(advice),
          ],
        ),
      ),
    );
  }
}
