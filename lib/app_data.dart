import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/database_service.dart';

class Meal {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final String? firestoreId;

  Meal({
    required this.name,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    this.firestoreId,
  });
}

class WorkoutBlock {
  final String focus;
  final String level;
  final String id;

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

typedef WeekSchedule = Map<int, List<WorkoutBlock>>;

const List<Map<String, dynamic>> kWeightLossRates = [
  {
    'key': 'Mild Weight Loss',
    'label': 'Mild weight loss',
    'subtitle': '0.5 lb / week',
    'deficit': 250,
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

class AppData {
  static final ValueNotifier<List<Meal>> meals = ValueNotifier<List<Meal>>([]);

  static final ValueNotifier<int> calorieGoal = ValueNotifier<int>(2200);
  static final ValueNotifier<double> bmi = ValueNotifier<double>(0);

  static final ValueNotifier<String?> fitnessLevel =
  ValueNotifier<String?>(null);

  static final ValueNotifier<WeekSchedule> weekSchedule =
  ValueNotifier<WeekSchedule>(_emptyWeek());

  static final ValueNotifier<String> userName = ValueNotifier<String>('');
  static final ValueNotifier<double> currentWeight = ValueNotifier<double>(0);
  static final ValueNotifier<double> targetWeight = ValueNotifier<double>(0);
  static final ValueNotifier<int> age = ValueNotifier<int>(0);
  static final ValueNotifier<String> gender = ValueNotifier<String>('');
  static final ValueNotifier<double> heightInches = ValueNotifier<double>(0);
  static final ValueNotifier<String> goal = ValueNotifier<String>('');
  static final ValueNotifier<String> activityLevel = ValueNotifier<String>('');

  static final ValueNotifier<String?> weightGoalRate =
  ValueNotifier<String?>(null);

  static WeekSchedule _emptyWeek() =>
      {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []};

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
    saveScheduleToFirestore();
  }

  static void addWorkoutBlock(int dayIndex, WorkoutBlock block) {
    final updated = Map<int, List<WorkoutBlock>>.from(weekSchedule.value);
    updated[dayIndex] = [...(updated[dayIndex] ?? []), block];
    weekSchedule.value = updated;
    saveScheduleToFirestore();
  }

  static void removeWorkoutBlock(int dayIndex, String blockId) {
    final updated = Map<int, List<WorkoutBlock>>.from(weekSchedule.value);
    updated[dayIndex] =
        (updated[dayIndex] ?? []).where((b) => b.id != blockId).toList();
    weekSchedule.value = updated;
    saveScheduleToFirestore();
  }

  static void updateWorkoutBlock(int dayIndex, WorkoutBlock updatedBlock) {
    final updated = Map<int, List<WorkoutBlock>>.from(weekSchedule.value);
    updated[dayIndex] = (updated[dayIndex] ?? [])
        .map((b) => b.id == updatedBlock.id ? updatedBlock : b)
        .toList();
    weekSchedule.value = updated;
    saveScheduleToFirestore();
  }

  static void applyLevelToDay(int dayIndex, String level) {
    final current = weekSchedule.value;
    final updated = Map<int, List<WorkoutBlock>>.from(current);
    updated[dayIndex] = (updated[dayIndex] ?? [])
        .map((b) => b.copyWith(level: level))
        .toList();
    weekSchedule.value = updated;
    saveScheduleToFirestore();
  }

  static void applyLevelToAllBlocks(String level) {
    fitnessLevel.value = level;
    final current = weekSchedule.value;
    final updated = Map<int, List<WorkoutBlock>>.from(current);
    updated.forEach((dayIndex, blocks) {
      updated[dayIndex] = blocks.map((b) => b.copyWith(level: level)).toList();
    });
    weekSchedule.value = updated;
    saveScheduleToFirestore();
  }

  static Map<String, dynamic> scheduleToMap() {
    final schedule = weekSchedule.value;
    final map = <String, dynamic>{};
    schedule.forEach((dayIndex, blocks) {
      map['$dayIndex'] = blocks
          .map((b) => {'focus': b.focus, 'level': b.level, 'id': b.id})
          .toList();
    });
    return map;
  }

  static void scheduleFromMap(Map<String, dynamic> map) {
    final schedule = _emptyWeek();
    map.forEach((key, value) {
      final dayIndex = int.tryParse(key);
      if (dayIndex != null && value is List) {
        schedule[dayIndex] = value.map<WorkoutBlock>((item) {
          final m = item as Map<String, dynamic>;
          return WorkoutBlock(
            focus: m['focus'] as String? ?? 'Abs',
            level: m['level'] as String? ?? 'Beginner',
            id: m['id'] as String? ?? '${dayIndex}_default',
          );
        }).toList();
      }
    });
    weekSchedule.value = schedule;
  }

  static void saveScheduleToFirestore() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseService().updateUserProfile(user.uid, {
        'weekSchedule': scheduleToMap(),
      });
    }
  }

