
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import 'profile_screen.dart';

class HyperScreen extends StatefulWidget {
  const HyperScreen({super.key});

  @override
  State<HyperScreen> createState() => _HyperScreenState();
}

class _HyperScreenState extends State<HyperScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentGlucoseController = TextEditingController();
  final _targetGlucoseController = TextEditingController();

  String? _correctionMessage;
  bool _isLoading = false;
  bool _showProfileButton = false;

  @override
  void dispose() {
    _currentGlucoseController.dispose();
    _targetGlucoseController.dispose();
    super.dispose();
  }

  Future<void> _calculateCorrection(UserProfile userProfile) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _correctionMessage = null;
        _showProfileButton = false;
      });

      final currentGlucose = double.parse(_currentGlucoseController.text);
      final targetGlucose = double.parse(_targetGlucoseController.text);
      final isf = userProfile.isf;

      if (isf == null || isf <= 0) {
        _correctionMessage = 'Erreur : Le Facteur de Sensibilité (ISF) est invalide ou non défini dans votre profil. Veuillez le configurer.';
        _showProfileButton = true;
      } else if (currentGlucose > targetGlucose) {
        final difference = currentGlucose - targetGlucose;
        final correction = difference / isf;
        _correctionMessage = 'Correction suggérée : ${correction.toStringAsFixed(1)} unités d\'insuline pour une baisse de ${difference.toStringAsFixed(0)} ${userProfile.glucoseUnit}.';
      } else {
        _correctionMessage = 'Votre glycémie est dans ou en dessous de la cible. Aucune correction nécessaire.';
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
      body: StreamBuilder<UserProfile?>(
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
            _targetGlucoseController.text = (userProfile.targetGlucoseFasting ?? '100').toString();
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

  Widget _buildCorrectionForm(UserProfile userProfile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
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
              'Entrez vos glycémies pour obtenir une recommandation de dose.',
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
              label: const Text('Calculer la Correction'), 
              onPressed: _isLoading ? null : () => _calculateCorrection(userProfile),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_correctionMessage != null)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _showProfileButton ? Colors.red.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _showProfileButton ? Colors.red : Theme.of(context).primaryColor, width: 1),
                    ),
                    child: SelectableText( 
                      _correctionMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _showProfileButton ? Colors.red.shade900 : Theme.of(context).textTheme.bodyLarge?.color,
                        height: 1.5, 
                      ),
                    ),
                  ),
                  if (_showProfileButton)
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
                            _correctionMessage = null;
                            _showProfileButton = false;
                            _currentGlucoseController.clear();
                          }));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ),
                ],
              ),
          ],
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
    );
  }
}
