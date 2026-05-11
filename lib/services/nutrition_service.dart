import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodItem {
  final String name;
  final String description; // Full description with brand/details
  final int caloriesPer100g;
  final int proteinPer100g;
  final int carbsPer100g;
  final int fatsPer100g;
  final double servingSize;
  final String servingSizeUnit;
  final String? brandName;
  final String dataType; // "Branded", "Survey (FNDDS)", etc.

  FoodItem({
    required this.name,
    required this.description,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    required this.servingSize,
    required this.servingSizeUnit,
    this.brandName,
    required this.dataType,
  });

  // Calculate nutrition for a specific portion
  Map<String, int> getPortionNutrition(double portionMultiplier) {
    return {
      'calories': (caloriesPer100g * portionMultiplier).round(),
      'protein': (proteinPer100g * portionMultiplier).round(),
      'carbs': (carbsPer100g * portionMultiplier).round(),
      'fats': (fatsPer100g * portionMultiplier).round(),
    };
  }

  String get displayName {
    if (brandName != null && brandName!.isNotEmpty) {
      return '$brandName - $name';
    }
    return name;
  }

  String get servingInfo {
    if (servingSize > 0) {
      return '${servingSize.toStringAsFixed(0)}$servingSizeUnit serving';
    }
    return 'per 100g';
  }
}

class NutritionService {
  final String apiKey = 'uSClJ1yQmQ2ZNKeDAaKlW0VzxVVkkZHkWUrDUUUy';
  final String baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  Future<List<FoodItem>> searchFood(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods/search?query=$query&pageSize=20&api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> foods = data['foods'] ?? [];
        
        // Convert to FoodItem objects
        List<FoodItem> foodItems = foods.map((food) {
          var nutrients = food['foodNutrients'] ?? [];
          double calories = 0;
          double protein = 0;
          double carbs = 0;
          double fats = 0;

          for (var nutrient in nutrients) {
            String name = nutrient['nutrientName'] ?? '';
            double value = (nutrient['value'] ?? 0).toDouble();

            if (name.contains('Energy')) calories = value;
            if (name.contains('Protein')) protein = value;
            if (name.contains('Carbohydrate')) carbs = value;
            if (name.contains('Total lipid')) fats = value;
          }

          // Get serving size info
          double servingSize = (food['servingSize'] ?? 100).toDouble();
          String servingSizeUnit = food['servingSizeUnit'] ?? 'g';
          String brandName = food['brandOwner'] ?? food['brandName'] ?? '';
          String dataType = food['dataType'] ?? '';

          return FoodItem(
            name: food['description'] ?? 'Unknown',
            description: _buildDescription(food),
            caloriesPer100g: calories.round(),
            proteinPer100g: protein.round(),
            carbsPer100g: carbs.round(),
            fatsPer100g: fats.round(),
            servingSize: servingSize,
            servingSizeUnit: servingSizeUnit,
            brandName: brandName.isNotEmpty ? brandName : null,
            dataType: dataType,
          );
        }).toList();

        // Remove duplicates (same name, brand, and similar calories)
        return _removeDuplicates(foodItems);
      }
      return [];
    } catch (e) {
      print('Error searching food: $e');
      return [];
    }
  }

  String _buildDescription(Map<String, dynamic> food) {
    String desc = food['description'] ?? 'Unknown';
    String brand = food['brandOwner'] ?? food['brandName'] ?? '';
    double servingSize = (food['servingSize'] ?? 0).toDouble();
    String servingUnit = food['servingSizeUnit'] ?? 'g';
    
    if (brand.isNotEmpty) {
      desc = '$brand - $desc';
    }
    
    if (servingSize > 0) {
      desc = '$desc (${servingSize.toStringAsFixed(0)}$servingUnit)';
    }
    
    return desc;
  }

  List<FoodItem> _removeDuplicates(List<FoodItem> items) {
    Map<String, FoodItem> uniqueItems = {};
    
    for (var item in items) {
      // Create a unique key based on name and brand
      String key = '${item.name}_${item.brandName ?? 'generic'}'.toLowerCase();
      
      // If we haven't seen this item, or this one has more detailed info, keep it
      if (!uniqueItems.containsKey(key) || 
          (item.brandName != null && uniqueItems[key]!.brandName == null)) {
        uniqueItems[key] = item;
      } else {
        // If calories are significantly different (>20%), it's a different item
        int existingCal = uniqueItems[key]!.caloriesPer100g;
        int newCal = item.caloriesPer100g;
        double difference = (existingCal - newCal).abs() / existingCal;
        
        if (difference > 0.2) {
          // Add a suffix to make it unique
          uniqueItems['${key}_${newCal}cal'] = item;
        }
      }
    }
    
    return uniqueItems.values.toList();
  }
}