import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_data.dart';
import 'login_screen.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _newWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  @override
  void dispose() {
    _newWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  // ── Weight update ─────────────────────────────────────────────────────────

  void _updateWeight(double newWeight) {
    AppData.currentWeight.value = newWeight;
    AppData.bmi.value = AppData.calculateBMI(
      weightLbs: newWeight,
      heightInches: AppData.heightInches.value,
    );
    AppData.calorieGoal.value = AppData.calculateCalorieGoal(
      age: AppData.age.value,
      weightLbs: newWeight,
      heightInches: AppData.heightInches.value,
      gender: AppData.gender.value,
      activityLevel: AppData.activityLevel.value,
      goal: AppData.goal.value,
      weightGoalRate: AppData.weightGoalRate.value,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseService().updateUserProfile(user.uid, {
        'weightLbs': newWeight,
        'bmi': AppData.bmi.value,
        'calorieGoal': AppData.calorieGoal.value,
      });

      // ✅ sync today's weight log
      AppData.todayWeight.value = newWeight;
      AppData.logTodayWeight(user.uid, newWeight);
    }
  }

  void _recalculateHealthData() {
    AppData.bmi.value = AppData.calculateBMI(
      weightLbs: AppData.currentWeight.value,
      heightInches: AppData.heightInches.value,
    );
    AppData.calorieGoal.value = AppData.calculateCalorieGoal(
      age: AppData.age.value,
      weightLbs: AppData.currentWeight.value,
      heightInches: AppData.heightInches.value,
      gender: AppData.gender.value,
      activityLevel: AppData.activityLevel.value,
      goal: AppData.goal.value,
      weightGoalRate: AppData.weightGoalRate.value,
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showUpdateWeightDialog() {
    _newWeightController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Weight',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current: ${AppData.currentWeight.value.toStringAsFixed(1)} lbs',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'New weight (lbs)',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  const BorderSide(color: Color(0xFF378ADD), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newWeight =
              double.tryParse(_newWeightController.text.trim());
              if (newWeight == null || newWeight < 50 || newWeight > 700) {
                return;
              }
              _updateWeight(newWeight);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                  Text('Weight updated! Calorie goal recalculated.'),
                  backgroundColor: Color(0xFF378ADD),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF378ADD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showUpdateTargetWeightDialog() {
    _targetWeightController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Target Weight',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current target: ${AppData.targetWeight.value.toStringAsFixed(1)} lbs',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Target weight (lbs)',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                  const BorderSide(color: Color(0xFF378ADD), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final target =
              double.tryParse(_targetWeightController.text.trim());
              if (target == null || target < 50 || target > 700) return;
              setState(() => AppData.targetWeight.value = target);
              Navigator.pop(context);
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                DatabaseService().updateUserProfile(
                    user.uid, {'targetWeight': target});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF378ADD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog({
    required String title,
    required String currentValue,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Fitness level — updates ALL days ─────────────────────────────────────

  void _showFitnessLevelDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ProfileLevelPickerSheet(
        current: AppData.fitnessLevel.value,
        onPicked: (level) {
          Navigator.pop(context);
          setState(() {
            AppData.applyLevelToAllBlocks(level);
          });
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            DatabaseService()
                .updateUserProfile(user.uid, {'fitnessLevel': level});
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Text('Fitness level updated to $level for all days.'),
              backgroundColor: const Color(0xFF378ADD),
            ),
          );
        },
      ),
    );
  }

  // ── Height picker ─────────────────────────────────────────────────────────

  void _showHeightPickerDialog() {
    final totalInches = AppData.heightInches.value;
    int tempFeet = totalInches == 0 ? 5 : (totalInches ~/ 12);
    int tempInches = totalInches == 0 ? 8 : (totalInches % 12).toInt();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 320,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('Select Height',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // feet wheel
                    Column(
                      children: [
                        const Text('ft',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          height: 150,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD85A30)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFD85A30),
                                      width: 1.5),
                                ),
                              ),
                              ListWheelScrollView.useDelegate(
                                itemExtent: 40,
                                perspective: 0.005,
                                diameterRatio: 1.5,
                                physics: const FixedExtentScrollPhysics(),
                                controller: FixedExtentScrollController(
                                    initialItem: tempFeet - 3),
                                onSelectedItemChanged: (index) {
                                  tempFeet = index + 3;
                                },
                                childDelegate:
                                ListWheelChildBuilderDelegate(
                                  childCount: 6,
                                  builder: (context, index) => Center(
                                    child: Text('${index + 3}\'',
                                        style: const TextStyle(
                                            fontSize: 22)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    // inches wheel
                    Column(
                      children: [
                        const Text('in',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 80,
                          height: 150,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD85A30)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFD85A30),
                                      width: 1.5),
                                ),
                              ),
                              ListWheelScrollView.useDelegate(
                                itemExtent: 40,
                                perspective: 0.005,
                                diameterRatio: 1.5,
                                physics: const FixedExtentScrollPhysics(),
                                controller: FixedExtentScrollController(
                                    initialItem: tempInches),
                                onSelectedItemChanged: (index) {
                                  tempInches = index;
                                },
                                childDelegate:
                                ListWheelChildBuilderDelegate(
                                  childCount: 12,
                                  builder: (context, index) => Center(
                                    child: Text('$index"',
                                        style: const TextStyle(
                                            fontSize: 22)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newHeight =
                    (tempFeet * 12 + tempInches).toDouble();
                    setState(() {
                      AppData.heightInches.value = newHeight;
                      _recalculateHealthData();
                    });
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      DatabaseService().updateUserProfile(user.uid, {
                        'heightInches': newHeight,
                        'bmi': AppData.bmi.value,
                        'calorieGoal': AppData.calorieGoal.value,
                      });
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF378ADD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Weight goal rate picker ───────────────────────────────────────────────

  void _showWeightGoalRateDialog() {
    final isLoss = AppData.goal.value == 'Weight Loss';
    final rates = isLoss ? kWeightLossRates : kWeightGainRates;
    String? selectedRate = AppData.weightGoalRate.value;

    final maintenance = AppData.calculateMaintenance(
      age: AppData.age.value,
      weightLbs: AppData.currentWeight.value,
      heightInches: AppData.heightInches.value,
      gender: AppData.gender.value,
      activityLevel: AppData.activityLevel.value,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoss ? 'Weight loss rate' : 'Bulk rate',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Maintain: $maintenance cal/day',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 16),
                ...rates.map((rate) {
                  final key = rate['key'] as String;
                  final isCurrent = selectedRate == key;
                  final isRecommended = rate['recommended'] as bool;
                  final adjustment =
                  (rate['deficit'] ?? rate['surplus']) as int;
                  final targetCals = isLoss
                      ? maintenance - adjustment
                      : maintenance + adjustment;
                  final color = isRecommended
                      ? const Color(0xFF378ADD)
                      : const Color(0xFFD85A30);

                  return GestureDetector(
                    onTap: () =>
                        setSheetState(() => selectedRate = key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? color.withValues(alpha: 0.08)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                          isCurrent ? color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(rate['label'] as String,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isCurrent
                                                ? color
                                                : Colors.black87)),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isRecommended
                                            ? const Color(0xFF2E7D32)
                                            .withValues(alpha: 0.12)
                                            : const Color(0xFFD85A30)
                                            .withValues(alpha: 0.10),
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isRecommended
                                            ? '✓ Recommended'
                                            : '⚠ Hard to maintain',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: isRecommended
                                              ? const Color(0xFF2E7D32)
                                              : const Color(0xFFD85A30),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(rate['subtitle'] as String,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: [
                              Text('$targetCals',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isCurrent
                                          ? color
                                          : Colors.black87)),
                              const Text('cal/day',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey)),
                            ],
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.check_circle,
                                color: color, size: 20),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        AppData.weightGoalRate.value = selectedRate;
                        _recalculateHealthData();
                      });
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        DatabaseService()
                            .updateUserProfile(user.uid, {
                          'weightGoalRate': selectedRate,
                          'calorieGoal': AppData.calorieGoal.value,
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378ADD),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _bmiCategory(double bmi) {
    if (bmi == 0) return 'Not calculated';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _bmiColor(double bmi) {
    if (bmi == 0) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return const Color(0xFFD85A30);
  }

  // ✅ REMOVED unused _weightProgress method

  Widget _statCard({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(unit,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF378ADD), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right,
              color: Colors.grey, size: 18),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return ValueListenableBuilder<String?>(
      valueListenable: AppData.weightGoalRate,
      builder: (context, weightGoalRate, _) {
        return ValueListenableBuilder<double>(
          valueListenable: AppData.currentWeight,
          builder: (context, currentWeight, _) {
            return ValueListenableBuilder<double>(
              valueListenable: AppData.bmi,
              builder: (context, bmi, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: AppData.goal,
                  builder: (context, goal, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: AppData.calorieGoal,
                      builder: (context, calorieGoal, _) {
                        return ValueListenableBuilder<String?>(
                          valueListenable: AppData.fitnessLevel,
                          builder: (context, fitnessLevel, _) {
                            return Scaffold(
                              backgroundColor: Colors.white,
                              appBar: AppBar(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                title: const Text(
                                  'Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 28,
                                  ),
                                ),
                                actions: [
                                  IconButton(
                                    icon: const Icon(Icons.logout,
                                        color: Color(0xFFD85A30)),
                                    onPressed: () async {
                                      await AuthService().logout();
                                      if (!context.mounted) return;
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                            const LoginScreen()),
                                            (route) => false,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              body: SafeArea(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [

                                      // profile header
                                      Container(
                                        width: double.infinity,
                                        padding:
                                        const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color:
                                          const Color(0xFFE3F2FD),
                                          borderRadius:
                                          BorderRadius.circular(18),
                                        ),
                                        child: Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 36,
                                              backgroundColor:
                                              Colors.white,
                                              child: Icon(Icons.person,
                                                  size: 40,
                                                  color: Color(
                                                      0xFF378ADD)),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(
                                                    AppData.userName.value.isNotEmpty
                                                        ? AppData.userName.value
                                                        : user?.email ?? 'User',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize: 16),
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                  ),
                                                  if (AppData.userName.value.isNotEmpty) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      user?.email ?? '',
                                                      style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                  const SizedBox(
                                                      height: 4),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    decoration:
                                                    BoxDecoration(
                                                      color: const Color(
                                                          0xFF378ADD),
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          20),
                                                    ),
                                                    child: Text(
                                                      goal.isEmpty
                                                          ? 'No goal set'
                                                          : goal,
                                                      style: const TextStyle(
                                                          color:
                                                          Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                          FontWeight
                                                              .w600),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // stats row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _statCard(
                                              label: 'Calorie Goal',
                                              value: '$calorieGoal',
                                              unit: 'cal/day',
                                              color: const Color(
                                                  0xFFD85A30),
                                              icon: Icons
                                                  .local_fire_department,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _statCard(
                                              label: 'BMI',
                                              value: bmi == 0
                                                  ? '--'
                                                  : bmi.toStringAsFixed(
                                                  1),
                                              unit: _bmiCategory(bmi),
                                              color: _bmiColor(bmi),
                                              icon: Icons
                                                  .monitor_weight_outlined,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 24),

                                      // weight tracking header
                                      const Text('Weight Tracking',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),

                                      const SizedBox(height: 12),

                                      // weight card
                                      Container(
                                        width: double.infinity,
                                        padding:
                                        const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color:
                                          const Color(0xFFF5F5F5),
                                          borderRadius:
                                          BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceAround,
                                              children: [
                                                // current weight
                                                GestureDetector(
                                                  onTap: _showUpdateWeightDialog,
                                                  child: Column(
                                                    children: [
                                                      const Text('Current',
                                                          style: TextStyle(
                                                              color: Colors.grey,
                                                              fontSize: 13)),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            '${currentWeight.toStringAsFixed(1)} lbs',
                                                            style: const TextStyle(
                                                                fontSize: 22,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color(0xFF378ADD)),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          const Icon(Icons.edit,
                                                              size: 14,
                                                              color: Colors.grey),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Icon(Icons.arrow_forward,
                                                    color: Colors.grey),
                                                // target weight
                                                GestureDetector(
                                                  onTap: _showUpdateTargetWeightDialog,
                                                  child: Column(
                                                    children: [
                                                      const Text('Target',
                                                          style: TextStyle(
                                                              color: Colors.grey,
                                                              fontSize: 13)),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            '${AppData.targetWeight.value.toStringAsFixed(1)} lbs',
                                                            style: const TextStyle(
                                                                fontSize: 22,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color(0xFFD85A30)),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          const Icon(Icons.edit,
                                                              size: 14,
                                                              color: Colors.grey),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              currentWeight <= AppData.targetWeight.value
                                                  ? '🎉 Goal reached!'
                                                  : '${(currentWeight - AppData.targetWeight.value).toStringAsFixed(1)} lbs to go',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // My Details
                                      const Text('My Details',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                              FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Tap any field to edit',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13),
                                      ),
                                      const SizedBox(height: 12),

                                      // Age
                                      GestureDetector(
                                        onTap: () => _showEditDialog(
                                          title: 'Edit Age',
                                          currentValue: AppData
                                              .age.value
                                              .toString(),
                                          onSave: (value) {
                                            final age =
                                            int.tryParse(value);
                                            if (age != null) {
                                              setState(() {
                                                AppData.age.value = age;
                                                _recalculateHealthData();
                                              });
                                              final u = FirebaseAuth
                                                  .instance.currentUser;
                                              if (u != null) {
                                                DatabaseService()
                                                    .updateUserProfile(
                                                    u.uid,
                                                    {'age': age});
                                              }
                                            }
                                          },
                                        ),
                                        child: _detailRow(
                                            Icons.cake_outlined,
                                            'Age',
                                            '${AppData.age.value} years'),
                                      ),

                                      // Height
                                      GestureDetector(
                                        onTap: _showHeightPickerDialog,
                                        child: _detailRow(
                                          Icons.height,
                                          'Height',
                                          AppData.heightInches.value == 0
                                              ? '--'
                                              : '${(AppData.heightInches.value ~/ 12)}\'${(AppData.heightInches.value % 12).toInt()}"',
                                        ),
                                      ),

                                      // Gender - ✅ FIXED: Using initialValue
                                      GestureDetector(
                                        onTap: () {
                                          String selectedGender =
                                              AppData.gender.value;
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                shape:
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        16)),
                                                title: const Text(
                                                    'Select Gender'),
                                                content:
                                                DropdownButtonFormField<
                                                    String>(
                                                  initialValue: selectedGender
                                                      .isEmpty
                                                      ? null
                                                      : selectedGender,
                                                  items: const [
                                                    DropdownMenuItem(
                                                        value: 'Male',
                                                        child:
                                                        Text('Male')),
                                                    DropdownMenuItem(
                                                        value: 'Female',
                                                        child:
                                                        Text('Female')),
                                                    DropdownMenuItem(
                                                        value: 'Other',
                                                        child:
                                                        Text('Other')),
                                                  ],
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      selectedGender = value;
                                                    }
                                                  },
                                                  decoration:
                                                  InputDecoration(
                                                    filled: true,
                                                    fillColor: const Color(
                                                        0xFFF5F5F5),
                                                    border:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(10),
                                                      borderSide:
                                                      BorderSide.none,
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: const Text(
                                                          'Cancel')),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        AppData.gender
                                                            .value =
                                                            selectedGender;
                                                        _recalculateHealthData();
                                                      });
                                                      final u = FirebaseAuth
                                                          .instance
                                                          .currentUser;
                                                      if (u != null) {
                                                        DatabaseService()
                                                            .updateUserProfile(
                                                            u.uid, {
                                                          'gender':
                                                          selectedGender
                                                        });
                                                      }
                                                      Navigator.pop(
                                                          context);
                                                    },
                                                    child: const Text(
                                                        'Save'),
                                                  ),
                                                ],
                                              ),
                                          );
                                        },
                                        child: _detailRow(
                                            Icons.person_outline,
                                            'Gender',
                                            AppData.gender.value.isEmpty
                                                ? '--'
                                                : AppData.gender.value),
                                      ),

                                      // Activity Level - ✅ FIXED: Using initialValue
                                      GestureDetector(
                                        onTap: () {
                                          String selectedActivity =
                                              AppData.activityLevel.value;
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                shape:
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        16)),
                                                title: const Text(
                                                    'Activity Level'),
                                                content:
                                                DropdownButtonFormField<
                                                    String>(
                                                  initialValue: selectedActivity
                                                      .isEmpty
                                                      ? null
                                                      : selectedActivity,
                                                  items: const [
                                                    DropdownMenuItem(
                                                        value: 'Sedentary',
                                                        child: Text(
                                                            'Sedentary')),
                                                    DropdownMenuItem(
                                                        value:
                                                        'Lightly Active',
                                                        child: Text(
                                                            'Lightly Active')),
                                                    DropdownMenuItem(
                                                        value:
                                                        'Moderately Active',
                                                        child: Text(
                                                            'Moderately Active')),
                                                    DropdownMenuItem(
                                                        value: 'Very Active',
                                                        child: Text(
                                                            'Very Active')),
                                                  ],
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      selectedActivity = value;
                                                    }
                                                  },
                                                  decoration:
                                                  InputDecoration(
                                                    filled: true,
                                                    fillColor: const Color(
                                                        0xFFF5F5F5),
                                                    border:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(10),
                                                      borderSide:
                                                      BorderSide.none,
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: const Text(
                                                          'Cancel')),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        AppData.activityLevel
                                                            .value =
                                                            selectedActivity;
                                                        _recalculateHealthData();
                                                      });
                                                      final u = FirebaseAuth
                                                          .instance
                                                          .currentUser;
                                                      if (u != null) {
                                                        DatabaseService()
                                                            .updateUserProfile(
                                                            u.uid, {
                                                          'activityLevel':
                                                          selectedActivity
                                                        });
                                                      }
                                                      Navigator.pop(
                                                          context);
                                                    },
                                                    child: const Text(
                                                        'Save'),
                                                  ),
                                                ],
                                              ),
                                          );
                                        },
                                        child: _detailRow(
                                            Icons.directions_run,
                                            'Activity Level',
                                            AppData.activityLevel.value
                                                .isEmpty
                                                ? '--'
                                                : AppData
                                                .activityLevel.value),
                                      ),

                                      // Fitness Level
                                      GestureDetector(
                                        onTap: _showFitnessLevelDialog,
                                        child: _detailRow(
                                            Icons.fitness_center,
                                            'Fitness Level',
                                            fitnessLevel ?? '--'),
                                      ),

                                      // Weight goal rate
                                      if (goal == 'Weight Loss' ||
                                          goal == 'Bulk')
                                        GestureDetector(
                                          onTap:
                                          _showWeightGoalRateDialog,
                                          child: _detailRow(
                                              Icons.trending_down,
                                              goal == 'Weight Loss'
                                                  ? 'Loss Rate'
                                                  : 'Bulk Rate',
                                              weightGoalRate ?? '--'),
                                        ),

                                      // Fitness Goal - ✅ FIXED: Using initialValue
                                      GestureDetector(
                                        onTap: () {
                                          String selectedGoal =
                                          AppData.goal.value ==
                                              'Muscle Gain'
                                              ? 'Bulk'
                                              : AppData.goal.value;
                                          const validGoals = [
                                            'Weight Loss',
                                            'Maintain Weight',
                                            'Bulk'
                                          ];
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                shape:
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        16)),
                                                title: const Text(
                                                    'Fitness Goal'),
                                                content:
                                                DropdownButtonFormField<
                                                    String>(
                                                  initialValue: selectedGoal
                                                      .isEmpty ||
                                                      !validGoals
                                                          .contains(
                                                          selectedGoal)
                                                      ? null
                                                      : selectedGoal,
                                                  items: const [
                                                    DropdownMenuItem(
                                                        value: 'Weight Loss',
                                                        child: Text(
                                                            'Weight Loss')),
                                                    DropdownMenuItem(
                                                        value:
                                                        'Maintain Weight',
                                                        child: Text(
                                                            'Maintain Weight')),
                                                    DropdownMenuItem(
                                                        value: 'Bulk',
                                                        child: Text('Bulk')),
                                                  ],
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      selectedGoal = value;
                                                    }
                                                  },
                                                  decoration:
                                                  InputDecoration(
                                                    filled: true,
                                                    fillColor: const Color(
                                                        0xFFF5F5F5),
                                                    border:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(10),
                                                      borderSide:
                                                      BorderSide.none,
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: const Text(
                                                          'Cancel')),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        AppData.goal.value =
                                                            selectedGoal;
                                                        if (selectedGoal ==
                                                            'Weight Loss' ||
                                                            selectedGoal ==
                                                                'Bulk') {
                                                          AppData.weightGoalRate
                                                              .value = null;
                                                        }
                                                        _recalculateHealthData();
                                                      });
                                                      final u = FirebaseAuth
                                                          .instance
                                                          .currentUser;
                                                      if (u != null) {
                                                        DatabaseService()
                                                            .updateUserProfile(
                                                            u.uid, {
                                                          'goal':
                                                          selectedGoal,
                                                          'weightGoalRate':
                                                          null,
                                                        });
                                                      }
                                                      Navigator.pop(
                                                          context);
                                                      if (selectedGoal ==
                                                          'Weight Loss' ||
                                                          selectedGoal ==
                                                              'Bulk') {
                                                        Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                              300),
                                                          _showWeightGoalRateDialog,
                                                        );
                                                      }
                                                    },
                                                    child: const Text(
                                                        'Save'),
                                                  ),
                                                ],
                                              ),
                                          );
                                        },
                                        child: _detailRow(
                                            Icons.flag_outlined,
                                            'Fitness Goal',
                                            AppData.goal.value.isEmpty
                                                ? '--'
                                                : AppData.goal.value),
                                      ),

                                      const SizedBox(height: 32),
                                    ],
                                  ),
                                ),
                              ),
                            ); // Scaffold
                          },
                        ); // fitnessLevel builder
                      },
                    ); // calorieGoal builder
                  },
                ); // goal builder
              },
            ); // bmi builder
          },
        ); // currentWeight builder
      },
    ); // weightGoalRate builder
  }
}

// ─── Level picker sheet ──────────────────────────────────────────────────────

class _ProfileLevelPickerSheet extends StatelessWidget {
  final String? current;
  final ValueChanged<String> onPicked;

  const _ProfileLevelPickerSheet({
    required this.current,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final levels = [
      {
        'label': 'Beginner',
        'icon': Icons.star_outline,
        'color': const Color(0xFF2E7D32),
      },
      {
        'label': 'Intermediate',
        'icon': Icons.star_half,
        'color': const Color(0xFF378ADD),
      },
      {
        'label': 'Advanced',
        'icon': Icons.star,
        'color': const Color(0xFFD85A30),
      },
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fitness Level',
              style:
              TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text(
            'Updates all workouts across every day in your plan.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ...levels.map((l) {
            final isCurrent = current == l['label'];
            final c = l['color'] as Color;
            return GestureDetector(
              onTap: () => onPicked(l['label'] as String),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? c.withValues(alpha: 0.08)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent ? c : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(l['icon'] as IconData, color: c, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      l['label'] as String,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isCurrent ? c : Colors.black87),
                    ),
                    const Spacer(),
                    if (isCurrent)
                      Icon(Icons.check_circle, color: c, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}