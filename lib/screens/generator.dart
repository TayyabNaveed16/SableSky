import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/air_quality.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


final String weatherApiKey = dotenv.env['WEATHER_API_KEY'] ?? 'no key';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  GeneratorPageState createState() => GeneratorPageState();
}

class GeneratorPageState extends State<GeneratorPage> {
  late WeatherFactory ws;
  Weather? _weather;
  bool _loading = false;
  String _cityName = "";
  String? _backgroundImage;
  List<Weather>? forecast;
  int? _visibility;
  int? _aqi;

  final Map<String, List<String>> weatherImages = {
    'Rain': [
      'assets/images/rainy1.png',
      'assets/images/rainy2.png',
      'assets/images/rainy3.png',
    ],
    'Snow': [
      'assets/images/snowy1.png',
      'assets/images/snowy2.png',
      'assets/images/snowy3.png',
      'assets/images/snowy4.png',
      'assets/images/snowy5.png',
      'assets/images/snowy6.png',
    ],
    'Clouds': [
      'assets/images/cloudy1.png',
      'assets/images/cloudy2.png',
      'assets/images/cloudy3.png',
    ],
    'ClearDay': [
      'assets/images/sunny1.jpg',
      'assets/images/sunny2.png',
      'assets/images/sunny3.png',
      'assets/images/sunny4.png',
    ],
    'ClearNight': [
      'assets/images/night1.png',
      'assets/images/night2.png',
      'assets/images/night3.png',
      'assets/images/night4.png',
      'assets/images/night5.png',
    ],
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    ws = WeatherFactory(weatherApiKey);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      Position position = lastPosition ?? await Geolocator.getCurrentPosition();

      debugPrint(
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}');

      await fetchWeather(position.latitude, position.longitude);
    } else {
      setState(() {
        _cityName = "Location permission denied";
      });
    }
  }

  Future<void> fetchWeather(double lat, double lon) async {
    setState(() {
      _loading = true;
    });

    //Rain
    // lat = 44.1006;
    // lon = 3.0778;

    // lat = 42.4755;
    // lon = 44.4805;

    Weather weather = await ws.currentWeatherByLocation(lat, lon);
    fetchVisibilityAndAirQuality(lat, lon);
    String city = await _getCityFromCoordinates(lat, lon);
    forecast = await ws.fiveDayForecastByLocation(lat, lon);

    // debugPrint("Weather after fetch: ${weather.toString()}");

    // debugPrint("Five day Forecast: $forecast");

    // debugPrint("weatherMain: $weather");

    setState(() {
      _weather = weather;
      _cityName = city;
      _backgroundImage = getRandomBackground();
      _loading = false;
    });
  }

  Future<void> fetchVisibilityAndAirQuality(double lat, double lon) async {
    final weatherUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$weatherApiKey&units=metric',
    );

    final airUrl = Uri.parse(
      'http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$weatherApiKey',
    );

    try {
      final weatherResponse = await http.get(weatherUrl);
      final airResponse = await http.get(airUrl);

      final weatherData = jsonDecode(weatherResponse.body);
      final airData = jsonDecode(airResponse.body);

      final visibility = weatherData['visibility']; // meters
      final aqi = airData['list'][0]['main']['aqi'];

      // debugPrint("Visibility is $visibility");
      // debugPrint("Air quality is $aqi");

      // Store these in your state if needed
      setState(() {
        _visibility = visibility;
        _aqi = aqi;
      });
    } catch (e) {
      // debugPrint("Error fetching visibility or air quality: $e");
    }
  }

  Future<void> _refreshWeather() async {
    await _getCurrentLocation();
  }

  Future<String> _getCityFromCoordinates(double lat, double lon) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&accept-language=en");

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'SableSky/1.0 tayyabnaveed1992@gmail.com',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Raw Response: $data");

        if (data['address'] != null) {
          final address = data['address'];
          return address['city'] ??
              address['town'] ??
              address['village'] ??
              address['county'] ??
              address['state'] ??
              "Unknown Location";
        }
      } else {
        debugPrint("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching city name: $e");
    }

    return "Unknown Location";
  }

  String? getRandomBackground() {
    if (_weather == null) return null;

    String description = _weather!.weatherMain ?? 'Clear';

    if (description == 'Clear') {
      if (_weather!.sunrise != null && _weather!.sunset != null) {
        final now = DateTime.now();
        final isDay =
            now.isAfter(_weather!.sunrise!) && now.isBefore(_weather!.sunset!);

        List<String> images = isDay
            ? weatherImages['ClearDay'] ?? [] // Daytime clear images
            : weatherImages['ClearNight'] ?? []; // Nighttime clear images

        if (images.isNotEmpty) {
          return images[Random().nextInt(images.length)];
        }
      }
    }

    // Default handling for other conditions
    List<String>? images = weatherImages[description];
    if (images != null && images.isNotEmpty) {
      return images[Random().nextInt(images.length)];
    }

    return null;
  }

  String? getRandomFeelsLikeMessage() {
    if (_weather == null) return null;

    final feelsLikeOptions = [
      'That may be so, but it feels like ',
      'Kinda feels like ',
      'But it feels like ',
      'Honestly, it feels more like ',
      'You’d swear it’s more like ',
      'Your skin says it’s actually ',
      'Don’t trust the numbers — it feels like ',
      'The forecasts say one thing, but it feels like ',
      'Could be wrong, but it really feels like ',
      'In reality, it’s more like ',
      'Whispers in the wind say it’s actually ',
      'Gut feeling? It’s closer to ',
    ];
    String feelsLike =
        feelsLikeOptions[Random().nextInt(feelsLikeOptions.length)];

    feelsLike += _weather!.tempFeelsLike?.toString() ?? 'N/A';

    // debugPrint(feelsLike);

    return feelsLike;
  }

  String timeUntilNextSunEvent() {
    final now = DateTime.now();

    if (_weather == null) {
      return 'Sunrise and/or Sunset data is unavailable';
    }

    if (now.isBefore(_weather!.sunrise!)) {
      final duration = _weather!.sunrise!.difference(now);
      return 'Sunrise in ${_formatDuration(duration)}';
    } else if (now.isBefore(_weather!.sunset!)) {
      final duration = _weather!.sunset!.difference(now);
      return 'Sunset in ${_formatDuration(duration)}';
    } else {
      final tomorrowSunrise = _weather!.sunrise!.add(Duration(days: 1));
      final duration = tomorrowSunrise.difference(now);
      return 'Sunrise in ${_formatDuration(duration)}';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  IconData getWeatherIcon(int? code, {double windSpeed = 0.0}) {
    if (code == null || code == 800) {
      return Icons.wb_sunny;
    } else if (code >= 200 && code < 300) {
      return Icons.thunderstorm;
    } else if (code >= 300 && code < 600) {
      return Icons.umbrella;
    } else if (code >= 600 && code < 700) {
      return Icons.ac_unit;
    } else if (code >= 700 && code < 800) {
      return Icons.foggy;
    } else if (code > 800) {
      return Icons.cloud;
    } else if (windSpeed > 10) {
      return Icons.air;
    }
    return Icons.wb_sunny;
  }

  String formatDateTime(DateTime? date) {
    if (date == null) return "";

    // Extract day abbreviation
    String weekday =
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.weekday % 7];

    // Extract time in 12-hour format with AM/PM
    String hour = date.hour == 0
        ? "12"
        : (date.hour > 12 ? "${date.hour - 12}" : "${date.hour}");
    String minute =
        date.minute.toString().padLeft(2, '0'); // Ensures "05" instead of "5"
    String period = date.hour >= 12 ? "PM" : "AM";

    return "$weekday, $hour:$minute $period"; // Example: "Wed, 5:00 PM"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background when loading so we can see the circular progress bar
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black,
              ),
            ),
          if (!_loading)
            Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            _backgroundImage ?? "assets/images/sunny1.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Dark Gradient Overlay at the Bottom
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha((0.5 * 255).toInt()),
                          Colors.black.withAlpha((0.8 * 255).toInt()),
                        ],
                        stops: [0.1, 0.7, 0.9],
                      ),
                    ),
                  ),
                ),
              ],
            ),

          if (!_loading) ...[
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: RefreshIndicator(
                onRefresh: _refreshWeather,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.white, size: 22),
                            Text(
                              _cityName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: 10),
                          _weather == null
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.only(left: 30),
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment
                                    //     .spaceBetween, // Pushes elements apart
                                    children: [
                                      Expanded(
                                        child: ShaderMask(
                                          shaderCallback: (Rect bounds) {
                                            return LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.white,
                                                Colors.white.withAlpha(
                                                    (0.3 * 255).toInt()),
                                                Colors.white.withAlpha(
                                                    (0.2 * 255).toInt()),
                                                Colors.transparent,
                                              ],
                                              stops: [0.0, 0.6, 0.8, 1.0],
                                            ).createShader(bounds);
                                          },
                                          blendMode: BlendMode.dstIn,
                                          child: Text(
                                            '${_weather!.temperature?.celsius?.round().toInt() ?? 0}°',
                                            style: GoogleFonts.poppins(
                                                fontSize: 130,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          // Row(
                          //   children: [
                          //     Padding(
                          //       padding: const EdgeInsets.only(left: 42, top: 0),
                          //       child: Text(
                          //         _weather?.weatherDescription ??
                          //             "Loading...",
                          //         maxLines: 1,
                          //         overflow: TextOverflow.ellipsis,
                          //         style: GoogleFonts.poppins(
                          //           fontSize: 20,
                          //           fontWeight: FontWeight.bold,
                          //           color: Colors.white,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          Transform.translate(
                            offset: Offset(80, -150),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                height: 30,
                                width: 200,
                                child: Transform.rotate(
                                  angle: -pi / 2,
                                  child: AutoSizeText(
                                    _weather?.weatherDescription ??
                                        "Loading...",
                                    maxLines: 1,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20, // Max size
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    minFontSize: 18,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 10),
                          Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            child: Text(
                              "${getRandomFeelsLikeMessage()}",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.aBeeZee(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 80),
                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                          width: double.infinity, // Full width
                          // height: 120,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(127),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withAlpha((0.2 * 255).toInt()),
                                blurRadius: 5,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    30,
                                    (index) => Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Container(
                                        width: 80,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withAlpha((0.2 * 255).toInt()),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              getWeatherIcon(
                                                forecast?[index]
                                                    .weatherConditionCode,
                                                windSpeed: forecast?[index]
                                                        .windSpeed ??
                                                    0.0,
                                              ),
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "${forecast?[index].temperature?.celsius?.round() ?? 0}°",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              formatDateTime(
                                                  forecast?[index].date),
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 20),

                              // Second item: maybe a summary or text
                              // Text(
                              //   "Next 30 hours of forecast",
                              //   style: GoogleFonts.poppins(
                              //     fontSize: 14,
                              //     color: Colors.white,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),

                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      timeUntilNextSunEvent(),
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Icon(Icons.wb_twilight_sharp,
                                          color: Colors.white, size: 22),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Humidity Container
                          Container(
                            width: 125,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(127),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withAlpha((0.2 * 255).toInt()),
                                  blurRadius: 5,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.grain,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _weather?.humidity != null
                                      ? 'Humidity: ${_weather!.humidity!.toInt()}%'
                                      : 'N/A',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Wind Container
                          Container(
                            width: 125,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(127),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withAlpha((0.2 * 255).toInt()),
                                  blurRadius: 5,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.wind_power,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _weather?.windSpeed != null
                                      ? 'Wind: ${_weather!.windSpeed!.toInt()} m/s'
                                      : 'N/A',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Gust Container
                          Container(
                            width: 125,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(127),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withAlpha((0.2 * 255).toInt()),
                                  blurRadius: 5,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.air_sharp,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  _weather?.windGust != null
                                      ? 'Gust: ${_weather!.windGust!.toInt()} m/s'
                                      : 'N/A',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Pressure Container
                          Container(
                            width: 125,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(127),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withAlpha((0.2 * 255).toInt()),
                                  blurRadius: 5,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.speed,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  _weather?.pressure != null
                                      ? 'Pres: ${_weather!.pressure!.toInt()} hpa'
                                      : 'N/A',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Pressure Container
                          Container(
                            width: 130,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(127),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withAlpha((0.2 * 255).toInt()),
                                  blurRadius: 5,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_sharp,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  _weather?.pressure != null
                                      ? 'Visibility: ${(_visibility! / 1000).round()} km'
                                      : 'N/A',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      DetailedAirQualityCard(aqi: _aqi),
                      SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          if (_loading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
