import 'package:flutter/material.dart';

class Meal {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;

  Meal({
    required this.name,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
  });
}

class AppData {
  static final ValueNotifier<List<Meal>> meals = ValueNotifier<List<Meal>>([]);

  static final ValueNotifier<int> calorieGoal = ValueNotifier<int>(2200);
  static final ValueNotifier<double> bmi = ValueNotifier<double>(0);

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
  }

  static void deleteMeal(int index) {
    final updatedMeals = [...meals.value];
    updatedMeals.removeAt(index);
    meals.value = updatedMeals;
  }

  static double calculateBMI({
    required double weightLbs,
    required double heightInches,
  }) {
    return (weightLbs / (heightInches * heightInches)) * 703;
  }

  static int calculateCalorieGoal({
    required int age,
    required double weightLbs,
    required double heightInches,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    final weightKg = weightLbs * 0.453592;
    final heightCm = heightInches * 2.54;

    double bmr;

    if (gender == 'Male') {
    bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
}   else if (gender == 'Female') {
    bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
}   else {
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

    double calories = bmr * activityMultiplier;

    if (goal == 'Weight Loss') {
      calories -= 500;
    } else if (goal == 'Muscle Gain') {
      calories += 300;
    }

    return calories.round();
  }

  static void saveProfileData({
    required int age,
    required double weightLbs,
    required double heightInches,
    required String gender,
    required String activityLevel,
    required String goal,
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
    );
  }
}
