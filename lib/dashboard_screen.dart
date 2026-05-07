import 'package:flutter/material.dart';
import 'meal_tracking_screen.dart';
import 'app_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _bmiCategory(double bmi) {
    if (bmi == 0) return 'Not calculated';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppData.calorieGoal,
      builder: (context, calorieGoal, child) {
        return ValueListenableBuilder<double>(
          valueListenable: AppData.bmi,
          builder: (context, bmi, child) {
            return ValueListenableBuilder<List<Meal>>(
              valueListenable: AppData.meals,
              builder: (context, meals, child) {
                final totalCalories = AppData.totalCalories;
                final progress =
                    (totalCalories / calorieGoal).clamp(0.0, 1.0);

                return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    title: const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Track your fitness journey',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Today’s Progress',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                Text(
                                  'Calories: $totalCalories / $calorieGoal',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF378ADD),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 12,
                                  borderRadius: BorderRadius.circular(12),
                                  backgroundColor: Colors.white,
                                  color: const Color(0xFFD85A30),
                                ),

                                const SizedBox(height: 16),

                                Text(
                                  'BMI: ${bmi.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFD85A30),
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  'Category: ${_bmiCategory(bmi)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 18),

                          _dashboardCard(
                            icon: Icons.local_fire_department,
                            title: 'Calorie Logger',
                            subtitle: 'Log meals and track calories',
                            color: const Color(0xFFD85A30),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const MealTrackingScreen(),
                                ),
                              );
                            },
                          ),

                          _dashboardCard(
                            icon: Icons.fitness_center,
                            title: 'Fitness Plan',
                            subtitle: 'View workouts and exercise plans',
                            color: const Color(0xFF378ADD),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Fitness Plan page coming soon',
                                  ),
                                ),
                              );
                            },
                          ),

                          _dashboardCard(
                            icon: Icons.person,
                            title: 'Profile',
                            subtitle: 'View and update your profile',
                            color: const Color(0xFF378ADD),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Profile page coming soon',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
