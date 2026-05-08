import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/database_service.dart';

// ─── Meal model ────────────────────────────────────────────────────────────────

class Meal {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final String? firestoreId; // set when loaded back from Firestore

  Meal({
    required this.name,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    this.firestoreId,
  });
}

// ─── Workout schedule models ───────────────────────────────────────────────────

/// A single workout block assigned to a day — has its own focus + difficulty
/// so users can mix-and-match independently of their global level.
class WorkoutBlock {
  final String focus;   // 'Abs', 'Arms', 'Chest', 'Legs', 'Shoulders'
  final String level;  // 'Beginner', 'Intermediate', 'Advanced'
  final String id;     // unique key so we can remove specific blocks

  WorkoutBlock({
    required this.focus,
    required this.level,
    required this.id,
  });

  WorkoutBlock copyWith({String? focus, String? level}) {
    return WorkoutBlock(
      focus: focus ?? this.focus,
      level: level ?? this.level,
      id: id,
    );
  }
}

/// The full 7-day schedule: maps day index (0=Mon … 6=Sun) to a list of
/// WorkoutBlocks. An empty list means rest day.
typedef WeekSchedule = Map<int, List<WorkoutBlock>>;

// ─── Weight loss / gain rate constants ────────────────────────────────────────

/// Labels for the rate options shown in setup and profile screens.
const List<Map<String, dynamic>> kWeightLossRates = [
  {
    'key': 'Mild Weight Loss',
    'label': 'Mild weight loss',
    'subtitle': '0.5 lb / week',
    'deficit': 250,       // kcal deficit per day
    'recommended': true,
  },
  {
    'key': 'Moderate Weight Loss',
    'label': 'Moderate weight loss',
    'subtitle': '1 lb / week',
    'deficit': 500,
    'recommended': true,
  },
  {
    'key': 'Extreme Weight Loss',
    'label': 'Extreme weight loss',
    'subtitle': '2 lb / week',
    'deficit': 1000,
    'recommended': false,
  },
];

const List<Map<String, dynamic>> kWeightGainRates = [
  {
    'key': 'Lean Bulk',
    'label': 'Lean bulk',
    'subtitle': '0.25 lb / week',
    'surplus': 125,
    'recommended': true,
  },
  {
    'key': 'Moderate Bulk',
    'label': 'Moderate bulk',
    'subtitle': '0.5 lb / week',
    'surplus': 250,
    'recommended': true,
  },
  {
    'key': 'Aggressive Bulk',
    'label': 'Aggressive bulk',
    'subtitle': '1 lb / week',
    'surplus': 500,
    'recommended': false,
  },
];

// ─── AppData ───────────────────────────────────────────────────────────────────

class AppData {
  static final ValueNotifier<List<Meal>> meals = ValueNotifier<List<Meal>>([]);

  static final ValueNotifier<int> calorieGoal = ValueNotifier<int>(2200);
  static final ValueNotifier<double> bmi = ValueNotifier<double>(0);

  // Persists the chosen fitness level across the session
  static final ValueNotifier<String?> fitnessLevel =
      ValueNotifier<String?>(null);

  // The customisable 7-day workout schedule
  static final ValueNotifier<WeekSchedule> weekSchedule =
      ValueNotifier<WeekSchedule>(_emptyWeek());

  // ── Profile fields ────────────────────────────────────────────────────────

  static final ValueNotifier<String> userName = ValueNotifier<String>('');
  static final ValueNotifier<double> currentWeight = ValueNotifier<double>(0);
  static final ValueNotifier<double> targetWeight = ValueNotifier<double>(0);
  static final ValueNotifier<int> age = ValueNotifier<int>(0);
  static final ValueNotifier<String> gender = ValueNotifier<String>('');
  static final ValueNotifier<double> heightInches = ValueNotifier<double>(0);
  static final ValueNotifier<String> goal = ValueNotifier<String>('');
  static final ValueNotifier<String> activityLevel = ValueNotifier<String>('');

  // The selected weight loss/gain rate key — e.g. 'Mild Weight Loss'
  static final ValueNotifier<String?> weightGoalRate =
      ValueNotifier<String?>(null);

  // ── Schedule helpers ─────────────────────────────────────────────────────

  static WeekSchedule _emptyWeek() =>
      {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []};

  // Called after sign-up to seed the default Mon–Fri plan
  static void initDefaultSchedule(String level) {
    final defaults = {
      0: 'Abs',
      1: 'Arms',
      2: 'Chest',
      3: 'Legs',
      4: 'Shoulders',
    };
    final schedule = _emptyWeek();
    defaults.forEach((dayIndex, focus) {
      schedule[dayIndex] = [
        WorkoutBlock(
          focus: focus,
          level: level,
          id: '${dayIndex}_${focus}_default',
        ),
      ];
    });
    weekSchedule.value = schedule;
  }

  static void addWorkoutBlock(int dayIndex, WorkoutBlock block) {
    final updated = Map<int, List<WorkoutBlock>>.from(weekSchedule.value);
    updated[dayIndex] = [...(updated[dayIndex] ?? []), block];
    weekSchedule.value = updated;
  }

  static void removeWorkoutBlock(int dayIndex, String blockId) {
    final updated = Map<int, List<WorkoutBlock>>.from(weekSchedule.value);
    updated[dayIndex] =
        (updated[dayIndex] ?? []).where((b) => b.id != blockId).toList();
    weekSchedule.value = updated;
  }

