import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_recipe_model.dart';

class SpoonacularService {
  static const String _apiKey = '42c38820b68841d2a9232c155ea0ee29';
  static const String _baseUrl = 'https://api.spoonacular.com/recipes';

  static Future<List<ApiRecipeModel>> fetchRandomRecipes({int number = 6}) async {
    try {
      final url = Uri.parse('$_baseUrl/random?apiKey=$_apiKey&number=$number');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List recipes = data['recipes'] ?? [];
        
        return recipes.map((json) => ApiRecipeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<ApiRecipeModel>> fetchRecipesByTag({
    required String tag,
    int number = 6,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/random?apiKey=$_apiKey&number=$number&tags=$tag',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List recipes = data['recipes'] ?? [];
        
        return recipes.map((json) => ApiRecipeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }
}
