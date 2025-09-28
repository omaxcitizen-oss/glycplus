import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String? id;
  final String uid;
  final String? pseudo;

  // 1. Profil utilisateur
  final int? age;
  final double? weight;
  final String? diabetesType;
  final String? glucoseUnit;

  // 2. Objectifs glycémiques
  final double? targetGlucoseFasting;
  final double? targetGlucosePostprandial;

  // 3. Insuline
  final String? basalInsulinBrand;
  final double? basalInsulinDose;
  final String? bolusInsulinBrand;
  final double? bolusInsulinDose;

  // 4. Ratios de calcul
  final double? isf; // Insulin Sensitivity Factor
  final double? icr; // Insulin-to-Carb Ratio

  UserProfile({
    this.id,
    required this.uid,
    this.pseudo,
    this.age,
    this.weight,
    this.diabetesType,
    this.glucoseUnit,
    this.targetGlucoseFasting,
    this.targetGlucosePostprandial,
    this.basalInsulinBrand,
    this.basalInsulinDose,
    this.bolusInsulinBrand,
    this.bolusInsulinDose,
    this.isf,
    this.icr,
  });

  // Calcul de la dose totale (lecture seule)
  double? get totalDailyDose {
    if (basalInsulinDose != null && bolusInsulinDose != null) {
      return basalInsulinDose! + bolusInsulinDose!;
    }
    return null;
  }

  // Conversion en Map pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'pseudo': pseudo,
      'age': age,
      'weight': weight,
      'diabetesType': diabetesType,
      'glucoseUnit': glucoseUnit,
      'targetGlucoseFasting': targetGlucoseFasting,
      'targetGlucosePostprandial': targetGlucosePostprandial,
      'basalInsulinBrand': basalInsulinBrand,
      'basalInsulinDose': basalInsulinDose,
      'bolusInsulinBrand': bolusInsulinBrand,
      'bolusInsulinDose': bolusInsulinDose,
      'isf': isf,
      'icr': icr,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  // Création depuis un DocumentSnapshot de Firestore
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      uid: data['uid'],
      pseudo: data['pseudo'] as String?,
      age: data['age'] as int?,
      weight: (data['weight'] as num?)?.toDouble(),
      diabetesType: data['diabetesType'] as String?,
      glucoseUnit: data['glucoseUnit'] as String?,
      targetGlucoseFasting: (data['targetGlucoseFasting'] as num?)?.toDouble(),
      targetGlucosePostprandial:
          (data['targetGlucosePostprandial'] as num?)?.toDouble(),
      basalInsulinBrand: data['basalInsulinBrand'] as String?,
      basalInsulinDose: (data['basalInsulinDose'] as num?)?.toDouble(),
      bolusInsulinBrand: data['bolusInsulinBrand'] as String?,
      bolusInsulinDose: (data['bolusInsulinDose'] as num?)?.toDouble(),
      isf: (data['isf'] as num?)?.toDouble(),
      icr: (data['icr'] as num?)?.toDouble(),
    );
  }
}