  static void updateWorkoutBlock(int dayIndex, WorkoutBlock updatedBlock) {
    final updated = Map<int, List<WorkoutBlock>>.from(weekSchedule.value);
    updated[dayIndex] = (updated[dayIndex] ?? [])
        .map((b) => b.id == updatedBlock.id ? updatedBlock : b)
        .toList();
    weekSchedule.value = updated;
  }

  // ── Meal helpers ─────────────────────────────────────────────────────────

  static int get totalCalories {
    return meals.value.fold(0, (sum, meal) => sum + meal.calories);
  }

  static void addMeal(String name, int calories,
      {int protein = 0, int carbs = 0, int fats = 0}) {
    meals.value = [
      ...meals.value,
      Meal(name: name, calories: calories,
          protein: protein, carbs: carbs, fats: fats),
    ];

    // persist to Firestore so meals survive logout/login
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseService().logMeal({
        'userId': user.uid,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'loggedAt': DateTime.now(),
      });
    }
  }

  static void deleteMeal(int index) {
    final meal = meals.value[index];
    final updatedMeals = [...meals.value];
    updatedMeals.removeAt(index);
    meals.value = updatedMeals;

    // remove from Firestore if it has a stored id
    if (meal.firestoreId != null) {
      DatabaseService().deleteMeal(meal.firestoreId!);
    }
  }

  // ── BMI / calorie helpers ────────────────────────────────────────────────

  static double calculateBMI({
    required double weightLbs,
    required double heightInches,
  }) {
    return (weightLbs / (heightInches * heightInches)) * 703;
  }

  /// Calculates TDEE (maintenance calories) with no deficit/surplus applied.
  /// Use this to show the breakdown of options to the user.
  static int calculateMaintenance({
    required int age,
    required double weightLbs,
    required double heightInches,
    required String gender,
    required String activityLevel,
  }) {
    final weightKg = weightLbs * 0.453592;
    final heightCm = heightInches * 2.54;

    double bmr;

    if (gender == 'Male') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else if (gender == 'Female') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    } else {
      // neutral average
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 78;
    }

    double activityMultiplier;

    switch (activityLevel) {
      case 'Lightly Active':
        activityMultiplier = 1.375;
        break;
      case 'Moderately Active':
        activityMultiplier = 1.55;
        break;
      case 'Very Active':
        activityMultiplier = 1.725;
        break;
      default:
        activityMultiplier = 1.2;
    }

    return (bmr * activityMultiplier).round();
  }

  static int calculateCalorieGoal({
    required int age,
    required double weightLbs,
    required double heightInches,
    required String gender,
    required String activityLevel,
    required String goal,
    String? weightGoalRate,
  }) {
    final maintenance = calculateMaintenance(
      age: age,
      weightLbs: weightLbs,
      heightInches: heightInches,
      gender: gender,
      activityLevel: activityLevel,
    );

    // apply the right deficit or surplus based on the selected rate
    if (weightGoalRate != null) {
      // check weight loss rates
      for (final rate in kWeightLossRates) {
        if (rate['key'] == weightGoalRate) {
          return maintenance - (rate['deficit'] as int);
        }
      }
      // check weight gain rates
      for (final rate in kWeightGainRates) {
        if (rate['key'] == weightGoalRate) {
          return maintenance + (rate['surplus'] as int);
        }
      }
    }

    // fallback to legacy goal-based logic if no specific rate is set
    if (goal == 'Weight Loss') {
      return maintenance - 500;
    } else if (goal == 'Bulk') {
      return maintenance + 300;
    }

    return maintenance; // Maintenance
  }

  // loads today's meals from Firestore and populates AppData.meals
  static Future<void> loadTodaysMeals(String userId) async {
    final data = await DatabaseService().getMealsByDate(userId, DateTime.now());
    meals.value = data.map((m) => Meal(
      name: m['name'] as String? ?? '',
      calories: (m['calories'] as num?)?.toInt() ?? 0,
      protein: (m['protein'] as num?)?.toInt() ?? 0,
      carbs: (m['carbs'] as num?)?.toInt() ?? 0,
      fats: (m['fats'] as num?)?.toInt() ?? 0,
      firestoreId: m['id'] as String?,
    )).toList();
  }

  static void saveProfileData({
    required int age,
    required double weightLbs,
    required double heightInches,
    required String gender,
    required String activityLevel,
    required String goal,
    String? weightGoalRate,
  }) {
    bmi.value = calculateBMI(
      weightLbs: weightLbs,
      heightInches: heightInches,
    );

    calorieGoal.value = calculateCalorieGoal(
      age: age,
      weightLbs: weightLbs,
      heightInches: heightInches,
      gender: gender,
      activityLevel: activityLevel,
      goal: goal,
      weightGoalRate: weightGoalRate,
    );

    // populate profile fields for the profile screen
    AppData.goal.value = goal;
    AppData.activityLevel.value = activityLevel;
    AppData.currentWeight.value = weightLbs;
    AppData.age.value = age;
    AppData.gender.value = gender;
    AppData.heightInches.value = heightInches;
    AppData.weightGoalRate.value = weightGoalRate;

    // target weight defaults to current - 10 for weight loss, same for others
    if (goal == 'Weight Loss') {
      AppData.targetWeight.value = weightLbs - 10;
    } else {
      AppData.targetWeight.value = weightLbs;
    }
  }
}
