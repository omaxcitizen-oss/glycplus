import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glycplus/services/firestore_service.dart';
import 'package:glycplus/models/user_model.dart';
import 'package:glycplus/models/insulin.dart';
import 'package:glycplus/screens/hyper_screen.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:flutter/scheduler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for TextFormFields
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _fastingTargetController = TextEditingController();
  final _postprandialTargetController = TextEditingController();
  final _basalDoseController = TextEditingController();
  final _bolusDoseController = TextEditingController();
  final _isfController = TextEditingController();
  final _icrController = TextEditingController();

  // Variables for Dropdowns
  String? _selectedDiabetesType;
  String? _selectedGlucoseUnit;
  String? _selectedBasalInsulin;
  String? _selectedBolusInsulin;

  // Variable for total dose display
  double _totalDose = 0.0;

  // To prevent running calculations before the first build
  bool _isFirstBuild = true;

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _fastingTargetController.dispose();
    _postprandialTargetController.dispose();
    _basalDoseController.dispose();
    _bolusDoseController.dispose();
    _isfController.dispose();
    _icrController.dispose();
    super.dispose();
  }

  void _updateCalculatedFields() {
    final double basalDose = double.tryParse(_basalDoseController.text) ?? 0.0;
    final double bolusDose = double.tryParse(_bolusDoseController.text) ?? 0.0;
    final total = basalDose + bolusDose;

    if (mounted) {
      setState(() {
        _totalDose = total;
        if (total > 0) {
          _isfController.text = (1800 / total).toStringAsFixed(2);
          _icrController.text = (500 / total).toStringAsFixed(2);
        } else {
          _isfController.text = '0.0';
          _icrController.text = '0.0';
        }
      });
    }
  }

  void _showEmpiricalIsfDialog() {
    final beforeController = TextEditingController();
    final afterController = TextEditingController();
    final doseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Calculer mon ISF empirique'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: beforeController,
                  decoration: const InputDecoration(
                      labelText: 'Glycémie avant correction'),
                  keyboardType: TextInputType.number),
              TextFormField(
                  controller: afterController,
                  decoration: const InputDecoration(
                      labelText: 'Glycémie après correction (2h)'),
                  keyboardType: TextInputType.number),
              TextFormField(
                  controller: doseController,
                  decoration: const InputDecoration(
                      labelText: 'Dose d\'insuline administrée'),
                  keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                final double? before = double.tryParse(beforeController.text);
                final double? after = double.tryParse(afterController.text);
                final double? dose = double.tryParse(doseController.text);

                if (before != null && after != null && dose != null && dose > 0) {
                  final double empiricalIsf = (before - after) / dose;
                  Navigator.of(context).pop(); // Close the first dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Résultat'),
                      content: Text(
                          'Votre ISF empirique est de ${empiricalIsf.toStringAsFixed(2)} mg/dL.\n\nCela signifie qu’une unité d\'insuline rapide fait baisser votre glycémie d\'environ ${empiricalIsf.toStringAsFixed(2)} mg/dL.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Fermer')),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isfController.text =
                                  empiricalIsf.toStringAsFixed(2);
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Utiliser cette valeur'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Calculer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = Provider.of<User?>(context, listen: false);
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur : Utilisateur non connecté')));
        return;
      }

      final profile = UserModel(
        uid: user.uid,
        email: user.email,
        age: int.tryParse(_ageController.text),
        weight: double.tryParse(_weightController.text),
        diabetesType: _selectedDiabetesType,
        glucoseUnit: _selectedGlucoseUnit,
        fastingTargetGlucose: double.tryParse(_fastingTargetController.text),
        postprandialTargetGlucose:
            double.tryParse(_postprandialTargetController.text),
        basalInsulinBrand: _selectedBasalInsulin,
        basalInsulinDose: double.tryParse(_basalDoseController.text),
        bolusInsulinBrand: _selectedBolusInsulin,
        bolusInsulinDose: double.tryParse(_bolusDoseController.text),
        isf: double.tryParse(_isfController.text),
        icr: double.tryParse(_icrController.text),
      );

      try {
        await firestoreService.setUserProfile(profile);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil sauvegardé avec succès !')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HyperScreen()),
        );
      } catch (e) {
        developer.log('Error saving profile: $e', name: 'profile_screen');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la sauvegarde : $e')));
      }
    }
  }

  void _populateFields(UserModel userProfile) {
    final basalInsulinBrands = basalInsulins.map((e) => e.brandName).toList();
    final bolusInsulinBrands = bolusInsulins.map((e) => e.brandName).toList();
    final diabetesTypes = ['Type 1', 'Type 2', 'Type 2 (insulino-dépendant)', 'LADA', 'Autre'];

    _ageController.text = userProfile.age?.toString() ?? '';
    _weightController.text = userProfile.weight?.toString() ?? '';
    _fastingTargetController.text = userProfile.fastingTargetGlucose?.toString() ?? '';
    _postprandialTargetController.text = userProfile.postprandialTargetGlucose?.toString() ?? '';
    _basalDoseController.text = userProfile.basalInsulinDose?.toString() ?? '';
    _bolusDoseController.text = userProfile.bolusInsulinDose?.toString() ?? '';
    _isfController.text = userProfile.isf?.toString() ?? '';
    _icrController.text = userProfile.icr?.toString() ?? '';

    _selectedGlucoseUnit = userProfile.glucoseUnit ?? 'mg/dL';

    if (diabetesTypes.contains(userProfile.diabetesType)) {
      _selectedDiabetesType = userProfile.diabetesType;
    }
    if (basalInsulinBrands.contains(userProfile.basalInsulinBrand)) {
      _selectedBasalInsulin = userProfile.basalInsulinBrand;
    }
    if (bolusInsulinBrands.contains(userProfile.bolusInsulinBrand)) {
      _selectedBolusInsulin = userProfile.bolusInsulinBrand;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final user = Provider.of<User?>(context);

    final basalInsulinBrands = basalInsulins.map((e) => e.brandName).toList();
    final bolusInsulinBrands = bolusInsulins.map((e) => e.brandName).toList();
    final diabetesTypes = ['Type 1', 'Type 2', 'Type 2 (insulino-dépendant)', 'LADA', 'Autre'];

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: user == null
          ? const Center(child: Text('Veuillez vous connecter.'))
          : StreamBuilder<UserModel>(
              stream: firestoreService.getUserProfileStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && _isFirstBuild) {
                  final userProfile = snapshot.data!;
                   SchedulerBinding.instance.addPostFrameCallback((_) {
                     _populateFields(userProfile);
                     _updateCalculatedFields();
                     if(mounted) setState(() => _isFirstBuild = false);
                   });
                }

                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildSectionTitle('Profil Utilisateur'),
                      TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(labelText: 'Âge'),
                          keyboardType: TextInputType.number),
                      TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(labelText: 'Poids (kg)'),
                          keyboardType: TextInputType.number),
                      DropdownButtonFormField<String>(
                        value: _selectedDiabetesType,
                        decoration:
                            const InputDecoration(labelText: 'Type de diabète'),
                        items: diabetesTypes.map((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                        onChanged: (newValue) =>
                            setState(() => _selectedDiabetesType = newValue),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedGlucoseUnit,
                        decoration:
                            const InputDecoration(labelText: 'Unité Glycémie'),
                        items: ['mg/dL', 'mmol/L'].map((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                        onChanged: (newValue) =>
                            setState(() => _selectedGlucoseUnit = newValue),
                        validator: (value) =>
                            value == null ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Objectifs Glycémiques'),
                      TextFormField(
                          controller: _fastingTargetController,
                          decoration: const InputDecoration(
                              labelText: 'Glycémie cible à jeun'),
                          keyboardType: TextInputType.number),
                      TextFormField(
                          controller: _postprandialTargetController,
                          decoration: const InputDecoration(
                              labelText: 'Glycémie cible postprandiale'),
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Insuline'),
                      DropdownButtonFormField<String>(
                        value: _selectedBasalInsulin,
                        decoration:
                            const InputDecoration(labelText: 'Basale (lente)'),
                        items: basalInsulinBrands.map((String brand) {
                          return DropdownMenuItem<String>(
                              value: brand, child: Text(brand));
                        }).toList(),
                        onChanged: (newValue) =>
                            setState(() => _selectedBasalInsulin = newValue),
                      ),
                      TextFormField(
                          controller: _basalDoseController,
                          decoration: const InputDecoration(
                              labelText: 'Dose journalière (Basale)'),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _updateCalculatedFields(),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedBolusInsulin,
                        decoration:
                            const InputDecoration(labelText: 'Bolus (rapide)'),
                        items: bolusInsulinBrands.map((String brand) {
                          return DropdownMenuItem<String>(
                              value: brand, child: Text(brand));
                        }).toList(),
                        onChanged: (newValue) =>
                            setState(() => _selectedBolusInsulin = newValue),
                      ),
                      TextFormField(
                          controller: _bolusDoseController,
                          decoration: const InputDecoration(
                              labelText: 'Dose journalière (Bolus)'),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _updateCalculatedFields(),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Calcul Automatique'),
                      Text(
                          'Dose totale journalière: ${_totalDose.toStringAsFixed(1)} unités',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                          controller: _isfController,
                          decoration: const InputDecoration(
                              labelText: 'Facteur de Sensibilité (ISF)'),
                          keyboardType: TextInputType.number),
                      _buildInfoCard(
                          'L\'ISF indique de combien votre glycémie baisse (en ${_selectedGlucoseUnit ?? 'mg/dL'}) pour 1 unité d\'insuline rapide.'),
                      ElevatedButton(
                          onPressed: _showEmpiricalIsfDialog,
                          child: const Text('Calculer mon ISF empirique')),
                      const SizedBox(height: 10),
                      TextFormField(
                          controller: _icrController,
                          decoration: const InputDecoration(
                              labelText: 'Ratio Insuline/Glucides (ICR)'),
                          keyboardType: TextInputType.number),
                      _buildInfoCard(
                          'L\'ICR indique combien de grammes de glucides sont couverts par 1 unité d\'insuline rapide.'),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Sauvegarder et Aller à la Correction'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildInfoCard(String message) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }
}
