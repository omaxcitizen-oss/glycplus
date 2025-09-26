import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  String? id;
  final String description;
  final DateTime timestamp;
  final String userId;

  Meal({
    this.id,
    required this.description,
    required this.timestamp,
    required this.userId,
  });

  // Convert Meal object to a Map
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
    };
  }

  // Create a Meal object from a Map
  factory Meal.fromMap(Map<String, dynamic> map, String id) {
    return Meal(
      id: id,
      description: map['description'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      userId: map['userId'] as String,
    );
  }
}
