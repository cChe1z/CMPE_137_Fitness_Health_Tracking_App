import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserProfile(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).set(data);
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  Future<void> logMeal(Map<String, dynamic> mealData) async {
    await _db.collection('meal_logs').add(mealData);
  }

  Future<void> deleteMeal(String mealId) async {
    await _db.collection('meal_logs').doc(mealId).delete();
  }

  Future<List<Map<String, dynamic>>> getMealsByDate(String userId, DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));
    
    QuerySnapshot snapshot = await _db
        .collection('meal_logs')
        .where('userId', isEqualTo: userId)
        .where('loggedAt', isGreaterThanOrEqualTo: startOfDay)
        .where('loggedAt', isLessThan: endOfDay)
        .orderBy('loggedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList();
  }

  Future<void> logWorkout(Map<String, dynamic> workoutData) async {
    await _db.collection('workout_logs').add(workoutData);
  }

  Future<List<Map<String, dynamic>>> getWorkoutsByDate(String userId, DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));
    
    QuerySnapshot snapshot = await _db
        .collection('workout_logs')
        .where('userId', isEqualTo: userId)
        .where('loggedAt', isGreaterThanOrEqualTo: startOfDay)
        .where('loggedAt', isLessThan: endOfDay)
        .orderBy('loggedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList();
  }

  Future<void> saveFitnessPlan(String userId, Map<String, dynamic> planData) async {
    await _db.collection('fitness_plans').doc(userId).set(planData);
  }

  Future<Map<String, dynamic>?> getFitnessPlan(String userId) async {
    DocumentSnapshot doc = await _db.collection('fitness_plans').doc(userId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  Future<int> getDailyCalorieTotal(String userId, DateTime date) async {
    List<Map<String, dynamic>> meals = await getMealsByDate(userId, date);
    int total = 0;
    for (var meal in meals) {
      total += (meal['calories'] as num).toInt();
    }
    return total;
  }

  // ── Daily snapshots (weight + calories per day) ───────────────────────────

  /// Merge-writes fields into a per-user, per-date document.
  /// dateKey format: 'YYYY-MM-DD'
  Future<void> saveDailySnapshot(
      String userId, String dateKey, Map<String, dynamic> data) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('daily_logs')
        .doc(dateKey)
        .set(data, SetOptions(merge: true));
  }

  /// Returns the snapshot for a single date, or null if none exists.
  Future<Map<String, dynamic>?> getDailySnapshot(
      String userId, String dateKey) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('daily_logs')
        .doc(dateKey)
        .get();
    return doc.data();
  }

  /// Returns all daily logs for a user, sorted oldest → newest.
  Future<List<Map<String, dynamic>>> getDailyLogs(String userId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('daily_logs')
        .orderBy(FieldPath.documentId)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }
}
