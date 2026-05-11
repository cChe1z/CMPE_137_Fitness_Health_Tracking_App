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
  final _nutritionService = NutritionService();
  
  List<FoodItem> _searchResults = [];
  bool _isSearching = false;
  bool _showManualEntry = false;

  // Manual entry controllers
  final _mealController = TextEditingController();
  final _calorieController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _mealController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  Future<void> _searchFood(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _nutritionService.searchFood(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    }
  }

  void _showPortionSelector(FoodItem food) {
    double selectedPortion = 1.0; // Default 1 serving
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final portionNutrition = food.getPortionNutrition(selectedPortion);
            
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
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
                            ),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildNutritionRow(
                          'Calories',
                          portionNutrition['calories']!,
                          'cal',
                          const Color(0xFFD85A30),
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMacroChip(
                              'P',
                              portionNutrition['protein']!,
                              'g',
                              Colors.blue,
                            ),
                            _buildMacroChip(
                              'C',
                              portionNutrition['carbs']!,
                              'g',
                              Colors.orange,
                            ),
                            _buildMacroChip(
                              'F',
                              portionNutrition['fats']!,
                              'g',
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Add button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        AppData.addMeal(
                          food.displayName,
                          portionNutrition['calories']!,
                        );
                        Navigator.pop(context);
                        setState(() {
                          _searchResults = [];
                          _searchController.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Meal added successfully!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF378ADD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add to Meals',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNutritionRow(String label, int value, String unit, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '$value $unit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroChip(String label, int value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _addManualMeal() {
    final name = _mealController.text.trim();
    final calories = int.tryParse(_calorieController.text.trim());

    if (name.isEmpty || calories == null) return;

    AppData.addMeal(name, calories);

    _mealController.clear();
    _calorieController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal added successfully!'),
        duration: Duration(seconds: 2),
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
            child: Column(
              children: [
                // Progress header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Container(
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
                ),

                // Search bar with toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search for food...',
                                prefixIcon: const Icon(Icons.search),
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
                              onChanged: (value) {
                                // Debounce search
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (_searchController.text == value) {
                                    _searchFood(value);
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showManualEntry = !_showManualEntry;
                                if (_showManualEntry) {
                                  _searchResults = [];
                                  _searchController.clear();
                                }
                              });
                            },
                            icon: Icon(
                              _showManualEntry ? Icons.search : Icons.edit,
                              color: const Color(0xFF378ADD),
                            ),
                          ),
                        ],
                      ),

                      if (_searchResults.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_searchResults.length} results',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _searchResults = [];
                                    _searchController.clear();
                                  });
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Content area
                Expanded(
                  child: _showManualEntry
                      ? _buildManualEntryForm()
                      : _searchResults.isNotEmpty
                          ? _buildSearchResults()
                          : _buildMealsList(meals),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${food.caloriesPer100g}\ncal',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD85A30),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            title: Text(
              food.displayName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  _buildSmallMacro('P', food.proteinPer100g, Colors.blue),
                  const SizedBox(width: 8),
                  _buildSmallMacro('C', food.carbsPer100g, Colors.orange),
                  const SizedBox(width: 8),
                  _buildSmallMacro('F', food.fatsPer100g, Colors.green),
                ],
              ),
            ),
            trailing: IconButton(
              onPressed: () => _showPortionSelector(food),
              icon: const Icon(
                Icons.add_circle,
                color: Color(0xFF378ADD),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmallMacro(String label, int value, Color color) {
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
          '${value}g',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manual Entry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mealController,
            decoration: InputDecoration(
              hintText: 'Meal name',
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
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _calorieController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Calories',
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
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addManualMeal,
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
        ],
      ),
    );
  }

  Widget _buildMealsList(List<Meal> meals) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                'No meals added yet.\nSearch for food or use manual entry.',
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
}