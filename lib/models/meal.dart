import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String? id;
  final String food;
  final int carbohydrates;
  final DateTime timestamp;

  Meal({
    this.id,
    required this.food,
    required this.carbohydrates,
    required this.timestamp,
  });

  // Crée un Meal à partir d'un document Firestore
  factory Meal.fromJson(Map<String, dynamic> json, String id) {
    return Meal(
      id: id,
      food: json['food'] as String,
      carbohydrates: json['carbohydrates'] as int,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  // Convertit un Meal en JSON pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'food': food,
      'carbohydrates': carbohydrates,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
