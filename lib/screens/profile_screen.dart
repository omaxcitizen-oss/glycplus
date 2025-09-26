
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../models/insulin.dart';
import 'advice_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  UserProfile? _userProfile;
  bool _isSaving = false;

  // Controllers
  final _pseudoController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetFastingController = TextEditingController();
  final _targetPostprandialController = TextEditingController();
  final _basalDoseController = TextEditingController();
  final _bolusDoseController = TextEditingController();
  final _isfController = TextEditingController();
  final _icrController = TextEditingController();

  // Dropdown values
  String? _selectedDiabetesType;
  String? _selectedGlucoseUnit = 'mg/dL'; // Default value
  String? _selectedBasalInsulin;
  String? _selectedBolusInsulin;

  @override
  void initState() {
    super.initState();
    _basalDoseController.addListener(_autoCalculateRatios);
    _bolusDoseController.addListener(_autoCalculateRatios);
  }

  @override
  void dispose() {
    _basalDoseController.removeListener(_autoCalculateRatios);
    _bolusDoseController.removeListener(_autoCalculateRatios);
    _pseudoController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _targetFastingController.dispose();
    _targetPostprandialController.dispose();
    _basalDoseController.dispose();
    _bolusDoseController.dispose();
    _isfController.dispose();
    _icrController.dispose();
    super.dispose();
  }

  void _loadUserProfile(UserProfile? profile) {
    if (profile == null) return;
    _userProfile = profile;

    _pseudoController.text = profile.pseudo ?? '';
    _ageController.text = profile.age?.toString() ?? '';
    _weightController.text = profile.weight?.toString() ?? '';
    _selectedDiabetesType = profile.diabetesType;
    _selectedGlucoseUnit = profile.glucoseUnit ?? 'mg/dL';
    _targetFastingController.text = profile.targetGlucoseFasting?.toString() ?? '';
    _targetPostprandialController.text = profile.targetGlucosePostprandial?.toString() ?? '';
    _selectedBasalInsulin = profile.basalInsulinBrand;
    _basalDoseController.text = profile.basalInsulinDose?.toString() ?? '';
    _selectedBolusInsulin = profile.bolusInsulinBrand;
    _bolusDoseController.text = profile.bolusInsulinDose?.toString() ?? '';
    _isfController.text = profile.isf?.toString() ?? '';
    _icrController.text = profile.icr?.toString() ?? '';
  }

  void _autoCalculateRatios() {
    final double basalDose = double.tryParse(_basalDoseController.text) ?? 0;
    final double bolusDose = double.tryParse(_bolusDoseController.text) ?? 0;
    final totalDose = basalDose + bolusDose;

    if (totalDose > 0) {
      double isf;
      switch (_selectedGlucoseUnit ?? 'mg/dL') {
        case 'mmol/L':
          isf = 100 / totalDose;
          break;
        case 'g/dL':
           isf = 1.8 / totalDose;
           break;
        case 'mg/dL':
        default:
          isf = 1800 / totalDose;
          break;
      }
      
      final icr = 500 / totalDose;
      
      if (isf.isFinite && !isf.isNegative) {
        _isfController.text = isf.toStringAsFixed(1);
      }
      if (icr.isFinite && !icr.isNegative) {
        _icrController.text = icr.toStringAsFixed(1);
      }
    } else {
      _isfController.clear();
      _icrController.clear();
    }
  }

  void _navigateToAdviceScreen() {
    final double? isf = double.tryParse(_isfController.text);
    final double? icr = double.tryParse(_icrController.text);

    if (isf != null && icr != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdviceScreen(
            isf: isf,
            icr: icr,
            glucoseUnit: _selectedGlucoseUnit!,
          ),
        ),
      );
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Les ratios n\'ont pas pu être calculés. Veuillez vérifier les doses d\'insuline.'), backgroundColor: Colors.orange),
        );
    }
  }

  Future<void> _saveProfile(User user) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isSaving = true);

      final profile = UserProfile(
        uid: user.uid,
        pseudo: _pseudoController.text,
        age: int.tryParse(_ageController.text),
        weight: double.tryParse(_weightController.text),
        diabetesType: _selectedDiabetesType,
        glucoseUnit: _selectedGlucoseUnit,
        targetGlucoseFasting: double.tryParse(_targetFastingController.text),
        targetGlucosePostprandial: double.tryParse(_targetPostprandialController.text),
        basalInsulinBrand: _selectedBasalInsulin,
        basalInsulinDose: double.tryParse(_basalDoseController.text),
        bolusInsulinBrand: _selectedBolusInsulin,
        bolusInsulinDose: double.tryParse(_bolusDoseController.text),
        isf: double.tryParse(_isfController.text),
        icr: double.tryParse(_icrController.text),
      );

      try {
        await Provider.of<FirestoreService>(context, listen: false).setUserProfile(profile);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil enregistré avec succès !'), backgroundColor: Colors.green),
        );
        // Redirect if needed
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde: $e'), backgroundColor: Colors.red),
        );
      }

      setState(() => _isSaving = false);
    }
  }

  Future<void> _showEmpiricalIsfDialog() async {
    final formKey = GlobalKey<FormState>();
    final beforeController = TextEditingController();
    final afterController = TextEditingController();
    final doseController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Calculer mon ISF Empirique'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFormField(beforeController, 'Glycémie avant correction', TextInputType.number, prefixIcon: Icons.arrow_upward),
                const SizedBox(height: 16),
                _buildTextFormField(afterController, 'Glycémie après (2h)', TextInputType.number, prefixIcon: Icons.arrow_downward),
                const SizedBox(height: 16),
                _buildTextFormField(doseController, 'Dose d\'insuline rapide (unités)', TextInputType.number, prefixIcon: Icons.opacity),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final before = double.parse(beforeController.text);
                  final after = double.parse(afterController.text);
                  final dose = double.parse(doseController.text);
                  if (dose > 0 && before > after) {
                    final isf = (before - after) / dose;
                    _isfController.text = isf.toStringAsFixed(1);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                        content: Text('Votre ISF empirique calculé est de ${isf.toStringAsFixed(1)}. Il a été mis à jour dans le formulaire.'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                }
              },
              child: const Text('Calculer et Utiliser'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: StreamBuilder<UserProfile?>(
        stream: firestoreService.getUserProfileStream(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && _userProfile == null) {
            _loadUserProfile(snapshot.data);
          }
          return _buildProfileForm(user);
        },
      ),
       floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : (() => _saveProfile(user)),
        label: const Text('Sauvegarder'),
        icon: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildProfileForm(User user) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 80.0), // Add padding to bottom
        children: <Widget>[
          _buildSectionTitle('Profil Utilisateur'),
          _buildTextFormField(_pseudoController, 'Pseudo', TextInputType.text, prefixIcon: Icons.person),
          const SizedBox(height: 16),
          _buildTextFormField(_ageController, 'Âge', TextInputType.number, prefixIcon: Icons.cake),
          const SizedBox(height: 16),
          _buildTextFormField(_weightController, 'Poids (kg)', const TextInputType.numberWithOptions(decimal: true), prefixIcon: Icons.monitor_weight),
          const SizedBox(height: 16),
          _buildDropdownFormField(
            value: _selectedDiabetesType,
            items: ['Type 1', 'Type 2 (insulino-dépendant)', 'LADA', 'Autre'],
            label: 'Type de diabète',
            onChanged: (value) => setState(() => _selectedDiabetesType = value),
          ),
          const SizedBox(height: 16),
          _buildDropdownFormField(
            value: _selectedGlucoseUnit,
            items: ['mg/dL', 'mmol/L', 'g/dL'],
            label: 'Unité de Glycémie',
            onChanged: (value) {
                setState(() => _selectedGlucoseUnit = value);
                _autoCalculateRatios();
            }
          ),
          const Divider(height: 40),

          _buildSectionTitle('Objectifs Glycémiques'),
          _buildTextFormField(_targetFastingController, 'Cible à jeun', const TextInputType.numberWithOptions(decimal: true), prefixIcon: Icons.wb_sunny_outlined, suffixText: _selectedGlucoseUnit),
          const SizedBox(height: 16),
          _buildTextFormField(_targetPostprandialController, 'Cible postprandiale', const TextInputType.numberWithOptions(decimal: true), prefixIcon: Icons.fastfood_outlined, suffixText: _selectedGlucoseUnit),
          const Divider(height: 40),

          _buildSectionTitle('Traitement Insuline'),
          _buildDropdownFormField(value: _selectedBasalInsulin, items: basalInsulinBrands, label: 'Insuline Lente (Basale)', onChanged: (v) => setState(() => _selectedBasalInsulin = v)),
          const SizedBox(height: 16),
          _buildTextFormField(_basalDoseController, 'Dose journalière (unités)', const TextInputType.numberWithOptions(decimal: true), prefixIcon: Icons.timelapse),
          const SizedBox(height: 24),
          _buildDropdownFormField(value: _selectedBolusInsulin, items: bolusInsulinBrands, label: 'Insuline Rapide (Bolus)', onChanged: (v) => setState(() => _selectedBolusInsulin = v)),
          const SizedBox(height: 16),
          _buildTextFormField(_bolusDoseController, 'Dose journalière (unités)', const TextInputType.numberWithOptions(decimal: true), prefixIcon: Icons.speed),
          const Divider(height: 40),
            
          _buildSectionTitle('Ratios de Calcul Personnalisés'),
          _buildTextFormField(_isfController, 'Facteur de Sensibilité (ISF)', const TextInputType.numberWithOptions(decimal: true), prefixIcon: Icons.straighten, suffixText: '${_selectedGlucoseUnit ?? 'mg/dL'}/U'),
          _buildInfoCard('L\'ISF (ou facteur de sensibilité) indique de combien votre glycémie baisse (en ${_selectedGlucoseUnit ?? 'mg/dL'}) pour 1 unité d\'insuline rapide.'),
          const SizedBox(height: 24),
          _buildTextFormField(_icrController, 'Ratio Glucides/Insuline (ICR)', const TextInputType.numberWithOptions(decimal: true), prefixIcon: Icons.rice_bowl, suffixText: 'g/U'),
          _buildInfoCard('L\'ICR représente le nombre de grammes de glucides couverts par 1 unité d\'insuline rapide.'),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Calculer mon ISF Empirique'),
              onPressed: _showEmpiricalIsfDialog,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Voir les conseils pour mes ratios'),
              onPressed: _navigateToAdviceScreen,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
        child: Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
      );

  Widget _buildTextFormField(TextEditingController controller, String label, TextInputType keyboardType, {IconData? prefixIcon, String? suffixText}) => TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixText: suffixText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Ce champ est recommandé.';
          if (num.tryParse(value) == null) return 'Veuillez entrer un nombre valide.';
          if ((num.tryParse(value) ?? -1) < 0) return 'Veuillez entrer une valeur positive.';
          return null;
        },
      );

  Widget _buildDropdownFormField({required String? value, required List<String> items, required String label, required void Function(String?) onChanged}) => DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      );

  Widget _buildInfoCard(String message) => Card(
        margin: const EdgeInsets.only(top: 8.0),
        elevation: 0,
        color: Colors.blue.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message, style: TextStyle(color: Colors.blue.shade800))),
            ],
          ),
        ),
      );
}
