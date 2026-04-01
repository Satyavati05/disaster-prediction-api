import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionService {
  static const String baseUrl = "http://10.0.2.2:5000"; // Use 10.0.2.2 for Android Emulator

  Future<String> getPrediction(double rainfall, double riverLevel) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "rainfall": rainfall,
          "river_level": riverLevel
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['prediction'];
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Connection failed: $e";
    }
  }
}
