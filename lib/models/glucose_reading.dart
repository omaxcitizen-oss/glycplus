
import 'package:cloud_firestore/cloud_firestore.dart';

class GlucoseReading {
  String? id;
  final double value;
  final DateTime timestamp;
  final String userId;

  GlucoseReading({
    this.id,
    required this.value,
    required this.timestamp,
    required this.userId,
  });

  // Convert a GlucoseReading object to a JSON object (Map)
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
    };
  }

  // Create a GlucoseReading object from a Firestore document
  factory GlucoseReading.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GlucoseReading(
      id: doc.id,
      value: (data['value'] as num).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] as String,
    );
  }
}
