import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'app_data.dart';
import 'services/nutrition_service.dart';

class MealTrackingScreen extends StatefulWidget {
  const MealTrackingScreen({super.key});

  @override
  State<MealTrackingScreen> createState() => _MealTrackingScreenState();
}

class _MealTrackingScreenState extends State<MealTrackingScreen> {
  final _searchController = TextEditingController();

  // custom entry controllers
  final _customNameController = TextEditingController();
  final _customCalorieController = TextEditingController();
  final _customProteinController = TextEditingController();
  final _customCarbsController = TextEditingController();
  final _customFatsController = TextEditingController();

  List<FoodItem> _searchResults = [];
  bool _isSearching = false;
  bool _showCustomForm = false;

  @override
  void dispose() {
    _searchController.dispose();
    _customNameController.dispose();
    _customCalorieController.dispose();
    _customProteinController.dispose();
    _customCarbsController.dispose();
    _customFatsController.dispose();
    super.dispose();
  }

  Future<void> _searchFood(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResults = [];
      _showCustomForm = false;
    });

    final results = await NutritionService().searchFood(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  // ✅ NEW: Show portion selector bottom sheet
  void _showPortionSelector(FoodItem food) {
    double selectedPortion = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final portionNutrition = food.getPortionNutrition(selectedPortion);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food.displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              food.servingInfo,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Portion selector
                  const Text(
                    'Select Portion',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Portion slider
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: selectedPortion,
                          min: 0.25,
                          max: 5.0,
                          divisions: 19,
                          label: '${selectedPortion.toStringAsFixed(2)}x',
                          activeColor: const Color(0xFF378ADD),
                          onChanged: (value) {
                            setModalState(() {
                              selectedPortion = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          '${selectedPortion.toStringAsFixed(2)}x',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Nutrition info card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF378ADD).withValues(alpha: 0.08),
                          const Color(0xFFD85A30).withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF378ADD).withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Calories
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Calories',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${portionNutrition['calories']} cal',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD85A30),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Macros
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMacroChip(
                              'P',
                              portionNutrition['protein']!,
                              'g',
                              const Color(0xFF378ADD),
                            ),
                            _buildMacroChip(
                              'C',
                              portionNutrition['carbs']!,
                              'g',
                              const Color(0xFFE67E22),
                            ),
                            _buildMacroChip(
                              'F',
                              portionNutrition['fats']!,
                              'g',
                              const Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Add button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        AppData.addMeal(
                          food.displayName,
                          portionNutrition['calories']!,
                          protein: portionNutrition['protein']!,
                          carbs: portionNutrition['carbs']!,
                          fats: portionNutrition['fats']!,
                        );
                        Navigator.pop(context);
                        setState(() {
                          _searchResults = [];
                          _searchController.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text('${food.displayName} added!')),
                              ],
                            ),
                            backgroundColor: const Color(0xFF378ADD),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF378ADD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add to Meals',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMacroChip(String label, int value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _addCustomMeal() {
    final name = _customNameController.text.trim();
    final calories = int.tryParse(_customCalorieController.text.trim());
    final protein = int.tryParse(_customProteinController.text.trim()) ?? 0;
    final carbs = int.tryParse(_customCarbsController.text.trim()) ?? 0;
    final fats = int.tryParse(_customFatsController.text.trim()) ?? 0;

    if (name.isEmpty || calories == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter at least a meal name and calories'),
          backgroundColor: const Color(0xFFD85A30),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    AppData.addMeal(name, calories,
        protein: protein, carbs: carbs, fats: fats);

    _customNameController.clear();
    _customCalorieController.clear();
    _customProteinController.clear();
    _customCarbsController.clear();
    _customFatsController.clear();

    setState(() => _showCustomForm = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('$name added!')),
          ],
        ),
        backgroundColor: const Color(0xFF378ADD),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Macro totals from today's meals ─────────────────────────────────────

  int get _totalProtein =>
      AppData.meals.value.fold(0, (sum, m) => sum + m.protein);
  int get _totalCarbs =>
      AppData.meals.value.fold(0, (sum, m) => sum + m.carbs);
  int get _totalFats =>
      AppData.meals.value.fold(0, (sum, m) => sum + m.fats);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Meal>>(
      valueListenable: AppData.meals,
      builder: (context, meals, child) {
        final totalCalories = AppData.totalCalories;
        final calorieGoal = AppData.calorieGoal.value;
        final remaining = calorieGoal - totalCalories;
        final progress = (totalCalories / calorieGoal).clamp(0.0, 1.0);
        final isOver = totalCalories > calorieGoal;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Meal Tracker',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Calorie gauge card ─────────────────────────────
                  _buildCalorieGaugeCard(
                    totalCalories: totalCalories,
                    calorieGoal: calorieGoal,
                    remaining: remaining,
                    progress: progress,
                    isOver: isOver,
                  ),

                  const SizedBox(height: 16),

                  // ── Macro breakdown row ────────────────────────────
                  _buildMacroRow(),

                  const SizedBox(height: 24),

                  // ── Search + custom ────────────────────────────────
                  _buildSearchSection(),

                  const SizedBox(height: 20),

                  // ── Results / custom form / spinner ────────────────
                  _buildResultsSection(),

                  // ── Meals today ────────────────────────────────────
                  _buildMealsSection(meals),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Circular calorie gauge ──────────────────────────────────────────────

  Widget _buildCalorieGaugeCard({
    required int totalCalories,
    required int calorieGoal,
    required int remaining,
    required double progress,
    required bool isOver,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF378ADD).withValues(alpha: 0.08),
            const Color(0xFFD85A30).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF378ADD).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          // circular gauge
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _CalorieRingPainter(
                progress: progress,
                isOver: isOver,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$totalCalories',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isOver
                            ? const Color(0xFFD85A30)
                            : const Color(0xFF378ADD),
                      ),
                    ),
                    Text(
                      'of $calorieGoal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 24),

          // right side text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOver ? 'Over Goal' : 'Remaining',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isOver ? totalCalories - calorieGoal : remaining} cal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isOver
                        ? const Color(0xFFD85A30)
                        : const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).round()}% of daily goal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Macro breakdown ─────────────────────────────────────────────────────

  Widget _buildMacroRow() {
    return Row(
      children: [
        Expanded(
          child: _macroCard(
            'Protein',
            _totalProtein,
            'g',
            const Color(0xFF378ADD),
            Icons.fitness_center,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _macroCard(
            'Carbs',
            _totalCarbs,
            'g',
            const Color(0xFFE67E22),
            Icons.grain,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _macroCard(
            'Fats',
            _totalFats,
            'g',
            const Color(0xFF2E7D32),
            Icons.water_drop,
          ),
        ),
      ],
    );
  }

  Widget _macroCard(
      String label, int value, String unit, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Search section ──────────────────────────────────────────────────────

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Food',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: _searchFood,
                decoration: InputDecoration(
                  hintText: 'Search foods...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF378ADD),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // custom button
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCustomForm = !_showCustomForm;
                  if (_showCustomForm) {
                    _searchResults = [];
                  }
                });
              },
              child: Container(
                height: 50,
                width: 80,
                decoration: BoxDecoration(
                  color: _showCustomForm
                      ? const Color(0xFFD85A30)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _showCustomForm
                        ? const Color(0xFFD85A30)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.edit,
                  color:
                      _showCustomForm ? Colors.white : Colors.grey.shade600,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Results section ─────────────────────────────────────────────────────

  Widget _buildResultsSection() {
    if (_isSearching) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF378ADD),
          ),
        ),
      );
    }

    if (_showCustomForm) {
      return _buildCustomForm();
    }

    if (_searchResults.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search Results',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchResults = [];
                    _searchController.clear();
                  });
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Color(0xFF378ADD),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(
            _searchResults.length,
            (index) => _buildSearchResultCard(_searchResults[index]),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // ✅ UPDATED: Search result card now opens portion selector
  Widget _buildSearchResultCard(FoodItem food) {
    return GestureDetector(
      onTap: () => _showPortionSelector(food),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${food.caloriesPer100g}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD85A30),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _miniMacro(
                          'P', '${food.proteinPer100g}g', const Color(0xFF378ADD)),
                      const SizedBox(width: 8),
                      _miniMacro(
                          'C', '${food.carbsPer100g}g', const Color(0xFFE67E22)),
                      const SizedBox(width: 8),
                      _miniMacro(
                          'F', '${food.fatsPer100g}g', const Color(0xFF2E7D32)),
                    ],
                  ),
                ],
              ),
            ),
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

  Widget _miniMacro(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // ── Custom form ─────────────────────────────────────────────────────────

  Widget _buildCustomForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD85A30).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Custom Meal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showCustomForm = false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFFD85A30),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildCustomField(
              _customNameController, 'Meal name', TextInputType.text),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildCustomField(_customCalorieController,
                    'Calories *', TextInputType.number),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCustomField(
                    _customProteinController, 'Protein (g)', TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildCustomField(
                    _customCarbsController, 'Carbs (g)', TextInputType.number),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCustomField(
                    _customFatsController, 'Fats (g)', TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addCustomMeal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD85A30),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Meal',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Meals section ───────────────────────────────────────────────────────

  Widget _buildMealsSection(List<Meal> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Today\'s Meals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF378ADD).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${meals.length}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF378ADD),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (meals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.restaurant_menu,
                    color: Colors.grey.shade300, size: 40),
                const SizedBox(height: 10),
                const Text(
                  'No meals logged yet',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black54),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Search or add a custom meal above.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...List.generate(
            meals.length,
            (index) => _buildMealCard(meals[index], index),
          ),
      ],
    );
  }

  // ── Meal card ───────────────────────────────────────────────────────────

  Widget _buildMealCard(Meal meal, int index) {
    return Dismissible(
      key: ValueKey('${meal.name}_${meal.calories}_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => AppData.deleteMeal(index),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFD85A30),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 24),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // food icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant,
                  color: Color(0xFF378ADD), size: 22),
            ),

            const SizedBox(width: 12),

            // name + macros
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (meal.protein > 0 ||
                      meal.carbs > 0 ||
                      meal.fats > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (meal.protein > 0)
                          _miniMacro('P', '${meal.protein}g',
                              const Color(0xFF378ADD)),
                        if (meal.protein > 0) const SizedBox(width: 8),
                        if (meal.carbs > 0)
                          _miniMacro('C', '${meal.carbs}g',
                              const Color(0xFFE67E22)),
                        if (meal.carbs > 0) const SizedBox(width: 8),
                        if (meal.fats > 0)
                          _miniMacro('F', '${meal.fats}g',
                              const Color(0xFF2E7D32)),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // calorie badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD85A30).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${meal.calories}',
                style: const TextStyle(
                  color: Color(0xFFD85A30),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            // delete button
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => AppData.deleteMeal(index),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close,
                    color: Colors.grey.shade400, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Custom form field ───────────────────────────────────────────────────

  Widget _buildCustomField(
      TextEditingController controller, String hint, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF378ADD), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// ─── Calorie ring painter ──────────────────────────────────────────────────────

class _CalorieRingPainter extends CustomPainter {
  final double progress;
  final bool isOver;

  _CalorieRingPainter({
    required this.progress,
    required this.isOver,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;

    // background ring
    final bgPaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (isOver) {
      progressPaint.color = const Color(0xFFD85A30);
    } else {
      progressPaint.shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: const [
          Color(0xFF378ADD),
          Color(0xFF2E7D32),
        ],
        stops: const [0.0, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    }

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CalorieRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isOver != isOver;
  }
}