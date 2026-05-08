import 'dart:convert';
import 'package:http/http.dart' as http;

class NutritionService {
  final String apiKey = 'uSClJ1yQmQ2ZNKeDAaKlW0VzxVVkkZHkWUrDUUUy';
  final String baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  Future<List<Map<String, dynamic>>> searchFood(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods/search?query=$query&pageSize=10&api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> foods = data['foods'] ?? [];

        return foods.map((food) {
          var nutrients = food['foodNutrients'] ?? [];
          double calories = 0;
          double protein = 0;
          double carbs = 0;
          double fats = 0;

          // The USDA API can return multiple Energy entries (kcal and kJ).
          // We specifically look for the kcal entry to avoid inflated values.
          double? kcalValue;
          double? genericEnergyValue;

          for (var nutrient in nutrients) {
            final String name = nutrient['nutrientName'] ?? '';
            final String unit = nutrient['unitName'] ?? '';
            final double value = (nutrient['value'] ?? 0).toDouble();

            if (name.contains('Energy')) {
              if (unit.toLowerCase() == 'kcal') {
                // prefer kcal specifically
                kcalValue = value;
              } else if (unit.toLowerCase() != 'kj') {
                // fallback: anything that isn't kJ
                genericEnergyValue = value;
              }
            }
            if (name.contains('Protein')) protein = value;
            if (name.contains('Carbohydrate')) carbs = value;
            if (name.contains('Total lipid')) fats = value;
          }

          // use kcal if found, otherwise fall back to generic, otherwise 0
          calories = kcalValue ?? genericEnergyValue ?? 0;

          return {
            'name': food['description'] ?? 'Unknown',
            'calories': calories.round(),
            'protein': protein.round(),
            'carbs': carbs.round(),
            'fats': fats.round(),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error searching food: $e');
      return [];
    }
  }
}
