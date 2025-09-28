import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glycplus/models/user_model.dart';
import 'package:glycplus/models/meal.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users
  Future<void> setUserProfile(UserModel user) {
    return _db.collection('users').doc(user.uid).set(user.toJson());
  }

  Future<UserModel> getUserProfile(String uid) async {
    final snapshot = await _db.collection('users').doc(uid).get();
    if (snapshot.exists && snapshot.data() != null) {
      return UserModel.fromJson(snapshot.data()!);
    } else {
      // Return a default/empty user model if the document doesn't exist
      return UserModel(uid: uid);
    }
  }

  Stream<UserModel> getUserProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (snap.exists && snap.data() != null) {
        return UserModel.fromJson(snap.data()!);
      } else {
        // Return a default/empty user model if the document doesn't exist
        return UserModel(uid: uid);
      }
    });
  }

  // Meals
  Future<void> addMeal(String uid, Meal meal) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('meals')
        .add(meal.toJson());
  }

  Future<void> updateMeal(String uid, Meal meal) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('meals')
        .doc(meal.id)
        .update(meal.toJson());
  }

  Future<void> deleteMeal(String uid, String mealId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('meals')
        .doc(mealId)
        .delete();
  }

  Stream<List<Meal>> getMealsStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('meals')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Meal.fromJson(doc.data(), doc.id))
            .toList());
  }
}
