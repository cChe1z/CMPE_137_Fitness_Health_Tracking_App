import 'package:flutter/material.dart';
import 'app_data.dart';

class MealTrackingScreen extends StatefulWidget {
  const MealTrackingScreen({super.key});

  @override
  State<MealTrackingScreen> createState() => _MealTrackingScreenState();
}

class _MealTrackingScreenState extends State<MealTrackingScreen> {
  final _mealController = TextEditingController();
  final _calorieController = TextEditingController();

  void _addMeal() {
    final name = _mealController.text.trim();
    final calories = int.tryParse(_calorieController.text.trim());

    if (name.isEmpty || calories == null) return;

    AppData.addMeal(name, calories);

    _mealController.clear();
    _calorieController.clear();
  }

  @override
  void dispose() {
    _mealController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Meal>>(
      valueListenable: AppData.meals,
      builder: (context, meals, child) {
        final totalCalories = AppData.totalCalories;
        final calorieGoal = AppData.calorieGoal.value;
        final progress = (totalCalories / calorieGoal).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Meal Tracker',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today’s Calories',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Track your meals and daily calorie goal',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$totalCalories / $calorieGoal',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF378ADD),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'calories consumed',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor: Colors.white,
                          color: const Color(0xFFD85A30),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Add Meal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _mealController,
                    hint: 'Meal name',
                  ),

                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _calorieController,
                    hint: 'Calories',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addMeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF378ADD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add Meal',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Meals Today',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 12),

                  if (meals.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'No meals added yet.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...List.generate(
                      meals.length,
                      (index) => _buildMealCard(meals[index], index),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealCard(Meal meal, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(Icons.restaurant, color: Color(0xFF378ADD)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              meal.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${meal.calories} cal',
            style: const TextStyle(
              color: Color(0xFFD85A30),
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              AppData.deleteMeal(index);
            },
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFD85A30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF378ADD),
            width: 2,
          ),
        ),
      ),
    );
  }
}
