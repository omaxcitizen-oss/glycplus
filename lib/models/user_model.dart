import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;

  // 1. Profil utilisateur
  final int? age;
  final double? weight;
  final String? diabetesType; // Type 1, Type 2, LADA, etc.
  final String? glucoseUnit; // mg/dL ou mmol/L

  // 2. Objectifs glycémiques
  final double? fastingTargetGlucose;
  final double? postprandialTargetGlucose;

  // 3. Insuline
  final String? basalInsulinBrand;
  final double? basalInsulinDose;
  final String? bolusInsulinBrand;
  final double? bolusInsulinDose;

  // 4. Calcul automatique
  final double? isf; // Insulin Sensitivity Factor
  final double? icr; // Insulin-to-Carb Ratio

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.age,
    this.weight,
    this.diabetesType,
    this.glucoseUnit,
    this.fastingTargetGlucose,
    this.postprandialTargetGlucose,
    this.basalInsulinBrand,
    this.basalInsulinDose,
    this.bolusInsulinBrand,
    this.bolusInsulinDose,
    this.isf,
    this.icr,
  });

  // Helper getter for total daily dose
  double get totalInsulinDose => (basalInsulinDose ?? 0) + (bolusInsulinDose ?? 0);


  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return UserModel(
      uid: snapshot.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      age: data['age'] as int?,
      weight: (data['weight'] as num?)?.toDouble(),
      diabetesType: data['diabetesType'] as String?,
      glucoseUnit: data['glucoseUnit'] as String?,
      fastingTargetGlucose: (data['fastingTargetGlucose'] as num?)?.toDouble(),
      postprandialTargetGlucose: (data['postprandialTargetGlucose'] as num?)?.toDouble(),
      basalInsulinBrand: data['basalInsulinBrand'] as String?,
      basalInsulinDose: (data['basalInsulinDose'] as num?)?.toDouble(),
      bolusInsulinBrand: data['bolusInsulinBrand'] as String?,
      bolusInsulinDose: (data['bolusInsulinDose'] as num?)?.toDouble(),
      isf: (data['isf'] as num?)?.toDouble(),
      icr: (data['icr'] as num?)?.toDouble(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      age: json['age'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      diabetesType: json['diabetesType'] as String?,
      glucoseUnit: json['glucoseUnit'] as String?,
      fastingTargetGlucose: (json['fastingTargetGlucose'] as num?)?.toDouble(),
      postprandialTargetGlucose: (json['postprandialTargetGlucose'] as num?)?.toDouble(),
      basalInsulinBrand: json['basalInsulinBrand'] as String?,
      basalInsulinDose: (json['basalInsulinDose'] as num?)?.toDouble(),
      bolusInsulinBrand: json['bolusInsulinBrand'] as String?,
      bolusInsulinDose: (json['bolusInsulinDose'] as num?)?.toDouble(),
      isf: (json['isf'] as num?)?.toDouble(),
      icr: (json['icr'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'age': age,
      'weight': weight,
      'diabetesType': diabetesType,
      'glucoseUnit': glucoseUnit,
      'fastingTargetGlucose': fastingTargetGlucose,
      'postprandialTargetGlucose': postprandialTargetGlucose,
      'basalInsulinBrand': basalInsulinBrand,
      'basalInsulinDose': basalInsulinDose,
      'bolusInsulinBrand': bolusInsulinBrand,
      'bolusInsulinDose': bolusInsulinDose,
      'isf': isf,
      'icr': icr,
    };
  }
}
