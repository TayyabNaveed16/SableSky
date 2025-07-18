import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String weatherApiKey = dotenv.env['WEATHER_API_KEY'] ?? 'no key';

class MyAppState extends ChangeNotifier {
  late WeatherFactory ws;
  List<Weather>? forecast;

  MyAppState() {
    ws = WeatherFactory(weatherApiKey);
  }

  Future<void> fetchForecast(double lat, double lon) async {
    forecast = await ws.fiveDayForecastByLocation(lat, lon);
    // debugPrint("Five day Forecast: $forecast");
    notifyListeners();
  }
}
