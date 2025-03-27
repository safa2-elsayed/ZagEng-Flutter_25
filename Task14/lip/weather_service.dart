import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class WeatherService {
  Future<Map<String, dynamic>?> fetchWeather(String city, bool isArabic) async {
    final lang = isArabic ? "ar" : "en";
    final url =
        "https://api.weatherapi.com/v1/forecast.json?key=${Secrets.weatherApiKey}&q=$city&days=3&lang=$lang";

    try {
      final response = await http.get(Uri.parse(url));

      print("API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(decodedResponse);
        print("API Response: $jsonData");
        return jsonData;
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Failed to fetch weather data: $e");
      return null;
    }
  }
}