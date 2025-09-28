import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'profile_screen.dart';

enum CorrectionState { none, hyper, hypo, error, inRange }

class HyperScreen extends StatefulWidget {
  const HyperScreen({super.key});

  @override
  State<HyperScreen> createState() => _HyperScreenState();
}

class _HyperScreenState extends State<HyperScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentGlucoseController = TextEditingController();
  final _targetGlucoseController = TextEditingController();

  CorrectionState _correctionState = CorrectionState.none;
  String? _resultMessage;
  double _calculatedValue = 0;
  bool _isLoading = false;
  bool _disclaimerAccepted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimerDialog();
    });
  }

  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber),
              SizedBox(width: 10),
              Text('Avertissement', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Les recommandations fournies par cette application sont des estimations et ne remplacent en aucun cas un avis médical professionnel. Consultez toujours votre médecin pour toute décision concernant votre traitement.',
              textAlign: TextAlign.justify,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("J'accepte", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                setState(() {
                  _disclaimerAccepted = true;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _currentGlucoseController.dispose();
    _targetGlucoseController.dispose();
    super.dispose();
  }

  Future<void> _calculateCorrection(UserModel userProfile) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _correctionState = CorrectionState.none;
        _resultMessage = null;
      });

      final currentGlucose = double.parse(_currentGlucoseController.text);
      final targetGlucose = double.parse(_targetGlucoseController.text);
      final isf = userProfile.isf;
      final icr = userProfile.icr;

      if (isf == null || isf <= 0) {
        _correctionState = CorrectionState.error;
        _resultMessage = 'Facteur de Sensibilité (ISF) invalide. Veuillez le configurer dans votre profil.';
      } else if (currentGlucose > targetGlucose) {
        final difference = currentGlucose - targetGlucose;
        final correction = difference / isf;
        _correctionState = CorrectionState.hyper;
        _calculatedValue = correction;
        _resultMessage = '${correction.toStringAsFixed(1)} unités';
      } else if (currentGlucose < targetGlucose) {
        if (icr == null || icr <= 0) {
          _correctionState = CorrectionState.error;
          _resultMessage = 'Ratio Insuline/Glucides (ICR) non défini. Configurez-le pour les calculs d\'hypoglycémie.';
        } else {
          final difference = targetGlucose - currentGlucose;
          final carbsNeeded = (difference / isf) * icr;
          _correctionState = CorrectionState.hypo;
          _calculatedValue = carbsNeeded;
          _resultMessage = '${carbsNeeded.toStringAsFixed(0)}g de glucides';
        }
      } else {
        _correctionState = CorrectionState.inRange;
        _resultMessage = 'Votre glycémie est à la cible.';
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final firestoreService = Provider.of<FirestoreService>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Veuillez vous connecter.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Correction de Glycémie'),
      ),
      body: StreamBuilder<UserModel?>(
        stream: firestoreService.getUserProfileStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userProfile = snapshot.data;

          if (userProfile == null || userProfile.isf == null || userProfile.isf! <= 0) {
            return _buildProfilePrompt();
          }

          if (_targetGlucoseController.text.isEmpty) {
            _targetGlucoseController.text = (userProfile.fastingTargetGlucose ?? 100).toString();
          }

          return _buildCorrectionForm(userProfile);
        },
      ),
    );
  }

  Widget _buildProfilePrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_pin, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 24),
            const Text(
              'Veuillez compléter votre profil pour utiliser cette fonctionnalité.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text(
              'Le calcul des corrections nécessite votre profil complet (ISF, Cibles, etc.).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Aller au Profil'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                ).then((_) => setState(() {}));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectionForm(UserModel userProfile) {
    return AbsorbPointer(
      absorbing: !_disclaimerAccepted,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Opacity(
          opacity: _disclaimerAccepted ? 1.0 : 0.5,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Assistant de Correction',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Entrez vos glycémies pour obtenir une recommandation.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildTextFormField(
                  controller: _currentGlucoseController,
                  labelText: 'Glycémie Actuelle (${userProfile.glucoseUnit ?? 'mg/dL'})',
                  icon: Icons.bloodtype,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _targetGlucoseController,
                  labelText: 'Glycémie Cible (${userProfile.glucoseUnit ?? 'mg/dL'})',
                  icon: Icons.gps_fixed,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculer'),
                  onPressed: (_isLoading || !_disclaimerAccepted) ? null : () => _calculateCorrection(userProfile),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 32),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
                if (_resultMessage != null) _buildResultCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    IconData icon;
    Color color;
    String title;

    switch (_correctionState) {
      case CorrectionState.hyper:
        icon = Icons.arrow_downward;
        color = Colors.red.shade700;
        title = 'Correction Hyperglycémie';
        break;
      case CorrectionState.hypo:
        icon = Icons.local_cafe_outlined;
        color = Theme.of(context).primaryColor;
        title = 'Correction Hypoglycémie';
        break;
      case CorrectionState.inRange:
        icon = Icons.check_circle_outline;
        color = Colors.green.shade700;
        title = 'Glycémie Stable';
        break;
      case CorrectionState.error:
        icon = Icons.error_outline;
        color = Colors.red.shade900;
        title = 'Erreur de Profil';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _resultMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (_correctionState == CorrectionState.hypo)
              _buildHypoSuggestions(),
            if (_correctionState == CorrectionState.error)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Configurer mon Profil'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    ).then((_) => setState(() {
                          _correctionState = CorrectionState.none;
                          _resultMessage = null;
                          _currentGlucoseController.clear();
                        }));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHypoSuggestions() {
    final carbsNeeded = _calculatedValue;
    final suggestions = [
      {'name': 'Morceaux de sucre', 'icon': Icons.widgets_outlined, 'carbs_per_unit': 5.0, 'unit_name': 'morceau'},
      {'name': 'Jus de fruits', 'icon': Icons.local_drink_outlined, 'carbs_per_unit': 10.0, 'unit_name': 'verre de 10cl'},
      {'name': 'Miel', 'icon': Icons.opacity, 'carbs_per_unit': 12.0, 'unit_name': 'c. à soupe'},
      {'name': 'Bonbons', 'icon': Icons.cake_outlined, 'carbs_per_unit': 4.0, 'unit_name': 'bonbon'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Suggestions de resucrage', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: suggestions.map((suggestion) {
              final double carbsPerUnit = (suggestion['carbs_per_unit'] as num).toDouble();
              final count = (carbsNeeded / carbsPerUnit).ceil();
              final unitName = suggestion['unit_name'] as String;

              return _buildFoodSuggestionCard(
                icon: suggestion['icon'] as IconData,
                name: suggestion['name'] as String,
                quantity: '$count $unitName${count > 1 ? 's' : ''}',
                color: Theme.of(context).primaryColor,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodSuggestionCard({required IconData icon, required String name, required String quantity, required Color color}) {
    return SizedBox(
      width: 130,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(quantity, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est obligatoire.';
        }
        if (double.tryParse(value) == null) {
          return 'Veuillez entrer un nombre valide.';
        }
        return null;
      },
      enabled: _disclaimerAccepted,
    );
  }
}