  static DateTime _startOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static void checkAndResetWeeklySchedule({
    required String? lastResetIso,
    required String globalLevel,
  }) {
    final now = DateTime.now();
    final currentWeekStart = _startOfWeek(now);

    DateTime? lastReset;
    if (lastResetIso != null) {
      lastReset = DateTime.tryParse(lastResetIso);
    }

    if (lastReset == null || lastReset.isBefore(currentWeekStart)) {
      final current = weekSchedule.value;
      final updated = Map<int, List<WorkoutBlock>>.from(current);
      updated.forEach((dayIndex, blocks) {
        updated[dayIndex] =
            blocks.map((b) => b.copyWith(level: globalLevel)).toList();
      });
      weekSchedule.value = updated;

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DatabaseService().updateUserProfile(user.uid, {
          'weekSchedule': scheduleToMap(),
          'scheduleLastReset': currentWeekStart.toIso8601String(),
        });
      }
    }
  }

  static int get totalCalories {
    return meals.value.fold(0, (sum, meal) => sum + meal.calories);
  }

  static Future<void> addMeal(String name, int calories,
      {int protein = 0, int carbs = 0, int fats = 0}) async {
    meals.value = [
      ...meals.value,
      Meal(name: name, calories: calories,
          protein: protein, carbs: carbs, fats: fats),
    ];

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await DatabaseService().logMeal({
        'userId': user.uid,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'loggedAt': DateTime.now(),
      });
      saveTodayCalorieSnapshot(user.uid);
    }
  }

  static void deleteMeal(int index) {
    final meal = meals.value[index];
    final updatedMeals = [...meals.value];
    updatedMeals.removeAt(index);
    meals.value = updatedMeals;

    if (meal.firestoreId != null) {
      DatabaseService().deleteMeal(meal.firestoreId!);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) saveTodayCalorieSnapshot(user.uid);
  }

  static double calculateBMI({
    required double weightLbs,
    required double heightInches,
  }) {
    return (weightLbs / (heightInches * heightInches)) * 703;
  }

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

    if (weightGoalRate != null) {
      for (final rate in kWeightLossRates) {
        if (rate['key'] == weightGoalRate) {
          return maintenance - (rate['deficit'] as int);
        }
      }
      for (final rate in kWeightGainRates) {
        if (rate['key'] == weightGoalRate) {
          return maintenance + (rate['surplus'] as int);
        }
      }
    }

    if (goal == 'Weight Loss') {
      return maintenance - 500;
    } else if (goal == 'Bulk') {
      return maintenance + 300;
    }

    return maintenance;
  }

  static final ValueNotifier<double?> todayWeight =
      ValueNotifier<double?>(null);

  static Future<void> logTodayWeight(String userId, double weightLbs) async {
    todayWeight.value = weightLbs;
    final dateKey = _dateKey(DateTime.now());
    await DatabaseService().saveDailySnapshot(userId, dateKey, {
      'weightLbs': weightLbs,
      'date': dateKey,
    });
  }

  static Future<void> loadTodayWeight(String userId) async {
    final dateKey = _dateKey(DateTime.now());
    final snap = await DatabaseService().getDailySnapshot(userId, dateKey);
    if (snap != null) {
      todayWeight.value = (snap['weightLbs'] as num?)?.toDouble();
    } else {
      todayWeight.value = null;
    }
  }

  static Future<void> saveTodayCalorieSnapshot(String userId) async {
    final dateKey = _dateKey(DateTime.now());
    await DatabaseService().saveDailySnapshot(userId, dateKey, {
      'calories': totalCalories,
      'date': dateKey,
    });
  }

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

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

    AppData.goal.value = goal;
    AppData.activityLevel.value = activityLevel;
    AppData.currentWeight.value = weightLbs;
    AppData.age.value = age;
    AppData.gender.value = gender;
    AppData.heightInches.value = heightInches;
    AppData.weightGoalRate.value = weightGoalRate;

    if (goal == 'Weight Loss') {
      AppData.targetWeight.value = weightLbs - 10;
    } else {
      AppData.targetWeight.value = weightLbs;
    }
  }
}