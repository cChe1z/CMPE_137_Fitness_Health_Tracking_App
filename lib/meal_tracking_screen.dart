import 'package:flutter/material.dart';
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
      _showCustomForm = false; // hide custom form when searching
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

    // clear results after adding
    setState(() {
      _searchResults = [];
      _hasSearched = false;
      _searchController.clear(); // also clear the search bar
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food['name']} added!'),
        backgroundColor: const Color(0xFF378ADD),
        duration: const Duration(seconds: 1),
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
        const SnackBar(
          content: Text('Please enter at least a meal name and calories'),
          backgroundColor: Color(0xFFD85A30),
        ),
      );
      return;
    }

    AppData.addMeal(name, calories,
        protein: protein, carbs: carbs, fats: fats);

    // clear and close form
    _customNameController.clear();
    _customCalorieController.clear();
    _customProteinController.clear();
    _customCarbsController.clear();
    _customFatsController.clear();

    setState(() => _showCustomForm = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added!'),
        backgroundColor: const Color(0xFF378ADD),
        duration: const Duration(seconds: 1),
      ),
    );
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // calorie progress card
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

                  const SizedBox(height: 24),

                  // search bar + custom button row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            prefixIcon: const Icon(Icons.search,
                                color: Colors.grey),
                            suffixIcon: _searchController.text.isNotEmpty || _searchResults.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchResults = [];
                                  _hasSearched = false;
                                });
                              },
                            )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF378ADD), width: 2),
                            ),
                          ),
                          onSubmitted: (val) => _searchFood(val.trim()),
                          onChanged: (val) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // custom button
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showCustomForm = !_showCustomForm;
                            // clear search results when opening custom
                            if (_showCustomForm) {
                              _searchResults = [];
                              _hasSearched = false;
                              _searchController.clear();
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD85A30),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Custom'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // search button below bar
                  if (!_showCustomForm)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            _searchFood(_searchController.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF378ADD),
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Search'),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // custom form
                  if (_showCustomForm) ...[
                    const Text(
                      'Add Custom Meal',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _buildCustomField(
                        _customNameController, 'Meal name', TextInputType.text),
                    const SizedBox(height: 10),
                    // calories and protein side by side
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
                    // carbs and fats side by side
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
                    const SizedBox(height: 4),
                    const Text(
                      '* required. Protein, carbs, fats are optional.',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addCustomMeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD85A30),
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add Meal',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // loading spinner
                  if (_isSearching)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          color: Color(0xFF378ADD),
                        ),
                      ),
                    )

                  // no results
                  else if (_hasSearched &&
                      _searchResults.isEmpty &&
                      !_showCustomForm)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'No results found. Try a different search.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )

                  // search results list
                  else if (_searchResults.isNotEmpty &&
                        !_showCustomForm) ...[
                      Text(
                        '${_searchResults.length > 10 ? 10 : _searchResults.length} results found',
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      ..._searchResults
                          .take(10)
                          .map((food) => _buildFoodResultCard(food)),
                    ],

                  const SizedBox(height: 24),

                  // meals today
                  const Text(
                    'Meals Today',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
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

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // search result card
  Widget _buildFoodResultCard(Map<String, dynamic> food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [

          // food icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Color(0xFF378ADD),
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // name and macros
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
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _macroTag(
                        '${food['calories']} cal', const Color(0xFFD85A30)),
                    _macroTag(
                        'P: ${food['protein']}g', const Color(0xFF378ADD)),
                    _macroTag('C: ${food['carbs']}g', Colors.orange),
                    _macroTag('F: ${food['fats']}g', Colors.green),
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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF378ADD),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
              const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // colored macro tag
  Widget _macroTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // logged meal card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // show macros if any were provided
                if (meal.protein > 0 ||
                    meal.carbs > 0 ||
                    meal.fats > 0) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (meal.protein > 0)
                        _macroTag('P: ${meal.protein}g',
                            const Color(0xFF378ADD)),
                      if (meal.carbs > 0)
                        _macroTag('C: ${meal.carbs}g', Colors.orange),
                      if (meal.fats > 0)
                        _macroTag('F: ${meal.fats}g', Colors.green),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${meal.calories} cal',
            style: const TextStyle(
              color: Color(0xFFD85A30),
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => AppData.deleteMeal(index),
            icon: const Icon(Icons.delete_outline,
                color: Color(0xFFD85A30)),
          ),
        ],
      ),
    );
  }

  // custom form text field
  Widget _buildCustomField(
      TextEditingController controller, String hint, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
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
    );
  }
}