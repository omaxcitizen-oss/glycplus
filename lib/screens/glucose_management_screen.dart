import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/log_model.dart';
import 'profile_screen.dart';

class GlucoseManagementScreen extends StatefulWidget {
  const GlucoseManagementScreen({super.key});

  @override
  State<GlucoseManagementScreen> createState() => _GlucoseManagementScreenState();
}

class _GlucoseManagementScreenState extends State<GlucoseManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentGlucoseController = TextEditingController();
  final _targetGlucoseController = TextEditingController(text: '100');

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserProfile() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  void _calculateAndShowCorrection(double isf) {
    if (_formKey.currentState!.validate()) {
      final currentGlucose = double.tryParse(_currentGlucoseController.text) ?? 0;
      final targetGlucose = double.tryParse(_targetGlucoseController.text) ?? 100;

      String title;
      String message;
      double correctionDose = 0;

      if (currentGlucose <= 70) {
        title = "Hypoglycémie Détectée";
        message =
            "Votre glycémie est basse. Il est recommandé de consommer 15g de sucre rapide. Contrôlez à nouveau dans 15 minutes.";
      } else if (currentGlucose > targetGlucose) {
        correctionDose = (currentGlucose - targetGlucose) / isf;
        title = "Dose de Correction Suggérée";
        message =
            "Basé sur une glycémie de ${currentGlucose.toStringAsFixed(0)} mg/dL et une cible de ${targetGlucose.toStringAsFixed(0)} mg/dL, la dose est de :";
        _logCorrection(currentGlucose, correctionDose);
      } else {
        title = "Glycémie Correcte";
        message = "Votre glycémie est dans la cible. Aucune correction n'est nécessaire.";
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontSize: 16)),
              if (correctionDose > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    '${correctionDose.toStringAsFixed(1)} unités',
                    style: const TextStyle(
                      color: Color(0xFF27AE60),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                "Avertissement : Ceci est une suggestion. Consultez toujours un médecin avant de modifier votre traitement.",
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey[700]),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("COMPRIS", style: TextStyle(fontSize: 16, color: Color(0xFF2D9CDB), fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    }
  }

  Future<void> _logCorrection(double glucose, double insulinDose) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final log = LogModel(
      id: FirebaseFirestore.instance.collection('logs').doc().id,
      timestamp: DateTime.now(),
      type: 'Correction',
      glucose: glucose,
      insulinDose: insulinDose,
      notes: 'Correction automatique',
    );
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('logs').doc(log.id).set(log.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Correction de Glycémie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF2D9CDB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists || snapshot.data!.data()?['isf'] == null || (snapshot.data!.data()!['isf'] as num) <= 0) {
            return _buildProfileNotSetWidget();
          }
          final userData = snapshot.data!.data()!;
          final isf = (userData['isf'] as num).toDouble();
          return _buildCorrectionForm(isf);
        },
      ),
    );
  }

  Widget _buildProfileNotSetWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orangeAccent),
            const SizedBox(height: 24),
            const Text(
              'Profil Incomplet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Définissez votre Facteur de Sensibilité à l\'Insuline (ISF) dans votre profil pour utiliser ce module.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.person, color: Colors.white),
              label: const Text('Aller au Profil'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D9CDB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectionForm(double isf) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                "Votre ISF : 1 unité fait baisser de ${isf.toStringAsFixed(0)} mg/dL",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _currentGlucoseController,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Glycémie Actuelle (mg/dL)',
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                  prefixIcon: const Icon(Icons.bloodtype, color: Color(0xFF2D9CDB)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D9CDB), width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Veuillez entrer une valeur valide.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _targetGlucoseController,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Glycémie Cible (mg/dL)',
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                  prefixIcon: const Icon(Icons.gps_fixed, color: Color(0xFF2D9CDB)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D9CDB), width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Veuillez entrer une valeur valide.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 60),
              ElevatedButton.icon(
                icon: const Icon(Icons.calculate, color: Colors.white),
                label: const Text('Calculer la Correction'),
                onPressed: () => _calculateAndShowCorrection(isf),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D9CDB), // CHANGED TO BLUE
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
