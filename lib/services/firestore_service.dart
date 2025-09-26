
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/glucose_reading.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Glucose Readings --- //

  // Get a stream of glucose readings for a user
  Stream<List<GlucoseReading>> getGlucoseReadingsStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('glucose_readings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GlucoseReading.fromFirestore(doc))
            .toList());
  }

  // Add a new glucose reading
  Future<void> addGlucoseReading(GlucoseReading reading) {
    return _db
        .collection('users')
        .doc(reading.userId)
        .collection('glucose_readings')
        .add(reading.toJson());
  }

  // Update an existing glucose reading
  Future<void> updateGlucoseReading(GlucoseReading reading) {
    return _db
        .collection('users')
        .doc(reading.userId)
        .collection('glucose_readings')
        .doc(reading.id)
        .update(reading.toJson());
  }

  // Delete a glucose reading
  Future<void> deleteGlucoseReading(String userId, String readingId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('glucose_readings')
        .doc(readingId)
        .delete();
  }

  // --- User Profile --- //

  // Get a stream of the user's profile
  Stream<UserProfile?> getUserProfileStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserProfile.fromFirestore(snapshot);
      }
      return null;
    });
  }

  // Create or Update a user profile
  Future<void> setUserProfile(UserProfile profile) {
    return _db.collection('users').doc(profile.uid).set(profile.toJson(), SetOptions(merge: true));
  }
}
