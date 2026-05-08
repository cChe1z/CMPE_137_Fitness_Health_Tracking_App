import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/database_service.dart';
import 'app_data.dart';
import 'main_navigation.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  int _selectedFeet = 5;
  int _selectedInches = 8;
  bool _heightSelected = false;

  String? _selectedGender;
  String? _selectedActivityLevel;
  String? _selectedGoal;
  String? _selectedWeightGoalRate;
  String? _selectedFitnessLevel;

  // errors
  String? _nameError;
  String? _ageError;
  String? _weightError;
  String? _heightError;
  String? _genderError;
  String? _activityError;
  String? _goalError;
  String? _weightGoalRateError;
  String? _fitnessLevelError;

  final List<String> _genders = ['Male', 'Female', 'Prefer not to say'];
  final List<String> _activityLevels = [
    'No Activity',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
  ];
  final List<String> _goals = [
    'Weight Loss',
    'Bulk',
    'Maintenance',
  ];

  static const List<Map<String, dynamic>> _fitnessLevels = [
    {
      'label': 'Beginner',
      'description': 'New to working out or getting back into it.',
      'icon': Icons.star_outline,
      'color': Color(0xFF2E7D32),
    },
    {
      'label': 'Intermediate',
      'description': 'Consistent training for a few months or more.',
      'icon': Icons.star_half,
      'color': Color(0xFF378ADD),
    },
    {
      'label': 'Advanced',
      'description': 'Over a year of structured training.',
      'icon': Icons.star,
      'color': Color(0xFFD85A30),
    },
  ];

  bool get _goalNeedsRate =>
      _selectedGoal == 'Weight Loss' || _selectedGoal == 'Bulk';

  List<Map<String, dynamic>> get _rateOptions =>
      _selectedGoal == 'Weight Loss' ? kWeightLossRates : kWeightGainRates;

  int? get _maintenanceCalories {
    final age = int.tryParse(_ageController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    if (age == null || weight == null || !_heightSelected ||
        _selectedGender == null || _selectedActivityLevel == null) {
      return null;
    }
    return AppData.calculateMaintenance(
      age: age,
      weightLbs: weight,
      heightInches: (_selectedFeet * 12 + _selectedInches).toDouble(),
      gender: _selectedGender!,
      activityLevel: _selectedActivityLevel!,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _continue() async {
    setState(() {
      _nameError = null;
      _ageError = null;
      _weightError = null;
      _heightError = null;
      _genderError = null;
      _activityError = null;
      _goalError = null;
      _weightGoalRateError = null;
      _fitnessLevelError = null;
    });

    bool hasError = false;

    // name validation
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      hasError = true;
    }

    // age validation
    final age = int.tryParse(_ageController.text.trim());
    if (_ageController.text.isEmpty) {
      setState(() => _ageError = 'Age is required');
      hasError = true;
    } else if (age == null || age < 13 || age > 100) {
      setState(() => _ageError = 'Please enter a valid age (13-100)');
      hasError = true;
    }

    // weight validation
    final weight = double.tryParse(_weightController.text.trim());
    if (_weightController.text.isEmpty) {
      setState(() => _weightError = 'Weight is required');
      hasError = true;
    } else if (weight == null || weight < 50 || weight > 700) {
      setState(() => _weightError = 'Please enter a valid weight in lbs');
      hasError = true;
    }

    if (!_heightSelected) {
      setState(() => _heightError = 'Please select your height');
      hasError = true;
    }

    if (_selectedGender == null) {
      setState(() => _genderError = 'Please select a gender');
      hasError = true;
    }

    if (_selectedActivityLevel == null) {
      setState(() => _activityError = 'Please select an activity level');
      hasError = true;
    }

    if (_selectedGoal == null) {
      setState(() => _goalError = 'Please select a fitness goal');
      hasError = true;
    }

    if (_goalNeedsRate && _selectedWeightGoalRate == null) {
      setState(() => _weightGoalRateError = 'Please select a rate');
      hasError = true;
    }

    if (_selectedFitnessLevel == null) {
      setState(() => _fitnessLevelError = 'Please select your fitness level');
      hasError = true;
    }

    if (hasError) return;

    final heightInches = (_selectedFeet * 12 + _selectedInches).toDouble();

    // save name to AppData
    AppData.userName.value = name;

    AppData.saveProfileData(
      age: age!,
      weightLbs: weight!,
      heightInches: heightInches,
      gender: _selectedGender!,
      activityLevel: _selectedActivityLevel!,
      goal: _selectedGoal!,
      weightGoalRate: _goalNeedsRate ? _selectedWeightGoalRate : null,
    );

    AppData.fitnessLevel.value = _selectedFitnessLevel;
    AppData.initDefaultSchedule(_selectedFitnessLevel!);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await DatabaseService().saveUserProfile(user.uid, {
        'name': name,
        'age': age,
        'weightLbs': weight,
        'heightInches': heightInches,
        'gender': _selectedGender,
        'activityLevel': _selectedActivityLevel,
        'goal': _selectedGoal,
        'weightGoalRate': _goalNeedsRate ? _selectedWeightGoalRate : null,
        'fitnessLevel': _selectedFitnessLevel,
        'calorieGoal': AppData.calorieGoal.value,
        'bmi': AppData.bmi.value,
        'targetWeight': AppData.targetWeight.value,
      });
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // header
              const Text(
                'Tell us about you',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text(
                'We will personalize your experience',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // name field
              _buildTextField(
                controller: _nameController,
                hint: 'Your name',
                errorText: _nameError,
              ),
              const SizedBox(height: 16),

              // age and gender row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController,
                      hint: 'Age',
                      keyboardType: TextInputType.number,
                      errorText: _ageError,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      hint: 'Gender',
                      value: _selectedGender,
                      items: _genders,
                      errorText: _genderError,
                      onChanged: (val) =>
                          setState(() => _selectedGender = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // weight and height row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _weightController,
                      hint: 'Weight (lbs)',
                      keyboardType: TextInputType.number,
                      errorText: _weightError,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildHeightPicker(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // activity level dropdown
              _buildDropdown(
                hint: 'Activity Level',
                value: _selectedActivityLevel,
                items: _activityLevels,
                errorText: _activityError,
                onChanged: (val) =>
                    setState(() => _selectedActivityLevel = val),
              ),
              const SizedBox(height: 24),

              // fitness goal section
              const Text(
                'Fitness goal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              ..._goals.map((goal) => _buildGoalOption(goal)),

              if (_goalError != null) ...[
                const SizedBox(height: 4),
                _errorRow(_goalError!),
              ],

              // weight loss / gain rate picker
              if (_goalNeedsRate) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      _selectedGoal == 'Weight Loss'
                          ? 'Weight loss rate'
                          : 'Bulk rate',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    if (_maintenanceCalories != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Maintain: $_maintenanceCalories cal',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF185FA5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedGoal == 'Weight Loss'
                      ? 'Choose how fast you want to lose weight.'
                      : 'Choose how fast you want to build muscle.',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                ..._rateOptions.map((rate) => _buildRateOption(rate)),

                if (_weightGoalRateError != null) ...[
                  const SizedBox(height: 4),
                  _errorRow(_weightGoalRateError!),
                ],
              ],

              const SizedBox(height: 28),

              // fitness level section
              const Text(
                'Fitness level',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sets the difficulty of your workout plan.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              ..._fitnessLevels.map((level) => _buildFitnessLevelOption(level)),

              if (_fitnessLevelError != null) ...[
                const SizedBox(height: 4),
                _errorRow(_fitnessLevelError!),
              ],
              const SizedBox(height: 32),

              // continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF378ADD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

            ],
          ),
        ),
      ),
    );
  }

  // ── Rate option card ──────────────────────────────────────────────────────

  Widget _buildRateOption(Map<String, dynamic> rate) {
    final key = rate['key'] as String;
    final isSelected = _selectedWeightGoalRate == key;
    final isRecommended = rate['recommended'] as bool;
    final isLoss = _selectedGoal == 'Weight Loss';
    final deficit = rate['deficit'] as int?;
    final surplus = rate['surplus'] as int?;
    final adjustment = deficit ?? surplus ?? 0;
    final maintenance = _maintenanceCalories;

    final int? targetCals = maintenance != null
        ? (isLoss ? maintenance - adjustment : maintenance + adjustment)
        : null;

    const Color selectedColor = Color(0xFF378ADD);
    const Color extremeColor = Color(0xFFD85A30);
    final Color cardColor = isRecommended ? selectedColor : extremeColor;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedWeightGoalRate = key;
        _weightGoalRateError = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: isSelected
              ? cardColor.withValues(alpha: 0.07)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cardColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? cardColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        rate['label'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? cardColor : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '✓ Recommended',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD85A30)
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '⚠ Hard to maintain',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFFD85A30),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rate['subtitle'] as String,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (targetCals != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$targetCals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? cardColor : Colors.black87,
                    ),
                  ),
                  const Text(
                    'cal/day',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ── Fitness level option ──────────────────────────────────────────────────

  Widget _buildFitnessLevelOption(Map<String, dynamic> level) {
    final label = level['label'] as String;
    final description = level['description'] as String;
    final icon = level['icon'] as IconData;
    final color = level['color'] as Color;
    final isSelected = _selectedFitnessLevel == label;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedFitnessLevel = label;
        _fitnessLevelError = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.07)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isSelected ? 1.0 : 0.0,
              child: Icon(Icons.check_circle, color: color, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ── Goal option ───────────────────────────────────────────────────────────

  Widget _buildGoalOption(String goal) {
    final isSelected = _selectedGoal == goal;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedGoal = goal;
        _goalError = null;
        _selectedWeightGoalRate = null;
        _weightGoalRateError = null;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF378ADD).withValues(alpha: 0.1)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD85A30)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFFD85A30) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              goal,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFFD85A30) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error row ─────────────────────────────────────────────────────────────

  Widget _errorRow(String message) {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFD85A30), size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFD85A30), fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ── Text field ────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: hasError
                ? const Color(0xFFD85A30).withValues(alpha: 0.05)
                : const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: hasError
                  ? const BorderSide(color: Color(0xFFD85A30), width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: hasError
                  ? const BorderSide(color: Color(0xFFD85A30), width: 2)
                  : const BorderSide(color: Color(0xFF378ADD), width: 2),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFD85A30), size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  errorText,
                  style: const TextStyle(
                      color: Color(0xFFD85A30), fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Dropdown ──────────────────────────────────────────────────────────────

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? errorText,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: hasError
                ? const Color(0xFFD85A30).withValues(alpha: 0.05)
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
            border: hasError
                ? Border.all(color: const Color(0xFFD85A30), width: 1.5)
                : Border.all(color: Colors.transparent),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(hint,
                    style: const TextStyle(color: Colors.grey)),
              ),
              isExpanded: true,
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              items: items
                  .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
                  .toList(),
              onChanged: (val) {
                onChanged(val);
                setState(() {});
              },
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFD85A30), size: 14),
              const SizedBox(width: 4),
              Text(
                errorText,
                style: const TextStyle(
                    color: Color(0xFFD85A30), fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Height picker ─────────────────────────────────────────────────────────

  Widget _buildHeightPicker() {
    final hasError = _heightError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showHeightPicker(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: hasError
                  ? const Color(0xFFD85A30).withValues(alpha: 0.05)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError ? const Color(0xFFD85A30) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _heightSelected
                      ? '$_selectedFeet\'$_selectedInches"'
                      : 'Height',
                  style: TextStyle(
                    fontSize: 16,
                    color: _heightSelected ? Colors.black87 : Colors.grey,
                  ),
                ),
                const Icon(Icons.expand_more, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Color(0xFFD85A30), size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _heightError!,
                  style: const TextStyle(
                      color: Color(0xFFD85A30), fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showHeightPicker() {
    int tempFeet = _selectedFeet;
    int tempInches = _selectedInches;

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
              const Text(
                'Select Height',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // feet wheel
                    Column(
                      children: [
                        const Text('ft',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                                    width: 1.5,
                                  ),
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
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 6,
                                  builder: (context, index) {
                                    final ft = index + 3;
                                    return Center(
                                      child: Text('$ft\'',
                                          style:
                                          const TextStyle(fontSize: 22)),
                                    );
                                  },
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
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                                    width: 1.5,
                                  ),
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
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 12,
                                  builder: (context, index) {
                                    return Center(
                                      child: Text('$index"',
                                          style:
                                          const TextStyle(fontSize: 22)),
                                    );
                                  },
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
                    setState(() {
                      _selectedFeet = tempFeet;
                      _selectedInches = tempInches;
                      _heightSelected = true;
                      _heightError = null;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF378ADD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
}