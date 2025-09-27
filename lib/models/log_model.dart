import 'package:cloud_firestore/cloud_firestore.dart';

class LogModel {
  final String id;
  final DateTime timestamp;
  final String type; // e.g., 'Meal', 'Correction', 'Bolus', 'Basal'
  final double? glucose;
  final double? insulinDose;
  final String? mealType; // e.g., 'Breakfast', 'Lunch', 'Dinner', 'Snack'
  final String? notes;

  LogModel({
    required this.id,
    required this.timestamp,
    required this.type,
    this.glucose,
    this.insulinDose,
    this.mealType,
    this.notes,
  });

  // Convert a LogModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'glucose': glucose,
      'insulinDose': insulinDose,
      'mealType': mealType,
      'notes': notes,
    };
  }

  // Create a LogModel from a Map
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['id'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: map['type'] as String,
      glucose: map['glucose'] as double?,
      insulinDose: map['insulinDose'] as double?,
      mealType: map['mealType'] as String?,
      notes: map['notes'] as String?,
    );
  }
}
