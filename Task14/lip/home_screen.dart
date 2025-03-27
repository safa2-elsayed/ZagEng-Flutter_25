import 'package:flutter/material.dart';
import '../weather_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService weatherService = WeatherService();
  Map<String, dynamic>? weatherData;
  String city = "Amman";
  final TextEditingController _controller = TextEditingController();
  bool isArabic = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future<void> getWeather() async {
    setState(() {
      _isLoading = true;
    });

    print("Fetching weather data for: $city");
    final data = await weatherService.fetchWeather(city, isArabic);

    setState(() {
      if (data != null) {
        print("Weather Data Received: $data");
        weatherData = data;
      } else {
        print("No data received!");
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFA957),
      appBar: AppBar(
        title: Text(
          isArabic ? "صفاء " : "Safaa",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.white),
            onPressed: () {
              setState(() {
                isArabic = !isArabic;
                getWeather();
              });
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                  isArabic ? "أدخل اسم المدينة" : "Search here...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        city = _controller.text;
                        getWeather();
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 5),
                Text(
                  weatherData?["location"]?["name"] ??
                      "Location not found",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              formatDateTime(
                  weatherData?["location"]?["localtime"] ?? ""),
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weatherData?["current"]?["condition"]?["text"] ??
                      "Condition not available",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${weatherData?["current"]?["temp_c"]?.toString() ?? "N/A"}",
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    "°C",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Image.asset(
                  getWeatherIcon(
                      weatherData?["current"]?["condition"]?["text"] ??
                          "cloud"),
                  width: 70,
                  height: 70,
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                final day =
                weatherData?["forecast"]?["forecastday"]?[index];
                String dayNumber = day?["date"]?.split("-")[2] ?? "N/A";
                String condition =
                    day?["day"]?["condition"]?["text"] ?? "Unknown";
                String temp =
                    day?["day"]?["avgtemp_c"]?.toString() ?? "N/A";
                return ForecastCard(
                  day: dayNumber,
                  condition: condition,
                  temperature: temp,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget ForecastCard({
    required String day,
    required String condition,
    required String temperature,
  }) {
    return Container(
      width: 100,
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            "$day ",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            condition,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Image.asset(
            getWeatherIcon(condition),
            width: 32,
            height: 32,
          ),
          SizedBox(height: 8),
          Text(
            "${temperature}°C ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains("sunny") || condition.contains("مشمس")) {
      return "assets/icons/sun.png";
    } else if (condition.contains("cloudy") || condition.contains("غائم")) {
      return "assets/icons/cloud.png";
    } else if (condition.contains("rain") || condition.contains("ممطر")) {
      return "assets/icons/rain.png";
    } else if (condition.contains("mist") || condition.contains("سديم")) {
      return "assets/icons/mist.png";
    } else {
      return "assets/icons/cloud.png";
    }
  }

  String formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      final format =
      DateFormat('EEEE, dd MMMM', 'en_US').addPattern(' , HH:mm');
      return format.format(dateTime);
    } catch (e) {
      print("Error formatting date: $e");
      return dateTimeString;
    }
  }
}
