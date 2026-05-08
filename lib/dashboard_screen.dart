import 'package:flutter/material.dart';
import 'meal_tracking_screen.dart';
import 'fitness_plan_screen.dart';
import 'profile_screen.dart';
import 'app_data.dart';

class DashboardScreen extends StatelessWidget {
  final void Function(int)? onNavigate;
  const DashboardScreen({super.key, this.onNavigate});

  String _bmiCategory(double bmi) {
    if (bmi == 0) return 'Not calculated';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // 0 = Mon … 6 = Sun (matches weekSchedule keys)
  int get _todayIndex => DateTime.now().weekday - 1;

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const weekdays = [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
      'Saturday', 'Sunday'
    ];
    return '${weekdays[now.weekday]}, ${months[now.month - 1]} ${now.day}';
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
                return ValueListenableBuilder<WeekSchedule>(
                  valueListenable: AppData.weekSchedule,
                  builder: (context, schedule, child) {
                    final totalCalories = AppData.totalCalories;
                    final progress =
                        (totalCalories / calorieGoal).clamp(0.0, 1.0);
                    final todayIndex = _todayIndex;
                    final todayBlocks = schedule[todayIndex] ?? [];

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
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // date tracker
                              _DateTrackerCard(
                                dateString: _formattedDate(),
                                todayIndex: todayIndex,
                                schedule: schedule,
                              ),

                              const SizedBox(height: 20),

                              // today's workout preview
                              _TodayWorkoutCard(
                                todayIndex: todayIndex,
                                todayBlocks: todayBlocks,
                                onTap: () => onNavigate?.call(2),
                              ),

                              const SizedBox(height: 20),

                              // today's progress card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Today\'s Progress',
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
                                      borderRadius:
                                          BorderRadius.circular(12),
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

                              // calorie logger card
                              _dashboardCard(
                                icon: Icons.local_fire_department,
                                title: 'Calorie Logger',
                                subtitle: 'Log meals and track calories',
                                color: const Color(0xFFD85A30),
                                onTap: () => onNavigate?.call(1),
                              ),

                              // fitness plan card (enhanced)
                              _fitnessPlanCard(context, schedule),

                              // profile card
                              _dashboardCard(
                                icon: Icons.person,
                                title: 'Profile',
                                subtitle: 'View and update your profile',
                                color: const Color(0xFF378ADD),
                                onTap: () => onNavigate?.call(3),
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
      },
    );
  }

  // enhanced fitness plan card
  Widget _fitnessPlanCard(BuildContext context, WeekSchedule schedule) {
    return GestureDetector(
      onTap: () => onNavigate?.call(2),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // square icon container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Color(0xFF378ADD),
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + badge row
                  Row(
                    children: [
                      const Text(
                        'Fitness Plan',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '7-day plan',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF185FA5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Custom weekly schedule',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 10),

                  // live day chips reflecting the user's schedule
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List.generate(7, (i) {
                      final blocks = schedule[i] ?? [];
                      final hasWorkout = blocks.isNotEmpty;
                      final color = hasWorkout
                          ? focusColor(blocks.first.focus)
                          : Colors.grey.shade300;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          kDayShort[i],
                          style: TextStyle(
                            fontSize: 11,
                            color: hasWorkout ? color : Colors.grey,
                            fontWeight: hasWorkout
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
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

// ─── Date Tracker Card ─────────────────────────────────────────────────────────

class _DateTrackerCard extends StatelessWidget {
  final String dateString;
  final int todayIndex;
  final WeekSchedule schedule;

  const _DateTrackerCard({
    required this.dateString,
    required this.todayIndex,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    final todayBlocks = schedule[todayIndex] ?? [];
    final hasWorkout = todayBlocks.isNotEmpty;
    final isWeekend = todayIndex == 5 || todayIndex == 6;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateString,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasWorkout
                      ? '${todayBlocks.length} workout${todayBlocks.length > 1 ? 's' : ''} today 💪'
                      : isWeekend
                          ? 'Rest day — enjoy it!'
                          : 'No workout scheduled today',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasWorkout
                        ? const Color(0xFF378ADD)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Mon–Sun dot indicators
          Row(
            children: List.generate(7, (i) {
              final isToday = todayIndex == i;
              final blocks = schedule[i] ?? [];
              final hasW = blocks.isNotEmpty;
              final dotColor = hasW
                  ? focusColor(blocks.first.focus)
                  : Colors.grey.shade300;

              return Container(
                margin: const EdgeInsets.only(left: 5),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isToday ? dotColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isToday
                        ? dotColor
                        : hasW
                            ? dotColor.withValues(alpha: 0.5)
                            : Colors.grey.shade300,
                    width: isToday ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    kDayShort[i].substring(0, 1),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? Colors.white
                          : hasW
                              ? dotColor
                              : Colors.grey,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Today's Workout Preview Card ─────────────────────────────────────────────

class _TodayWorkoutCard extends StatelessWidget {
  final int todayIndex;
  final List<WorkoutBlock> todayBlocks;
  final VoidCallback onTap;

  const _TodayWorkoutCard({
    required this.todayIndex,
    required this.todayBlocks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekend = todayIndex == 5 || todayIndex == 6;

    // rest day — no workouts scheduled
    if (todayBlocks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              isWeekend ? Icons.weekend : Icons.add_circle_outline,
              color: Colors.grey.shade400,
              size: 32,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWeekend ? 'Rest & Recover' : 'No workout today',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isWeekend
                      ? 'Recharge for next week.'
                      : 'Open Fitness Plan to add one.',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // active workout day — show block summary + tap to open plan
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: focusColor(todayBlocks.first.focus)
              .withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: focusColor(todayBlocks.first.focus)
                .withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Workout",
                        style: TextStyle(
                          fontSize: 11,
                          color: focusColor(todayBlocks.first.focus),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        todayBlocks.length == 1
                            ? '${todayBlocks.first.focus} · ${todayBlocks.first.level}'
                            : '${todayBlocks.length} workouts planned',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ],
            ),

            const SizedBox(height: 12),

            // workout block chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: todayBlocks.map((block) {
                final c = focusColor(block.focus);
                final exercises = WorkoutLibrary.getExercises(
                    block.focus, block.level);
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: c.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(focusIcon(block.focus), color: c, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        block.focus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '· ${exercises.length} ex',
                        style: TextStyle(
                          fontSize: 11,
                          color: c.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
