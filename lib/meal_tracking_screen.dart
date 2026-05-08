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

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
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
      _hasSearched = true;
      _searchResults = [];
      _showCustomForm = false;
    });

    final results = await NutritionService().searchFood(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _addFromSearch(Map<String, dynamic> food) {
    AppData.addMeal(
      food['name'],
      food['calories'],
      protein: food['protein'],
      carbs: food['carbs'],
      fats: food['fats'],
    );

    setState(() {
      _searchResults = [];
      _hasSearched = false;
      _searchController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('${food['name']} added!')),
          ],
        ),
        backgroundColor: const Color(0xFF378ADD),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalCalories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isOver
                            ? const Color(0xFFD85A30)
                            : const Color(0xFF378ADD),
                      ),
                    ),
                    Text(
                      'of $calorieGoal',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // info column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOver ? 'Over budget' : 'Remaining',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOver
                      ? '+${totalCalories - calorieGoal} cal'
                      : '$remaining cal',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isOver
                        ? const Color(0xFFD85A30)
                        : const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),

                // progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor:
                    const Color(0xFF378ADD).withValues(alpha: 0.1),
                    color: isOver
                        ? const Color(0xFFD85A30)
                        : const Color(0xFF378ADD),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% of daily goal',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Macro breakdown row ─────────────────────────────────────────────────

  Widget _buildMacroRow() {
    return Row(
      children: [
        _buildMacroCard(
          label: 'Protein',
          grams: _totalProtein,
          color: const Color(0xFF378ADD),
          icon: Icons.blur_circular,
        ),
        const SizedBox(width: 10),
        _buildMacroCard(
          label: 'Carbs',
          grams: _totalCarbs,
          color: const Color(0xFFE67E22),
          icon: Icons.grain,
        ),
        const SizedBox(width: 10),
        _buildMacroCard(
          label: 'Fats',
          grams: _totalFats,
          color: const Color(0xFF2E7D32),
          icon: Icons.opacity,
        ),
      ],
    );
  }

  Widget _buildMacroCard({
    required String label,
    required int grams,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              '${grams}g',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search section ──────────────────────────────────────────────────────

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // section header
        Row(
          children: [
            const Text(
              'Add Food',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            // custom toggle
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCustomForm = !_showCustomForm;
                  if (_showCustomForm) {
                    _searchResults = [];
                    _hasSearched = false;
                    _searchController.clear();
                  }
                });
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _showCustomForm
                      ? const Color(0xFFD85A30).withValues(alpha: 0.1)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _showCustomForm
                        ? const Color(0xFFD85A30)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showCustomForm ? Icons.close : Icons.add,
                      size: 14,
                      color: _showCustomForm
                          ? const Color(0xFFD85A30)
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showCustomForm ? 'Cancel' : 'Custom',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _showCustomForm
                            ? const Color(0xFFD85A30)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // search bar (hidden when custom form is open)
        if (!_showCustomForm)
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search foods...',
                      hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.grey.shade400, size: 20),
                      suffixIcon:
                      _searchController.text.isNotEmpty ||
                          _searchResults.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.close,
                            color: Colors.grey.shade400, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchResults = [];
                            _hasSearched = false;
                          });
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onSubmitted: (val) => _searchFood(val.trim()),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _searchFood(_searchController.text.trim()),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF378ADD),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.search,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ── Results / custom form / spinner ─────────────────────────────────────

  Widget _buildResultsSection() {
    // custom form
    if (_showCustomForm) {
      return _buildCustomFormCard();
    }

    // loading
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                color: Color(0xFF378ADD),
                strokeWidth: 3,
              ),
              SizedBox(height: 12),
              Text('Searching foods...',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    // no results
    if (_hasSearched && _searchResults.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off,
                color: Colors.grey.shade400, size: 36),
            const SizedBox(height: 10),
            const Text(
              'No results found',
              style:
              TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try a different search or add a custom meal.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // search results
    if (_searchResults.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${_searchResults.length > 10 ? 10 : _searchResults.length} results',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchResults = [];
                    _hasSearched = false;
                    _searchController.clear();
                  });
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Color(0xFF378ADD),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._searchResults
              .take(10)
              .toList()
              .asMap()
              .entries
              .map((entry) => _buildFoodResultCard(entry.value, entry.key)),
          const SizedBox(height: 8),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // ── Custom form card ────────────────────────────────────────────────────

  Widget _buildCustomFormCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD85A30).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD85A30).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFD85A30).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note,
                    color: Color(0xFFD85A30), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Custom Meal',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
                child: _buildCustomField(_customProteinController,
                    'Protein (g)', TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildCustomField(_customCarbsController,
                    'Carbs (g)', TextInputType.number),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCustomField(_customFatsController,
                    'Fats (g)', TextInputType.number),
              ),
            ],
          ),

          const SizedBox(height: 6),
          const Text(
            '* required. Macros are optional.',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addCustomMeal,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Meal',
                  style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD85A30),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search result card ──────────────────────────────────────────────────

  Widget _buildFoodResultCard(Map<String, dynamic> food, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // calorie badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFD85A30).withValues(alpha: 0.12),
                  const Color(0xFFD85A30).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${food['calories']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFFD85A30),
                  ),
                ),
                const Text(
                  'cal',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFFD85A30),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // name + macros
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _miniMacro('P', '${food['protein']}g',
                        const Color(0xFF378ADD)),
                    const SizedBox(width: 8),
                    _miniMacro('C', '${food['carbs']}g',
                        const Color(0xFFE67E22)),
                    const SizedBox(width: 8),
                    _miniMacro('F', '${food['fats']}g',
                        const Color(0xFF2E7D32)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // add button
          GestureDetector(
            onTap: () => _addFromSearch(food),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF378ADD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMacro(String letter, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Meals today section ─────────────────────────────────────────────────

  Widget _buildMealsSection(List<Meal> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Today\'s Meals',
              style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            if (meals.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF378ADD).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
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