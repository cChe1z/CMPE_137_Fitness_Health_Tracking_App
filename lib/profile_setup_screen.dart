import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  int _selectedFeet = 5;
  int _selectedInches = 8;
  bool _heightSelected = false;

  String? _selectedGender;
  String? _selectedActivityLevel;
  String? _selectedGoal;

  // errors
  String? _ageError;
  String? _weightError;
  String? _heightError;
  String? _genderError;
  String? _activityError;
  String? _goalError;

  final List<String> _genders = ['Male', 'Female', 'Prefer not to say'];
  final List<String> _activityLevels = [
    'No Activity',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
  ];
  final List<String> _goals = [
    'Weight Loss',
    'Muscle Gain',
    'Maintenance',
  ];

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _continue() {
    // reset all errors
    setState(() {
      _ageError = null;
      _weightError = null;
      _heightError = null;
      _genderError = null;
      _activityError = null;
      _goalError = null;
    });

    bool hasError = false;

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

    // height validation
    if (!_heightSelected) {
      setState(() => _heightError = 'Please select your height');
      hasError = true;
    }

    // dropdown validations
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

    if (hasError) return;

    // ----------- add: save profile data ---------------------------
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
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

              // goal options
              ..._goals.map((goal) => _buildGoalOption(goal)),

              // goal error
              if (_goalError != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFD85A30), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _goalError!,
                      style: const TextStyle(
                          color: Color(0xFFD85A30), fontSize: 12),
                    ),
                  ],
                ),
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

  // goal radio button option
  Widget _buildGoalOption(String goal) {
    final isSelected = _selectedGoal == goal;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedGoal = goal;
        _goalError = null; // clear error when selected
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
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFFD85A30) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // reusable text field
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

  // reusable dropdown
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
              onChanged: onChanged,
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

  // Scrollable height selection
  void _showHeightPicker() {
    // temp values while scrolling
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

                              // orange highlight behind selected item
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD85A30).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFD85A30),
                                    width: 1.5,
                                  ),
                                ),
                              ),

                              // feet scroll wheel
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
                                      child: Text(
                                        '$ft\'',
                                        style: const TextStyle(fontSize: 22),
                                      ),
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

                              // orange highlight behind selected item
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD85A30).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFD85A30),
                                    width: 1.5,
                                  ),
                                ),
                              ),

                              // inches scroll wheel
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
                                      child: Text(
                                        '$index"',
                                        style: const TextStyle(fontSize: 22),
                                      ),
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

              // confirm button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFeet = tempFeet;
                      _selectedInches = tempInches;
                      _heightSelected = true;
                      _heightError = null; // clear error on confirm
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