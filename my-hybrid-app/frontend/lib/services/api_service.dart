import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your computer's IP address when testing on physical device
  static const String baseUrl = 'http://192.168.100.23:3000/api';

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
        const Duration(seconds: 30),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to analyze food: ${response.statusCode}');
      }
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
        const Duration(seconds: 30),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to detect ingredients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error detecting ingredients: $e');
    }
  }

  /// Get recipe recommendations based on ingredients
  static Future<Map<String, dynamic>> recommendRecipes(
    List<String> ingredients,
  ) async {
    try {
      var response = await http
          .post(
            Uri.parse('$baseUrl/ai/recommend-recipes'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'ingredients': ingredients}),
          )
          .timeout(const Duration(seconds: 30));

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
