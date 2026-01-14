import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Analyze food image using AI
  static Future<Map<String, dynamic>> analyzeFood(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/ai/analyze-food'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to analyze food: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out while analyzing food. This can happen if the phone cannot reach the backend, '
        'or if the AI processing takes longer than expected. Tried API: $baseUrl',
      );
    } catch (e) {
      throw Exception('Error analyzing food: $e');
    }
  }

  /// Detect ingredients from food image
  static Future<Map<String, dynamic>> detectIngredients(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/ai/detect-ingredients'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to detect ingredients: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out while detecting ingredients. Tried API: $baseUrl',
      );
    } catch (e) {
      throw Exception('Error detecting ingredients: $e');
    }
  }

  /// Get recipe recommendations based on ingredients and filters
  ///
  /// [ingredients] - Required list of available ingredients
  /// [maxMinutes] - Optional max cooking time filter
  /// [cuisines] - Optional list of preferred cuisines
  /// [vegetarian] - Filter for vegetarian recipes only
  /// [vegan] - Filter for vegan recipes only
  /// [halal] - Filter for halal recipes only (excludes pork, bacon, etc.)
  /// [maxMissingIngredients] - Max number of missing ingredients allowed (default: 5)
  /// [topK] - Number of recipes to return (default: 10)
  static Future<Map<String, dynamic>> recommendRecipes({
    required List<String> ingredients,
    int? maxMinutes,
    List<String>? cuisines,
    bool vegetarian = false,
    bool vegan = false,
    bool halal = false,
    int maxMissingIngredients = 5,
    int topK = 10,
  }) async {
    try {
      final body = {
        'ingredients': ingredients,
        'vegetarian': vegetarian,
        'vegan': vegan,
        'halal': halal,
        'maxMissingIngredients': maxMissingIngredients,
        'topK': topK,
      };

      // Only add optional filters if they have values
      if (maxMinutes != null) {
        body['maxMinutes'] = maxMinutes;
      }
      if (cuisines != null && cuisines.isNotEmpty) {
        body['cuisines'] = cuisines;
      }

      var response = await http
          .post(
            Uri.parse('$baseUrl/ai/recommend-recipes'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(
            const Duration(seconds: 120),
          ); // Increased timeout for large CSV processing

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recipes: $e');
    }
  }

  /// Health check
  static Future<bool> checkHealth() async {
    try {
      var response = await http
          .get(Uri.parse('$baseUrl/ai/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
